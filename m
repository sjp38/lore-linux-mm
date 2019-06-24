Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCE81C48BD3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 821A320679
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="N5uvdv1C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 821A320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CAFD6B0006; Mon, 24 Jun 2019 18:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1C748E0003; Mon, 24 Jun 2019 18:30:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D48838E0002; Mon, 24 Jun 2019 18:30:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8472B6B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:30:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k136so3505859pgc.10
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=Z4QUr2JWt+ZPJEZ0dxC4WKWDOnKU7fGjD+mT1S2kvztPZ+eBxwC8caH5t6VqYlQij3
         w+MOMaSJTUe9lZI/Rh4dUxOoslCq37MX8HCJI4QZh81icbgQNyEuu3Q6Yrdh8UuuLdLG
         SrZdkeb5yaGSjG6DXm0m3r05PfkkEoDw6t70eaG5RQOt4rUuNZBSCwcrtayHx/otcr5Y
         pv6cKZSPh8gN/YLgrYfW53Rhn0ZzNZKEU/sqB81dtB/huwe490wsXcBhyVR0yB7ktstH
         O1hdlo367CKZ4orC13XqDQKB3TWeOME+pxVeztWdBF80NPNXtV6LSdaTRb0eVOdtBAvm
         Y6Ww==
X-Gm-Message-State: APjAAAVe9HJ6Nf7np/9A/QhpPMmKixkjLYWr3l5q+q4uQjojhJC9O4SX
	hcUCaaAclFbm3g0MRD4ujgTd+Ue/dX9QtcZFImz7sCb09lxylVPl3zB/+aQ7SWqgh79eiDlz7MB
	VwPgQb+uHFs4byEzxoJt51o8Cq/P6X/B45IVtcxeYle2U/Gg1E82Qr4KGBRRLNzabtw==
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr28724964pgd.198.1561415400953;
        Mon, 24 Jun 2019 15:30:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+3ESpxNM5pK04K/v4exAT8IeQE5l/q5zuSyVPU4vhaErHGPvt0/cfJQsjC9ax8RW75PdX
X-Received: by 2002:a63:8ac3:: with SMTP id y186mr28724897pgd.198.1561415399994;
        Mon, 24 Jun 2019 15:29:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561415399; cv=none;
        d=google.com; s=arc-20160816;
        b=DFrDdPkR00LOIbxZnWxBtqBSS60H02lFcg8qxWCb0ko3LMSXo/S4lsp8CVvRbgqn55
         A8mYxY9dMPD0EBH9RccJRdW08Jjc/tKeLbWU/NEQ1FInKe0ufmmsJNZColVMIvPkbsXb
         7uEicYv6qpSLD8CQTdQF++Lo5MFp0WVpRT69C1IhxEGfY6aoRJnhLp23VNHJyJHsdSM9
         MOT7P3et6qk+NfYtjeY0YG8Q6rUgrUlNDs/nr7ug6dx7FRz7FvrvTCmjOuvTnXyBW6l1
         QefjCvgBjLAEEUzd4SDSoHL5EC7sPnz0HySAA468d8/asb3IpifYDAhBhlfeSbbLx2PI
         gNIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=kEUffcwddJaElI70kQL5cdqvlYZXGMCATw52kUgi+AzRBTO1kb+FuqAngxnF7OvvdI
         r8LWXWBDHCcUUhe+1HstNRtjQ5IrRgMRIqqVIFDovID52Fgd93UiNYPsaR51bp+PaWw/
         jJ2zuDOfjEI/YvHzqhQgpODP7bv2ycqy3ai4Kc+9P0P6o+Yxzq3lIPJrYLsjxbxz29AZ
         qAsDkJlWMzMsG3a6FLR9a/HuYNgt/Lt6ajU/nYcO6QmwqfSMiqy/rOh26+kl8QvNu6fm
         wZaGZSvloKen+jrRHCcPIYJX5CuoEZ6gpfd24TpmX7VZV28XyoKnXfJkBya4P3ChkacC
         Izzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N5uvdv1C;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t190si11760752pgd.191.2019.06.24.15.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:29:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=N5uvdv1C;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OMJPxF026762
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:29:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=N5uvdv1CGI9JHMSPHd8HFKa/zD9qNyZx+dmMTZHdCM8D2i+k27CqCYDz9eGVOIfss23x
 GNEiOBo6wKidr9D9bdiPSmhcjUPZKm+Rm+Gd38rFkf9Yw0S7HJyVokcVDVe+6OyU09yI
 mW4gqSXIq2/BoxckrA/n76U5Y7/cFYmnwLA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb3v00vqu-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:29:59 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 24 Jun 2019 15:29:58 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 0A56462E206E; Mon, 24 Jun 2019 15:29:58 -0700 (PDT)
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
Subject: [PATCH v8 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Mon, 24 Jun 2019 15:29:46 -0700
Message-ID: <20190624222951.37076-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190624222951.37076-1-songliubraving@fb.com>
References: <20190624222951.37076-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=926 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240176
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, filemap_fault() avoids trace condition with truncate by
checking page->mapping == mapping. This does not work for compound
pages. This patch let it check compound_head(page)->mapping instead.

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index df2006ba0cfa..f5b79a43946d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2517,7 +2517,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		goto out_retry;
 
 	/* Did it get truncated? */
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(compound_head(page)->mapping != mapping)) {
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
-- 
2.17.1

