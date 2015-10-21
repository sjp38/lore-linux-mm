Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8222B82F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:14:58 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so44457554qkb.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:14:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b16si9748472qkj.55.2015.10.21.13.14.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:14:57 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH v11 09/14] HMM: allow to get pointer to spinlock protecting a directory.
Date: Wed, 21 Oct 2015 17:10:14 -0400
Message-Id: <1445461819-2675-10-git-send-email-jglisse@redhat.com>
In-Reply-To: <1445461819-2675-1-git-send-email-jglisse@redhat.com>
References: <1445461819-2675-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Several use case for getting pointer to spinlock protecting a directory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/hmm_pt.h | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/include/linux/hmm_pt.h b/include/linux/hmm_pt.h
index f745d6c..22100a6 100644
--- a/include/linux/hmm_pt.h
+++ b/include/linux/hmm_pt.h
@@ -255,6 +255,16 @@ static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
 		spin_lock(&pt->lock);
 }
 
+static inline spinlock_t *hmm_pt_directory_lock_ptr(struct hmm_pt *pt,
+						    struct page *ptd,
+						    unsigned level)
+{
+	if (level)
+		return &ptd->ptl;
+	else
+		return &pt->lock;
+}
+
 static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
 					   struct page *ptd,
 					   unsigned level)
@@ -272,6 +282,13 @@ static inline void hmm_pt_directory_lock(struct hmm_pt *pt,
 	spin_lock(&pt->lock);
 }
 
+static inline spinlock_t *hmm_pt_directory_lock_ptr(struct hmm_pt *pt,
+						    struct page *ptd,
+						    unsigned level)
+{
+	return &pt->lock;
+}
+
 static inline void hmm_pt_directory_unlock(struct hmm_pt *pt,
 					   struct page *ptd,
 					   unsigned level)
@@ -358,6 +375,14 @@ static inline void hmm_pt_iter_directory_lock(struct hmm_pt_iter *iter)
 	hmm_pt_directory_lock(pt, iter->ptd[pt->llevel - 1], pt->llevel);
 }
 
+static inline spinlock_t *hmm_pt_iter_directory_lock_ptr(struct hmm_pt_iter *i)
+{
+	struct hmm_pt *pt = i->pt;
+
+	return hmm_pt_directory_lock_ptr(pt, i->ptd[pt->llevel - 1],
+					 pt->llevel);
+}
+
 static inline void hmm_pt_iter_directory_unlock(struct hmm_pt_iter *iter)
 {
 	struct hmm_pt *pt = iter->pt;
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
