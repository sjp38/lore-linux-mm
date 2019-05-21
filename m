Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA5F7C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 765E320863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:18:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="hK6xaZo+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 765E320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE05C6B0003; Tue, 21 May 2019 04:18:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8FA36B0005; Tue, 21 May 2019 04:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7F466B0006; Tue, 21 May 2019 04:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE776B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:18:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so29426276eda.15
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:18:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=p3Nrdg6Ctrkg1BnYl6D+p3VJZfh4Lp9djB6gn7+dVDY=;
        b=K+u9nItC86HvNNXtkF7f3ATmuZr/WxL3EJi/xm2wvD21MLqwx8vCOMsyqLziL/gWAF
         nVWeQ28wm6dig5f4op+k4vGIitFR/NMJN/YRDDea3ZOTa4e+1i8GB4Mv5X3Ubm2kZG0W
         o7Pwt4wjcktAQ9PjMuKFQVeYHfMxOD/FVrVVlB7mej7RmG2o7T+/jy2AzRNPR0++Y+Jt
         jID0/PXVbazscrH3AyTQ/Y2gDainrwh6uzbXoU0RhI+QQNDqQCLHHF7vusl973+uHxQi
         Csf6rAj/bVaZyr6htC20M14FvAkDxZ9GTDVx4Aklrv5ewIxYbn5STs7AAaahzXliRu2h
         IsqQ==
X-Gm-Message-State: APjAAAV3EN4Cc3L5BwAUV5Ml54J89rAxhxD0vOHDWyy21quoZeUwTgIB
	8+gtOQic3oyEV2h89TcZ2upZ6fwlz7g+cbNCiQ5EKY/qXMkcPiTN2X0Z+cR6Q++KfHt7a3r5Xu3
	zw7SodS7YegAb8TdF50YSYBmHvDOcPOhZeP/pF5HBsQdrm5Yral0qod/Agrk+Nz7PmA==
X-Received: by 2002:a50:a3a2:: with SMTP id s31mr79985336edb.254.1558426703043;
        Tue, 21 May 2019 01:18:23 -0700 (PDT)
X-Received: by 2002:a50:a3a2:: with SMTP id s31mr79985268edb.254.1558426702241;
        Tue, 21 May 2019 01:18:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558426702; cv=none;
        d=google.com; s=arc-20160816;
        b=mhiBmGyfboN/RJqzGsjpUvSUj6KK3W3ygO+aBeI6eSFCz4sAvryJB4Ab2nKjrWjAS4
         kcxVLcr61oGnB/dx6QVP+ayscryClxquVyfpMgFwOnwcRWPVPvkxJuVtzuIqhUyPojlZ
         ztoqcEYTASS35gPlgnRRRBtf9W10ajBI5avaRWfvbmsJTZLphnehhcbW5Gok8jjCJPWU
         R2JZa3z+2DdRJ6vcYk4m9JFlv8AoU+RcBQQ2DFVgcl7uua+UcBqpz92DoHszolO/RDK7
         aEOo1+yovOL0HWhd1beMUKaPgNl3Wv9JQBxZtsrpAWtEd2vf/pFJlpKUn61ilaolHCuZ
         d7zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=p3Nrdg6Ctrkg1BnYl6D+p3VJZfh4Lp9djB6gn7+dVDY=;
        b=kFHojIo4SbCUu8DYVoqPOyUJInra7AKxvPDLHxv5FK2leiNhF8Cp6bKwtKAJ51DMCa
         3XDHRt+OkbDWg7Xdm6AEqRdwdg/W5hQNQzrTJUrGbAR5BJbwAODg1Bm+N7bAet/XHeRO
         XcnQ3UHdjNAYugGtTZvMwHAtM9lqYKI4HGRYb1jO8caCxu6YQEGhm4K9dTE5sDiuW6eA
         r6hAM9a6/GO6AWA9N51yw92vRd30gt1LdDbauM4GsAl+P6n1470tpCjjUB3fSJ6wUSNA
         NgdFvdmrFsZLOPWVQxvs0mdawsPBx8xMsKLNMOzme6WUwJ56istUCP/q0zsfLnKx7/JD
         gbSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hK6xaZo+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id dc4sor5837755ejb.20.2019.05.21.01.18.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 01:18:22 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hK6xaZo+;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=p3Nrdg6Ctrkg1BnYl6D+p3VJZfh4Lp9djB6gn7+dVDY=;
        b=hK6xaZo+Q3D4T9iE+RYYq+foJG26LDhmheIS8o9IlQBdPRWi/ltIIm0+lJrFQADlP6
         iSZJMqhE6aV4PzfH/xzJ4PQELLlvSeG59Np+3zAPfRBTrJOKHKwK74MyieTpD7SkrGlZ
         Ilm5e6kNz65ineaE2aEisGF0AbM6w7l+gK+r8iNe0PsNC7VwP/3Iq1N+OxbkWBBNc1J7
         zT/RDFzFJqcNh5hyJMPsPIPYNw7ET8J2qORbJ7zQ80MC8mXOOTACc4LBr2rKlDwczDce
         PIvq51WbfwcmPKd2kgrHOtStGUgN+9hcGlYxcfENyoDE/PddYtm0Ii3n2f97AVCok61k
         Fp6Q==
X-Google-Smtp-Source: APXvYqzTgjNri1NtSKT6LkgIPj3l6byv2T33Chcz9SoRYRJhBXgqJUnbmuXvLBBg0xaCJu8rXsYRhA==
X-Received: by 2002:a17:906:6c15:: with SMTP id j21mr51373767ejr.33.1558426701716;
        Tue, 21 May 2019 01:18:21 -0700 (PDT)
