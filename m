Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D47006B0038
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 12:09:45 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id v186so98645401lfa.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:09:45 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 84si1280268lfp.363.2017.01.26.09.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 09:09:44 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id q89so24168695lfi.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:09:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2059ec0c-d817-9660-9a16-59fe46f3e3a7@samsung.com>
References: <bug-192571-27@https.bugzilla.kernel.org/> <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain> <1484719121.25232.1.camel@list.ru>
 <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com>
 <1485216185.5952.2.camel@list.ru> <CGME20170124201830epcas5p4aefd0bcb970be36f405d23c24e8cedbd@epcas5p4.samsung.com>
 <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com> <2059ec0c-d817-9660-9a16-59fe46f3e3a7@samsung.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 26 Jan 2017 12:09:03 -0500
Message-ID: <CALZtONDuV-B1uOL9yr0MdeM5+YwD0Y9ofqd3WQD-ZyJLFJt67g@mail.gmail.com>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Alexandr <sss123next@list.ru>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 24, 2017 at 11:02 PM, Chulmin Kim <cmlaika.kim@samsung.com> wrote:
> On 01/24/2017 03:16 PM, Dan Streetman wrote:
>>
>> On Mon, Jan 23, 2017 at 7:03 PM, Alexandr <sss123next@list.ru> wrote:
>>>
>>> -----BEGIN PGP SIGNED MESSAGE-----
>>> Hash: SHA512
>>>
>>>
>>>> Why would you do this?  There's no benefit of using zswap together
>>>> with zram.
>>>
>>>
>>> i just wanted to test zram and zswap, i still not dig to deep in it,
>>> but what i wanted is to use zram swap (with zswap disabled), and if it
>>> exceeded use real swap on block device with zswap enabled.
>>
>>
>> I don't believe that's possible, you can't enable zswap for only
>> specific swap devices; and anyway, if you fill up zram, you won't
>> really have any memory left for zswap to use will you?
>>
>> However, it shouldn't encounter any BUG(), like you saw.  If it's
>> reproducable for you, can you give details on how to reproduce it?
>>
>
> Hello. Mr. Streetman.
>
>
> Regarding to this problem, I have a question on zswap.
>
> Is there any reason that
> zswap_frontswap_load() does not call flush_dcache_page()?
>
> The zswap load function can dirty the page mapped to user space (might be
> shareable/writable) which seems exactly the condition mentioned in the
> definition of flush_dcache_page().
>
> I'm thinking that
> flush_dcache_page() should be called in the end of zswap_frontswap_load().
> Could you review my opinion?

I don't think it needs to, as i detailed in my response to the other thread.

Also, this is a different issue, I think - even if there is a cache
problem with pages loaded from zswap, i don't see how it would cause a
decompression failure - the zpool storage is the only code that has a
copy of its compressed pages, no userspace or any other kernel code
should be accessing any of it.

>
> Thanks!
> Chulmin Kim
>
>
>
>
>
>
>
>
>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
