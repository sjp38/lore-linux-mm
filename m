Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BEADC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:44:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C810F20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:44:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C810F20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47C508E009B; Thu, 21 Feb 2019 12:44:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42C338E0094; Thu, 21 Feb 2019 12:44:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31ACB8E009B; Thu, 21 Feb 2019 12:44:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 065F48E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:44:13 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id f24so27346416qte.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:44:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=VdrN4SIXWmBsI5Gz1BYGZaPEEBNaaKsPo9zDWJvUxg4=;
        b=kHYXcYCa2BNkSdQLqEp/iTqVmz/KExrlUmbhOklE5WwyDvw7ux+lXXto8TQK9yIcvW
         A9HEXiv8pm2325wgyT5x5yR+H6FupI4PNsR7iDRUHd3uDZYwvjkhurHWaIVxrCwRUFBm
         os6Jgk+2buk+di8Ev/fnjrP8vq/XxawglmcGZ/xxAAVWxaJ/HlfesTBGdH3lrqTS2/q3
         8sv8JyTv6pF48o227mCJgDQclQoWzI8/FoL5Oh4JNPDRcP8hDaokvb81w794v6RT3ohp
         8jt9aLb9Y/4rNFCHj21AnqcG9WOJXJY2wXTHd8aEsTP6LE8rZssNDrIzfrHK1WsGJq7u
         HW1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaN74/Aeuab1qvBNFqv0iFqyxYppgCFV/iFfr2pTzsXO4B+dTBX
	iaElLtDCU1MVtp/HQEJX4JeSJFWmKfNf15V88+8JqVEXeFZMFXZqXoDcZnypdbBLGhWFP2/hFtq
	/Rf2boLBQjJKOrC9xO1TcEjT3obvSZ1KvLJp7ErSO+0IHSQxmom8DV3bmhHjU6guCqw==
X-Received: by 2002:ac8:2847:: with SMTP id 7mr32004905qtr.335.1550771052775;
        Thu, 21 Feb 2019 09:44:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyzb9XM1dNerBDDWI1ihiW/2qbExE+W35Sal9eMzMI6P3hYfAvw59+O8XsQOlVqHrHn99h
X-Received: by 2002:ac8:2847:: with SMTP id 7mr32004874qtr.335.1550771052149;
        Thu, 21 Feb 2019 09:44:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550771052; cv=none;
        d=google.com; s=arc-20160816;
        b=VEWwYiHt1fNS7Zm/WlKnYrdOmFu6kXuCT7YpPGV7hxsUzXfRw9OJG+ACW7gEStoons
         TzgPP0etXrl00ibC1X/QJDwa1agmg46AZOSST7lVEnchygmatB37mOaPBvveGWwyN76W
         rdTycM8q/Qv+DlAc9Pw37hVd6tTgc2b6xgMhCCjJPS9/KpuTHIdIvrgExqQxCIqBBcsV
         E9G/REAfiCNCFs6nyNcsfzlsw9SPknLQzTwFbiqrfH5rmu9mGcd+TBaUsvxvVj/IH5d/
         bJfsAXzzsQqksCV7Q0Dm0z5SvZMs+sDUkOEQsYCBJBJy6dRbgkuKxsC34nS0ZlPp6YJ5
         QlHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=VdrN4SIXWmBsI5Gz1BYGZaPEEBNaaKsPo9zDWJvUxg4=;
        b=G0Lf//em0onwzVesLLuELxVjq8fAKWFDBvoEEFaxu2UguNZnTodXtXj2HY4s2MLJWT
         +USJr/1m+zTu01JOXVOpOTvEb0diuNMCFhERUPccisjbpU4EtkPUCoktmf3FLjqlS9Iq
         eq2/CSloeJAftp7OuNUHvroCEzJ5/oTflA9VOBc1u35OgLha1u1DEY7sB0QOK/hG6djd
         U4hG14FOhsQikACeQHVlq4A2BZnxns3HwZmSvW0I4xdhQXHesCIiXZV89nIHMmmmXyRo
         kvJMiG17z5Ok9jC8RWFJKPqGiDAGvHwMNxdcefisWi8fCJwvKfRnTuFvdfWq/sRd48uy
         oIKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r48si10090178qtr.9.2019.02.21.09.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:44:12 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F7CC4E341;
	Thu, 21 Feb 2019 17:44:11 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 55BE619C58;
	Thu, 21 Feb 2019 17:44:03 +0000 (UTC)
