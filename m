Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D98EA6B4542
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 12:10:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t23-v6so1177752pfe.20
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 09:10:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u64-v6si1375605pgu.533.2018.08.28.09.10.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 09:10:47 -0700 (PDT)
Date: Tue, 28 Aug 2018 18:10:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828161043.GT10223@dhcp22.suse.cz>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
 <20180828152414.GQ10223@dhcp22.suse.cz>
 <20180828153658.GA4029@redhat.com>
 <20180828154206.GR10223@dhcp22.suse.cz>
 <20180828154555.GS10223@dhcp22.suse.cz>
 <44C89854-FE83-492F-B6BB-CF54B77233CF@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44C89854-FE83-492F-B6BB-CF54B77233CF@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Tue 28-08-18 11:54:33, Zi Yan wrote:
> Hi Michal,
> 
> On 28 Aug 2018, at 11:45, Michal Hocko wrote:
> 
> > On Tue 28-08-18 17:42:06, Michal Hocko wrote:
> >> On Tue 28-08-18 11:36:59, Jerome Glisse wrote:
> >>> On Tue, Aug 28, 2018 at 05:24:14PM +0200, Michal Hocko wrote:
> >>>> On Fri 24-08-18 20:05:46, Zi Yan wrote:
> >>>> [...]
> >>>>>> +	if (!pmd_present(pmd)) {
> >>>>>> +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> >>>>>> +
> >>>>>> +		if (is_migration_entry(entry)) {
> >>>>>
> >>>>> I think you should check thp_migration_supported() here, since PMD migration is only enabled in x86_64 systems.
> >>>>> Other architectures should treat PMD migration entries as bad.
> >>>>
> >>>> How can we have a migration pmd entry when the migration is not
> >>>> supported?
> >>>
> >>> Not sure i follow here, migration can happen anywhere (assuming
> >>> that something like compaction is active or numa or ...). So this
> >>> code can face pmd migration entry on architecture that support
> >>> it. What is missing here is thp_migration_supported() call to
> >>> protect the is_migration_entry() to avoid false positive on arch
> >>> which do not support thp migration.
> >>
> >> I mean that architectures which do not support THP migration shouldn't
> >> ever see any migration entry. So is_migration_entry should be always
> >> false. Or do I miss something?
> >
> > And just to be clear. thp_migration_supported should be checked only
> > when we actually _do_ the migration or evaluate migratability of the
> > page. We definitely do want to sprinkle this check to all places where
> > is_migration_entry is checked.
> 
> is_migration_entry() is a general check for swp_entry_t, so it can return
> true even if THP migration is not enabled. is_pmd_migration_entry() always
> returns false when THP migration is not enabled.
> 
> So the code can be changed in two ways, either replacing is_migration_entry()
> with is_pmd_migration_entry() or adding thp_migration_supported() check
> like Jerome did.
> 
> Does this clarify your question?

Not really. IIUC the code checks for the pmd. So even though
is_migration_entry is a more generic check it should never return true
for thp_migration_supported() == F because we simply never have those
unless I am missing something.

is_pmd_migration_entry is much more readable of course and I suspect it
can save few cycles as well.
-- 
Michal Hocko
SUSE Labs
