Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 02B956B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 20:12:56 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so5240048pbb.41
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:12:56 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jy13so4030156veb.6
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 17:12:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Ning Qu <quning@google.com>
Date: Tue, 24 Sep 2013 17:12:33 -0700
Message-ID: <CACz4_2drFs5LsM8mTFNOWGHAs0QbsNfHAhiBXJ7jM3qkGerd5w@mail.gmail.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Type: multipart/alternative; boundary=047d7bd6ac72543ed004e72a1d1a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--047d7bd6ac72543ed004e72a1d1a
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi, Kirill,

Seems you dropped one patch in v5, is that intentional? Just wondering ...

  thp, mm: handle tail pages in page_cache_get_speculative()

Thanks!

Best wishes,
--=20
Ning Qu (=E6=9B=B2=E5=AE=81) | Software Engineer | quning@google.com | +1-4=
08-418-6066


On Mon, Sep 23, 2013 at 5:05 AM, Kirill A. Shutemov <
kirill.shutemov@linux.intel.com> wrote:

> It brings thp support for ramfs, but without mmap() -- it will be posted
> separately.
>
> Please review and consider applying.
>
> Intro
> -----
>
> The goal of the project is preparing kernel infrastructure to handle huge
> pages in page cache.
>
> To proof that the proposed changes are functional we enable the feature
> for the most simple file system -- ramfs. ramfs is not that useful by
> itself, but it's good pilot project.
>
> Design overview
> ---------------
>
> Every huge page is represented in page cache radix-tree by HPAGE_PMD_NR
> (512 on x86-64) entries. All entries points to head page -- refcounting f=
or
> tail pages is pretty expensive.
>
> Radix tree manipulations are implemented in batched way: we add and remov=
e
> whole huge page at once, under one tree_lock. To make it possible, we
> extended radix-tree interface to be able to pre-allocate memory enough to
> insert a number of *contiguous* elements (kudos to Matthew Wilcox).
>
> Huge pages can be added to page cache three ways:
>  - write(2) to file or page;
>  - read(2) from sparse file;
>  - fault sparse file.
>
> Potentially, one more way is collapsing small page, but it's outside
> initial
> implementation.
>
> For now we still write/read at most PAGE_CACHE_SIZE bytes a time. There's
> some room for speed up later.
>
> Since mmap() isn't targeted for this patchset, we just split huge page on
> page fault.
>
> To minimize memory overhead for small files we aviod write-allocation in
> first huge page area (2M on x86-64) of the file.
>
> truncate_inode_pages_range() drops whole huge page at once if it's fully
> inside the range. If a huge page is only partly in the range we zero out
> the part, exactly like we do for partial small pages.
>
> split_huge_page() for file pages works similar to anon pages, but we
> walk by mapping->i_mmap rather then anon_vma->rb_root. At the end we call
> truncate_inode_pages() to drop small pages beyond i_size, if any.
>
> inode->i_split_sem taken on read will protect hugepages in inode's
> pagecache
> against splitting. We take it on write during splitting.
>
> Changes since v5
> ----------------
>  - change how hugepage stored in pagecache: head page for all relevant
>    indexes;
>  - introduce i_split_sem;
>  - do not create huge pages on write(2) into first hugepage area;
>  - compile-disabled by default;
>  - fix transparent_hugepage_pagecache();
>
> Benchmarks
> ----------
>
> Since the patchset doesn't include mmap() support, we should expect much
> change in performance. We just need to check that we don't introduce any
> major regression.
>
> On average read/write on ramfs with thp is a bit slower, but I don't thin=
k
> it's a stopper -- ramfs is a toy anyway, on real world filesystems I
> expect difference to be smaller.
>
> postmark
> =3D=3D=3D=3D=3D=3D=3D=3D
>
> workload1:
> chmod +x postmark
> mount -t ramfs none /mnt
> cat >/root/workload1 <<EOF
> set transactions 250000
> set size 5120 524288
> set number 500
> run
> quit
>
> workload2:
> set transactions 10000
> set size 2097152 10485760
> set number 100
> run
> quit
>
> throughput (transactions/sec)
>                 workload1       workload2
> baseline        8333            416
> patched         8333            454
>
> FS-Mark
> =3D=3D=3D=3D=3D=3D=3D
>
> throughput (files/sec)
>
>                 2000 files by 1M        200 files by 10M
> baseline        5326.1                  548.1
> patched         5192.8                  528.4
>
> tiobench
> =3D=3D=3D=3D=3D=3D=3D=3D
>
> baseline:
> Tiotest results for 16 concurrent io threads:
> ,----------------------------------------------------------------------.
> | Item                  | Time     | Rate         | Usr CPU  | Sys CPU |
> +-----------------------+----------+--------------+----------+---------+
> | Write        2048 MBs |    0.2 s | 8667.792 MB/s | 445.2 %  | 5535.9 % =
|
> | Random Write   62 MBs |    0.0 s | 8341.118 MB/s |   0.0 %  | 2615.8 % =
|
> | Read         2048 MBs |    0.2 s | 11680.431 MB/s | 339.9 %  | 5470.6 %=
 |
