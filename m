Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7E4E66B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:16:38 -0400 (EDT)
Message-ID: <1338297385.26856.74.camel@twins>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 29 May 2012 15:16:25 +0200
In-Reply-To: <1337965359-29725-14-git-send-email-aarcange@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
	 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 780ded7..e8dc82c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -126,6 +126,31 @@ struct page {
>  		struct page *first_page;	/* Compound tail pages */
>  	};
> =20
> +#ifdef CONFIG_AUTONUMA
> +	/*
> +	 * FIXME: move to pgdat section along with the memcg and allocate
> +	 * at runtime only in presence of a numa system.
> +	 */
> +	/*
> +	 * To modify autonuma_last_nid lockless the architecture,
> +	 * needs SMP atomic granularity < sizeof(long), not all archs
> +	 * have that, notably some alpha. Archs without that requires
> +	 * autonuma_last_nid to be a long.
> +	 */
> +#if BITS_PER_LONG > 32
> +	int autonuma_migrate_nid;
> +	int autonuma_last_nid;
> +#else
> +#if MAX_NUMNODES >=3D 32768
> +#error "too many nodes"
> +#endif
> +	/* FIXME: remember to check the updates are atomic */
> +	short autonuma_migrate_nid;
> +	short autonuma_last_nid;
> +#endif
> +	struct list_head autonuma_migrate_node;
> +#endif
> +
>  	/*
>  	 * On machines where all RAM is mapped into kernel address space,
>  	 * we can simply calculate the virtual address. On machines with


24 bytes per page.. or ~0.6% of memory gone. This is far too great a
price to pay.

At LSF/MM Rik already suggested you limit the number of pages that can
be migrated concurrently and use this to move the extra list_head out of
struct page and into a smaller amount of extra structures, reducing the
total overhead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
