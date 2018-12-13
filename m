Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D16A08E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 05:26:52 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so1375108qte.16
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 02:26:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c7si839345qtn.359.2018.12.13.02.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 02:26:51 -0800 (PST)
Date: Thu, 13 Dec 2018 05:26:50 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <837880744.86933950.1544696810428.JavaMail.zimbra@redhat.com>
In-Reply-To: <9291e284-7b9b-3d93-1e79-f01c174d9979@huawei.com>
References: <1125108393.85764095.1544629302243.JavaMail.zimbra@redhat.com> <9291e284-7b9b-3d93-1e79-f01c174d9979@huawei.com>
Subject: Re: [bug?] poor migrate_pages() performance on arm64
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Garry <john.garry@huawei.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, ltp@lists.linux.it, Linuxarm <linuxarm@huawei.com>, Tan Xiaojun <tanxiaojun@huawei.com>



----- Original Message -----
> + cc'ing linuxarm@huawei.com
>=20
> It seems that we're spending much time in cache invalidate.
>=20
> When you say 4 nodes, does that mean memory on all 4 nodes?

Correct:

# numactl -H
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
node 0 size: 65304 MB
node 0 free: 59939 MB
node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
node 1 size: 65404 MB
node 1 free: 64419 MB
node 2 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
node 2 size: 65404 MB
node 2 free: 64832 MB
node 3 cpus: 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
node 3 size: 65403 MB
node 3 free: 64805 MB
node distances:
node   0   1   2   3=20
  0:  10  15  20  20=20
  1:  15  10  20  20=20
  2:  20  20  10  15=20
  3:  20  20  15  10

>=20
> Thanks,
> John
>=20
> On 12/12/2018 15:41, Jan Stancek wrote:
> > Hi,
> >
> > I'm observing migrate_pages() taking quite long time on arm64
> > system (Huawei TaiShan 2280, 4 nodes, 64 CPUs). I'm using 4.20.0-rc6,
> > but it's reproducible with older kernels (4.14) as well.
> >
> > The test (see [1] below), is a trivial C application, that migrates
> > current process from one node to another. More complicated example
> > is also LTP's migrate_pages03, where this has been originally reported.
> >
> > It takes 2+ seconds to migrate process from one node to another:
> >   # strace -f -t -T ./a.out
> >   ...
> >   [pid 13754] 10:17:13 migrate_pages(0, 8, [0x0000000000000002],
> >   [0x0000000000000001]) =3D 1 <0.058115>
> >   [pid 13754] 10:17:13 migrate_pages(0, 8, [0x0000000000000001],
> >   [0x0000000000000002]) =3D 12 <2.348186>
> >   [pid 13754] 10:17:16 migrate_pages(0, 8, [0x0000000000000002],
> >   [0x0000000000000001]) =3D 1 <0.057889>
> >   [pid 13754] 10:17:16 migrate_pages(0, 8, [0x0000000000000001],
> >   [0x0000000000000002]) =3D 10 <2.194890>
> >   ...
> >
> > This scales with number of children. For example with MAXCHILD 1000,
> > it takes ~33 seconds:
> >   # strace -f -t -T ./a.out
> >   ...
> >   [pid 13773] 10:17:55 migrate_pages(0, 8, [0x0000000000000001],
> >   [0x0000000000000002]) =3D 11 <33.615550>
> >   [pid 13773] 10:18:29 migrate_pages(0, 8, [0x0000000000000002],
> >   [0x0000000000000001]) =3D 2 <5.460270>
> >   ...
> >
> > It appears to be related to migration of shared pages, presumably
> > executable code of glibc.
> >
> > If I run [1] without CAP_SYS_NICE, it completes very quickly:
> >   # sudo -u nobody strace -f -t -T ./a.out
> >   ...
> >   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000001],
> >   [0x0000000000000002]) =3D 0 <0.000172>
> >   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000002],
> >   [0x0000000000000001]) =3D 0 <0.000091>
> >   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000001],
> >   [0x0000000000000002]) =3D 0 <0.000074>
> >   [pid 14847] 10:24:57 migrate_pages(0, 8, [0x0000000000000002],
> >   [0x0000000000000001]) =3D 0 <0.000069>
> >   ...
> >
> >
> > Looking at perf, most of time is spent invalidating icache.
> >
> > -  100.00%     0.00%  a.out    [kernel.kallsyms]  [k] __sys_trace_retur=
n
> >    - __sys_trace_return
> >       - 100.00% __se_sys_migrate_pages
> >            do_migrate_pages.part.9
> >          - migrate_pages
> >             - 99.92% rmap_walk
> >                - 99.92% rmap_walk_file
> >                   - 99.90% remove_migration_pte
> >                      - 99.85% __sync_icache_dcache
> >                           __flush_cache_user_range
> >
> > Percent=E2=94=82      nop
> >        =E2=94=82      ubfx   x3, x3, #16, #4
> >        =E2=94=82      mov    x2, #0x4                        // #4
> >        =E2=94=82      lsl    x2, x2, x3
> >        =E2=94=82      sub    x3, x2, #0x1
> >        =E2=94=82      bic    x4, x0, x3
> >   1.82 =E2=94=82      dc     cvau, x4
> >        =E2=94=82      add    x4, x4, x2
> >        =E2=94=82      cmp    x4, x1
> >        =E2=94=82    =E2=86=92 b.cc   0xffff00000809efc8  // b.lo, b.ul,=
 fffff7f61067