Date: Thu, 21 Feb 2019 12:44:02 -0500
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
Message-ID: <20190221174401.GL2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-13-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-13-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 21 Feb 2019 17:44:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:18AM +0800, Peter Xu wrote:
> Firstly, introduce two new flags MM_CP_UFFD_WP[_RESOLVE] for
> change_protection() when used with uffd-wp and make sure the two new
> flags are exclusively used.  Then,
> 
>   - For MM_CP_UFFD_WP: apply the _PAGE_UFFD_WP bit and remove _PAGE_RW
>     when a range of memory is write protected by uffd
> 
>   - For MM_CP_UFFD_WP_RESOLVE: remove the _PAGE_UFFD_WP bit and recover
>     _PAGE_RW when write protection is resolved from userspace
> 
> And use this new interface in mwriteprotect_range() to replace the old
> MM_CP_DIRTY_ACCT.
> 
> Do this change for both PTEs and huge PMDs.  Then we can start to
> identify which PTE/PMD is write protected by general (e.g., COW or soft
> dirty tracking), and which is for userfaultfd-wp.
> 
> Since we should keep the _PAGE_UFFD_WP when doing pte_modify(), add it
> into _PAGE_CHG_MASK as well.  Meanwhile, since we have this new bit, we
> can be even more strict when detecting uffd-wp page faults in either
> do_wp_page() or wp_huge_pmd().
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Few comments but still:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  arch/x86/include/asm/pgtable_types.h |  2 +-
>  include/linux/mm.h                   |  5 +++++
>  mm/huge_memory.c                     | 14 +++++++++++++-
>  mm/memory.c                          |  4 ++--
>  mm/mprotect.c                        | 12 ++++++++++++
>  mm/userfaultfd.c                     |  8 ++++++--
>  6 files changed, 39 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 8cebcff91e57..dd9c6295d610 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -133,7 +133,7 @@
>   */
>  #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
> -			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP)
> +			 _PAGE_SOFT_DIRTY | _PAGE_DEVMAP | _PAGE_UFFD_WP)
>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)

This chunk needs to be in the earlier arch specific patch.

[...]

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 8d65b0f041f9..817335b443c2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c

[...]

> @@ -2198,6 +2208,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  				entry = pte_mkold(entry);
>  			if (soft_dirty)
>  				entry = pte_mksoft_dirty(entry);
> +			if (uffd_wp)
> +				entry = pte_mkuffd_wp(entry);
>  		}
>  		pte = pte_offset_map(&_pmd, addr);
>  		BUG_ON(!pte_none(*pte));

Reading that code and i thought i would be nice if we could define a
pte_mask that we can or instead of all those if () entry |= ... but
that is just some dumb optimization and does not have any bearing on
the present patch. Just wanted to say that outloud.


> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index a6ba448c8565..9d4433044c21 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -46,6 +46,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	int target_node = NUMA_NO_NODE;
>  	bool dirty_accountable = cp_flags & MM_CP_DIRTY_ACCT;
>  	bool prot_numa = cp_flags & MM_CP_PROT_NUMA;
> +	bool uffd_wp = cp_flags & MM_CP_UFFD_WP;
> +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
>  
>  	/*
>  	 * Can be called with only the mmap_sem for reading by
> @@ -117,6 +119,14 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (preserve_write)
>  				ptent = pte_mk_savedwrite(ptent);
>  
> +			if (uffd_wp) {
> +				ptent = pte_wrprotect(ptent);
> +				ptent = pte_mkuffd_wp(ptent);
> +			} else if (uffd_wp_resolve) {
> +				ptent = pte_mkwrite(ptent);
> +				ptent = pte_clear_uffd_wp(ptent);
> +			}
> +
>  			/* Avoid taking write faults for known dirty pages */
>  			if (dirty_accountable && pte_dirty(ptent) &&
>  					(pte_soft_dirty(ptent) ||
> @@ -301,6 +311,8 @@ unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  {
>  	unsigned long pages;
>  
> +	BUG_ON((cp_flags & MM_CP_UFFD_WP_ALL) == MM_CP_UFFD_WP_ALL);

Don't you want to abort and return here if both flags are set ?

[...]

