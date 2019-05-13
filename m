Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0E4CC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73E242084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rJqFVfy/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73E242084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F27B6B026E; Mon, 13 May 2019 10:39:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 455D46B026F; Mon, 13 May 2019 10:39:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25BCD6B0270; Mon, 13 May 2019 10:39:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE4C96B026E
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:32 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y15so9986212iod.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=HIfaAaJqDpQgZqOlqv93OYEN222yx/NWgo2RgdnE7Ys=;
        b=Hb9+4ID65uTiE9KUVx+wbYarbn0Hh5dS5B6dm51whdZiCMV1IFNQ+shr1Pq8kRL3Mo
         wRXknBlJ0wgqYU/s5IBEOollbpHnq2QCoU0ike1ES0zaNc/vnnfHjfzv1NUrbekpnKZn
         Dmjz7X6UUMRDmg36LWeICov++xKtbU4se8ssrQLW10a7C/92cw5eXhaIFmjc7a0pI/Sg
         sIBG0K74K6HVC/5uyG0VIFQ3HYDaq/wnznV5Og78ihkCX385yYiiZa+lmC57R5o2FsST
         jez9sk2H8e4HA/JYC4ZqMa1zfDcDXAqJqHdXaRLwq6T9I1kw2/zYsqgVRg/5CUoZiShn
         16lw==
X-Gm-Message-State: APjAAAUoQz3KFTnCxOQ3BsuI5HL0sTN2/p8GjacY2vhm+ieL5jpGQPUm
	ITNoXDpN7MeY10L6bOdwqYgDnzhkBY4IUs7SDwE/LbHdTCobR1c3YSFhTo/j9cjJKzp0kbFdd5W
	TjcDihSOY6CWudph4S6QYVbPDmUXYtdimU2h1/it9DZViY5MTk9IVuAtpE0d1NynHRQ==
X-Received: by 2002:a6b:14ce:: with SMTP id 197mr15661550iou.29.1557758372679;
        Mon, 13 May 2019 07:39:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrk6602vsJype93i5KY1HXl3KP7JuUx9bhHHCbgiye3/oiI4BhL8ekBX+N/x8xHo5Xjs/6
X-Received: by 2002:a6b:14ce:: with SMTP id 197mr15661496iou.29.1557758371709;
        Mon, 13 May 2019 07:39:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758371; cv=none;
        d=google.com; s=arc-20160816;
        b=uRtRJ0CQfXDZad5M7fIKeeDL7Rh4LVuIawUA3g6yDhRiHLK7BeCbauMxTJbIsk/IXK
         dcEJcBQjGdYI2cKgMfn0WiTEPIkNSbAzYMvL0Akyk9FNOOvcj34pMfj55lCtwcCvjmDF
         eYHTVwYXMIqyP2H2LcZwaCV/eS+j8atPHg79cDpHTBM0mKBbRSRUhN73vBJum6+X9D3b
         Yqx87tjG0Av619OIJSLqUNh57PU5EmX+buVvjghS8PHzuS+ng1bdtdGO5h6A0QMb+SE5
         6ZKRlagqBzgru0YMtwQNjpgB7GcTHJi3YCelnM3cc+KGnsd+lgWmNlWvm4qrE4Az8vDC
         V8NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=HIfaAaJqDpQgZqOlqv93OYEN222yx/NWgo2RgdnE7Ys=;
        b=OICrLbwuoyogil5BoM5r39sDP4kpzDn+daqS8kvXCBwofG+tuiWnRnUojfRcrfTJuk
         YgfMhUaZCszbxcwsCapRSZ18NcOrBYeFPdor2qggl4fqta4tP92MrQX1omNkLa1c3ker
         Jc0fF+PTt2JyRaNJamiPFGHbkTirrGmqAxZeasxxLn8aBHk2kaV7hNprxHCMr1WZpSZ6
         fxGh/OwJbAqYZYibaKoTJDWFtRpokmBj1UNueCD+5XHaEcJL4OSA+Cc2P19tQ86PLGNl
         ZGNqSmR9Ckf9Awuawyn1HE7ifJP/d/L8y2jDF/C6gIzMiO7MqdYksQ6UIDZDwYIoIgp1
         z4EA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="rJqFVfy/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g127si7640610jag.119.2019.05.13.07.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="rJqFVfy/";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2pd194892;
	Mon, 13 May 2019 14:39:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=HIfaAaJqDpQgZqOlqv93OYEN222yx/NWgo2RgdnE7Ys=;
 b=rJqFVfy/BraQo2VV+vTf4vEU8uKTxNMJYqNUMPJntKe3SPbYIqJswWfe8FSX9DOUDUvq
 NMeBPV/EFppUnPmGQYbDoMnmg/dC+wvoFJX/MAxWhRp9eR7c70Ir05eJ9ObgYhuTZIN0
 D6O2EwvBsR4WuKaiukLz+63YyUEe8qIjPm7QE5ehY3t9v0MmShxoS6X2fFxg5nPXKcjD
 5e42nLFl9jyGEOT3WQUgTW0ZEa0BSwnYUeiOjo0jQFfif/6jx2982K9zu7DiWOea0CSj
 W4Xl7iGJz5g3uHt6WP7akNTkktkKiod+MAJFVIj50sV+mpTRrNCEYkdwKX02CtXlEBbR ag== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7aws-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:23 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQH022780;
	Mon, 13 May 2019 14:39:19 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 14/27] kvm/isolation: functions to copy page table entries for a VA range
