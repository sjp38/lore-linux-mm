Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6CE9C6B0108
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 21:11:03 -0400 (EDT)
Received: by gxk12 with SMTP id 12so5038791gxk.4
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:11:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
References: <82e12e5f0908220954p7019fb3dg15f9b99bb7e55a8c@mail.gmail.com>
	 <28c262360908231844o3df95b14v15b2d4424465f033@mail.gmail.com>
	 <20090824105139.c2ab8403.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 24 Aug 2009 11:23:21 +0900
Message-ID: <28c262360908231923q354281a6yca3b43019af3c40e@mail.gmail.com>
Subject: Re: [PATCH] mm: make munlock fast when mlock is canceled by sigkill
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroaki Wakabayashi <primulaelatior@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Paul Menage <menage@google.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 24, 2009 at 10:51 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 24 Aug 2009 10:44:41 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Sun, Aug 23, 2009 at 1:54 AM, Hiroaki
>> Wakabayashi<primulaelatior@gmail.com> wrote:
>> > From 27b2fde0222c59049026e7d0bdc4a2a68d0720f5 Mon Sep 17 00:00:00 2001
>> > From: Hiroaki Wakabayashi <primulaelatior@gmail.com>
>> > Date: Sat, 22 Aug 2009 19:14:53 +0900
>> > Subject: [PATCH] mm: make munlock fast when mlock is canceled by sigki=
ll
>> >
>> > This patch is for making commit 4779280d1e (mm: make get_user_pages()
>> > interruptible) complete.
>> >
>> > At first, munlock() assumes that all pages in vma are pinned,
>> >
>> > Now, by the commit, mlock() can be interrupted by SIGKILL, etc =C2=A0S=
o, part of
>> > pages are not pinned.
>> > If SIGKILL, In exit() path, munlock is called for unlocking pinned pag=
es
>> > in vma.
>> >
>> > But, there, get_user_pages(write) is used for munlock(). Then, pages a=
re
>> > allocated via page-fault for exsiting process !!! This is problem at c=
anceling
>> > big mlock.
>> > This patch tries to avoid allocating new pages at munlock().
>> >
>> > =C2=A0 mlock( big area )
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0<=3D=3D=3D=3D=3D sig kill
>> > =C2=A0 do_exit()
>> > =C2=A0 =C2=A0->mmput()
>> > =C2=A0 =C2=A0 =C2=A0 -> do_munlock()
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 -> get_user_pages()
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <allocate *never used=
* memory>
>> > =C2=A0 =C2=A0 =C2=A0 ->.....freeing allocated memory.
>> >
>> > * Test program
>> > % cat run.sh
>> > #!/bin/sh
>> >
>> > ./mlock_test 2000000000 &
>> > sleep 2
>> > kill -9 $!
>> > wait
>> >
>> > % cat mlock_test.c
>> > #include <stdio.h>
>> > #include <stdlib.h>
>> > #include <string.h>
>> > #include <sys/mman.h>
>> > #include <sys/types.h>
>> > #include <sys/stat.h>
>> > #include <fcntl.h>
>> > #include <errno.h>
>> > #include <time.h>
>> > #include <unistd.h>
>> > #include <sys/time.h>
>> >
>> > int main(int argc, char **argv)
>> > {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t length =3D 50 * 1024 * 1024;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0void *addr;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0time_t timer;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (argc >=3D 2)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0length =3D strt=
oul(argv[1], NULL, 10);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("PID =3D %d\n", getpid());
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0addr =3D mmap(NULL, length, PROT_READ | PRO=
T_WRITE,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0MAP_PRIVATE | MAP_ANONYMOUS, -1, 0=
);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (addr =3D=3D MAP_FAILED) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fprintf(stderr,=
 "mmap failed: %s, length=3D%lu\n",
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0strerror(errno), length);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exit(EXIT_FAILU=
RE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("try mlock length=3D%lu\n", length);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0timer =3D time(NULL);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mlock(addr, length) < 0) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fprintf(stderr,=
 "mlock failed: %s, time=3D%lu[sec]\n",
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0strerror(errno), time(NULL) - time=
r);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exit(EXIT_FAILU=
RE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("mlock succeed, time=3D%lu[sec]\n\n"=
, time(NULL) - timer);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("try munlock length=3D%lu\n", length=
);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0timer =3D time(NULL);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (munlock(addr, length) < 0) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fprintf(stderr,=
 "munlock failed: %s, time=3D%lu[sec]\n",
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0strerror(errno), time(NULL)-timer)=
;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exit(EXIT_FAILU=
RE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0printf("munlock succeed, time=3D%lu[sec]\n\=
n", time(NULL) - timer);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (munmap(addr, length) < 0) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fprintf(stderr,=
 "munmap failed: %s\n", strerror(errno));
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exit(EXIT_FAILU=
RE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> > }
>> >
>> > * Executed Result
>> > -- Original executed result
>> > % time ./run.sh
>> >
>> > PID =3D 2678
>> > try mlock length=3D2000000000
>> > ./run.sh: line 6: =C2=A02678 Killed =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0./mlock_test 2000000000
>> > ./run.sh =C2=A00.00s user 2.59s system 13% cpu 18.781 total
>> > %
>> >
>> > -- After applied this patch
>> > % time ./run.sh
>> >
>> > PID =3D 2512
>> > try mlock length=3D2000000000
>> > ./run.sh: line 6: =C2=A02512 Killed =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0./mlock_test 2000000000
>> > ./run.sh =C2=A00.00s user 1.15s system 45% cpu 2.507 total
>> > %
>> >
>> > Signed-off-by: Hiroaki Wakabayashi <primulaelatior@gmail.com>
>> > ---
>> > =C2=A0mm/internal.h | =C2=A0 =C2=A01 +
>> > =C2=A0mm/memory.c =C2=A0 | =C2=A0 =C2=A09 +++++++--
>> > =C2=A0mm/mlock.c =C2=A0 =C2=A0| =C2=A0 35 +++++++++++++++++++---------=
-------
>> > =C2=A03 files changed, 27 insertions(+), 18 deletions(-)
>> >
>> > diff --git a/mm/internal.h b/mm/internal.h
>> > index f290c4d..4ab5b24 100644
>> > --- a/mm/internal.h
>> > +++ b/mm/internal.h
>> > @@ -254,6 +254,7 @@ static inline void
>> > mminit_validate_memmodel_limits(unsigned long *start_pfn,
>> > =C2=A0#define GUP_FLAGS_FORCE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00x2
>> > =C2=A0#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
>> > =C2=A0#define GUP_FLAGS_IGNORE_SIGKILL =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x8
>> > +#define GUP_FLAGS_ALLOW_NULL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 0x10
>> >
>>
>> I am worried about adding new flag whenever we need it.
>> But I think this case makes sense to me.
>> In addition, I guess ZERO page can also use this flag.
>>
>> Kame. What do you think about it?
>>
> I do welcome this !
> Then, I don't have to take care of mlock/munlock in ZERO_PAGE patch.
>
> And without this patch, munlock() does copy-on-write just for unpinning m=
emory.
> So, this patch shows some right direction, I think.
>
> One concern is flag name, ALLOW_NULL sounds not very good.
>
> =C2=A0GUP_FLAGS_NOFAULT ?
>
> I wonder we can remove a hack of FOLL_ANON for core-dump by this flag, to=
o.

That's a good point.
It can remove little cache footprint and
unnecessary calls[flush_xxx_page in GUP].

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
