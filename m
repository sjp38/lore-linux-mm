Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 030566B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:50:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so4510630wrb.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:50:17 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id b2si3423343wra.295.2017.03.24.09.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 09:50:16 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id l43so5498667wre.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 09:50:16 -0700 (PDT)
Date: Fri, 24 Mar 2017 19:50:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 06/11] mm: thp: check pmd migration entry in common
 path
Message-ID: <20170324165014.2ibdmurirjd4pa7r@node.shutemov.name>
References: <20170313154507.3647-1-zi.yan@sent.com>
 <20170313154507.3647-7-zi.yan@sent.com>
 <20170324145042.bda52glerop5wydx@node.shutemov.name>
 <58D544B5.20102@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58D544B5.20102@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, dnellans@nvidia.com

On Fri, Mar 24, 2017 at 11:09:25AM -0500, Zi Yan wrote:
> Kirill A. Shutemov wrote:
> > On Mon, Mar 13, 2017 at 11:45:02AM -0400, Zi Yan wrote:
> > Again. That's doesn't look right..
> 
> It will be changed:
> 
>  	ptl = pmd_lock(mm, pmd);
> +retry_locked:
> +	if (unlikely(!pmd_present(*pmd))) {
> +		if (likely(!(flags & FOLL_MIGRATION))) {
> +			spin_unlock(ptl);
> +			return no_page_table(vma, flags);
> +		}
> +		pmd_migration_entry_wait(mm, pmd);
> +		goto retry_locked;

Nope. pmd_migration_entry_wait() unlocks the ptl.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
