Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EE4096B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 12:04:21 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p5BG4JXJ018853
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 09:04:19 -0700
Received: from pvh18 (pvh18.prod.google.com [10.241.210.210])
	by wpaz33.hot.corp.google.com with ESMTP id p5BG4HXJ002199
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 09:04:18 -0700
Received: by pvh18 with SMTP id 18so1772768pvh.31
        for <linux-mm@kvack.org>; Sat, 11 Jun 2011 09:04:17 -0700 (PDT)
Date: Sat, 11 Jun 2011 09:04:14 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
In-Reply-To: <BANLkTi=bBSeMFtUDyz+px1Kt34HDU=DEcw@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1106110847190.29336@sister.anvils>
References: <20110609212956.GA2319@redhat.com> <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com> <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com> <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils> <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com> <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com> <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com> <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106101425400.28334@sister.anvils> <BANLkTi=bBSeMFtUDyz+px1Kt34HDU=DEcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1115670598-1307808256=:29336"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1115670598-1307808256=:29336
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 11 Jun 2011, Hiroyuki Kamezawa wrote:
> 2011/6/11 Hugh Dickins <hughd@google.com>:
> > On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> >>
> >> I think this can be a fix.
> >
> > Sorry, I think not: I've not digested your rationale,
> > but three things stand out:
> >
> > 1. Why has this only just started happening? =A0I may not have run that
> > =A0 test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
> > =A0 maybe not with khugepaged, but certainly with ksmd.
> >
> Not sure. I pointed this just by review because I found "charge" in
> khugepaged is out of mmap_sem now.

Right, Andrea's patch cited below.

>=20
> > 2. Your hunk below:
> >> - =A0 =A0 if (!mm_need_new_owner(mm, p))
> >> + =A0 =A0 if (!mm_need_new_owner(mm, p)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(mm->owner, NULL);
> > =A0 is now setting mm->owner to NULL at times when we were sure it did =
not
> > =A0 need updating before (task is not the owner): you're damaging mm->o=
wner.
> >
> Ah, yes. It's my mistake.
>=20
> > 3. There's a patch from Andrea in 3.0-rc1 which looks very likely to be
> > =A0 relevant, 692e0b35427a "mm: thp: optimize memcg charge in khugepage=
d".
> > =A0 I'll try reproducing without that tonight (I crashed in 20 minutes
> > =A0 this morning, so it's not too hard).

I had another go at reproducing it, 2 hours that time, then a try with
692e0b35427a reverted: it ran overnight for 9 hours when I stopped it.

Andrea, please would you ask Linus to revert that commit before -rc3?
Or is there something else you'd like us to try instead?  I admit that
I've not actually taken the time to think through exactly how it goes
wrong, but it does look dangerous.

The way I reproduce it is with my tmpfs kbuilds swapping load,
in this case restricting mem by memcg, and (perhaps the important
detail, not certain) doing concurrent swapoff/swapon repeatedly -
swapoff takes another mm_users reference to the mm it's working on,
which can cause surprises.

Hugh
--8323584-1115670598-1307808256=:29336--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
