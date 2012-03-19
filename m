Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A95D76B00EA
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 14:42:07 -0400 (EDT)
Message-ID: <1332182502.18960.371.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 19:41:42 +0100
In-Reply-To: <20120319143442.GR24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	 <20120319130401.GI24602@redhat.com> <1332163591.18960.334.camel@twins>
	 <20120319135745.GL24602@redhat.com> <1332166079.18960.342.camel@twins>
	 <20120319143442.GR24602@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 15:34 +0100, Andrea Arcangeli wrote:
> On Mon, Mar 19, 2012 at 03:07:59PM +0100, Peter Zijlstra wrote:
> > And no, I really don't think giving up 0.5% of RAM is acceptable.
>=20
> Fine it's up to you :).
>=20
> Also note 16 bytes of those 24 bytes, you need to spend them too if
> you remotely hope to perform as good as AutoNUMA (I can already tell
> you...), they've absolutely nothing to do with the background scanning
> that AutoNUMA does to avoid modifying the apps.

Going by that size it can only be the list head and you use that for
enqueueing the page on target node lists for page-migration. The thing
is, since you work on page granular objects you have to have this
information per-page. I work on vma objects and can do with this
information per vma.

It would be ever so much more helpful if, instead of talking in clues
and riddles you just say what you mean. Also, try and say it without
writing a book. I still haven't completely read your first email of
today (and probably never will -- its just too big).

> The blame on autonuma you can give is 8 bytes per page only, so 0.07%,
> which I can probably reduce 0.03% if I screw the natural alignment of
> the list pointers and MAX_NUMNODES is < 32768 at build time, not sure
> if it's worth it.

Well, no, I can blame the entire size increase on auto-numa. I don't
need to enqueue individual pages to a target node, I simply unmap
everything that's on the wrong node and the migrate-on-fault stuff will
compute the target node based on the vma information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
