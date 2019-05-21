Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBE7CC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:48:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57EF72173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:48:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RhPoX/bh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57EF72173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0946B0003; Mon, 20 May 2019 22:48:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4FD06B0005; Mon, 20 May 2019 22:48:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1A106B0006; Mon, 20 May 2019 22:48:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 892B86B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:48:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s5so11073745pgv.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:48:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/lAmntZ5U0fXlP9cYoBen6KqVrgsWey2T1FPxI6ygc8=;
        b=k+UE0RuDYywrFtP9l/lrdBhXViuXlCye3Tm6g/mTR/YLckQFvWqpHREnPrYVzThhsU
         rii6iD3anMdY7uv/AE4Y0TVxygKwiSgaxHxS1CwfPEcyXMFY1yewtI2wq0stShSVG0AF
         EPYFWoyVY2kWP/6655RzpUe0VrmR3pgiyndFJ4Y9d5MGiEcCCXgF/lBoRsaV+sLD77JJ
         GCyrpnxPTHpnGlGWUFdeC09gqn35BVVuXKNVQ0z/xZJ2DH4ZLpj9YEqHBx9kd7/QdcRB
         CnCnCTzp9FBPbkHNXDjcceKA1xqjBsJxnzoaVrshywjzAGUvl7113DFDhUo+5pZe4YFA
         fOgw==
X-Gm-Message-State: APjAAAWojixZd7OKFMqzFvnBOmeth9QChYj/QSbJNwM2HpnmOBTJ925G
	2zG0CrAAgZF+/Ayzjf4nB5VAZCJRKGk49+3lRPgAtFT0p0BSrxa13NqsVxXKoKWFWnqAjbq3zdA
	HjUlo6qn7wbPEHWOSgn7aWyrSSe8JrW4b0UVKU0cS6MVvQhvWEy1i05PZL/9EQrI=
X-Received: by 2002:a17:902:e108:: with SMTP id cc8mr68994131plb.145.1558406909055;
        Mon, 20 May 2019 19:48:29 -0700 (PDT)
X-Received: by 2002:a17:902:e108:: with SMTP id cc8mr68994066plb.145.1558406908070;
        Mon, 20 May 2019 19:48:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558406908; cv=none;
        d=google.com; s=arc-20160816;
        b=CPMX+5UyKsM1iRDiyRX4ZgZgpnYYcUQjScbkc6/GUKiGi5qYjKvCgl030sfQRpVOso
         NQ5UNp0M2Z+WnOsyx78bTrYRCpeF7n5UsaLanH3BdgExGPZ4YM+aHuleAPIH8lwfKFur
         T3LixqA7LoXYN1WmSISJYJmxAxXUQLFYY3v+08dnDLSYWH9O3cyzrhV0KyYKCljjGTWB
         9qTNZq3Y6iipNDkQGXrLTUyojH6/uDoquXl+/eVgsgJv+yzvVtwxVgcyBee0/xV0ooro
         I2x//xu9DqVRxGoA4YLwwA32ZpaT/j0j6022ycsVkRKUEztbOGsNJGiaymOwnh++LXRB
         G+6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=/lAmntZ5U0fXlP9cYoBen6KqVrgsWey2T1FPxI6ygc8=;
        b=Apdv/Ee0ooJQ1PPXb0Igp9EkzK8tLRxM7Y8jddfKkUgiVi5klTmWyZ3ZdW4kmIUJ/F
         y5wTrtWmL/FlkeoRPar+Z+Fg9MxiIOC5in56wzYtFVD7wlCN7CrhycPzQU6VHqMjROhY
         pcZv6PxUjjIdMyP70ZWZTRwLv1Ke0UJkJxP102TCziP5nIJZ5ni8AoHudwzrnQP1X0WV
         F21+jQFOKG4ZPen+Zc5Gy6faH9z8W5/LoRM98AXrDtaeu67psjUy/EyzjkDTXWwVWjy9
         JqfPu9c05YAVZaKGzFdqx41zo/pzMtt+npb12x8cwEJM8OW6/f4s8xPt4EiUfO9isQ59
         wafw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="RhPoX/bh";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor18713285plc.24.2019.05.20.19.48.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 19:48:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="RhPoX/bh";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/lAmntZ5U0fXlP9cYoBen6KqVrgsWey2T1FPxI6ygc8=;
        b=RhPoX/bh3Hg+pTgTY27MVkxnws4/wk8skg3w9rNOGvc47vb30HgYwox4HqX5x2VWQX
         7Gua/nRhvgBbMyH7c6chRu3LD6wCEblGRRt6G/85g2vmfD2ozAbUyGjp+N6W8yHtR5Xh
         WsxoPP3No1TiniPAL7wj07y8c3a3JjslWSeNLhXosfdXIw76MtNg8us2Wflc+6vkquqh
         zrBnoRc+c11QGMpOLj2c8QywTXv/rUb6s3YAxsm1QjxIKUU2425x2F9f2vagK/ZfFuId
         ptjO0qxYK8t3otHzMnPZt3glpvlIgxzJKkVElVcODzrz/P+aOx4EdPZK+k2iHPcLwOiP
         aqYw==
