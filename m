Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81174C04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19046206BF
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="RSgjsP4c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19046206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91A486B0007; Mon,  6 May 2019 19:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CA746B000A; Mon,  6 May 2019 19:30:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76AC76B000C; Mon,  6 May 2019 19:30:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 344066B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:30:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so8052752pll.16
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:30:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=lIdFU1rqHJ9svPV3iBuugHZa71MJn+mQZ7zg5rlsxNo=;
        b=hVsMjHHcG1KPqelWcrmDX0LkW4s9I0+q7seT6ZJg3/izOG6lvxWbmDoWZJC11o/qBf
         RpFf9imcXo9RyIJ3nCeDUWfCRvsgKQ9vWcD4mdCCj5oFNnwkO5iI8Hr/diDebYnyBG4Q
         0t1vFpydZ1OQbCZiE2bOkaryhAUpP8AWXmpG9ynPz5QEkUtFpZ3j1IfxmQ0ufunL5iBe
         h7mY5K2ASuv2s+qXswfrZFeXuLx8xQrU/6i5PtyPJQ8uXQEbHjtqu/1GlsFp74vzhwld
         gdWj1EMi4A7H50nLWlVhPLRT4M6oHjyUBcIf1s4m8MYLk4ACNkOcN1+JAzeOpGqQLC43
         jQ9Q==
X-Gm-Message-State: APjAAAXlHTMQCb26J7m8q+LWkvNlcvxADWGQgu2VTv0s200JSXZtOkQj
	rHVD2DxldPofzPaHp6PT3RKJ0+WgVXmUblkuXWqkjAOYm5bFs2bDzYVuSX2d4BR6GLggVaEobDt
	JrzB7xyKxJiHhZgfQ1gBm9faUNEiUieeFcVreYfc9DIrr1exzYWx7WyFGXoF+MR831w==
X-Received: by 2002:a62:3501:: with SMTP id c1mr37961178pfa.184.1557185451752;
        Mon, 06 May 2019 16:30:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhHwPgPH/pKfQystX1B3DgqNQPP02VLzo7IMYEHxslfIBycRxpdEpyznd/wTRB5m8ABY7m
X-Received: by 2002:a62:3501:: with SMTP id c1mr37961010pfa.184.1557185449816;
        Mon, 06 May 2019 16:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185449; cv=none;
        d=google.com; s=arc-20160816;
        b=tpfryQl5UGkKIH/gYm/Tc6X4CIwQNAqVXBqm9mPOOzEKFDXCoBM5llBBpY02N+fLtT
         U+03YGIqKER9V08sKwtDMltfMDkLl30vNS5drdJlUIK/vmz2Rpjg+5JLlCn1VK5vjUoC
         jrT4wL9H9i+G+HCL0OL47QxGuT4Xj8PQ3TztzMPbDfUaVB9bL0RAxz9RLYuAygWiUA4t
         RMDTZScDcE+tqB2IbOnPxael3H+rdnBW2tRzOt6Fisg1fsFMnl1QT/RwjAs3Xob9a7ji
         FVM1RArxXdgGXqHEZK8kwjeKB0gfgI7AasWpvDRkguw0ROcK0nRIkl5ulJi1Ly6o7MaG
         57bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=lIdFU1rqHJ9svPV3iBuugHZa71MJn+mQZ7zg5rlsxNo=;
        b=MPw2vpYo1JI73bmivucYfMzenYJs4CMfS1ytPeFmJAfoXHEP7tSr/fcAyZ6XUz862I
         QM2u/tCB2DG+i/O11tPy4gNZMIFnaSaSJ1Y8i+A6Ea5Qd4noWub3CtMADgi/0/KJX13g
         YHWKo3U1S7VKUw25UhMw3nCV6k699kuH2wqWP+i1gOElbYfRFCRwxmPyKzxK1fD8VezH
         gY/jswpBjU1MjaOG21t1NEDBcLKPGyMz+ToUAuSILakv3hCuYsAUDyVRfA5aLQxB3b4M
         01IQG7NcRytDzTc1ckbHMan3qJrkbM19lrs/14rrPMa0v+DxNtA7+N1PCk7bAAlqz3yd
         e6+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RSgjsP4c;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e89si18628304plb.99.2019.05.06.16.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=RSgjsP4c;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd0c3a50000>; Mon, 06 May 2019 16:30:45 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 06 May 2019 16:30:49 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 06 May 2019 16:30:49 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 6 May
 2019 23:30:48 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Souptick Joarder
	<jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 2/5] mm/hmm: Clean up some coding style and comments
