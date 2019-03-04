Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DED7BC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 00:13:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F35820835
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 00:13:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F35820835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1FF28E0003; Sun,  3 Mar 2019 19:13:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD07B8E0001; Sun,  3 Mar 2019 19:13:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A983E8E0003; Sun,  3 Mar 2019 19:13:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCC78E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 19:13:39 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id i3so3693511qtc.7
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 16:13:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q4R4YZtBEN7I9uyGVnGwsthpgpOBRFSntkvgaLtbe6s=;
        b=p8jnWZBDMfzemrWmI72GKHSUJ97nHNYUp8BXMV/KlfHMtwjitWj0rNKu28zB3tpgk1
         F+Zu+9803r4mIDvmj/ISxz4yRKjnTB0DYPSxNNP8eB9VGO5aZjGTsOGE3ylRgB9KrWG3
         t9ATQxJ02IUtvsg6C/JrXR/f3zhSw2thc4eYwZ6IAniz6WOEzNnK0baKiHM4e959cwmo
         YyFtxXQ0AFzQwc6K9WPi9g4UQkYNmxfJ1lEhbHRyQXSW+QBA+L0/nc0eDnJqmnONX1rV
         vALMerPV2T+Rq7zWnZBHq3NLq8yzVFSXJwhv6qjWwnpQrKwd6wuie3UGeLDIIoyo6VAm
         WoRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXDB83boHEuUFTuL7JrUYN03RCnXz4wkQ+TbPKyZedWCr6cpcPF
	37ZruLjHYtpiIHFyWEPsFJLoA0HecqQmUmISRusbWT6YKriidRdfaeZwbnvTlqlTxis7uUjriEe
	bnqYmfGU6i1/qVgoYAxga6T2ASsCKgTzd/KDHQU83YQeBRKSGDXSilwVk9vTw6a/mYw==
X-Received: by 2002:ac8:1702:: with SMTP id w2mr13308707qtj.164.1551658419055;
        Sun, 03 Mar 2019 16:13:39 -0800 (PST)
X-Google-Smtp-Source: APXvYqy6LaSRuIqKBM/TWu3cQ2h8BLJFitJLgJP4NityR99lV0NBOMLFerVrvr85ECoAKJr9qFRh
X-Received: by 2002:ac8:1702:: with SMTP id w2mr13308662qtj.164.1551658417922;
        Sun, 03 Mar 2019 16:13:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551658417; cv=none;
        d=google.com; s=arc-20160816;
        b=0HdL0U64+TNtwmWPD7YsStZYZHJxIRx91hpkgGcfbCChXkng2s17wlxN4xuTZILDfo
         RXdHz92gpeKYB10oMS2OpYqM0XUciCBF6E7++otLMMRf7lnUPaVBE2QcGO8+1gb3WDa0
         yLCiyZc9KFPqNUbHtIF2VYXbS4K4OiD+R03f/u+KuIhvJVvXz5e4a19wo0ldP08ETHRI
         n8yT6PIolPYwzJHo+QezjqbLke61TDuA0q7gpHAnariZ9HE/DI89QE7YXxTTHbIeMczI
         e3kOdQRaKx3i1bQEMGERPI/0Cqbzz9lKp3jIz2PNPHGsS/6T9AJS93LtPwNqBf6HbTf0
         DGeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q4R4YZtBEN7I9uyGVnGwsthpgpOBRFSntkvgaLtbe6s=;
        b=EIT8MhVkXU9/au8tVD4V+FjAS9zONuFWr/qOTbsUIcGJqGQIPxegen+XlEYEZPJeW9
         nIRabVjV23KuQINoKe+l6DaSJYcP9UzE1VTcPH7ft6Zpt2qKpRp+6H6UXmSNFBJFRILl
         jcLE4wGzuPzzz1JUYBYMdNPC13b6N8/pMjJolzEQIhoXC3AaNzer7YnzR5VoLX8pJCwe
         DyDEHdzVvmLc1kXKGtcfeFxN2MoluvZrwLSMEOjSMngcCPkmv9eHowyq7Ry1vmop63tC
         YP1TEXm9E9Mr7IHcUm/brvo4qWgOXtg5FlfnZ6xUJonCr/JAKN+Mk2c3Khr1pU9IgocV
         7CVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u44si257820qtk.297.2019.03.03.16.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 16:13:37 -0800 (PST)
