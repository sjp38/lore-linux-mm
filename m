Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 0FDC26B0062
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:44:36 -0400 (EDT)
Message-ID: <1338309855.26856.130.camel@twins>
Subject: Re: [PATCH 35/35] autonuma: page_autonuma
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 18:44:15 +0200
In-Reply-To: <1337965359-29725-36-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-36-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> Move the AutoNUMA per page information from the "struct page" to a
> separate page_autonuma data structure allocated in the memsection
> (with sparsemem) or in the pgdat (with flatmem).
>=20
> This is done to avoid growing the size of the "struct page" and the
> page_autonuma data is only allocated if the kernel has been booted on
> real NUMA hardware (or if noautonuma is passed as parameter to the
> kernel).
>=20

Argh, please fold this change back into the series proper. If you want
to keep it.. as it is its not really an improvement IMO, see below.

> +struct page_autonuma {
> +       /*
> +        * FIXME: move to pgdat section along with the memcg and allocate
> +        * at runtime only in presence of a numa system.
> +        */
> +       /*
> +        * To modify autonuma_last_nid lockless the architecture,
> +        * needs SMP atomic granularity < sizeof(long), not all archs
> +        * have that, notably some alpha. Archs without that requires
> +        * autonuma_last_nid to be a long.
> +        */

Looking at arch/alpha/include/asm/xchg.h it looks to have that just
fine, so maybe we simply don't support SMP on those early Alphas that
had that weirdness.

> +#if BITS_PER_LONG > 32
> +       int autonuma_migrate_nid;
> +       int autonuma_last_nid;
> +#else
> +#if MAX_NUMNODES >=3D 32768
> +#error "too many nodes"
> +#endif
> +       /* FIXME: remember to check the updates are atomic */
> +       short autonuma_migrate_nid;
> +       short autonuma_last_nid;
> +#endif
> +       struct list_head autonuma_migrate_node;
> +
> +       /*
> +        * To find the page starting from the autonuma_migrate_node we
> +        * need a backlink.
> +        */
> +       struct page *page;
> +};=20

This makes a shadow page frame of 32 bytes per page, or ~0.8% of memory.
This isn't in fact an improvement.

The suggestion done by Rik was to have something like a sqrt(nr_pages)
(?) scaled array of such things containing the list_head and page
pointer -- and leave the two nids in the regular page frame. Although I
think you've got to fight the memcg people over that last word in struct
page.

That places a limit on the amount of pages that can be in migration
concurrently, but also greatly reduces the memory overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