X-Google-Smtp-Source: APXvYqyCxR4N09bj3zAr4PCFA+mhTez8UuDdzvEQ3vFKD6Gsg1ER/nP1fbpV8Nx41xfxlkCOXfJMrw==
X-Received: by 2002:a17:902:860c:: with SMTP id f12mr81191872plo.127.1558406907601;
        Mon, 20 May 2019 19:48:27 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id f4sm21972213pfn.118.2019.05.20.19.48.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 19:48:25 -0700 (PDT)
Date: Tue, 21 May 2019 11:48:20 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190521024820.GG10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520092258.GZ6836@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> [Cc linux-api]
> 
> On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > Currently, process_madvise syscall works for only one address range
> > so user should call the syscall several times to give hints to
> > multiple address range.
> 
> Is that a problem? How big of a problem? Any numbers?

We easily have 2000+ vma so it's not trivial overhead. I will come up
with number in the description at respin.

> 
> > This patch extends process_madvise syscall to support multiple
> > hints, address ranges and return vaules so user could give hints
> > all at once.
> > 
> > struct pr_madvise_param {
> >     int size;                       /* the size of this structure */
> >     const struct iovec __user *vec; /* address range array */
> > }
> > 
> > int process_madvise(int pidfd, ssize_t nr_elem,
> > 		    int *behavior,
> > 		    struct pr_madvise_param *results,
> > 		    struct pr_madvise_param *ranges,
> > 		    unsigned long flags);
> > 
> > - pidfd
> > 
> > target process fd
> > 
> > - nr_elem
> > 
> > the number of elemenent of array behavior, results, ranges
> > 
> > - behavior
> > 
> > hints for each address range in remote process so that user could
> > give different hints for each range.
> 
> What is the guarantee of a single call? Do all hints get applied or the
> first failure backs of? What are the atomicity guarantees?

All hints will be tried even though one of them is failed. User will
see the success or failure from the restuls parameter.
For the single call, there is no guarantee of atomicity.

