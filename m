Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 536CD6B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 16:03:16 -0400 (EDT)
Date: Thu, 6 Aug 2009 21:03:03 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: shmem + TTM  oops
In-Reply-To: <4A7ACC90.2000808@tungstengraphics.com>
Message-ID: <Pine.LNX.4.64.0908062045270.944@sister.anvils>
References: <4A7ACC90.2000808@tungstengraphics.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-70471242-1249588983=:944"
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-70471242-1249588983=:944
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 6 Aug 2009, Thomas Hellstr=C3=B6m wrote:
> Hi!
> I've been debugging a strange problem for a while, and it'd be nice to ha=
ve
> some more eyes on this.
>=20
> When the TTM graphics memory manager decides it's using too much memory, =
it
> copies the contents of the buffer to shmem objects and releases the buffe=
rs.
> This is because shmem objects are pageable whereas TTM buffers are not. W=
hen
> the TTM buffers are accessed in one way or another, it copies contents ba=
ck.
> Seems to work fairly nice, but not really optimal.
>=20
> When the X server is VT switched, TTM optionally switches out all buffers=
 to
> shmem objects, but when the contents are read back, some shmem objects ha=
ve
> corrupted swap entry top directory. The member
> shmem_inode_info::i_indirect[0] usually contains a value 0xffffff60 or
> something similar, causing an oops in shmem_truncate_range() when the shm=
em
> object is freed. Before that, readback seems to work OK. The corruption i=
s
> happening after X server VT switch when TTM is supposed to be idle. The s=
hmem
> objects have been verified to have swap entry directories after all buffe=
r
> objects have been swapped out.

Not a symptom I've ever come across: I agree strange.  A few questions:

What architecture? I assume x86 32-bit; if so, what happens on 64-bit?
if not x86, what is your PAGE_SIZE?

What size are these objects i.e. how many pages?

What release? I'm assuming 2.6.31-rc5 and various earlier.

What slab allocator? what if you choose another (SLUB versus SLAB)?
Please turn on all the slab/slub debugging you can.

And you say i_indirect "usually contains a value 0xffffff60 or something
similar": please give other examples of what you find there (if possible,
with a rough idea of their frequency e.g. is 0xffffff60 the most common?).

Does there appear to be corruption of any other nearby fields?

Thanks.

>=20
> If anyone could shed some light over this, it would be very helpful. Rele=
vant
> TTM code is fairly straightforward looks like this. The process that copi=
es
> out to shmem objects may not be the same process that copies in:

I didn't notice anything wrong with your code; and it wouldn't
be easy for it to corrupt that field of shmem_inode_info.

Hugh
--8323584-70471242-1249588983=:944--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
