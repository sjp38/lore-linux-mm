Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5636B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 10:20:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t80so173958991pgb.0
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 07:20:44 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a7si3607190pgd.387.2017.08.18.07.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 07:20:43 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Fri, 18 Aug 2017 14:20:38 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07753786CE9@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
In-Reply-To: <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi
 Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



> On Thu, Aug 17, 2017 at 01:44:40PM -0700, Linus Torvalds wrote:
> > On Thu, Aug 17, 2017 at 1:18 PM, Liang, Kan <kan.liang@intel.com> wrote=
:
> > >
> > > Here is the call stack of wait_on_page_bit_common when the queue is
> > > long (entries >1000).
> > >
> > > # Overhead  Trace output
> > > # ........  ..................
> > > #
> > >    100.00%  (ffffffff931aefca)
> > >             |
> > >             ---wait_on_page_bit
> > >                __migration_entry_wait
> > >                migration_entry_wait
> > >                do_swap_page
> > >                __handle_mm_fault
> > >                handle_mm_fault
> > >                __do_page_fault
> > >                do_page_fault
> > >                page_fault
> >
> > Hmm. Ok, so it does seem to very much be related to migration. Your
> > wake_up_page_bit() profile made me suspect that, but this one seems to
> > pretty much confirm it.
> >
> > So it looks like that wait_on_page_locked() thing in
> > __migration_entry_wait(), and what probably happens is that your load
> > ends up triggering a lot of migration (or just migration of a very hot
> > page), and then *every* thread ends up waiting for whatever page that
> > ended up getting migrated.
> >
>=20
> Agreed.
>=20
> > And so the wait queue for that page grows hugely long.
> >
>=20
> It's basically only bounded by the maximum number of threads that can exi=
st.
>=20
> > Looking at the other profile, the thing that is locking the page (that
> > everybody then ends up waiting on) would seem to be
> > migrate_misplaced_transhuge_page(), so this is _presumably_ due to
> > NUMA balancing.
> >
>=20
> Yes, migrate_misplaced_transhuge_page requires NUMA balancing to be
> part of the picture.
>=20
> > Does the problem go away if you disable the NUMA balancing code?
> >
> > Adding Mel and Kirill to the participants, just to make them aware of
> > the issue, and just because their names show up when I look at blame.
> >
>=20
> I'm not imagining a way of dealing with this that would reliably detect w=
hen
> there are a large number of waiters without adding a mess. We could adjus=
t
> the scanning rate to reduce the problem but it would be difficult to targ=
et
> properly and wouldn't prevent the problem occurring with the added hassle
> that it would now be intermittent.
>=20
> Assuming the problem goes away by disabling NUMA then it would be nice if
> it could be determined that the page lock holder is trying to allocate a =
page
> when the queue is huge. That is part of the operation that potentially ta=
kes a
> long time and may be why so many callers are stacking up. If so, I would
> suggest clearing __GFP_DIRECT_RECLAIM from the GFP flags in
> migrate_misplaced_transhuge_page and assume that a remote hit is always
> going to be cheaper than compacting memory to successfully allocate a THP=
.
> That may be worth doing unconditionally because we'd have to save a
> *lot* of remote misses to offset compaction cost.
>=20
> Nothing fancy other than needing a comment if it works.
>=20

No, the patch doesn't work.

Thanks,
Kan

> diff --git a/mm/migrate.c b/mm/migrate.c index
> 627671551873..87b0275ddcdb 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1926,7 +1926,7 @@ int migrate_misplaced_transhuge_page(struct
> mm_struct *mm,
>  		goto out_dropref;
>=20
>  	new_page =3D alloc_pages_node(node,
> -		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
> +		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE) &
> ~__GFP_DIRECT_RECLAIM,
>  		HPAGE_PMD_ORDER);
>  	if (!new_page)
>  		goto out_fail;
>=20
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
