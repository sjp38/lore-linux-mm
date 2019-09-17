Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADB5CC4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 11:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31D71214AF
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 11:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31D71214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wangsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C12756B0003; Tue, 17 Sep 2019 07:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEA726B0005; Tue, 17 Sep 2019 07:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFF406B0006; Tue, 17 Sep 2019 07:58:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0205.hostedemail.com [216.40.44.205])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC576B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 07:58:51 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 34A9C181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:58:51 +0000 (UTC)
X-FDA: 75944266062.05.lamp67_4ce87314e1861
X-HE-Tag: lamp67_4ce87314e1861
X-Filterd-Recvd-Size: 11776
Received: from aliyun-sdnproxy-4.icoremail.net (aliyun-cloud.icoremail.net [47.90.73.12])
	by imf17.hostedemail.com (Postfix) with SMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 11:58:48 +0000 (UTC)
Received: from bogon.wangsu.com (unknown [218.85.123.226])
	by app2 (Coremail) with SMTP id 4zNnewCnreVjyoBdoWhyAA--.30568S2;
	Tue, 17 Sep 2019 19:58:31 +0800 (CST)
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
	linf@wangsu.com
Subject: [PATCH] [RFC] vmscan.c: add a sysctl entry for controlling memory reclaim IO congestion_wait length
Date: Tue, 17 Sep 2019 19:58:24 +0800
Message-Id: <20190917115824.16990-1-linf@wangsu.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-CM-TRANSID:4zNnewCnreVjyoBdoWhyAA--.30568S2
X-Coremail-Antispam: 1UD129KBjvJXoWxtFyDXw45Cr48JF4Dtr4Utwb_yoWfCFy3pF
	yDZr1Sva4UJFWfJFZxA3WUJFn5J3s7CFyDtw4UGr1FvryUXFykKwn5CF1UZa48ur1UG398
	tF4qqws5Gr18JF7anT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9m1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVWDJVCq3wA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJr0_GcWl84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2
	z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1le2I262IYc4CY6c8Ij28IcVAaY2xG8wAqx4
	xG64xvF2IEw4CE5I8CrVC2j2WlYx0EF7xvrVAajcxG14v26r1j6r4UMcIj6x8ErcxFaVAv
	8VW8GwAv7VCY1x0262k0Y48FwI0_Jr0_Gr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48Icx
	kI7VAKI48JM4x0x7Aq67IIx4CEVc8vx2IErcIFxwACI402YVCY1x02628vn2kIc2xKxwCY
	02Avz4vE14v_Gw4l42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8GwCFx2IqxV
	CFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r10
	6r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxV
	WUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IYs7xG
	6rWUJVWrZr1UMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr
	0_Gr1UYxBIdaVFxhVjvjDU0xZFpf9x0JjOrchUUUUU=
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

Signed-off-by: Lin Feng <linf@wangsu.com>
---
 Documentation/admin-guide/sysctl/vm.rst | 17 +++++++++++++++++
 kernel/sysctl.c                         | 10 ++++++++++
 mm/vmscan.c                             | 12 +++++++++---
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/sysctl/vm.rst b/Documentation/admi=
n-guide/sysctl/vm.rst
index 64aeee1009ca..e4dd83731ecf 100644
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
+Keep this control as it were if your box are not above case.
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
index 078950d9605b..064a3da04789 100644
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
+		.extra1		=3D &SYSCTL_ONE,
+		.extra2		=3D &one_hundred,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	=3D "nr_hugepages",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6c5d0b28321..8c19afdcff95 100644
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
@@ -2788,7 +2794,7 @@ static bool shrink_node(pg_data_t *pgdat, struct sc=
an_control *sc)
 			 * faster than they are written so also forcibly stall.
 			 */
 			if (sc->nr.immediate)
-				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				congestion_wait(BLK_RW_ASYNC, mm_reclaim_congestion_wait_jiffies);
 		}
=20
 		/*
@@ -2807,7 +2813,7 @@ static bool shrink_node(pg_data_t *pgdat, struct sc=
an_control *sc)
 		 */
 		if (!sc->hibernation_mode && !current_is_kswapd() &&
 		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
-			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
+			wait_iff_congested(BLK_RW_ASYNC, mm_reclaim_congestion_wait_jiffies);
=20
 	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed=
,
 					 sc->nr_scanned - nr_scanned, sc));
--=20
2.20.1


