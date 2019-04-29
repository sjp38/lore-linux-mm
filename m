Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864AAC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 410962087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 04:54:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 410962087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D38E16B000A; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEB1B6B000E; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDB1D6B0010; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 838586B000A
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 00:54:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v9so6613279pgg.8
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DWrhJvzI4B9THuKSC7ont7yGgnZboxq2WA/aGo3q4Do=;
        b=XqbORAXMbRJNv1zAtgeI5scaUK1S7O5wH42TpsVvtpuyM/DqS1jyBliTLfvMoHzVY3
         +qdJetAI37f/lx+UKYzlbDaMqR3y6XXcxMXeAmLxgpTOjmkNwPJV6L0ZE5k3kRJQXi6x
         3lWeIkeMrgWFAV0xb7wlWYTm2WQTi1oG2JHjQ+GoU/Cpn3NtyfpjWHOSVPHglq/Be45j
         y7JPZ5aimkaApvLeXsBzOd5mC98SCDvKXNfydGH2OxjxpAKj1xZIFnnmWERM7PjW9RmA
         AoeLiV71o/t9yeHVcyjYJSrbbX6sgyCC4mZiU9p743SDrKqw8hlWGPGWOIqcEa0hbNad
         IgtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV7meEkMcUCvVmlcGh/SKuDH6vOcRmh6h5r+xBuyzAwHq2Afa/7
	b5vTxIEt7iHDbdAnijjo8h5SpqwP7Nkey0Zf0/wo2BQcjkGqG2w6Bid3PqXIByY5HIp4AMKVHTP
	imi0ydS0+p09aaF+2vxgRSySyCXfJVt7F5XPVxhandLWVGF2HzkG/eEK1t1hF6ToZ2w==
X-Received: by 2002:a63:5742:: with SMTP id h2mr4587657pgm.194.1556513649181;
        Sun, 28 Apr 2019 21:54:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoy5FP6836ZhKdHWQQo7gIjRcY6+Y4IO62IDz3Gp2eZsD7QejzFWLLSqFxVe46h+39iM8G
X-Received: by 2002:a63:5742:: with SMTP id h2mr4587621pgm.194.1556513648235;
        Sun, 28 Apr 2019 21:54:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556513648; cv=none;
        d=google.com; s=arc-20160816;
        b=kwXad/IlKFGTxhyyqDihFKkWwhHpQoHHzvuT06+xExm8E9rgbNh6/6fYXE5ekOpnJD
         s/0J+9GR7S9CUSujrrRHsS/J1iJcinmiK/oisxpfobb9RLZ0yL4eAIe5sOVHyI3T9K8C
         NYsVUZxo9/o6r3REcla+ZUhUrt2n//u0uNq5oXT1MmAPcJ80naM7SIV4Lloe3sylZnBf
         rGyHOLiJRWiZmYQUbnnfF68aTxce/toU8XEW/2SpnONphpZEF9upY02uX6DRyRu+exxN
         WeahBuogGHX4cJLM8nFdek/SxSeV48XgKUYreEn0zqhKcAtQyxji1POzPv5bgq2BKPWS
         j3Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DWrhJvzI4B9THuKSC7ont7yGgnZboxq2WA/aGo3q4Do=;
        b=m1MWud3NxQqpzdw5FvMk+6/2D/M3YX8pRPFZeIH/g6Q51oixgpAmJn8G5bQpb7F01d
         6XJpYMksJMKBOZbX5SkVF1E/pRkali7DwPpiEwdZKOinUuesSMDZM11wMMXQWPkizLvv
         NUIOtlcTzPYMJ4YiEzPRzIqZEQJEjTeae9NFjT991jCSdUqQ8cGBvqZdIxqoA1Fl+81k
         EMbQE2OQPwSRp+SIDo3V+N0eNFS4O4vL5Lr0J8uy3neaI4/SyDm8eouVlX7X/A0cdjnD
         uTmsetEhDXB/0KEy19UXocsRjcJ7+pBCCo8Oh/o38b2n+F3LIV6hNaeIzajFf/8LfKBG
         Hi1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m184si14181099pfb.166.2019.04.28.21.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 21:54:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Apr 2019 21:54:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,408,1549958400"; 
   d="scan'208";a="146566289"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Apr 2019 21:54:07 -0700
From: ira.weiny@intel.com
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH 04/10] WIP: mm/gup: Ensure F_LONGTERM lease is held on GUP pages
Date: Sun, 28 Apr 2019 21:53:53 -0700
Message-Id: <20190429045359.8923-5-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190429045359.8923-1-ira.weiny@intel.com>
References: <20190429045359.8923-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Honestly I think I should remove this patch.  It is removed later in the
series and ensuring the lease is there at GUP time does not guarantee
the lease is held.  The user could remove the lease???

Regardless the code in GUP to take the lease holds it even if the user
does try to remove it and will take the lease back if they race and the
lease is remove prior to the GUP getting a reference to it...

So pretty much anyway you slice it this patch is not needed...

FOLL_LONGTERM pins are currently disabled for GUP calls which map to FS
DAX files.  As an alternative allow these files to be mapped if the user
has taken a F_LONGTERM lease on the file.

