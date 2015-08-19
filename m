Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id EC1656B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 22:20:43 -0400 (EDT)
Received: by igfj19 with SMTP id j19so94861504igf.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 19:20:43 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id s20si13550445ioi.117.2015.08.18.19.20.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 19:20:43 -0700 (PDT)
Received: by igui7 with SMTP id i7so94442912igu.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 19:20:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150818153818.cab58a99f60113c2aca2f006@linux-foundation.org>
References: <1439928361-31294-1-git-send-email-ddstreet@ieee.org> <20150818153818.cab58a99f60113c2aca2f006@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 18 Aug 2015 22:20:03 -0400
Message-ID: <CALZtONCjUgUWxO6=SYui-cWE2m4hi9cJ-jKPHaRha707NimB0w@mail.gmail.com>
Subject: Re: [PATCH 1/2] zpool: define and use max type length
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, kbuild test robot <fengguang.wu@intel.com>

On Tue, Aug 18, 2015 at 6:38 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 18 Aug 2015 16:06:00 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add ZPOOL_MAX_TYPE_NAME define, and change zpool_driver *type field to
>> type[ZPOOL_MAX_TYPE_NAME].  Remove redundant type field from struct zpool
>> and use zpool->driver->type instead.
>>
>> The define will be used by zswap for its zpool param type name length.
>>
>
> Patchset is fugly.  All this putzing around with fixed-length strings,
> worrying about overflow and is-it-null-terminated-or-isnt-it.  Shudder.
>
> It's much better to use variable-length strings everywhere.  We're not
> operating in contexts which can't use kmalloc, we're not
> performance-intensive and these strings aren't being written to
> fixed-size fields on disk or anything.  Why do we need any fixed-length
> strings?
>
> IOW, why not just replace that alloca with a kstrdup()?

for the zpool drivers (zbud and zsmalloc), the type is actually just
statically assigned, e.g. .type = "zbud", so you're right the *type is
better than type[].  I'll update it.

>
>> --- a/include/linux/zpool.h
>> +++ b/include/linux/zpool.h
>>
>> ...
>>
>> @@ -79,7 +77,7 @@ static struct zpool_driver *zpool_get_driver(char *type)
>>
>>       spin_lock(&drivers_lock);
>>       list_for_each_entry(driver, &drivers_head, list) {
>> -             if (!strcmp(driver->type, type)) {
>> +             if (!strncmp(driver->type, type, ZPOOL_MAX_TYPE_NAME)) {
>
> Why strncmp?  Please tell me these strings are always null-terminated.

Yep, you're right.  The driver->type always is, and the type param is
passed in from sysfs, which we can rely on to be null-terminated.

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
