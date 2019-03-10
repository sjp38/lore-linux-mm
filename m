Return-Path: <SRS0=tu4S=RN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17128C43381
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 20:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0BF520652
	for <linux-mm@archiver.kernel.org>; Sun, 10 Mar 2019 20:01:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="bc2gNDeY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0BF520652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CC708E0005; Sun, 10 Mar 2019 16:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A1B8E0002; Sun, 10 Mar 2019 16:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292418E0005; Sun, 10 Mar 2019 16:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0076A8E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 16:01:15 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z13so2836943qkf.14
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 13:01:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=cJzQZJGS3u6X82yZ/MtBJfkke08BS/hFxdt9Bk28ewU=;
        b=TenQXCdUDMlZmzglgTsK3VTSSYqPdSk0lS+pw3qy3w3SAmJyJJWO+VUNSs/RptaV3G
         dEJTZyL9/XKaRUad2E1L+ldf0+fdkaR2dSmtFxMez1dFLQT9C8X3AQAFNt64X2SQu8kj
         gQCU0nX9Fc+O9DofJXnurL8X9eP/15uw85LW9cuEhSwhSXMZFHUPLy4CMh5uVS2Jttt6
         hzqsjGgJpWQsFfW9fqdNU7YGXelB0kFp4fR2TVyrNG23mU6xIA2CR2jX92gr6wmX37XR
         2eLv73+w3S0T5afLmvvIT5BtFZr3iqHbKTTWpZpk/UowK95VxH7h41oPOYvA+dJdEQur
         I6pg==
X-Gm-Message-State: APjAAAUExC8bjySegzZvNSagZPHdIWD9uwEVCZkR/hOXQrdjIMH4SX9Y
	lYFOnTz46G69b15yG0XpFbThgRe7pVV4CHT+xGQ7z/yGGYo0GJSBQvoL3+GkXZvMyZ7mSEfQg69
	AqwBF381bykNYd+ue/NfIyp9NXuedBVE3auZ2Ifxf0Wahnn4+ivLiblV+wNKbeL0Fwhz2g75uvj
	L3w3wDnLDzqIKiku+KJXxnq5REwZeu2/wStLsyNhNkdI2dokutu2asx4U/q8fC6NfUg+kKYgu8m
	9oFG9r10zJ6Y9rTMuC2fJ26Nnk0BvTnriJI9BOhrNLCr76fIDp2FGfzalsNnv0k9jxZwR7yQQ5b
	K29gu+vxlRhtXQuxRtCC2w28Mv8HaJGgZjoLMFqoOEMERboBR6fg9ZVdpHORegPc0HV157AVtUa
	0
X-Received: by 2002:a05:620a:10b2:: with SMTP id h18mr6267753qkk.211.1552248075658;
        Sun, 10 Mar 2019 13:01:15 -0700 (PDT)
