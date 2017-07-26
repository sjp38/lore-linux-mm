Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA6DF6B02F4
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:53:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v102so31074325wrb.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:53:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21si17585965wra.51.2017.07.26.01.53.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 01:53:29 -0700 (PDT)
Date: Wed, 26 Jul 2017 10:53:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and
 document behaviour
Message-ID: <20170726085325.GC2981@dhcp22.suse.cz>
References: <20170725154114.24131-1-punit.agrawal@arm.com>
 <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170726085038.GB2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726085038.GB2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 26-07-17 10:50:38, Michal Hocko wrote:
> On Tue 25-07-17 16:41:14, Punit Agrawal wrote:
> > When walking the page tables to resolve an address that points to
> > !p*d_present() entry, huge_pte_offset() returns inconsistent values
> > depending on the level of page table (PUD or PMD).
> > 
> > It returns NULL in the case of a PUD entry while in the case of a PMD
> > entry, it returns a pointer to the page table entry.
> > 
> > A similar inconsitency exists when handling swap entries - returns NULL
> > for a PUD entry while a pointer to the pte_t is retured for the PMD
> > entry.
> > 
> > Update huge_pte_offset() to make the behaviour consistent - return NULL
> > in the case of p*d_none() and a pointer to the pte_t for hugepage or
> > swap entries.
> > 
> > Document the behaviour to clarify the expected behaviour of this
> > function. This is to set clear semantics for architecture specific
> > implementations of huge_pte_offset().
> 
> hugetlb pte semantic is a disaster and I agree it could see some
> cleanup/clarifications but I am quite nervous to see a patchi like this.
> How do we check that nothing will get silently broken by this change?

Forgot to add. Hugetlb have been special because of the pte sharing. I
haven't looked into that code for quite some time but there might be a
good reason why pud behave differently.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
