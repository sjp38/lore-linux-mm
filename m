Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 485D86B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:19:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m15so7196281qke.16
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:19:13 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a39si8968044qtb.187.2018.03.16.12.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:19:12 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:19:09 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/4] mm/hmm: change CPU page table snapshot functions to
 simplify drivers
Message-ID: <20180316191909.GA4861@redhat.com>
References: <20180315183700.3843-1-jglisse@redhat.com>
 <20180315183700.3843-5-jglisse@redhat.com>
 <cc1bfc05-9b06-1de8-7b14-ca1a6bc6496c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc1bfc05-9b06-1de8-7b14-ca1a6bc6496c@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On Thu, Mar 15, 2018 at 10:08:21PM -0700, John Hubbard wrote:
> On 03/15/2018 11:37 AM, jglisse@redhat.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > This change hmm_vma_fault() and hmm_vma_get_pfns() API to allow HMM
> > to directly write entry that can match any device page table entry
> > format. Device driver now provide an array of flags value and we use
> > enum to index this array for each flag.
> > 
> > This also allow the device driver to ask for write fault on a per page
> > basis making API more flexible to service multiple device page faults
> > in one go.
> > 
> 
> Hi Jerome,
> 
> This is a large patch, so I'm going to review it in two passes. The first 
> pass is just an overview plus the hmm.h changes (now), and tomorrow I will
> review the hmm.c, which is where the real changes are.
> 
> Overview: the hmm.c changes are doing several things, and it is difficult to
> review, because refactoring, plus new behavior, makes diffs less useful here.
> It would probably be good to split the hmm.c changes into a few patches, such
> as:
> 
> 	-- HMM_PFN_FLAG_* changes, plus function signature changes (mm_range* 
>            being passed to functions), and
>         -- New behavior in the page handling loops, and 
> 	-- Refactoring into new routines (hmm_vma_handle_pte, and others)
> 
> That way, reviewers can see more easily that things are correct. 

So i resent patchset and i splitted this patch in many (11 patches now).
I included your comments so far in the new version so probably better if
you look at new one.

[...[

> > - * HMM_PFN_READ:  CPU page table has read permission set
> 
> So why is it that we don't need the _READ flag anymore? I looked at the corresponding
> hmm.c but still don't quite get it. Is it that we just expect that _READ is
> always set if there is an entry at all? Or something else?

Explained why in the commit message, !READ when WRITE make no sense so
now VALID imply READ as does WRITE (write by itself is meaningless
without valid).

Cheers,
Jerome
