Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED8EFC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 05:34:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4F01208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 05:34:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BKUh5c33"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4F01208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 399D88E0003; Wed, 31 Jul 2019 01:34:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A968E0001; Wed, 31 Jul 2019 01:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 213448E0003; Wed, 31 Jul 2019 01:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E12E78E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:34:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g21so42466709pfb.13
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 22:34:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=B809nu+qDvG2keKE9LaOcbN2n/N576RYGU8+2av9Vpw=;
        b=ozwZdtApV76qoG7eIg8l7NxaLxQ/Xgy6wbBn2zwJO4crn6mbJqc0L38kiruaGhcj+m
         INtL5ToSbmYUiN2sYuT3u9OWRArAedoPDBMRGhYVQ0Bma55819JbnFR8ZIn+BTRIuVRk
         hn0n1eqYi0cGG1HQ+4k57xjV1/0Y6mHmCc9xdI2sJN/8dH+aFoKr0kl8JU0vzkkA8pWk
         yC1u8nwa9XhU69iFtaFEobfesNYI9/9xA9W2+YcIcNWO3jn/FB9S3E73gI/WShj4nRkZ
         KHl7Rm1ya2KE0GgfVjkvNcNa4wXvtRdw64VUlXcpdzlCtMiYahE2Hu7VwutsORQTcCsh
         E0RQ==
X-Gm-Message-State: APjAAAWsAuBqBYG4luGvysHbSLzKftdVhixv3fpqnQGIciWGTsSOZUHW
	W3u4dtusgVOqwJEPJOQtHOrJjES6xrKU37NsfJlDX8H+8JRcGImwwMdVNnalbD61SL4iuaGzUTd
	/wYT2fo9GvkVVD63ljBElvhGPT6KQ5xKmciQ/Qfk7v7knVOs35rs2OQblKl8gVrg=
X-Received: by 2002:a63:ec03:: with SMTP id j3mr10291656pgh.325.1564551291313;
        Tue, 30 Jul 2019 22:34:51 -0700 (PDT)
X-Received: by 2002:a63:ec03:: with SMTP id j3mr10291603pgh.325.1564551290355;
        Tue, 30 Jul 2019 22:34:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564551290; cv=none;
        d=google.com; s=arc-20160816;
        b=z+N3S1cmhu+efTvHpMTUa3/XuaJmGXkPtnFAYepqARvCsJYpZWuusDF1RAsM4fZz1W
         GuIHoh/WZEBOdNzwhQqyE/78rGPGNtgwG4XdK59b6t9W6nQ75PdGxVlun2aPQ3bd9DHO
         2nPgxxECqSVr0qzWV84C1SAgVQnLXnuPjPupDabcpo9vyCJ6qUpuUg8q9ERH53oSc0DH
         532DeoQ4/UKdou9wRQ6BMmJ4LQvyGZqrpmdAOqROIB5YuSUEGnuaThHuiIQyP4cd9P58
         pSYnFDDpT6sFFHojkV9BALlD/MI33rZHyZ8onNyuWkJlTSfPGpTW/P1GU/4tvBlHtgCV
         i3vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=B809nu+qDvG2keKE9LaOcbN2n/N576RYGU8+2av9Vpw=;
        b=jFaBJAUEm3wn6DtoifJjBGTkXUE307cFeZWcxq+pP35lAUjsZsYjrXI+hCoXY4HkQa
         8ULl9cBqOO6PNct5zr0Vd0PsEn//rF+yje1TC4TSQwXKxbuWdOouSjg3FjBRv1qqg6jj
         xHEIJWviLrgX3Cd0GUt5JdhyOnRM6Euz8uXv9eB47IC+hjPgGvhCyG+8V+r0piINo4v6
         xrRXJxMO5dM1R3DV2vyCEoatJ4p4Y/y1rlTj1zvi+ixKSw9Gjs+c4vN7kc7thRz+6QK5
         a4jbIll7fJcxGpL63XwoaS73c/PceaU1TIPrSPHfF2BLZm/KBp1QTvSYAC/ntqbHWvNa
         xMxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BKUh5c33;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21sor34887119pgb.48.2019.07.30.22.34.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 22:34:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BKUh5c33;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=B809nu+qDvG2keKE9LaOcbN2n/N576RYGU8+2av9Vpw=;
        b=BKUh5c33i4Ntgitzba1xegNXnbHGi8OMrrIAOhXmxDwbW0jytYqGT3Z+Ijm0vWjhsz
         WAhlCXrxWwYh/aJA+FJFEYQKkEzQzCAkuIW5xrSqkL2PyF34Iji0hJtSmuXRDtKGdT/v
         lYJpJswjCpbn+zPp+3rAoXDlf65TldnlhqWm+4xhWP1ACUgvEm6n96G4mRQVVj/+prTm
         8olrck+rPy2eMksmudzo+TMDkHYFMIz9dKKX/EoJL9cca6pcQVy1xAF92K6NfHUkg1lP
         jbfc8LugwnGaIuEd7NkGM2GVl0u4e2625cfwVFoJrg971WYoHLo08AEIfvVhD736xX5l
         emrg==
