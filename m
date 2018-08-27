Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1C486B3F7E
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:01:58 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k204-v6so7937498ite.1
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 02:01:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y196-v6sor5094686iod.115.2018.08.27.02.01.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 02:01:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4a576f65b8fb3a0e6f0ca662e89070eb982be298.camel@perches.com>
References: <20180827082101.5036-1-brgl@bgdev.pl> <4a576f65b8fb3a0e6f0ca662e89070eb982be298.camel@perches.com>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Mon, 27 Aug 2018 11:01:57 +0200
Message-ID: <CAMRc=McVQ6co1KispVNotLOj4t6Pok0F+j4X9eYnrpDTm-CYaQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] devres: provide devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2018-08-27 10:42 GMT+02:00 Joe Perches <joe@perches.com>:
> On Mon, 2018-08-27 at 10:21 +0200, Bartosz Golaszewski wrote:
>> Provide a resource managed version of kstrdup_const(). This variant
>> internally calls devm_kstrdup() on pointers that are outside of
>> .rodata section. Also provide a corresponding version of devm_kfree().
> []
>> diff --git a/mm/util.c b/mm/util.c
> []
>>  /**
>>   * kstrdup - allocate space for and copy an existing string
>>   * @s: the string to duplicate
>> @@ -78,6 +92,27 @@ const char *kstrdup_const(const char *s, gfp_t gfp)
>>  }
>>  EXPORT_SYMBOL(kstrdup_const);
>>
>> +/**
>> + * devm_kstrdup_const - resource managed conditional string duplication
>> + * @dev: device for which to duplicate the string
>> + * @s: the string to duplicate
>> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
>> + *
>> + * Function returns source string if it is in .rodata section otherwise it
>> + * fallbacks to devm_kstrdup.
>> + *
>> + * Strings allocated by devm_kstrdup_const will be automatically freed when
>> + * the associated device is detached.
>> + */
>> +char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
>> +{
>> +     if (is_kernel_rodata((unsigned long)s))
>> +             return s;
>> +
>> +     return devm_kstrdup(dev, s, gfp);
>> +}
>> +EXPORT_SYMBOL(devm_kstrdup_const);
>
> Doesn't this lose constness and don't you get
> a compiler warning here?
>

Yes it does but for some reason gcc 6.3 didn't complain...

> The kstrdup_const function returns a const char *,
> why shouldn't this?
>

It probably should, I'll fix it for v2.

Bart
