Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DD94C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20FD82082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="b3fuWxEO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20FD82082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5207A8E0005; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CEE48E0001; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 395058E0006; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C2288E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:05 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id a13so3721063ybm.5
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=kCXO9rx8qOusGbwvvp17XdLWBHnoN1MLRiVuXsE4x/U2ZCLxJR8WhRWeJqrH8OP7eZ
         ghczb08ej1m8yybMMJ6qNkIVEAmRqEmtfvlshd/vF6OQmoR3D2qVl2O06wS2q25/G6cw
         4z/iJZ3g6P045/sjtygrsxBs5SuiR5wst3vyitSBYyPmnfyOLzNDadSxy0oAhcKYGhlP
         +V2KDEiFqAsifD2NTtDqtwZYD6pin78r5XklGvNauvUT0qHTFR6pb6yUfaGz4NK93+zG
         0l9oKDeb5Z/7tKOCAO7q/2WZwqVSfLeEwPqVwtTgsUWtnfHn8AgsNWzIJZIPMKt6lAAX
         ibnA==
X-Gm-Message-State: APjAAAX4OICJWxBdF9d8KX5hvou9WBuNbiz/V9M58B1aiQZslAuz6sl1
	Z5o/MwXjUu8Id/IJyy0Q9nW3DX50TSCe9F9m5Qs1NXZLOQNosS+vXnmBsXjlrGV4kiXmp0vfVHC
	hye0vpijsdiPc6KTErfjiNUckhd1SxjT3QabxOEOBpHqoZwNy6ExhTleXPLJKF8R2eA==
X-Received: by 2002:a81:1390:: with SMTP id 138mr54800589ywt.68.1561064044799;
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5NEK1oQSGN1XykPi0PboZEnw7r+I/3C4ZPx2QNk9gvqxCilJ/pxJTy6eITncqlzllaIuD
X-Received: by 2002:a81:1390:: with SMTP id 138mr54800569ywt.68.1561064044261;
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064044; cv=none;
        d=google.com; s=arc-20160816;
        b=Kjg/PLZGWE6nYZTWaibxhSDlpsVsKMDfWBP4tdV8y1qd68daN8S3G7O7Eb+Q1gn2Gs
         nrj2pKanRBPW1RkiyJvO5XU33+u8Esmb2zjSogMTdN133CJyUc0oJqBZAAUd367B7tgJ
         b/7kDMCe23pSkcRUAW25kW37/JBuOSG58kuPZcfXDzIjcBbzvdVktLpMdNU/P7fxJGwL
         XED4cstWuO2f4NDq/wrk8CUWKSi4POeTrnQKmEbn90iLnqQ8kJZCwEpdV24z4yBkDQE9
         6sUm9aYWpgcdznnOgCBlSa1uka2I3Lt2JH+IfCMMr8Dbhf4THIGGQFegADsEq5suSQBL
         z0Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=cg9LUJlo1R1Z6mXYecAg/OmdHF0aVIzJCmWY9Xuyw6AnObF8/GSgwAPcgOoZSOL4rw
         +/0nJXyggC582niMKro0mL79gF6ezQ93NqXT1QgxcWsO+u+ynHfJWHBnsuxvGq3FG0UT
         J1wPK7eNrCr3VYRvMMgUot0hMFk+Bl2/eJ4+xA2TO5pXyT7iX7oynIqh1s2PhF5nHiCC
         yXFgtMBkEp8ZTT9CKVCqgpy/euNIHLOvwXDBfBfaoXpCX9bUqq/BRaZlg66HNAtsCtdd
         QxyoaGM74eQzU5oKCaGm5AEWyzLhT7f4DdxUYwj5BQehpvlh/LqZOV2QeR8959dqhQO2
         9ERg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=b3fuWxEO;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b188si226585ywh.113.2019.06.20.13.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=b3fuWxEO;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKs2vV010773
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
 b=b3fuWxEO2bh8EURL6LgbdwtTE0On0VONM5U8+/w2EiFEQLS9oOFpgcdCbTuOe5hPfUgz
 kX/6nUK8e79VK9unMApm+cqPvb8ZTUgxxa3bWBBZOu1nadIBd17jpOUIEKSHA+fcuzZM
 Xo1So6jIa9/E94+wKRc2OB4oh0s9UJpjX60= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8aj31pm6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:03 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 13:54:02 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6532D62E2A35; Thu, 20 Jun 2019 13:54:01 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 3/6] mm,thp: stats for file backed THP
Date: Thu, 20 Jun 2019 13:53:45 -0700
Message-ID: <20190620205348.3980213-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620205348.3980213-1-songliubraving@fb.com>
References: <20190620205348.3980213-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200150
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for non-shmem THP, this patch adds two stats and exposes
them in /proc/meminfo

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 fs/proc/meminfo.c      | 4 ++++
 include/linux/mmzone.h | 2 ++
 mm/vmstat.c            | 2 ++
 3 files changed, 8 insertions(+)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e17c17..bac395fc11f9 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -136,6 +136,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
 	show_val_kb(m, "ShmemPmdMapped: ",
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
+	show_val_kb(m, "FileHugePages: ",
+		    global_node_page_state(NR_FILE_THPS) * HPAGE_PMD_NR);
+	show_val_kb(m, "FilePmdMapped: ",
+		    global_node_page_state(NR_FILE_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394cabaf4e..827f9b777938 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -234,6 +234,8 @@ enum node_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
+	NR_FILE_THPS,
+	NR_FILE_PMDMAPPED,
 	NR_ANON_THPS,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16ca6996..6afc892a148a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1158,6 +1158,8 @@ const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
+	"nr_file_hugepages",
+	"nr_file_pmdmapped",
 	"nr_anon_transparent_hugepages",
 	"nr_unstable",
 	"nr_vmscan_write",
-- 
2.17.1

