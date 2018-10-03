Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 885F86B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:48:47 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x24-v6so3100615edm.13
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:48:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h33-v6si971166edb.423.2018.10.03.04.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 04:48:46 -0700 (PDT)
Date: Wed, 3 Oct 2018 13:48:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/hugetlb: Enable PUD level huge page migration
Message-ID: <20181003114842.GD4714@dhcp22.suse.cz>
References: <1538482531-26883-1-git-send-email-anshuman.khandual@arm.com>
 <1538482531-26883-2-git-send-email-anshuman.khandual@arm.com>
 <20181002123909.GS18290@dhcp22.suse.cz>
 <fae68a4e-b14b-8342-940c-ea5ef3c978af@arm.com>
 <20181003065833.GD18290@dhcp22.suse.cz>
 <7f0488b5-053f-0954-9b95-8c0890ef5597@arm.com>
 <20181003105926.GA4714@dhcp22.suse.cz>
 <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34b25855-fcef-61ed-312d-2011f80bdec4@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, suzuki.poulose@arm.com, punit.agrawal@arm.com, will.deacon@arm.com, Steven.Price@arm.com, catalin.marinas@arm.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com

On Wed 03-10-18 17:07:13, Anshuman Khandual wrote:
> 
> 
> On 10/03/2018 04:29 PM, Michal Hocko wrote:
[...]
> > It is not the platform that decides. That is the whole point of the
> > distinction. It is us to say what is feasible and what we want to
> > support. Do we want to support giga pages in zone_movable? Under which
> > conditions? See my point?
> 
> So huge_movable() is going to be a generic MM function deciding on the
> feasibility for allocating a huge page of 'size' from movable zone during
> migration.

Yeah, this might be a more complex logic than just the size check. If
there is a sufficient pre-allocated pool to migrate the page off it
might be pre-reserved for future migration etc... Nothing to be done
right now of course.

> If the feasibility turns out to be negative, then migration
> process is aborted there.

You are still confusing allocation and migration here I am afraid. The
whole "feasible to migrate" is for the _allocation_ time when we decide
whether the new page should be placed in zone_movable or not.

> huge_movable() will do something like these:
> 
> - Return positive right away on smaller size huge pages
> - Measure movable allocation feasibility for bigger huge pages
> 	- Look out for free_pages in the huge page order in movable areas
> 	- if (order > (MAX_ORDER - 1))
> 		- Scan the PFN ranges in movable zone for possible allocation
> 	- etc
> 	- etc
> 
> Did I get this right ?

Well, not really. I was thinking of something like this for the
beginning
	if (!arch_hugepage_migration_supporte())
		return false;
	if (hstate_is_gigantic(h))
		return false;
	return true;

further changes might be done on top of this.
-- 
Michal Hocko
SUSE Labs
