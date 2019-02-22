Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC138C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 887D420823
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 887D420823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED578E0112; Fri, 22 Feb 2019 10:17:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1A48E0109; Fri, 22 Feb 2019 10:17:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7478E0112; Fri, 22 Feb 2019 10:17:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D56FF8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:17:16 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id e1so2258009qth.23
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:17:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KKsXW0jnkjvHI4KB4+q2o3adHOvgtei/ego8Zgdus2Y=;
        b=SE33FWG+hsAhRg5uGVSAhbCKqaz7iM0Oe7RHOUWrbCFznRFw5SJwpEr1x4ntLRaKcE
         jV/ER86SixRhPyLuyYHXOwlEL7Bh8dcbdjqd2h3A+pe4DdeLnyOz8pwBxchOQRwZOB6U
         s4T8W3M6XDyb2EuhXD/0YjUf7L4/tDtRtzOaetf5j+r8lDbYkSPNysaRElJMVuaqP3uI
         sYz4w2JDCUqMTR3tTnGJW9/XFKe4+dZ7munjoWuNBZPgbfxhuXq0XkhhoJUfoJzOioV9
         7MSiefF/t5y2j9MzA0En4adeweyUe7Jgbz/gS+bp38s/WDhrmWaI+4CoLe/iz54tb0G0
         +ipw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaE0Gklb4mF+5PBFEl1ODEC0RHzJ1TJ5PCtliJ6ux9XyWLp4bLG
	BQbxhHywAjePyh8uBlkSIqkySoYtR9N5A2pxl1Pnx6753bUNuHFgkBLUKKfeMTKPlmCRoS4HxmY
	mrdV4nwakOveb86MK71JFLJaj0rKwlrSSkqSM9kPCqagyBP9RFiNwOLUaYYGPjESJKQ==
X-Received: by 2002:a37:4804:: with SMTP id v4mr3313876qka.104.1550848636634;
        Fri, 22 Feb 2019 07:17:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazyO1o8NvrwLORPYzT/v/cBBjYoQtrxE9BIdQGNlaAUyxhVQMXgVvFozYivZxN3kbgIdXn
X-Received: by 2002:a37:4804:: with SMTP id v4mr3313823qka.104.1550848635909;
        Fri, 22 Feb 2019 07:17:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550848635; cv=none;
        d=google.com; s=arc-20160816;
        b=GHNPLDayiZNHDJ6ahawtoNTagBhKsTKBJyRrAOwjSMpalxGXIULGx7g6SIcSji4Zwf
         ymBgV44SPXmtU/XLKM60xmXR3rf05WyVszMgEBn15FYUZZ7FkLRfArrYHPLf8rImhjXW
         2zDLAL4GNMQ09ccb2TdBZeW4cguU1O1xS24tQT7LOHOzZeKaDfXU28kamQ95xkiIGIp+
         HO+Nzvo8EZSwj6GnopJh8waDPtYajJn0sw8wOxcpcDlVr8GEF/ChbURVonFBm09IiMYL
         uwp/aii6g/zk/m0raueyOzgx4/X5er0rB2SAPWKJSOr1ulQmx06GY+yIhKF3ajQBQoRO
         qyQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KKsXW0jnkjvHI4KB4+q2o3adHOvgtei/ego8Zgdus2Y=;
        b=bCTMO9z/jxBLa52xHDrBO9yLpFafsOJ0FvuNNZnzU8WCIK0BgSypd2nutJyWil/dfL
         DsGwYxKtpoGd5sAxOJ0kNw9nvBRPlkITFzRKF6xMLd5LpU+cSCBXZ1IhCsnMRsPynjpv
         3zXK2HSyeT5ZUJJ4S814jsqMElTspnBLChdcVbcg/vONQHI5s1KpIbyhFbsZzSAElA2q
         Lv99Eakm1yhyuxIf//5vCzUq5TnsJ8G7/nUt/DqRDV8PTO3HnwoefFMfAX0V7XQ1FLWq
         1j/5jqFaKKHC9gGHzK3j+2meiNTFEeBHNAGiCFHhoLy0EB2X5xuipAQ7JffoYPjP7lHT
         50VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t29si787368qvc.4.2019.02.22.07.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:17:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DEDBE3002F3C;
	Fri, 22 Feb 2019 15:17:14 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 583195D9E2;
	Fri, 22 Feb 2019 15:17:09 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:17:07 -0500
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
Subject: Re: [PATCH v2 12/26] userfaultfd: wp: apply _PAGE_UFFD_WP bit
Message-ID: <20190222151707.GD7783@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-13-peterx@redhat.com>
 <20190221174401.GL2813@redhat.com>
 <20190222073135.GJ8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222073135.GJ8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 22 Feb 2019 15:17:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 03:31:35PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 12:44:02PM -0500, Jerome Glisse wrote:
