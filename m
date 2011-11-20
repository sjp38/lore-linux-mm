Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 681C46B0069
	for <linux-mm@kvack.org>; Sun, 20 Nov 2011 16:39:21 -0500 (EST)
Received: by iaek3 with SMTP id k3so8564429iae.14
        for <linux-mm@kvack.org>; Sun, 20 Nov 2011 13:39:19 -0800 (PST)
Date: Sun, 20 Nov 2011 13:39:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
In-Reply-To: <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1111201322310.1264@sister.anvils>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com> <20111119100326.GA27967@infradead.org> <CAPXgP10q8Fba3vr0zf-XBBaRPwjP7MyJ=-QRL45_8WC-vtotOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-594298835-1321825155=:1264"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-594298835-1321825155=:1264
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 19 Nov 2011, Kay Sievers wrote:
> On Sat, Nov 19, 2011 at 11:03, Christoph Hellwig <hch@infradead.org> wrot=
e:
> > On Fri, Nov 18, 2011 at 06:39:50PM +0800, Cong Wang wrote:
> >> It seems that systemd needs tmpfs to support fallocate,
> >> see http://lkml.org/lkml/2011/10/20/275. This patch adds
> >> fallocate support to tmpfs.
> >
> > What for exactly? =C2=A0Please explain why preallocating on tmpfs would
> > make any sense.
>=20
> To be able to safely use mmap(), regarding SIGBUS, on files on the
> /dev/shm filesystem. The glibc fallback loop for -ENOSYS on fallocate
> is just ugly.

The fallback for -EOPNOTSUPP?

Being unfamiliar with glibc, I failed to find the internal_fallocate()
that it appears to use when the filesystem doesn't support the call;
so I don't know if I would agree with you that it's uglier than doing
the same(?) in the kernel.

But since the present situation is that tmpfs has one interface to
punching holes, madvise(MADV_REMOVE), that IBM were pushing 5 years ago;
but ext4 (and others) now a fallocate(FALLOC_FL_PUNCH_HOLE) interface
which IBM have been pushing this year: we do want to normalize that
situation and make them all behave the same way.

And if tmpfs is going to support fallocate(FALLOC_FL_PUNCH_HOLE),
looking at Amerigo's much more attractive V2 patch, it would seem
to me perverse to permit the deallocation but fail the allocation.

The principle of least surprise argues that we grant your wish:
provided it doesn't grow much more complicated once I look more
closely.

Hugh
--8323584-594298835-1321825155=:1264--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