> | Random Read    62 MBs |    0.0 s | 9451.081 MB/s | 786.3 %  | 1451.7 % =
|
> `----------------------------------------------------------------------'
> Tiotest latency results:
> ,------------------------------------------------------------------------=
-.
> | Item         | Average latency | Maximum latency | % >2 sec | % >10 sec=
 |
> +--------------+-----------------+-----------------+----------+----------=
-+
> | Write        |        0.006 ms |       28.019 ms |  0.00000 |   0.00000=
 |
> | Random Write |        0.002 ms |        5.574 ms |  0.00000 |   0.00000=
 |
> | Read         |        0.005 ms |       28.018 ms |  0.00000 |   0.00000=
 |
> | Random Read  |        0.002 ms |        4.852 ms |  0.00000 |   0.00000=
 |
> |--------------+-----------------+-----------------+----------+----------=
-|
> | Total        |        0.005 ms |       28.019 ms |  0.00000 |   0.00000=
 |
> `--------------+-----------------+-----------------+----------+----------=
-'
>
> patched:
> Tiotest results for 16 concurrent io threads:
> ,----------------------------------------------------------------------.
> | Item                  | Time     | Rate         | Usr CPU  | Sys CPU |
> +-----------------------+----------+--------------+----------+---------+
> | Write        2048 MBs |    0.3 s | 7942.818 MB/s | 442.1 %  | 5533.6 % =
|
> | Random Write   62 MBs |    0.0 s | 9425.426 MB/s | 723.9 %  | 965.2 % |
> | Read         2048 MBs |    0.2 s | 11998.008 MB/s | 374.9 %  | 5485.8 %=
 |
> | Random Read    62 MBs |    0.0 s | 9823.955 MB/s | 251.5 %  | 2011.9 % =
|
> `----------------------------------------------------------------------'
> Tiotest latency results:
> ,------------------------------------------------------------------------=
-.
> | Item         | Average latency | Maximum latency | % >2 sec | % >10 sec=
 |
> +--------------+-----------------+-----------------+----------+----------=
-+
> | Write        |        0.007 ms |       28.020 ms |  0.00000 |   0.00000=
 |
> | Random Write |        0.001 ms |        0.022 ms |  0.00000 |   0.00000=
 |
> | Read         |        0.004 ms |       24.011 ms |  0.00000 |   0.00000=
 |
> | Random Read  |        0.001 ms |        0.019 ms |  0.00000 |   0.00000=
 |
> |--------------+-----------------+-----------------+----------+----------=
-|
> | Total        |        0.005 ms |       28.020 ms |  0.00000 |   0.00000=
 |
> `--------------+-----------------+-----------------+----------+----------=
-'
>
> IOZone
> =3D=3D=3D=3D=3D=3D
>
> Syscalls, not mmap.
>
> ** Initial writers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           4741691    7986408    9149064    9898695    9868597
>  9629383    9469202   11605064    9507802   10641869   11360701   1104037=
6
> patched:            4682864    7275535    8691034    8872887    8712492
>  8771912    8397216    7701346    7366853    8839736    8299893   1078843=
9
> speed-up(times):       0.99       0.91       0.95       0.90       0.88
>     0.91       0.89       0.66       0.77       0.83       0.73       0.9=
8
>
> ** Rewriters **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           5807891    9554869   12101083   13113533   12989751
> 14359910   16998236   16833861   24735659   17502634   17396706   2044865=
5
> patched:            6161690    9981294   12285789   13428846   13610058
> 13669153   20060182   17328347   24109999   19247934   24225103   3468657=
4
> speed-up(times):       1.06       1.04       1.02       1.02       1.05
>     0.95       1.18       1.03       0.97       1.10       1.39       1.7=
0
>
> ** Readers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           7978066   11825735   13808941   14049598   14765175
> 14422642   17322681   23209831   21386483   20060744   22032935   3116666=
3
> patched:            7723293   11481500   13796383   14363808   14353966
> 14979865   17648225   18701258   29192810   23973723   22163317   2310463=
8
> speed-up(times):       0.97       0.97       1.00       1.02       0.97
>     1.04       1.02       0.81       1.37       1.20       1.01       0.7=
4
>
> ** Re-readers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           7966269   11878323   14000782   14678206   14154235
> 14271991   15170829   20924052   27393344   19114990   12509316   1849559=
7
> patched:            7719350   11410937   13710233   13232756   14040928
> 15895021   16279330   17256068   26023572   18364678   27834483   2328868=
0
> speed-up(times):       0.97       0.96       0.98       0.90       0.99
>     1.11       1.07       0.82       0.95       0.96       2.23       1.2=
6
>
> ** Reverse readers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           6630795   10331013   12839501   13157433   12783323
> 13580283   15753068   15434572   21928982   17636994   14737489   1947067=
9
> patched:            6502341    9887711   12639278   12979232   13212825
> 12928255   13961195   14695786   21370667   19873807   20902582   2189289=
9
> speed-up(times):       0.98       0.96       0.98       0.99       1.03
>     0.95       0.89       0.95       0.97       1.13       1.42       1.1=
2
>
> ** Random_readers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           5152935    9043813   11752615   11996078   12283579
> 12484039   14588004   15781507   23847538   15748906   13698335   2719584=
7
> patched:            5009089    8438137   11266015   11631218   12093650
> 12779308   17768691   13640378   30468890   19269033   23444358   2277590=
8
> speed-up(times):       0.97       0.93       0.96       0.97       0.98
>     1.02       1.22       0.86       1.28       1.22       1.71       0.8=
4
>
> ** Random_writers **
> threads:                  1          2          4          8         10
>       20         30         40         50         60         70         8=
0
> baseline:           3886268    7405345   10531192   10858984   10994693
> 12758450   10729531    9656825   10370144   13139452    4528331   1261581=
2
> patched:            4335323    7916132   10978892   11423247   11790932
> 11424525   11798171   11413452   12230616   13075887   11165314   1692567=
9
> speed-up(times):       1.12       1.07       1.04       1.05       1.07
>     0.90       1.10       1.18       1.18       1.00       2.47       1.3=
4
>
> Kirill A. Shutemov (22):
>   mm: implement zero_huge_user_segment and friends
>   radix-tree: implement preload for multiple contiguous elements
>   memcg, thp: charge huge cache pages
>   thp: compile-time and sysfs knob for thp pagecache
>   thp, mm: introduce mapping_can_have_hugepages() predicate
>   thp: represent file thp pages in meminfo and friends
>   thp, mm: rewrite add_to_page_cache_locked() to support huge pages
>   mm: trace filemap: dump page order
>   block: implement add_bdi_stat()
>   thp, mm: rewrite delete_from_page_cache() to support huge pages
>   thp, mm: warn if we try to use replace_page_cache_page() with THP
>   thp, mm: add event counters for huge page alloc on file write or read
>   mm, vfs: introduce i_split_sem
>   thp, mm: allocate huge pages in grab_cache_page_write_begin()
>   thp, mm: naive support of thp in generic_perform_write
>   thp, mm: handle transhuge pages in do_generic_file_read()
>   thp, libfs: initial thp support
>   truncate: support huge pages
>   thp: handle file pages in split_huge_page()
>   thp: wait_split_huge_page(): serialize over i_mmap_mutex too
>   thp, mm: split huge page on mmap file page
>   ramfs: enable transparent huge page cache
>
>  Documentation/vm/transhuge.txt |  16 ++++
>  drivers/base/node.c            |   4 +
>  fs/inode.c                     |   3 +
>  fs/libfs.c                     |  58 +++++++++++-
>  fs/proc/meminfo.c              |   3 +
>  fs/ramfs/file-mmu.c            |   2 +-
>  fs/ramfs/inode.c               |   6 +-
>  include/linux/backing-dev.h    |  10 +++
>  include/linux/fs.h             |  11 +++
>  include/linux/huge_mm.h        |  68 +++++++++++++-
>  include/linux/mm.h             |  18 ++++
>  include/linux/mmzone.h         |   1 +
>  include/linux/page-flags.h     |  13 +++
>  include/linux/pagemap.h        |  31 +++++++
>  include/linux/radix-tree.h     |  11 +++
>  include/linux/vm_event_item.h  |   4 +
>  include/trace/events/filemap.h |   7 +-
>  lib/radix-tree.c               |  94 ++++++++++++++++++--
>  mm/Kconfig                     |  11 +++
>  mm/filemap.c                   | 196
> ++++++++++++++++++++++++++++++++---------
>  mm/huge_memory.c               | 147 +++++++++++++++++++++++++++----
>  mm/memcontrol.c                |   3 +-
>  mm/memory.c                    |  40 ++++++++-
>  mm/truncate.c                  | 125 ++++++++++++++++++++------
>  mm/vmstat.c                    |   5 ++
>  25 files changed, 779 insertions(+), 108 deletions(-)
>
> --
> 1.8.4.rc3
>
>