Received-SPF: pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4CBCF3084215;
	Mon,  4 Mar 2019 00:13:36 +0000 (UTC)
Received: from x230.aquini.net (ovpn-116-145.phx2.redhat.com [10.3.116.145])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B15A75D6A6;
	Mon,  4 Mar 2019 00:13:30 +0000 (UTC)
Date: Sun, 3 Mar 2019 21:13:28 -0300
From: Rafael Aquini <aquini@redhat.com>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org,
	peterz@infradead.org, riel@surriel.com, mhocko@suse.com,
	ying.huang@intel.com, jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190304001328.GA27580@x230.aquini.net>
References: <20190302185144.GD31083@redhat.com>
 <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 04 Mar 2019 00:13:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 08:28:04AM +0100, Jan Stancek wrote:
> LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
> This is a stress test, where one thread mmaps/writes/munmaps memory area
> and other thread is trying to read from it:
> 
>   CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
>   Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
>   Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
>   Call Trace:
>   ([<0000000000000000>]           (null))
>    [<00000000001adae4>] lock_acquire+0xec/0x258
>    [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
>    [<000000000012a780>] page_table_free+0x48/0x1a8
>    [<00000000002f6e54>] do_fault+0xdc/0x670
>    [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
>    [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
>    [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
>    [<000000000080e5ee>] pgm_check_handler+0x19e/0x200
> 
> page_table_free() is called with NULL mm parameter, but because
> "0" is a valid address on s390 (see S390_lowcore), it keeps
> going until it eventually crashes in lockdep's lock_acquire.
> This crash is reproducible at least since 4.14.
> 
> Problem is that "vmf->vma" used in do_fault() can become stale.
> Because mmap_sem may be released, other threads can come in,
> call munmap() and cause "vma" be returned to kmem cache, and
> get zeroed/re-initialized and re-used:
> 
> handle_mm_fault                           |
>   __handle_mm_fault                       |
>     do_fault                              |
>       vma = vmf->vma                      |
>       do_read_fault                       |
>         __do_fault                        |
>           vma->vm_ops->fault(vmf);        |
>             mmap_sem is released          |
>                                           |
>                                           | do_munmap()
>                                           |   remove_vma_list()
>                                           |     remove_vma()
>                                           |       vm_area_free()
>                                           |         # vma is released
>                                           | ...
>                                           | # same vma is allocated
>                                           | # from kmem cache
>                                           | do_mmap()
>                                           |   vm_area_alloc()
>                                           |     memset(vma, 0, ...)
>                                           |
>       pte_free(vma->vm_mm, ...);          |
>         page_table_free                   |
>           spin_lock_bh(&mm->context.lock);|
>             <crash>                       |
> 
> Cache mm_struct to avoid using potentially stale "vma".
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/memory.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..e8d69ade5acc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3517,10 +3517,13 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
>   * but allow concurrent faults).
>   * The mmap_sem may have been released depending on flags and our
>   * return value.  See filemap_fault() and __lock_page_or_retry().
> + * If mmap_sem is released, vma may become invalid (for example
> + * by other thread calling munmap()).
>   */
>  static vm_fault_t do_fault(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> +	struct mm_struct *vm_mm = vma->vm_mm;
>  	vm_fault_t ret;
>  
>  	/*
> @@ -3561,7 +3564,7 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
>  
>  	/* preallocated pagetable is unused: free it */
>  	if (vmf->prealloc_pte) {
> -		pte_free(vma->vm_mm, vmf->prealloc_pte);
> +		pte_free(vm_mm, vmf->prealloc_pte);
>  		vmf->prealloc_pte = NULL;
>  	}
>  	return ret;
> -- 
> 1.8.3.1
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

