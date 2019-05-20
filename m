Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45FB6C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:23:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC87A20675
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:23:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC87A20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D9CC6B0008; Mon, 20 May 2019 05:23:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6633F6B000A; Mon, 20 May 2019 05:23:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 504676B000C; Mon, 20 May 2019 05:23:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC0786B0008
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:23:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d15so24254774edm.7
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:23:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dwHODEU6vo6uDiKAVnLuh2veREWMOOp74wcYm1Tgprc=;
        b=nHf6RieYP96Lpg4OwhiRQj2FNljtCVj2Ma7PViKGiCQLToiMjKpcRKiH1k6vGI/sX4
         xZrYsTWnHjEuM1sUSH5+TCE5jCmfyeCIA5jXiOkP/ytQ1AdHewAHNqzjjYP+TgIK8sjr
         hSMU5yrz+5TZZ5zjNe5yXUTbD57hTWSx4j4OGqoX7tpDJrSNdTiaN7ZM4CxbguYbvnKe
         c3IlBA9mKlSnKwDY+5TsSbp0D4NKqTQg9cMkv3bmihYrGbVgE+hOfsaiuyOwKA3SJsCC
         g2BfOyrnQuu8uws6CpLDEHVq3lIF2Islnw2wPsxKJGgPoYvFg6cHzNzWy8G0s0xEyAvD
         LDng==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX2cv8llQWRre+acceBF4IaarXPiEFSbWSGK+5Mb5hkv7i/aQDE
	PGl5Cvaksarz3OgWHtEU9T7evqIVN2JsLK78gYkHgJGUyYH/UpSOj85Ossy1GdQEepmTAoM7s5r
	f2L8LwI9p1hbiPzNVjfOSin5IIhFQx0635AL5xXbxXdoTkUYXIyAwTvtkuPh6Z30=
X-Received: by 2002:a50:947c:: with SMTP id q57mr75182286eda.81.1558344180510;
        Mon, 20 May 2019 02:23:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws1oQ2ipUPbOU1LNxzEjXn/xVO3MpxLvEcngWdH1FdvpxiGcl3WhguMI3Dh12pV/Jocidw
X-Received: by 2002:a50:947c:: with SMTP id q57mr75182222eda.81.1558344179583;
        Mon, 20 May 2019 02:22:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558344179; cv=none;
        d=google.com; s=arc-20160816;
        b=Q4alFVbasY/f9Acn4gdhkOOWp51oWVyLQEX9gcdL/fwRnQdTactF5nnosyeb0UaZ9Z
         C+IiNXPkr8yrMPhR4aBMSZWCnt/oChZgM8ItIaUnLCVKJ8+X02I2AkPm7B/MO17v9Cah
         rp1JlG8Cg0ztWx2V/jy1AJN1PUIIJPgbDJfMXm836vp6kOGGKhObwlo6Twk3XGJLFkL0
         LVoesO9HjvGaH2mUZoHGOJrOJRTMuGyPWpu9QT5VRbKVS6LDaTNr2sl0GbgTxuv/cGoM
         3/4RxWv4qSeZmkqFGm1/K751Wc9DGGDJPTGyLT+y0fqA6sM8rTwXvHgUy7NXz/jCiw8g
         Q2mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dwHODEU6vo6uDiKAVnLuh2veREWMOOp74wcYm1Tgprc=;
        b=h8uXncDXQuNrHDwjCDW/+xCj7YREekb5X5JDbnbFR/Vb3Rbz8P0KB7Df4csY78UFOB
         SWaJTphREzEk7np3WjBlwgRp+VgHGJms7ovoc5rHT6+dYJrBpQmPorxJt4E1bdNV0m7N
         dAG/OTWJMpHyzcRY7Bodrltq4w9Gr3Qcf3L52Dv5D5HRiAksukMtIoNq/Ze4FQQwCKFD
         MI65czXUDCm4YWwByNqaZSzKiXSG/GY7siXI/zNYqriitB+DpPmlunkEE9TXIWr3n7H5
         0t3YLTLZ/1B1HueQ1tuN9r9FhqBwXLM3hebHGz0ogz7sWffpixv0Vwq68dFFzndhCRal
         a32g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h17si1183991ejd.23.2019.05.20.02.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:22:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2FB58AF5F;
	Mon, 20 May 2019 09:22:59 +0000 (UTC)