--047d7bd6ac72543ed004e72a1d1a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi, Kirill,<div><br></div><div>Seems you dropped one patch=
 in v5, is that intentional? Just wondering ...</div><div><br></div><div><s=
pan style=3D"font-family:arial,sans-serif;font-size:13px">=C2=A0 thp, mm:=
=C2=A0</span><span class=3D"" style=3D"font-family:arial,sans-serif;font-si=
ze:13px">handle</span><span style=3D"font-family:arial,sans-serif;font-size=
:13px">=C2=A0</span><span class=3D"" style=3D"font-family:arial,sans-serif;=
font-size:13px">tail</span><span style=3D"font-family:arial,sans-serif;font=
-size:13px">=C2=A0</span><span class=3D"" style=3D"font-family:arial,sans-s=
erif;font-size:13px">pages</span><span style=3D"font-family:arial,sans-seri=
f;font-size:13px">=C2=A0in=C2=A0</span><span class=3D"" style=3D"font-famil=
y:arial,sans-serif;font-size:13px">page_cache_get_speculative</span><span s=
tyle=3D"font-family:arial,sans-serif;font-size:13px">()</span><br style=3D"=
font-family:arial,sans-serif;font-size:13px">

</div><div><span style=3D"font-family:arial,sans-serif;font-size:13px"><br>=
</span></div><div><span style=3D"font-family:arial,sans-serif;font-size:13p=
x">Thanks!</span></div></div><div class=3D"gmail_extra"><br clear=3D"all"><=
div>

