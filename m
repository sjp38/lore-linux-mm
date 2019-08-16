Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E232CC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:54:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81D232171F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:54:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Pz6eEnVz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81D232171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19A9F6B0007; Fri, 16 Aug 2019 10:54:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 124FE6B0008; Fri, 16 Aug 2019 10:54:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 012806B000A; Fri, 16 Aug 2019 10:54:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0017.hostedemail.com [216.40.44.17])
	by kanga.kvack.org (Postfix) with ESMTP id CE7676B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:54:47 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8524C180AD802
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:54:47 +0000 (UTC)
X-FDA: 75828587814.15.hen37_29c3bc39cfd24
X-HE-Tag: hen37_29c3bc39cfd24
X-Filterd-Recvd-Size: 6789
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:54:46 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id s49so5385158edb.1
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:54:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=RP4Y5+bgIjta9EqVBePgFrEPG0+swd2+E3k4NSriJUA=;
        b=Pz6eEnVzn4gQ6TrMm4eQdUk40FimoUF20fjVEGlI2gS94qWX6Pzs/zCZ1yo+OLTrmw
         84enU9Nsg4GOuSInKa9yiP73hlkYfX0kVeIwY3zCMZnAyUVEUjmTKAw1yZ/cBJgbb3oq
         NtBD+T6KjQsXIfmTGPpayUp70sAibpGMZwBX8Om/swZXcpxK9pd+oFM/OzhGTIX6lHS0
         qeMI0Hfv9/r9QTgxsszYa9SOwOyRpPvrvvQc2LHFA1ChGTmfhhA3DFTp40jV1g8cqdrv
         HsiQd6lfbjCqr7zw5pIVS3JRBQs/bDiFo/9lmsTYT4BB/xQduWuAFyZV5ppoyEgJuhdi
         iITw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=RP4Y5+bgIjta9EqVBePgFrEPG0+swd2+E3k4NSriJUA=;
        b=Wh7hA5VdYqxVN5jAclbNgTt9HTDU7KdgPo5O9AsOEDWeo0C+OTMKeLxtlKJlaH3nwO
         QSBJM3U9CwBf6hByGvQYU5FaiKhX+IFGrZJIqBzJgvj+C//33dyH7TKHDqi07xZsQW82
         RyuvjK2bmx/dbc5JcQjHCDirxAJQI831eBOSfoEDO3n//l7A/d6KL7F3JeKG2AZAw6Ei
         U3zclA6xbW7bZTWlvZlMADbzdXzNk1HlumT3U3BrgWNLARt2cdAHQ7QJ2j3bY2eQgrFA
         P74CxjSmM04Szh0x42PNoJ7ZoKs7l93sqhfx4J8EAvS6CV0XLVVSdKLhkdXY40iv2hWn
         AefA==
X-Gm-Message-State: APjAAAU28MG4ySjkXw8YEiCJpB8QYjNPaB3ZD647ojYrhjgCfcb5/aNY
	6q71aP6bSDnE9aJofo87VAnLM+2mLhg=
X-Google-Smtp-Source: APXvYqz1fk1wUBJVpm+rJIUDDo75k4oj1TMCzrilriH5HBeDsWEjkEcw3bLRLt1fc1S5QBFDGV6+aw==
X-Received: by 2002:a17:907:2101:: with SMTP id qn1mr9779789ejb.3.1565967285579;
        Fri, 16 Aug 2019 07:54:45 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id y12sm831843ejq.40.2019.08.16.07.54.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Aug 2019 07:54:44 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 02AE010490E; Fri, 16 Aug 2019 17:54:43 +0300 (+03)
Date: Fri, 16 Aug 2019 17:54:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Song Liu <songliubraving@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190816145443.6ard3iilytc6jlgv@box>
References: <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <20190813133034.GA6971@redhat.com>
 <20190813140552.GB6971@redhat.com>
 <20190813150539.ciai477wk2cratvc@box>
 <20190813162451.GD6971@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813162451.GD6971@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 06:24:51PM +0200, Oleg Nesterov wrote:
> > Let me see first that my explanation makes sense :P
> 
> It does ;)

Does it look fine to you? It's on top of Song's patchset.

From 58834d6c1e63321af742b208558a6b5cb86fc7ec Mon Sep 17 00:00:00 2001
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Fri, 16 Aug 2019 17:50:41 +0300
Subject: [PATCH] khugepaged: Add comments for retract_page_tables()

Oleg Nesterov pointed that logic behind checks in retract_page_tables()
are not obvious.

Add comments to clarify the reasoning for the checks and why they are
safe.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 5c0a5f0826b2..00cec6a127aa 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1421,7 +1421,22 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 
 	i_mmap_lock_write(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
-		/* probably overkill */
+		/*
+		 * Check vma->anon_vma to exclude MAP_PRIVATE mappings that
+		 * got written to. These VMAs are likely not worth investing
+		 * down_write(mmap_sem) as PMD-mapping is likely to be split
+		 * later.
+		 *
+		 * Not that vma->anon_vma check is racy: it can be set up after
+		 * the check but before we took mmap_sem by the fault path.
+		 * But page lock would prevent establishing any new ptes of the
+		 * page, so we are safe.
+		 *
+		 * An alternative would be drop the check, but check that page
+		 * table is clear before calling pmdp_collapse_flush() under
+		 * ptl. It has higher chance to recover THP for the VMA, but
+		 * has higher cost too.
+		 */
 		if (vma->anon_vma)
 			continue;
 		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
@@ -1434,9 +1449,10 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			continue;
 		/*
 		 * We need exclusive mmap_sem to retract page table.
-		 * If trylock fails we would end up with pte-mapped THP after
-		 * re-fault. Not ideal, but it's more important to not disturb
-		 * the system too much.
+		 *
+		 * We use trylock due to lock inversion: we need to acquire
+		 * mmap_sem while holding page lock. Fault path does it in
+		 * reverse order. Trylock is a way to avoid deadlock.
 		 */
 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
 			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
@@ -1446,8 +1462,10 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			up_write(&vma->vm_mm->mmap_sem);
 			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
-		} else
+		} else {
+			/* Try again later */
 			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
+		}
 	}
 	i_mmap_unlock_write(mapping);
 }
-- 
 Kirill A. Shutemov

