Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 346966B016D
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:53:49 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p7J7rjBb032381
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:53:46 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by wpaz5.hot.corp.google.com with ESMTP id p7J7riOu010242
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:53:44 -0700
Received: by qwj8 with SMTP id 8so2432118qwj.32
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:53:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Date: Fri, 19 Aug 2011 00:53:43 -0700
Message-ID: <CANN689GV25iM9Gv1QQierpRg7nH5TBr+sRdLop2cg1MoHnnxow@mail.gmail.com>
Subject: Re: [PATCH 0/9] Use RCU to stabilize page counts
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

Adding Paul - I meant to have him in the original email, but git
send-email filtered him out because I forgot to add <> around his
email. DOH!

On Fri, Aug 19, 2011 at 12:48 AM, Michel Lespinasse <walken@google.com> wro=
te:
> include/linux/pagemap.h describes the protocol one should use to get page=
s
> from page cache - one can't know if the reference they get will be on the
> desired page, so newly allocated pages might see elevated reference count=
s,
> but using RCU this effect can be limited in time to one RCU grace period.
>
> For this protocol to work, every call site of get_page_unless_zero() has =
to
> participate, and this was not previously enforced.
>
> Patches 1-3 convert some get_page_unless_zero() call sites to use the pro=
per
> RCU protocol as described in pagemap.h
>
> Patches 4-5 convert some get_page_unless_zero() call sites to just call
> get_page()
>
> Patch 6 asserts that every remaining get_page_unless_zero() call site sho=
uld
> participate in the RCU protocol. Well, not actually all of them -
> __isolate_rcu_page() is exempted because it holds the zone LRU lock which
> would prevent the given page from getting entirely freed, and a few other=
s
> related to hwpoison, memory hotplug and memory failure are exempted becau=
se
> I haven't been able to figure out what to do.
>
> Patch 7 is a placeholder for an RCU API extension we have been talking ab=
out
> with Paul McKenney. The idea is to record an initial time as an opaque co=
okie,
> and to be able to determine later on if an rcu grace period has elapsed s=
ince
> that initial time.
>
> Patch 8 adds wrapper functions to store an RCU cookie into compound pages=
.
>
> Patch 9 makes use of new RCU API, as well as the prior fixes from patches=
 1-6,
> to ensure tail page counts are stable while we split THP pages. This fixe=
s a
> (rather theorical, not actually been observed) race condition where THP p=
age
> splitting could result in incorrect page counts if THP page allocation an=
d
> splitting both occur while another thread tries to run get_page_unless_ze=
ro
> on a single page that got re-allocated as THP tail page.
>
>
> The patches have received only a limited amount of testing; however I
> believe patches 1-6 to be sane and I would like them to get more
> exposure, maybe as part of andrew's -mm tree.
>
>
> Besides that, this proposal is also to sync up with Paul regarding the RC=
U
> functionality :)
>
>
> Michel Lespinasse (9):
> =A0mm: rcu read lock for getting reference on pages in
> =A0 =A0migration_entry_wait()
> =A0mm: avoid calling get_page_unless_zero() when charging cgroups
> =A0mm: rcu read lock when getting from tail to head page
> =A0mm: use get_page in deactivate_page()
> =A0kvm: use get_page instead of get_page_unless_zero
> =A0mm: assert that get_page_unless_zero() callers hold the rcu lock
> =A0rcu: rcu_get_gp_cookie() / rcu_gp_cookie_elapsed() stand-ins
> =A0mm: add API for setting a grace period cookie on compound pages
> =A0mm: make sure tail page counts are stable before splitting THP pages
>
> =A0arch/x86/kvm/mmu.c =A0 =A0 =A0 | =A0 =A03 +--
> =A0include/linux/mm.h =A0 =A0 =A0 | =A0 38 ++++++++++++++++++++++++++++++=
+++++++-
> =A0include/linux/mm_types.h | =A0 =A06 +++++-
> =A0include/linux/pagemap.h =A0| =A0 =A01 +
> =A0include/linux/rcupdate.h | =A0 35 +++++++++++++++++++++++++++++++++++
> =A0mm/huge_memory.c =A0 =A0 =A0 =A0 | =A0 33 ++++++++++++++++++++++++++++=
+----
> =A0mm/hwpoison-inject.c =A0 =A0 | =A0 =A02 +-
> =A0mm/ksm.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0| =A0 20 ++++++++++----------
> =A0mm/memory-failure.c =A0 =A0 =A0| =A0 =A06 +++---
> =A0mm/memory_hotplug.c =A0 =A0 =A0| =A0 =A02 +-
> =A0mm/migrate.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +++
> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0mm/swap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 22 ++++++++++++++------=
--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A07 ++++++-
> =A015 files changed, 151 insertions(+), 32 deletions(-)

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