Date: Mon, 6 May 2019 16:29:39 -0700
Message-ID: <20190506232942.12623-3-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557185445; bh=lIdFU1rqHJ9svPV3iBuugHZa71MJn+mQZ7zg5rlsxNo=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 X-Originating-IP:X-ClientProxiedBy:Content-Transfer-Encoding:
	 Content-Type;
	b=RSgjsP4cWyGu7325S3r5+6bbBt4X8E9r47TkjuH5gs5tG0bEAgD5Kl3dYQSzbJo8o
	 fhxnA/JW/hqRUGYpgipY2FRNexErCAyUC1YQV5S3nKFzqT+iSaUKD/QQalzlKQkgo9
	 bui4JW2YLMKAyCbiVGq3k/wX1j9gBqamiPqlgRrw861P/UFXzQVfsiLa5+gQNdlUvw
	 t+axpH0K10Evm1hipSDGoxZCrbYk3BusIKX7DwWzzsYicpjiUuUqSXCGQZ/wMcSvW1
	 ovVUE65aG3AUJoIH8KN5rDPkIpsR9Wy2Pt9E3/o5oi0VuY+BhLYnUnDDoLnBk91Y5q
	 Q0vLkS4Qmr20w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

There are no functional changes, just some coding style clean ups and
minor comment changes.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/hmm.h | 71 +++++++++++++++++++++++----------------------
 mm/hmm.c            | 51 ++++++++++++++++----------------
 2 files changed, 62 insertions(+), 60 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 51ec27a84668..35a429621e1e 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -30,8 +30,8 @@
  *
  * HMM address space mirroring API:
  *
- * Use HMM address space mirroring if you want to mirror range of the CPU =
page
- * table of a process into a device page table. Here, "mirror" means "keep
+ * Use HMM address space mirroring if you want to mirror a range of the CP=
U
+ * page tables of a process into a device page table. Here, "mirror" means=
 "keep
  * synchronized". Prerequisites: the device must provide the ability to wr=
ite-
  * protect its page tables (at PAGE_SIZE granularity), and must be able to
  * recover from the resulting potential page faults.
