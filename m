Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5152C6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:17:22 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 97so11802047wrb.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:17:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 55si6785203wrz.265.2017.09.26.01.17.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 01:17:21 -0700 (PDT)
Date: Tue, 26 Sep 2017 10:17:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] a question about mlockall() and mprotect()
Message-ID: <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
References: <59CA0847.8000508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59CA0847.8000508@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On Tue 26-09-17 15:56:55, Xishi Qiu wrote:
> When we call mlockall(), we will add VM_LOCKED to the vma,
> if the vma prot is ---p,

not sure what you mean here. apply_mlockall_flags will set the flag on
all vmas except for special mappings (mlock_fixup). This phase will
cause that memory reclaim will not free already mapped pages in those
vmas (see page_check_references and the lazy mlock pages move to
unevictable LRUs).

> then mm_populate -> get_user_pages will not alloc memory.

mm_populate all the vmas with pages. Well there are certainly some
constrains - e.g. memory cgroup hard limit might be hit and so the
faulting might fail.

> I find it said "ignore errors" in mm_populate()
> static inline void mm_populate(unsigned long addr, unsigned long len)
> {
> 	/* Ignore errors */
> 	(void) __mm_populate(addr, len, 1);
> }

But we do not report the failure because any failure past
apply_mlockall_flags would be tricky to handle. We have already dropped
the mmap_sem lock so some other address space operations could have
interfered.
 
> And later we call mprotect() to change the prot, then it is
> still not alloc memory for the mlocked vma.
> 
> My question is that, shall we alloc memory if the prot changed,
> and who(kernel, glibc, user) should alloc the memory?

I do not understand your question but if you are asking how to get pages
to map your vmas then touching that area will fault the memory in.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
