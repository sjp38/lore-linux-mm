Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 30C476B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 02:36:47 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md4so6774974pbc.16
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:36:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id gn4si9790412pbc.141.2013.11.03.23.36.45
        for <linux-mm@kvack.org>;
        Sun, 03 Nov 2013 23:36:46 -0800 (PST)
Received: by mail-ee0-f51.google.com with SMTP id t10so882273eei.38
        for <linux-mm@kvack.org>; Sun, 03 Nov 2013 23:36:43 -0800 (PST)
Date: Mon, 4 Nov 2013 08:36:40 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131104073640.GF13030@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
 <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> I will look into doing the vma cache per thread instead of mm (I hadn't 
> really looked at the problem like this) as well as Ingo's suggestion on 
> the weighted LRU approach. However, having seen that we can cheaply and 
> easily reach around ~70% hit rate in a lot of workloads, makes me wonder 
> how good is good enough?

So I think it all really depends on the hit/miss cost difference. It makes 
little sense to add a more complex scheme if it washes out most of the 
benefits!

Also note the historic context: the _original_ mmap_cache, that I 
implemented 16 years ago, was a front-line cache to a linear list walk 
over all vmas (!).

This is the relevant 2.1.37pre1 code in include/linux/mm.h:

/* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
static inline struct vm_area_struct * find_vma(struct mm_struct * mm, unsigned long addr)
{
        struct vm_area_struct *vma = NULL;

        if (mm) {
                /* Check the cache first. */
                vma = mm->mmap_cache;
                if(!vma || (vma->vm_end <= addr) || (vma->vm_start > addr)) {
                        vma = mm->mmap;
                        while(vma && vma->vm_end <= addr)
                                vma = vma->vm_next;
                        mm->mmap_cache = vma;
                }
        }
        return vma;
}

See that vma->vm_next iteration? It was awful - but back then most of us 
had at most a couple of megs of RAM with just a few vmas. No RAM, no SMP, 
no worries - the mm was really simple back then.

Today we have the vma rbtree, which is self-balancing and a lot faster 
than your typical linear list walk search ;-)

So I'd _really_ suggest to first examine the assumptions behind the cache, 
it being named 'cache' and it having a hit rate does in itself not 
guarantee that it gives us any worthwile cost savings when put in front of 
an rbtree ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
