Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B2A2C282DA
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECEB3218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:27:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECEB3218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7318E0034; Thu,  7 Feb 2019 09:27:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A93A8E0002; Thu,  7 Feb 2019 09:27:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 849DB8E0034; Thu,  7 Feb 2019 09:27:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 242618E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:27:49 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p3so17536plk.9
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:27:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=0pMPTXsx/BAGix/Z2Ll/WxLvelGfTSrlCxUNRMakkEY=;
        b=jRbuOTS+c11Bk2qJbGQp1RKLEu9hXOjK+vZpPgAySMNJMXzCkhyut+MS8YO/XqFzVW
         IusHJxq7uVsNErL4v9ZH62XCWpRjl1KhelxsmbaIXsHx1rHrYqwpB/d7pxry6BQuchbn
         eYJGaSXpmVY2ZrQpkEjXx1J1zUIgqPoXRRM6p7s0Q7cM2JcmspPRev6KMbR8pn2wfloJ
         m6RJHvvJCHLKgXAdFs3aBhRQCwUXEgHzEvps3TjsLIBpDXEVU80pUZbBBE7JdVlAExaa
         qCH7QsyErAJ3a3jET3LzS/BwKQDRndrazDGpUzf2re7m/LIO16qZeGiRoM/CmzRS+shq
         sRLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAub8DaRZvKTKOi5k37PPraIhi6IyJ5/RoR2a7/YNyrelzLGtgJtf
	RYHX9FPDBNTI7abrSvgXO6wS2znltsp/t3DxiNAn/GsxA1AnMcU3geN4JIqUbB4zT2QJL9Fn7g5
	uPISWeXLQLbJ6QHYnirEK8tgPu59J4XIyuw/07iyboiVRj/NFtaYkQvWI4V1UrVdeXA==
X-Received: by 2002:a63:1f06:: with SMTP id f6mr15147258pgf.414.1549549668599;
        Thu, 07 Feb 2019 06:27:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbK6m+AcD49cS1bSlwQbxTiIuPQNSgfX/K+4/8ekT0kE20hPoSm0Ebyh5pERahz8g9YKDiC
X-Received: by 2002:a63:1f06:: with SMTP id f6mr15146959pgf.414.1549549664546;
        Thu, 07 Feb 2019 06:27:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549549664; cv=none;
        d=google.com; s=arc-20160816;
        b=fEFGw4hpADka6aoVNvlLmaLt2fpD59RwUQakIF3NsEdLH5wEPaWfW76a9SiK4yeV9t
         I2XMB8qYerq6Y0tAFgwiH1oU7BtToODQHEgy0iaKN/7LYXFXoL7TtlyZRcYnp+QAHlBX
         q2gLzNtUuh5sLHJRZRuTTMWoHGbegRT/brTWDCozSf4t+tsVIq+Atw/8jUhke3y71Xo3
         02EGQJrK8Y3xXKkN+yb16CtprKh5tl6yeaYVySS5ERyY5Qi/iDuCvVmyPub73JUfG541
         zFT3DaTklzB2TWQu1hEksNk9JN7r0l2E1MR48b6BONLfBCggRnSZ5EYVb16l1Qd2vJ7G
         Yekg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=0pMPTXsx/BAGix/Z2Ll/WxLvelGfTSrlCxUNRMakkEY=;
        b=EGdUZZ6+dB3JrsAznGf8RNUzZ/oG1+IqhcCLnqqk+hwzdgnh1NdrXIUwbPGWBCG7IQ
         MDvlzcHk1nLmVEQil4L8TGxEYNYQOgd9SXsGssWr32/+0uyMFBeai/CmAftyMLI3bRu+
         H0EiUwuMPaPCJfcfjPoXJ5FUK1MegWb8oFiP7iKiUXPMpSmqBQbV2GqW0Gpoa+rFW7kf
         IHzbcCMr36YZrdGpQDt456NXdbOXJZa+MqEKxPy0a+j0R6r4EtxWfX0vP4pOeXTA8h/y
         MhsWh2YAsER0yeBx6fMRs2MQRnr4a9obGIFFTNLDeeMklauoZ6mTRAwUfzor9mWkjHIJ
         YqvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g32si4679827pgg.400.2019.02.07.06.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:27:44 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x17EGplT086631
	for <linux-mm@kvack.org>; Thu, 7 Feb 2019 09:27:44 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qgntnjaga-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:27:43 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 7 Feb 2019 14:27:38 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 7 Feb 2019 14:27:35 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x17ERYwu50200660
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 7 Feb 2019 14:27:34 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3BAE1A4060;
	Thu,  7 Feb 2019 14:27:34 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AC865A4054;
	Thu,  7 Feb 2019 14:27:32 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  7 Feb 2019 14:27:32 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 07 Feb 2019 16:27:32 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RESEND PATCH 3/3] docs/core-api/mm: fix return value descriptions in mm/
Date: Thu,  7 Feb 2019 16:27:24 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1549549644-4903-1-git-send-email-rppt@linux.ibm.com>
References: <1549549644-4903-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19020714-0008-0000-0000-000002BDA59F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020714-0009-0000-0000-00002229B004
Message-Id: <1549549644-4903-4-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-07_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902070111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Many kernel-doc comments in mm/ have the return value descriptions either
misformatted or omitted at all which makes kernel-doc script unhappy:

$ make V=1 htmldocs
...
./mm/util.c:36: info: Scanning doc for kstrdup
./mm/util.c:41: warning: No description found for return value of 'kstrdup'
./mm/util.c:57: info: Scanning doc for kstrdup_const
./mm/util.c:66: warning: No description found for return value of 'kstrdup_const'
./mm/util.c:75: info: Scanning doc for kstrndup
./mm/util.c:83: warning: No description found for return value of 'kstrndup'
...

