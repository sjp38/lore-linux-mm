Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E22CAC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A859F2077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:25:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A859F2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246418E0093; Thu, 21 Feb 2019 11:25:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5B88E0002; Thu, 21 Feb 2019 11:25:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BDF98E0093; Thu, 21 Feb 2019 11:25:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D215A8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:25:22 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id y6so3548893qke.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:25:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HHQY5veNASjO2pod73NRL7AN3uY1YlFiiKItnbJX9p4=;
        b=GLVNFrrgj7ZYkwh3c8h0mXsVuQN4u5q2PpVq0RX84pOQ5b/h6JMmgy/D1EArzG5M2z
         HHkdWafUW4IcvCkN5ut71faHMLN7esaQTVhwtKWB7At71GSVScIqEZdmlQDP2XxciUg+
         9bktHAyL9nv2N9uueyJsrIptJKCklIcg3jHAGZ2SF1cKYkW6sXpjwWJXmCSXiHlFrCDn
         R+QBSe0cRx6jRylWKfSpVMo7kI/on/2TFMOVNbru/3ZZA3ngu5WPcwcpWFJBYn/phOef
         ekdwl2dFlrs9oXy2bi+t/brHB6fwqkb+qqpHkad9XSyn9rWqyDkDhl9yD8pQCF7+6YHt
         E2cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua+yukL7LRTVV4xwCqwx9MFgXcvr6RiKtKPbmNNxRa6VG8mIPKW
	gwDm5HFB7tUUAPxIEtMUEMy77M6xcNjGt9hvtPSgFN9NuJm7ovCjhDPLrBr7awUm7zh/Go/kCAV
	NGBJ64NI/LqdpmloO1E5QDeIKZKsyl+6/V1CypGaIbHOhGhrBMCaQtXUqki5h4qcLBA==
X-Received: by 2002:a37:61d3:: with SMTP id v202mr10256162qkb.217.1550766322478;
        Thu, 21 Feb 2019 08:25:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IalVrR95l0U1OeLlfV1NHfBTV/+xDLf3uguY//xBluqkK29UR5cgjvZiP+L1J0YhdeP50zG
X-Received: by 2002:a37:61d3:: with SMTP id v202mr10256106qkb.217.1550766321584;
        Thu, 21 Feb 2019 08:25:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550766321; cv=none;
        d=google.com; s=arc-20160816;
        b=LR52Z3XbuDI5VZ8rNyofFbi4hWexzHni0hfn9QbEPunR+nXMPUPFXzb5W3/BYyYlrn
         ew2gVsjPxwQjW3oZtKbUgWDfj8+PaqBuHsAGQ8npQAsmSXsAGFuvCOIl5OpvJFhVRVWA
         Q+CrhEGwA4li3DohpcLOBxEQzGWa+oPdXITXA0mMMUlnwitpUYqr+sBsEobiC8Ck0fgG
         WKHildqpPCtQ6GEx9UKipoOZwLCiR5GRmRWyyQsCv47iv6chA/zjgy12NnUA4xQvB6zV
         lm43/JWTQ1aOuI5fPwoC5SBs1Q7aJDr1drUW8tPEmt6c7iweNEp8iBIzQDG7lF9gYLvh
         zEUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HHQY5veNASjO2pod73NRL7AN3uY1YlFiiKItnbJX9p4=;
        b=WXpHmzAn6e/vO1K0Lo9wQcDVFCqcFqL5brw8jdA0jy0wE65DSTdAd9tGPGNoUNYvTW
         Ic44UeY1xxuRb9u/DZ6MTtBZOlUjoJqd7k4yYuLtpYoeYiS9CjuSmfbYoE70lEtkn0Vq
         /HhJGU/CXF5faMdILezkHP1OQVkTi9cIio0rpF1qEIjcU8Et8vvtfxRdf1IYbuTzyHAW
         R13M1cq0JzOdhDbH9WRnnAflL0nfFUFeVzNrX2F+YRDeCsbXH0XyIu1SAu0aUIRIuUiw
         NbwY6HbFvNPKfDqVEM4dLNIm8eXUMgrPE3Ej+9G7uEo0gG+c1SfPK5/MqVUWlN3ZOLtP
         ZRGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y82si369287qkb.123.2019.02.21.08.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 08:25:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E50913086275;
	Thu, 21 Feb 2019 16:25:19 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F341D282E4;
	Thu, 21 Feb 2019 16:25:12 +0000 (UTC)
