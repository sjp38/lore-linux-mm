Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EB96C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F37652186A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Gfr3nMzN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F37652186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE6548E0182; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0928E017F; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 642A78E0184; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F41A8E0182
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m1so994023ita.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:46:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=69rc/HLjHXpWY00W09MehBQXPdb8h1Mg0HmD/buXmQE=;
        b=ptyJmnEOdnN3e2Ev096CwVxTYxO6AN2jkguBnmKhtIt9Bsrbz3a+UetlnB/AkLVFvo
         /Nd/JPbeyF4cCPrehNGtRNerVAfB/MeUvudXphLrAqhrfDrS0xFWmhoOCm+j/WZUoAoz
         kzW7lnkiuzlFeUU+tL9vFo8MMqRECk9ani0dSvJk/43l9jx+nXa1L77efiByUHMy5efU
         eTw9SzGH6ZpOmyBmAnRVz8hrxlCO0V94ROdqM/LQ4HvzEnDxXVPWONtUq8YvdNTk+LnY
         2o13viiE41ScUglU1BWdJ79aiIz3GIYwoRqsPygO/qusAmk+Yy9WEzPQDErXVtbpln2X
         1ysg==
X-Gm-Message-State: AHQUAuYCWf5hy6hJTOTUEjl96BlUWaTPNbbvUdefb9JJ5qqyd1kNqbHm
	pwucNEsXlgnvBVffISUe8o2V0oFSH1AuE+sf5bc3ap8lsMASP58m2m1FReHgfxuFimBjOgWpdri
	zPu3PabDjBnxlNSb5gr3GpqaySZqrx5KEmnjpj17pAoqA2EWJ3It2Das4GZKC2/N7Bw==
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr333378ior.11.1549925168910;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1Rfkrv5TxoSafsTKUGVRTpj7GEB9zD2Dz+ar+VHej7vw4goKHQnne1RH4x233+3yilbRX
X-Received: by 2002:a5d:84c3:: with SMTP id z3mr333357ior.11.1549925168220;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925168; cv=none;
        d=google.com; s=arc-20160816;
        b=F1Pij7ETATilA7YX+I3iBOcNJfGEIKQ+T7nDgRAXZQNJdYYhQhIEAWcMLDr7QFbVQZ
         c6b/HEbP5HH5x3rbylQCoeU72o+yaXROAu8vNwUDlpHMM2EeHttEJgSnBmKJ6NfaufZW
         9+w0QFIof9lKMRmGH8Kof+bOld2BQ1RTSWZnv5H052hPIGRhqnxXJicuJjhlV96+oG7M
         vApToolJzVHw9+iTosUTnMZSUuV9UtpbCp7LpRpkX0+RdBXhsP6fuWjXXI3nrcMR2vaj
         gINiAFsGOvy/dm8IPDpwalTXCMtm93nOPHyT4QopWQcoMeu8htiMpB/pjYQzixcBYW6E
         qkKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=69rc/HLjHXpWY00W09MehBQXPdb8h1Mg0HmD/buXmQE=;
        b=N93ArMupxbmqzkorXdgeqcUROFhqdM2uWjx6zbyJG0JYS+FfYL15Y6cQliR8OShslb
         5JoR0nXBFx9E7ZS5xzvVeUrNNQks5NBbEmhG9jnV+uc2EWl+waLG2nFawMcE7kE47rs/
         Qe3qsjygps5wmBFJc7eWoPeR0cphMPliMwQfF5w/jzUz7C2oUVDfqf1sBYlMYkDLpqlA
         AVcHmZ2KbFOJRlywx1NYmbkDLgdORQwxvLPNfvt1l4TracmWWLTBrH4EzDcgCNAWtNZ5
         QQmFAqk5tJ1b7JgvgGsAtS5u7ZW2zvCIDSxELYcM39g4KYTqJahUU6SkzqdAXejLSBph
         /Rjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Gfr3nMzN;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c100si382862itd.11.2019.02.11.14.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Gfr3nMzN;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhngk080623;
	Mon, 11 Feb 2019 22:44:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=69rc/HLjHXpWY00W09MehBQXPdb8h1Mg0HmD/buXmQE=;
 b=Gfr3nMzNWtSmRQKUAlaR6K8BOIJHCFY5nf7j4z47WYheSxOUPHcxULWcuty9OQxO0yp2
 n8KtHxjsTHToGobqYK2XyioonKcPd+2gO4XOlGyT4wo94g19guNjk1xy0PQDMuAWpQz6
 1mkYSXvlssEu7NmA2mavemTv8Jm8va+5wWBgcyLRLf8cRhLNsKhASO38yS1wutvmfHyo
 Q4YxEr2lSht1W9wx1znxe+Axbs9fslLbFTJpAYpNxLs4mzJt0+d6gGyMQmQfIX/YKOI1
 0mT793Yti8IDnYpZsgFhj6zQoEJ4IUvUFOG7BzbxiPXaBRsCOPVWULWVhz8YoLY5CqyM sg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre58p9q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:54 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMirBK030983
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:53 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1BMiqrQ026826;
	Mon, 11 Feb 2019 22:44:52 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:52 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 4/5] powerpc/mmu: use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:36 -0500
