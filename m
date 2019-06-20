Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE0A7C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B6C82064B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mNhc/hpX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B6C82064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 259C76B0006; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E45C8E0002; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D3BC8E0001; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCA936B0006
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:28:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so769704pff.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=t4WP0ysVCAWfCLs/z5oz2yIS2tXOX7fKqzTXHhkUjsDhraUvbrXd/4iOMH90y4RK4c
         7kE9l9Vryz+A8JclnN8Ud8R/4CTw1LAYpJFbFh1WvF7VqKM3vAstccDwSmstFSSFBHCH
         RkmWE+ngl44L3fvpAp3kJT5or4XLIKtq/BRqGdSJoDOg+rifv6tOwyTV3Rq0PGM1J8iV
         VsZ40u46KhddodwFT177YeW+VVK3Xe9evnT8Ui9EtrC0+nvXuAfqsEI3hY5dIREXD9dh
         C7IW/3J1MbC0IbLA/0e9RtlgOaHXJqd7PxfilSUjNygaaNI6gAImaNztmHZI+ROvHUGQ
         jgmg==
X-Gm-Message-State: APjAAAXzR8xRCEj7Cb3Pwuj5EwCWKlLujHdjrzsy9PdylBDLPlc8iVWp
	ywOtXv4PIz3bFfC+ghWKt4QMmC49Cf34/U//Eyv+Z1KGbKJcqNltQ4CmFLHuQdue7h4rP5YZYKD
	Q9UYyvSKUxMYIJdgkL0FKEaKBEstZQSQFr8SOQJ8HCjEJG63x01+N5agUqsO9qIFwPg==
X-Received: by 2002:a17:90a:32ec:: with SMTP id l99mr819202pjb.44.1561051691499;
        Thu, 20 Jun 2019 10:28:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3EPC7s1OSoZnDYjae4Gnt4U4lplBFM07DZCVMDcNJydCrLxtqICVJBW3Knnocfqqpjafb
X-Received: by 2002:a17:90a:32ec:: with SMTP id l99mr819152pjb.44.1561051690940;
        Thu, 20 Jun 2019 10:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051690; cv=none;
        d=google.com; s=arc-20160816;
        b=xw3XfoaRq8OO0rZHqhceJ5cDNwgLDHyE6TFFY5PyA5vq34fh3ui3ZKS6XV+1yL04nv
         1+/RBPgk7C29olJP6/mIPZ6EmiJP4GEGsMMF0hvZQyYWlqRcpKd+P/JqQ/jc0wwIsodQ
         5lfKKw+82uB4JB2wtECsyY6buBkdvetoDADOL5vkC3PZBdSzHS+SukuhvNxv7opTrbHw
         W4xrPGsvs9aIAKIvZ/7GHPWOBN59nJGlXWlzz0ilkSODlw1v0447/vHWYx+VDvwVo9GI
         5ZMz7flUCpeG19gtg87PSIhUg8MozPXt2QCJy7YSgPEzZV4ePfwKx7hkEfbdhaOrzY2D
         tWag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=A1fU+O+3pmlsjI/G7D/0whG9z6EAwg5iuo7YRcKWdj3wug63BREYlJOFhH58Q3e8/t
         637oaiPj5RQsrMva6qr5H5/P5OQM8mNOSxo0abF9ZXcAD+PYVyLgj5WXwe9N26HXVkzR
         eJvnZexccT7YN6zG0Ci/PrcTcf9Z97ISZKtSb+bgkAGVlFqhjsrS2jd9hDYOPVVEe0/i
         aaVpzy5pzFnsNt4lO4TtgD8+t+N9mslpFT5ryotcQL+pMSq7sAfs614ptFIzKEbZQs/4
         4zbRXLffh7PEVOq/Oc91h2bP6+uwDmiAVsu4APx9H4SCGsF66021fsngJlFw1R85n+l5
         sIUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mNhc/hpX";
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d31si260043pla.393.2019.06.20.10.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:28:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="mNhc/hpX";
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHJx5W008103
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:10 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=mNhc/hpX80vHQg9u1eg66tZ1YAkihKLtnrLdS9akUfCSDf3mAo2t9I8+6iKvzcaYbn4d
 vtenrW+VwtMHK0eiP7mAQ+1pGOHXf8rUFN61PepQBZWXnc84HnHgHUoU/qsmHv3SOBVw
 yd19T7EPogSnkyo5Zc852usFjK6wP00kdp4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t85v8hthb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:10 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 10:28:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id AC6B762E2004; Thu, 20 Jun 2019 10:28:08 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 2/6] filemap: update offset check in filemap_fault()
Date: Thu, 20 Jun 2019 10:27:48 -0700
Message-ID: <20190620172752.3300742-3-songliubraving@fb.com>
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
 mlxlogscore=804 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
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