<div><div>Best wishes,<br></div><div><span style=3D"border-collapse:collaps=
e;font-family:arial,sans-serif;font-size:13px">--=C2=A0<br><span style=3D"b=
order-collapse:collapse;font-family:sans-serif;line-height:19px"><span styl=
e=3D"border-top-width:2px;border-right-width:0px;border-bottom-width:0px;bo=
rder-left-width:0px;border-top-style:solid;border-right-style:solid;border-=
bottom-style:solid;border-left-style:solid;border-top-color:rgb(213,15,37);=
border-right-color:rgb(213,15,37);border-bottom-color:rgb(213,15,37);border=
-left-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Ning Qu (=E6=9B=
=B2=E5=AE=81)<font color=3D"#555555">=C2=A0|</font></span><span style=3D"co=
lor:rgb(85,85,85);border-top-width:2px;border-right-width:0px;border-bottom=
-width:0px;border-left-width:0px;border-top-style:solid;border-right-style:=
solid;border-bottom-style:solid;border-left-style:solid;border-top-color:rg=
b(51,105,232);border-right-color:rgb(51,105,232);border-bottom-color:rgb(51=
,105,232);border-left-color:rgb(51,105,232);padding-top:2px;margin-top:2px"=
>=C2=A0Software Engineer |</span><span style=3D"color:rgb(85,85,85);border-=
top-width:2px;border-right-width:0px;border-bottom-width:0px;border-left-wi=
dth:0px;border-top-style:solid;border-right-style:solid;border-bottom-style=
:solid;border-left-style:solid;border-top-color:rgb(0,153,57);border-right-=
color:rgb(0,153,57);border-bottom-color:rgb(0,153,57);border-left-color:rgb=
(0,153,57);padding-top:2px;margin-top:2px">=C2=A0<a href=3D"mailto:quning@g=
oogle.com" style=3D"color:rgb(0,0,204)" target=3D"_blank">quning@google.com=
</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);border-top-width:2px;b=
order-right-width:0px;border-bottom-width:0px;border-left-width:0px;border-=
top-style:solid;border-right-style:solid;border-bottom-style:solid;border-l=
eft-style:solid;border-top-color:rgb(238,178,17);border-right-color:rgb(238=
,178,17);border-bottom-color:rgb(238,178,17);border-left-color:rgb(238,178,=
17);padding-top:2px;margin-top:2px">=C2=A0<a value=3D"+16502143877" style=
=3D"color:rgb(0,0,204)">+1-408-418-6066</a></span></span></span></div>

</div></div>
<br><br><div class=3D"gmail_quote">On Mon, Sep 23, 2013 at 5:05 AM, Kirill =
A. Shutemov <span dir=3D"ltr">&lt;<a href=3D"mailto:kirill.shutemov@linux.i=
ntel.com" target=3D"_blank">kirill.shutemov@linux.intel.com</a>&gt;</span> =
wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">It brings thp support for ramfs, but without=
 mmap() -- it will be posted<br>
separately.<br>
<br>
Please review and consider applying.<br>
<br>
Intro<br>
-----<br>
<br>
The goal of the project is preparing kernel infrastructure to handle huge<b=
r>
pages in page cache.<br>
<br>
To proof that the proposed changes are functional we enable the feature<br>
for the most simple file system -- ramfs. ramfs is not that useful by<br>
itself, but it&#39;s good pilot project.<br>
<br>
Design overview<br>
---------------<br>
<br>
Every huge page is represented in page cache radix-tree by HPAGE_PMD_NR<br>
(512 on x86-64) entries. All entries points to head page -- refcounting for=
<br>
tail pages is pretty expensive.<br>
<br>
Radix tree manipulations are implemented in batched way: we add and remove<=
br>
whole huge page at once, under one tree_lock. To make it possible, we<br>
extended radix-tree interface to be able to pre-allocate memory enough to<b=
r>
insert a number of *contiguous* elements (kudos to Matthew Wilcox).<br>
<br>
Huge pages can be added to page cache three ways:<br>
=C2=A0- write(2) to file or page;<br>
=C2=A0- read(2) from sparse file;<br>
=C2=A0- fault sparse file.<br>
<br>
Potentially, one more way is collapsing small page, but it&#39;s outside in=
itial<br>
implementation.<br>
<br>
For now we still write/read at most PAGE_CACHE_SIZE bytes a time. There&#39=
;s<br>
some room for speed up later.<br>
<br>
Since mmap() isn&#39;t targeted for this patchset, we just split huge page =
on<br>
page fault.<br>
<br>
To minimize memory overhead for small files we aviod write-allocation in<br=
>
first huge page area (2M on x86-64) of the file.<br>
<br>
truncate_inode_pages_range() drops whole huge page at once if it&#39;s full=
y<br>
inside the range. If a huge page is only partly in the range we zero out<br=
>
the part, exactly like we do for partial small pages.<br>
<br>
split_huge_page() for file pages works similar to anon pages, but we<br>
walk by mapping-&gt;i_mmap rather then anon_vma-&gt;rb_root. At the end we =
call<br>
truncate_inode_pages() to drop small pages beyond i_size, if any.<br>
<br>
inode-&gt;i_split_sem taken on read will protect hugepages in inode&#39;s p=
agecache<br>
against splitting. We take it on write during splitting.<br>
<br>
Changes since v5<br>
----------------<br>
=C2=A0- change how hugepage stored in pagecache: head page for all relevant=
<br>
=C2=A0 =C2=A0indexes;<br>
=C2=A0- introduce i_split_sem;<br>
=C2=A0- do not create huge pages on write(2) into first hugepage area;<br>
=C2=A0- compile-disabled by default;<br>
=C2=A0- fix transparent_hugepage_pagecache();<br>
<br>
Benchmarks<br>
----------<br>
<br>
Since the patchset doesn&#39;t include mmap() support, we should expect muc=
h<br>
change in performance. We just need to check that we don&#39;t introduce an=
y<br>
major regression.<br>
<br>
On average read/write on ramfs with thp is a bit slower, but I don&#39;t th=
ink<br>
it&#39;s a stopper -- ramfs is a toy anyway, on real world filesystems I<br=
>
expect difference to be smaller.<br>
<br>
postmark<br>
=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
workload1:<br>
chmod +x postmark<br>
mount -t ramfs none /mnt<br>
cat &gt;/root/workload1 &lt;&lt;EOF<br>
set transactions 250000<br>
set size 5120 524288<br>
set number 500<br>
run<br>
quit<br>
<br>
workload2:<br>
set transactions 10000<br>
set size 2097152 10485760<br>
set number 100<br>
run<br>
quit<br>
<br>
throughput (transactions/sec)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 workload1 =C2=A0 =
=C2=A0 =C2=A0 workload2<br>
baseline =C2=A0 =C2=A0 =C2=A0 =C2=A08333 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0416<br>
patched =C2=A0 =C2=A0 =C2=A0 =C2=A0 8333 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0454<br>
<br>
FS-Mark<br>
=3D=3D=3D=3D=3D=3D=3D<br>
<br>
throughput (files/sec)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2000 files by 1M =
=C2=A0 =C2=A0 =C2=A0 =C2=A0200 files by 10M<br>
baseline =C2=A0 =C2=A0 =C2=A0 =C2=A05326.1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0548.1<br>
patched =C2=A0 =C2=A0 =C2=A0 =C2=A0 5192.8 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0528.4<br>
<br>
tiobench<br>
=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
baseline:<br>
Tiotest results for 16 concurrent io threads:<br>
,----------------------------------------------------------------------.<br=
>
| Item =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| Time=
 =C2=A0 =C2=A0 | Rate =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Usr CPU =C2=A0| Sys CPU=
 |<br>
