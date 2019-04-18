Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10554C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:05:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C433E214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 22:05:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C433E214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77B206B0005; Thu, 18 Apr 2019 18:05:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72AE86B0006; Thu, 18 Apr 2019 18:05:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F3EB6B0007; Thu, 18 Apr 2019 18:05:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9676B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 18:05:53 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z19so141758qkj.5
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 15:05:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kjaqv1yERcNZ6s1PEC8wCbequ+KYSzl8PjfiI4bSXoA=;
        b=LvJ+qa39TntpHzRt6xbUceYh+TPBlq/Mo1W0xQidesohBK9cZiHR4/bnuArMAthw4J
         hbN5syygALOJ3Y6GIs4CAFInvIxmLCCo3ANHCSk2JJVcr8/gxq3JbpEnKdbp+X/BZojF
         crz0/fFQE+k55/9R+DUCoxznoN2ZbCcokMw1f9hxcBm+CoOEjGZnd09pPWK5JLT7qCPN
         rR7VF24YGqnFyaCIlRqrIIbSSuqTQxOQrGoPSnofJftIuqrR5sI12QNnDgJldQgxc0WC
         DJP+oBIKk2WjFiYFkq9884WhOYMm2NHDzBZjZILbVW8dNtYdC6XXWpu5gSsaylgmDf5Q
         pakg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXEPf8ZcctNNHW9pQ4d68bG0QUIZgdcp6cS+0YjARZ9vAvhIZvq
	PFFOrzctOienRdnfm0kRnqIEqR39mHXdWsmpBE1zsTAbas/RipWHQmLBs71f73Akaiv5rg+VqJ9
	bhLqknTlMAoLc51Y4jcwB5JFGiBy6HUQBu4QddfzaMMukbnyLTLmuki8iycJGfKM1yw==
X-Received: by 2002:a0c:9ac1:: with SMTP id k1mr532345qvf.36.1555625153003;
        Thu, 18 Apr 2019 15:05:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2433QR+Qu1YVoaBjerE6OibvQcE64Alr9kXqLzFDkGgyOG+cWjZkFub9qcI6Ve5UKeCOs
X-Received: by 2002:a0c:9ac1:: with SMTP id k1mr532299qvf.36.1555625152428;
        Thu, 18 Apr 2019 15:05:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555625152; cv=none;
        d=google.com; s=arc-20160816;
        b=1HoBWRMQRRNVx7jnZCTwAEPR6CEgIrp3ykx4TmCsttMhnoxbmrE3SMsSVSehna7Ubx
         1ocRfxeHfeVVjAZsz3FgLRt5trnlBkiLRi/Mu+yz7NKamVeDNoEXxkKBogofmbsuMsrD
         qpJOqtbGwyNHZaHoCkDysVDlUPGx8V81TPdxGEwo+oZA8AQmfRpzuMsUZJtHL7RVnWAJ
         obQKP9B+L74vDX+tSHkHtkZrDeB97GOeoKCneNv6z9jfoMojamt6zQKw4XW2FO4nYkdD
         EJklv4wULb/JmW6U4P6diz+RLW90/Uc4q8ioPk/6dVJLXpap5iE/YVIpAIcrTfp5tOI9
         6BfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=kjaqv1yERcNZ6s1PEC8wCbequ+KYSzl8PjfiI4bSXoA=;
        b=BE5783Vbjz9xd+sjz9W/PlvkzmtD16WZItaEQj9Ltfukp3wWNUndXhPnMXiNbJNqxQ
         Z1eK7LusUILOm3hfd+n9i+7kHeDjFKO4swOvR2UG3R8DqTQ9Dw52diFpaH4v67ESqT31
         UPItviLPfbmJOOolNmOQi37Qp5g90B3Oeo1yfmH5+iZqs+FYaUn5iIZF+bcRVCodeA1N
         bWiUAjcTD8Z8t5TGzBRznOOJGWLXWJSZgE/7QdkagZK7dcW5zqpYoxh3vLMDOPC2BLBM
         3NID3MUatAc70pBmJ2MmhCsn6Cnc8rQ6fidluAzkvmno71cfJHsD7AOX2go/ktzuExaX
         9/Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d28si2201393qtb.275.2019.04.18.15.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 15:05:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F3EE7301EA88;
	Thu, 18 Apr 2019 22:05:50 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 46F5A600C5;
	Thu, 18 Apr 2019 22:05:47 +0000 (UTC)
Date: Thu, 18 Apr 2019 18:05:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 06/31] mm: introduce pte_spinlock for
 FAULT_FLAG_SPECULATIVE
Message-ID: <20190418220545.GF11645@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-7-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-7-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 18 Apr 2019 22:05:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:44:57PM +0200, Laurent Dufour wrote:
> When handling page fault without holding the mmap_sem the fetch of the
> pte lock pointer and the locking will have to be done while ensuring
> that the VMA is not touched in our back.
> 
> So move the fetch and locking operations in a dedicated function.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>


> ---
>  mm/memory.c | 15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index fc3698d13cb5..221ccdf34991 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2073,6 +2073,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
> +static inline bool pte_spinlock(struct vm_fault *vmf)
> +{
> +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> +	spin_lock(vmf->ptl);
> +	return true;
> +}
> +
>  static inline bool pte_map_lock(struct vm_fault *vmf)
>  {
>  	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> @@ -3656,8 +3663,8 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
>  	 * validation through pte_unmap_same(). It's of NUMA type but
>  	 * the pfn may be screwed if the read is non atomic.
>  	 */
> -	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
> -	spin_lock(vmf->ptl);
> +	if (!pte_spinlock(vmf))
> +		return VM_FAULT_RETRY;
>  	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
>  		goto out;
> @@ -3850,8 +3857,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
>  		return do_numa_page(vmf);
>  
> -	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> -	spin_lock(vmf->ptl);
> +	if (!pte_spinlock(vmf))
> +		return VM_FAULT_RETRY;
>  	entry = vmf->orig_pte;
>  	if (unlikely(!pte_same(*vmf->pte, entry)))
>  		goto unlock;
> -- 
> 2.21.0
> 

