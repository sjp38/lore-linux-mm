Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0183C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:08:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B61720823
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 08:08:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="U6WZCxft"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B61720823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDCE36B0006; Wed, 19 Jun 2019 04:08:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8DE98E0002; Wed, 19 Jun 2019 04:08:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C56418E0001; Wed, 19 Jun 2019 04:08:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B3756B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 04:08:40 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so11201628pfc.2
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=hDeVdBWWPPTkbBXHklX8Rt51hyYEzQf0jmQ1XrF86ag=;
        b=fCfIvBK5ajYGmBEgAVUQcuj/v4EBUMzx2rH0mtJIpBMv5xSQi80nmsEG1GFt6MCw3e
         CFvWriN0/Ugz6Ds2jw8gYLAcP737YUvlXoU96DQHpyLF4tAyW4OKtW/jN2h2n4ID1eC6
         qCqUGMcA4oEf9P0SRVEnsRu5VE/6mkYKuVhzb9XhsMET0yx4X0f/XfkZbeVxjaNZsOAD
         ebVJL7ZqBQBBvbmDrJEwwHwOdLw5Nz/JO5kvxtp7b4rXlud34nsEKE8SIL0vlYSbpz12
         Nn9jm4EH5A/MBOOq4hrZ7ltFKZttHY0QIGVkrmvEckqcbVPhbaLTskP8wtbC1OI/Ppy6
         tAsA==
X-Gm-Message-State: APjAAAWlmEWy+VzYAFe6C4QaBBAGamIjK+r3XoibqQUjdyXhgCZzPOJ2
	g/tShCkzTaTiu0qG+y/IRljHDAz2lgp6Ps6eGW7I1aMLS62i6zGm6oHS1io0JjtHvPCsx4HKv6i
	yUwsVbv8Ychd9cXb6+tl7zlN5NGGjxgqzK4uf3FkmJhmqZv7XQcWr1caEILB8si1z6Q==
X-Received: by 2002:a62:2f04:: with SMTP id v4mr8458424pfv.14.1560931720157;
        Wed, 19 Jun 2019 01:08:40 -0700 (PDT)
X-Received: by 2002:a62:2f04:: with SMTP id v4mr8458355pfv.14.1560931719240;
        Wed, 19 Jun 2019 01:08:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560931719; cv=none;
        d=google.com; s=arc-20160816;
        b=iqXwOnqnCZB4DJ/exa8GnTcq30yQUOkJbf1Je3ZAEKNZS7KvK8XMVgQ6hoJLWgm+hC
         cMVBG1xs62N3J2vwK+O78C9Xclk/yW/c+8F8qC/XooJhYj5vW47cQrXF7E+G06DcRe3z
         rYy+15dr8PZ9VMvwrpVED+pelo0TgOZ+jBgtkhrJIR7QgGg/NE8KGorWnkvpWyLkaVmE
         PqrnwYZ01S7K3EejjH21vq8TRi5CI+VghHSMv+8h9M1hANONyl/6YZxtskB73XvbFwg6
         GD3s9pZOXBThRHkgrJB6808UmPeucsuwvM2VoLnN6vPD04lY3qCLlGhjGBtwtEHHB2ei
         0grw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=hDeVdBWWPPTkbBXHklX8Rt51hyYEzQf0jmQ1XrF86ag=;
        b=ZnNmljolVp99qN2jfPP5F8AWaG1li9V1Skhdl7PQh+ranja/2iT5BLexwoiUQBvKcz
         EXCnEaK2dLyu0UzdQqLpr4P1zgE9PzR56qbpVDmkL7CLgldC7PceaOo43TixYse27kTv
         sC7zJ9E6i9V6bIAYNg2QWoFc0Kxrj435KtH4VnwwABKAA4MwTzGY+gMAoY3cHd+VzDN5
         qZSxYnsca4GfRf/LYezYfKgC4pOaMppcgqguCiAhnmJzd2loEEKv7SMET7iHj6+aADgm
         NVGzBCL8usXHuGPMniWaPFxSBEWkucg+hxyJ5qo8uwSzYPt+fA+3snZo77w1k/C/02aX
         xRiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U6WZCxft;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p61sor20455130plb.47.2019.06.19.01.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 01:08:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=U6WZCxft;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=hDeVdBWWPPTkbBXHklX8Rt51hyYEzQf0jmQ1XrF86ag=;
        b=U6WZCxft1YmIyjwH5Znr6VX8IS/f71mPVNA/6CormE/HP80HaNHImYH+aM1yKclQRS
         KCCZkUoz8mjPWW++D5Z9ltxghClm58t9I54NwSBZ8Tuv7YxrBqdbm8nkyUG5CuHaGJkZ
         PFhFI26MFip3NWmg15ii8LdoQVSa3a2dWvRdY=
