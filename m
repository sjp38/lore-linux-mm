Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0892F8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:30:18 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v23-v6so549138ljc.8
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:30:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u125-v6sor1010991lja.19.2018.09.27.04.30.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 04:30:16 -0700 (PDT)
Subject: Re: [PATCH v3 3/4] devres: provide devm_kstrdup_const()
References: <20180924101150.23349-1-brgl@bgdev.pl>
 <20180924101150.23349-4-brgl@bgdev.pl>
 <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
 <9ad301dc-47ef-cd7d-699d-e51716d1703f@rasmusvillemoes.dk>
 <CAMuHMdWi0TQfu093po9-TniiLa2=T1E1c5R0S0tr85F==GcaGw@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <c9d0cf98-628d-f2c2-016c-c13d5bdb76c7@rasmusvillemoes.dk>
Date: Thu, 27 Sep 2018 13:30:13 +0200
MIME-Version: 1.0
In-Reply-To: <CAMuHMdWi0TQfu093po9-TniiLa2=T1E1c5R0S0tr85F==GcaGw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Kees Cook <keescook@chromium.org>, Bartosz Golaszewski <brgl@bgdev.pl>, Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, vivek.gautam@codeaurora.org, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, guro@fb.com, Huang Ying <ying.huang@intel.com>, =?UTF-8?Q?Bj=c3=b6rn_Andersson?= <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 2018-09-27 13:01, Geert Uytterhoeven wrote:
> Hi Rasmus,
> 
> On Thu, Sep 27, 2018 at 12:55 PM Rasmus Villemoes
> <linux@rasmusvillemoes.dk> wrote:
>> On 2018-09-27 01:13, Kees Cook wrote:
>>
>> Just drop devm_kfree_const and teach devm_kfree to ignore
>> is_kernel_rodata(). That avoids the 50-100 bytes of overhead for adding
>> yet another EXPORT_SYMBOL and makes it easier to port drivers to
>> devm_kstrdup_const (and avoids the bugs Kees is worried about). devm
>> managed resources are almost never freed explicitly, so that single
>> extra comparison in devm_kfree shouldn't matter for performance.
> 
> I guess we can also teach kfree() to ignore is_kernel_rodata(), and
> drop kfree_const()?

In principle, yes, but the difference is that kfree() is called a lot
more frequently, and on normal code paths, whereas devm_kfree is more
often (though not always) called on error paths.

The goal of _const variants of strdup is to save some memory, so one
place to start is to reduce the .text overhead of that feature. And it
avoids introducing subtle bugs if some devm_kfree() call is missed
during conversion to devm_kstrdup_const().

Rasmus
