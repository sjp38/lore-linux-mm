Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C20B8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:37:56 -0500 (EST)
Received: by iwl42 with SMTP id 42so6552872iwl.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:37:54 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 2 Mar 2011 16:37:54 +0800
Message-ID: <AANLkTik7MA6YcrWVbjFhQsN0arR72xmH9g1M2Yi-E_B-@mail.gmail.com>
Subject: [RFC PATCH 0/5] Add accountings for Page Cache
From: noname noname <namei.unix@gmail.com>
Content-Type: multipart/alternative; boundary=90e6ba2121d73bb16f049d7bd4f0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

--90e6ba2121d73bb16f049d7bd4f0
Content-Type: text/plain; charset=ISO-8859-1

[Summery]

In order to evaluate page cache efficiency, system admins are happy to
know whether a block of data is cached for subsequent use, or whether
the page is read-in but seldom used. This patch extends an effort to
provide such kind of information. We adds three counters, which are
exported to the user space, for the Page Cache that is almost
transparent to the applications. This would benifit some heavy page
cache users that might try to tune the performance in hybrid storage
situation.

[Detail]

The kernel would query the page cache first when it tries to manipulate
file data & meta data. If the target data is out there, this is called
page cache _hit_ and will save one IO operation to disk. If the target
data is absent, then the kernel will issue the real IO requests to the
disk, this is called page cache _miss_.

Two counters are page cache specific, that is, page cache _hit_ and
_miss_. Another counter named _readpages_ is also added because the
kernel relys on the readahead module to make the real read requests to
save future read IOs. The _readpages_ is supposed to give more
information about kernel read operations.

The different combinations of three counters would give some hints on
kernel page cache system. For example, nr(hit) + nr(miss) would means
how many request[nr(request)] the kernel ask for in some time.
nr(miss)/nr(requests) would produce miss ratio, etc.

There is a long request from our operation teams who run hapdoop in a
very large scale. They ask for some information about underlying Page
Cache system when they are tuning the applications.

The statistics are collected per partition. This would benifit
performance tuning at the situation when the hybrid storage are applied
(for example, SSD + SAS + SATA).

Currently only regular file data in the page acche are collected.[meta
data accounting is also under consideration]

There is still much work that needs to be done, but it is better for me
to send it out to review and get feedbacks as early as possible.

[Performance]

Since the patch is on the one of the hottest code path of the kernel, I
did a simple function gragh tracing on the sys_read() path by
_no-inlining_ the hit function with loop-reading a 2G
file.[hit/miss/readpages share virtually the same logic]

1)first read a 2G file from disk into page cache.
2)read 2G file in a loop without disk IOs.
3)function graph tracing on sys_read()

This is the worst case for hit function, it is called every time when
kernel query the page cache.

In the context, test shows that sys_read() costs 8.567us, hit() costs
0.173us (approximate to put_page() function), so 0.173 / 8.567 = 2%.

Any comments are more than welcome :)

-Yuan

--------------------
Liu Yuan(5)

x86/Kconfig: Add Page Cache Accounting entry
block: Add functions and data types for Page Cache Accounting
block: Make page cache counters work with sysfs
mm: Add hit/miss accounting for Page Cache
mm: Add readpages accounting

 arch/x86/Kconfig.debug |    9 +++++++
 block/genhd.c          |    6 ++++
 fs/partitions/check.c  |   23 ++++++++++++++++++
 include/linux/genhd.h  |   60
++++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c           |   27 ++++++++++++++++++---
 mm/readahead.c         |    2 +
 6 files changed, 123 insertions(+), 4 deletions(-)

--90e6ba2121d73bb16f049d7bd4f0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

[Summery]<br><br>In order to evaluate page cache efficiency, system admins =
are happy to<br>know whether a block of data is cached for subsequent use, =
or whether<br>the page is read-in but seldom used. This patch extends an ef=
fort to<br>
provide such kind of information. We adds three counters, which are<br>expo=
rted to the user space, for the Page Cache that is almost<br>transparent to=
 the applications. This would benifit some heavy page<br>cache users that m=
ight try to tune the performance in hybrid storage<br>
situation.<br><br>[Detail]<br><br>The kernel would query the page cache fir=
st when it tries to manipulate<br>file data &amp; meta data. If the target =
data is out there, this is called<br>page cache _hit_ and will save one IO =
operation to disk. If the target<br>
data is absent, then the kernel will issue the real IO requests to the<br>d=
isk, this is called page cache _miss_.<br><br>Two counters are page cache s=
pecific, that is, page cache _hit_ and<br>_miss_. Another counter named _re=
adpages_ is also added because the<br>
kernel relys on the readahead module to make the real read requests to<br>s=
ave future read IOs. The _readpages_ is supposed to give more<br>informatio=
n about kernel read operations.<br><br>The different combinations of three =
counters would give some hints on<br>
kernel page cache system. For example, nr(hit) + nr(miss) would means<br>ho=
w many request[nr(request)] the kernel ask for in some time.<br>nr(miss)/nr=
(requests) would produce miss ratio, etc.<br><br>There is a long request fr=
om our operation teams who run hapdoop in a<br>
very large scale. They ask for some information about underlying Page<br>Ca=
che system when they are tuning the applications.<br><br>The statistics are=
 collected per partition. This would benifit<br>performance tuning at the s=
ituation when the hybrid storage are applied<br>
(for example, SSD + SAS + SATA).<br><br>Currently only regular file data in=
 the page acche are collected.[meta<br>data accounting is also under consid=
eration]<br><br>There is still much work that needs to be done, but it is b=
etter for me<br>
to send it out to review and get feedbacks as early as possible.<br><br>[Pe=
rformance]<br><br>Since the patch is on the one of the hottest code path of=
 the kernel, I<br>did a simple function gragh tracing on the sys_read() pat=
h by<br>
_no-inlining_ the hit function with loop-reading a 2G<br>file.[hit/miss/rea=
dpages share virtually the same logic]<br><br>1)first read a 2G file from d=
isk into page cache.<br>2)read 2G file in a loop without disk IOs.<br>3)fun=
ction graph tracing on sys_read()<br>
<br>This is the worst case for hit function, it is called every time when<b=
r>kernel query the page cache.<br><br>In the context, test shows that sys_r=
ead() costs 8.567us, hit() costs<br>0.173us (approximate to put_page() func=
tion), so 0.173 / 8.567 =3D 2%.<br>
<br>Any comments are more than welcome :)<br><br>-Yuan<br><br>-------------=
-------<br>Liu Yuan(5)<br><br>x86/Kconfig: Add Page Cache Accounting entry<=
br>block: Add functions and data types for Page Cache Accounting<br>block: =
Make page cache counters work with sysfs<br>
mm: Add hit/miss accounting for Page Cache<br>mm: Add readpages accounting<=
br><br>=A0arch/x86/Kconfig.debug |=A0=A0=A0 9 +++++++<br>=A0block/genhd.c=
=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0=A0 6 ++++<br>=A0fs/partitions/check.c=
=A0 |=A0=A0 23 ++++++++++++++++++<br>=A0include/linux/genhd.h=A0 |=A0=A0 60=
 ++++++++++++++++++++++++++++++++++++++++++++++++<br>
=A0mm/filemap.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0 27 ++++++++++++++++++=
---<br>=A0mm/readahead.c=A0=A0=A0=A0=A0=A0=A0=A0 |=A0=A0=A0 2 +<br>=A06 fil=
es changed, 123 insertions(+), 4 deletions(-)<br>

--90e6ba2121d73bb16f049d7bd4f0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
