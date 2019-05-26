Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE210C282E5
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3F96206BA
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ao5CkBZM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3F96206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FA816B0269; Sun, 26 May 2019 17:22:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55E186B026A; Sun, 26 May 2019 17:22:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425346B026B; Sun, 26 May 2019 17:22:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D36A96B0269
	for <linux-mm@kvack.org>; Sun, 26 May 2019 17:22:27 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id 17so2464659lfr.14
        for <linux-mm@kvack.org>; Sun, 26 May 2019 14:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=zcDlkJTeHrjHVEgzRPAEZQALvFAG5US4eI5mM5YgZuY=;
        b=fPM3UeapCZOQMxYiXnqn504djpmdAXYqSYKYKN7Q+mtRtYyiro5g67RANJl79MTfUw
         k3PyfeIum3n9GjBqojzBtMLT0CpFIHWCF/ar4kVSNTWo2mCp9WzhjVwbyLjSajyLvdZ/
         +Ki3wEgf8VoD+ngpLZRxWD/5y3FKcYhZ7W23ixpBnqMexl0M+9XQ+OEViyE5maveHNnz
         lhvcfRoFjEQO5HSz6M3WO6LDMTNUqf1hKdxZ9IfeZBEz5rjsTi2/6MhFMHuNaM6v9YS9
         WIflZn4IzoIXEsY47eVxKYODwOlVXbir5fOEgwGQfWK2eq4E+X1T5e5ZrCcym6rkygVo
         g6VA==
X-Gm-Message-State: APjAAAWvaSFRPD236J9rlX2wzaFfYHvmAroOFq5quLAjdYQ2uIyxs0ac
	Fc483OI/TpVOfZUgC/yr6ZYQYWWLMyleeGF2SGjzjpdLhHF8TpQlalNH0XUJR9WNsACt/3zETN3
	nOYVxWj55KxeexDve9rwe52NvUmF/MspgZ4FXxyqSDXwQ2D4np9NeB1NjCqktlFBBQQ==
X-Received: by 2002:a19:3f16:: with SMTP id m22mr2130741lfa.104.1558905747315;
        Sun, 26 May 2019 14:22:27 -0700 (PDT)
X-Received: by 2002:a19:3f16:: with SMTP id m22mr2130707lfa.104.1558905746206;
        Sun, 26 May 2019 14:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558905746; cv=none;
        d=google.com; s=arc-20160816;
        b=KA7lf/O1zrHtWLr+iwwwEFG60VrnJTemEW0kqOnkx6m8lDSFn46xbLWk3E11tOOYXb
         kZuQ7w73PmzsTkug+bPZbno7Xv8afx/3+HSBAlg8KZLwrjKF5sr5m9tcBNCVwTysPT7W
         whQCry3K1HDM1q12sm4uz2Ywyw3JD1VY3DMneIIBiK5X9DE1R2hidVPoWKH6tsKKljSZ
         ehnafEvVyuAXa1PI4qNI5EQKl/kVeRZj2yF8zTbstkoQ3LhqFL8sO1uPtFgKFp40mBCQ
         oMJ7U7C7QYXK6mUzXkRiOWdSZYQG4Z5sXKACQHojiv+zyjlEnKOcwXeBFdVMK1H0rP77
         PiHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=zcDlkJTeHrjHVEgzRPAEZQALvFAG5US4eI5mM5YgZuY=;
        b=x1idipNSZ7pxtnHwhm/te8spgvs45TaxKrPwi62F3AHmepi/rxNR/JYR5meq57OWcc
         nP31eBA5UZ4j6FlRr/pnM+3fx481VNp1DsKk5WUkO+5kOZ1UBLMthl6mP6/jMWysuv6T
         MSUJaJb1mZHKCu6IiqPT8FilvqjdnH7/fhrO8SrDaNuMp//mSfws5o0q6T1XoVPBDS+F
         VY645M6IKqjET6FXtChqAX53gVzlMlGx9OQlOMOa4mX8ERwcXXrLutQnmi9/dyLlzAnB
         UT7PQtH7yPQ2pWczsacCITVrn1/2wBtZW8+LigyYiHAe/ypVWaNvILvom825/uEz81m/
         cOKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ao5CkBZM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor2126295lfl.36.2019.05.26.14.22.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 14:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ao5CkBZM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zcDlkJTeHrjHVEgzRPAEZQALvFAG5US4eI5mM5YgZuY=;
        b=Ao5CkBZMIKG8lMZLADM2cFJSxDg0Ojot0t///bzeuKFY03bvOBAnzd/IYRNsnx1egd
         3cx0VIwpT7ShMf+DETVPyhQbGBL4J7Dq99mDqyJg9c16+rDrd31BAiUqhE+YSuLBA84g
         xyPOC78X5H2fEytgSnUVAtMS0oN4D55Qh4L+biWyJ0niL4cwDMbctSZPD0sko/8Wt+NL
         LwcBZwe5kMfaF35crXxjCxAx0oMGBleEaBvzu7biLO379bYGhX9Rla8wNqgEaWl9NWDQ
         Nu5wVqUKH58QonUtZTVWyTbAR65RhJDpanmma1bnW5KnExBlTs7P+ZcleNLu4AQoOqJP
         Y4WA==
X-Google-Smtp-Source: APXvYqxcGZ6X45TO6AjIW2X5VxteP29qd3Xp+Mlo5MYszszCZhtL1+swSlNelKa8z6Y5OwrNMEa4KA==
X-Received: by 2002:ac2:5922:: with SMTP id v2mr164163lfi.180.1558905745839;
        Sun, 26 May 2019 14:22:25 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y4sm1885105lje.24.2019.05.26.14.22.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 14:22:25 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 3/4] mm/vmap: get rid of one single unlink_va() when merge
Date: Sun, 26 May 2019 23:22:12 +0200
Message-Id: <20190526212213.5944-4-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190526212213.5944-1-urezki@gmail.com>
References: <20190526212213.5944-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It does not make sense to try to "unlink" the node that is
definitely not linked with a list nor tree. On the first
merge step VA just points to the previously disconnected
busy area.

On the second step, check if the node has been merged and do
"unlink" if so, because now it points to an object that must
be linked.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b553047aa05b..6f91136f2cc8 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -718,9 +718,6 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
-
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
 
@@ -745,12 +742,12 @@ merge_or_add_vmap_area(struct vmap_area *va,
 			/* Check and update the tree if needed. */
 			augment_tree_propagate_from(sibling);
 
-			/* Remove this VA, it has been merged. */
-			unlink_va(va, root);
+			/* Remove this VA, if it has been merged. */
+			if (merged)
+				unlink_va(va, root);
 
 			/* Free vmap_area object. */
 			kmem_cache_free(vmap_area_cachep, va);
-
 			return;
 		}
 	}
-- 
2.11.0

