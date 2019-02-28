Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C91EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0FB0218AC
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0FB0218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 688EB8E0005; Wed, 27 Feb 2019 21:18:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 636738E0001; Wed, 27 Feb 2019 21:18:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54E868E0005; Wed, 27 Feb 2019 21:18:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8618E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:46 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id q17so17102892qta.17
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ap32u9J2DjTEbnwK8tlI9EaVEAe0C092XmNehyAz4/8=;
        b=YPzHxIZBfDm54FIvs3XaSnxjdXtakf0bYHNhOC+yPKxhJtklFMQhdIUMixplAhX17h
         Gpr01Q48ljg9ZI7hts2W9U6y4Rg4ET6AyEQDyPCSWbyan7/89i35afxuRmoZvtU8Z1HO
         TJ4MpPkZerEKanuNxpE71SRYehw2qzzfb8pnYNETzZ2lJilUoWxM8gIaiyy8timBrsZu
         SZgQhhbTtgZzbx7Fp4fvRhXHq9mlRcQIVGqzsAhpiJ0OiitlvoWE6NZdgCWgShYUkBiK
         PEcVlfivLCBr1lTVO68ssPodY8WesxYXtk5/VUR7lqQq/orHUwYnEXR1Kyr+aw0AxfOl
         x92g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuY6KCBwMecTJ27LUIpXLUcqHjZjLpYu8et7FTA26JzrXV8jaP0e
	EW75xSY0n7sT2hSxCnpL4oSXPDTnTF1iCKA1IyYmdFPiJ43DmVD3Y5HCA7oyRa2BbOKr7yMhFVB
	vEDWrTUAkEQ8M+sPcHqtLun26LlF10vQ9OIIh4nevfYKsbYdafwdf1C12HuPo9Ts7tSsltk1z//
	39IEmerUY7A5aXl2p0JJZtNr4KFttFkVWNWxFBH+B7Am7riFp6LXxn9OgRKvYPPlxV86k9rVVDt
	KcYspnROjtovA6zS2gsP7Ij/8EQmkFl85bYWBYI3QtR0lYK8vKYkUUJF7ve9h/b1RZ3knFbt0Ju
	aAHc7eM0753zf8JPWB0T6VVnLh0DiKwYYkXBmf47SMRAzlijK4unHtj+PwuuXBxDodtuxoUvZg=
	=
X-Received: by 2002:ac8:f76:: with SMTP id l51mr4306194qtk.248.1551320325928;
        Wed, 27 Feb 2019 18:18:45 -0800 (PST)
X-Received: by 2002:ac8:f76:: with SMTP id l51mr4306170qtk.248.1551320325262;
        Wed, 27 Feb 2019 18:18:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320325; cv=none;
        d=google.com; s=arc-20160816;
        b=CBTY2Vfi+AikBk6jCjNT2kgjEuPRBzFuKC+OXhKBQdngO1ME3SifzlM/6ef35CEyyy
         n0Tlc9uu4vzTrT5u/swBBxyVEyqe2YQ5nuB0M0EYqQgAjFnabP8zhdrf7Basx0OWE9b3
         lEnBjPUC6U5d430xx1qx3POK3JyqdnxeQ/x2ThomhKggJE9zzo5SSc38YG0eTUOLbP5/
         7/5YlH1GCoJ2Ioi9vQI3s0lyNcw1uKSSf1/vikYzmxd8dxt/MymfOJQ0AWjnxYvpRdsH
         x6X37xSwE+X+CeX3kfYFWFrjy429Z403HZftOYCAh/0jpqtImp/n0BGGoT3o9l9YryWH
         Cj3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ap32u9J2DjTEbnwK8tlI9EaVEAe0C092XmNehyAz4/8=;
        b=QpkN+RUpjFhssCDlkNT3jB4X2ICdVGPd76C614AeO4XfXUHCo4Li0OOOAQWqFTd/fI
         IgGKd9jLdM6LD0USEIEyfuBSXqs8v7jpvA9TtEKnbdgf7zqFAfW+gc1Qd0sgFF46EgSs
         bOOvshDt0mafTHF+5FECa3LqvTKf3b1LW3pvoW3+hi29NE+ADFjsuHI+Ik0f0+WlNol4
         D4Eux5Rvq/NW0krMGK85d4pNwvZpWIkrXnmtBeEL6sVBF9jwmp9gjZKA27iUcAh0VBwQ
         yoCeKUhBMYcJxXy5KW4n9UGc4V84o45u/aOemgZb1f4QmEem3l31kHw2mufM8lscG/JG
         Y0Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor9786587qkg.4.2019.02.27.18.18.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:45 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3Ib9npUsIiyGRCnSbW0Gjjezvhtl8EJKNhNK6/9zB6/aj4x+e7X7Rv/8FH7Vb9liQTh/0R1Mrw==
X-Received: by 2002:a37:61d3:: with SMTP id v202mr4658157qkb.217.1551320325029;
        Wed, 27 Feb 2019 18:18:45 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:43 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 01/12] percpu: update free path with correct new free region
Date: Wed, 27 Feb 2019 21:18:28 -0500
Message-Id: <20190228021839.55779-2-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When updating the chunk's contig_hint on the free path of a hint that
does not touch the page boundaries, it was incorrectly using the
starting offset of the free region and the block's contig_hint. This
could lead to incorrect assumptions about fit given a size and better
alignment of the start. Fix this by using (end - start) as this is only
called when updating a hint within a block.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index db86282fd024..53bd79a617b1 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -871,7 +871,7 @@ static void pcpu_block_update_hint_free(struct pcpu_chunk *chunk, int bit_off,
 		pcpu_chunk_refresh_hint(chunk);
 	else
 		pcpu_chunk_update(chunk, pcpu_block_off_to_off(s_index, start),
-				  s_block->contig_hint);
+				  end - start);
 }
 
 /**
-- 
2.17.1

