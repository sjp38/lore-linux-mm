Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A65FC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A0A5217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A0A5217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC4BB6B0282; Tue, 19 Mar 2019 22:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4C766B0284; Tue, 19 Mar 2019 22:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEE736B0285; Tue, 19 Mar 2019 22:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB34F6B0282
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:10:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k29so19638512qkl.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=bs6QHkKFHQBImeSERvMYc93b5+IKtx0QA2EvCI0MuCU=;
        b=ZlfxEg8nHyxE9IzR9RBkgmq5DHufLPWRacNzDeoQJMq8Edkvmpfafa8GT0cLQXE7Xi
         CMnAoNvACh1Iu8QSOpgXvPSmGJjhETYrkEbHYLWjoST9ita1C70G964zif7QJS/vQGDF
         ZNxhfDxrDhAoFUge4DyBsjlk3/UDrD9DHXwWmHsyLe4ZXkiorcyQkoedKzGTU9qG80Go
         yqrbHybrNh9WO0UlZu60jqM3IIzpj4EDM+cvJA4jPYUDKHh2oDzIwsSc4pT7VDe79kQ2
         CCXlmE5qCwTJlZQ5tWaFGISMCNjwSp6HvRTho/YecJ9wc7BapI9+vXPkvfaolsGZ//gQ
         JLng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXWo+u2Zyp+pblQiR+AQVNIzEKQO3jiZsToQItNJoimR/xdAD0K
	0HMvmHiyEEu4A6Ody4P5N6savuwD3RukS80KUyayknC9PT4bib40hWvY1CdNB9GkHjS8W/OD0OQ
	VDFRZ7tKeVolGhWWX65ePaXfAKFxuJQPkJlZ0kKEiurbmcSKcZ1Vt8GQitt5FV+xMPQ==
X-Received: by 2002:ac8:1638:: with SMTP id p53mr4629145qtj.257.1553047825501;
        Tue, 19 Mar 2019 19:10:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbou+iOPHc3BlDIjiUUUVDyCIiUVHmAPOCAPHr/IVaYqD3roAaobCjctedyO1/H+e0gVgE
X-Received: by 2002:ac8:1638:: with SMTP id p53mr4629089qtj.257.1553047824482;
        Tue, 19 Mar 2019 19:10:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047824; cv=none;
        d=google.com; s=arc-20160816;
        b=DzyNXRhi5WvpvKuAThqzqQRNerXmssckcHOSWT8FokBLWBNxL2H1xDDRXxXh+92dNs
         lKyDlf0yOoPpaUBR+enHmFZQYmWwSiFKqtPnO2oNRz4d6xNBtBvKZ3miEnNz4zZrL/ol
         uQk35ENVoS5iT+c/DMCL8Foy9+Bv8MlWBSSj3Pg92IO7DE2t89rXY6UiAtfuKeMg2PlI
         1giQVe3PfRnk1EJ3ILsPoOhhNrm11pr9sUSnZ2wBAqhmkkeQm0ttUIQGd/MoV2S7uIM7
         GpO3h1CLi2I/U4Y5c2l76hRl6BKVDfTorJ21BYVVjkFj6lOOfxjCiwbeAP9MwWjvmvDZ
         0g/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=bs6QHkKFHQBImeSERvMYc93b5+IKtx0QA2EvCI0MuCU=;
        b=ou7HkaPOiI/VVQoRQ4KzONPFDgMGF9GnUho6MsAnuKRJW2veJgWQwsliYyDBY25G9M
         /JsytpuXhXPCrfPZ3dvEq0pq4JeQhEVCyYa4stS4p5sxagtwq5SfqLMlsGgdN90kDW/5
         PzBpDnywKeH/BRqEpWiOPBFeL/l6es/j4ptYEJupdcrIF/gFqLsvL9n5A0bDAgZof70A
         Yau/SX/yZ6h24ydAkGEcs3gT7w8RJYd24p/v5eKXtLOpR6fB2keCLkZWtwH/pEjguqQj
         MEDKad1c/uiPLLIsWpQv35mYsm7AphIv2Fg9npHtcMtUQRFTCE/m+ZA7NCcziqP34sQ7
         pQgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f50si451776qte.34.2019.03.19.19.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:10:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 95594307D874;
	Wed, 20 Mar 2019 02:10:23 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E522A605CA;
	Wed, 20 Mar 2019 02:10:15 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 25/28] userfaultfd: wp: fixup swap entries in change_pte_range
Date: Wed, 20 Mar 2019 10:06:39 +0800
Message-Id: <20190320020642.4000-26-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 20 Mar 2019 02:10:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In change_pte_range() we do nothing for uffd if the PTE is a swap
entry.  That can lead to data mismatch if the page that we are going
to write protect is swapped out when sending the UFFDIO_WRITEPROTECT.
This patch applies/removes the uffd-wp bit even for the swap entries.

Signed-off-by: Peter Xu <peterx@redhat.com>
---

I kept this patch a standalone one majorly to make review easier.  The
patch can be considered as standalone or to squash into the patch
"userfaultfd: wp: support swap and page migration".
---
 mm/mprotect.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 96c0f521099d..a23e03053787 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -183,11 +183,11 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
 			pages++;
-		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
+		} else if (is_swap_pte(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
+			pte_t newpte;
 
 			if (is_write_migration_entry(entry)) {
-				pte_t newpte;
 				/*
 				 * A protection check is difficult so
 				 * just be safe and disable write
@@ -198,22 +198,24 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					newpte = pte_swp_mksoft_dirty(newpte);
 				if (pte_swp_uffd_wp(oldpte))
 					newpte = pte_swp_mkuffd_wp(newpte);
-				set_pte_at(mm, addr, pte, newpte);
-
-				pages++;
-			}
-
-			if (is_write_device_private_entry(entry)) {
-				pte_t newpte;
-
+			} else if (is_write_device_private_entry(entry)) {
 				/*
 				 * We do not preserve soft-dirtiness. See
 				 * copy_one_pte() for explanation.
 				 */
 				make_device_private_entry_read(&entry);
 				newpte = swp_entry_to_pte(entry);
-				set_pte_at(mm, addr, pte, newpte);
+			} else {
+				newpte = oldpte;
+			}
 
+			if (uffd_wp)
+				newpte = pte_swp_mkuffd_wp(newpte);
+			else if (uffd_wp_resolve)
+				newpte = pte_swp_clear_uffd_wp(newpte);
+
+			if (!pte_same(oldpte, newpte)) {
+				set_pte_at(mm, addr, pte, newpte);
 				pages++;
 			}
 		}
-- 
2.17.1

