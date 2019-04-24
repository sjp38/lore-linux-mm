Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 886DDC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 15:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 281152148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 15:14:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 281152148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFCD96B0007; Wed, 24 Apr 2019 11:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAB9D6B0008; Wed, 24 Apr 2019 11:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99BE56B000A; Wed, 24 Apr 2019 11:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4696B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:14:00 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f20so14992069qtf.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:14:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WENIyZFw2vkKplyFENhs8iBQectF/EmOryptPTNelWQ=;
        b=PzJsGyDdCxkOhNeIfL8wcddmS7vL4K3sen3KqI54VDLJ1diHLZRiuDtIkYNQIDzZjQ
         cBJnsXlWZExRtt+cU0PIaJrmJjBsK166oVkL5+hcXhI+EAwwXjQDlomwVSRSeXx0Shf+
         A9F4vCgyHoG/toCg9yMq/ly+pgK0u0HnrNJkZeXM6M8PHjafcGkoBweZ89NfgeUKEOFD
         XSedCoyrrdiIE9f0C+iXXVftGAwljMpTN7//pWGNzG+WtolW6LMudVetclzEBKpsHyy+
         ZTqWQRbtp1nlGPT0g/5HGdZpDvXUyobcYeIUxrbWj2gHe0oFCEbs82BQkX5hW1u9UOor
         Bl5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUGdnRRGNFFdU3cWkqzx3CQRG88iGTLcjxSCCiQpBuasOUl+nTV
	LkMJcEIlbMBNhpoklu37wj5ShIDXXAmk5UWMuYG9AK/j7j6zeD7q55TZpmkX6WvfFegvJDb4xti
	xbIJmKjGs1zprOkpoZq6pGviLtPCeXVbyNoQOcsUeTspMBYpQaxB4Drvo03tz/zG2wA==
X-Received: by 2002:aed:3f3a:: with SMTP id p55mr8036676qtf.302.1556118840153;
        Wed, 24 Apr 2019 08:14:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy60lJidFTeMI8X/7lYBJf/pKbYhkLPUVM9z/EXqa9DdPqcKprzBVx7XL7xX/jDcSElsrq0
X-Received: by 2002:aed:3f3a:: with SMTP id p55mr8036550qtf.302.1556118838641;
        Wed, 24 Apr 2019 08:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556118838; cv=none;
        d=google.com; s=arc-20160816;
        b=GnzBcnu8vtlshQ6pZJJrAJZDLA1MapEerh+9MuvcJJl6CTc9Eve3ucA9g8kja9e4FN
         uZrq2lkd8K+uaMMjANbxvqe42DvYYasasIK8vxdpl7NWH3Av9uaS0nAzy6sTXXEbdFuP
         nmZUwZpSktThzJAJ2w94Hqq8ghBM+0X0jSSY6Ba8D9PuuDPgSvBOGVmiAizReBgc+UGG
         NRTtR4ffonVYe2kQ22J1kypjzUNeUBR20e1J5hCkaqNN6PkdCnHMCfypSyP5EtJk59NX
         oms8zQr3uUg8PxbM4w7uWD8UVmfKwTrody3luwIXaPAqW5h0bzjy5JYGAzzKjziko6NC
         Cv5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=WENIyZFw2vkKplyFENhs8iBQectF/EmOryptPTNelWQ=;
        b=eB216CvPqotoTOIOn34SI2WPVBo+kVDXx71UwK02h1mV2lJnOJbYaYrUzg3j3fbWDp
         uwRtceTHMXblCinDXgn1rvBMWquvzPVW8XOS9Jpvj8BQ8KVVkcesO7Zv3Rc+5B6olZR9
         B+YK1+Yv9ZeHXJCzb8m94PArlu8JGHF7sr6TGUH6m3M2Ly9cmKNWBvLKQOfLXkqcUZ4b
         PYaALBVEPy+nAkIsqNpbQIXS22W+gNwxc4TQZ0IUYWoPuMOS2prQKDBwdtc1Pdw/nx76
         Mqr9cwBs4ac/SfhgSY3G0bB9KXr7IYgrdBDTt/fzx+eFDVZEN7y3rhPp/M/g6enDaFIj
         ueLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z1si3033257qtb.264.2019.04.24.08.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 08:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 876A63084027;
	Wed, 24 Apr 2019 15:13:42 +0000 (UTC)
Received: from redhat.com (ovpn-124-214.rdu2.redhat.com [10.10.124.214])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5B220272D2;
	Wed, 24 Apr 2019 15:13:32 +0000 (UTC)
