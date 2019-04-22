Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4602C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BC7D20859
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 20:32:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BC7D20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 364366B0003; Mon, 22 Apr 2019 16:32:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EEB76B0006; Mon, 22 Apr 2019 16:32:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6716B0007; Mon, 22 Apr 2019 16:32:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAABE6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 16:32:26 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k68so8993127qkd.21
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 13:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=P09pkxWElASToNdfd2dy3lTcBD1etVU9+ydYGLyvzu0=;
        b=V90NajGcERaIoUbl1JW0meTFxv7cUB4SyT1xsNTb0NiUGSnkiv80QLf6Sa68Doy3st
         HM6W/ZUZ01CTRzKNW2PfnVbJJHF5QAeSel4Kffh1r6xJNZKB0GLkaKniptN/11AmOnyH
         uEgzr2ZDM1SYTZYi3TRX+/YTGz3aUNYWJJ/zIYx8tnixHul2cH4JBtTbJc3jW/AfkuAl
         NQ8Csq7yNoHWDLNBPGXNIdZ8f41DTJti73XDqJYeEnBUQnt9R+aP9gv1gH8bxA0+sii1
         O4YGbC0aZIdfmmsW35lqKUQbUAdKtKbqkDLBTg43B3VT+7Y4Vr1FRUxzlrlrxkZlvKuK
         gdKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVvpqAND/Nuxjvz2yP31orYwK0NK0qVTtfOlukmN/hv19FBlbgE
	w5kAQZjK+bX3WI8eC88Cb2iylWG0NOo1ftvqYmQiS3LEogjzcjK3HHZVp6/WA+w07FJW115WvZT
	eeZvx/Qp+p34vRWPXBUyIKgkoqZ//AeTo8x2Srqh+Vi9GJOdxug35v2qqSLL76gG7Gw==
X-Received: by 2002:a0c:bec4:: with SMTP id f4mr16949631qvj.17.1555965146700;
        Mon, 22 Apr 2019 13:32:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiHOHWSmnEEXJhHX+P+WudJDOPzbSW4j3UqNwVqn3NIhFyYTQ5ZV6ZKmJ5i9xJyfIn2hgm
X-Received: by 2002:a0c:bec4:: with SMTP id f4mr16949567qvj.17.1555965145830;
        Mon, 22 Apr 2019 13:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555965145; cv=none;
        d=google.com; s=arc-20160816;
        b=nKoKh3Q/sNQVKENB0r2AHhQDoT9fE7i8HTU8s96LeKdpPQWudi/QyTofKigRsDqlCE
         FIzIWW+/EiQohijc3g7oQB0cIfj2D9Lle+gJokbBgF31kFmE+yvexy/zX1Scbd/NVcBZ
         rNSXFzAcwiJtHAno8OR+47nLDri+tElo4TUiWOsBO3D48TfOMSePa5Hzc7bh2m6o86yQ
         zPs+hUQnKXojI8mfn/JO0h6u6n1gifavTIwhKaYK6847XTPNJfGpxQwfOfi39aPcNJs2
         KBxNU/M7NoF2l24+6TgLJCZQKfE/p1aDIxcUH0lqU3WOs7LJM6lLmsbDP9/pepgm2nCT
         8ZTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=P09pkxWElASToNdfd2dy3lTcBD1etVU9+ydYGLyvzu0=;
        b=z9w5PQlnYRf08vuCGXjCRDrRg27DKppDcw+UhBzFNq90Yhvx6pZqhHRa4S2sSbkO15
         XsV+zBH2o1rLhLQdOtX1M3u56BHC1QNXD2pz4SjE/Sk9qLB2Xri7eQsiyo5AK694ziIT
         1BJTz0sLMb9Ih99iaL7ozaX5R/wWIxHISXDLaMJkJJ+dpx4tCr3kga6dUCYdzvALlWaN
         ucc9llbsSOD2mmhuFYaymQu02HelHRESdToFt80FnClR0ztThTwEm2eHqgnBT8fnvVmB
         N9bx4NXMHApA8UGUinzuKoiVqfZspgxG5DETY6ogUnTh8BAhMA1ABhVSP+rEYV3uXVta
         QIiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n40si3921211qvc.51.2019.04.22.13.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 13:32:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 27DE43092654;
	Mon, 22 Apr 2019 20:32:24 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id CBEE05D6A6;
	Mon, 22 Apr 2019 20:32:19 +0000 (UTC)
Date: Mon, 22 Apr 2019 16:32:18 -0400
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
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org,
	Vinayak Menon <vinmenon@codeaurora.org>