X-Google-Smtp-Source: APXvYqy0Rhm4TA+2ZMv3rfgXXv14ZYAZHjJV4QK7rYCsewfrnKIbNiKGk15ogGJUnV+a1ciO9lI0vA==
X-Received: by 2002:a17:902:903:: with SMTP id 3mr93535586plm.281.1560931718751;
        Wed, 19 Jun 2019 01:08:38 -0700 (PDT)
Received: from google.com ([2401:fa00:1:b:d89e:cfa6:3c8:e61b])
        by smtp.gmail.com with ESMTPSA id c26sm740179pfr.172.2019.06.19.01.08.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 19 Jun 2019 01:08:38 -0700 (PDT)
Date: Wed, 19 Jun 2019 16:08:35 +0800
From: Kuo-Hsin Yang <vovoy@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	Kuo-Hsin Yang <vovoy@chromium.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] mm: vmscan: fix not scanning anonymous pages when detecting
 file refaults
Message-ID: <20190619080835.GA68312@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When file refaults are detected and there are many inactive file pages,
the system never reclaim anonymous pages, the file pages are dropped
aggressively when there are still a lot of cold anonymous pages and
system thrashes. This issue impacts the performance of applications with
large executable, e.g. chrome.

When file refaults are detected. inactive_list_is_low() may return
different values depends on the actual_reclaim parameter, the following
2 conditions could be satisfied at the same time.

1) inactive_list_is_low() returns false in get_scan_count() to trigger
   scanning file lists only.
2) inactive_list_is_low() returns true in shrink_list() to allow
   scanning active file list.

In that case vmscan would only scan file lists, and as active file list
is also scanned, inactive_list_is_low() may keep returning false in
get_scan_count() until file cache is very low.

Before commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in
cache workingset transition"), inactive_list_is_low() never returns
different value in get_scan_count() and shrink_list() in one
shrink_node_memcg() run. The original design should be that when
inactive_list_is_low() returns false for file lists, vmscan only scan
inactive file list. As only inactive file list is scanned,
inactive_list_is_low() would soon return true.

This patch makes the return value of inactive_list_is_low() independent
of actual_reclaim.

The problem can be reproduced by the following test program.

---8<---
void fallocate_file(const char *filename, off_t size)
{
	struct stat st;
	int fd;

	if (!stat(filename, &st) && st.st_size >= size)
		return;

	fd = open(filename, O_WRONLY | O_CREAT, 0600);
	if (fd < 0) {
		perror("create file");
		exit(1);
	}
	if (posix_fallocate(fd, 0, size)) {
		perror("fallocate");
		exit(1);
	}
	close(fd);
}

long *alloc_anon(long size)
{
	long *start = malloc(size);
	memset(start, 1, size);
	return start;
}