Date: Thu, 21 Feb 2019 11:25:11 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 07/26] userfaultfd: wp: hook userfault handler to
 write protection fault
Message-ID: <20190221162510.GG2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-8-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-8-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 21 Feb 2019 16:25:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:13AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> There are several cases write protection fault happens. It could be a
> write to zero page, swaped page or userfault write protected
> page. When the fault happens, there is no way to know if userfault
> write protect the page before. Here we just blindly issue a userfault
> notification for vma with VM_UFFD_WP regardless if app write protects
> it yet. Application should be ready to handle such wp fault.
> 
> v1: From: Shaohua Li <shli@fb.com>
> 
> v2: Handle the userfault in the common do_wp_page. If we get there a
> pagetable is present and readonly so no need to do further processing
> until we solve the userfault.
> 
> In the swapin case, always swapin as readonly. This will cause false
> positive userfaults. We need to decide later if to eliminate them with
> a flag like soft-dirty in the swap entry (see _PAGE_SWP_SOFT_DIRTY).
> 
> hugetlbfs wouldn't need to worry about swapouts but and tmpfs would
> be handled by a swap entry bit like anonymous memory.
> 
> The main problem with no easy solution to eliminate the false
> positives, will be if/when userfaultfd is extended to real filesystem
> pagecache. When the pagecache is freed by reclaim we can't leave the
> radix tree pinned if the inode and in turn the radix tree is reclaimed
> as well.

For real file system my generic page write protection patchset might
be of use. See my last year posting of it. I intend to repost it in
next few weeks as i am making steady progress on a cleaned and updated
version of it.

> 
> The estimation is that full accuracy and lack of false positives could
> be easily provided only to anonymous memory (as long as there's no
> fork or as long as MADV_DONTFORK is used on the userfaultfd anonymous
> range) tmpfs and hugetlbfs, it's most certainly worth to achieve it
> but in a later incremental patch.
> 
> v3: Add hooking point for THP wrprotect faults.
> 
> CC: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

I have some comments on this patch.

> ---
>  mm/memory.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..00781c43407b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2483,6 +2483,11 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
>  
> +	if (userfaultfd_wp(vma)) {
> +		pte_unmap_unlock(vmf->pte, vmf->ptl);
> +		return handle_userfault(vmf, VM_UFFD_WP);
> +	}
> +
>  	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
>  	if (!vmf->page) {
>  		/*
> @@ -2800,6 +2805,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
>  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
>  	pte = mk_pte(page, vma->vm_page_prot);
> +	if (userfaultfd_wp(vma))
> +		vmf->flags &= ~FAULT_FLAG_WRITE;

This looks wrong to me by clearing FAULT_FLAG_WRITE you disable the
call to do_wp_page() which would have handled the userfault write
protect fault. It seems to me that you want to disable below code
path to happen so it would be better to change below

From
>  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {

To
>  	if (!userfaultfd_wp(vma) && (vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {


>  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
>  		vmf->flags &= ~FAULT_FLAG_WRITE;
> @@ -3684,8 +3691,11 @@ static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
>  /* `inline' is required to avoid gcc 4.1.2 build error */
>  static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
>  {
> -	if (vma_is_anonymous(vmf->vma))
> +	if (vma_is_anonymous(vmf->vma)) {
> +		if (userfaultfd_wp(vmf->vma))
> +			return handle_userfault(vmf, VM_UFFD_WP);
>  		return do_huge_pmd_wp_page(vmf, orig_pmd);
> +	}
>  	if (vmf->vma->vm_ops->huge_fault)
>  		return vmf->vma->vm_ops->huge_fault(vmf, PE_SIZE_PMD);
>  
> -- 
> 2.17.1
> 