@@ -114,10 +114,11 @@ struct hmm {
  * HMM_PFN_WRITE: CPU page table has write permission set
  * HMM_PFN_DEVICE_PRIVATE: private device memory (ZONE_DEVICE)
  *
- * The driver provide a flags array, if driver valid bit for an entry is b=
it
- * 3 ie (entry & (1 << 3)) is true if entry is valid then driver must prov=
ide
+ * The driver provides a flags array for mapping page protections to devic=
e
+ * PTE bits. If the driver valid bit for an entry is bit 3,
+ * i.e., (entry & (1 << 3)), then the driver must provide
  * an array in hmm_range.flags with hmm_range.flags[HMM_PFN_VALID] =3D=3D =
1 << 3.
- * Same logic apply to all flags. This is same idea as vm_page_prot in vma
+ * Same logic apply to all flags. This is the same idea as vm_page_prot in=
 vma
  * except that this is per device driver rather than per architecture.
  */
 enum hmm_pfn_flag_e {
@@ -138,13 +139,13 @@ enum hmm_pfn_flag_e {
  *      be mirrored by a device, because the entry will never have HMM_PFN=
_VALID
  *      set and the pfn value is undefined.
  *
- * Driver provide entry value for none entry, error entry and special entr=
y,
- * driver can alias (ie use same value for error and special for instance)=
. It
- * should not alias none and error or special.
+ * Driver provides values for none entry, error entry, and special entry.
+ * Driver can alias (i.e., use same value) error and special, but
+ * it should not alias none with error or special.
  *
  * HMM pfn value returned by hmm_vma_get_pfns() or hmm_vma_fault() will be=
:
  * hmm_range.values[HMM_PFN_ERROR] if CPU page table entry is poisonous,
- * hmm_range.values[HMM_PFN_NONE] if there is no CPU page table
+ * hmm_range.values[HMM_PFN_NONE] if there is no CPU page table entry,
  * hmm_range.values[HMM_PFN_SPECIAL] if CPU page table entry is a special =
one
  */
 enum hmm_pfn_value_e {
@@ -167,6 +168,7 @@ enum hmm_pfn_value_e {
  * @values: pfn value for some special case (none, special, error, ...)
  * @default_flags: default flags for the range (write, read, ... see hmm d=
oc)
  * @pfn_flags_mask: allows to mask pfn flags so that only default_flags ma=
tter
+ * @page_shift: device virtual address shift value (should be >=3D PAGE_SH=
IFT)
  * @pfn_shifts: pfn shift value (should be <=3D PAGE_SHIFT)
  * @valid: pfns array did not change since it has been fill by an HMM func=
tion
  */
@@ -189,7 +191,7 @@ struct hmm_range {
 /*
  * hmm_range_page_shift() - return the page shift for the range
  * @range: range being queried
- * Returns: page shift (page size =3D 1 << page shift) for the range
+ * Return: page shift (page size =3D 1 << page shift) for the range
  */
 static inline unsigned hmm_range_page_shift(const struct hmm_range *range)
 {
@@ -199,7 +201,7 @@ static inline unsigned hmm_range_page_shift(const struc=
t hmm_range *range)
 /*
  * hmm_range_page_size() - return the page size for the range
  * @range: range being queried
- * Returns: page size for the range in bytes
+ * Return: page size for the range in bytes
  */
 static inline unsigned long hmm_range_page_size(const struct hmm_range *ra=
nge)
 {
@@ -210,7 +212,7 @@ static inline unsigned long hmm_range_page_size(const s=
truct hmm_range *range)
  * hmm_range_wait_until_valid() - wait for range to be valid
  * @range: range affected by invalidation to wait on
  * @timeout: time out for wait in ms (ie abort wait after that period of t=
ime)
- * Returns: true if the range is valid, false otherwise.
+ * Return: true if the range is valid, false otherwise.
  */
 static inline bool hmm_range_wait_until_valid(struct hmm_range *range,
 					      unsigned long timeout)
@@ -231,7 +233,7 @@ static inline bool hmm_range_wait_until_valid(struct hm=
m_range *range,
 /*
  * hmm_range_valid() - test if a range is valid or not
  * @range: range
- * Returns: true if the range is valid, false otherwise.
+ * Return: true if the range is valid, false otherwise.
  */
 static inline bool hmm_range_valid(struct hmm_range *range)
 {
@@ -242,7 +244,7 @@ static inline bool hmm_range_valid(struct hmm_range *ra=
nge)
  * hmm_device_entry_to_page() - return struct page pointed to by a device =
entry
  * @range: range use to decode device entry value
  * @entry: device entry value to get corresponding struct page from
- * Returns: struct page pointer if entry is a valid, NULL otherwise
+ * Return: struct page pointer if entry is a valid, NULL otherwise
  *
  * If the device entry is valid (ie valid flag set) then return the struct=
 page
  * matching the entry value. Otherwise return NULL.
@@ -265,7 +267,7 @@ static inline struct page *hmm_device_entry_to_page(con=
st struct hmm_range *rang
  * hmm_device_entry_to_pfn() - return pfn value store in a device entry
  * @range: range use to decode device entry value
  * @entry: device entry to extract pfn from
- * Returns: pfn value if device entry is valid, -1UL otherwise
+ * Return: pfn value if device entry is valid, -1UL otherwise
  */
 static inline unsigned long
 hmm_device_entry_to_pfn(const struct hmm_range *range, uint64_t pfn)
@@ -285,7 +287,7 @@ hmm_device_entry_to_pfn(const struct hmm_range *range, =
uint64_t pfn)
  * hmm_device_entry_from_page() - create a valid device entry for a page
  * @range: range use to encode HMM pfn value
  * @page: page for which to create the device entry
- * Returns: valid device entry for the page
+ * Return: valid device entry for the page
  */
 static inline uint64_t hmm_device_entry_from_page(const struct hmm_range *=
range,
 						  struct page *page)
@@ -298,7 +300,7 @@ static inline uint64_t hmm_device_entry_from_page(const=
 struct hmm_range *range,
  * hmm_device_entry_from_pfn() - create a valid device entry value from pf=
n
  * @range: range use to encode HMM pfn value
  * @pfn: pfn value for which to create the device entry
- * Returns: valid device entry for the pfn
+ * Return: valid device entry for the pfn
  */
 static inline uint64_t hmm_device_entry_from_pfn(const struct hmm_range *r=
ange,
 						 unsigned long pfn)
@@ -403,7 +405,7 @@ enum hmm_update_event {
 };
=20
 /*
- * struct hmm_update - HMM update informations for callback
+ * struct hmm_update - HMM update information for callback
  *
  * @start: virtual start address of the range to update
  * @end: virtual end address of the range to update
@@ -436,8 +438,8 @@ struct hmm_mirror_ops {
 	/* sync_cpu_device_pagetables() - synchronize page tables
 	 *
 	 * @mirror: pointer to struct hmm_mirror
-	 * @update: update informations (see struct hmm_update)
-	 * Returns: -EAGAIN if update.blockable false and callback need to
+	 * @update: update information (see struct hmm_update)
+	 * Return: -EAGAIN if update.blockable false and callback need to
 	 *          block, 0 otherwise.
 	 *
 	 * This callback ultimately originates from mmu_notifiers when the CPU
@@ -476,13 +478,13 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)=
;
 /*
  * hmm_mirror_mm_is_alive() - test if mm is still alive
  * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
- * Returns: false if the mm is dead, true otherwise
+ * Return: false if the mm is dead, true otherwise
  *
- * This is an optimization it will not accurately always return -EINVAL if=
 the
- * mm is dead ie there can be false negative (process is being kill but HM=
M is
- * not yet inform of that). It is only intented to be use to optimize out =
case
- * where driver is about to do something time consuming and it would be be=
tter
- * to skip it if the mm is dead.
+ * This is an optimization, it will not always accurately return false if =
the
+ * mm is dead; i.e., there can be false negatives (process is being killed=
 but
+ * HMM is not yet informed of that). It is only intended to be used to opt=
imize
+ * out cases where the driver is about to do something time consuming and =
it
+ * would be better to skip it if the mm is dead.
  */
 static inline bool hmm_mirror_mm_is_alive(struct hmm_mirror *mirror)
 {
@@ -497,7 +499,6 @@ static inline bool hmm_mirror_mm_is_alive(struct hmm_mi=
rror *mirror)
 	return true;
 }
=20
-
 /*
  * Please see Documentation/vm/hmm.rst for how to use the range API.
  */
@@ -570,7 +571,7 @@ static inline int hmm_vma_fault(struct hmm_range *range=
, bool block)
 	ret =3D hmm_range_fault(range, block);
 	if (ret <=3D 0) {
 		if (ret =3D=3D -EBUSY || !ret) {
-			/* Same as above  drop mmap_sem to match old API. */
+			/* Same as above, drop mmap_sem to match old API. */
 			up_read(&range->vma->vm_mm->mmap_sem);
 			ret =3D -EBUSY;
 		} else if (ret =3D=3D -EAGAIN)
@@ -637,7 +638,7 @@ struct hmm_devmem_ops {
 	 * @page: pointer to struct page backing virtual address (unreliable)
 	 * @flags: FAULT_FLAG_* (see include/linux/mm.h)
 	 * @pmdp: page middle directory
-	 * Returns: VM_FAULT_MINOR/MAJOR on success or one of VM_FAULT_ERROR
+	 * Return: VM_FAULT_MINOR/MAJOR on success or one of VM_FAULT_ERROR
 	 *   on error
 	 *
 	 * The callback occurs whenever there is a CPU page fault or GUP on a
@@ -645,14 +646,14 @@ struct hmm_devmem_ops {
 	 * page back to regular memory (CPU accessible).
 	 *
 	 * The device driver is free to migrate more than one page from the
-	 * fault() callback as an optimization. However if device decide to
-	 * migrate more than one page it must always priotirize the faulting
+	 * fault() callback as an optimization. However if the device decides
+	 * to migrate more than one page it must always priotirize the faulting
 	 * address over the others.
 	 *
-	 * The struct page pointer is only given as an hint to allow quick
+	 * The struct page pointer is only given as a hint to allow quick
 	 * lookup of internal device driver data. A concurrent migration
-	 * might have already free that page and the virtual address might
-	 * not longer be back by it. So it should not be modified by the
+	 * might have already freed that page and the virtual address might
+	 * no longer be backed by it. So it should not be modified by the
 	 * callback.
 	 *
 	 * Note that mmap semaphore is held in read mode at least when this
@@ -679,7 +680,7 @@ struct hmm_devmem_ops {
  * @ref: per CPU refcount
  * @page_fault: callback when CPU fault on an unaddressable device page
  *
- * This an helper structure for device drivers that do not wish to impleme=
nt
+ * This is a helper structure for device drivers that do not wish to imple=
ment
  * the gory details related to hotplugging new memoy and allocating struct
  * pages.
  *
diff --git a/mm/hmm.c b/mm/hmm.c
index 0db8491090b8..f6c4c8633db9 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -162,9 +162,8 @@ static void hmm_release(struct mmu_notifier *mn, struct=
 mm_struct *mm)
=20
 	/* Wake-up everyone waiting on any range. */
 	mutex_lock(&hmm->lock);
-	list_for_each_entry(range, &hmm->ranges, list) {
+	list_for_each_entry(range, &hmm->ranges, list)
 		range->valid =3D false;
-	}
 	wake_up_all(&hmm->wq);
 	mutex_unlock(&hmm->lock);
=20
@@ -175,9 +174,10 @@ static void hmm_release(struct mmu_notifier *mn, struc=
t mm_struct *mm)
 		list_del_init(&mirror->list);
 		if (mirror->ops->release) {
 			/*
-			 * Drop mirrors_sem so callback can wait on any pending
-			 * work that might itself trigger mmu_notifier callback
-			 * and thus would deadlock with us.
+			 * Drop mirrors_sem so the release callback can wait
+			 * on any pending work that might itself trigger a
+			 * mmu_notifier callback and thus would deadlock with
+			 * us.
 			 */
 			up_write(&hmm->mirrors_sem);
 			mirror->ops->release(mirror);
@@ -232,11 +232,8 @@ static int hmm_invalidate_range_start(struct mmu_notif=
ier *mn,
 		int ret;
=20
 		ret =3D mirror->ops->sync_cpu_device_pagetables(mirror, &update);
-		if (!update.blockable && ret =3D=3D -EAGAIN) {
-			up_read(&hmm->mirrors_sem);
-			ret =3D -EAGAIN;
-			goto out;
-		}
+		if (!update.blockable && ret =3D=3D -EAGAIN)
+			break;
 	}
 	up_read(&hmm->mirrors_sem);
=20
@@ -280,6 +277,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_o=
ps =3D {
  *
  * @mirror: new mirror struct to register
  * @mm: mm to register against
+ * Return: 0 on success, -ENOMEM if no memory, -EINVAL if invalid argument=
s
  *
  * To start mirroring a process address space, the device driver must regi=
ster
  * an HMM mirror struct.
@@ -307,7 +305,7 @@ EXPORT_SYMBOL(hmm_mirror_register);
 /*
  * hmm_mirror_unregister() - unregister a mirror
  *
- * @mirror: new mirror struct to register
+ * @mirror: mirror struct to unregister
  *
  * Stop mirroring a process address space, and cleanup.
  */
@@ -381,7 +379,7 @@ static int hmm_pfns_bad(unsigned long addr,
  * @fault: should we fault or not ?
  * @write_fault: write fault ?
  * @walk: mm_walk structure
- * Returns: 0 on success, -EBUSY after page fault, or page fault error
+ * Return: 0 on success, -EBUSY after page fault, or page fault error
  *
  * This function will be called whenever pmd_none() or pte_none() returns =
true,
  * or whenever there is no page directory covering the virtual address ran=
ge.
@@ -924,6 +922,7 @@ int hmm_range_register(struct hmm_range *range,
 		       unsigned page_shift)
 {
 	unsigned long mask =3D ((1UL << page_shift) - 1UL);
+	struct hmm *hmm;
=20
 	range->valid =3D false;
 	range->hmm =3D NULL;
@@ -947,18 +946,18 @@ int hmm_range_register(struct hmm_range *range,
 		return -EFAULT;
 	}
=20
-	/* Initialize range to track CPU page table update */
+	/* Initialize range to track CPU page table updates. */
 	mutex_lock(&range->hmm->lock);
=20
-	list_add_rcu(&range->list, &range->hmm->ranges);
+	list_add_rcu(&range->list, &hmm->ranges);
=20
 	/*
 	 * If there are any concurrent notifiers we have to wait for them for
 	 * the range to be valid (see hmm_range_wait_until_valid()).
 	 */
-	if (!range->hmm->notifiers)
+	if (!hmm->notifiers)
 		range->valid =3D true;
-	mutex_unlock(&range->hmm->lock);
+	mutex_unlock(&hmm->lock);
=20
 	return 0;
 }
@@ -973,17 +972,19 @@ EXPORT_SYMBOL(hmm_range_register);
  */
 void hmm_range_unregister(struct hmm_range *range)
 {
+	struct hmm *hmm =3D range->hmm;
+
 	/* Sanity check this really should not happen. */
-	if (range->hmm =3D=3D NULL || range->end <=3D range->start)
+	if (hmm =3D=3D NULL || range->end <=3D range->start)
 		return;
=20
-	mutex_lock(&range->hmm->lock);
+	mutex_lock(&hmm->lock);
 	list_del_rcu(&range->list);
-	mutex_unlock(&range->hmm->lock);
+	mutex_unlock(&hmm->lock);
=20
 	/* Drop reference taken by hmm_range_register() */
 	range->valid =3D false;
-	hmm_put(range->hmm);
+	hmm_put(hmm);
 	range->hmm =3D NULL;
 }
 EXPORT_SYMBOL(hmm_range_unregister);
@@ -991,7 +992,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
 /*
  * hmm_range_snapshot() - snapshot CPU page table for a range
  * @range: range
- * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM inv=
alid
+ * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM inva=
lid
  *          permission (for instance asking for write and range is read on=
ly),
  *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no va=
lid
  *          vma or it is illegal to access that range), number of valid pa=
ges
@@ -1075,7 +1076,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
  * hmm_range_fault() - try to fault some address in a virtual address rang=
e
  * @range: range being faulted
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap=
_sem)
- * Returns: number of valid pages in range->pfns[] (from range start
+ * Return: number of valid pages in range->pfns[] (from range start
  *          address). This may be zero. If the return value is negative,
  *          then one of the following values may be returned:
  *
@@ -1193,7 +1194,7 @@ EXPORT_SYMBOL(hmm_range_fault);
  * @device: device against to dma map page to
  * @daddrs: dma address of mapped pages
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap=
_sem)
- * Returns: number of pages mapped on success, -EAGAIN if mmap_sem have be=
en
+ * Return: number of pages mapped on success, -EAGAIN if mmap_sem have bee=
n
  *          drop and you need to try again, some other error value otherwi=
se
  *
  * Note same usage pattern as hmm_range_fault().
@@ -1281,7 +1282,7 @@ EXPORT_SYMBOL(hmm_range_dma_map);
  * @device: device against which dma map was done
  * @daddrs: dma address of mapped pages
  * @dirty: dirty page if it had the write flag set
- * Returns: number of page unmapped on success, -EINVAL otherwise
+ * Return: number of page unmapped on success, -EINVAL otherwise
  *
  * Note that caller MUST abide by mmu notifier or use HMM mirror and abide
  * to the sync_cpu_device_pagetables() callback so that it is safe here to
@@ -1404,7 +1405,7 @@ static void hmm_devmem_free(struct page *page, void *=
data)
  * @ops: memory event device driver callback (see struct hmm_devmem_ops)
  * @device: device struct to bind the resource too
  * @size: size in bytes of the device memory to add
- * Returns: pointer to new hmm_devmem struct ERR_PTR otherwise
+ * Return: pointer to new hmm_devmem struct ERR_PTR otherwise
  *
  * This function first finds an empty range of physical address big enough=
 to
  * contain the new resource, and then hotplugs it as ZONE_DEVICE memory, w=
hich
--=20
2.20.1

