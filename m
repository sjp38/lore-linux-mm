Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 64A8F6B45CB
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 11:42:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t4-v6so819205plo.0
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 08:42:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o9-v6si1434678pgf.331.2018.08.28.08.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 08:42:16 -0700 (PDT)
Date: Tue, 28 Aug 2018 17:42:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828154206.GR10223@dhcp22.suse.cz>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
 <20180828152414.GQ10223@dhcp22.suse.cz>
 <20180828153658.GA4029@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828153658.GA4029@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Tue 28-08-18 11:36:59, Jerome Glisse wrote:
> On Tue, Aug 28, 2018 at 05:24:14PM +0200, Michal Hocko wrote:
> > On Fri 24-08-18 20:05:46, Zi Yan wrote:
> > [...]
> > > > +	if (!pmd_present(pmd)) {
> > > > +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> > > > +
> > > > +		if (is_migration_entry(entry)) {
> > > 
> > > I think you should check thp_migration_supported() here, since PMD migration is only enabled in x86_64 systems.
> > > Other architectures should treat PMD migration entries as bad.
> > 
> > How can we have a migration pmd entry when the migration is not
> > supported?
> 
> Not sure i follow here, migration can happen anywhere (assuming
> that something like compaction is active or numa or ...). So this
> code can face pmd migration entry on architecture that support
> it. What is missing here is thp_migration_supported() call to
> protect the is_migration_entry() to avoid false positive on arch
> which do not support thp migration.

I mean that architectures which do not support THP migration shouldn't
ever see any migration entry. So is_migration_entry should be always
false. Or do I miss something?
-- 
Michal Hocko
SUSE Labs
