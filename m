Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCB69C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 899012184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EG0ZXxRI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 899012184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EDD28E0180; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D31D8E017E; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 012138E0180; Mon, 11 Feb 2019 17:46:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA96C8E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:46:08 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 135so963203itk.5
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8MbdNDL3CBMqXq9cKy6Blm5jHVV6AhFQ5tncilAoYP0=;
        b=JDyiBjtvIbD3MDc5zOgsNiYHeFVqnvFpX2cBmrP/R8rC1H3odYfnZ/Zm7hNHNzMYCo
         8JC/fzoA0BaDvWz+y9cbAYuZZefvVi172wQ89gNdbhy/9EfRgzIQGKSnTyE4o1QqNqDk
         A7d0PjK4ehrTCw/gEQZTN+G3jKxiJu7pf0ZgMixKn3aZbMhMl3gLd+uKwCiKX9cWgVlH
         UufX2Qgi75aBHmHvooJXSb0Jd7Jip6uNlxt+dkNd0B7lov4IW5i8GHoxA0SMWFtVRGB3
         HZoDQ+rYaXzvxZQHlzLdPoesvxU7M6yDfldpxOYr0RWvxiNzCta2JMT76PBV9REWJUt3
         A7+g==
X-Gm-Message-State: AHQUAubJQM66RnVDLNTCNEqVq3T2XXba3EUtsOJkRqn9zQhk/rD3EN5C
	wucSkYLHQ+cU3LdhfXvNaBa+0owRo9yoRxlTfxgBGbcPd43Io0ZDwVAdu26kw+0ac/DuhhZ5GlR
	+MzRQ4wWaa6KMdHDls7RrlS0uhtnM2E2dRIQ9pFiFk0VT+wubRrLku+oRWxfJ4vukzg==
X-Received: by 2002:a24:fc86:: with SMTP id b128mr320815ith.93.1549925168596;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYlnk/lYzBbzgnZurBCCP/GA0ckRdmJU5OGIvNVUy7nJS1sAACtXK7r0tXhFPHTAzUcFJrE
X-Received: by 2002:a24:fc86:: with SMTP id b128mr320797ith.93.1549925167944;
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925167; cv=none;
        d=google.com; s=arc-20160816;
        b=nkLgrPfct66Zj4/4Ap0TIO1vaCaTyhO4UGqPpEw2+LhZVsJqtAbrw0yeaW+a7QXicf
         xCXnf3a22pzxFdGIIefHRlxDPF9BPo37SsRnA8loEDwZxXQHjmJCYII8SjjuPcKVLI2j
         030lk3a1RkEEvDxEmTYJngFNll18fnO6fmkT0Ql267ioukVC94Otcw+OW1AVr+26n16+
         O4rvGt9RuQqqDQdXcizsAkYV7mY7r7V/Ny6YBr0hhxwOuR3XmoL67b01EwLWE8r1engU
         GTWqa4hQIqt9KrIfXYCJ5AGWedNqb0qviweEIsHHcI4oBMR9APsJJgfvEggaMcVUeDvW
         TRBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=8MbdNDL3CBMqXq9cKy6Blm5jHVV6AhFQ5tncilAoYP0=;
        b=IzINK4m8/7rVQTVwoKD0RTh1hEu8DPPzbrhRjgB0ZBD9UrNlIYQq4CMCsm8r5P/f7I
         NCj2diqW/lZaJCMRmwCwwFtfQkqWyuAEeCl7mqkBwlTltv7bQ5YXPaygHyeaBZoYToec
         uf5ug8helWDey1HGx1IbcnSDxzI3JogR1llv6c430xAQBnxNecSp+8x5CkvEIJC6B81X
         3H3nfhg/614Z3IHLM4C8WMrn0lDqopSoaPaTQpZkS22Hai4swWtw5lO9OcLC0sOWL52R
         7KEs00M1ak83ghUvYtF75agpinojyJYW9lS+AJrCzLx12oP0EFUXjOgaw71Jdsbo8KaF
         ed/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EG0ZXxRI;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m189si375808ita.78.2019.02.11.14.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EG0ZXxRI;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhV8N079558;
	Mon, 11 Feb 2019 22:44:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=8MbdNDL3CBMqXq9cKy6Blm5jHVV6AhFQ5tncilAoYP0=;
 b=EG0ZXxRIiRONLX+NDCb7AU32LV8AKND2VEChzN77taJ7iEGUuI1z4OoUMuQpnZicawWe
 RXogTQPXYeYaXWw3MQUOEFU7gL1zAD2Ly8l/sIUldPQdQPyEW3RIW/4wAuYoavKVlWHU
 Y2rrABeTstBOJEOlT0RlbS8RAkrfdCFJMFS+J5b+K7Zo4RkNB1ReF/V2w6BHsqRkDykn
 Mssyo/lzb7IEt0LAlz/bGhphSCrT7nJe17mf3n30G8KdVDWwDt8P3O+iLjqbtOvrBcmk
 fBm5gS0hG0WZBzuHwkJytEj2gdnYfXVTzUyWnxy8cbaVmOZFgHqQqlGzGOKFSxmz9wuU dQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qhredrqvs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:56 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMitAb031041
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:55 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1BMisBM026862;
	Mon, 11 Feb 2019 22:44:54 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:54 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 5/5] kvm/book3s: use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:37 -0500
