Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DEF16B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 06:07:09 -0400 (EDT)
Received: by igr7 with SMTP id 7so7849177igr.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:07:09 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id rs7si1238352igb.46.2015.08.06.03.07.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 03:07:08 -0700 (PDT)
Received: by iodb91 with SMTP id b91so16092600iod.1
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 03:07:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150805131406.8bd8a1a6d2a6691aa6eedd34@linux-foundation.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-4-git-send-email-ddstreet@ieee.org> <20150805131406.8bd8a1a6d2a6691aa6eedd34@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 6 Aug 2015 06:06:49 -0400
Message-ID: <CALZtONCquXbE-dHWQUfKL_OSO7Bk5HN+t2EZduoD11vcaiJxmQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] zswap: change zpool/compressor at runtime
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 5, 2015 at 4:14 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed,  5 Aug 2015 09:46:43 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Update the zpool and compressor parameters to be changeable at runtime.
>> When changed, a new pool is created with the requested zpool/compressor,
>> and added as the current pool at the front of the pool list.  Previous
>> pools remain in the list only to remove existing compressed pages from.
>> The old pool(s) are removed once they become empty.
>>
>> +/*********************************
>> +* param callbacks
>> +**********************************/
>> +
>> +static int __zswap_param_set(const char *val, const struct kernel_param *kp,
>> +                          char *type, char *compressor)
>> +{
>> +     struct zswap_pool *pool, *put_pool = NULL;
>> +     char str[kp->str->maxlen], *s;
>
> What's the upper bound on the size of this variable-sized array?

the kernel_param in this function will always be either
zswap_compressor_kparam or zswap_zpool_kparam, which are defined at
the top, and their maxlen fields are set to sizeof(their string),
which is either CRYPTO_MAX_ALG_NAME (currently 64) or 32 (arbitrary
max for zpool name).

I can also add a comment here to clarify that.

>
>> +     int ret;
>> +
>> +     strlcpy(str, val, kp->str->maxlen);
>> +     s = strim(str);
>> +
>> +     /* if this is load-time (pre-init) param setting,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
