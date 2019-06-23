Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAB49C43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 08:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31DBF20820
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 08:40:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31DBF20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F5E26B0003; Sun, 23 Jun 2019 04:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6A68E0002; Sun, 23 Jun 2019 04:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746938E0001; Sun, 23 Jun 2019 04:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 486136B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 04:40:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i132so4137824oif.2
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:40:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:sender
         :precedence:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=oSEzkJI0S6u9P3CEU3YXLwgc1Jh7lGurcxoDqBPg9/A=;
        b=d0p1UtxCPK9z2zEV5kfiTeQu7vm4pUBQvJYyKg/rNupRY3hfFgthjxXQ/W0cXQmcP2
         Pc5P7OrvsG025/dOkXywIO0N40RGkzaTSf5FreYIrN2tsQ56S2yYdGq5XlX05k5qRXw5
         jFOSs/XXGzQZduSFnIIbRoL+W9lFwBA8ez4A6XbvpD5QXIEv7Uein9gjqU5Tk/irsh5w
         LeOGyq0b2/dkt5sjsZbrDu+hPZJASbiUPaMipZAWH1MEBMX5HEjZToPn0DYUevvaEuiQ
         9qvQb8G+qcX+5vX2XpS7hJ6rZvvdbtK2kZAp8yRIgXdajtZZ0nx/XqAnKi5ZCE6x+18f
         FIeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVrnu1M0UpCV4bh97Q6o6jHLTwWPkBwn7wcyOYaHx1N2yXjqYRS
	ToPrGHkxPFFm5ci+LRkFD26yaa9DYQeW9yVqep+qcIT6gTd5VOqgwnGmsPEYAUGsNr3JCr/IpTV
	E+Rt2qRCtp9No9tfSRWHypJmc5EG7byn1Om9CYFRvxqc9KYr42lqH9j8qmrSLzM3dNA==
X-Received: by 2002:a9d:578c:: with SMTP id q12mr36422780oth.240.1561279211916;
        Sun, 23 Jun 2019 01:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLG5oSYblhEIjGWRTL0Qt11+F3rtrUWi25nCh3UsvJCl5vBsN6RM17MXqtY3/PSjDRcLI4
X-Received: by 2002:a9d:578c:: with SMTP id q12mr36422740oth.240.1561279210728;
        Sun, 23 Jun 2019 01:40:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561279210; cv=none;
        d=google.com; s=arc-20160816;
        b=EgPjVa0Zep8J7+ELA1x12aEVWWM/GekOwOoOKifjO4q++hcDKZcTXyWJvp4qv3QRBR
         46lF5oQ9na7P60wxPAlcXxhLvdfkDnFxtPGY+0wLZxKTf4G46GbWvkHLM2nRpKTM3OXG
         yeRuteaXIbLoN3UKKA1u2ppXT/oEfXxAPe2DVMaStmdX6h5gmSFBGX9iG53WKMgBQd4Z
         vktTkdpFfrnbBy1qGebkqn65jhfTJ37WeamPNm78ReuaJD4+0f423zvZtscdjLJHVmZC
         JvZhRFwEkRcSWB8R4rTuKLURnrnuNSl1mdO0MODMIt5Y08v+zIPZrU6JsmHiqdkz8Fy8
         SVKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:sender:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oSEzkJI0S6u9P3CEU3YXLwgc1Jh7lGurcxoDqBPg9/A=;
        b=B7I5FqkwiKIl7LGs1uOCMKaEm4KLYl/510q4R6NenXkGRxL9SEMWEaA0Was/kmx+Qa
         XVt4A1WA7rJp8HAfxTC4RDxCbc13teI6aZFYMT7iFfiOc8nyWVWBTi/Qc3uCcIQeZnk7
         Wii57LTFzQkHdPDNm1go8vpNixpy1TvyIGr66f1nqU1szlpzOilIUQvCTVKFpCRlwLSd
         eQZPaq1ZoxXwkIas+fo4Nio/7MkiB2gHICbdNNAKcO3oPYdCfMbTaH0I0zaEnrQG83FW
         IXvp87INar9N94/0BzXV9x94OWWTj89NqQQ8hbJ8Ljh7kRyF4OKAUtSWHXzwy7BWSZYT
         7LqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-163.sinamail.sina.com.cn (mail3-163.sinamail.sina.com.cn. [202.108.3.163])
        by mx.google.com with SMTP id z22si4410284otk.135.2019.06.23.01.40.09
        for <linux-mm@kvack.org>;
        Sun, 23 Jun 2019 01:40:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) client-ip=202.108.3.163;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.163 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([221.219.4.32])
	by sina.com with ESMTP
	id 5D0F3ADF00003993; Sun, 23 Jun 2019 16:40:01 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 497150395290
From: Hillf Danton <hdanton@sina.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	"Dr. David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v5 10/25] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Date: Sun, 23 Jun 2019 16:39:52 +0800
Message-Id: <20190623083952.10776-1-hdanton@sina.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190620022008.19172-11-peterx@redhat.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

