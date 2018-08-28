Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14EB36B456C
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 11:37:03 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k21-v6so1634434qtj.23
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 08:37:03 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c126-v6si1333581qke.99.2018.08.28.08.37.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 08:37:02 -0700 (PDT)
Date: Tue, 28 Aug 2018 11:36:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 4/7] mm/hmm: properly handle migration pmd
Message-ID: <20180828153658.GA4029@redhat.com>
References: <20180824192549.30844-1-jglisse@redhat.com>
 <20180824192549.30844-5-jglisse@redhat.com>
 <0560A126-680A-4BAE-8303-F1AB34BE4BA5@cs.rutgers.edu>
 <20180828152414.GQ10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180828152414.GQ10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Tue, Aug 28, 2018 at 05:24:14PM +0200, Michal Hocko wrote:
> On Fri 24-08-18 20:05:46, Zi Yan wrote:
> [...]
> > > +	if (!pmd_present(pmd)) {
> > > +		swp_entry_t entry = pmd_to_swp_entry(pmd);
> > > +
> > > +		if (is_migration_entry(entry)) {
> > 
> > I think you should check thp_migration_supported() here, since PMD migration is only enabled in x86_64 systems.
> > Other architectures should treat PMD migration entries as bad.
> 
> How can we have a migration pmd entry when the migration is not
> supported?

Not sure i follow here, migration can happen anywhere (assuming
that something like compaction is active or numa or ...). So this
code can face pmd migration entry on architecture that support
it. What is missing here is thp_migration_supported() call to
protect the is_migration_entry() to avoid false positive on arch
which do not support thp migration.

Cheers,
Jerome
