Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79B306B46F1
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 12:06:07 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w142-v6so1688587qkw.8
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 09:06:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k1-v6si1448618qkc.104.2018.08.28.09.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 09:06:06 -0700 (PDT)
Date: Tue, 28 Aug 2018 12:06:03 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828160602.GB4029@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
 <20180828152414.GQ10223@dhcp22.suse.cz>
 <20180828153658.GA4029@redhat.com>
 <20180828154206.GR10223@dhcp22.suse.cz>
 <20180828154555.GS10223@dhcp22.suse.cz>
 <44C89854-FE83-492F-B6BB-CF54B77233CF@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <44C89854-FE83-492F-B6BB-CF54B77233CF@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Tue, Aug 28, 2018 at 11:54:33AM -0400, Zi Yan wrote:
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
> 

Well looking back at code is_migration_entry() will return false on arch
which do not have thp migration because pmd_to_swp_entry() will return
swp_entry(0,0) which is can not be a valid migration entry.

Maybe using is_pmd_migration_entry() would be better here ? It seems
that is_pmd_migration_entry() is more common then the open coded
thp_migration_supported() && is_migration_entry()

Cheers,
Jerome