Message-Id: <20190211224437.25267-6-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory used for TCE tables in kvm_vm_ioctl_create_spapr_tce is currently
accounted to locked_vm because it stays resident and its allocation is
directly triggered from userspace as explained in f8626985c7c2 ("KVM:
PPC: Account TCE-containing pages in locked_vm").

However, since the memory comes straight from the page allocator (and to
a lesser extent unreclaimable slab) and is effectively pinned, it should
be accounted with pinned_vm (see bc3e53f682d9 ("mm: distinguish between
mlocked and pinned pages")).

pinned_vm recently became atomic and so no longer relies on mmap_sem
held as writer: delete.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 arch/powerpc/kvm/book3s_64_vio.c | 35 ++++++++++++++------------------
 1 file changed, 15 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_64_vio.c b/arch/powerpc/kvm/book3s_64_vio.c
index 532ab79734c7..2f8d7c051e4e 100644
--- a/arch/powerpc/kvm/book3s_64_vio.c
+++ b/arch/powerpc/kvm/book3s_64_vio.c
@@ -56,39 +56,34 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
 	return tce_pages + ALIGN(stt_bytes, PAGE_SIZE) / PAGE_SIZE;
 }
 
-static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
+static long kvmppc_account_memlimit(unsigned long pages, bool inc)
 {
 	long ret = 0;
+	s64 pinned_vm;
 
 	if (!current || !current->mm)
 		return ret; /* process exited */
 
-	down_write(&current->mm->mmap_sem);
-
 	if (inc) {
-		unsigned long locked, lock_limit;
+		unsigned long lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 
-		locked = current->mm->locked_vm + stt_pages;
-		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+		pinned_vm = atomic64_add_return(pages, &current->mm->pinned_vm);
+		if (pinned_vm > lock_limit && !capable(CAP_IPC_LOCK)) {
 			ret = -ENOMEM;
-		else
-			current->mm->locked_vm += stt_pages;
+			atomic64_sub(pages, &current->mm->pinned_vm);
+		}
 	} else {
-		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
-			stt_pages = current->mm->locked_vm;
+		pinned_vm = atomic64_read(&current->mm->pinned_vm);
+		if (WARN_ON_ONCE(pages > pinned_vm))
+			pages = pinned_vm;
 
-		current->mm->locked_vm -= stt_pages;
+		atomic64_sub(pages, &current->mm->pinned_vm);
 	}
 
-	pr_debug("[%d] RLIMIT_MEMLOCK KVM %c%ld %ld/%ld%s\n", current->pid,
-			inc ? '+' : '-',
-			stt_pages << PAGE_SHIFT,
-			current->mm->locked_vm << PAGE_SHIFT,
-			rlimit(RLIMIT_MEMLOCK),
-			ret ? " - exceeded" : "");
-
-	up_write(&current->mm->mmap_sem);
+	pr_debug("[%d] RLIMIT_MEMLOCK KVM %c%lu %ld/%lu%s\n", current->pid,
+			inc ? '+' : '-', pages << PAGE_SHIFT,
+			atomic64_read(&current->mm->pinned_vm) << PAGE_SHIFT,
+			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
 
 	return ret;
 }
-- 
2.20.1