+-----------------------+----------+--------------+----------+---------+<br=
>
| Write =C2=A0 =C2=A0 =C2=A0 =C2=A02048 MBs | =C2=A0 =C2=A00.2 s | 8667.792=
 MB/s | 445.2 % =C2=A0| 5535.9 % |<br>
| Random Write =C2=A0 62 MBs | =C2=A0 =C2=A00.0 s | 8341.118 MB/s | =C2=A0 =
0.0 % =C2=A0| 2615.8 % |<br>
| Read =C2=A0 =C2=A0 =C2=A0 =C2=A0 2048 MBs | =C2=A0 =C2=A00.2 s | 11680.43=
1 MB/s | 339.9 % =C2=A0| 5470.6 % |<br>
| Random Read =C2=A0 =C2=A062 MBs | =C2=A0 =C2=A00.0 s | 9451.081 MB/s | 78=
6.3 % =C2=A0| 1451.7 % |<br>
`----------------------------------------------------------------------&#39=
;<br>
Tiotest latency results:<br>
,-------------------------------------------------------------------------.=
<br>
| Item =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Average latency | Maximum latency | % =
&gt;2 sec | % &gt;10 sec |<br>
+--------------+-----------------+-----------------+----------+-----------+=
<br>
| Write =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.006 ms | =
=C2=A0 =C2=A0 =C2=A0 28.019 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Random Write | =C2=A0 =C2=A0 =C2=A0 =C2=A00.002 ms | =C2=A0 =C2=A0 =C2=A0=
 =C2=A05.574 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Read =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A00.005 ms | =
=C2=A0 =C2=A0 =C2=A0 28.018 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Random Read =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.002 ms | =C2=A0 =C2=A0 =
=C2=A0 =C2=A04.852 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
|--------------+-----------------+-----------------+----------+-----------|=
<br>
| Total =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.005 ms | =
=C2=A0 =C2=A0 =C2=A0 28.019 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
`--------------+-----------------+-----------------+----------+-----------&=
#39;<br>
<br>
patched:<br>
Tiotest results for 16 concurrent io threads:<br>
,----------------------------------------------------------------------.<br=
>
| Item =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| Time=
 =C2=A0 =C2=A0 | Rate =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Usr CPU =C2=A0| Sys CPU=
 |<br>
+-----------------------+----------+--------------+----------+---------+<br=
>
| Write =C2=A0 =C2=A0 =C2=A0 =C2=A02048 MBs | =C2=A0 =C2=A00.3 s | 7942.818=
 MB/s | 442.1 % =C2=A0| 5533.6 % |<br>
| Random Write =C2=A0 62 MBs | =C2=A0 =C2=A00.0 s | 9425.426 MB/s | 723.9 %=
 =C2=A0| 965.2 % |<br>
