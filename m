Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 74BB86B0255
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 18:00:46 -0400 (EDT)
Received: by iodb91 with SMTP id b91so3385637iod.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 15:00:46 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id u98si3634300ioi.176.2015.08.05.15.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 15:00:45 -0700 (PDT)
Received: by iggf3 with SMTP id f3so42318937igg.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 15:00:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-2-git-send-email-ddstreet@ieee.org> <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 5 Aug 2015 18:00:26 -0400
Message-ID: <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 5, 2015 at 4:08 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed,  5 Aug 2015 09:46:41 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Add zpool_has_pool() function, indicating if the specified type of zpool
>> is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
>> available, without actually trying to allocate it, similar to
>> crypto_has_alg().
>>
>> This is used by a following patch to zswap that enables the dynamic
>> runtime creation of zswap zpools.
>>
>> ...
>>
>>  /**
>> + * zpool_has_pool() - Check if the pool driver is available
>> + * @type     The type of the zpool to check (e.g. zbud, zsmalloc)
>> + *
>> + * This checks if the @type pool driver is available.
>> + *
>> + * Returns: true if @type pool is available, false if not
>> + */
>> +bool zpool_has_pool(char *type)
>> +{
>> +     struct zpool_driver *driver = zpool_get_driver(type);
>> +
>> +     if (!driver) {
>> +             request_module("zpool-%s", type);
>> +             driver = zpool_get_driver(type);
>> +     }
>> +
>> +     if (!driver)
>> +             return false;
>> +
>> +     zpool_put_driver(driver);
>> +     return true;
>> +}
>
> This looks racy: after that zpool_put_driver() has completed, an rmmod
> will invalidate zpool_has_pool()'s return value.

the true/false return value is only a snapshot of that moment in time;
zswap's use of this is only to validate that the user-provided zpool
name is valid; if this fails, zswap will just return failure to the
user (or if this happens at init-time, falls back to LZO).  If this
succeeds, zswap still must use zpool_create_pool() which will fail if
the requested module can't be loaded.

essentially zswap does:

if (!zpool_has_pool(zpool_type) || !crypto_has_comp(compressor_type))
  return -EINVAL;

that allows it to check that the requested zpool and compressor types
are valid, before actually creating anything.  The creation of the
zpool and compressor do have error handling if either of them fail.

>
> If there's some reason why this can't happen, can we please have a code
> comment which reveals that reason?

zpool_create_pool() should work if this returns true, unless as you
say the module is rmmod'ed *and* removed from the system - since
zpool_create_pool() will call request_module() just as this function
does.  I can add a comment explaining that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
