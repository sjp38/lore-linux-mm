Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E165AC48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A19620652
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="BeRNQIsv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A19620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3236A8E0003; Thu, 20 Jun 2019 16:54:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4968E0001; Thu, 20 Jun 2019 16:54:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8A98E0003; Thu, 20 Jun 2019 16:54:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCDC38E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w14so2307482plp.4
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=qhxqNETnQd4xHerE8VwMjRO5tytvT/aQOrEbN4Ede3ILqbRu34Esby2XHXwxhxPuuL
         5g4PDvaj9TbemywCoEPLT6Ic/GTL3ur+NJTOUAyFEtiHTmR5hSD+D3ujfUeL8bcy3v7o
         LbEELb+vUOQOXkWLmb4WE3RpnfddrP0XiYJ1JToKwi25PTZiT/EAcjHpdXDyelc+Fp5g
         sc9OuTCyaKc2ik4Q9Fpf2HxbJmRXBnlbIbP+tfeANtyX0QcVbote7SiblHOJ5sk7/5Cm
         1AB9vBYYSCuGFJmi0WSRPc8HcKhlPGIiT9e8vIzDcasTZRl3aigmFMlgUvhYeUuLOzxF
         ZIgg==
X-Gm-Message-State: APjAAAVc/eLGqargYfNxUvLrjFvUGq41xOke5u+Zv4LFL2IvaunqDtMO
	FCbZWDFAZFlHpSyPBxOappFlnRL+PTA2i4dxiIPYcVvqJpxTZzz3Tq93I6IGyVVbgAmRT0rS8U6
	q4yix6+LDAEgSXXMvAll25admW6Xqd7bxWx/yvUr6+nfxBZaM/fk/MqHBnpaBZInVmw==
X-Received: by 2002:a17:90a:3548:: with SMTP id q66mr1651587pjb.17.1561064042568;
        Thu, 20 Jun 2019 13:54:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxf0Ea+Y9k6XtA9U5evz5XK/txhUSyc6eDjXbvA1EOIeFlAjQe+q1SvDoTf/YOmItDrcVcC
X-Received: by 2002:a17:90a:3548:: with SMTP id q66mr1651557pjb.17.1561064041981;
        Thu, 20 Jun 2019 13:54:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064041; cv=none;
        d=google.com; s=arc-20160816;
        b=zu/a4RaYZRzkEuOiO8SFDxxkSx+SWcNHWFsJhdToYA2xii5biSCsjqnqHME2VuHk2t
         JqqzjVBApK5GT4x+Ed2ZAnW/QLF/28AW77Vs+MOWHW+9tuzi9MA3/t+jzObbe8KCIppy
         cHbMGamap+AAkdyUZjWIr/ZXeAbzSxhLjAIK0Z1vcVz6UQeexBKNXHyQCcyqxW2nUaE/
         u4K55lBQzUgzwdrD4QQU286VOlbBCiFi0Ef4nJnLch9LvWzKN6tWGWu2FcI3d96jfppK
         d1uSijleLmfKnfcPfwWxnEOfS4/PT5669aDF/faK/T1/Cuii17cQkTXk3IPToByP/m36
         3BMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=Oy8HHetMzK1DaNligOZ9Lz/BcWzhpo1DXMsTCRYxVSYEajlw29WnvaG/7bD6IRBU4L
         ypFHb8M79CYx4gyZPwFUB7g4KpHndLPKWjIrPe2gaA65tzNnknm2dkOKkBiP3eNiNTMa
         MaDn/Pj2vNpIPcuQrBwv2vl9K5lVx0yHl5ua8ozD+h8LgrwhoO8iDHjEW+URG8QHAzcT
         s7Agq8n5uBDBAcU5LIK8eS72vtZTd1hUJZArFIcYWoEkCZwj82Jk/vUHB+0CywQGlRgj
         kdMmgnXadatcqD0aDtYFyYEeQ0H3k5CEGKDXA1Ro6Bi/7t153dY8HxFcr8UMULHjxQ5H
         LSKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=BeRNQIsv;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id cg6si704845plb.350.2019.06.20.13.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:54:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=BeRNQIsv;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKjEIZ003579
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:01 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=BeRNQIsvId5MZwnRm+n67jDrBkFpk7yz6cY5yKEDzWJ+ysSw0utTe7k9FMC430P+EHCe
 a1CTKktxqjcwssvkSTMQLcXFTQ+xxxjN2vKph3qcgzz+FW2iXaPf/2yY8ZmZGFKh9HMo
 MIDVaXYbwzI5sX4PxhXVrqbPOq31dDgXG7Q= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8eru0n9t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:01 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 20 Jun 2019 13:54:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 99C6262E2A35; Thu, 20 Jun 2019 13:53:58 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 2/6] filemap: update offset check in filemap_fault()
Date: Thu, 20 Jun 2019 13:53:44 -0700
Message-ID: <20190620205348.3980213-3-songliubraving@fb.com>
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
 mlxlogscore=808 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200149
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

