Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD539C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:46:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82C252168B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:46:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MjTBTwPX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82C252168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00DF96B0003; Tue, 25 Jun 2019 23:46:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F006A8E0003; Tue, 25 Jun 2019 23:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEFB38E0002; Tue, 25 Jun 2019 23:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A648D6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:46:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so792498pff.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:46:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jhSS/VU2JvhQ9M+GOpp5nvGB9qw4vPKa3mniPk6Lg+E=;
        b=n3YqIAf8ttf9Ikgld9iNCqDB4/xBeTgV5JPddCzuzaV3TvFRHzAERxPYT70kjUVsRy
         QJpboBlXF/jjjvHx/6ibHtD3dnuZh/tPzftKuwYp+6kLmPNwfqOcf4JfkgVKVon5sOMW
         sNxu0vaNc71CDDl6OwiXfSZDMbaS6hcHQuwR3IuawkvRdcc5Ub/ixMxfC1+aA/fsxnxt
         ilR0Z0+9hV3OXI1Ha4ofaL3kBS7O0Jbbb9NfyHc7wLA9Ll71tXgWdBDXe5PvSneHbOTe
         RiuwM7HLLQWxuTcMufTAOkKQfRTxnjG7u3/Li2BunTjKmBA8pyGCO/+lB1LMwnXzaE1j
         SjIg==
X-Gm-Message-State: APjAAAWWpdu0Wev9MnLcb4kYP2WqC+uw0TfMwtAxip+zgDGN9bYfgDVP
	mbp4zzBG8m763EiJ+m7jKIJcDOyf7PNKFmBhkPKpd9mHVSryFmNfuJmLWwzqSvuBrDM+kBt5OPZ
	kwpJjvinu+M3g9Hs9kbHmv2Jy4hmsF2Ryg7expq+7OinwXQN5idclY825KEwgVDE6Nw==
X-Received: by 2002:a17:902:86:: with SMTP id a6mr2619599pla.244.1561520797355;
        Tue, 25 Jun 2019 20:46:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9dWqLgvjvIhqvdZph/JWUugfpfqSeLMCXKR1RturTrdJwx6UBHsWiYno3Edpqro8rSuQX
X-Received: by 2002:a17:902:86:: with SMTP id a6mr2619546pla.244.1561520796786;
        Tue, 25 Jun 2019 20:46:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561520796; cv=none;
        d=google.com; s=arc-20160816;
        b=ArmQqhmGDjDXgjQ4y8qTQy8y3UD/B+2fFzoC3copPZbO6TvwbHUpvhcJdecEZ8H6EW
         2YTH7wyTrYzoezsXGdg5B0H06fOg2V5rMDqnGFt8kC3KWeoCSBkH5PthrFyPTskq7jWf
         tiSLoqaYjJ80YRkfwgWQwRt87Z6S8oWbEmHqRm4A5aYeFE+lGNjUa9hzMsdAseaLKO4O
         RTe8ZEnBxykatALURC9cymeZg1wYqY3eCmv+q1IcTFAvLYPUaAWswtFqcDSnH+74kPHg
         mfsvusqFY7DREz9QwJGc6SWZbyah2rzxL9SUh16AN0Isnw5QeZWaj+z9bOMuuGv5kRcN
         cMMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=jhSS/VU2JvhQ9M+GOpp5nvGB9qw4vPKa3mniPk6Lg+E=;
        b=eoVe6wDTmWuSROO8nWvBUBGQMDJApjsafiXdEk6DsLQiGlyZeK966GSfEKwRPSGI7Q
         Ib68t4fswPZWqvYHAWFixm+ZWL+yk4EYtut+Bk49RIhZrLfYs4pZ2j30Sf8e/S6iErkI
         G0Aq5MMf9+rqopB6yVdzW2veeDFNJ0+AD4TWjO0TBi9qfYIFNMvIupjVm/Zy29ES/1dd
         WOVEzgCGGvy6em7qFElNnlMncdRTMbDVgkcepM41UL2zYjVGNYmoaYgTZPWj8TjHB8XI
         cITundeUxanczmRjYra4a/m7k3Q2qEIJg4t7pRaP3N8Q3/1fNObhNQfD6ykR3dlftXEB
         49dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MjTBTwPX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z19si16353231pfa.260.2019.06.25.20.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 20:46:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=MjTBTwPX;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (mobile-107-77-172-82.mobile.att.net [107.77.172.82])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 20FF7208CB;
	Wed, 26 Jun 2019 03:46:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561520796;
	bh=6dWU0dNv9cYf+yPMs3W3XUy0ihTiE85lp1iKoVZoxn0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=MjTBTwPXskrnUj7eqa3LdcHIaQRzIHGii9RFD/cg5l19l4WqC1hpOj8gbYUJZC0vK
	 u93ZCujT4smTzV8SKGtlUBzyo7QqhzXZKWsXzZltDjN9YEZ0G4KENvMhVi352IqLiU
	 qlFqtyjQcV4dLOqbfl4eyYqpBhC1KTFdmJh8Vggc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: swkhack <swkhack@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 11/11] mm/mlock.c: change count_mm_mlocked_page_nr return type
Date: Tue, 25 Jun 2019 23:46:01 -0400
Message-Id: <20190626034602.24367-11-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626034602.24367-1-sashal@kernel.org>
References: <20190626034602.24367-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: swkhack <swkhack@gmail.com>

[ Upstream commit 0874bb49bb21bf24deda853e8bf61b8325e24bcb ]

On a 64-bit machine the value of "vma->vm_end - vma->vm_start" may be
negative when using 32 bit ints and the "count >> PAGE_SHIFT"'s result
will be wrong.  So change the local variable and return value to
unsigned long to fix the problem.

Link: http://lkml.kernel.org/r/20190513023701.83056-1-swkhack@gmail.com
Fixes: 0cf2f6f6dc60 ("mm: mlock: check against vma for actual mlock() size")
Signed-off-by: swkhack <swkhack@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index f0505692a5f4..3e7fe404bfb8 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -630,11 +630,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
  * is also counted.
  * Return value: previously mlocked page counts
  */
-static int count_mm_mlocked_page_nr(struct mm_struct *mm,
+static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
 		unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
-	int count = 0;
+	unsigned long count = 0;
 
 	if (mm == NULL)
 		mm = current->mm;
-- 
2.20.1

