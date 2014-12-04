Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A24F76B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 02:17:06 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so17473554pab.33
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 23:17:06 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bh4si41822362pbc.5.2014.12.03.23.17.03
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 23:17:05 -0800 (PST)
Date: Thu, 4 Dec 2014 16:20:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mmotm:master 185/397] mm/nommu.c:1193:8: warning: assignment
 makes pointer from integer without a cast
Message-ID: <20141204072030.GC12141@js1304-P5Q-DELUXE>
References: <201411270833.w1auTAKD%fengguang.wu@intel.com>
 <20141127051311.GB6755@js1304-P5Q-DELUXE>
 <20141201150851.019d6a8aeaf269af3f94354a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141201150851.019d6a8aeaf269af3f94354a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Dec 01, 2014 at 03:08:51PM -0800, Andrew Morton wrote:
> On Thu, 27 Nov 2014 14:13:12 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > @@ -1190,7 +1190,7 @@ static int do_mmap_private(struct vm_area_struct *vma,
> >  		kdebug("try to alloc exact %lu pages", total);
> >  		base = alloc_pages_exact(len, GFP_KERNEL);
> >  	} else {
> > -		base = __get_free_pages(GFP_KERNEL, order);
> > +		base = (void *)__get_free_pages(GFP_KERNEL, order);
> >  	}
> 
> __get_free_pages() is so irritating.  I'm counting 268 calls, at least
> 172 of which have to typecast the return value.
> 
> static inline void *
> someone_think_of_a_name_for_this(gfp_t gfp_mask, unsigned int order)
> {
> 	return (void *)__get_free_pages(gfp, order);
> }
> 

Hello,

I think that changing return type of __get_free_pages() is better than
introducing new interface. With it, we only need to fix 268 - 172 = 96
callsites. And, get_zeroed_page() should also be fixed. Almost every
caller of this function do typecast. :)

I'm not familiar with this kind of massive change so it'd be better to
be done it by another developer.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
