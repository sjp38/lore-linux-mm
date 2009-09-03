Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7D8466B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 07:51:47 -0400 (EDT)
Date: Thu, 3 Sep 2009 12:51:13 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: BUG? misused atomic instructions in mm/swapfile.c
In-Reply-To: <2014bcab0909022255i53e9f72t4c131c648fb4754@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0909031246050.4008@sister.anvils>
References: <2014bcab0909022255i53e9f72t4c131c648fb4754@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1486218263-1251978673=:4008"
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1486218263-1251978673=:4008
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 3 Sep 2009, =ED=99=8D=EC=8B=A0 shin hong wrote:

> Hello. I am reporting atomic instructions usages
> which are suspected to be misused in mm/swapfile.c
> of Linux 2.6.30.5.
>=20
> I do not have much background on mm
> so that I am not certain whether it is correct or not.
> But I hope this report is helpful. Please examine the code.
>=20
> In try_to_use(), setup_swap_extents(), and SYSCALL_DEFINE2(),
> there are following codes:

It's only in try_to_unuse(), and let's add in the comment above it:
      /*
       * Don't hold on to start_mm if it looks like exiting.
       */
>     if (atomic_read(&start_mm->mm_users) =3D=3D 1) {
>         mmput(start_mm) ;
>         start_mm =3D &init_mm ;
>         atomic_inc(&init_mm.mm_users) ;
>     }
>=20
> It first checks start_mm->mm_users and then increments its value by one.
                                     and if it happens to be 1, decrements
  it in mmput, points start_mm to init_mm and increments that's mm_users.

>=20
> If one of these functions is executed in two different threads
> for the same start_mm concurrently,

Yes, that could happen, if swapoff is run concurrently on two different
swap areas: I usually forget that's even a possibility, and it's not an
efficient way to work, but we don't exclude it - thanks for reminding me.

> mmput(start_mm) can be executed twice as result of race.

That would be okay.  The juggling between init_mm, start_mm, new_start_mm,
prev_mm and mm is intricate and hard to follow!  but the reference that
that mmput puts started off with our atomic_inc_not_zero(&mm->mm_users)
lower down: this swapoff is mmput'ting a reference it acquired itself,
now associated with start_mm, and it's entitled to do so when resetting
start_mm, whether mm_users is 1 at that moment or not.

But given that, the "race" you describe cannot occur: if a concurrent
swapoff is going through the same code with the same start_mm, mm_users
will be at least 2.  The "problem" that can occur is the reverse of the
one you saw: the start_mm process may be exiting, but neither swapoff
sees mm_users 1, so together they hold that mm from being freed.

That too is okay: exit_mmap can free a lot of swap much faster than
swapoff can do it, so we prefer to get out of its way if we can; but
if occasionally we don't notice, no big deal.  After all, mm_users
might go down to 1 just a moment after that check there (or perhaps
even up to 2): it's nothing more than a heuristic.

>=20
> I think it would be better to combine two atomic operations
> into one atomic operation (e.g. atomic_cmpxchg).

That's not necessary here at all, but is important in the
atomic_inc_not_zero we got our first reference from.

Hugh
--8323584-1486218263-1251978673=:4008--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