Received: from box.localdomain (mm-192-235-121-178.mgts.dynamic.pppoe.byfly.by. [178.121.235.192])
        by smtp.gmail.com with ESMTPSA id k37sm6250102edb.11.2019.05.21.01.18.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 01:18:21 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 2063C1005F5; Tue, 21 May 2019 11:18:21 +0300 (+03)
Date: Tue, 21 May 2019 11:18:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
	keith.busch@intel.com, kirill.shutemov@linux.intel.com,
	alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
	andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz,
	cl@linux.com, riel@surriel.com, keescook@chromium.org,
	hannes@cmpxchg.org, npiggin@gmail.com,
	mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
	aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
	mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
	jannh@google.com, kilobyte@angband.pl, linux-api@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/7] mm: Extend copy_vma()
Message-ID: <20190521081821.fbngbxk7lzwrb7md@box>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <155836081252.2441.9024100415314519956.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155836081252.2441.9024100415314519956.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 05:00:12PM +0300, Kirill Tkhai wrote:
> This prepares the function to copy a vma between
> two processes. Two new arguments are introduced.

This kind of changes requires a lot more explanation in commit message,
describing all possible corner cases.

For instance, I would really like to see a story on why logic around
need_rmap_locks is safe after the change.

> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/mm.h |    4 ++--
>  mm/mmap.c          |   33 ++++++++++++++++++++++++---------
>  mm/mremap.c        |    4 ++--
>  3 files changed, 28 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834ac32b7..afe07e4a76f8 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2329,8 +2329,8 @@ extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
>  	struct rb_node **, struct rb_node *);
>  extern void unlink_file_vma(struct vm_area_struct *);
>  extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
> -	unsigned long addr, unsigned long len, pgoff_t pgoff,
> -	bool *need_rmap_locks);
> +	struct mm_struct *, unsigned long addr, unsigned long len,
> +	pgoff_t pgoff, bool *need_rmap_locks, bool clear_flags_ctx);
>  extern void exit_mmap(struct mm_struct *);
>  
>  static inline int check_data_rlimit(unsigned long rlim,
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 57803a0a3a5c..99778e724ad1 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3195,19 +3195,21 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
>  }
>  
>  /*
> - * Copy the vma structure to a new location in the same mm,
> - * prior to moving page table entries, to effect an mremap move.
> + * Copy the vma structure to new location in the same vma
> + * prior to moving page table entries, to effect an mremap move;
>   */
>  struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
> -	unsigned long addr, unsigned long len, pgoff_t pgoff,
> -	bool *need_rmap_locks)
> +				struct mm_struct *mm, unsigned long addr,
> +				unsigned long len, pgoff_t pgoff,
> +				bool *need_rmap_locks, bool clear_flags_ctx)
>  {
>  	struct vm_area_struct *vma = *vmap;
>  	unsigned long vma_start = vma->vm_start;
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct vm_userfaultfd_ctx uctx;
>  	struct vm_area_struct *new_vma, *prev;
>  	struct rb_node **rb_link, *rb_parent;
>  	bool faulted_in_anon_vma = true;
> +	unsigned long flags;
>  
>  	/*
>  	 * If anonymous vma has not yet been faulted, update new pgoff
> @@ -3220,15 +3222,25 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  
>  	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
>  		return NULL;	/* should never get here */
> -	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
> -			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
> -			    vma->vm_userfaultfd_ctx);
> +
> +	uctx = vma->vm_userfaultfd_ctx;
> +	flags = vma->vm_flags;
> +	if (clear_flags_ctx) {
> +		uctx = NULL_VM_UFFD_CTX;
> +		flags &= ~(VM_UFFD_MISSING | VM_UFFD_WP | VM_MERGEABLE |
> +			   VM_LOCKED | VM_LOCKONFAULT | VM_WIPEONFORK |
> +			   VM_DONTCOPY);
> +	}

Why is the new logic required? No justification given.

> +
> +	new_vma = vma_merge(mm, prev, addr, addr + len, flags, vma->anon_vma,
> +			    vma->vm_file, pgoff, vma_policy(vma), uctx);
>  	if (new_vma) {
>  		/*
>  		 * Source vma may have been merged into new_vma
>  		 */
>  		if (unlikely(vma_start >= new_vma->vm_start &&
> -			     vma_start < new_vma->vm_end)) {
> +			     vma_start < new_vma->vm_end) &&
> +			     vma->vm_mm == mm) {

How can vma_merge() succeed if vma->vm_mm != mm?

>  			/*
>  			 * The only way we can get a vma_merge with
>  			 * self during an mremap is if the vma hasn't
> @@ -3249,6 +3261,9 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  		new_vma = vm_area_dup(vma);
>  		if (!new_vma)
>  			goto out;
> +		new_vma->vm_mm = mm;
> +		new_vma->vm_flags = flags;
> +		new_vma->vm_userfaultfd_ctx = uctx;
>  		new_vma->vm_start = addr;
>  		new_vma->vm_end = addr + len;
>  		new_vma->vm_pgoff = pgoff;
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 37b5b2ad91be..9a96cfc28675 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -352,8 +352,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
>  		return err;
>  
>  	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
> -	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
> -			   &need_rmap_locks);
> +	new_vma = copy_vma(&vma, mm, new_addr, new_len, new_pgoff,
> +			   &need_rmap_locks, false);
>  	if (!new_vma)
>  		return -ENOMEM;
>  
> 