Fixing the formatting and adding the missing return value descriptions
eliminates ~100 such warnings.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/dmapool.c        | 13 +++++++---
 mm/filemap.c        | 73 +++++++++++++++++++++++++++++++++++++++++++++--------
 mm/memory.c         | 26 ++++++++++++++-----
 mm/mempool.c        |  8 ++++++
 mm/page-writeback.c | 24 ++++++++++++------
 mm/page_alloc.c     | 24 +++++++++++++-----
 mm/readahead.c      |  2 ++
 mm/slab.c           | 14 ++++++++++
 mm/slab_common.c    |  6 +++++
 mm/truncate.c       |  6 +++--
 mm/util.c           | 37 +++++++++++++++++++--------
 mm/vmalloc.c        | 47 ++++++++++++++++++++++++++--------
 12 files changed, 221 insertions(+), 59 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 6d4b97e..76a1600 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -114,10 +114,9 @@ static DEVICE_ATTR(pools, 0444, show_pools, NULL);
  * @size: size of the blocks in this pool.
  * @align: alignment requirement for blocks; must be a power of two
  * @boundary: returned blocks won't cross this power of two boundary
- * Context: !in_interrupt()
+ * Context: not in_interrupt()
  *
- * Returns a dma allocation pool with the requested characteristics, or
- * null if one can't be created.  Given one of these pools, dma_pool_alloc()
+ * Given one of these pools, dma_pool_alloc()
  * may be used to allocate memory.  Such memory will all have "consistent"
  * DMA mappings, accessible by the device and its driver without using
  * cache flushing primitives.  The actual size of blocks allocated may be
@@ -127,6 +126,9 @@ static DEVICE_ATTR(pools, 0444, show_pools, NULL);
  * cross that size boundary.  This is useful for devices which have
  * addressing restrictions on individual DMA transfers, such as not crossing
  * boundaries of 4KBytes.
+ *
+ * Return: a dma allocation pool with the requested characteristics, or
+ * %NULL if one can't be created.
  */
 struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 				 size_t size, size_t align, size_t boundary)
@@ -313,7 +315,7 @@ EXPORT_SYMBOL(dma_pool_destroy);
  * @mem_flags: GFP_* bitmask
  * @handle: pointer to dma address of block
  *
- * This returns the kernel virtual address of a currently unused block,
+ * Return: the kernel virtual address of a currently unused block,
  * and reports its dma address through the handle.
  * If such a memory block can't be allocated, %NULL is returned.
  */
@@ -498,6 +500,9 @@ static int dmam_pool_match(struct device *dev, void *res, void *match_data)
  *
  * Managed dma_pool_create().  DMA pool created with this function is
  * automatically destroyed on driver detach.
+ *
+ * Return: a managed dma allocation pool with the requested
+ * characteristics, or %NULL if one can't be created.
  */
 struct dma_pool *dmam_pool_create(const char *name, struct device *dev,
 				  size_t size, size_t align, size_t allocation)
diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323..d2c53b8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -392,6 +392,8 @@ static int filemap_check_and_keep_errors(struct address_space *mapping)
  * opposed to a regular memory cleansing writeback.  The difference between
  * these two operations is that if a dirty page/buffer is encountered, it must
  * be waited upon, and not just skipped over.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 				loff_t end, int sync_mode)
