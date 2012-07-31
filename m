Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id DBB116B005A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:53:04 -0400 (EDT)
Date: Tue, 31 Jul 2012 15:52:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: page allocation failure
Message-ID: <20120731135258.GB7867@tiehlicka.suse.cz>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B900@HKMAIL02.nvidia.com>
 <20120730141329.GC9981@tiehlicka.suse.cz>
 <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DA@HKMAIL02.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157B9DA@HKMAIL02.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "andi@firstfloor.org" <andi@firstfloor.org>

On Tue 31-07-12 13:32:36, Shawn Joo wrote:
> Thank you for attention and comment, here is following question.
> 
> 
> 
> 1.  In general if order 3(32KB) is required to be allocated, if
> "size-32768" cache does not have available slab, then "size-32768"
> will request memory from buddy Here watermark is involved as important
> factor.
>
> (I would like to know how to increase the number of object on the
> cache, because when cache is created by "kmem_cache_create", there is
> only object size, but no number of the object)

I am not familiar with the slab allocator much but I do not think this
is possible. At least slab drops unused objects if the system is under
memory pressure so I do not see how this would help. I guess the problem
is the high order allocation itself (maybe you should consider disable
jumbo frames?)

>
> d my understanding is correct?, please correct.
> 
> 2.     In my init.rc, min_free_order_shift is set to 4.

I am not familiar with such a tunable. Google says it might be something
android specific
(https://dev.openwrt.org/browser/trunk/target/linux/goldfish/patches-2.6.30/0055-mm-Add-min_free_order_shift-tunable.patch?rev=16459)
 
> If I decrease this value, it should be helpful.

No, quite opposite. From the quick glance at the patch it makes the
rules for high order balancing in __zone_watermark_ok more relaxed.
min_free_order_shift == 1 is what we do in the upstream kernel.
Anyway this will not help much if these allocations are continuous. It
would just get the system under a bigger memory pressure because it
allows to allocate more memory.

> 
> any recommend size of "min_free_order_shift"? If I can have doc about
> it, it will be helpful.

You have to ask the patch author for that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
