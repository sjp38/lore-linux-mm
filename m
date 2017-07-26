Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 113646B0313
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 08:34:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e204so7343272wma.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 05:34:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si13463901wrh.288.2017.07.26.05.34.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 05:34:00 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:33:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/hugetlb: Make huge_pte_offset() consistent and
 document behaviour
Message-ID: <20170726123357.GP2981@dhcp22.suse.cz>
References: <20170725154114.24131-1-punit.agrawal@arm.com>
 <20170725154114.24131-2-punit.agrawal@arm.com>
 <20170726085038.GB2981@dhcp22.suse.cz>
 <20170726085325.GC2981@dhcp22.suse.cz>
 <87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87bmo7jt31.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, steve.capper@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, kirill.shutemov@linux.intel.com, Mike Kravetz <mike.kravetz@oracle.com>

On Wed 26-07-17 13:11:46, Punit Agrawal wrote:
> Hi Michal,
> 
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Wed 26-07-17 10:50:38, Michal Hocko wrote:
> >> On Tue 25-07-17 16:41:14, Punit Agrawal wrote:
> >> > When walking the page tables to resolve an address that points to
> >> > !p*d_present() entry, huge_pte_offset() returns inconsistent values
> >> > depending on the level of page table (PUD or PMD).
> >> > 
> >> > It returns NULL in the case of a PUD entry while in the case of a PMD
> >> > entry, it returns a pointer to the page table entry.
> >> > 
> >> > A similar inconsitency exists when handling swap entries - returns NULL
> >> > for a PUD entry while a pointer to the pte_t is retured for the PMD
> >> > entry.
> >> > 
> >> > Update huge_pte_offset() to make the behaviour consistent - return NULL
> >> > in the case of p*d_none() and a pointer to the pte_t for hugepage or
> >> > swap entries.
> >> > 
> >> > Document the behaviour to clarify the expected behaviour of this
> >> > function. This is to set clear semantics for architecture specific
> >> > implementations of huge_pte_offset().
> >> 
> >> hugetlb pte semantic is a disaster and I agree it could see some
> >> cleanup/clarifications but I am quite nervous to see a patchi like this.
> >> How do we check that nothing will get silently broken by this change?
> 
> Glad I'm not the only one who finds the hugetlb semantics somewhat
> confusing. :)

This is a huge understatement. It is a source of nightmares.

> I've been running tests from mce-test suite and libhugetlbfs for similar
> changes we did on arm64. There could be assumptions that were not
> exercised but I'm not sure how to check for all the possible usages.
> 
> Do you have any other suggestions that can help improve confidence in
> the patch?

Unfortunatelly I don't. I just know there were many subtle assumptions
all over the place so I am rather careful to not touch the code unless
really necessary.

That being said, I am not opposing your patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