> >        =E2=94=82      dsb    ish
> >        =E2=94=82      nop
> >   0.07 =E2=94=82      nop
> >        =E2=94=82      mrs    x3, ctr_el0
> >        =E2=94=82      nop
> >        =E2=94=82      and    x3, x3, #0xf
> >        =E2=94=82      mov    x2, #0x4                        // #4
> >        =E2=94=82      lsl    x2, x2, x3
> >        =E2=94=82      sub    x3, x2, #0x1
> >        =E2=94=82      bic    x3, x0, x3
> >  96.17 =E2=94=82      ic     ivau, x3
> >        =E2=94=82      add    x3, x3, x2
> >        =E2=94=82      cmp    x3, x1
> >        =E2=94=82    =E2=86=92 b.cc   0xffff00000809f000  // b.lo, b.ul,=
 fffff7f61067
> >   0.10 =E2=94=82      dsb    ish
> >        =E2=94=82      isb
> >   1.85 =E2=94=82      mov    x0, #0x0                        // #0
> >        =E2=94=8278: =E2=86=90 ret
> >        =E2=94=82      mov    x0, #0xfffffffffffffff2         // #-14
> >        =E2=94=82    =E2=86=91 b      78
> >
> > Regards,
> > Jan
> >
> > [1]
> > ----- 8< -----
> > #include <signal.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <unistd.h>
> > #include <sys/syscall.h>
> >
> > #define MAXCHILD 10
> >
> > int main(void)
> > {
> > =09long node1 =3D 1, node2 =3D 2;
> > =09int i, child;
> > =09int pids[MAXCHILD];
> >
> > =09for (i =3D 0; i < MAXCHILD; i++) {
> > =09=09child =3D fork();
> > =09=09if (child =3D=3D 0) {
> > =09=09=09sleep(600);
> > =09=09=09exit(0);
> > =09=09}
> > =09=09pids[i] =3D child;
> > =09}
> >
> > =09for (i =3D 0; i < 5; i++) {
> > =09=09syscall(__NR_migrate_pages, 0, 8, &node1, &node2);
> > =09=09syscall(__NR_migrate_pages, 0, 8, &node2, &node1);
> > =09}
> >
> > =09for (i =3D 0; i < MAXCHILD; i++) {
> > =09=09kill(pids[i], SIGKILL);
> > =09}
> >
> > =09return 0;
> > }
> > ----- >8 -----
> >
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> >
>=20
>=20
>=20
