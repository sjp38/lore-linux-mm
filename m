Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88B362806F4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:23:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b8so92382502pgn.10
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:23:53 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g1si10022408pld.694.2017.08.22.10.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 10:23:51 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Tue, 22 Aug 2017 17:23:47 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>, 'Linus Torvalds' <torvalds@linux-foundation.org>
Cc: 'Mel Gorman' <mgorman@suse.de>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Tim Chen' <tim.c.chen@linux.intel.com>, 'Peter Zijlstra' <peterz@infradead.org>, 'Ingo Molnar' <mingo@elte.hu>, 'Andi Kleen' <ak@linux.intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jan Kara' <jack@suse.cz>, 'linux-mm' <linux-mm@kvack.org>, 'Linux Kernel Mailing List' <linux-kernel@vger.kernel.org>


> > Covering both paths would be something like the patch below which
> > spins until the page is unlocked or it should reschedule. It's not
> > even boot tested as I spent what time I had on the test case that I
> > hoped would be able to prove it really works.
>=20
> I will give it a try.

Although the patch doesn't trigger watchdog, the spin lock wait time
is not small (0.45s).
It may get worse again on larger systems.


Irqsoff ftrace result.
# tracer: irqsoff
#
# irqsoff latency trace v1.1.5 on 4.13.0-rc4+
# --------------------------------------------------------------------
# latency: 451753 us, #4/4, CPU#159 | (M:desktop VP:0, KP:0, SP:0 HP:0 #P:2=
24)
#    -----------------
#    | task: fjsctest-233851 (uid:0 nice:0 policy:0 rt_prio:0)
#    -----------------
#  =3D> started at: wake_up_page_bit
#  =3D> ended at:   wake_up_page_bit
#
#
#                  _------=3D> CPU#           =20
#                 / _-----=3D> irqs-off       =20
#                | / _----=3D> need-resched   =20
#                || / _---=3D> hardirq/softirq=20
#                ||| / _--=3D> preempt-depth  =20
#                |||| /     delay           =20
#  cmd     pid   ||||| time  |   caller     =20
#     \   /      |||||  \    |   /        =20
   <...>-233851 159d...    0us@: _raw_spin_lock_irqsave <-wake_up_page_bit
   <...>-233851 159dN.. 451726us+: _raw_spin_unlock_irqrestore <-wake_up_pa=
ge_bit
   <...>-233851 159dN.. 451754us!: trace_hardirqs_on <-wake_up_page_bit
   <...>-233851 159dN.. 451873us : <stack trace>
 =3D> unlock_page
 =3D> migrate_pages
 =3D> migrate_misplaced_page
 =3D> __handle_mm_fault
 =3D> handle_mm_fault
 =3D> __do_page_fault
 =3D> do_page_fault
 =3D> page_fault


The call stack of wait_on_page_bit_common

   100.00%  (ffffffff971b252b)
            |
            ---__spinwait_on_page_locked
               |         =20
               |--96.81%--__migration_entry_wait
               |          migration_entry_wait
               |          do_swap_page
               |          __handle_mm_fault
               |          handle_mm_fault
               |          __do_page_fault
               |          do_page_fault
               |          page_fault
               |          |         =20
               |          |--22.49%--0x123a2
               |          |          |         =20
               |          |           --22.34%--start_thread
               |          |         =20
               |          |--15.69%--0x127bc
               |          |          |         =20
               |          |           --13.20%--start_thread
               |          |         =20
               |          |--13.48%--0x12352
               |          |          |         =20
               |          |           --11.74%--start_thread
               |          |         =20
               |          |--13.43%--0x127f2
               |          |          |         =20
               |          |           --11.25%--start_thread
               |          |         =20
               |          |--10.03%--0x1285e
               |          |          |         =20
               |          |           --8.59%--start_thread
               |          |         =20
               |          |--5.90%--0x12894
               |          |          |         =20
               |          |           --5.03%--start_thread
               |          |         =20
               |          |--5.66%--0x12828
               |          |          |         =20
               |          |           --4.81%--start_thread
               |          |         =20
               |          |--5.17%--0x1233c
               |          |          |         =20
               |          |           --4.46%--start_thread
               |          |         =20
               |           --4.72%--0x2b788
               |                     |         =20
               |                      --4.72%--0x127a2
               |                                start_thread
               |         =20
                --3.19%--do_huge_pmd_numa_page
                          __handle_mm_fault
                          handle_mm_fault
                          __do_page_fault
                          do_page_fault
                          page_fault
                          0x2b788
                          0x127a2
                          start_thread


>=20
> >
> > diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h index
> > 79b36f57c3ba..31cda1288176 100644
> > --- a/include/linux/pagemap.h
> > +++ b/include/linux/pagemap.h
> > @@ -517,6 +517,13 @@ static inline void wait_on_page_locked(struct
> > page
> > *page)
> >  		wait_on_page_bit(compound_head(page), PG_locked);  }
> >
> > +void __spinwait_on_page_locked(struct page *page); static inline void
> > +spinwait_on_page_locked(struct page *page) {
> > +	if (PageLocked(page))
> > +		__spinwait_on_page_locked(page);
> > +}
> > +
> >  static inline int wait_on_page_locked_killable(struct page *page)  {
> >  	if (!PageLocked(page))
> > diff --git a/mm/filemap.c b/mm/filemap.c index
> > a49702445ce0..c9d6f49614bc 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1210,6 +1210,15 @@ int __lock_page_or_retry(struct page *page,
> > struct mm_struct *mm,
> >  	}
> >  }
> >
> > +void __spinwait_on_page_locked(struct page *page) {
> > +	do {
> > +		cpu_relax();
> > +	} while (PageLocked(page) && !cond_resched());
> > +
> > +	wait_on_page_locked(page);
> > +}
> > +
> >  /**
> >   * page_cache_next_hole - find the next hole (not-present entry)
> >   * @mapping: mapping
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c index
> > 90731e3b7e58..c7025c806420 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1443,7 +1443,7 @@ int do_huge_pmd_numa_page(struct vm_fault
> *vmf,
> > pmd_t pmd)
> >  		if (!get_page_unless_zero(page))
> >  			goto out_unlock;
> >  		spin_unlock(vmf->ptl);
> > -		wait_on_page_locked(page);
> > +		spinwait_on_page_locked(page);
> >  		put_page(page);
> >  		goto out;
> >  	}
> > @@ -1480,7 +1480,7 @@ int do_huge_pmd_numa_page(struct vm_fault
> *vmf,
> > pmd_t pmd)
> >  		if (!get_page_unless_zero(page))
> >  			goto out_unlock;
> >  		spin_unlock(vmf->ptl);
> > -		wait_on_page_locked(page);
> > +		spinwait_on_page_locked(page);
> >  		put_page(page);
> >  		goto out;
> >  	}
> > diff --git a/mm/migrate.c b/mm/migrate.c index
> > e84eeb4e4356..9b6c3fc5beac 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -308,7 +308,7 @@ void __migration_entry_wait(struct mm_struct
> *mm,
> > pte_t *ptep,
> >  	if (!get_page_unless_zero(page))
> >  		goto out;
> >  	pte_unmap_unlock(ptep, ptl);
> > -	wait_on_page_locked(page);
> > +	spinwait_on_page_locked(page);
> >  	put_page(page);
> >  	return;
> >  out:
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