> 
> > 
> > - results
> > 
> > array of buffers to get results for associated remote address range
> > action.
> > 
> > - ranges
> > 
> > array to buffers to have remote process's address ranges to be
> > processed
> > 
> > - flags
> > 
> > extra argument for the future. It should be zero this moment.
> > 
> > Example)
> > 
> > struct pr_madvise_param {
> >         int size;
> >         const struct iovec *vec;
> > };
> > 
> > int main(int argc, char *argv[])
> > {
> >         struct pr_madvise_param retp, rangep;
> >         struct iovec result_vec[2], range_vec[2];
> >         int hints[2];
> >         long ret[2];
> >         void *addr[2];
> > 
> >         pid_t pid;
> >         char cmd[64] = {0,};
> >         addr[0] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
> >                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> > 
> >         if (MAP_FAILED == addr[0])
> >                 return 1;
> > 
> >         addr[1] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
> >                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> > 
> >         if (MAP_FAILED == addr[1])
> >                 return 1;
> > 
> >         hints[0] = MADV_COLD;
> > 	range_vec[0].iov_base = addr[0];
> >         range_vec[0].iov_len = ALLOC_SIZE;
> >         result_vec[0].iov_base = &ret[0];
> >         result_vec[0].iov_len = sizeof(long);
> > 	retp.vec = result_vec;
> >         retp.size = sizeof(struct pr_madvise_param);
> > 
> >         hints[1] = MADV_COOL;
> >         range_vec[1].iov_base = addr[1];
> >         range_vec[1].iov_len = ALLOC_SIZE;
> >         result_vec[1].iov_base = &ret[1];
> >         result_vec[1].iov_len = sizeof(long);
> >         rangep.vec = range_vec;
> >         rangep.size = sizeof(struct pr_madvise_param);
> > 
> >         pid = fork();
> >         if (!pid) {
> >                 sleep(10);
> >         } else {
> >                 int pidfd = open(cmd,  O_DIRECTORY | O_CLOEXEC);
> >                 if (pidfd < 0)
> >                         return 1;
> > 
> >                 /* munmap to make pages private for the child */
> >                 munmap(addr[0], ALLOC_SIZE);
> >                 munmap(addr[1], ALLOC_SIZE);
> >                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
> >                 if (syscall(__NR_process_madvise, pidfd, 2, behaviors,
> > 						&retp, &rangep, 0))
> >                         perror("process_madvise fail\n");
> >                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
> >         }
> > 
> >         return 0;
> > }
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/uapi/asm-generic/mman-common.h |   5 +
> >  mm/madvise.c                           | 184 +++++++++++++++++++++----
> >  2 files changed, 166 insertions(+), 23 deletions(-)
> > 
> > diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> > index b9b51eeb8e1a..b8e230de84a6 100644
> > --- a/include/uapi/asm-generic/mman-common.h
> > +++ b/include/uapi/asm-generic/mman-common.h
> > @@ -74,4 +74,9 @@
> >  #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
> >  				 PKEY_DISABLE_WRITE)
> >  
> > +struct pr_madvise_param {
> > +	int size;			/* the size of this structure */
> > +	const struct iovec __user *vec;	/* address range array */
> > +};
> > +
> >  #endif /* __ASM_GENERIC_MMAN_COMMON_H */
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index af02aa17e5c1..f4f569dac2bd 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -320,6 +320,7 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> >  	struct page *page;
> >  	struct vm_area_struct *vma = walk->vma;
> >  	unsigned long next;
> > +	long nr_pages = 0;
> >  
> >  	next = pmd_addr_end(addr, end);
> >  	if (pmd_trans_huge(*pmd)) {
> > @@ -380,9 +381,12 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> >  
> >  		ptep_test_and_clear_young(vma, addr, pte);
> >  		deactivate_page(page);
> > +		nr_pages++;
> > +
> >  	}
> >  
> >  	pte_unmap_unlock(orig_pte, ptl);
> > +	*(long *)walk->private += nr_pages;
> >  	cond_resched();
> >  
> >  	return 0;
> > @@ -390,11 +394,13 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
> >  
> >  static void madvise_cool_page_range(struct mmu_gather *tlb,
> >  			     struct vm_area_struct *vma,
> > -			     unsigned long addr, unsigned long end)
> > +			     unsigned long addr, unsigned long end,
> > +			     long *nr_pages)
> >  {
> >  	struct mm_walk cool_walk = {
> >  		.pmd_entry = madvise_cool_pte_range,
> >  		.mm = vma->vm_mm,
> > +		.private = nr_pages
> >  	};
> >  
> >  	tlb_start_vma(tlb, vma);
> > @@ -403,7 +409,8 @@ static void madvise_cool_page_range(struct mmu_gather *tlb,
> >  }
> >  
> >  static long madvise_cool(struct vm_area_struct *vma,
> > -			unsigned long start_addr, unsigned long end_addr)
> > +			unsigned long start_addr, unsigned long end_addr,
> > +			long *nr_pages)
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	struct mmu_gather tlb;
> > @@ -413,7 +420,7 @@ static long madvise_cool(struct vm_area_struct *vma,
> >  
> >  	lru_add_drain();
> >  	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> > -	madvise_cool_page_range(&tlb, vma, start_addr, end_addr);
> > +	madvise_cool_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
> >  	tlb_finish_mmu(&tlb, start_addr, end_addr);
> >  
> >  	return 0;
> > @@ -429,6 +436,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> >  	int isolated = 0;
> >  	struct vm_area_struct *vma = walk->vma;
> >  	unsigned long next;
> > +	long nr_pages = 0;
> >  
> >  	next = pmd_addr_end(addr, end);
> >  	if (pmd_trans_huge(*pmd)) {
> > @@ -492,7 +500,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> >  		list_add(&page->lru, &page_list);
> >  		if (isolated >= SWAP_CLUSTER_MAX) {
> >  			pte_unmap_unlock(orig_pte, ptl);
> > -			reclaim_pages(&page_list);
> > +			nr_pages += reclaim_pages(&page_list);
> >  			isolated = 0;
> >  			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  			orig_pte = pte;
> > @@ -500,19 +508,22 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
> >  	}
> >  
> >  	pte_unmap_unlock(orig_pte, ptl);
> > -	reclaim_pages(&page_list);
> > +	nr_pages += reclaim_pages(&page_list);
> >  	cond_resched();
> >  
> > +	*(long *)walk->private += nr_pages;
> >  	return 0;
> >  }
> >  
> >  static void madvise_cold_page_range(struct mmu_gather *tlb,
> >  			     struct vm_area_struct *vma,
> > -			     unsigned long addr, unsigned long end)
> > +			     unsigned long addr, unsigned long end,
> > +			     long *nr_pages)
> >  {
> >  	struct mm_walk warm_walk = {
> >  		.pmd_entry = madvise_cold_pte_range,
> >  		.mm = vma->vm_mm,
> > +		.private = nr_pages,
> >  	};
> >  
> >  	tlb_start_vma(tlb, vma);
> > @@ -522,7 +533,8 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
> >  
> >  
> >  static long madvise_cold(struct vm_area_struct *vma,
> > -			unsigned long start_addr, unsigned long end_addr)
> > +			unsigned long start_addr, unsigned long end_addr,
> > +			long *nr_pages)
> >  {
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	struct mmu_gather tlb;
> > @@ -532,7 +544,7 @@ static long madvise_cold(struct vm_area_struct *vma,
> >  
> >  	lru_add_drain();
> >  	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> > -	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
> > +	madvise_cold_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
> >  	tlb_finish_mmu(&tlb, start_addr, end_addr);
> >  
> >  	return 0;
> > @@ -922,7 +934,7 @@ static int madvise_inject_error(int behavior,
> >  static long
> >  madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
> >  		struct vm_area_struct **prev, unsigned long start,
> > -		unsigned long end, int behavior)
> > +		unsigned long end, int behavior, long *nr_pages)
> >  {
> >  	switch (behavior) {
> >  	case MADV_REMOVE:
> > @@ -930,9 +942,9 @@ madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
> >  	case MADV_WILLNEED:
> >  		return madvise_willneed(vma, prev, start, end);
> >  	case MADV_COOL:
> > -		return madvise_cool(vma, start, end);
> > +		return madvise_cool(vma, start, end, nr_pages);
> >  	case MADV_COLD:
> > -		return madvise_cold(vma, start, end);
> > +		return madvise_cold(vma, start, end, nr_pages);
> >  	case MADV_FREE:
> >  	case MADV_DONTNEED:
> >  		return madvise_dontneed_free(tsk, vma, prev, start,
> > @@ -981,7 +993,7 @@ madvise_behavior_valid(int behavior)
> >  }
> >  
> >  static int madvise_core(struct task_struct *tsk, unsigned long start,
> > -			size_t len_in, int behavior)
> > +			size_t len_in, int behavior, long *nr_pages)
> >  {
> >  	unsigned long end, tmp;
> >  	struct vm_area_struct *vma, *prev;
> > @@ -996,6 +1008,7 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >  
> >  	if (start & ~PAGE_MASK)
> >  		return error;
> > +
> >  	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
> >  
> >  	/* Check to see whether len was rounded up from small -ve to zero */
> > @@ -1035,6 +1048,8 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >  	blk_start_plug(&plug);
> >  	for (;;) {
> >  		/* Still start < end. */
> > +		long pages = 0;
> > +
> >  		error = -ENOMEM;
> >  		if (!vma)
> >  			goto out;
> > @@ -1053,9 +1068,11 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >  			tmp = end;
> >  
> >  		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> > -		error = madvise_vma(tsk, vma, &prev, start, tmp, behavior);
> > +		error = madvise_vma(tsk, vma, &prev, start, tmp,
> > +					behavior, &pages);
> >  		if (error)
> >  			goto out;
> > +		*nr_pages += pages;
> >  		start = tmp;
> >  		if (prev && start < prev->vm_end)
> >  			start = prev->vm_end;
> > @@ -1140,26 +1157,137 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
> >   */
> >  SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> >  {
> > -	return madvise_core(current, start, len_in, behavior);
> > +	unsigned long dummy;
> > +
> > +	return madvise_core(current, start, len_in, behavior, &dummy);
> >  }
> >  
> > -SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> > -		size_t, len_in, int, behavior)
> > +static int pr_madvise_copy_param(struct pr_madvise_param __user *u_param,
> > +		struct pr_madvise_param *param)
> > +{
> > +	u32 size;
> > +	int ret;
> > +
> > +	memset(param, 0, sizeof(*param));
> > +
> > +	ret = get_user(size, &u_param->size);
> > +	if (ret)
> > +		return ret;
> > +
> > +	if (size > PAGE_SIZE)
> > +		return -E2BIG;
> > +
> > +	if (!size || size > sizeof(struct pr_madvise_param))
> > +		return -EINVAL;
> > +
> > +	ret = copy_from_user(param, u_param, size);
> > +	if (ret)
> > +		return -EFAULT;
> > +
> > +	return ret;
> > +}
> > +
> > +static int process_madvise_core(struct task_struct *tsk, int *behaviors,
> > +				struct iov_iter *iter,
> > +				const struct iovec *range_vec,
> > +				unsigned long riovcnt,
> > +				unsigned long flags)
> > +{
> > +	int i;
> > +	long err;
> > +
> > +	for (err = 0, i = 0; i < riovcnt && iov_iter_count(iter); i++) {
> > +		long ret = 0;
> > +
> > +		err = madvise_core(tsk, (unsigned long)range_vec[i].iov_base,
> > +				range_vec[i].iov_len, behaviors[i],
> > +				&ret);
> > +		if (err)
> > +			ret = err;
> > +
> > +		if (copy_to_iter(&ret, sizeof(long), iter) !=
> > +				sizeof(long)) {
> > +			err = -EFAULT;
> > +			break;
> > +		}
> > +
> > +		err = 0;
> > +	}
> > +
> > +	return err;
> > +}
> > +
> > +SYSCALL_DEFINE6(process_madvise, int, pidfd, ssize_t, nr_elem,
> > +			const int __user *, hints,
> > +			struct pr_madvise_param __user *, results,
> > +			struct pr_madvise_param __user *, ranges,
> > +			unsigned long, flags)
> >  {
> >  	int ret;
> >  	struct fd f;
> >  	struct pid *pid;
> >  	struct task_struct *tsk;
> >  	struct mm_struct *mm;
> > +	struct pr_madvise_param result_p, range_p;
> > +	const struct iovec __user *result_vec, __user *range_vec;
> > +	int *behaviors;
> > +	struct iovec iovstack_result[UIO_FASTIOV];
> > +	struct iovec iovstack_r[UIO_FASTIOV];
> > +	struct iovec *iov_l = iovstack_result;
> > +	struct iovec *iov_r = iovstack_r;
> > +	struct iov_iter iter;
> > +
> > +	if (flags != 0)
> > +		return -EINVAL;
> > +
> > +	ret = pr_madvise_copy_param(results, &result_p);
> > +	if (ret)
> > +		return ret;
> > +
> > +	ret = pr_madvise_copy_param(ranges, &range_p);
> > +	if (ret)
> > +		return ret;
> > +
> > +	result_vec = result_p.vec;
> > +	range_vec = range_p.vec;
> > +
> > +	if (result_p.size != sizeof(struct pr_madvise_param) ||
> > +			range_p.size != sizeof(struct pr_madvise_param))
> > +		return -EINVAL;
> > +
> > +	behaviors = kmalloc_array(nr_elem, sizeof(int), GFP_KERNEL);
> > +	if (!behaviors)
> > +		return -ENOMEM;
> > +
> > +	ret = copy_from_user(behaviors, hints, sizeof(int) * nr_elem);
> > +	if (ret < 0)
> > +		goto free_behavior_vec;
> > +
> > +	ret = import_iovec(READ, result_vec, nr_elem, UIO_FASTIOV,
> > +				&iov_l, &iter);
> > +	if (ret < 0)
> > +		goto free_behavior_vec;
> > +
> > +	if (!iov_iter_count(&iter)) {
> > +		ret = -EINVAL;
> > +		goto free_iovecs;
> > +	}
> > +
> > +	ret = rw_copy_check_uvector(CHECK_IOVEC_ONLY, range_vec, nr_elem,
> > +				UIO_FASTIOV, iovstack_r, &iov_r);
> > +	if (ret <= 0)
> > +		goto free_iovecs;
> >  
> >  	f = fdget(pidfd);
> > -	if (!f.file)
> > -		return -EBADF;
> > +	if (!f.file) {
> > +		ret = -EBADF;
> > +		goto free_iovecs;
> > +	}
> >  
> >  	pid = pidfd_to_pid(f.file);
> >  	if (IS_ERR(pid)) {
> >  		ret = PTR_ERR(pid);
> > -		goto err;
> > +		goto put_fd;
> >  	}
> >  
> >  	ret = -EINVAL;
> > @@ -1167,7 +1295,7 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> >  	tsk = pid_task(pid, PIDTYPE_PID);
> >  	if (!tsk) {
> >  		rcu_read_unlock();
> > -		goto err;
> > +		goto put_fd;
> >  	}
> >  	get_task_struct(tsk);
> >  	rcu_read_unlock();
> > @@ -1176,12 +1304,22 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> >  		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
> >  		if (ret == -EACCES)
> >  			ret = -EPERM;
> > -		goto err;
> > +		goto put_task;
> >  	}
> > -	ret = madvise_core(tsk, start, len_in, behavior);
> > +
> > +	ret = process_madvise_core(tsk, behaviors, &iter, iov_r,
> > +					nr_elem, flags);
> >  	mmput(mm);
> > +put_task:
> >  	put_task_struct(tsk);
> > -err:
> > +put_fd:
> >  	fdput(f);
> > +free_iovecs:
> > +	if (iov_r != iovstack_r)
> > +		kfree(iov_r);
> > +	kfree(iov_l);
> > +free_behavior_vec:
> > +	kfree(behaviors);
> > +
> >  	return ret;
> >  }
> > -- 
> > 2.21.0.1020.gf2820cf01a-goog
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