Subject: Re: [PATCH v12 18/31] mm: protect against PTE changes done by
 dup_mmap()
Message-ID: <20190422203217.GI14666@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-19-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190416134522.17540-19-ldufour@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 22 Apr 2019 20:32:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 03:45:09PM +0200, Laurent Dufour wrote:
> Vinayak Menon and Ganesh Mahendran reported that the following scenario may
> lead to thread being blocked due to data corruption:
> 
>     CPU 1                   CPU 2                    CPU 3
>     Process 1,              Process 1,               Process 1,
>     Thread A                Thread B                 Thread C
> 
>     while (1) {             while (1) {              while(1) {
>     pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>     pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>     }                       }
> 
> In the details this happens because :
> 
>     CPU 1                CPU 2                       CPU 3
>     fork()
>     copy_pte_range()
>       set PTE rdonly
>     got to next VMA...
>      .                   PTE is seen rdonly          PTE still writable
>      .                   thread is writing to page
>      .                   -> page fault
>      .                     copy the page             Thread writes to page
>      .                      .                        -> no page fault
>      .                     update the PTE
>      .                     flush TLB for that PTE
>    flush TLB                                        PTE are now rdonly

Should the fork be on CPU3 to be consistant with the top thing (just to
make it easier to read and go from one to the other as thread can move
from one CPU to another).

> 
> So the write done by the CPU 3 is interfering with the page copy operation
> done by CPU 2, leading to the data corruption.
> 
> To avoid this we mark all the VMA involved in the COW mechanism as changing
> by calling vm_write_begin(). This ensures that the speculative page fault
> handler will not try to handle a fault on these pages.
> The marker is set until the TLB is flushed, ensuring that all the CPUs will
> now see the PTE as not writable.
> Once the TLB is flush, the marker is removed by calling vm_write_end().
> 
> The variable last is used to keep tracked of the latest VMA marked to
> handle the error path where part of the VMA may have been marked.
> 
> Since multiple VMA from the same mm may have the sequence count increased
> during this process, the use of the vm_raw_write_begin/end() is required to
> avoid lockdep false warning messages.
> 
> Reported-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>

A minor comment (see below)

Reviewed-by: Jérome Glisse <jglisse@redhat.com>

> ---
>  kernel/fork.c | 30 ++++++++++++++++++++++++++++--
>  1 file changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f8dae021c2e5..2992d2c95256 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -462,7 +462,7 @@ EXPORT_SYMBOL(free_task);
>  static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  					struct mm_struct *oldmm)
>  {
> -	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
> +	struct vm_area_struct *mpnt, *tmp, *prev, **pprev, *last = NULL;
>  	struct rb_node **rb_link, *rb_parent;
>  	int retval;
>  	unsigned long charge;
> @@ -581,8 +581,18 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  		rb_parent = &tmp->vm_rb;
>  
>  		mm->map_count++;
> -		if (!(tmp->vm_flags & VM_WIPEONFORK))
> +		if (!(tmp->vm_flags & VM_WIPEONFORK)) {
> +			if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {
> +				/*
> +				 * Mark this VMA as changing to prevent the
> +				 * speculative page fault hanlder to process
> +				 * it until the TLB are flushed below.
> +				 */
> +				last = mpnt;
> +				vm_raw_write_begin(mpnt);
> +			}
>  			retval = copy_page_range(mm, oldmm, mpnt);
> +		}
>  
>  		if (tmp->vm_ops && tmp->vm_ops->open)
>  			tmp->vm_ops->open(tmp);
> @@ -595,6 +605,22 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
>  out:
>  	up_write(&mm->mmap_sem);
>  	flush_tlb_mm(oldmm);
> +
> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {

You do not need to check for CONFIG_SPECULATIVE_PAGE_FAULT as last
will always be NULL if it is not enabled but maybe the compiler will
miss the optimization opportunity if you only have the for() loop
below.

> +		/*
> +		 * Since the TLB has been flush, we can safely unmark the
> +		 * copied VMAs and allows the speculative page fault handler to
> +		 * process them again.
> +		 * Walk back the VMA list from the last marked VMA.
> +		 */
> +		for (; last; last = last->vm_prev) {
> +			if (last->vm_flags & VM_DONTCOPY)
> +				continue;
> +			if (!(last->vm_flags & VM_WIPEONFORK))
> +				vm_raw_write_end(last);
> +		}
> +	}
> +
>  	up_write(&oldmm->mmap_sem);
>  	dup_userfaultfd_complete(&uf);
>  fail_uprobe_end:
> -- 
> 2.21.0
> 