Message-Id: <20190211224437.25267-5-daniel.m.jordan@oracle.com>
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

Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
pages"), locked and pinned pages are accounted separately.  The IOMMU
MMU helpers on powerpc account pinned pages to locked_vm; use pinned_vm
instead.

pinned_vm recently became atomic and so no longer relies on mmap_sem
held as writer: delete.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 arch/powerpc/mm/mmu_context_iommu.c | 43 ++++++++++++++---------------
 1 file changed, 21 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index a712a650a8b6..fdf670542847 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -40,36 +40,35 @@ struct mm_iommu_table_group_mem_t {
 	u64 dev_hpa;		/* Device memory base address */
 };
 
-static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
+static long mm_iommu_adjust_pinned_vm(struct mm_struct *mm,
 		unsigned long npages, bool incr)
 {
-	long ret = 0, locked, lock_limit;
+	long ret = 0;
+	unsigned long lock_limit;
+	s64 pinned_vm;
 
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
-
 	if (incr) {
-		locked = mm->locked_vm + npages;
 		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+		pinned_vm = atomic64_add_return(npages, &mm->pinned_vm);
+		if (pinned_vm > lock_limit && !capable(CAP_IPC_LOCK)) {
 			ret = -ENOMEM;
-		else
-			mm->locked_vm += npages;
+			atomic64_sub(npages, &mm->pinned_vm);
+		}
 	} else {
-		if (WARN_ON_ONCE(npages > mm->locked_vm))
-			npages = mm->locked_vm;
-		mm->locked_vm -= npages;
+		pinned_vm = atomic64_read(&mm->pinned_vm);
+		if (WARN_ON_ONCE(npages > pinned_vm))
+			npages = pinned_vm;
+		atomic64_sub(npages, &mm->pinned_vm);
 	}
 
-	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%ld %ld/%ld\n",
-			current ? current->pid : 0,
-			incr ? '+' : '-',
+	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%lu %ld/%lu\n",
+			current ? current->pid : 0, incr ? '+' : '-',
 			npages << PAGE_SHIFT,
-			mm->locked_vm << PAGE_SHIFT,
+			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
 
 	return ret;
 }
@@ -133,7 +132,7 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 		struct mm_iommu_table_group_mem_t **pmem)
 {
 	struct mm_iommu_table_group_mem_t *mem;
-	long i, j, ret = 0, locked_entries = 0;
+	long i, j, ret = 0, pinned_entries = 0;
 	unsigned int pageshift;
 	unsigned long flags;
 	unsigned long cur_ua;
@@ -154,11 +153,11 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 	}
 
 	if (dev_hpa == MM_IOMMU_TABLE_INVALID_HPA) {
-		ret = mm_iommu_adjust_locked_vm(mm, entries, true);
+		ret = mm_iommu_adjust_pinned_vm(mm, entries, true);
 		if (ret)
 			goto unlock_exit;
 
-		locked_entries = entries;
+		pinned_entries = entries;
 	}
 
 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
@@ -252,8 +251,8 @@ static long mm_iommu_do_alloc(struct mm_struct *mm, unsigned long ua,
 	list_add_rcu(&mem->next, &mm->context.iommu_group_mem_list);
 
 unlock_exit:
-	if (locked_entries && ret)
-		mm_iommu_adjust_locked_vm(mm, locked_entries, false);
+	if (pinned_entries && ret)
+		mm_iommu_adjust_pinned_vm(mm, pinned_entries, false);
 
 	mutex_unlock(&mem_list_mutex);
 
@@ -352,7 +351,7 @@ long mm_iommu_put(struct mm_struct *mm, struct mm_iommu_table_group_mem_t *mem)
 	mm_iommu_release(mem);
 
 	if (dev_hpa == MM_IOMMU_TABLE_INVALID_HPA)
-		mm_iommu_adjust_locked_vm(mm, entries, false);
+		mm_iommu_adjust_pinned_vm(mm, entries, false);
 
 unlock_exit:
 	mutex_unlock(&mem_list_mutex);
-- 
2.20.1

