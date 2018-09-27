Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD0C98E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:55:15 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e12-v6so545415ljk.3
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 03:55:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13-v6sor984416lja.1.2018.09.27.03.55.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 03:55:13 -0700 (PDT)
Subject: Re: [PATCH v3 3/4] devres: provide devm_kstrdup_const()
References: <20180924101150.23349-1-brgl@bgdev.pl>
 <20180924101150.23349-4-brgl@bgdev.pl>
 <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <9ad301dc-47ef-cd7d-699d-e51716d1703f@rasmusvillemoes.dk>
Date: Thu, 27 Sep 2018 12:55:10 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 2018-09-27 01:13, Kees Cook wrote:
> On Mon, Sep 24, 2018 at 3:11 AM, Bartosz Golaszewski <brgl@bgdev.pl> wrote:
>> Provide a resource managed version of kstrdup_const(). This variant
>> internally calls devm_kstrdup() on pointers that are outside of
>> .rodata section and returns the string as is otherwise.
>>
>> Also provide a corresponding version of devm_kfree().
>>
>> +/**
>> + * devm_kfree_const - Resource managed conditional kfree
>> + * @dev: device this memory belongs to
>> + * @p: memory to free
>> + *
>> + * Function calls devm_kfree only if @p is not in .rodata section.
>> + */
>> +void devm_kfree_const(struct device *dev, const void *p)
>> +{
>> +       if (!is_kernel_rodata((unsigned long)p))
>> +               devm_kfree(dev, p);
>> +}
>> +EXPORT_SYMBOL(devm_kfree_const);
>> +
>>  /**
>>   * devm_kmemdup - Resource-managed kmemdup
>>   * @dev: Device this memory belongs to
>> diff --git a/include/linux/device.h b/include/linux/device.h
>> index 33f7cb271fbb..79ccc6eb0975 100644
>> --- a/include/linux/device.h
>> +++ b/include/linux/device.h
>> @@ -693,7 +693,10 @@ static inline void *devm_kcalloc(struct device *dev,
>>         return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
>>  }
>>  extern void devm_kfree(struct device *dev, const void *p);
>> +extern void devm_kfree_const(struct device *dev, const void *p);
> 
> With devm_kfree and devm_kfree_const both taking "const", how are
> devm_kstrdup_const() and devm_kfree_const() going to be correctly
> paired at compile time? (i.e. I wasn't expecting the prototype change
> to devm_kfree())

Just drop devm_kfree_const and teach devm_kfree to ignore
is_kernel_rodata(). That avoids the 50-100 bytes of overhead for adding
yet another EXPORT_SYMBOL and makes it easier to port drivers to
devm_kstrdup_const (and avoids the bugs Kees is worried about). devm
managed resources are almost never freed explicitly, so that single
extra comparison in devm_kfree shouldn't matter for performance.

Rasmus
