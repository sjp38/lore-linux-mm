Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA8FB6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 21:36:00 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4J1ZvOK007275
	for <linux-mm@kvack.org>; Wed, 18 May 2011 18:35:57 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq1.eem.corp.google.com with ESMTP id p4J1Zseb011734
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 18:35:55 -0700
Received: by pxi10 with SMTP id 10so1593116pxi.22
        for <linux-mm@kvack.org>; Wed, 18 May 2011 18:35:54 -0700 (PDT)
Date: Wed, 18 May 2011 18:35:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
In-Reply-To: <BANLkTi=bLOzrEPVx8ossZtaxe3OmH9ZXNw@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1105181821500.1690@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils> <BANLkTi=4YY6aJk+ZLiiF7UX73LZD=7+W2Q@mail.gmail.com> <alpine.LSU.2.00.1105181709540.1282@sister.anvils> <BANLkTi=bLOzrEPVx8ossZtaxe3OmH9ZXNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1581008198-1305768964=:1690"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1581008198-1305768964=:1690
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 19 May 2011, Minchan Kim wrote:
> On Thu, May 19, 2011 at 9:28 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Thu, 19 May 2011, Minchan Kim wrote:
> >>
> >> You are changing behavior a bit.
> >> Old behavior is to account FAULT although the operation got failed.
> >> But new one is to not account it.
> >> I think we have to account it regardless of whether it is successful o=
r not.
> >> That's because it is fact fault happens.
> >
> > That's a good catch: something I didn't think of at all.
> >
> > However, it looks as if the patch remains correct, and is fixing
> > a bug (or inconsistency) that we hadn't noticed before.
> >
> > If you look through filemap_fault() or do_swap_page() (or even
> > ncp_file_mmap_fault(), though I don't take that one as canonical!),
> > they clearly do not count the major fault on error (except in the
> > case where VM_FAULT_MAJOR needs VM_FAULT_RETRY, then gets
> > VM_FAULT_ERROR on the retry).
> >
> > So, shmem.c was the odd one out before. =C2=A0If you feel very strongly
> > about it ("it is fact fault happens") you could submit a patch to
> > change them all - but I think just leave them as is.
>=20
> Okay. I don't feel it strongly now.
> Then, could you repost your patch with corrected description about
> this behavior change which is a bug or inconsistency whatever. :)

If I can think up a correct paragraph which makes it clear.
Let me hold off on that, and see what other comments come in.

The situation is less clear-cut than I described above.  I was
dismissing the VM_FAULT_MAJOR|VM_FAULT_RETRY then VM_FAULT_ERROR
case as unlikely, whereas that would be the common case of I/O error
on fault on x86 now - reading in takes page lock, so it will retry.

Whereas other architectures (not using FAULT_FLAG_ALLOW_RETRY)
behave as I described, as filemap_fault() used to behave.

I don't think this a major fault in my patch ;)
Just something we don't care very much about.

Hugh
--8323584-1581008198-1305768964=:1690--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
