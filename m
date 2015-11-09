Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0AADB6B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 19:15:56 -0500 (EST)
Received: by ykba4 with SMTP id a4so240271962ykb.3
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 16:15:55 -0800 (PST)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id d126si5853799ywc.319.2015.11.08.16.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 16:15:55 -0800 (PST)
Received: by ykek133 with SMTP id k133so240609824yke.2
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 16:15:55 -0800 (PST)
Date: Sun, 8 Nov 2015 16:15:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: avoid a little creat and stat slowdown
In-Reply-To: <87bnbagqa0.fsf@yhuang-dev.intel.com>
Message-ID: <alpine.LSU.2.11.1511081543590.14116@eggly.anvils>
References: <alpine.LSU.2.11.1510291208000.3475@eggly.anvils> <87bnbagqa0.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1103293643-1447028153=:14116"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, Yu Zhao <yuzhao@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1103293643-1447028153=:14116
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 4 Nov 2015, Huang, Ying wrote:
> Hugh Dickins <hughd@google.com> writes:
>=20
> > LKP reports that v4.2 commit afa2db2fb6f1 ("tmpfs: truncate prealloc
> > blocks past i_size") causes a 14.5% slowdown in the AIM9 creat-clo
> > benchmark.
> >
> > creat-clo does just what you'd expect from the name, and creat's O_TRUN=
C
> > on 0-length file does indeed get into more overhead now shmem_setattr()
> > tests "0 <=3D 0" instead of "0 < 0".
> >
> > I'm not sure how much we care, but I think it would not be too VW-like
> > to add in a check for whether any pages (or swap) are allocated: if non=
e
> > are allocated, there's none to remove from the radix_tree.  At first I
> > thought that check would be good enough for the unmaps too, but no: we
> > should not skip the unlikely case of unmapping pages beyond the new EOF=
,
> > which were COWed from holes which have now been reclaimed, leaving none=
=2E
> >
> > This gives me an 8.5% speedup: on Haswell instead of LKP's Westmere,
> > and running a debug config before and after: I hope those account for
> > the lesser speedup.
> >
> > And probably someone has a benchmark where a thousand threads keep on
> > stat'ing the same file repeatedly: forestall that report by adjusting
> > v4.3 commit 44a30220bc0a ("shmem: recalculate file inode when fstat")
> > not to take the spinlock in shmem_getattr() when there's no work to do.
> >
> > Reported-by: Ying Huang <ying.huang@linux.intel.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
>=20
> Hi, Hugh,
>=20
> Thanks a lot for your support!  The test on LKP shows that this patch
> restores a big part of the regression!  In following list,
>=20
> c435a390574d012f8d30074135d8fcc6f480b484: is parent commit
> afa2db2fb6f15f860069de94a1257db57589fe95: is the first bad commit has
> performance regression.
> 43819159da2b77fedcf7562134d6003dccd6a068: is the fixing patch

Hi Ying,

Thank you, for reporting, and for trying out the patch (which is now
in Linus's tree as commit d0424c429f8e0555a337d71e0a13f2289c636ec9).

But I'm disappointed by the result: do I understand correctly,
that afa2db2fb6f1 made a -12.5% change, but the fix still -5.6%
from your parent comparison point?  If we value that microbenchmark
at all (debatable), I'd say that's not good enough.

It does match with my own rough measurement, but I'd been hoping
for better when done in a more controlled environment; and I cannot
explain why "truncate prealloc blocks past i_size" creat-clo performance
would not be fully corrected by "avoid a little creat and stat slowdown"
(unless either patch adds subtle icache or dcache displacements).

I'm not certain of how you performed the comparison.  Was the
c435a390574d tree measured, then patch afa2db2fb6f1 applied on top
of that and measured, then patch 43819159da2b applied on top of that
and measured?  Or were there other intervening changes, which could
easily add their own interference?

Hugh

>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> compiler/cpufreq_governor/kconfig/rootfs/tbox_group/test/testcase/testtim=
e:
>   gcc-4.9/performance/x86_64-rhel/debian-x86_64-2015-02-07.cgz/lkp-wsx02/=
creat-clo/aim9/300s
>=20
> commit:=20
>   c435a390574d012f8d30074135d8fcc6f480b484
>   afa2db2fb6f15f860069de94a1257db57589fe95
>   43819159da2b77fedcf7562134d6003dccd6a068
>=20
> c435a390574d012f afa2db2fb6f15f860069de94a1 43819159da2b77fedcf7562134=20
> ---------------- -------------------------- --------------------------=20
>          %stddev     %change         %stddev     %change         %stddev
>              \          |                \          |                \ =
=20
>     563556 =C2=B1  1%     -12.5%     493033 =C2=B1  5%      -5.6%     531=
968 =C2=B1  1%  aim9.creat-clo.ops_per_sec
>      11836 =C2=B1  7%     +11.4%      13184 =C2=B1  7%     +15.0%      13=
608 =C2=B1  5%  numa-meminfo.node1.SReclaimable
>   10121526 =C2=B1  3%     -12.1%    8897097 =C2=B1  5%      -4.1%    9707=
953 =C2=B1  4%  proc-vmstat.pgalloc_normal
>       9.34 =C2=B1  4%     -11.4%       8.28 =C2=B1  3%      -4.8%       8=
=2E88 =C2=B1  2%  time.user_time
>       3480 =C2=B1  3%      -2.5%       3395 =C2=B1  1%     -28.5%       2=
488 =C2=B1  3%  vmstat.system.cs
>     203275 =C2=B1 17%      -6.8%     189453 =C2=B1  5%     -34.4%     133=
352 =C2=B1 11%  cpuidle.C1-NHM.usage
>    8081280 =C2=B1129%     -93.3%     538377 =C2=B1 97%     +31.5%   10625=
496 =C2=B1106%  cpuidle.C1E-NHM.time
>       3144 =C2=B1 58%    +619.0%      22606 =C2=B1 56%    +903.9%      31=
563 =C2=B1  0%  numa-vmstat.node0.numa_other
>       2958 =C2=B1  7%     +11.4%       3295 =C2=B1  7%     +15.0%       3=
401 =C2=B1  5%  numa-vmstat.node1.nr_slab_reclaimable
>      45074 =C2=B1  5%     -43.4%      25494 =C2=B1 57%     -68.7%      14=
105 =C2=B1  2%  numa-vmstat.node2.numa_other
>      56140 =C2=B1  0%      +0.0%      56158 =C2=B1  0%     -94.4%       3=
120 =C2=B1  0%  slabinfo.Acpi-ParseExt.active_objs
>       1002 =C2=B1  0%      +0.0%       1002 =C2=B1  0%     -92.0%      80=
=2E00 =C2=B1  0%  slabinfo.Acpi-ParseExt.active_slabs
>      56140 =C2=B1  0%      +0.0%      56158 =C2=B1  0%     -94.4%       3=
120 =C2=B1  0%  slabinfo.Acpi-ParseExt.num_objs
>       1002 =C2=B1  0%      +0.0%       1002 =C2=B1  0%     -92.0%      80=
=2E00 =C2=B1  0%  slabinfo.Acpi-ParseExt.num_slabs
>       1079 =C2=B1  5%     -10.8%     962.00 =C2=B1 10%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.blkdev_ioc.active_objs
>       1079 =C2=B1  5%     -10.8%     962.00 =C2=B1 10%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.blkdev_ioc.num_objs
>     110.67 =C2=B1 39%     +74.4%     193.00 =C2=B1 46%    +317.5%     462=
=2E00 =C2=B1  8%  slabinfo.blkdev_queue.active_objs
>     189.33 =C2=B1 23%     +43.7%     272.00 =C2=B1 33%    +151.4%     476=
=2E00 =C2=B1 10%  slabinfo.blkdev_queue.num_objs
>       1129 =C2=B1 10%      -1.9%       1107 =C2=B1  7%     +20.8%       1=
364 =C2=B1  6%  slabinfo.blkdev_requests.active_objs
>       1129 =C2=B1 10%      -1.9%       1107 =C2=B1  7%     +20.8%       1=
364 =C2=B1  6%  slabinfo.blkdev_requests.num_objs
>       1058 =C2=B1  3%     -10.3%     949.00 =C2=B1  9%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.file_lock_ctx.active_objs
>       1058 =C2=B1  3%     -10.3%     949.00 =C2=B1  9%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.file_lock_ctx.num_objs
>       4060 =C2=B1  1%      -2.1%       3973 =C2=B1  1%     -10.5%       3=
632 =C2=B1  1%  slabinfo.files_cache.active_objs
>       4060 =C2=B1  1%      -2.1%       3973 =C2=B1  1%     -10.5%       3=
632 =C2=B1  1%  slabinfo.files_cache.num_objs
>      10001 =C2=B1  0%      -0.3%       9973 =C2=B1  0%     -61.1%       3=
888 =C2=B1  0%  slabinfo.ftrace_event_field.active_objs
>      10001 =C2=B1  0%      -0.3%       9973 =C2=B1  0%     -61.1%       3=
888 =C2=B1  0%  slabinfo.ftrace_event_field.num_objs
>       1832 =C2=B1  0%      +0.4%       1840 =C2=B1  0%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.ftrace_event_file.active_objs
>       1832 =C2=B1  0%      +0.4%       1840 =C2=B1  0%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.ftrace_event_file.num_objs
>       1491 =C2=B1  5%      -2.3%       1456 =C2=B1  6%     +12.0%       1=
669 =C2=B1  4%  slabinfo.mnt_cache.active_objs
>       1491 =C2=B1  5%      -2.3%       1456 =C2=B1  6%     +12.0%       1=
669 =C2=B1  4%  slabinfo.mnt_cache.num_objs
>     126.33 =C2=B1 19%     +10.2%     139.17 =C2=B1  9%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.nfs_commit_data.active_objs
>     126.33 =C2=B1 19%     +10.2%     139.17 =C2=B1  9%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.nfs_commit_data.num_objs
>      97.17 =C2=B1 20%      -9.1%      88.33 =C2=B1 28%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.user_namespace.active_objs
>      97.17 =C2=B1 20%      -9.1%      88.33 =C2=B1 28%    -100.0%       0=
=2E00 =C2=B1 -1%  slabinfo.user_namespace.num_objs
>=20
> Best Regards,
> Huang, Ying
--0-1103293643-1447028153=:14116--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