| Read =C2=A0 =C2=A0 =C2=A0 =C2=A0 2048 MBs | =C2=A0 =C2=A00.2 s | 11998.00=
8 MB/s | 374.9 % =C2=A0| 5485.8 % |<br>
| Random Read =C2=A0 =C2=A062 MBs | =C2=A0 =C2=A00.0 s | 9823.955 MB/s | 25=
1.5 % =C2=A0| 2011.9 % |<br>
`----------------------------------------------------------------------&#39=
;<br>
Tiotest latency results:<br>
,-------------------------------------------------------------------------.=
<br>
| Item =C2=A0 =C2=A0 =C2=A0 =C2=A0 | Average latency | Maximum latency | % =
&gt;2 sec | % &gt;10 sec |<br>
+--------------+-----------------+-----------------+----------+-----------+=
<br>
| Write =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.007 ms | =
=C2=A0 =C2=A0 =C2=A0 28.020 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Random Write | =C2=A0 =C2=A0 =C2=A0 =C2=A00.001 ms | =C2=A0 =C2=A0 =C2=A0=
 =C2=A00.022 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Read =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A0 =C2=A0 =C2=A00.004 ms | =
=C2=A0 =C2=A0 =C2=A0 24.011 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
| Random Read =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.001 ms | =C2=A0 =C2=A0 =
=C2=A0 =C2=A00.019 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
|--------------+-----------------+-----------------+----------+-----------|=
<br>
| Total =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A0 =C2=A0 =C2=A00.005 ms | =
=C2=A0 =C2=A0 =C2=A0 28.020 ms | =C2=A00.00000 | =C2=A0 0.00000 |<br>
`--------------+-----------------+-----------------+----------+-----------&=
#39;<br>
<br>
IOZone<br>
=3D=3D=3D=3D=3D=3D<br>
<br>
Syscalls, not mmap.<br>
<br>
** Initial writers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4741691 =C2=A0 =C2=A07986408 =
=C2=A0 =C2=A09149064 =C2=A0 =C2=A09898695 =C2=A0 =C2=A09868597 =C2=A0 =C2=
=A09629383 =C2=A0 =C2=A09469202 =C2=A0 11605064 =C2=A0 =C2=A09507802 =C2=A0=
 10641869 =C2=A0 11360701 =C2=A0 11040376<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04682864 =C2=A0 =C2=A07275=
535 =C2=A0 =C2=A08691034 =C2=A0 =C2=A08872887 =C2=A0 =C2=A08712492 =C2=A0 =
=C2=A08771912 =C2=A0 =C2=A08397216 =C2=A0 =C2=A07701346 =C2=A0 =C2=A0736685=
3 =C2=A0 =C2=A08839736 =C2=A0 =C2=A08299893 =C2=A0 10788439<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 0.99 =C2=A0 =C2=A0 =C2=A0 0.91 =C2=A0=
 =C2=A0 =C2=A0 0.95 =C2=A0 =C2=A0 =C2=A0 0.90 =C2=A0 =C2=A0 =C2=A0 0.88 =C2=
=A0 =C2=A0 =C2=A0 0.91 =C2=A0 =C2=A0 =C2=A0 0.89 =C2=A0 =C2=A0 =C2=A0 0.66 =
=C2=A0 =C2=A0 =C2=A0 0.77 =C2=A0 =C2=A0 =C2=A0 0.83 =C2=A0 =C2=A0 =C2=A0 0.=
73 =C2=A0 =C2=A0 =C2=A0 0.98<br>
<br>
** Rewriters **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5807891 =C2=A0 =C2=A09554869 =
=C2=A0 12101083 =C2=A0 13113533 =C2=A0 12989751 =C2=A0 14359910 =C2=A0 1699=
8236 =C2=A0 16833861 =C2=A0 24735659 =C2=A0 17502634 =C2=A0 17396706 =C2=A0=
 20448655<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06161690 =C2=A0 =C2=A09981=
294 =C2=A0 12285789 =C2=A0 13428846 =C2=A0 13610058 =C2=A0 13669153 =C2=A0 =
20060182 =C2=A0 17328347 =C2=A0 24109999 =C2=A0 19247934 =C2=A0 24225103 =
=C2=A0 34686574<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 1.06 =C2=A0 =C2=A0 =C2=A0 1.04 =C2=A0=
 =C2=A0 =C2=A0 1.02 =C2=A0 =C2=A0 =C2=A0 1.02 =C2=A0 =C2=A0 =C2=A0 1.05 =C2=
=A0 =C2=A0 =C2=A0 0.95 =C2=A0 =C2=A0 =C2=A0 1.18 =C2=A0 =C2=A0 =C2=A0 1.03 =
=C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 1.10 =C2=A0 =C2=A0 =C2=A0 1.=
39 =C2=A0 =C2=A0 =C2=A0 1.70<br>
<br>
** Readers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7978066 =C2=A0 11825735 =C2=A0=
 13808941 =C2=A0 14049598 =C2=A0 14765175 =C2=A0 14422642 =C2=A0 17322681 =
=C2=A0 23209831 =C2=A0 21386483 =C2=A0 20060744 =C2=A0 22032935 =C2=A0 3116=
6663<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07723293 =C2=A0 11481500 =
=C2=A0 13796383 =C2=A0 14363808 =C2=A0 14353966 =C2=A0 14979865 =C2=A0 1764=
8225 =C2=A0 18701258 =C2=A0 29192810 =C2=A0 23973723 =C2=A0 22163317 =C2=A0=
 23104638<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0=
 =C2=A0 =C2=A0 1.00 =C2=A0 =C2=A0 =C2=A0 1.02 =C2=A0 =C2=A0 =C2=A0 0.97 =C2=
