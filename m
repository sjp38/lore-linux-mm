Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E7B4C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 09:53:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBF3A218AF
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 09:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBF3A218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 664246B0291; Wed, 18 Sep 2019 05:53:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EF156B0292; Wed, 18 Sep 2019 05:53:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DB426B0293; Wed, 18 Sep 2019 05:53:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDC36B0291
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 05:53:08 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 93A6E181AC9B4
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:53:07 +0000 (UTC)
X-FDA: 75947578014.07.side19_382965debd22a
X-HE-Tag: side19_382965debd22a
X-Filterd-Recvd-Size: 12233
Received: from wangsu.com (unknown [123.103.51.227])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 09:53:05 +0000 (UTC)
Received: from bogon.wangsu.com (unknown [218.85.123.226])
	by app2 (Coremail) with SMTP id 4zNnewC3vORQ_oFdDGl5AA--.39905S2;
	Wed, 18 Sep 2019 17:52:24 +0800 (CST)
From: Lin Feng <linf@wangsu.com>
To: corbet@lwn.net,
	mcgrof@kernel.org,
	akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: keescook@chromium.org,
	mchehab+samsung@kernel.org,
	mgorman@techsingularity.net,
	vbabka@suse.cz,
	mhocko@suse.com,
	ktkhai@virtuozzo.com,
	hannes@cmpxchg.org,
	linf@wangsu.com,
	willy@infradead.org,
	kbuild test robot <lkp@intel.com>
Subject: [PATCH] [RESEND] vmscan.c: add a sysctl entry for controlling memory reclaim IO congestion_wait length
Date: Wed, 18 Sep 2019 17:51:59 +0800
Message-Id: <20190918095159.27098-1-linf@wangsu.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-CM-TRANSID:4zNnewC3vORQ_oFdDGl5AA--.39905S2
X-Coremail-Antispam: 1UD129KBjvJXoWxtFy3tr43Wry7GrW7Aw17Awb_yoWfKF4kpF
	9rZr1Sva4UJFWfJFZxA3WUJFn5J3s7CFyDtw4UGr1FvryUXFykGwn5CF1UZa48ur1UG398
	tF4qqws5Gr18JFUanT9S1TB71UUUUUUqnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUyG1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVWDJVCq3wA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIE14v26rxl6s0DM28E
	F7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAS0I0E0xvYzxvE52x082IY62kv0487Mc02F4
	0EFcxC0VAKzVAqx4xG6I80ewAv7VCjz48v1sIEY20_Gr4lOx8S6xCaFVCjc4AY6r1j6r4U
	M4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc8vx2IErcIFxwACI402YVCY1x02628vn2
	kIc2xKxwCY02Avz4vE14v_GFWl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8
	GwCFx2IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4
	vE14v26r106r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IY
	x2IY67AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26c
	xKx2IYs7xG6rW3Jr0E3s1lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x02
	67AKxVW8JVW8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU0F_M3UUUUU==
X-CM-SenderInfo: holqwq5zdqw23xof0z/
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This sysctl is named as mm_reclaim_congestion_wait_jiffies, default to
HZ/10 as unchanged to old codes.
It is in jiffies unit and can be set in range between [1, 100], so
refers to CONFIG_HZ before tuning.

In a high-end production environment(all high iops ssds) we found that
CPU iowait spikes a lot as server under memory pressure(a lot of order
2 or 3 pages allocations), but in the meantime IO pressure is nearly
none, await and util% seen by iostat are quite healthy.

In direct and background(kswapd) pages reclaim paths both may fall into
calling msleep(100) or congestion_wait(HZ/10) or wait_iff_congested(HZ/10=
)
while under IO pressure, and the sleep length is hard-coded and the later
two will introduce 100ms iowait length per time.

So if pages reclaim is relatively active in some circumstances such as hi=
gh
order pages reappings, it's possible to see a lot of iowait introduced by
congestion_wait(HZ/10) and wait_iff_congested(HZ/10).

The 100ms sleep length is proper if the backing drivers are slow like
traditionnal rotation disks. While if the backing drivers are high-end
storages such as high iops ssds or even faster drivers, the high iowait
inroduced by pages reclaim is really misleading, because the storage IO
utils seen by iostat is quite low, in this case the congestion_wait time
modified to 1ms is likely enough for high-end ssds.

Another benifit is that it's potentially shorter the direct reclaim block=
ed
time when kernel falls into sync reclaim path, which may improve user
applications response time.

All ssds box is a trend, so introduce this sysctl entry for making a way
to relieving the concerns of system administrators.

Tested:
1. Before this patch:

top - 10:10:40 up 8 days, 16:22,  4 users,  load average: 2.21, 2.15, 2.1=
0
Tasks: 718 total,   5 running, 712 sleeping,   0 stopped,   1 zombie
Cpu0  :  0.3%us,  3.4%sy,  0.0%ni, 95.3%id,  1.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu1  :  1.4%us,  1.7%sy,  0.0%ni, 95.2%id,  0.0%wa,  0.0%hi,  1.7%si,  0=
.0%st
Cpu2  :  4.7%us,  3.3%sy,  0.0%ni, 91.0%id,  0.0%wa,  0.0%hi,  1.0%si,  0=
.0%st
Cpu3  :  7.0%us,  3.7%sy,  0.0%ni, 87.7%id,  1.0%wa,  0.0%hi,  0.7%si,  0=
.0%st
Cpu4  :  1.0%us,  2.0%sy,  0.0%ni, 96.3%id,  0.0%wa,  0.0%hi,  0.7%si,  0=
.0%st
Cpu5  :  1.0%us,  2.0%sy,  0.0%ni,  1.7%id, 95.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu6  :  1.0%us,  1.3%sy,  0.0%ni, 97.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu7  :  1.3%us,  1.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu8  :  4.3%us,  1.3%sy,  0.0%ni, 94.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu9  :  0.7%us,  0.7%sy,  0.0%ni, 98.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu10 :  0.7%us,  1.0%sy,  0.0%ni, 98.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu11 :  1.0%us,  1.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu12 :  3.0%us,  1.0%sy,  0.0%ni, 95.3%id,  0.3%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu13 :  0.3%us,  1.3%sy,  0.0%ni, 88.6%id,  9.4%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu14 :  3.3%us,  2.3%sy,  0.0%ni, 93.7%id,  0.3%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu15 :  6.4%us,  3.0%sy,  0.0%ni, 90.2%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu16 :  2.7%us,  1.7%sy,  0.0%ni, 95.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu17 :  1.0%us,  1.7%sy,  0.0%ni, 97.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu18 :  1.3%us,  1.0%sy,  0.0%ni, 97.0%id,  0.3%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu19 :  4.3%us,  1.7%sy,  0.0%ni, 86.0%id,  7.7%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu20 :  0.7%us,  1.3%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu21 :  0.3%us,  1.7%sy,  0.0%ni, 50.2%id, 47.5%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu22 :  0.7%us,  0.7%sy,  0.0%ni, 98.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu23 :  0.7%us,  0.7%sy,  0.0%ni, 98.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st

2. After this patch and set mm_reclaim_congestion_wait_jiffies to 1:

top - 10:12:19 up 8 days, 16:24,  4 users,  load average: 1.32, 1.93, 2.0=
3
Tasks: 724 total,   2 running, 721 sleeping,   0 stopped,   1 zombie
Cpu0  :  4.4%us,  3.0%sy,  0.0%ni, 90.3%id,  1.3%wa,  0.0%hi,  1.0%si,  0=
.0%st
Cpu1  :  2.1%us,  1.4%sy,  0.0%ni, 93.5%id,  0.7%wa,  0.0%hi,  2.4%si,  0=
.0%st
Cpu2  :  2.7%us,  1.0%sy,  0.0%ni, 96.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu3  :  1.0%us,  1.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu4  :  0.7%us,  1.0%sy,  0.0%ni, 97.7%id,  0.3%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu5  :  1.0%us,  0.7%sy,  0.0%ni, 97.7%id,  0.3%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu6  :  1.7%us,  1.0%sy,  0.0%ni, 97.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu7  :  2.0%us,  0.7%sy,  0.0%ni, 94.3%id,  2.7%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu8  :  2.0%us,  0.7%sy,  0.0%ni, 97.0%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu9  :  0.7%us,  1.0%sy,  0.0%ni, 97.7%id,  0.7%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu10 :  0.3%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu11 :  0.7%us,  0.3%sy,  0.0%ni, 99.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu12 :  0.7%us,  1.0%sy,  0.0%ni, 98.0%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu13 :  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu14 :  1.7%us,  0.7%sy,  0.0%ni, 97.3%id,  0.3%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu15 :  4.3%us,  1.0%sy,  0.0%ni, 94.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu16 :  1.7%us,  1.3%sy,  0.0%ni, 96.3%id,  0.0%wa,  0.0%hi,  0.7%si,  0=
.0%st
Cpu17 :  2.0%us,  1.3%sy,  0.0%ni, 96.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu18 :  0.3%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu19 :  1.0%us,  1.0%sy,  0.0%ni, 97.6%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu20 :  1.3%us,  0.7%sy,  0.0%ni, 97.0%id,  0.7%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu21 :  0.7%us,  0.7%sy,  0.0%ni, 98.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0=
.0%st
Cpu22 :  1.0%us,  1.0%sy,  0.0%ni, 98.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0=
.0%st
Cpu23 :  0.7%us,  0.3%sy,  0.0%ni, 98.3%id,  0.0%wa,  0.0%hi,  0.7%si,  0=
.0%st

