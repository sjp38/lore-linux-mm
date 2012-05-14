Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 1F4416B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 02:56:27 -0400 (EDT)
Message-ID: <1336978573.2443.13.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 14 May 2012 08:56:13 +0200
In-Reply-To: <4FB0866D.4020203@kernel.org>
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>
	 <4FB0866D.4020203@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, 2012-05-14 at 13:13 +0900, Minchan Kim wrote:
> On 05/11/2012 06:20 PM, Peter Zijlstra wrote:
>=20
> > On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
> >> I hope hear opinion from rt guys, too.
> >=20
> > Its a problem yes, not sure your solution is any good though. As it
> > stands mlock() simply doesn't guarantee no faults, all it does is
> > guarantee no major faults.
>=20
>=20
> I can't find such definition from man pages
> "
>        Real-time  processes  that are using mlockall() to prevent delays =
on page faults should
>        reserve enough locked stack pages before entering the time-critica=
l section, so that no
>        page fault can be caused by function calls
> "
> So I didn't expect it. Is your definition popular available on server RT?
> At least, embedded guys didn't expect it.

Sod the manpage, the opengroup.org definition only states the page will
not be paged-out.

  http://pubs.opengroup.org/onlinepubs/009604599/functions/mlock.html

It only states: 'shall be memory resident' that very much implies no
major faults. But I cannot make that mean no minor faults.


Also, no clue what the userspace guys know or think to know, in my
experience they get it wrong anyway, regardless of what the manpage/spec
says.

But I've been telling the -rt folks for a long while that mlock only
guarantees no major faults for a while now (although apparently that's
not entirely true with current kernels, but see below).

> > Its sad that mlock() doesn't take a flags argument, so I'd rather
> > introduce a new madvise() flag for -rt, something like MADV_UNMOVABLE
> > (or whatever) which will basically copy the pages to an un-movable page
> > block and really pin the things.
>=20
>=20
> 1) We don't have space of vm_flags in 32bit machine and Konstantin
>    have sorted out but not sure it's merged. Anyway, Okay. It couldn't be=
 a problem.

Or we just make the thing u64... :-)

> 2) It needs application's fix and as Mel said, we might get new bug repor=
ts about latency.
>    Doesn't it break current mlock semantic? - " no page fault can be caus=
ed by function calls"
>    Otherwise, we should fix man page like your saying -   "no major page =
fault can be caused by function calls"=20

Well, if you look at v2.6.18:mm/rmap.c it would actually migrate mlocked
pages (which is what I remembered):

        if (!migration && ((vma->vm_flags & VM_LOCKED) ||
                        (ptep_clear_flush_young(vma, address, pte)))) {
                ret =3D SWAP_FAIL;
                goto out_unmap;
        }

So somewhere someone changed mlock() semantics already.

But yes, its going to cause pain whichever way around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
