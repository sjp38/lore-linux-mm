Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B34D96B00C8
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 17:09:16 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 7 Jan 2011 17:07:06 -0500
Subject: [RFC][PATCH 2/2] Make watermarks tunable separately
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A298@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

This patch introduces three new sysctls to /proc/sys/vm:
wmark_min_kbytes, wmark_low_kbytes and wmark_high_kbytes.

Each entry is used to compute watermark[min], watermark[low]
and watermark[high] for each zone.

These parameters are also updated when min_free_kbytes are
changed because originally they are set based on min_free_kbytes.
On the other hand, min_free_kbytes is updated when wmark_free_kbytes
changes.

By using the parameters one can adjust the difference among
watermark[min], watermark[low] and watermark[high] and as a result
one can tune the kernel reclaim behaviour to fit their requirement.

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 Documentation/sysctl/vm.txt |   37 +++++++++++++++
 include/linux/mmzone.h      |    6 ++
 kernel/sysctl.c             |   28 +++++++++++-
 mm/page_alloc.c             |  109 +++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 179 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index e10b279..674681d 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -55,6 +55,9 @@ Currently, these files are in /proc/sys/vm:
 - stat_interval
 - swappiness
 - vfs_cache_pressure
+- wmark_high_kbytes
+- wmark_low_kbytes
+- wmark_min_kbytes
 - zone_reclaim_mode
=20
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
@@ -360,6 +363,8 @@ become subtly broken, and prone to deadlock under high =
loads.
=20
 Setting this too high will OOM your machine instantly.
=20
+This is also updated when wmark_min_free_kbytes changes.
+
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
 min_slab_ratio:
@@ -664,6 +669,38 @@ causes the kernel to prefer to reclaim dentries and in=
odes.
=20
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
+wmark_high_kbytes
+
+Contains the amount of free memory above which kswapd stops reclaiming pag=
es.
+
+The Linux VM uses this number to compute a watermark[WMARK_HIGH] value for
+each zone in the system. This is also updated when min_free_kbytes is upda=
ted.
+The minimum is wmark_low_kbytes.
+
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+wmark_low_kbytes
+
+Contains the amount of free memory below which kswapd starts to reclaim pa=
ges.
+
+The Linux VM uses this number to compute a watermark[WMARK_LOW] value for
+each zone in the system. This is also updated when min_free_kbytes changes=