Chagelog:
V1: Fix a compile error reported by kbuild test robot and a checkpatch
error. Also more detailed the background for the commit log of this patch=
.

Signed-off-by: Lin Feng <linf@wangsu.com>
Reported-by: kbuild test robot <lkp@intel.com>
---
 Documentation/admin-guide/sysctl/vm.rst | 17 +++++++++++++++++
 kernel/sysctl.c                         | 10 ++++++++++
 mm/vmscan.c                             | 14 +++++++++++---
 3 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/sysctl/vm.rst b/Documentation/admi=
n-guide/sysctl/vm.rst
index 64aeee1009ca..fbe9a04583ac 100644
--- a/Documentation/admin-guide/sysctl/vm.rst
+++ b/Documentation/admin-guide/sysctl/vm.rst
@@ -837,6 +837,23 @@ than the high water mark in a zone.
 The default value is 60.
=20
=20
+mm_reclaim_congestion_wait_jiffies
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+This control is used to define how long kernel will wait/sleep while
+system memory is under pressure and memroy reclaim is relatively active.
+Lower values will decrease the kernel wait/sleep time.
+
+It's suggested to lower this value on high-end box that system is under =
memory
+pressure but with low storage IO utils and high CPU iowait, which could =
also
+potentially decrease user application response time in this case.
+
+Keep this control as it were if your box is not above case.
+
+The default value is HZ/10, which is of equal value to 100ms independ of=
 how
+many HZ is defined.
+
+
 unprivileged_userfaultfd
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 078950d9605b..5d02f137bdf9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -114,6 +114,7 @@ extern int pid_max;
 extern int pid_max_min, pid_max_max;
 extern int percpu_pagelist_fraction;
 extern int latencytop_enabled;
+extern int mm_reclaim_congestion_wait_jiffies;
 extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
 #ifndef CONFIG_MMU
 extern int sysctl_nr_trim_pages;
@@ -1413,6 +1414,15 @@ static struct ctl_table vm_table[] =3D {
 		.extra1		=3D SYSCTL_ZERO,
 		.extra2		=3D &one_hundred,
 	},
+	{
+		.procname	=3D "mm_reclaim_congestion_wait_jiffies",
+		.data		=3D &mm_reclaim_congestion_wait_jiffies,
+		.maxlen		=3D sizeof(mm_reclaim_congestion_wait_jiffies),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D SYSCTL_ONE,
+		.extra2		=3D &one_hundred,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	=3D "nr_hugepages",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6c5d0b28321..a1eab811772a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -165,6 +165,12 @@ struct scan_control {
  * From 0 .. 100.  Higher means more swappy.
  */
 int vm_swappiness =3D 60;
+
+/*
+ * From 0 .. 100.  Lower means shorter memory reclaim IO congestion wait=
 time.
+ */
+int mm_reclaim_congestion_wait_jiffies =3D HZ / 10;
+
 /*
  * The total number of pages which are beyond the high watermark within =
all
  * zones.
@@ -1966,7 +1972,7 @@ shrink_inactive_list(unsigned long nr_to_scan, stru=
ct lruvec *lruvec,
 			return 0;
=20
 		/* wait a bit for the reclaimer. */
-		msleep(100);
+		msleep(jiffies_to_msecs(mm_reclaim_congestion_wait_jiffies));
 		stalled =3D true;
=20
 		/* We are about to die and free our memory. Return now. */
@@ -2788,7 +2794,8 @@ static bool shrink_node(pg_data_t *pgdat, struct sc=
an_control *sc)
 			 * faster than they are written so also forcibly stall.
 			 */
 			if (sc->nr.immediate)
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				congestion_wait(BLK_RW_ASYNC,
+					mm_reclaim_congestion_wait_jiffies);
 		}
=20
 		/*
@@ -2807,7 +2814,8 @@ static bool shrink_node(pg_data_t *pgdat, struct sc=
an_control *sc)
 		 */
 		if (!sc->hibernation_mode && !current_is_kswapd() &&
 		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
-			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
+			wait_iff_congested(BLK_RW_ASYNC,
+				mm_reclaim_congestion_wait_jiffies);
=20
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed=
,
 					 sc->nr_scanned - nr_scanned, sc));
--=20
2.20.1