> > On Tue, Feb 12, 2019 at 10:56:18AM +0800, Peter Xu wrote:
> > > Firstly, introduce two new flags MM_CP_UFFD_WP[_RESOLVE] for
> > > change_protection() when used with uffd-wp and make sure the two new
> > > flags are exclusively used.  Then,
> > > 
> > >   - For MM_CP_UFFD_WP: apply the _PAGE_UFFD_WP bit and remove _PAGE_RW
> > >     when a range of memory is write protected by uffd
> > > 
> > >   - For MM_CP_UFFD_WP_RESOLVE: remove the _PAGE_UFFD_WP bit and recover
> > >     _PAGE_RW when write protection is resolved from userspace
> > > 
> > > And use this new interface in mwriteprotect_range() to replace the old
> > > MM_CP_DIRTY_ACCT.
> > > 
> > > Do this change for both PTEs and huge PMDs.  Then we can start to
> > > identify which PTE/PMD is write protected by general (e.g., COW or soft
> > > dirty tracking), and which is for userfaultfd-wp.
> > > 
> > > Since we should keep the _PAGE_UFFD_WP when doing pte_modify(), add it
> > > into _PAGE_CHG_MASK as well.  Meanwhile, since we have this new bit, we
> > > can be even more strict when detecting uffd-wp page faults in either
> > > do_wp_page() or wp_huge_pmd().
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > Few comments but still:
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> Thanks!
> 
> > 
> > > ---
> > >  arch/x86/include/asm/pgtable_types.h |  2 +-
> > >  include/linux/mm.h                   |  5 +++++
> > >  mm/huge_memory.c                     | 14 +++++++++++++-
> > >  mm/memory.c                          |  4 ++--
> > >  mm/mprotect.c                        | 12 ++++++++++++
> > >  mm/userfaultfd.c                     |  8 ++++++--
> > >  6 files changed, 39 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> > > index 8cebcff91e57..dd9c6295d610 100644
> > > --- a/arch/x86/include/asm/pgtable_types.h
> > > +++ b/arch/x86/include/asm/pgtable_types.h
> > > @@ -133,7 +133,7 @@
> > >   */
> > >  #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
> > >  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> > > -			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
> > > +			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP | _PAGE_UFFD_WP)
> > >  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
> > 
> > This chunk needs to be in the earlier arch specific patch.
> 
> Indeed.  I'll move it over.
> 
> > 
> > [...]
> > 
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > index 8d65b0f041f9..817335b443c2 100644
> > > --- a/mm/huge_memory.c
> > > +++ b/mm/huge_memory.c
> > 
> > [...]
> > 
> > > @@ -2198,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> > >  				entry = pte_mkold(entry);
> > >  			if (soft_dirty)
> > >  				entry = pte_mksoft_dirty(entry);
> > > +			if (uffd_wp)
> > > +				entry = pte_mkuffd_wp(entry);
> > >  		}
> > >  		pte = pte_offset_map(&_pmd, addr);
> > >  		BUG_ON(!pte_none(*pte));
> > 
> > Reading that code and i thought i would be nice if we could define a
> > pte_mask that we can or instead of all those if () entry |= ... but
> > that is just some dumb optimization and does not have any bearing on
> > the present patch. Just wanted to say that outloud.
> 
> (I agree; though I'll just concentrate on the series for now)
> 
> > 
> > 
> > > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > > index a6ba448c8565..9d4433044c21 100644
> > > --- a/mm/mprotect.c
> > > +++ b/mm/mprotect.c
> > > @@ -46,6 +46,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >  	int target_node = NUMA_NO_NODE;
> > >  	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
> > >  	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
> > > +	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
> > > +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
> > >  
> > >  	/*
> > >  	 * Can be called with only the mmap_sem for reading by
> > > @@ -117,6 +119,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >  			if (preserve_write)
> > >  				ptent = pte_mk_savedwrite(ptent);
> > >  
> > > +			if (uffd_wp) {
> > > +				ptent = pte_wrprotect(ptent);
> > > +				ptent = pte_mkuffd_wp(ptent);
> > > +			} else if (uffd_wp_resolve) {
> > > +				ptent = pte_mkwrite(ptent);
> > > +				ptent = pte_clear_uffd_wp(ptent);
> > > +			}
> > > +
> > >  			/* Avoid taking write faults for known dirty pages */
> > >  			if (dirty_accountable && pte_dirty(ptent) &&
> > >  					(pte_soft_dirty(ptent) ||
> > > @@ -301,6 +311,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
> > >  {
> > >  	unsigned long pages;
> > >  
> > > +	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);
> > 
> > Don't you want to abort and return here if both flags are set ?
> 
> Here I would slightly prefer BUG_ON() because current code (any
> userspace syscalls) cannot trigger this without changing the kernel
> (currently the only kernel user of these two flags will be
> mwriteprotect_range but it'll definitely only pass one flag in).  This
> line will be only useful when we add new kernel code (or writting new
> kernel drivers) and it can be used to detect programming errors. In
> that case IMHO BUG_ON() would be more straightforward.
> 

Ok i agree.

Cheers,
Jérôme

