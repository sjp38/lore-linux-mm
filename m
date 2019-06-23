Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2540AC4646B
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4F22208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DQH6Z5J1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4F22208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 185EA6B0006; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10FEE8E0002; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5168E0001; Sun, 23 Jun 2019 01:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADC796B0006
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k136so173716pgc.10
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=iRj7q6HjSvGP+FFXO9kK02rWbLxt30EzSimsM4GbPmKm0qk+G0CgLjA69pEqKODNKU
         zaKrXgPJ6Xy6U/D+RIwonb2ouFSZKRWc4orGghJL3OgNHUa4Qc+FRuZ3qTz53RvgfLqr
         SBuVVAviid0PUzJwXIODuw+xCVwDEKtqsA7kMFXVYuPb29ZY/BJal/lr9xvvU8kpDGuO
         iHEF5quEDo1Ku7W5eL4l+57woP0x791VxHR/Gd7szLjHzbqkT6IlBE2P8IHnW30p+jIL
         ELamYHoyJ2APsYwT6k1iDjTvGXJCcTQRQXCJkw5zXX2+ApPds3wTP0PwVcRU6MemYljF
         4y9A==
X-Gm-Message-State: APjAAAUESfY+zPawcD6bW9WlsdTF7xNLCNcNdxM8TaZYL60U/Qprgx3B
	3fVRohjv+mT7kbqLJA0QnNEc0A2LEqNSPE15fBbUEf6wgtgbfxLww9hGTFIb7YQwtMQPy6eu57E
	V+IeIdUYrUhAH8uTEM8nFbWEpLnOgIEpqCWqnm2Fw3/6UCw5v5TK5+RmJSxLu6YYqjA==
X-Received: by 2002:a17:90a:2446:: with SMTP id h64mr17697202pje.0.1561268881278;
        Sat, 22 Jun 2019 22:48:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwlrS8LMuomlNq4rfU1D8wxnfhhYWlSZw1+f5Tgev46a65BTizgJ1khyGein2uoy8A0iN+
X-Received: by 2002:a17:90a:2446:: with SMTP id h64mr17697163pje.0.1561268880711;
        Sat, 22 Jun 2019 22:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268880; cv=none;
        d=google.com; s=arc-20160816;
        b=ir8KBdOgIXh9XZ00YGQyED9Au5nyWFiRg1/Fs3VmhoET0ACHqghQni2tJLgjO49srK
         47wYGlEtMEkTIdDZ6Y93nWAQxzxlcwkudnD2yKumDUqaOveG0j7+cwkB51z+X+Pdg/Zg
         RWXQkWiOjKHlHHpjPBkPqqIfMlux770AzfckyWbYK/6Mmb22JmWGcwOQJEO9ZkYBjVBK
         sVEyDJGIJ8SgbN1FJr2UmSYzm5BBfFzNID5tX/FFcX7hjxtjFNhOcjCGXj6JwlJmKPde
         zOJogZwkaTv0xUKEklFMict4KkcvFl9ib+S63jIsw3qY9KMbRgGVujk7CnRjiqMWIMqO
         L3DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=cs5tigbiFa9LVHqEfFJyBmuh0Wk4ChjIuC1FjqT7+2Ixon+usVe+0rDF1levBU3Pqk
         gO8K2DZ5BgaEbZZV7+MiQowhVjTlmSEFxV00m/3w6dnq55SacI3SBXJQtlHvffCMsfXw
         pzfc2B5V/uHsli9MOxqSycNeCV3Z/JvKCAOny6R79kGTRkyXyu4u5OmPHGYoa8fcUjkB
         CLNuiAWRdy2zCRHsg76akxsQUXAS8xsvRFa6NBUNixKUccriUXwe7gT/EGejQJ+IayQz
         MSwaLXYpZcmO8Uz0Ghok3cujuddP+VnfrPsbSUwGfGskJ0dY07MJYSC4/e8M0wehvvJr
         Y7Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DQH6Z5J1;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 31si2650681pld.245.2019.06.22.22.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DQH6Z5J1;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5gg64018602
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=DQH6Z5J1ftaDDjyPugAGXH8mrN4pGG+P0POCXuezd2+btjU0ZmyPv3fxqwXt474rDpmN
 Q5RWGFCat0V9LnDwrjwR6zYCSZT9+WyArOkNcGiupUH1KzeRSTGPivyhEo0ZTIMBbzr6
 RWAWn9ar2sFekaFl4aAO4TZLL7+mRg3uMqE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9kmja0xp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:47:58 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1599262E2D94; Sat, 22 Jun 2019 22:47:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v7 2/6] filemap: update offset check in filemap_fault()
Date: Sat, 22 Jun 2019 22:47:45 -0700
Message-ID: <20190623054749.4016638-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054749.4016638-1-songliubraving@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=803 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With THP, current check of offset:

    VM_BUG_ON_PAGE(page->index != offset, page);

is no longer accurate. Update it to:

    VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index f5b79a43946d..5f072a113535 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2522,7 +2522,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
-- 
2.17.1