On Thu, 20 Jun 2019 10:19:53 +0800 Peter Xu <peterx@redhat.com> wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This allows UFFDIO_COPY to map pages write-protected.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx: switch to VM_WARN_ON_ONCE in mfill_atomic_pte; add brackets
>  around "dst_vma->vm_flags & VM_WRITE"; fix wordings in comments and
>  commit messages]
> Reviewed-by: Jerome Glisse <jglisse@redhat.com>
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c                 |  5 +++--
>  include/linux/userfaultfd_k.h    |  2 +-
>  include/uapi/linux/userfaultfd.h | 11 +++++-----
>  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
>  4 files changed, 35 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 5dbef45ecbf5..c594945ad5bf 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -1694,11 +1694,12 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
>  	ret = -EINVAL;
>  	if (uffdio_copy.src + uffdio_copy.len <= uffdio_copy.src)
>  		goto out;
> -	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
> +	if (uffdio_copy.mode & ~(UFFDIO_COPY_MODE_DONTWAKE|UFFDIO_COPY_MODE_WP))
>  		goto out;
>  	if (mmget_not_zero(ctx->mm)) {
>  		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
> -				   uffdio_copy.len, &ctx->mmap_changing);
> +				   uffdio_copy.len, &ctx->mmap_changing,
> +				   uffdio_copy.mode);
>  		mmput(ctx->mm);
>  	} else {
>  		return -ESRCH;
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 7b91b76aac58..dcd33172b728 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -36,7 +36,7 @@ extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
>  
>  extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
>  			    unsigned long src_start, unsigned long len,
> -			    bool *mmap_changing);
> +			    bool *mmap_changing, __u64 mode);
>  extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
>  			      unsigned long dst_start,
>  			      unsigned long len,
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 48f1a7c2f1f0..340f23bc251d 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -203,13 +203,14 @@ struct uffdio_copy {
>  	__u64 dst;
>  	__u64 src;
>  	__u64 len;
> +#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
>  	/*
> -	 * There will be a wrprotection flag later that allows to map
> -	 * pages wrprotected on the fly. And such a flag will be
> -	 * available if the wrprotection ioctl are implemented for the
> -	 * range according to the uffdio_register.ioctls.
> +	 * UFFDIO_COPY_MODE_WP will map the page write protected on
> +	 * the fly.  UFFDIO_COPY_MODE_WP is available only if the
> +	 * write protected ioctl is implemented for the range
> +	 * according to the uffdio_register.ioctls.
>  	 */
> -#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
> +#define UFFDIO_COPY_MODE_WP			((__u64)1<<1)
>  	__u64 mode;
>  
>  	/*
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 9932d5755e4c..c8e7846e9b7e 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  			    struct vm_area_struct *dst_vma,
>  			    unsigned long dst_addr,
>  			    unsigned long src_addr,
> -			    struct page **pagep)
> +			    struct page **pagep,
> +			    bool wp_copy)
>  {
>  	struct mem_cgroup *memcg;
>  	pte_t _dst_pte, *dst_pte;
> @@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
>  		goto out_release;
>  
> -	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> -	if (dst_vma->vm_flags & VM_WRITE)
> -		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> +	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));

Make a dirty pte if the memory region is writable, imho.

> +	if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
> +		_dst_pte = pte_mkwrite(_dst_pte);
>  
>  	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
>  	if (dst_vma->vm_file) {
> @@ -398,7 +399,8 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
>  						unsigned long dst_addr,
>  						unsigned long src_addr,
>  						struct page **page,
> -						bool zeropage)
> +						bool zeropage,
> +						bool wp_copy)
>  {
>  	ssize_t err;
>  
> @@ -415,11 +417,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
>  	if (!(dst_vma->vm_flags & VM_SHARED)) {
>  		if (!zeropage)
>  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> -					       dst_addr, src_addr, page);
> +					       dst_addr, src_addr, page,
> +					       wp_copy);
>  		else
>  			err = mfill_zeropage_pte(dst_mm, dst_pmd,
>  						 dst_vma, dst_addr);
>  	} else {
> +		VM_WARN_ON_ONCE(wp_copy);
>  		if (!zeropage)
>  			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
>  						     dst_vma, dst_addr,
> @@ -437,7 +441,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  					      unsigned long src_start,
>  					      unsigned long len,
>  					      bool zeropage,
> -					      bool *mmap_changing)
> +					      bool *mmap_changing,
> +					      __u64 mode)
>  {
>  	struct vm_area_struct *dst_vma;
>  	ssize_t err;
> @@ -445,6 +450,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  	unsigned long src_addr, dst_addr;
>  	long copied;
>  	struct page *page;
> +	bool wp_copy;
>  
>  	/*
>  	 * Sanitize the command parameters:
> @@ -501,6 +507,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  	    dst_vma->vm_flags & VM_SHARED))
>  		goto out_unlock;
>  
> +	/*
> +	 * validate 'mode' now that we know the dst_vma: don't allow
> +	 * a wrprotect copy if the userfaultfd didn't register as WP.
> +	 */
> +	wp_copy = mode & UFFDIO_COPY_MODE_WP;
> +	if (wp_copy && !(dst_vma->vm_flags & VM_UFFD_WP))
> +		goto out_unlock;
> +
>  	/*
>  	 * If this is a HUGETLB vma, pass off to appropriate routine
>  	 */
> @@ -556,7 +570,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  		BUG_ON(pmd_trans_huge(*dst_pmd));
>  
>  		err = mfill_atomic_pte(dst_mm, dst_pmd, dst_vma, dst_addr,
> -				       src_addr, &page, zeropage);
> +				       src_addr, &page, zeropage, wp_copy);
>  		cond_resched();
>  
>  		if (unlikely(err == -ENOENT)) {
> @@ -603,14 +617,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
>  
>  ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
>  		     unsigned long src_start, unsigned long len,
> -		     bool *mmap_changing)
> +		     bool *mmap_changing, __u64 mode)
>  {
>  	return __mcopy_atomic(dst_mm, dst_start, src_start, len, false,
> -			      mmap_changing);
> +			      mmap_changing, mode);
>  }
>  
>  ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
>  		       unsigned long len, bool *mmap_changing)
>  {
> -	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing);
> +	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
>  }
> -- 
> 2.21.0
> 
> 
Hillf

