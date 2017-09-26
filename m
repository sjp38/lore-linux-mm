Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA436B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:03:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so17441420pfj.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:03:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j13si5588713pga.73.2017.09.26.02.02.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 02:02:59 -0700 (PDT)
Date: Tue, 26 Sep 2017 11:02:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] a question about mlockall() and mprotect()
Message-ID: <20170926090255.jmocezs6s3lpd6p4@dhcp22.suse.cz>
References: <59CA0847.8000508@huawei.com>
 <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
 <59CA125C.8000801@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59CA125C.8000801@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On Tue 26-09-17 16:39:56, Xishi Qiu wrote:
> On 2017/9/26 16:17, Michal Hocko wrote:
> 
> > On Tue 26-09-17 15:56:55, Xishi Qiu wrote:
> >> When we call mlockall(), we will add VM_LOCKED to the vma,
> >> if the vma prot is ---p,
> > 
> > not sure what you mean here. apply_mlockall_flags will set the flag on
> > all vmas except for special mappings (mlock_fixup). This phase will
> > cause that memory reclaim will not free already mapped pages in those
> > vmas (see page_check_references and the lazy mlock pages move to
> > unevictable LRUs).
> > 
> >> then mm_populate -> get_user_pages will not alloc memory.
> > 
> > mm_populate all the vmas with pages. Well there are certainly some
> > constrains - e.g. memory cgroup hard limit might be hit and so the
> > faulting might fail.
> > 
> >> I find it said "ignore errors" in mm_populate()
> >> static inline void mm_populate(unsigned long addr, unsigned long len)
> >> {
> >> 	/* Ignore errors */
> >> 	(void) __mm_populate(addr, len, 1);
> >> }
> > 
> > But we do not report the failure because any failure past
> > apply_mlockall_flags would be tricky to handle. We have already dropped
> > the mmap_sem lock so some other address space operations could have
> > interfered.
> >  
> >> And later we call mprotect() to change the prot, then it is
> >> still not alloc memory for the mlocked vma.
> >>
> >> My question is that, shall we alloc memory if the prot changed,
> >> and who(kernel, glibc, user) should alloc the memory?
> > 
> > I do not understand your question but if you are asking how to get pages
> > to map your vmas then touching that area will fault the memory in.
> 
> Hi Michal,
> 
> syscall mlockall() will first apply the VM_LOCKED to the vma, then
> call mm_populate() to map the vmas.
> 
> mm_populate
> 	populate_vma_page_range
> 		__get_user_pages
> 			check_vma_flags
> And the above path maybe return -EFAULT in some case, right?
> 
> If we call mprotect() to change the prot of vma, just let
> check_vma_flags() return 0, then we will get the mlocked pages
> in following page-fault, right?

Any future page fault to the existing vma will result in the mlocked
page. That is what VM_LOCKED guarantess.

> My question is that, shall we map the vmas immediately when
> the prot changed? If we should map it immediately, who(kernel, glibc, user)
> do this step?

This is still very fuzzy. What are you actually trying to achieve?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