The intention is that the user is aware of the dangers of file
truncated/hole punch and accepts

file which has been mapped this way (such as is done
with RDMA) and they have taken this lease to indicate they will accept
the behavior if the filesystem needs to take action.

Example user space pseudocode for a user using RDMA and reacting to a
lease break of this type would look like this:

    lease_break() {
    ...
            if (sigio.fd == rdma_fd) {
                    ibv_dereg_mr(mr);
                    close(rdma_fd);
            }
    }

    foo() {
            rdma_fd = open()
            fcntl(rdma_fd, F_SETLEASE, F_LONGTERM);
            sigaction(SIGIO, ...  lease_break ...);
            ptr = mmap(rdma_fd, ...);
            mr = ibv_reg_mr(ptr, ...);
    }

Failure to process the SIGIO as above will result in a SIGBUS being
given to the process.  SIGBUS is implemented in later patches.

This patch X of Y fails the FOLL_LONGTERM pin if the FL_LONGTERM lease
is not held.
---
 fs/locks.c         | 47 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h |  2 ++
 mm/gup.c           | 13 +++++++++++++
 mm/huge_memory.c   | 20 ++++++++++++++++++++
 4 files changed, 82 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 8ea1c5713e6a..31c8b761a578 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2939,3 +2939,50 @@ static int __init filelock_init(void)
 	return 0;
 }
 core_initcall(filelock_init);
+
+// FIXME what about GUP calls to Device DAX???
+// I believe they will still return true for *_devmap
+//
+// return true if the page has a LONGTERM lease associated with it's file.
+bool mapping_inode_has_longterm(struct page *page)
+{
+	bool ret;
+	struct inode *inode;
+	struct file_lock *fl;
+	struct file_lock_context *ctx;
+
+	/*
+	 * should never be here unless we are a "page cache" page without a
+	 * page cache.
+	 */
+	if (WARN_ON(PageAnon(page)))
+		return false;
+	if (WARN_ON(!page))
+		return false;
+	if (WARN_ON(!page->mapping))
+		return false;
+	if (WARN_ON(!page->mapping->host))
+		return false;
+
+	/* Ensure page->mapping isn't freed while we look at it */
+	/* FIXME mm lock is held here I think?  so is this really needed? */
+	rcu_read_lock();
+	inode = page->mapping->host;
+
+	ctx = locks_get_lock_context(inode, F_RDLCK);
+
+	ret = false;
+	spin_lock(&ctx->flc_lock);
+	list_for_each_entry(fl, &ctx->flc_lease, fl_list) {
+		if (fl->fl_flags & FL_LONGTERM) {
+			ret = true;
+			break;
+		}
+	}
+	spin_unlock(&ctx->flc_lock);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mapping_inode_has_longterm);
+
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 77e34ec5dfbe..cde359e71b7b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1572,6 +1572,8 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages);
 
+bool mapping_inode_has_longterm(struct page *page);
+
 /* Container for pinned pfns / pages */
 struct frame_vector {
 	unsigned int nr_allocated;	/* Number of frames we have space for */
diff --git a/mm/gup.c b/mm/gup.c
index a8ac75bc1452..5ae1dd31a58d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -292,6 +292,12 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			page = pte_page(pte);
 		else
 			goto no_page;
+
+		if (unlikely(flags & FOLL_LONGTERM) &&
+		    !mapping_inode_has_longterm(page)) {
+			page = ERR_PTR(-EINVAL);
+			goto out;
+		}
 	} else if (unlikely(!page)) {
 		if (flags & FOLL_DUMP) {
 			/* Avoid special (like zero) pages in core dumps */
@@ -1869,6 +1875,13 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		}
 		SetPageReferenced(page);
 		pages[*nr] = page;
+
+		if (unlikely(flags & FOLL_LONGTERM) &&
+		    !mapping_inode_has_longterm(page)) {
+			undo_dev_pagemap(nr, nr_start, pages);
+			return 0;
+		}
+
 		if (get_gup_pin_page(page)) {
 			undo_dev_pagemap(nr, nr_start, pages);
 			return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 404acdcd0455..8819624c740f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -910,6 +910,16 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	// Check for Layout lease.
+	// FIXME combine logic
+	if (unlikely(flags & FOLL_LONGTERM)) {
+		WARN_ON_ONCE(PageAnon(page));
+		if (!mapping_inode_has_longterm(page)) {
+			return NULL;
+		}
+	}
+
 	get_page(page);
 
 	return page;
@@ -1050,6 +1060,16 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 	if (!*pgmap)
 		return ERR_PTR(-EFAULT);
 	page = pfn_to_page(pfn);
+
+	// Check for LONGTERM lease.
+	// FIXME combine logic remove Warn
+	if (unlikely(flags & FOLL_LONGTERM)) {
+		WARN_ON_ONCE(PageAnon(page));
+		if (!mapping_inode_has_longterm(page)) {
+			return NULL;
+		}
+	}
+
 	get_page(page);
 
 	return page;
-- 
2.20.1