X-Google-Smtp-Source: APXvYqzRXtWuiNLN8+b2CexnrxJ2mi6hxZoX1aoOMcOYRIJNJypGE1uhWtsObN2wTtC3QTQze0WLkw==
X-Received: by 2002:a65:64ce:: with SMTP id t14mr46024399pgv.137.1564551289575;
        Tue, 30 Jul 2019 22:34:49 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id u7sm59500233pfm.96.2019.07.30.22.34.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 22:34:48 -0700 (PDT)
Date: Wed, 31 Jul 2019 14:34:44 +0900
From: Minchan Kim <minchan@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
 breaks OOM with swap
Message-ID: <20190731053444.GA155569@google.com>
References: <1564503928.11067.32.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1564503928.11067.32.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:25:28PM -0400, Qian Cai wrote:
> OOM workloads with swapping is unable to recover with linux-next since next-
> 20190729 due to the commit "mm: account nr_isolated_xxx in
> [isolate|putback]_lru_page" breaks OOM with swap" [1]
> 
> [1] https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kernel.org/
> T/#mdcd03bcb4746f2f23e6f508c205943726aee8355
> 
> For example, LTP oom01 test case is stuck for hours, while it finishes in a few
> minutes here after reverted the above commit. Sometimes, it prints those message
> while hanging.
> 
> [  509.983393][  T711] INFO: task oom01:5331 blocked for more than 122 seconds.
> [  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
> [  509.983447][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [  509.983477][  T711] oom01           D24656  5331   5157 0x00040000
> [  509.983513][  T711] Call Trace:
> [  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8 (unreliable)
> [  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
> __switch_to+0x3a4/0x520
> [  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
> __schedule+0x2fc/0x950
> [  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68] schedule+0x58/0x150
> [  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
> rwsem_down_read_slowpath+0x4b4/0x630
> [  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
> down_read+0x12c/0x240
> [  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
> __do_page_fault+0x6f8/0xee0
> [  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
> handle_page_fault+0x18/0x38

Thanks for the testing! No surprise the patch make some bugs because
it's rather tricky.

Could you test this patch?

From b31667210dd747f4d8aeb7bdc1f5c14f1f00bff5 Mon Sep 17 00:00:00 2001
From: Minchan Kim <minchan@kernel.org>
Date: Wed, 31 Jul 2019 14:18:01 +0900
Subject: [PATCH] mm: decrease NR_ISOALTED count at succesful migration

If migration fails, it should go back to LRU list so putback_lru_page
could handle NR_ISOLATED count in pair with isolate_lru_page. However,
if migration is successful, the page will be freed so no need to
add the page back to LRU list. Thus, NR_ISOLATED count should be done
in manually.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/migrate.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 84b89d2d69065..96ae0c3cada8d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1166,6 +1166,7 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 {
 	int rc = MIGRATEPAGE_SUCCESS;
 	struct page *newpage;
+	bool is_lru = __PageMovable(page);
 
 	if (!thp_migration_supported() && PageTransHuge(page))
 		return -ENOMEM;
@@ -1175,17 +1176,10 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		return -ENOMEM;
 
 	if (page_count(page) == 1) {
-		bool is_lru = !__PageMovable(page);
-
 		/* page was freed from under us. So we are done. */
 		ClearPageActive(page);
 		ClearPageUnevictable(page);
-		if (likely(is_lru))
-			mod_node_page_state(page_pgdat(page),
-						NR_ISOLATED_ANON +
-						page_is_file_cache(page),
-						-hpage_nr_pages(page));
-		else {
+		if (unlikely(!is_lru)) {
 			lock_page(page);
 			if (!PageMovable(page))
 				__ClearPageIsolated(page);
@@ -1229,6 +1223,12 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 			if (set_hwpoison_free_buddy_page(page))
 				num_poisoned_pages_inc();
 		}
+
+		if (likely(is_lru))
+			mod_node_page_state(page_pgdat(page),
+					NR_ISOLATED_ANON +
+						page_is_file_cache(page),
+					-hpage_nr_pages(page));
 	} else {
 		if (rc != -EAGAIN) {
 			if (likely(!__PageMovable(page))) {
-- 
2.22.0.709.g102302147b-goog