@@ -438,6 +440,8 @@ EXPORT_SYMBOL(filemap_fdatawrite_range);
  *
  * This is a mostly non-blocking flush.  Not suitable for data-integrity
  * purposes - I/O may not be started against all dirty pages.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int filemap_flush(struct address_space *mapping)
 {
@@ -453,6 +457,9 @@ EXPORT_SYMBOL(filemap_flush);
  *
  * Find at least one page in the range supplied, usually used to check if
  * direct writing in this range will trigger a writeback.
+ *
+ * Return: %true if at least one page exists in the specified range,
+ * %false otherwise.
  */
 bool filemap_range_has_page(struct address_space *mapping,
 			   loff_t start_byte, loff_t end_byte)
@@ -529,6 +536,8 @@ static void __filemap_fdatawait_range(struct address_space *mapping,
  * Since the error status of the address space is cleared by this function,
  * callers are responsible for checking the return value and handling and/or
  * reporting the error.
+ *
+ * Return: error status of the address space.
  */
 int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
 			    loff_t end_byte)
@@ -551,6 +560,8 @@ EXPORT_SYMBOL(filemap_fdatawait_range);
  * Since the error status of the file is advanced by this function,
  * callers are responsible for checking the return value and handling and/or
  * reporting the error.
+ *
+ * Return: error status of the address space vs. the file->f_wb_err cursor.
  */
 int file_fdatawait_range(struct file *file, loff_t start_byte, loff_t end_byte)
 {
@@ -572,6 +583,8 @@ EXPORT_SYMBOL(file_fdatawait_range);
  * Use this function if callers don't handle errors themselves.  Expected
  * call sites are system-wide / filesystem-wide data flushers: e.g. sync(2),
  * fsfreeze(8)
+ *
+ * Return: error status of the address space.
  */
 int filemap_fdatawait_keep_errors(struct address_space *mapping)
 {
@@ -623,6 +636,8 @@ EXPORT_SYMBOL(filemap_write_and_wait);
  *
  * Note that @lend is inclusive (describes the last byte to be written) so
  * that this function can be used to write to the very end-of-file (end = -1).
+ *
+ * Return: error status of the address space.
  */
 int filemap_write_and_wait_range(struct address_space *mapping,
 				 loff_t lstart, loff_t lend)
@@ -678,6 +693,8 @@ EXPORT_SYMBOL(__filemap_set_wb_err);
  * While we handle mapping->wb_err with atomic operations, the f_wb_err
  * value is protected by the f_lock since we must ensure that it reflects
  * the latest value swapped in for this file descriptor.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int file_check_and_advance_wb_err(struct file *file)
 {
@@ -720,6 +737,8 @@ EXPORT_SYMBOL(file_check_and_advance_wb_err);
  *
  * After writing out and waiting on the data, we check and advance the
  * f_wb_err cursor to the latest value, and return any errors detected there.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int file_write_and_wait_range(struct file *file, loff_t lstart, loff_t lend)
 {
@@ -753,6 +772,8 @@ EXPORT_SYMBOL(file_write_and_wait_range);
  * caller must do that.
  *
  * The remove + add is atomic.  This function cannot fail.
+ *
+ * Return: %0
  */
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 {
@@ -867,6 +888,8 @@ static int __add_to_page_cache_locked(struct page *page,
  *
  * This function is used to add a page to the pagecache. It must be locked.
  * This function does not add the page to the LRU.  The caller must do that.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
@@ -1463,7 +1486,7 @@ EXPORT_SYMBOL(page_cache_prev_miss);
  * If the slot holds a shadow entry of a previously evicted page, or a
  * swap entry from shmem/tmpfs, it is returned.
  *
- * Otherwise, %NULL is returned.
+ * Return: the found page or shadow entry, %NULL if nothing is found.
  */
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
@@ -1521,9 +1544,9 @@ EXPORT_SYMBOL(find_get_entry);
  * If the slot holds a shadow entry of a previously evicted page, or a
  * swap entry from shmem/tmpfs, it is returned.
  *
- * Otherwise, %NULL is returned.
- *
  * find_lock_entry() may sleep.
+ *
+ * Return: the found page or shadow entry, %NULL if nothing is found.
  */
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 {
@@ -1563,12 +1586,14 @@ EXPORT_SYMBOL(find_lock_entry);
  * - FGP_CREAT: If page is not present then a new page is allocated using
  *   @gfp_mask and added to the page cache and the VM's LRU
  *   list. The page is returned locked and with an increased
- *   refcount. Otherwise, NULL is returned.
+ *   refcount.
  *
  * If FGP_LOCK or FGP_CREAT are specified then the function may sleep even
  * if the GFP flags specified for FGP_CREAT are atomic.
  *
  * If there is a page cache page, it is returned with an increased refcount.
+ *
+ * Return: the found page or %NULL otherwise.
  */
 struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 	int fgp_flags, gfp_t gfp_mask)
@@ -1656,8 +1681,7 @@ EXPORT_SYMBOL(pagecache_get_page);
  * Any shadow entries of evicted pages, or swap entries from
  * shmem/tmpfs, are included in the returned array.
  *
- * find_get_entries() returns the number of pages and shadow entries
- * which were found.
+ * Return: the number of pages and shadow entries which were found.
  */
 unsigned find_get_entries(struct address_space *mapping,
 			  pgoff_t start, unsigned int nr_entries,
@@ -1727,8 +1751,8 @@ unsigned find_get_entries(struct address_space *mapping,
  * indexes.  There may be holes in the indices due to not-present pages.
  * We also update @start to index the next page for the traversal.
  *
- * find_get_pages_range() returns the number of pages which were found. If this
- * number is smaller than @nr_pages, the end of specified range has been
+ * Return: the number of pages which were found. If this number is
+ * smaller than @nr_pages, the end of specified range has been
  * reached.
  */
 unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
@@ -1801,7 +1825,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
  * find_get_pages_contig() works exactly like find_get_pages(), except
  * that the returned number of pages are guaranteed to be contiguous.
  *
- * find_get_pages_contig() returns the number of pages which were found.
+ * Return: the number of pages which were found.
  */
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 			       unsigned int nr_pages, struct page **pages)
@@ -1872,6 +1896,8 @@ EXPORT_SYMBOL(find_get_pages_contig);
  *
  * Like find_get_pages, except we only return pages which are tagged with
  * @tag.   We update @index to index the next page for the traversal.
+ *
+ * Return: the number of pages which were found.
  */
 unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 			pgoff_t end, xa_mark_t tag, unsigned int nr_pages,
@@ -1949,6 +1975,8 @@ EXPORT_SYMBOL(find_get_pages_range_tag);
  *
  * Like find_get_entries, except we only return entries which are tagged with
  * @tag.
+ *
+ * Return: the number of entries which were found.
  */
 unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			xa_mark_t tag, unsigned int nr_entries,
@@ -2034,6 +2062,10 @@ static void shrink_readahead_size_eio(struct file *filp,
  *
  * This is really ugly. But the goto's actually try to clarify some
  * of the logic when it comes to error handling etc.
+ *
+ * Return:
+ * * total number of bytes copied, including those the were already @written
+ * * negative error code if nothing was copied
  */
 static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 		struct iov_iter *iter, ssize_t written)
@@ -2295,6 +2327,9 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
  *
  * This is the "read_iter()" routine for all filesystems
  * that can use the page cache directly.
+ * Return:
+ * * number of bytes copied, even for partial reads
+ * * negative error code if nothing was read
  */
 ssize_t
 generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
@@ -2362,6 +2397,8 @@ EXPORT_SYMBOL(generic_file_read_iter);
  *
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 static int page_cache_read(struct file *file, pgoff_t offset, gfp_t gfp_mask)
 {
@@ -2476,6 +2513,8 @@ static void do_async_mmap_readahead(struct vm_area_struct *vma,
  * has not been released.
  *
  * We never return with VM_FAULT_RETRY and a bit from VM_FAULT_ERROR set.
+ *
+ * Return: bitwise-OR of %VM_FAULT_ codes.
  */
 vm_fault_t filemap_fault(struct vm_fault *vmf)
 {
@@ -2861,6 +2900,8 @@ static struct page *do_read_cache_page(struct address_space *mapping,
  * not set, try to fill the page and wait for it to become unlocked.
  *
  * If the page does not get brought uptodate, return -EIO.
+ *
+ * Return: up to date page on success, ERR_PTR() on failure.
  */
 struct page *read_cache_page(struct address_space *mapping,
 				pgoff_t index,
@@ -2881,6 +2922,8 @@ EXPORT_SYMBOL(read_cache_page);
  * any new page allocations done using the specified allocation flags.
  *
  * If the page does not get brought uptodate, return -EIO.
+ *
+ * Return: up to date page on success, ERR_PTR() on failure.
  */
 struct page *read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index,
@@ -3264,6 +3307,10 @@ EXPORT_SYMBOL(generic_perform_write);
  * This function does *not* take care of syncing data in case of O_SYNC write.
  * A caller has to handle it. This is mainly due to the fact that we want to
  * avoid syncing under i_mutex.
+ *
+ * Return:
+ * * number of bytes written, even for truncated writes
+ * * negative error code if no data has been written at all
  */
 ssize_t __generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
@@ -3348,6 +3395,10 @@ EXPORT_SYMBOL(__generic_file_write_iter);
  * This is a wrapper around __generic_file_write_iter() to be used by most
  * filesystems. It takes care of syncing the file in case of O_SYNC file
  * and acquires i_mutex as needed.
+ * Return:
+ * * negative error code if no data has been written at all of
+ *   vfs_fsync_range() failed for a synchronous write
+ * * number of bytes written, even for truncated writes
  */
 ssize_t generic_file_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
@@ -3374,8 +3425,7 @@ EXPORT_SYMBOL(generic_file_write_iter);
  * @gfp_mask: memory allocation flags (and I/O mode)
  *
  * The address_space is to try to release any data against the page
- * (presumably at page->private).  If the release was successful, return '1'.
- * Otherwise return zero.
+ * (presumably at page->private).
  *
  * This may also be called if PG_fscache is set on a page, indicating that the
  * page is known to the local caching routines.
@@ -3383,6 +3433,7 @@ EXPORT_SYMBOL(generic_file_write_iter);
  * The @gfp_mask argument specifies whether I/O may be performed to release
  * this page (__GFP_IO), and whether the call may block (__GFP_RECLAIM & __GFP_FS).
  *
+ * Return: %1 if the release was successful, otherwise return zero.
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
diff --git a/mm/memory.c b/mm/memory.c
index a52663c..1691648e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1503,6 +1503,8 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
  * under mm->mmap_sem write-lock, so it can change vma->vm_flags.
  * Caller must set VM_MIXEDMAP on vma if it wants to call this
  * function from other places, for example from page-fault handler.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 			struct page *page)
@@ -1830,7 +1832,9 @@ static inline int remap_p4d_range(struct mm_struct *mm, pgd_t *pgd,
  * @size: size of map area
  * @prot: page protection flags for this mapping
  *
- *  Note: this is only safe if the mm semaphore is held when called.
+ * Note: this is only safe if the mm semaphore is held when called.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 		    unsigned long pfn, unsigned long size, pgprot_t prot)
@@ -1903,6 +1907,8 @@ EXPORT_SYMBOL(remap_pfn_range);
  *
  * NOTE! Some drivers might want to tweak vma->vm_page_prot first to get
  * whatever write-combining details or similar.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len)
 {
@@ -2381,12 +2387,13 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
  *
  * This function handles all that is needed to finish a write page fault in a
  * shared mapping due to PTE being read-only once the mapped page is prepared.
- * It handles locking of PTE and modifying it. The function returns
- * VM_FAULT_WRITE on success, 0 when PTE got changed before we acquired PTE
- * lock.
+ * It handles locking of PTE and modifying it.
  *
  * The function expects the page to be locked or other protection against
  * concurrent faults / writeback (such as DAX radix tree locks).
+ *
+ * Return: %VM_FAULT_WRITE on success, %0 when PTE got changed before
+ * we acquired PTE lock.
  */
 vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf)
 {
@@ -3179,6 +3186,8 @@ static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
  *
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
+ *
+ * Return: %0 on success, %VM_FAULT_ code in case of error.
  */
 vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page)
@@ -3239,11 +3248,12 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
  * This function handles all that is needed to finish a page fault once the
  * page to fault in is prepared. It handles locking of PTEs, inserts PTE for
  * given page, adds reverse page mapping, handles memcg charges and LRU
- * addition. The function returns 0 on success, VM_FAULT_ code in case of
- * error.
+ * addition.
  *
  * The function expects the page to be locked and on success it consumes a
  * reference of a page being mapped (for the PTE which maps it).
+ *
+ * Return: %0 on success, %VM_FAULT_ code in case of error.
  */
 vm_fault_t finish_fault(struct vm_fault *vmf)
 {
@@ -4128,7 +4138,7 @@ EXPORT_SYMBOL(follow_pte_pmd);
  *
  * Only IO mappings and raw PFN mappings are allowed.
  *
- * Returns zero and the pfn at @pfn on success, -ve otherwise.
+ * Return: zero and the pfn at @pfn on success, -ve otherwise.
  */
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn)
@@ -4278,6 +4288,8 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
  * @gup_flags:	flags modifying lookup behaviour
  *
  * The caller must hold a reference on @mm.
+ *
+ * Return: number of bytes copied from source to destination.
  */
 int access_remote_vm(struct mm_struct *mm, unsigned long addr,
 		void *buf, int len, unsigned int gup_flags)
diff --git a/mm/mempool.c b/mm/mempool.c
index 0ef8cc8..85efab3 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -222,6 +222,8 @@ EXPORT_SYMBOL(mempool_init_node);
  *
  * Like mempool_create(), but initializes the pool in (i.e. embedded in another
  * structure).
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int mempool_init(mempool_t *pool, int min_nr, mempool_alloc_t *alloc_fn,
 		 mempool_free_t *free_fn, void *pool_data)
@@ -245,6 +247,8 @@ EXPORT_SYMBOL(mempool_init);
  * functions. This function might sleep. Both the alloc_fn() and the free_fn()
  * functions might sleep - as long as the mempool_alloc() function is not called
  * from IRQ contexts.
+ *
+ * Return: pointer to the created memory pool object or %NULL on error.
  */
 mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 				mempool_free_t *free_fn, void *pool_data)
@@ -289,6 +293,8 @@ EXPORT_SYMBOL(mempool_create_node);
  * Note, the caller must guarantee that no mempool_destroy is called
  * while this function is running. mempool_alloc() & mempool_free()
  * might be called (eg. from IRQ contexts) while this function executes.
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 int mempool_resize(mempool_t *pool, int new_min_nr)
 {
@@ -363,6 +369,8 @@ EXPORT_SYMBOL(mempool_resize);
  * *never* fails when called from process contexts. (it might
  * fail if called from an IRQ context.)
  * Note: using __GFP_ZERO is not supported.
+ *
+ * Return: pointer to the allocated element or %NULL on error.
  */
 void *mempool_alloc(mempool_t *pool, gfp_t gfp_mask)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 7d10104..9f61dfe 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -270,7 +270,7 @@ static void wb_min_max_ratio(struct bdi_writeback *wb,
  * node_dirtyable_memory - number of dirtyable pages in a node
  * @pgdat: the node
  *
- * Returns the node's number of pages potentially available for dirty
+ * Return: the node's number of pages potentially available for dirty
  * page cache.  This is the base value for the per-node dirty limits.
  */
 static unsigned long node_dirtyable_memory(struct pglist_data *pgdat)
@@ -355,7 +355,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 /**
  * global_dirtyable_memory - number of globally dirtyable pages
  *
- * Returns the global number of pages potentially available for dirty
+ * Return: the global number of pages potentially available for dirty
  * page cache.  This is the base value for the global dirty limits.
  */
 static unsigned long global_dirtyable_memory(void)
@@ -470,7 +470,7 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
  * node_dirty_limit - maximum number of dirty pages allowed in a node
  * @pgdat: the node
  *
- * Returns the maximum number of dirty pages allowed in a node, based
+ * Return: the maximum number of dirty pages allowed in a node, based
  * on the node's dirtyable memory.
  */
 static unsigned long node_dirty_limit(struct pglist_data *pgdat)
@@ -495,7 +495,7 @@ static unsigned long node_dirty_limit(struct pglist_data *pgdat)
  * node_dirty_ok - tells whether a node is within its dirty limits
  * @pgdat: the node to check
  *
- * Returns %true when the dirty pages in @pgdat are within the node's
+ * Return: %true when the dirty pages in @pgdat are within the node's
  * dirty limit, %false if the limit is exceeded.
  */
 bool node_dirty_ok(struct pglist_data *pgdat)
@@ -743,9 +743,6 @@ static void mdtc_calc_avail(struct dirty_throttle_control *mdtc,
  * __wb_calc_thresh - @wb's share of dirty throttling threshold
  * @dtc: dirty_throttle_context of interest
  *
- * Returns @wb's dirty limit in pages. The term "dirty" in the context of
- * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
- *
  * Note that balance_dirty_pages() will only seriously take it as a hard limit
  * when sleeping max_pause per page is not enough to keep the dirty pages under
  * control. For example, when the device is completely stalled due to some error
@@ -759,6 +756,9 @@ static void mdtc_calc_avail(struct dirty_throttle_control *mdtc,
  *
  * The wb's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
+ *
+ * Return: @wb's dirty limit in pages. The term "dirty" in the context of
+ * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
  */
 static unsigned long __wb_calc_thresh(struct dirty_throttle_control *dtc)
 {
@@ -1918,7 +1918,9 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
  * @wb: bdi_writeback of interest
  *
  * Determines whether background writeback should keep writing @wb or it's
- * clean enough.  Returns %true if writeback should continue.
+ * clean enough.
+ *
+ * Return: %true if writeback should continue.
  */
 bool wb_over_bg_thresh(struct bdi_writeback *wb)
 {
@@ -2147,6 +2149,8 @@ EXPORT_SYMBOL(tag_pages_for_writeback);
  * lock/page writeback access order inversion - we should only ever lock
  * multiple pages in ascending page->index order, and looping back to the start
  * of the file violates that rule and causes deadlocks.
+ *
+ * Return: %0 on success, negative error code otherwise
  */
 int write_cache_pages(struct address_space *mapping,
 		      struct writeback_control *wbc, writepage_t writepage,
@@ -2305,6 +2309,8 @@ static int __writepage(struct page *page, struct writeback_control *wbc,
  *
  * This is a library function, which implements the writepages()
  * address_space_operation.
+ *
+ * Return: %0 on success, negative error code otherwise
  */
 int generic_writepages(struct address_space *mapping,
 		       struct writeback_control *wbc)
@@ -2351,6 +2357,8 @@ int do_writepages(struct address_space *mapping, struct writeback_control *wbc)
  *
  * Note that the mapping's AS_EIO/AS_ENOSPC flags will be cleared when this
  * function returns.
+ *
+ * Return: %0 on success, negative error code otherwise
  */
 int write_one_page(struct page *page)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cde5dac..259bb76 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4743,6 +4743,8 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
  * This function is also limited by MAX_ORDER.
  *
  * Memory allocated by this function must be released by free_pages_exact().
+ *
+ * Return: pointer to the allocated area or %NULL in case of error.
  */
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 {
@@ -4763,6 +4765,8 @@ EXPORT_SYMBOL(alloc_pages_exact);
  *
  * Like alloc_pages_exact(), but try to allocate on node nid first before falling
  * back.
+ *
+ * Return: pointer to the allocated area or %NULL in case of error.
  */
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
@@ -4796,11 +4800,13 @@ EXPORT_SYMBOL(free_pages_exact);
  * nr_free_zone_pages - count number of pages beyond high watermark
  * @offset: The zone index of the highest zone
  *
- * nr_free_zone_pages() counts the number of counts pages which are beyond the
+ * nr_free_zone_pages() counts the number of pages which are beyond the
  * high watermark within all zones at or below a given zone index.  For each
  * zone, the number of pages is calculated as:
  *
  *     nr_free_zone_pages = managed_pages - high_pages
+ *
+ * Return: number of pages beyond high watermark.
  */
 static unsigned long nr_free_zone_pages(int offset)
 {
@@ -4827,6 +4833,9 @@ static unsigned long nr_free_zone_pages(int offset)
  *
  * nr_free_buffer_pages() counts the number of pages which are beyond the high
  * watermark within ZONE_DMA and ZONE_NORMAL.
+ *
+ * Return: number of pages beyond high watermark within ZONE_DMA and
+ * ZONE_NORMAL.
  */
 unsigned long nr_free_buffer_pages(void)
 {
@@ -4839,6 +4848,8 @@ EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
  *
  * nr_free_pagecache_pages() counts the number of pages which are beyond the
  * high watermark within all zones.
+ *
+ * Return: number of pages beyond high watermark within all zones.
  */
 unsigned long nr_free_pagecache_pages(void)
 {
@@ -5285,7 +5296,8 @@ static int node_load[MAX_NUMNODES];
  * from each node to each node in the system), and should also prefer nodes
  * with no CPUs, since presumably they'll have very little allocation pressure
  * on them otherwise.
- * It returns -1 if no node is found.
+ *
+ * Return: node id of the found node or %NUMA_NO_NODE if no node is found.
  */
 static int find_next_best_node(int node, nodemask_t *used_node_mask)
 {
@@ -6208,7 +6220,7 @@ unsigned long __init __absent_pages_in_range(int nid,
  * @start_pfn: The start PFN to start searching for holes
  * @end_pfn: The end PFN to stop searching for holes
  *
- * It returns the number of pages frames in memory holes within a range.
+ * Return: the number of pages frames in memory holes within a range.
  */
 unsigned long __init absent_pages_in_range(unsigned long start_pfn,
 							unsigned long end_pfn)
@@ -6758,7 +6770,7 @@ void __init setup_nr_node_ids(void)
  * model has fine enough granularity to avoid incorrect mapping for the
  * populated node map.
  *
- * Returns the determined alignment in pfn's.  0 if there is no alignment
+ * Return: the determined alignment in pfn's.  0 if there is no alignment
  * requirement (single node).
  */
 unsigned long __init node_map_pfn_alignment(void)
@@ -6813,7 +6825,7 @@ static unsigned long __init find_min_pfn_for_node(int nid)
 /**
  * find_min_pfn_with_active_regions - Find the minimum PFN registered
  *
- * It returns the minimum PFN based on information provided via
+ * Return: the minimum PFN based on information provided via
  * memblock_set_node().
  */
 unsigned long __init find_min_pfn_with_active_regions(void)
@@ -8106,7 +8118,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * pageblocks in the range.  Once isolated, the pageblocks should not
  * be modified by others.
  *
- * Returns zero on success or negative error code.  On success all
+ * Return: zero on success or negative error code.  On success all
  * pages which PFN is in [start, end) are allocated for the caller and
  * need to be freed with free_contig_range().
  */
diff --git a/mm/readahead.c b/mm/readahead.c
index 1ae1652..a459365 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -81,6 +81,8 @@ static void read_cache_pages_invalidate_pages(struct address_space *mapping,
  * @data: private data for the callback routine.
  *
  * Hides the details of the LRU cache etc from the filesystems.
+ *
+ * Returns: %0 on success, error return by @filler otherwise
  */
 int read_cache_pages(struct address_space *mapping, struct list_head *pages,
 			int (*filler)(void *, struct page *), void *data)
diff --git a/mm/slab.c b/mm/slab.c
index 73fe23e..3d1969d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1725,6 +1725,8 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
  * This could be made much more intelligent.  For now, try to avoid using
  * high order pages for slabs.  When the gfp() functions are more friendly
  * towards high-order requests, this should be changed.
+ *
+ * Return: number of left-over bytes in a slab
  */
 static size_t calculate_slab_order(struct kmem_cache *cachep,
 				size_t size, slab_flags_t flags)
@@ -1973,6 +1975,8 @@ static bool set_on_slab_cache(struct kmem_cache *cachep,
  * %SLAB_HWCACHE_ALIGN - Align the objects in this cache to a hardware
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
+ *
+ * Return: a pointer to the created cache or %NULL in case of error
  */
 int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 {
@@ -3533,6 +3537,8 @@ void ___cache_free(struct kmem_cache *cachep, void *objp,
  *
  * Allocate an object from this cache.  The flags are only relevant
  * if the cache has no available objects.
+ *
+ * Return: pointer to the new object or %NULL in case of error
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
@@ -3623,6 +3629,8 @@ EXPORT_SYMBOL(kmem_cache_alloc_trace);
  * node, which can improve the performance for cpu bound structures.
  *
  * Fallback to other node is possible if __GFP_THISNODE is not set.
+ *
+ * Return: pointer to the new object or %NULL in case of error
  */
 void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
@@ -3692,6 +3700,8 @@ EXPORT_SYMBOL(__kmalloc_node_track_caller);
  * @size: how many bytes of memory are required.
  * @flags: the type of memory to allocate (see kmalloc).
  * @caller: function caller for debug tracking of the caller
+ *
+ * Return: pointer to the allocated memory or %NULL in case of error
  */
 static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 					  unsigned long caller)
@@ -4157,6 +4167,8 @@ void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
  * @buffer: user buffer
  * @count: data length
  * @ppos: unused
+ *
+ * Return: %0 on success, negative error code otherwise.
  */
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos)
@@ -4448,6 +4460,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
  * The caller must guarantee that objp points to a valid object previously
  * allocated with either kmalloc() or kmem_cache_alloc(). The object
  * must not be freed during the duration of the call.
+ *
+ * Return: size of the actual memory used by @objp in bytes
  */
 size_t ksize(const void *objp)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 81732d0..edd1368 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -939,6 +939,8 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *
  * Releases as many slabs as possible for a cache.
  * To help debugging, a zero exit status indicates all slabs were released.
+ *
+ * Return: %0 if all slabs were released, non-zero otherwise
  */
 int kmem_cache_shrink(struct kmem_cache *cachep)
 {
@@ -1527,6 +1529,8 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
  * This function is like krealloc() except it never frees the originally
  * allocated buffer. Use this if you don't want to free the buffer immediately
  * like, for example, with RCU.
+ *
+ * Return: pointer to the allocated memory or %NULL in case of error
  */
 void *__krealloc(const void *p, size_t new_size, gfp_t flags)
 {
@@ -1548,6 +1552,8 @@ EXPORT_SYMBOL(__krealloc);
  * lesser of the new and old sizes.  If @p is %NULL, krealloc()
  * behaves exactly like kmalloc().  If @new_size is 0 and @p is not a
  * %NULL pointer, the object pointed to is freed.
+ *
+ * Return: pointer to the allocated memory or %NULL in case of error
  */
 void *krealloc(const void *p, size_t new_size, gfp_t flags)
 {
diff --git a/mm/truncate.c b/mm/truncate.c
index 798e7cc..b7d3c99 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -539,6 +539,8 @@ EXPORT_SYMBOL(truncate_inode_pages_final);
  * invalidate_mapping_pages() will not block on IO activity. It will not
  * invalidate pages which are dirty, locked, under writeback or mapped into
  * pagetables.
+ *
+ * Return: the number of the pages that were invalidated
  */
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
@@ -664,7 +666,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
  * Any pages which are found to be mapped into pagetables are unmapped prior to
  * invalidation.
  *
- * Returns -EBUSY if any pages could not be invalidated.
+ * Return: -EBUSY if any pages could not be invalidated.
  */
 int invalidate_inode_pages2_range(struct address_space *mapping,
 				  pgoff_t start, pgoff_t end)
@@ -761,7 +763,7 @@ EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);
  * Any pages which are found to be mapped into pagetables are unmapped prior to
  * invalidation.
  *
- * Returns -EBUSY if any pages could not be invalidated.
+ * Return: -EBUSY if any pages could not be invalidated.
  */
 int invalidate_inode_pages2(struct address_space *mapping)
 {
diff --git a/mm/util.c b/mm/util.c
index 4df23d6..6aa1f74 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -36,6 +36,8 @@ EXPORT_SYMBOL(kfree_const);
  * kstrdup - allocate space for and copy an existing string
  * @s: the string to duplicate
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Return: newly allocated copy of @s or %NULL in case of error
  */
 char *kstrdup(const char *s, gfp_t gfp)
 {
@@ -58,9 +60,10 @@ EXPORT_SYMBOL(kstrdup);
  * @s: the string to duplicate
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory
  *
- * Function returns source string if it is in .rodata section otherwise it
- * fallbacks to kstrdup.
- * Strings allocated by kstrdup_const should be freed by kfree_const.
+ * Note: Strings allocated by kstrdup_const should be freed by kfree_const.
+ *
+ * Return: source string if it is in .rodata section otherwise
+ * fallback to kstrdup.
  */
 const char *kstrdup_const(const char *s, gfp_t gfp)
 {
@@ -78,6 +81,8 @@ EXPORT_SYMBOL(kstrdup_const);
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory
  *
  * Note: Use kmemdup_nul() instead if the size is known exactly.
+ *
+ * Return: newly allocated copy of @s or %NULL in case of error
  */
 char *kstrndup(const char *s, size_t max, gfp_t gfp)
 {
@@ -103,6 +108,8 @@ EXPORT_SYMBOL(kstrndup);
  * @src: memory region to duplicate
  * @len: memory region length
  * @gfp: GFP mask to use
+ *
+ * Return: newly allocated copy of @src or %NULL in case of error
  */
 void *kmemdup(const void *src, size_t len, gfp_t gfp)
 {
@@ -120,6 +127,9 @@ EXPORT_SYMBOL(kmemdup);
  * @s: The data to stringify
  * @len: The size of the data
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory
+ *
+ * Return: newly allocated copy of @s with NUL-termination or %NULL in
+ * case of error
  */
 char *kmemdup_nul(const char *s, size_t len, gfp_t gfp)
 {
@@ -143,7 +153,7 @@ EXPORT_SYMBOL(kmemdup_nul);
  * @src: source address in user space
  * @len: number of bytes to copy
  *
- * Returns an ERR_PTR() on failure.  Result is physically
+ * Return: an ERR_PTR() on failure.  Result is physically
  * contiguous, to be freed by kfree().
  */
 void *memdup_user(const void __user *src, size_t len)
@@ -169,7 +179,7 @@ EXPORT_SYMBOL(memdup_user);
  * @src: source address in user space
  * @len: number of bytes to copy
  *
- * Returns an ERR_PTR() on failure.  Result may be not
+ * Return: an ERR_PTR() on failure.  Result may be not
  * physically contiguous.  Use kvfree() to free.
  */
 void *vmemdup_user(const void __user *src, size_t len)
@@ -193,6 +203,8 @@ EXPORT_SYMBOL(vmemdup_user);
  * strndup_user - duplicate an existing string from user space
  * @s: The string to duplicate
  * @n: Maximum number of bytes to copy, including the trailing NUL.
+ *
+ * Return: newly allocated copy of @s or %NULL in case of error
  */
 char *strndup_user(const char __user *s, long n)
 {
@@ -224,7 +236,7 @@ EXPORT_SYMBOL(strndup_user);
  * @src: source address in user space
  * @len: number of bytes to copy
  *
- * Returns an ERR_PTR() on failure.
+ * Return: an ERR_PTR() on failure.
  */
 void *memdup_user_nul(const void __user *src, size_t len)
 {
@@ -310,10 +322,6 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * @pages:	array that receives pointers to the pages pinned.
  *		Should be at least nr_pages long.
  *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- *
  * get_user_pages_fast provides equivalent functionality to get_user_pages,
  * operating on current and current->mm, with force=0 and vma=NULL. However
  * unlike get_user_pages, it must be called without mmap_sem held.
@@ -325,6 +333,10 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * pages have to be faulted in, it may turn out to be slightly slower so
  * callers need to carefully consider what to use. On many architectures,
  * get_user_pages_fast simply falls back to get_user_pages.
+ *
+ * Return: number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno.
  */
 int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
@@ -386,6 +398,8 @@ EXPORT_SYMBOL(vm_mmap);
  *
  * Please note that any use of gfp flags outside of GFP_KERNEL is careful to not
  * fall back to vmalloc.
+ *
+ * Return: pointer to the allocated memory of %NULL in case of failure
  */
 void *kvmalloc_node(size_t size, gfp_t flags, int node)
 {
@@ -729,7 +743,8 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
  * @buffer:   the buffer to copy to.
  * @buflen:   the length of the buffer. Larger cmdline values are truncated
  *            to this length.
- * Returns the size of the cmdline field copied. Note that the copy does
+ *
+ * Return: the size of the cmdline field copied. Note that the copy does
  * not guarantee an ending NULL byte.
  */
 int get_cmdline(struct task_struct *task, char *buffer, int buflen)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 215961c..a748165 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -840,7 +840,7 @@ static void *vmap_block_vaddr(unsigned long va_start, unsigned long pages_off)
  * @order:    how many 2^order pages should be occupied in newly allocated block
  * @gfp_mask: flags for the page level allocator
  *
- * Returns: virtual address in a newly allocated block or ERR_PTR(-errno)
+ * Return: virtual address in a newly allocated block or ERR_PTR(-errno)
  */
 static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 {
@@ -1429,6 +1429,8 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
  * Search an area of @size in the kernel virtual mapping area,
  * and reserved it for out purposes.  Returns the area descriptor
  * on success or %NULL on failure.
+ *
+ * Return: the area descriptor on success or %NULL on failure.
  */
 struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
@@ -1451,6 +1453,8 @@ struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
  * Search for the kernel VM area starting at @addr, and return it.
  * It is up to the caller to do all required locking to keep the returned
  * pointer valid.
+ *
+ * Return: pointer to the found area or %NULL on faulure
  */
 struct vm_struct *find_vm_area(const void *addr)
 {
@@ -1470,6 +1474,8 @@ struct vm_struct *find_vm_area(const void *addr)
  * Search for the kernel VM area starting at @addr, and remove it.
  * This function returns the found VM area, but using it is NOT safe
  * on SMP machines, except for its size or flags.
+ *
+ * Return: pointer to the found area or %NULL on faulure
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
@@ -1626,6 +1632,8 @@ EXPORT_SYMBOL(vunmap);
  *
  * Maps @count pages from @pages into contiguous kernel virtual
  * space.
+ *
+ * Return: the address of the area or %NULL on failure
  */
 void *vmap(struct page **pages, unsigned int count,
 	   unsigned long flags, pgprot_t prot)
@@ -1729,6 +1737,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
  * Allocate enough pages to cover @size from the page level
  * allocator with @gfp_mask flags.  Map them into contiguous
  * kernel virtual space, using a pagetable protection of @prot.
+ *
+ * Return: the address of the area or %NULL on failure
  */
 void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			unsigned long start, unsigned long end, gfp_t gfp_mask,
@@ -1787,6 +1797,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
  *
  * Any use of gfp flags outside of GFP_KERNEL should be consulted
  * with mm people.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
@@ -1826,6 +1838,8 @@ void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags,
  *
  * For tight control over page level allocator and protection flags
  * use __vmalloc() instead.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc(unsigned long size)
 {
@@ -1844,6 +1858,8 @@ EXPORT_SYMBOL(vmalloc);
  *
  * For tight control over page level allocator and protection flags
  * use __vmalloc() instead.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vzalloc(unsigned long size)
 {
@@ -1858,6 +1874,8 @@ EXPORT_SYMBOL(vzalloc);
  *
  * The resulting memory area is zeroed so it can be mapped to userspace
  * without leaking data.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc_user(unsigned long size)
 {
@@ -1886,6 +1904,8 @@ EXPORT_SYMBOL(vmalloc_user);
  *
  * For tight control over page level allocator and protection flags
  * use __vmalloc() instead.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc_node(unsigned long size, int node)
 {
@@ -1905,6 +1925,8 @@ EXPORT_SYMBOL(vmalloc_node);
  *
  * For tight control over page level allocator and protection flags
  * use __vmalloc_node() instead.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vzalloc_node(unsigned long size, int node)
 {
@@ -1923,6 +1945,8 @@ EXPORT_SYMBOL(vzalloc_node);
  *
  * For tight control over page level allocator and protection flags
  * use __vmalloc() instead.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc_exec(unsigned long size)
 {
@@ -1948,6 +1972,8 @@ void *vmalloc_exec(unsigned long size)
  *
  * Allocate enough 32bit PA addressable pages to cover @size from the
  * page level allocator and map them into contiguous kernel virtual space.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc_32(unsigned long size)
 {
@@ -1962,6 +1988,8 @@ EXPORT_SYMBOL(vmalloc_32);
  *
  * The resulting memory area is 32bit addressable and zeroed so it can be
  * mapped to userspace without leaking data.
+ *
+ * Return: pointer to the allocated memory or %NULL on error
  */
 void *vmalloc_32_user(unsigned long size)
 {
@@ -2065,10 +2093,6 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
  * @addr:    vm address.
  * @count:   number of bytes to be read.
  *
- * Returns # of bytes which addr and buf should be increased.
- * (same number to @count). Returns 0 if [addr...addr+count) doesn't
- * includes any intersect with alive vmalloc area.
- *
  * This function checks that addr is a valid vmalloc'ed area, and
  * copy data from that area to a given buffer. If the given memory range
  * of [addr...addr+count) includes some valid address, data is copied to
@@ -2082,6 +2106,10 @@ static int aligned_vwrite(char *buf, char *addr, unsigned long count)
  * should know vmalloc() area is valid and can use memcpy().
  * This is for routines which have to access vmalloc area without
  * any informaion, as /dev/kmem.
+ *
+ * Return: number of bytes for which addr and buf should be increased
+ * (same number as @count) or %0 if [addr...addr+count) doesn't
+ * include any intersection with valid vmalloc area
  */
 long vread(char *buf, char *addr, unsigned long count)
 {
@@ -2144,11 +2172,6 @@ long vread(char *buf, char *addr, unsigned long count)
  * @addr:     vm address.
  * @count:    number of bytes to be read.
  *
- * Returns # of bytes which addr and buf should be incresed.
- * (same number to @count).
- * If [addr...addr+count) doesn't includes any intersect with valid
- * vmalloc area, returns 0.
- *
  * This function checks that addr is a valid vmalloc'ed area, and
  * copy data from a buffer to the given addr. If specified range of
  * [addr...addr+count) includes some valid address, data is copied from
@@ -2162,6 +2185,10 @@ long vread(char *buf, char *addr, unsigned long count)
  * should know vmalloc() area is valid and can use memcpy().
  * This is for routines which have to access vmalloc area without
  * any informaion, as /dev/kmem.
+ *
+ * Return: number of bytes for which addr and buf should be
+ * increased (same number as @count) or %0 if [addr...addr+count)
+ * doesn't include any intersection with valid vmalloc area
  */
 long vwrite(char *buf, char *addr, unsigned long count)
 {
-- 
2.7.4

