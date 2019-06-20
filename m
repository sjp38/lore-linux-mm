Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C80C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F1B2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="G9H7o7hR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F1B2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BAAB6B000A; Thu, 20 Jun 2019 13:28:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36D928E0002; Thu, 20 Jun 2019 13:28:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 198498E0001; Thu, 20 Jun 2019 13:28:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECF136B000A
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:28:18 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f11so3687672ywc.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=SkHITzS2mKkMJkoUi4xNLmQIhW9SCtar4JsUiZp5wkSykA9eOL08TioA1bB1QRvXB2
         nBWGV7iz/2tewrFJ5BBgG9lHTrTi2yz9rNJ0J48spwxbIEKG5T4xnMsse7YUrrVZt4Rw
         ovIeVCsMIovfLvFtTgXkycRgYK7r+Zddu2piet82cWmU9SBigIW9UMTFw14gvTa5G5lg
         IVQ6otdmRPzuG6XXwiGJRgIdUhLPBpX7NivG00BJ8i2uAW43+175yBsvpbnU8PayLFcj
         OJuRytLe+Bvxl11gk7Yq7QZ+bxC/joEht7z7aB6yhYiyDRixYi+S8mFWcFaWj0rjJ3bu
         ohGw==
X-Gm-Message-State: APjAAAWwvmoAsGUNgul3thOvzKJe7g/dfpmKwQIWuWulMZsLEYDNWXAC
	jr4n2l9XdejaLQU1xhikJpweRCp53mJmUGmMbkFokEsB6AMG39//m0Rgn6i3xkVpatCcAVPfxYM
	KKDUcDVM5od5FAHcKiKcfx5dGR+9Xas3IrCbgGZJ0J87zZx94CZVFwBV/owwV/qy9NA==
X-Received: by 2002:a25:bd91:: with SMTP id f17mr66195604ybh.509.1561051698738;
        Thu, 20 Jun 2019 10:28:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQWO4oCzGfR6l7kHahpZFdkbc58lW4qeQNtA0B+blZCiDE65yRxQqUtvGRLHaZsVQaeXjg
X-Received: by 2002:a25:bd91:: with SMTP id f17mr66195573ybh.509.1561051697991;
        Thu, 20 Jun 2019 10:28:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051697; cv=none;
        d=google.com; s=arc-20160816;
        b=nh8qcKqnBcS81QOJIXUeJSzjpQ6KxOPvDe37cYE0kWVLaJ6t/KcM59yZZVhisE+688
         kYyAPLKjCnEXoBZoG/oZtOIRsAKWUO8Q8nJwcCPkWNv6Eo6xGhDCNS86fX277Z7RRXXt
         /7cC5C2Tta1o+BVdjqToW8qFP9v1HZxIyRLtv76zx9//waRWyiPVKdBdLlpy4K3uDy0F
         PU4tlgR0OBNU9KzTVQEXR331apYCb0+Ztiw3NxfCp/hRhtwqedv3XgHwF4P7LFSidzAn
         pjYUBqNhSkQBYluZrNEwHBKUJCRYYVS7RAnxN/O2I4km/TmBQYgngFysFojEd72k0qWo
         Mkqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
        b=ef7OXXYKi+pE6yul03GyIWlTQ3L7JCmk+UGnA0g6Ce5WyrzOezyRzRMouzJsANWpNn
         8AyH7EGFumLomaNsu6NJgbNS9BAFlGTp+lu3cbSLYyrjvmEA4PFICtJgu7+KKOIy4Ix0
         LeqRy1kGFleFUqedJIYRqznFITpm0Uh/f3LFwvrsNlYC4z9srsgduwaEk+EDWyqTQksx
         +vNsWEMaOWM/6SRAxwRrDuvp/IJ+awHxxBHdrw2U/MLzdR5L9ujEak/h9qXKMwMx243E
         MGBKN8mociVN7Fne3rMJDtVpbGi57vIFJYPx9LKShcLu3leYPJJtYQUpHIAHCryq9RRK
         3dKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=G9H7o7hR;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 187si28265ybt.401.2019.06.20.10.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:28:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=G9H7o7hR;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHJt5N023614
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=iFz1RdjWCbrw1b7w4eZ5iGWyb2zDfKg3QSt6me6ZtqE=;
 b=G9H7o7hRRDhToLUjiPC/9weezLUab7QuK3QTMtXgsg9vrzVqnCDbKhxv2O/DIU02paLi
 2TpfVbB7HWcJjKVQRtAAIEFpcx6M3hkd5lRUkTTpirzoYnRbK+cjeHAj4lKQorJoq7dT
 igpKuTPymnTsZ1nU4z0RxZDtoZ72UeUc1Pw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8aj310br-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:17 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 10:28:13 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E4F3762E2004; Thu, 20 Jun 2019 10:28:11 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 3/6] mm,thp: stats for file backed THP
Date: Thu, 20 Jun 2019 10:27:49 -0700
Message-ID: <20190620172752.3300742-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620172752.3300742-1-songliubraving@fb.com>
References: <20190620172752.3300742-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
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