Date: Wed, 24 Apr 2019 11:13:30 -0400
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
Subject: Re: [PATCH v12 22/31] mm: provide speculative fault infrastructure
Message-ID: <20190424151329.GA4491@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-23-ldufour@linux.ibm.com>
 <20190422212623.GM14666@redhat.com>
 <a1e27d15-2890-28fc-d350-ca62fb77f508@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a1e27d15-2890-28fc-d350-ca62fb77f508@linux.ibm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 24 Apr 2019 15:13:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 04:56:14PM +0200, Laurent Dufour wrote:
> Le 22/04/2019 à 23:26, Jerome Glisse a écrit :
> > On Tue, Apr 16, 2019 at 03:45:13PM +0200, Laurent Dufour wrote:
> > > From: Peter Zijlstra <peterz@infradead.org>
> > > 
> > > Provide infrastructure to do a speculative fault (not holding
> > > mmap_sem).
> > > 
> > > The not holding of mmap_sem means we can race against VMA
> > > change/removal and page-table destruction. We use the SRCU VMA freeing
> > > to keep the VMA around. We use the VMA seqcount to detect change
> > > (including umapping / page-table deletion) and we use gup_fast() style
> > > page-table walking to deal with page-table races.
> > > 
> > > Once we've obtained the page and are ready to update the PTE, we
> > > validate if the state we started the fault with is still valid, if
> > > not, we'll fail the fault with VM_FAULT_RETRY, otherwise we update the
> > > PTE and we're done.
> > > 
> > > Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> > > 
> > > [Manage the newly introduced pte_spinlock() for speculative page
> > >   fault to fail if the VMA is touched in our back]
> > > [Rename vma_is_dead() to vma_has_changed() and declare it here]
> > > [Fetch p4d and pud]
> > > [Set vmd.sequence in __handle_mm_fault()]
> > > [Abort speculative path when handle_userfault() has to be called]
> > > [Add additional VMA's flags checks in handle_speculative_fault()]
> > > [Clear FAULT_FLAG_ALLOW_RETRY in handle_speculative_fault()]
> > > [Don't set vmf->pte and vmf->ptl if pte_map_lock() failed]
> > > [Remove warning comment about waiting for !seq&1 since we don't want
> > >   to wait]
> > > [Remove warning about no huge page support, mention it explictly]
> > > [Don't call do_fault() in the speculative path as __do_fault() calls
> > >   vma->vm_ops->fault() which may want to release mmap_sem]
> > > [Only vm_fault pointer argument for vma_has_changed()]
> > > [Fix check against huge page, calling pmd_trans_huge()]
> > > [Use READ_ONCE() when reading VMA's fields in the speculative path]
> > > [Explicitly check for __HAVE_ARCH_PTE_SPECIAL as we can't support for
> > >   processing done in vm_normal_page()]
> > > [Check that vma->anon_vma is already set when starting the speculative
> > >   path]
> > > [Check for memory policy as we can't support MPOL_INTERLEAVE case due to
> > >   the processing done in mpol_misplaced()]
> > > [Don't support VMA growing up or down]
> > > [Move check on vm_sequence just before calling handle_pte_fault()]
> > > [Don't build SPF services if !CONFIG_SPECULATIVE_PAGE_FAULT]
> > > [Add mem cgroup oom check]
> > > [Use READ_ONCE to access p*d entries]
> > > [Replace deprecated ACCESS_ONCE() by READ_ONCE() in vma_has_changed()]
> > > [Don't fetch pte again in handle_pte_fault() when running the speculative
> > >   path]
> > > [Check PMD against concurrent collapsing operation]
> > > [Try spin lock the pte during the speculative path to avoid deadlock with
> > >   other CPU's invalidating the TLB and requiring this CPU to catch the
> > >   inter processor's interrupt]
> > > [Move define of FAULT_FLAG_SPECULATIVE here]
> > > [Introduce __handle_speculative_fault() and add a check against
> > >   mm->mm_users in handle_speculative_fault() defined in mm.h]
> > > [Abort if vm_ops->fault is set instead of checking only vm_ops]
> > > [Use find_vma_rcu() and call put_vma() when we are done with the VMA]
> > > Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> > 
> > 
> > Few comments and questions for this one see below.
> > 
> > 
> > > ---
> > >   include/linux/hugetlb_inline.h |   2 +-
> > >   include/linux/mm.h             |  30 +++
> > >   include/linux/pagemap.h        |   4 +-
> > >   mm/internal.h                  |  15 ++
> > >   mm/memory.c                    | 344 ++++++++++++++++++++++++++++++++-
> > >   5 files changed, 389 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.h
> > > index 0660a03d37d9..9e25283d6fc9 100644
> > > --- a/include/linux/hugetlb_inline.h
> > > +++ b/include/linux/hugetlb_inline.h
> > > @@ -8,7 +8,7 @@
> > >   static inline bool is_vm_hugetlb_page(struct vm_area_struct *vma)
> > >   {
> > > -	return !!(vma->vm_flags & VM_HUGETLB);
> > > +	return !!(READ_ONCE(vma->vm_flags) & VM_HUGETLB);
> > >   }
> > >   #else
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index f761a9c65c74..ec609cbad25a 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -381,6 +381,7 @@ extern pgprot_t protection_map[16];
> > >   #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
> > >   #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
> > >   #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> > > +#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
> > >   #define FAULT_FLAG_TRACE \
> > >   	{ FAULT_FLAG_WRITE,		"WRITE" }, \
> > > @@ -409,6 +410,10 @@ struct vm_fault {
> > >   	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
> > >   	pgoff_t pgoff;			/* Logical page offset based on vma */
> > >   	unsigned long address;		/* Faulting virtual address */
> > > +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> > > +	unsigned int sequence;
> > > +	pmd_t orig_pmd;			/* value of PMD at the time of fault */
> > > +#endif
> > >   	pmd_t *pmd;			/* Pointer to pmd entry matching
> > >   					 * the 'address' */
> > >   	pud_t *pud;			/* Pointer to pud entry matching
> > > @@ -1524,6 +1529,31 @@ int invalidate_inode_page(struct page *page);
> > >   #ifdef CONFIG_MMU
> > >   extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
> > >   			unsigned long address, unsigned int flags);
> > > +
> > > +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> > > +extern vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
> > > +					     unsigned long address,
> > > +					     unsigned int flags);
> > > +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
> > > +						  unsigned long address,
> > > +						  unsigned int flags)
> > > +{
> > > +	/*
> > > +	 * Try speculative page fault for multithreaded user space task only.
> > > +	 */
> > > +	if (!(flags & FAULT_FLAG_USER) || atomic_read(&mm->mm_users) == 1)
> > > +		return VM_FAULT_RETRY;
> > > +	return __handle_speculative_fault(mm, address, flags);
> > > +}
> > > +#else
> > > +static inline vm_fault_t handle_speculative_fault(struct mm_struct *mm,
> > > +						  unsigned long address,
> > > +						  unsigned int flags)
> > > +{
> > > +	return VM_FAULT_RETRY;
> > > +}
> > > +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> > > +
> > >   extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
> > >   			    unsigned long address, unsigned int fault_flags,
> > >   			    bool *unlocked);
> > > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> > > index 2e8438a1216a..2fcfaa910007 100644
> > > --- a/include/linux/pagemap.h
> > > +++ b/include/linux/pagemap.h
> > > @@ -457,8 +457,8 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
> > >   	pgoff_t pgoff;
> > >   	if (unlikely(is_vm_hugetlb_page(vma)))
> > >   		return linear_hugepage_index(vma, address);
> > > -	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
> > > -	pgoff += vma->vm_pgoff;
> > > +	pgoff = (address - READ_ONCE(vma->vm_start)) >> PAGE_SHIFT;
> > > +	pgoff += READ_ONCE(vma->vm_pgoff);
> > >   	return pgoff;
> > >   }
> > > diff --git a/mm/internal.h b/mm/internal.h
> > > index 1e368e4afe3c..ed91b199cb8c 100644
> > > --- a/mm/internal.h
> > > +++ b/mm/internal.h
> > > @@ -58,6 +58,21 @@ static inline void put_vma(struct vm_area_struct *vma)
> > >   extern struct vm_area_struct *find_vma_rcu(struct mm_struct *mm,
> > >   					   unsigned long addr);
> > > +
> > > +static inline bool vma_has_changed(struct vm_fault *vmf)
> > > +{
> > > +	int ret = RB_EMPTY_NODE(&vmf->vma->vm_rb);
> > > +	unsigned int seq = READ_ONCE(vmf->vma->vm_sequence.sequence);
> > > +
> > > +	/*
> > > +	 * Matches both the wmb in write_seqlock_{begin,end}() and
> > > +	 * the wmb in vma_rb_erase().
> > > +	 */
> > > +	smp_rmb();
> > > +
> > > +	return ret || seq != vmf->sequence;
> > > +}
> > > +
> > >   #else /* CONFIG_SPECULATIVE_PAGE_FAULT */
> > >   static inline void get_vma(struct vm_area_struct *vma)
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 46f877b6abea..6e6bf61c0e5c 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -522,7 +522,8 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
> > >   	if (page)
> > >   		dump_page(page, "bad pte");
> > >   	pr_alert("addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
> > > -		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
> > > +		 (void *)addr, READ_ONCE(vma->vm_flags), vma->anon_vma,
> > > +		 mapping, index);
> > >   	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
> > >   		 vma->vm_file,
> > >   		 vma->vm_ops ? vma->vm_ops->fault : NULL,
> > > @@ -2082,6 +2083,118 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
> > >   }
> > >   EXPORT_SYMBOL_GPL(apply_to_page_range);
> > > +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> > > +static bool pte_spinlock(struct vm_fault *vmf)
> > > +{
> > > +	bool ret = false;
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > > +	pmd_t pmdval;
> > > +#endif
> > > +
> > > +	/* Check if vma is still valid */
> > > +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
> > > +		vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> > > +		spin_lock(vmf->ptl);
> > > +		return true;
> > > +	}
> > > +
> > > +again:
> > > +	local_irq_disable();
> > > +	if (vma_has_changed(vmf))
> > > +		goto out;
> > > +
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > > +	/*
> > > +	 * We check if the pmd value is still the same to ensure that there
> > > +	 * is not a huge collapse operation in progress in our back.
> > > +	 */
> > > +	pmdval = READ_ONCE(*vmf->pmd);
> > > +	if (!pmd_same(pmdval, vmf->orig_pmd))
> > > +		goto out;
> > > +#endif
> > > +
> > > +	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> > > +	if (unlikely(!spin_trylock(vmf->ptl))) {
> > > +		local_irq_enable();
> > > +		goto again;
> > > +	}
> > 
> > Do we want to constantly retry taking the spinlock ? Shouldn't it
> > be limited ? If we fail few times it is probably better to give
> > up on that speculative page fault.
> > 
> > So maybe putting everything within a for(i; i < MAX_TRY; ++i) loop
> > would be cleaner.
> 
> I did tried that by the past when I added this loop but I never reach the
> limit I set. By the way what should be the MAX_TRY value? ;)

A power of 2 :) Like 4, something small.

> 
> The loop was introduced to fix a race between CPU, this is explained in the
> patch description, but a comment is clearly missing here:
> 
> /*
>  * A spin_trylock() of the ptl is done to avoid a deadlock with other
>  * CPU invalidating the TLB and requiring this CPU to catch the IPI.
>  * As the interrupt are disabled during this operation we need to relax
>  * them and try again locking the PTL.
>  */
> 
> I don't think that retrying the page fault would help, since the regular
> page fault handler will also spin here if there is a massive contention on
> the PTL.

My main fear is the loop will hammer a CPU if another CPU is holding
the same spinlock. In most places the page table lock should be held
only for short period of time so it should never last long. So while i
can not think of any reasons it would loop forever i fear i might have
a lack of imagination here.

> 
> > 
> > 
> > > +
> > > +	if (vma_has_changed(vmf)) {
> > > +		spin_unlock(vmf->ptl);
> > > +		goto out;
> > > +	}
> > > +
> > > +	ret = true;
> > > +out:
> > > +	local_irq_enable();
> > > +	return ret;
> > > +}
> > > +
> > > +static bool pte_map_lock(struct vm_fault *vmf)
> > > +{
> > > +	bool ret = false;
> > > +	pte_t *pte;
> > > +	spinlock_t *ptl;
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > > +	pmd_t pmdval;
> > > +#endif
> > > +
> > > +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE)) {
> > > +		vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> > > +					       vmf->address, &vmf->ptl);
> > > +		return true;
> > > +	}
> > > +
> > > +	/*
> > > +	 * The first vma_has_changed() guarantees the page-tables are still
> > > +	 * valid, having IRQs disabled ensures they stay around, hence the
> > > +	 * second vma_has_changed() to make sure they are still valid once
> > > +	 * we've got the lock. After that a concurrent zap_pte_range() will
> > > +	 * block on the PTL and thus we're safe.
> > > +	 */
> > > +again:
> > > +	local_irq_disable();
> > > +	if (vma_has_changed(vmf))
> > > +		goto out;
> > > +
> > > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > > +	/*
> > > +	 * We check if the pmd value is still the same to ensure that there
> > > +	 * is not a huge collapse operation in progress in our back.
> > > +	 */
> > > +	pmdval = READ_ONCE(*vmf->pmd);
> > > +	if (!pmd_same(pmdval, vmf->orig_pmd))
> > > +		goto out;
> > > +#endif
> > > +
> > > +	/*
> > > +	 * Same as pte_offset_map_lock() except that we call
> > > +	 * spin_trylock() in place of spin_lock() to avoid race with
> > > +	 * unmap path which may have the lock and wait for this CPU
> > > +	 * to invalidate TLB but this CPU has irq disabled.
> > > +	 * Since we are in a speculative patch, accept it could fail
> > > +	 */
> > > +	ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> > > +	pte = pte_offset_map(vmf->pmd, vmf->address);
> > > +	if (unlikely(!spin_trylock(ptl))) {
> > > +		pte_unmap(pte);
> > > +		local_irq_enable();
> > > +		goto again;
> > > +	}
> > 
> > Same comment as above shouldn't be limited to a maximum number of retry ?
> 
> Same answer ;)
> 
> > 
> > > +
> > > +	if (vma_has_changed(vmf)) {
> > > +		pte_unmap_unlock(pte, ptl);
> > > +		goto out;
> > > +	}
> > > +
> > > +	vmf->pte = pte;
> > > +	vmf->ptl = ptl;
> > > +	ret = true;
> > > +out:
> > > +	local_irq_enable();
> > > +	return ret;
> > > +}
> > > +#else
> > >   static inline bool pte_spinlock(struct vm_fault *vmf)
> > >   {
> > >   	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
> > > @@ -2095,6 +2208,7 @@ static inline bool pte_map_lock(struct vm_fault *vmf)
> > >   				       vmf->address, &vmf->ptl);
> > >   	return true;
> > >   }
> > > +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> > >   /*
> > >    * handle_pte_fault chooses page fault handler according to an entry which was
> > > @@ -2999,6 +3113,14 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
> > >   		ret = check_stable_address_space(vma->vm_mm);
> > >   		if (ret)
> > >   			goto unlock;
> > > +		/*
> > > +		 * Don't call the userfaultfd during the speculative path.
> > > +		 * We already checked for the VMA to not be managed through
> > > +		 * userfaultfd, but it may be set in our back once we have lock
> > > +		 * the pte. In such a case we can ignore it this time.
> > > +		 */
> > > +		if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> > > +			goto setpte;
> > 
> > Bit confuse by the comment above, if userfaultfd is set in the back
> > then shouldn't the speculative fault abort ? So wouldn't the following
> > be correct:
> > 
> > 		if (userfaultfd_missing(vma)) {
> > 			pte_unmap_unlock(vmf->pte, vmf->ptl);
> > 			if (vmf->flags & FAULT_FLAG_SPECULATIVE)
> > 				return VM_FAULT_RETRY;
> > 			...
> 
> Well here we are racing with the user space action setting the userfaultfd,
> we may have go through this page fault seeing the userfaultfd or not. But I
> can't imagine that the user process will rely on that to happen. If there is
> such a race, it would be up to the user space process to ensure that no page
> fault are triggered while it is setting up the userfaultfd.
> Since a check on the userfaultfd is done at the beginning of the SPF
> handler, I made the choice to ignore this later and not trigger the
> userfault this time.
> 
> Obviously we may abort the SPF handling but what is the benefit ?

Yeah probably no benefit one way or the other, backing of when a vma
change in anyway seems to be more consistent to me but i am fine either
way.

> 
> > 
> > >   		/* Deliver the page fault to userland, check inside PT lock */
> > >   		if (userfaultfd_missing(vma)) {
> > >   			pte_unmap_unlock(vmf->pte, vmf->ptl);
> > > @@ -3041,7 +3163,8 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
> > >   		goto unlock_and_release;
> > >   	/* Deliver the page fault to userland, check inside PT lock */
> > > -	if (userfaultfd_missing(vma)) {
> > > +	if (!(vmf->flags & FAULT_FLAG_SPECULATIVE) &&
> > > +	    userfaultfd_missing(vma)) {
> > 
> > Same comment as above but this also seems more wrong then above. What
> > i propose above would look more correct in both cases ie we still want
> > to check for userfaultfd but if we are in speculative fault then we
> > just want to abort the speculative fault.
> 
> Why is more wrong here ? Indeed this is consistent with the previous action,
> ignore the userfault event if it has been set while the SPF handler is in
> progress. IMHO this is up to the user space to serialize the userfaultfd
> setting against the ongoing page fault in that case.

Adding a comment saying that SPF would have back off if userfaulfd
was arm at begining of SPF and that we want to ignore race with
userfaultfd enablement.