=A0 =C2=A0 =C2=A0 1.04 =C2=A0 =C2=A0 =C2=A0 1.02 =C2=A0 =C2=A0 =C2=A0 0.81 =
=C2=A0 =C2=A0 =C2=A0 1.37 =C2=A0 =C2=A0 =C2=A0 1.20 =C2=A0 =C2=A0 =C2=A0 1.=
01 =C2=A0 =C2=A0 =C2=A0 0.74<br>
<br>
** Re-readers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7966269 =C2=A0 11878323 =C2=A0=
 14000782 =C2=A0 14678206 =C2=A0 14154235 =C2=A0 14271991 =C2=A0 15170829 =
=C2=A0 20924052 =C2=A0 27393344 =C2=A0 19114990 =C2=A0 12509316 =C2=A0 1849=
5597<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07719350 =C2=A0 11410937 =
=C2=A0 13710233 =C2=A0 13232756 =C2=A0 14040928 =C2=A0 15895021 =C2=A0 1627=
9330 =C2=A0 17256068 =C2=A0 26023572 =C2=A0 18364678 =C2=A0 27834483 =C2=A0=
 23288680<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 0.96 =C2=A0=
 =C2=A0 =C2=A0 0.98 =C2=A0 =C2=A0 =C2=A0 0.90 =C2=A0 =C2=A0 =C2=A0 0.99 =C2=
=A0 =C2=A0 =C2=A0 1.11 =C2=A0 =C2=A0 =C2=A0 1.07 =C2=A0 =C2=A0 =C2=A0 0.82 =
=C2=A0 =C2=A0 =C2=A0 0.95 =C2=A0 =C2=A0 =C2=A0 0.96 =C2=A0 =C2=A0 =C2=A0 2.=
23 =C2=A0 =C2=A0 =C2=A0 1.26<br>
<br>
** Reverse readers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6630795 =C2=A0 10331013 =C2=A0=
 12839501 =C2=A0 13157433 =C2=A0 12783323 =C2=A0 13580283 =C2=A0 15753068 =
=C2=A0 15434572 =C2=A0 21928982 =C2=A0 17636994 =C2=A0 14737489 =C2=A0 1947=
0679<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06502341 =C2=A0 =C2=A09887=
711 =C2=A0 12639278 =C2=A0 12979232 =C2=A0 13212825 =C2=A0 12928255 =C2=A0 =
13961195 =C2=A0 14695786 =C2=A0 21370667 =C2=A0 19873807 =C2=A0 20902582 =
=C2=A0 21892899<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 0.98 =C2=A0 =C2=A0 =C2=A0 0.96 =C2=A0=
 =C2=A0 =C2=A0 0.98 =C2=A0 =C2=A0 =C2=A0 0.99 =C2=A0 =C2=A0 =C2=A0 1.03 =C2=
=A0 =C2=A0 =C2=A0 0.95 =C2=A0 =C2=A0 =C2=A0 0.89 =C2=A0 =C2=A0 =C2=A0 0.95 =
=C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 1.13 =C2=A0 =C2=A0 =C2=A0 1.=
42 =C2=A0 =C2=A0 =C2=A0 1.12<br>
<br>
** Random_readers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 5152935 =C2=A0 =C2=A09043813 =
=C2=A0 11752615 =C2=A0 11996078 =C2=A0 12283579 =C2=A0 12484039 =C2=A0 1458=
8004 =C2=A0 15781507 =C2=A0 23847538 =C2=A0 15748906 =C2=A0 13698335 =C2=A0=
 27195847<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A05009089 =C2=A0 =C2=A08438=
137 =C2=A0 11266015 =C2=A0 11631218 =C2=A0 12093650 =C2=A0 12779308 =C2=A0 =
17768691 =C2=A0 13640378 =C2=A0 30468890 =C2=A0 19269033 =C2=A0 23444358 =
=C2=A0 22775908<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 0.93 =C2=A0=
 =C2=A0 =C2=A0 0.96 =C2=A0 =C2=A0 =C2=A0 0.97 =C2=A0 =C2=A0 =C2=A0 0.98 =C2=
=A0 =C2=A0 =C2=A0 1.02 =C2=A0 =C2=A0 =C2=A0 1.22 =C2=A0 =C2=A0 =C2=A0 0.86 =
=C2=A0 =C2=A0 =C2=A0 1.28 =C2=A0 =C2=A0 =C2=A0 1.22 =C2=A0 =C2=A0 =C2=A0 1.=
71 =C2=A0 =C2=A0 =C2=A0 0.84<br>
<br>
** Random_writers **<br>
threads: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 20 =C2=A0 =C2=A0 =C2=A0 =C2=A0 30 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 40 =C2=A0 =C2=A0 =C2=A0 =C2=A0 50 =C2=A0 =C2=A0 =C2=A0 =C2=A0 60 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 70 =C2=A0 =C2=A0 =C2=A0 =C2=A0 80<br>
baseline: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 3886268 =C2=A0 =C2=A07405345 =
=C2=A0 10531192 =C2=A0 10858984 =C2=A0 10994693 =C2=A0 12758450 =C2=A0 1072=
9531 =C2=A0 =C2=A09656825 =C2=A0 10370144 =C2=A0 13139452 =C2=A0 =C2=A04528=
331 =C2=A0 12615812<br>
patched: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04335323 =C2=A0 =C2=A07916=
132 =C2=A0 10978892 =C2=A0 11423247 =C2=A0 11790932 =C2=A0 11424525 =C2=A0 =
11798171 =C2=A0 11413452 =C2=A0 12230616 =C2=A0 13075887 =C2=A0 11165314 =
=C2=A0 16925679<br>
speed-up(times): =C2=A0 =C2=A0 =C2=A0 1.12 =C2=A0 =C2=A0 =C2=A0 1.07 =C2=A0=
 =C2=A0 =C2=A0 1.04 =C2=A0 =C2=A0 =C2=A0 1.05 =C2=A0 =C2=A0 =C2=A0 1.07 =C2=
