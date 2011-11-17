Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 391F26B006C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 20:31:51 -0500 (EST)
Received: by iaek3 with SMTP id k3so1952076iae.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 17:31:47 -0800 (PST)
Date: Wed, 16 Nov 2011 17:31:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Patch] tmpfs: add fallocate support
In-Reply-To: <4EC3633D.6090900@redhat.com>
Message-ID: <alpine.LSU.2.00.1111161634360.1957@sister.anvils>
References: <1321346525-10187-1-git-send-email-amwang@redhat.com> <CAOJsxLEXbWbEhqX2YfzcQhyLJrY0H2ifCJCvGkoFHZsYAZEMPA@mail.gmail.com> <4EC361C0.7040309@redhat.com> <alpine.LFD.2.02.1111160911320.2446@tux.localdomain> <4EC3633D.6090900@redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-434404406-1321493505=:1957"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kay.sievers@vrfy.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-434404406-1321493505=:1957
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 16 Nov 2011, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B411=E6=9C=8816=E6=97=A5 15:12, Pekka Enberg =E5=86=
=99=E9=81=93:
> > On Wed, 16 Nov 2011, Cong Wang wrote:
> > > > What's the use case for this?
> > >=20
> > > Systemd needs it, see http://lkml.org/lkml/2011/10/20/275.
> > > I am adding Kay into Cc.
> >=20
> > The post doesn't mention why it needs it, though.
> >=20
>=20
> Right, I should mention this in the changelog. :-/

Yes, but I think Pekka's point is that the page which you link to does not
explain why Plumbers would want tmpfs to support fallocate() properly.

What good is it going to do for them?  Why not just do it in userspace,
either by dd if=3D/dev/zero of=3Dtmpfsfile, or by mmap() and touch if very
anxious to avoid the triple memset/memcpy (once reading from /dev/zero,
once allocating tmpfs pages, once copying to tmpfs pages)?  Or splice().

I don't want to stand in the way of progress, but there's a lot of
things tmpfs does not support (a persistent filesystem would be top
of the list; but readahead, direct I/O, AIO, ....), and it may be
better to continue not to support them unless there's good reason.
tmpfs does not have a disk layout that we need to optimize.

I did not study your implementation in detail, but agree with Dave
and Kame that (if it needs to be in kernel at all) you should reuse
the existing code rather than repeating extracts: shmem_getpage_gfp()
is the one place which looks after all of shmem page allocation, so
I'd prefer you just make a loop of calls to that (with a new sgp_type
if there's particular reason to do something differently in there).

I've not yet looked up the specification of fallocate(), but it
looked surprising to be allocating pages up to the point where a
page already exists (when shmem_add_to_page_cache will fail) and
then giving up with -EEXIST.

Seeing your Subject, I imagined at first that you would be implementing
FALLOC_FL_PUNCH_HOLE support. That is on my list to do: tmpfs has its
own peculiar madvise(MADV_REMOVE) support (and yes, you may question
whether we were right to add that in) - we should be converting
MADV_REMOVE to use FALLOC_FL_PUNCH_HOLE, and tmpfs to support that.

Thanks,
Hugh
--8323584-434404406-1321493505=:1957--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