long access_file(const char *filename, long size, long rounds)
{
	int fd, i;
	volatile char *start1, *end1, *start2;
	const int page_size = getpagesize();
	long sum = 0;

	fd = open(filename, O_RDONLY);
	if (fd == -1) {
		perror("open");
		exit(1);
	}

	/*
	 * Some applications, e.g. chrome, use a lot of executable file
	 * pages, map some of the pages with PROT_EXEC flag to simulate
	 * the behavior.
	 */
	start1 = mmap(NULL, size / 2, PROT_READ | PROT_EXEC, MAP_SHARED,
		      fd, 0);
	if (start1 == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	end1 = start1 + size / 2;

	start2 = mmap(NULL, size / 2, PROT_READ, MAP_SHARED, fd, size / 2);
	if (start2 == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}

	for (i = 0; i < rounds; ++i) {
		struct timeval before, after;
		volatile char *ptr1 = start1, *ptr2 = start2;
		gettimeofday(&before, NULL);
		for (; ptr1 < end1; ptr1 += page_size, ptr2 += page_size)
			sum += *ptr1 + *ptr2;
		gettimeofday(&after, NULL);
		printf("File access time, round %d: %f (sec)\n", i,
		       (after.tv_sec - before.tv_sec) +
		       (after.tv_usec - before.tv_usec) / 1000000.0);
	}
	return sum;
}

int main(int argc, char *argv[])
{
	const long MB = 1024 * 1024;
	long anon_mb, file_mb, file_rounds;
	const char filename[] = "large";
	long *ret1;
	long ret2;

	if (argc != 4) {
		printf("usage: thrash ANON_MB FILE_MB FILE_ROUNDS\n");
		exit(0);
	}
	anon_mb = atoi(argv[1]);
	file_mb = atoi(argv[2]);
	file_rounds = atoi(argv[3]);

	fallocate_file(filename, file_mb * MB);
	printf("Allocate %ld MB anonymous pages\n", anon_mb);
	ret1 = alloc_anon(anon_mb * MB);
	printf("Access %ld MB file pages\n", file_mb);
	ret2 = access_file(filename, file_mb * MB, file_rounds);
	printf("Print result to prevent optimization: %ld\n",
	       *ret1 + ret2);
	return 0;
}
---8<---

Running the test program on 2GB RAM VM with kernel 5.2.0-rc5, the
program fills ram with 2048 MB memory, access a 200 MB file for 10
times. Without this patch, the file cache is dropped aggresively and
every access to the file is from disk.

  $ ./thrash 2048 200 10
  Allocate 2048 MB anonymous pages
  Access 200 MB file pages
  File access time, round 0: 2.489316 (sec)
  File access time, round 1: 2.581277 (sec)
  File access time, round 2: 2.487624 (sec)
  File access time, round 3: 2.449100 (sec)
  File access time, round 4: 2.420423 (sec)
  File access time, round 5: 2.343411 (sec)
  File access time, round 6: 2.454833 (sec)
  File access time, round 7: 2.483398 (sec)
  File access time, round 8: 2.572701 (sec)
  File access time, round 9: 2.493014 (sec)

With this patch, these file pages can be cached.

  $ ./thrash 2048 200 10
  Allocate 2048 MB anonymous pages
  Access 200 MB file pages
  File access time, round 0: 2.475189 (sec)
  File access time, round 1: 2.440777 (sec)
  File access time, round 2: 2.411671 (sec)
  File access time, round 3: 1.955267 (sec)
  File access time, round 4: 0.029924 (sec)
  File access time, round 5: 0.000808 (sec)
  File access time, round 6: 0.000771 (sec)
  File access time, round 7: 0.000746 (sec)
  File access time, round 8: 0.000738 (sec)
  File access time, round 9: 0.000747 (sec)

Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7889f583ced9f..b95d05fe828d1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2151,7 +2151,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * rid of the stale workingset quickly.
 	 */
 	refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
-	if (file && actual_reclaim && lruvec->refaults != refaults) {
+	if (file && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
 		gb = (inactive + active) >> (30 - PAGE_SHIFT);
-- 
2.22.0.410.gd8fdbe21b5-goog