=A0 =C2=A0 =C2=A0 0.90 =C2=A0 =C2=A0 =C2=A0 1.10 =C2=A0 =C2=A0 =C2=A0 1.18 =
=C2=A0 =C2=A0 =C2=A0 1.18 =C2=A0 =C2=A0 =C2=A0 1.00 =C2=A0 =C2=A0 =C2=A0 2.=
47 =C2=A0 =C2=A0 =C2=A0 1.34<br>
<br>
Kirill A. Shutemov (22):<br>
=C2=A0 mm: implement zero_huge_user_segment and friends<br>
=C2=A0 radix-tree: implement preload for multiple contiguous elements<br>
=C2=A0 memcg, thp: charge huge cache pages<br>
=C2=A0 thp: compile-time and sysfs knob for thp pagecache<br>
=C2=A0 thp, mm: introduce mapping_can_have_hugepages() predicate<br>
=C2=A0 thp: represent file thp pages in meminfo and friends<br>
=C2=A0 thp, mm: rewrite add_to_page_cache_locked() to support huge pages<br=
>
=C2=A0 mm: trace filemap: dump page order<br>
=C2=A0 block: implement add_bdi_stat()<br>
=C2=A0 thp, mm: rewrite delete_from_page_cache() to support huge pages<br>
=C2=A0 thp, mm: warn if we try to use replace_page_cache_page() with THP<br=
>
=C2=A0 thp, mm: add event counters for huge page alloc on file write or rea=
d<br>
=C2=A0 mm, vfs: introduce i_split_sem<br>
=C2=A0 thp, mm: allocate huge pages in grab_cache_page_write_begin()<br>
=C2=A0 thp, mm: naive support of thp in generic_perform_write<br>
=C2=A0 thp, mm: handle transhuge pages in do_generic_file_read()<br>
=C2=A0 thp, libfs: initial thp support<br>
=C2=A0 truncate: support huge pages<br>
=C2=A0 thp: handle file pages in split_huge_page()<br>
=C2=A0 thp: wait_split_huge_page(): serialize over i_mmap_mutex too<br>
=C2=A0 thp, mm: split huge page on mmap file page<br>
=C2=A0 ramfs: enable transparent huge page cache<br>
<br>
=C2=A0Documentation/vm/transhuge.txt | =C2=A016 ++++<br>
=C2=A0drivers/base/node.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 4 +<br>
=C2=A0fs/inode.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | =C2=A0 3 +<br>
=C2=A0fs/libfs.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | =C2=A058 +++++++++++-<br>
=C2=A0fs/proc/meminfo.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =
=C2=A0 3 +<br>
=C2=A0fs/ramfs/file-mmu.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 2 +-<br>
=C2=A0fs/ramfs/inode.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0 6 +-<br>
=C2=A0include/linux/backing-dev.h =C2=A0 =C2=A0| =C2=A010 +++<br>
=C2=A0include/linux/fs.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
11 +++<br>
=C2=A0include/linux/huge_mm.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A068 +++++++=
++++++-<br>
=C2=A0include/linux/mm.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0=
18 ++++<br>
=C2=A0include/linux/mmzone.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 1 +<br>
=C2=A0include/linux/page-flags.h =C2=A0 =C2=A0 | =C2=A013 +++<br>
=C2=A0include/linux/pagemap.h =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A031 +++++++=
<br>
=C2=A0include/linux/radix-tree.h =C2=A0 =C2=A0 | =C2=A011 +++<br>
=C2=A0include/linux/vm_event_item.h =C2=A0| =C2=A0 4 +<br>
=C2=A0include/trace/events/filemap.h | =C2=A0 7 +-<br>
=C2=A0lib/radix-tree.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A094 ++++++++++++++++++--<br>
=C2=A0mm/Kconfig =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 | =C2=A011 +++<br>
=C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 | 196 ++++++++++++++++++++++++++++++++---------<br>
=C2=A0mm/huge_memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 1=
47 +++++++++++++++++++++++++++----<br>
=C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 3 +-<br>
=C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A040 ++++++++-<br>
=C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0| 125 ++++++++++++++++++++------<br>
=C2=A0mm/vmstat.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0 5 ++<br>
=C2=A025 files changed, 779 insertions(+), 108 deletions(-)<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.8.4.rc3<br>
<br>
</font></span></blockquote></div><br></div>

--047d7bd6ac72543ed004e72a1d1a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
