Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A873C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C31C0227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qngBAmzE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C31C0227BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E97DE6B0008; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4B666B000A; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D37B76B000C; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B09C06B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:38:24 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id 77so34156696ywp.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=eoG9KyvLhlYE00FluZL3g7CcZO+Du9sWRL0eYJzs+KHvNQsw5h7q2hpkfKMjrrVYJ+
         IIg7HZ4TeLPGVsYb0jzWY0XzTc/3wTbGm8q5m2+xF6UsRm57J7SPa49jUENsbTpZaw5g
         JMPCfkEZSbYWS8q/5y4fsJoRGoABm+3i3B0QSQfHiejd9DDj72ZPHT6obzlhJ1PFiZZb
         XHVWSYKAkBwnnPhbWYCvV2ePEZjyHg4jxBpYpX0Qx00gBYt+tCgvLctaQh/RL3Y8nmXJ
         7JP6WQz0KI4gWeobVXcAOp7Kd460YvrZQi6G+leggHgqBvODBcpZtC8Mapm69Km+A2SY
         tbBw==
X-Gm-Message-State: APjAAAWY8VHc4i92cjcydWvokuHhCeeApDaH+gBE4aUABCfs+MpgmTuu
	Nf/hnRHAoz4RWb4lvr8vda56Us7MNIPoM4OSm6iRlEIDOPMAH4CYZrrcK/4nTQ6roce0rf2RL+e
	Q8UzWTaOmB4VtZPzcVoscck32WMbRGHZyaY3/n7LTrjerfHf2/Ffl5RUqFcXfx9CkzA==
X-Received: by 2002:a25:830e:: with SMTP id s14mr50083353ybk.500.1563957504449;
        Wed, 24 Jul 2019 01:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3/k+eheJPZVfFPWrI6d6YdfV5EIQMjbyMQMjXUFkOielZyfR5KZ347hKo+q0MdnA24Rbc
X-Received: by 2002:a25:830e:: with SMTP id s14mr50083338ybk.500.1563957503923;
        Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563957503; cv=none;
        d=google.com; s=arc-20160816;
        b=LJexCS7xzPBJiRU9VX7tSV8rhunonlZcfHslo0w6T0jjW84CrL5fposg+G+wEa2d0m
         0sGJDvdnV1KVwn4SKjWsa42ESDFFw/OmLskLBSpg7eRpi5oHGcZb0zKtqX1s8tvpWqdr
         eSQuuGNTQHg/IrWzY7ocn5V7P7N/k9FlerWLnq5+x6yxBpB4H4k8NFte5JdIBQiT5wcf
         gR+hNem12Ow+5190pdPpsQ0IB429MLj7gsKha+uUO6NTC4/6TTihadawA+fScgX0plJG
         JMgZE0K3Q6v0DmAUpzTwqGItfSUhO/A8Ji4Y2Hbe7xieeYVQh8EMnP7s9ymuMU9mP/Fj
         3avg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
        b=tuCMjrlbXzrIDjPzWA0tTZzGgEwWDMUypYdykJ886NIozvfK3g1XxTqlWx7N9/jBW2
         hz+UpbJ4QQ63rspKfIJu8nBzuZjLaB89MCjLLhwyiEjK/4V1Urx1327VLmv+fPnFG3a0
         XrMdMQ9VrNi0j7LGl1b1TZu8E0Gyv0z/y6rRsreEOs9dPHP5WJrGx4sKz2Z11+OtvNPV
         ieNT6jjmIAfCcGN5UMaApzcfTlFPcJDAD0cFOUlqFbr8HI0vdlVFmvG9fVCzANc9ddai
         9PZ0Z82s2x7a6BuxWqGKfAIAm/DwkxIcxzpLCdIYGVzBPZdfij+ckcBTcK6MAOq15Aiq
         em+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qngBAmzE;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v193si15184740ybv.496.2019.07.24.01.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:38:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qngBAmzE;
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6O8b4dq028464
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=LjmLHqeEBIcPM1EzxLLHUMjC3IQ3Iyup262DaJYHDoM=;
 b=qngBAmzEIM8Bkk0aumHkSmeqkqIHn9isMrPgNPQrHEQopUf9EC4DxYUdbh+KXlshcbxj
 FYdyMVVl45rhaUkkcDViOP03E6fIQNlLNEbj2mrZKRyft4MB2001HCjqZz6gwTzcj0fe
 YaPxu6TP1bZr+B2nhypi2iiyYr9VheBxxcE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2tx613jw2x-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:38:23 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 24 Jul 2019 01:38:19 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 5009762E30CD; Wed, 24 Jul 2019 01:36:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 1/4] mm: move memcmp_pages() and pages_identical()
Date: Wed, 24 Jul 2019 01:35:57 -0700
Message-ID: <20190724083600.832091-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190724083600.832091-1-songliubraving@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=947 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240097
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch moves memcmp_pages() to mm/util.c and pages_identical() to
mm.h, so that we can use them in other files.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h |  7 +++++++
 mm/ksm.c           | 18 ------------------
 mm/util.c          | 13 +++++++++++++
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..f189176dabed 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2891,5 +2891,12 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int memcmp_pages(struct page *page1, struct page *page2);
+
+static inline int pages_identical(struct page *page1, struct page *page2)
+{
+	return !memcmp_pages(page1, page2);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index 3dc4346411e4..dbee2eb4dd05 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1029,24 +1029,6 @@ static u32 calc_checksum(struct page *page)
 	return checksum;
 }
 
-static int memcmp_pages(struct page *page1, struct page *page2)
-{
-	char *addr1, *addr2;
-	int ret;
-
-	addr1 = kmap_atomic(page1);
-	addr2 = kmap_atomic(page2);
-	ret = memcmp(addr1, addr2, PAGE_SIZE);
-	kunmap_atomic(addr2);
-	kunmap_atomic(addr1);
-	return ret;
-}
-
-static inline int pages_identical(struct page *page1, struct page *page2)
-{
-	return !memcmp_pages(page1, page2);
-}
-
 static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 			      pte_t *orig_pte)
 {
diff --git a/mm/util.c b/mm/util.c
index e6351a80f248..0d5e2f425612 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -783,3 +783,16 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 out:
 	return res;
 }
+
+int memcmp_pages(struct page *page1, struct page *page2)
+{
+	char *addr1, *addr2;
+	int ret;
+
+	addr1 = kmap_atomic(page1);
+	addr2 = kmap_atomic(page2);
+	ret = memcmp(addr1, addr2, PAGE_SIZE);
+	kunmap_atomic(addr2);
+	kunmap_atomic(addr1);
+	return ret;
+}
-- 
2.17.1