Date: Mon, 20 May 2019 11:22:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
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
Message-ID: <20190520092258.GZ6836@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-7-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc linux-api]

On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> Currently, process_madvise syscall works for only one address range
> so user should call the syscall several times to give hints to
> multiple address range.

Is that a problem? How big of a problem? Any numbers?

> This patch extends process_madvise syscall to support multiple
> hints, address ranges and return vaules so user could give hints
> all at once.
> 
> struct pr_madvise_param {
>     int size;                       /* the size of this structure */
>     const struct iovec __user *vec; /* address range array */
> }
> 
> int process_madvise(int pidfd, ssize_t nr_elem,
> 		    int *behavior,
> 		    struct pr_madvise_param *results,
> 		    struct pr_madvise_param *ranges,
> 		    unsigned long flags);
> 
> - pidfd
> 
> target process fd
> 
> - nr_elem
> 
> the number of elemenent of array behavior, results, ranges
> 
> - behavior
> 
> hints for each address range in remote process so that user could
> give different hints for each range.

What is the guarantee of a single call? Do all hints get applied or the
first failure backs of? What are the atomicity guarantees?

> 
> - results
> 
> array of buffers to get results for associated remote address range
> action.
> 
> - ranges
> 
> array to buffers to have remote process's address ranges to be
> processed
> 
> - flags
> 
> extra argument for the future. It should be zero this moment.
> 
> Example)
> 
> struct pr_madvise_param {
>         int size;
>         const struct iovec *vec;
> };
> 
> int main(int argc, char *argv[])
> {
>         struct pr_madvise_param retp, rangep;
>         struct iovec result_vec[2], range_vec[2];
>         int hints[2];
>         long ret[2];
>         void *addr[2];
> 
>         pid_t pid;
>         char cmd[64] = {0,};
>         addr[0] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
>                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> 
>         if (MAP_FAILED == addr[0])
>                 return 1;
> 
>         addr[1] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
>                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> 
>         if (MAP_FAILED == addr[1])
>                 return 1;
> 
>         hints[0] = MADV_COLD;
> 	range_vec[0].iov_base = addr[0];
>         range_vec[0].iov_len = ALLOC_SIZE;
>         result_vec[0].iov_base = &ret[0];
>         result_vec[0].iov_len = sizeof(long);
> 	retp.vec = result_vec;
>         retp.size = sizeof(struct pr_madvise_param);
> 
>         hints[1] = MADV_COOL;
>         range_vec[1].iov_base = addr[1];
>         range_vec[1].iov_len = ALLOC_SIZE;
>         result_vec[1].iov_base = &ret[1];
>         result_vec[1].iov_len = sizeof(long);
>         rangep.vec = range_vec;
>         rangep.size = sizeof(struct pr_madvise_param);
> 
>         pid = fork();
>         if (!pid) {
>                 sleep(10);
>         } else {
>                 int pidfd = open(cmd,  O_DIRECTORY | O_CLOEXEC);
>                 if (pidfd < 0)
>                         return 1;
> 
>                 /* munmap to make pages private for the child */
>                 munmap(addr[0], ALLOC_SIZE);
>                 munmap(addr[1], ALLOC_SIZE);
>                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
>                 if (syscall(__NR_process_madvise, pidfd, 2, behaviors,
> 						&retp, &rangep, 0))
>                         perror("process_madvise fail\n");
>                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
>         }
> 
>         return 0;
> }
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/uapi/asm-generic/mman-common.h |   5 +
>  mm/madvise.c                           | 184 +++++++++++++++++++++----
>  2 files changed, 166 insertions(+), 23 deletions(-)
> 
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index b9b51eeb8e1a..b8e230de84a6 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -74,4 +74,9 @@
>  #define PKEY_ACCESS_MASK	(PKEY_DISABLE_ACCESS |\
>  				 PKEY_DISABLE_WRITE)
>  
> +struct pr_madvise_param {
> +	int size;			/* the size of this structure */
> +	const struct iovec __user *vec;	/* address range array */
> +};
> +
>  #endif /* __ASM_GENERIC_MMAN_COMMON_H */
> diff --git a/mm/madvise.c b/mm/madvise.c
> index af02aa17e5c1..f4f569dac2bd 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -320,6 +320,7 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
>  	struct page *page;
>  	struct vm_area_struct *vma = walk->vma;
>  	unsigned long next;
> +	long nr_pages = 0;
>  
>  	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> @@ -380,9 +381,12 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  		ptep_test_and_clear_young(vma, addr, pte);
>  		deactivate_page(page);
> +		nr_pages++;
> +
>  	}
>  
>  	pte_unmap_unlock(orig_pte, ptl);
> +	*(long *)walk->private += nr_pages;
>  	cond_resched();
>  
>  	return 0;
> @@ -390,11 +394,13 @@ static int madvise_cool_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  static void madvise_cool_page_range(struct mmu_gather *tlb,
>  			     struct vm_area_struct *vma,
> -			     unsigned long addr, unsigned long end)
> +			     unsigned long addr, unsigned long end,
> +			     long *nr_pages)
>  {
>  	struct mm_walk cool_walk = {
>  		.pmd_entry = madvise_cool_pte_range,
>  		.mm = vma->vm_mm,
> +		.private = nr_pages
>  	};
>  
>  	tlb_start_vma(tlb, vma);
> @@ -403,7 +409,8 @@ static void madvise_cool_page_range(struct mmu_gather *tlb,
>  }
>  
>  static long madvise_cool(struct vm_area_struct *vma,
> -			unsigned long start_addr, unsigned long end_addr)
> +			unsigned long start_addr, unsigned long end_addr,
> +			long *nr_pages)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct mmu_gather tlb;
> @@ -413,7 +420,7 @@ static long madvise_cool(struct vm_area_struct *vma,
>  
>  	lru_add_drain();
>  	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> -	madvise_cool_page_range(&tlb, vma, start_addr, end_addr);
> +	madvise_cool_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
>  	tlb_finish_mmu(&tlb, start_addr, end_addr);
>  
>  	return 0;
> @@ -429,6 +436,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  	int isolated = 0;
>  	struct vm_area_struct *vma = walk->vma;
>  	unsigned long next;
> +	long nr_pages = 0;
>  
>  	next = pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
> @@ -492,7 +500,7 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  		list_add(&page->lru, &page_list);
>  		if (isolated >= SWAP_CLUSTER_MAX) {
>  			pte_unmap_unlock(orig_pte, ptl);
> -			reclaim_pages(&page_list);
> +			nr_pages += reclaim_pages(&page_list);
>  			isolated = 0;
>  			pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  			orig_pte = pte;
> @@ -500,19 +508,22 @@ static int madvise_cold_pte_range(pmd_t *pmd, unsigned long addr,
>  	}
>  
>  	pte_unmap_unlock(orig_pte, ptl);
> -	reclaim_pages(&page_list);
> +	nr_pages += reclaim_pages(&page_list);
>  	cond_resched();
>  
> +	*(long *)walk->private += nr_pages;
>  	return 0;
>  }
>  
>  static void madvise_cold_page_range(struct mmu_gather *tlb,
>  			     struct vm_area_struct *vma,
> -			     unsigned long addr, unsigned long end)
> +			     unsigned long addr, unsigned long end,
> +			     long *nr_pages)
>  {
>  	struct mm_walk warm_walk = {
>  		.pmd_entry = madvise_cold_pte_range,
>  		.mm = vma->vm_mm,
> +		.private = nr_pages,
>  	};
>  
>  	tlb_start_vma(tlb, vma);
> @@ -522,7 +533,8 @@ static void madvise_cold_page_range(struct mmu_gather *tlb,
>  
>  
>  static long madvise_cold(struct vm_area_struct *vma,
> -			unsigned long start_addr, unsigned long end_addr)
> +			unsigned long start_addr, unsigned long end_addr,
> +			long *nr_pages)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct mmu_gather tlb;
> @@ -532,7 +544,7 @@ static long madvise_cold(struct vm_area_struct *vma,
>  
>  	lru_add_drain();
>  	tlb_gather_mmu(&tlb, mm, start_addr, end_addr);
> -	madvise_cold_page_range(&tlb, vma, start_addr, end_addr);
> +	madvise_cold_page_range(&tlb, vma, start_addr, end_addr, nr_pages);
>  	tlb_finish_mmu(&tlb, start_addr, end_addr);
>  
>  	return 0;
> @@ -922,7 +934,7 @@ static int madvise_inject_error(int behavior,
>  static long
>  madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
>  		struct vm_area_struct **prev, unsigned long start,
> -		unsigned long end, int behavior)
> +		unsigned long end, int behavior, long *nr_pages)
>  {
>  	switch (behavior) {
>  	case MADV_REMOVE:
> @@ -930,9 +942,9 @@ madvise_vma(struct task_struct *tsk, struct vm_area_struct *vma,
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
>  	case MADV_COOL:
> -		return madvise_cool(vma, start, end);
> +		return madvise_cool(vma, start, end, nr_pages);
>  	case MADV_COLD:
> -		return madvise_cold(vma, start, end);
> +		return madvise_cold(vma, start, end, nr_pages);
>  	case MADV_FREE:
>  	case MADV_DONTNEED:
>  		return madvise_dontneed_free(tsk, vma, prev, start,
> @@ -981,7 +993,7 @@ madvise_behavior_valid(int behavior)
>  }
>  
>  static int madvise_core(struct task_struct *tsk, unsigned long start,
> -			size_t len_in, int behavior)
> +			size_t len_in, int behavior, long *nr_pages)
>  {
>  	unsigned long end, tmp;
>  	struct vm_area_struct *vma, *prev;
> @@ -996,6 +1008,7 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>  
>  	if (start & ~PAGE_MASK)
>  		return error;
> +
>  	len = (len_in + ~PAGE_MASK) & PAGE_MASK;
>  
>  	/* Check to see whether len was rounded up from small -ve to zero */
> @@ -1035,6 +1048,8 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>  	blk_start_plug(&plug);
>  	for (;;) {
>  		/* Still start < end. */
> +		long pages = 0;
> +
>  		error = -ENOMEM;
>  		if (!vma)
>  			goto out;
> @@ -1053,9 +1068,11 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>  			tmp = end;
>  
>  		/* Here vma->vm_start <= start < tmp <= (end|vma->vm_end). */
> -		error = madvise_vma(tsk, vma, &prev, start, tmp, behavior);
> +		error = madvise_vma(tsk, vma, &prev, start, tmp,
> +					behavior, &pages);
>  		if (error)
>  			goto out;
> +		*nr_pages += pages;
>  		start = tmp;
>  		if (prev && start < prev->vm_end)
>  			start = prev->vm_end;
> @@ -1140,26 +1157,137 @@ static int madvise_core(struct task_struct *tsk, unsigned long start,
>   */
>  SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
>  {
> -	return madvise_core(current, start, len_in, behavior);
> +	unsigned long dummy;
> +
> +	return madvise_core(current, start, len_in, behavior, &dummy);
>  }
>  
> -SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
> -		size_t, len_in, int, behavior)
> +static int pr_madvise_copy_param(struct pr_madvise_param __user *u_param,
> +		struct pr_madvise_param *param)
> +{
> +	u32 size;
> +	int ret;
> +
> +	memset(param, 0, sizeof(*param));
> +
> +	ret = get_user(size, &u_param->size);
> +	if (ret)
> +		return ret;
> +
> +	if (size > PAGE_SIZE)
> +		return -E2BIG;
> +
> +	if (!size || size > sizeof(struct pr_madvise_param))
> +		return -EINVAL;
> +
> +	ret = copy_from_user(param, u_param, size);
> +	if (ret)
> +		return -EFAULT;
> +
> +	return ret;
> +}
> +
> +static int process_madvise_core(struct task_struct *tsk, int *behaviors,
> +				struct iov_iter *iter,
> +				const struct iovec *range_vec,
> +				unsigned long riovcnt,
> +				unsigned long flags)
> +{
> +	int i;
> +	long err;
> +
> +	for (err = 0, i = 0; i < riovcnt && iov_iter_count(iter); i++) {
> +		long ret = 0;
> +
> +		err = madvise_core(tsk, (unsigned long)range_vec[i].iov_base,
> +				range_vec[i].iov_len, behaviors[i],
> +				&ret);
> +		if (err)
> +			ret = err;
> +
> +		if (copy_to_iter(&ret, sizeof(long), iter) !=
> +				sizeof(long)) {
> +			err = -EFAULT;
> +			break;
> +		}
> +
> +		err = 0;
> +	}
> +
> +	return err;
> +}
> +
> +SYSCALL_DEFINE6(process_madvise, int, pidfd, ssize_t, nr_elem,
> +			const int __user *, hints,
> +			struct pr_madvise_param __user *, results,
> +			struct pr_madvise_param __user *, ranges,
> +			unsigned long, flags)
>  {
>  	int ret;
>  	struct fd f;
>  	struct pid *pid;
>  	struct task_struct *tsk;
>  	struct mm_struct *mm;
> +	struct pr_madvise_param result_p, range_p;
> +	const struct iovec __user *result_vec, __user *range_vec;
> +	int *behaviors;
> +	struct iovec iovstack_result[UIO_FASTIOV];
> +	struct iovec iovstack_r[UIO_FASTIOV];
> +	struct iovec *iov_l = iovstack_result;
> +	struct iovec *iov_r = iovstack_r;
> +	struct iov_iter iter;
> +
> +	if (flags != 0)
> +		return -EINVAL;
> +
> +	ret = pr_madvise_copy_param(results, &result_p);
> +	if (ret)
> +		return ret;
> +
> +	ret = pr_madvise_copy_param(ranges, &range_p);
> +	if (ret)
> +		return ret;
> +
> +	result_vec = result_p.vec;
> +	range_vec = range_p.vec;
> +
> +	if (result_p.size != sizeof(struct pr_madvise_param) ||
> +			range_p.size != sizeof(struct pr_madvise_param))
> +		return -EINVAL;
> +
> +	behaviors = kmalloc_array(nr_elem, sizeof(int), GFP_KERNEL);
> +	if (!behaviors)
> +		return -ENOMEM;
> +
> +	ret = copy_from_user(behaviors, hints, sizeof(int) * nr_elem);
> +	if (ret < 0)
> +		goto free_behavior_vec;
> +
> +	ret = import_iovec(READ, result_vec, nr_elem, UIO_FASTIOV,
> +				&iov_l, &iter);
> +	if (ret < 0)
> +		goto free_behavior_vec;
> +
> +	if (!iov_iter_count(&iter)) {
> +		ret = -EINVAL;
> +		goto free_iovecs;
> +	}
> +
> +	ret = rw_copy_check_uvector(CHECK_IOVEC_ONLY, range_vec, nr_elem,
> +				UIO_FASTIOV, iovstack_r, &iov_r);
> +	if (ret <= 0)
> +		goto free_iovecs;
>  
>  	f = fdget(pidfd);
> -	if (!f.file)
> -		return -EBADF;
> +	if (!f.file) {
> +		ret = -EBADF;
> +		goto free_iovecs;
> +	}
>  
>  	pid = pidfd_to_pid(f.file);
>  	if (IS_ERR(pid)) {
>  		ret = PTR_ERR(pid);
> -		goto err;
> +		goto put_fd;
>  	}
>  
>  	ret = -EINVAL;
> @@ -1167,7 +1295,7 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
>  	tsk = pid_task(pid, PIDTYPE_PID);
>  	if (!tsk) {
>  		rcu_read_unlock();
> -		goto err;
> +		goto put_fd;
>  	}
>  	get_task_struct(tsk);
>  	rcu_read_unlock();
> @@ -1176,12 +1304,22 @@ SYSCALL_DEFINE4(process_madvise, int, pidfd, unsigned long, start,
>  		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
>  		if (ret == -EACCES)
>  			ret = -EPERM;
> -		goto err;
> +		goto put_task;
>  	}
> -	ret = madvise_core(tsk, start, len_in, behavior);
> +
> +	ret = process_madvise_core(tsk, behaviors, &iter, iov_r,
> +					nr_elem, flags);
>  	mmput(mm);
> +put_task:
>  	put_task_struct(tsk);
> -err:
> +put_fd:
>  	fdput(f);
> +free_iovecs:
> +	if (iov_r != iovstack_r)
> +		kfree(iov_r);
> +	kfree(iov_l);
> +free_behavior_vec:
> +	kfree(behaviors);
> +
>  	return ret;
>  }
> -- 
> 2.21.0.1020.gf2820cf01a-goog
> 

-- 
Michal Hocko
SUSE Labs