X-Received: by 2002:a05:620a:10b2:: with SMTP id h18mr6267715qkk.211.1552248074836;
        Sun, 10 Mar 2019 13:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552248074; cv=none;
        d=google.com; s=arc-20160816;
        b=F5NjD1+CjEb1YkqnnZN7IYCpxQRzYHZqEAjvbK59LKRbYA804o+N1Ln+D//kVRtRyw
         243FVtpwH/tcLy93snJxqVqsxtcz1ywJDEfeqloBQFj98HSjGf+1u+msI8sjyrBVsWy1
         ZmgYPhvgsgN2bxQkyobQwel1vYp0LVznvPq6XFCE4ynj7XBsKeCTSUBSlp3jiiEwZT05
         LWwveO5oDKghVa3KSB8oxp2hywdX3zN+pZbRyKeIk5Qgb5BuHEVcVMA5TU9Nt9qGrjOa
         28iNrqNx6EYOBFnDy04GI4GLXbck13vpga2Cg0N/p1SfcftdponmPg3z32TwvjQckKzn
         8qtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=cJzQZJGS3u6X82yZ/MtBJfkke08BS/hFxdt9Bk28ewU=;
        b=mFEXlWY5g02TqT5kAVheLy/oG1cOrPI51AdG4uSH03ZvVfN/53PEr1ldqxjs1Z2Lqd
         TGzZJYHN7YZzPNPRlb/0Qcflkg63AWFsweBkEGMdfyW+LXnYQ8XkKUg+fVNnwSlZfdRN
         i2L6LueW2REaO0Bm/IkVSPH7E1SKOif8yk6Gh2QDCj15WGXoDFN+S31Tg3T0dlc9ujyL
         JaNg+QtB8O6K/ysBJsMenZhrn7Zdy7FENqNHQesEHf5DGjc98p9eSJZheYKzALyjcFbU
         KqLFUL10nfFkU3lPFCYx0AUkXfz4VJcP+8hvn/aL0+1vuKW71FR8oKfaWyBeDt42t/SW
         OVmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bc2gNDeY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e27sor4025327qvh.65.2019.03.10.13.01.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Mar 2019 13:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=bc2gNDeY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=cJzQZJGS3u6X82yZ/MtBJfkke08BS/hFxdt9Bk28ewU=;
        b=bc2gNDeYf6gDx3Yr3oQIeqvlH4mJsYHUhfZ1+LC+UjBPBRDDX5hwmcC+qNhr5HcH4p
         xE89kZjSVpwK2nAfwhyP0W1GrZr/pOCLlncHTInpN0FUTPKX5usrc6ffiwTCwb9dNO+m
         rSjfRu2emN1m4XZT6uksSk7mchCKi7fe/Efl7+ATZEUIiSnMa2rwDXpi4LHlriEkNPMo
         FWTtsdDolQZDYnKo6Q2v89MWozhanuIeFTTYVd6ZNyUV6t9+1xgkCr+Xh3o5jxuYJoVg
         HLgp2gmTuSIVfKDv8SJfIVeQ0FUb/gNUibpOmvfrCrhcmI6StAHlS4Zd0nZfAq62AgHT
         kMxA==
X-Google-Smtp-Source: APXvYqy43fpnSl61MlAaf6NcvNVwq1vbUnCoIdIqy0jXzR5xcuDTtfUMGWMtYF/5yU3isT1d1VT2Sg==
X-Received: by 2002:ad4:5190:: with SMTP id b16mr2614239qvp.100.1552248074382;
        Sun, 10 Mar 2019 13:01:14 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s76sm2263077qki.42.2019.03.10.13.01.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 13:01:13 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [RESEND PATCH] mm/hotplug: don't reset pagetype flags for offline
Date: Sun, 10 Mar 2019 16:01:02 -0400
Message-Id: <20190310200102.88014-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
memory to zones until online") introduced move_pfn_range_to_zone() which
calls memmap_init_zone() during onlining a memory block.
memmap_init_zone() will reset pagetype flags and makes migrate type to
be MOVABLE.

However, in __offline_pages(), it also call undo_isolate_page_range()
after offline_isolated_pages() to do the same thing. Due to
the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
pages") changed __first_valid_page() to skip offline pages,
undo_isolate_page_range() here just waste CPU cycles looping around the
offlining PFN range while doing nothing, because __first_valid_page()
will return NULL as offline_isolated_pages() has already marked all
memory sections within the pfn range as offline via
offline_mem_sections().

Also, after calling the "useless" undo_isolate_page_range() here, it
reaches the point of no returning by notifying MEM_OFFLINE. Those pages
will be marked as MIGRATE_MOVABLE again once onlining. In addition, fix
an incorrect comment along the way.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memory_hotplug.c | 2 --
 mm/sparse.c         | 2 +-
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6b05576fb4ec..46017040b2f8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1655,8 +1655,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
-	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
diff --git a/mm/sparse.c b/mm/sparse.c
index 77a0554fa5bd..b3771f35a0ed 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -556,7 +556,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-/* Mark all memory sections within the pfn range as online */
+/* Mark all memory sections within the pfn range as offline */
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
-- 
2.17.2 (Apple Git-113)

