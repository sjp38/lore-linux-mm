Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C6C76900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 02:44:52 -0400 (EDT)
Message-ID: <475805.23113.qm@web162014.mail.bf1.yahoo.com>
Date: Wed, 13 Apr 2011 23:44:50 -0700 (PDT)
From: Pintu Agarwal <pintu_agarwal@yahoo.com>
Subject: Re: Regarding memory fragmentation using malloc....
In-Reply-To: <op.vtvuf5sk3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, Jiri Slaby <jslaby@suse.cz>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>

Thanks Mr. Michal for all your comments :)

As I can understand from your comments that, malloc from user space will no=
t have much impact on memory fragmentation.=20
Will the memory fragmentation be visible if I do kmalloc from the kernel mo=
dule????

> No.  When you call malloc() only virtual address space
> is allocated.  The
> actual allocation of physical space occurs when user space
> accesses the
> memory (either reads or writes) and it happens page at a
> time.

Here, if I do memset then I am accessing the memory...right? That I am doin=
g already in my sample program.

> what really happens is that kernel allocates the 0-order
> pages and when
> it runs out of those, splits a 1-order page into two
> 0-order pages and
> takes one of those.

Actually, if I understand buddy allocator, it allocates pages from top to b=
ottom. That means it checks for the highest order block that can be allocat=
ed, if possible it allocates pages from that block otherwise split the next=
 highest block into two.
What will happen if the next higher blocks are all empty???


Is the memory fragmentation is always a cause of the kernel space program a=
nd not user space at all??


Can you provide me with some references for migitating memory fragmentation=
 in linux?



Thanks,
Pintu


--- On Wed, 4/13/11, Michal Nazarewicz <mina86@mina86.com> wrote:

> From: Michal Nazarewicz <mina86@mina86.com>
> Subject: Re: Regarding memory fragmentation using malloc....
> To: "Am=E9rico Wang" <xiyou.wangcong@gmail.com>, "Pintu Agarwal" <pintu_a=
garwal@yahoo.com>
> Cc: "Andrew Morton" <akpm@linux-foundation.org>, "Eric Dumazet" <eric.dum=
azet@gmail.com>, "Changli Gao" <xiaosuo@gmail.com>, "Jiri Slaby" <jslaby@su=
se.cz>, "azurIt" <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@=
kvack.org, linux-fsdevel@vger.kernel.org, "Jiri Slaby" <jirislaby@gmail.com=
>
> Date: Wednesday, April 13, 2011, 10:25 AM
> On Wed, 13 Apr 2011 15:56:00 +0200,
> Pintu Agarwal <pintu_agarwal@yahoo.com>
> wrote:
> > My requirement is, I wanted to measure memory
> fragmentation level in linux kernel2.6.29 (ARM cortex A8
> without swap).
> > How can I measure fragmentation level(percentage) from
> /proc/buddyinfo ?
>=20
> [...]
>=20
> > In my linux2.6.29 ARM machine, the initial
> /proc/buddyinfo shows the following:
> > Node 0, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A017=A0 =A0=A0=A022=A0 =A0
> =A0 1=A0 =A0 =A0 1=A0 =A0 =A0 0=A0
> =A0 =A0 1=A0 =A0 =A0 1=A0 =A0 =A0
> 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0 =A0
> =A0 0=A0 =A0 =A0 0
> > Node 1, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A015=A0 =A0 320=A0 =A0 423=A0
> =A0 225=A0 =A0=A0=A097=A0
> =A0=A0=A026=A0 =A0 =A0 1=A0 =A0
> =A0 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0
> =A0 =A0 0=A0 =A0 =A0 0
> >=20
> > After running my sample program (with 16 iterations)
> the buddyinfo output is as follows:
> > Requesting <16> blocks of memory of block size
> <262144>........
> > Node 0, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A017=A0 =A0=A0=A022=A0 =A0
> =A0 1=A0 =A0 =A0 1=A0 =A0 =A0 0=A0
> =A0 =A0 1=A0 =A0 =A0 1=A0 =A0 =A0
> 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0 =A0
> =A0 0=A0 =A0 =A0 0
> > Node 1, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A015=A0 =A0 301=A0 =A0 419=A0
> =A0 224=A0 =A0=A0=A096=A0
> =A0=A0=A027=A0 =A0 =A0 1=A0 =A0
> =A0 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0
> =A0 =A0 0=A0 =A0 =A0 0
> >=A0 =A0=A0=A0nr_free_pages 169
> >=A0 =A0=A0=A0nr_free_pages 6545
> > *****************************************
> >=20
> >=20
> > Node 0, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A017=A0 =A0=A0=A022=A0 =A0
> =A0 1=A0 =A0 =A0 1=A0 =A0 =A0 0=A0
> =A0 =A0 1=A0 =A0 =A0 1=A0 =A0 =A0
> 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0 =A0
> =A0 0=A0 =A0 =A0 0
> > Node 1, zone=A0 =A0 =A0 DMA=A0
> =A0=A0=A018=A0 =A0 =A0 2=A0 =A0
> 305=A0 =A0 226=A0 =A0=A0=A096=A0
> =A0=A0=A027=A0 =A0 =A0 1=A0 =A0
> =A0 0=A0 =A0 =A0 0=A0 =A0 =A0 0=A0
> =A0 =A0 0=A0 =A0 =A0 0
> >=A0 =A0=A0=A0nr_free_pages 169
> >=A0 =A0=A0=A0nr_free_pages 5514
> > -----------------------------------------
> >=20
> > The requested block size is 64 pages (2^6) for each
> block.
> > But if we see the output after 16 iterations the
> buddyinfo allocates pages only from Node 1 , (2^0, 2^1, 2^2,
> 2^3).
> > But the actual allocation should happen from (2^6)
> block in buddyinfo.
>=20
> No.=A0 When you call malloc() only virtual address space
> is allocated.=A0 The
> actual allocation of physical space occurs when user space
> accesses the
> memory (either reads or writes) and it happens page at a
> time.
>=20
> As a matter of fact, if you have limited number of 0-order
> pages and
> allocates in user space block of 64 pages later accessing
> the memory,
> what really happens is that kernel allocates the 0-order
> pages and when
> it runs out of those, splits a 1-order page into two
> 0-order pages and
> takes one of those.
>=20
> Because of MMU, fragmentation of physical memory is not an
> issue for
> normal user space programs.
>=20
> It becomes an issue once you deal with hardware that does
> not have MMU
> nor support for scatter-getter DMA or with some big kernel
> structures.
>=20
> /proc/buddyinfo tells you how many free pages of given
> order there are
> in the system.=A0 You may interpret it in such a way
> that the bigger number
> of the low order pages the bigger fragmentation of physical
> memory.=A0 If
> there was no fragmentation (for some definition of the
> term) you'd get only
> the highest order pages and at most one page for each lower
> order.
>=20
> Again though, this fragmentation is not an issue for user
> space programs.
>=20
> --Best regards,=A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 =A0 =A0=A0=A0_=A0
> =A0=A0=A0_
> .o. | Liege of Serenely Enlightened Majesty of=A0 =A0
> =A0 o' \,=3D./ `o
> ..o | Computer Science,=A0 Michal "mina86"
> Nazarewicz=A0 =A0 (o o)
> ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
