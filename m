Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A36C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:10:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E80120B7C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:10:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Y1Jl7Q3r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E80120B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0F526B0003; Mon,  1 Jul 2019 04:10:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC09F8E0003; Mon,  1 Jul 2019 04:10:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB0568E0002; Mon,  1 Jul 2019 04:10:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 7594F6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:10:44 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id w14so6912024plp.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:10:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=E/CZW9HTMtXTzsWNO626jk1uoh4yKNXGp5gpm1i8SNo=;
        b=jzl9ymOWf5bh8Y9Pwmbq9F0a/eZX85Gn2+63HW9Mcq1A+tUVDWkH6ZyCU9np6OwEIN
         Qfk/gULwH75xjeZyAGuKmpKIkIlQKTjLGQ0eB4KIORFhItHEj02Ou5/JeDnAoEFnHV15
         he1f1vCKsD70DwUdSgVWF8Vv310YuajTERyxDUGkIm174sC8Bxl0oqLOpUUfIl0rxfmQ
         pU45UUFhivR10aiW4NbJU6gBJbRr2eiILN0rAKFdMPcxQVZS3gbM6gB9p2hbnSgdKptC
         5IKTm3XbjvIEV2paGQ12y6tAsNHwwmOcyy2lqsJZXvmVCmKoy/R5uv242DApukyGNs/A
         4qgQ==
X-Gm-Message-State: APjAAAUpzTOPxVxmXV4aoDzCIzE69dAu+AY8I3QQy1OvtDJNSzbL0mwc
	vbDyMQEs5R/wlJViNZnqdzCQLR5KQ2gdQiVV/Ey6oWuR2I5i+GNN+TMH8etjexUkxJvS4ymyca+
	s6NFFBvUuPrsiCL1N12PDpiutDOfhszQplkDeIyx9lupSFdKnhDPQ6To/vsscka1Kbg==
X-Received: by 2002:a63:4d50:: with SMTP id n16mr23669310pgl.146.1561968643881;
        Mon, 01 Jul 2019 01:10:43 -0700 (PDT)
X-Received: by 2002:a63:4d50:: with SMTP id n16mr23669230pgl.146.1561968642875;
        Mon, 01 Jul 2019 01:10:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561968642; cv=none;
        d=google.com; s=arc-20160816;
        b=pYYKl+IHd+z5LmekfONPL+WuUbJgTZ7BokAqVaPrHtW+5LarmKqSQZcs6oldYum1Ra
         1Swol0KLPK/GTNDKqJq2htvFwYazoAJ0fi+wYcuDz8bUR+r6PRIVWu9mTOdUPmQmofD+
         JQAULPzrJiQvhpYa67bWBx+Nhm/6JmxAvVmhbmvYZK27s7z0yZ/JnGhnFb0auHSxY1Va
         OmJMidGoX5ah8md6EtJzaLQcpZJtZ0OEyR/PBQ9uOkvX9QYbz3/XKh9D8FxVWFzNK4ca
         d8smN47wDl6Z/WW4Z3C8VThoY1auDQwQ/EkcbbrGohOX6aZx1FP9elX5VyGS1N7oOWO/
         uGMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=E/CZW9HTMtXTzsWNO626jk1uoh4yKNXGp5gpm1i8SNo=;
        b=oOXUJ7mW0vSlARJYJlgYpqfTXe0d3wG6NhmyCagY4qdVmm1B4ciDfEBnA+Pj+fOIHu
         +VDhlm8kk9JI7dssPAOWayS54FxVEAQldYDV+Y1a06PngCBws4j3ThsXcW+jVZwtZrpM
         R+t3oK3g50rluAqKD4/OFdnm3D28/WG4WwuL9OhkRXnzvXliNV42xT4YVr+lOGkSrN2K
         ngvck+L0cDOHBOELrBEu0ZtuTfqd8e9YeS9yw+Rn2khu0Y3fOu7VTBmYiUfJ1xhkj9uz
         MgXjbPXAvIUAPzmftgMKEt5GanmrPxPwK9IFhi/t3TOzJYqiIU7cvSkjjnicHtnx2vfo
         yY1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y1Jl7Q3r;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12sor4390281pgm.75.2019.07.01.01.10.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 01:10:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=Y1Jl7Q3r;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E/CZW9HTMtXTzsWNO626jk1uoh4yKNXGp5gpm1i8SNo=;
        b=Y1Jl7Q3riwientCHluxuBavS3le3r8ZkQ6ZthBM24QSSsseeTqeNZmXcJEXfC9QeP8
         l6bbotOduPtoFStTdwPBkP9o7qaDEjwmJ6Le1PbbVtSbBiZqF22uqzR5WevH/mqIxbXS
         auNIogcG5elmi+eckCW5UoPAoVU7+6A7QfwDA=
X-Google-Smtp-Source: APXvYqw/mugHN9o8pQ1MjJFOIOtoYW8do+1rzm25p+7GQndefP86Q2v1wR+6xWqkKyU8+6gIl6y1tA==
X-Received: by 2002:a63:dd53:: with SMTP id g19mr22552755pgj.3.1561968642410;
        Mon, 01 Jul 2019 01:10:42 -0700 (PDT)
Received: from google.com ([2401:fa00:1:b:d89e:cfa6:3c8:e61b])
        by smtp.gmail.com with ESMTPSA id a16sm14383490pfd.68.2019.07.01.01.10.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 01:10:41 -0700 (PDT)
Date: Mon, 1 Jul 2019 16:10:38 +0800
From: Kuo-Hsin Yang <vovoy@chromium.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Sonny Rao <sonnyrao@chromium.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, stable@vger.kernel.org
Subject: [PATCH] mm: vmscan: scan anonymous pages on file refaults
Message-ID: <20190701081038.GA83398@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628111627.GA107040@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When file refaults are detected and there are many inactive file pages,
the system never reclaim anonymous pages, the file pages are dropped
aggressively when there are still a lot of cold anonymous pages and
system thrashes.  This issue impacts the performance of applications
with large executable, e.g. chrome.

With this patch, when file refault is detected, inactive_list_is_low()
always returns true for file pages in get_scan_count() to enable
scanning anonymous pages.

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
times.  Without this patch, the file cache is dropped aggresively and
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

Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")
Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org> # 4.12+
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7889f583ced9f..da0b97204372e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2125,7 +2125,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct scan_control *sc, bool actual_reclaim)
+				 struct scan_control *sc, bool trace)
 {
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
@@ -2151,7 +2151,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	 * rid of the stale workingset quickly.
 	 */
 	refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
-	if (file && actual_reclaim && lruvec->refaults != refaults) {
+	if (file && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
 		gb = (inactive + active) >> (30 - PAGE_SHIFT);
@@ -2161,7 +2161,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 			inactive_ratio = 1;
 	}
 
-	if (actual_reclaim)
+	if (trace)
 		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id, sc->reclaim_idx,
 			lruvec_lru_size(lruvec, inactive_lru, MAX_NR_ZONES), inactive,
 			lruvec_lru_size(lruvec, active_lru, MAX_NR_ZONES), active,
-- 
2.22.0.410.gd8fdbe21b5-goog