Date: Mon, 13 May 2019 16:38:22 +0200
Message-Id: <1557758315-12667-15-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These functions are based on the copy_pxx_range() functions defined in
mm/memory.c. The main difference is that a level parameter is specified
to indicate the page table level (PGD, P4D, PUD PMD, PTE) at which the
copy should be done. Also functions don't use a vma parameter, and
don't alter the source page table even if an entry is bad.

Also kvm_copy_pte_range() can be called with a non page-aligned buffer,
so the buffer should be aligned with the page start so that the entire
buffer is mapped if the end of buffer crosses a page.

These functions will be used to populate the KVM page table.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |  229 ++++++++++++++++++++++++++++++++++++++++++++++
 arch/x86/kvm/isolation.h |    1 +
 2 files changed, 230 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index b681e4f..4f1b511 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -450,6 +450,235 @@ static int kvm_set_pgd(pgd_t *pgd, pgd_t pgd_value)
 }
 
 
+static int kvm_copy_pte_range(struct mm_struct *dst_mm,
+			      struct mm_struct *src_mm, pmd_t *dst_pmd,
+			      pmd_t *src_pmd, unsigned long addr,
+			      unsigned long end)
+{
+	pte_t *src_pte, *dst_pte;
+
+	dst_pte = kvm_pte_alloc(dst_mm, dst_pmd, addr);
+	if (IS_ERR(dst_pte))
+		return PTR_ERR(dst_pte);
+
+	addr &= PAGE_MASK;
+	src_pte = pte_offset_map(src_pmd, addr);
+
+	do {
+		pr_debug("PTE: %lx/%lx set[%lx] = %lx\n",
+		    addr, addr + PAGE_SIZE, (long)dst_pte, pte_val(*src_pte));
+		set_pte_at(dst_mm, addr, dst_pte, *src_pte);
+
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr < end);
+
+	return 0;
+}
+
+static int kvm_copy_pmd_range(struct mm_struct *dst_mm,
+			      struct mm_struct *src_mm,
+			      pud_t *dst_pud, pud_t *src_pud,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	unsigned long next;
+	int err;
+
+	dst_pmd = kvm_pmd_alloc(dst_mm, dst_pud, addr);
+	if (IS_ERR(dst_pmd))
+		return PTR_ERR(dst_pmd);
+
+	src_pmd = pmd_offset(src_pud, addr);
+
+	do {
+		next = pmd_addr_end(addr, end);
+		if (level == PGT_LEVEL_PMD || pmd_none(*src_pmd)) {
+			pr_debug("PMD: %lx/%lx set[%lx] = %lx\n",
+			    addr, next, (long)dst_pmd, pmd_val(*src_pmd));
+			err = kvm_set_pmd(dst_pmd, *src_pmd);
+			if (err)
+				return err;
+			continue;
+		}
+
+		if (!pmd_present(*src_pmd)) {
+			pr_warn("PMD: not present for [%lx,%lx]\n",
+			    addr, next - 1);
+			pmd_clear(dst_pmd);
+			continue;
+		}
+
+		if (pmd_trans_huge(*src_pmd) || pmd_devmap(*src_pmd)) {
+			pr_debug("PMD: %lx/%lx set[%lx] = %lx (huge/devmap)\n",
+			    addr, next, (long)dst_pmd, pmd_val(*src_pmd));
+			err = kvm_set_pmd(dst_pmd, *src_pmd);
+			if  (err)
+				return err;
+			continue;
+		}
+
+		err = kvm_copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+					addr, next);
+		if (err) {
+			pr_err("PMD: ERR PTE addr=%lx next=%lx\n", addr, next);
+			return err;
+		}
+
+	} while (dst_pmd++, src_pmd++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int kvm_copy_pud_range(struct mm_struct *dst_mm,
+			      struct mm_struct *src_mm,
+			      p4d_t *dst_p4d, p4d_t *src_p4d,
+			      unsigned long addr, unsigned long end,
+			      enum page_table_level level)
+{
+	pud_t *src_pud, *dst_pud;
+	unsigned long next;
+	int err;
+
+	dst_pud = kvm_pud_alloc(dst_mm, dst_p4d, addr);
+	if (IS_ERR(dst_pud))
+		return PTR_ERR(dst_pud);
+
+	src_pud = pud_offset(src_p4d, addr);
+
+	do {
+		next = pud_addr_end(addr, end);
+		if (level == PGT_LEVEL_PUD || pud_none(*src_pud)) {
+			pr_debug("PUD: %lx/%lx set[%lx] = %lx\n",
+			    addr, next, (long)dst_pud, pud_val(*src_pud));
+			err = kvm_set_pud(dst_pud, *src_pud);
+			if (err)
+				return err;
+			continue;
+		}
+
+		if (pud_trans_huge(*src_pud) || pud_devmap(*src_pud)) {
+			pr_debug("PUD: %lx/%lx set[%lx] = %lx (huge/devmap)\n",
+			    addr, next, (long)dst_pud, pud_val(*src_pud));
+			err = kvm_set_pud(dst_pud, *src_pud);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = kvm_copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
+					addr, next, level);
+		if (err) {
+			pr_err("PUD: ERR PMD addr=%lx next=%lx\n", addr, next);
+			return err;
+		}
+
+	} while (dst_pud++, src_pud++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int kvm_copy_p4d_range(struct mm_struct *dst_mm,
+				struct mm_struct *src_mm,
+				pgd_t *dst_pgd, pgd_t *src_pgd,
+				unsigned long addr, unsigned long end,
+				enum page_table_level level)
+{
+	p4d_t *src_p4d, *dst_p4d;
+	unsigned long next;
+	int err;
+
+	dst_p4d = kvm_p4d_alloc(dst_mm, dst_pgd, addr);
+	if (IS_ERR(dst_p4d))
+		return PTR_ERR(dst_p4d);
+
+	src_p4d = p4d_offset(src_pgd, addr);
+
+	do {
+		next = p4d_addr_end(addr, end);
+		if (level == PGT_LEVEL_P4D || p4d_none(*src_p4d)) {
+			pr_debug("P4D: %lx/%lx set[%lx] = %lx\n",
+			    addr, next, (long)dst_p4d, p4d_val(*src_p4d));
+
+			err = kvm_set_p4d(dst_p4d, *src_p4d);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = kvm_copy_pud_range(dst_mm, src_mm, dst_p4d, src_p4d,
+					addr, next, level);
+		if (err) {
+			pr_err("P4D: ERR PUD addr=%lx next=%lx\n", addr, next);
+			return err;
+		}
+
+	} while (dst_p4d++, src_p4d++, addr = next, addr < end);
+
+	return 0;
+}
+
+static int kvm_copy_pgd_range(struct mm_struct *dst_mm,
+				struct mm_struct *src_mm, unsigned long addr,
+				unsigned long end, enum page_table_level level)
+{
+	pgd_t *src_pgd, *dst_pgd;
+	unsigned long next;
+	int err;
+
+	dst_pgd = pgd_offset(dst_mm, addr);
+	src_pgd = pgd_offset(src_mm, addr);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		if (level == PGT_LEVEL_PGD || pgd_none(*src_pgd)) {
+			pr_debug("PGD: %lx/%lx set[%lx] = %lx\n",
+			    addr, next, (long)dst_pgd, pgd_val(*src_pgd));
+			err = kvm_set_pgd(dst_pgd, *src_pgd);
+			if (err)
+				return err;
+			continue;
+		}
+
+		err = kvm_copy_p4d_range(dst_mm, src_mm, dst_pgd, src_pgd,
+					addr, next, level);
+		if (err) {
+			pr_err("PGD: ERR P4D addr=%lx next=%lx\n", addr, next);
+			return err;
+		}
+
+	} while (dst_pgd++, src_pgd++, addr = next, addr < end);
+
+	return 0;
+}
+
+/*
+ * Copy page table entries from the current page table (i.e. from the
+ * kernel page table) to the KVM page table. The level parameter specifies
+ * the page table level (PGD, P4D, PUD PMD, PTE) at which the copy should
+ * be done.
+ */
+static int kvm_copy_mapping(void *ptr, size_t size, enum page_table_level level)
+{
+	unsigned long addr = (unsigned long)ptr;
+	unsigned long end = addr + ((unsigned long)size);
+
+	BUG_ON(current->mm == &kvm_mm);
+	pr_debug("KERNMAP COPY addr=%px size=%lx\n", ptr, size);
+	return kvm_copy_pgd_range(&kvm_mm, current->mm, addr, end, level);
+}
+
+
+/*
+ * Copy page table PTE entries from the current page table to the KVM
+ * page table.
+ */
+int kvm_copy_ptes(void *ptr, unsigned long size)
+{
+	return kvm_copy_mapping(ptr, size, PGT_LEVEL_PTE);
+}
+EXPORT_SYMBOL(kvm_copy_ptes);
+
+
 static int kvm_isolation_init_mm(void)
 {
 	pgd_t *kvm_pgd;
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index aa5e979..e8c018a 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -16,5 +16,6 @@ static inline bool kvm_isolation(void)
 extern void kvm_isolation_enter(void);
 extern void kvm_isolation_exit(void);
 extern void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu);
+extern int kvm_copy_ptes(void *ptr, unsigned long size);
 
 #endif
-- 
1.7.1

