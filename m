Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C62AEC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E7572177B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 06:58:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cPfQczMz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E7572177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 148026B0003; Fri, 28 Jun 2019 02:58:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F9248E0003; Fri, 28 Jun 2019 02:58:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F017D8E0002; Fri, 28 Jun 2019 02:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6F846B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 02:58:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d190so3276684pfa.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 23:58:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ESOloCsNcWCvH+ErqVz8d4Y7PTRFELsUnE8Q8N0c9F8=;
        b=RdJum6+CpJNn2V93Dy0o8nzKV9lcOf/neBWYuV19gWHsNpGTMQTSNK02JG6376N/DX
         +YE9xOpn6AHI4bpKMRY3XJqpO9QAZjPLP5C68dSgZ/mBM8zbeDEZsw4GX6YpshyKGGjj
         jL4nlSLXJz4lvHZv64pQ30uaXKM3ryY1e8bCCJJYU5v3mhh5XgUfQjp59bUuLBwDkVQR
         6uLYgNOH5t3hkSa7ikOcJWBddLyNA8P5TzB5R/l4mTccwccWD0iGnFZafaiEFKLc2b7E
         s1x02aDvjpJkgZJeSYeCleDNkwYUZ/EIp2IIuktHZbrf8u/xjgm6fAA/xRAzTT919027
         q1cw==
X-Gm-Message-State: APjAAAVP8SOPI+2HdmV4gL18FfZuE8rLrYJ3aZRZoD2MPN9SMz27YYx4
	s+ZiCJozmYfEJd1jtMHVikwXDXIgGeBXiOJxP2LjRlNDOGZMBjdcxarpEJoksWqiLG5w5yclZV1
	LQyqN9zem9DhQMIYJ9wiolta6700r50bfeXxJ405BirWG9st+zSPMVUgTUFUP4lY=
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr10738214pje.110.1561705104262;
        Thu, 27 Jun 2019 23:58:24 -0700 (PDT)
X-Received: by 2002:a17:90a:258b:: with SMTP id k11mr10738165pje.110.1561705103449;
        Thu, 27 Jun 2019 23:58:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561705103; cv=none;
        d=google.com; s=arc-20160816;
        b=hmlc00Bto13poEz3wBBcExoqgjCWdn4DNUtdYFqwWZdQPubLbUOTsA16WA+7s2PNY3
         9ojLWLPBD4l7rxbYPnNvlm+WV56PaPazI/u9ZH7+m83IcaYLtAYPTiE0ZeNRtX3gkuod
         WFRl6RvgHnfLlNhzD90mpXA5EvmKKMxMLsi+IeFRW/fI4wWoGsyVdxg1qBlFOQv/WGvU
         Jq8A45/sogn2K7iWuNBI4qTHB2rgXt2p3Tv/CbDaDN9exuagKvg3KucCmit3KxeiUxGS
         zhX2iBMFS+tNB/IlL7yENwHxI7PbdTZNS8u9wfOqpBbEqSVq7UMNnpkJPSv5oCEuEMjf
         K4PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=ESOloCsNcWCvH+ErqVz8d4Y7PTRFELsUnE8Q8N0c9F8=;
        b=wa/5KHFUlimojCXuTwiaGNy4y3ogd9bXK/zhvb8eyOupawtafqzc+EE+wqTF5K3GcB
         lhP2CmBvjgUeZjvgm54oBmwboxaxapKKv6PtWsXf//uZfrFP9Qoqc4HbBJ0E4ikkmHm1
         82Jo89/PNUjm82fHJKwWJk1FKW0Mpq36kjt1lS9HaQBcVCvhq+dgKBPLxWzwA0WVdWOs
         eWG5uaKKc1MBJwU0grBTnyX3wWcEqkPIJTS/j4lRZzUmSisPxFQlwPIaqKBxdndKcYrG
         kQVQs0urNce7xD4CEH+IvCEE9sSYSuVShzCFOKTugvLG2vPhB2rxrf2+79wpim+0jzj1
         pQiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cPfQczMz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor1477146pln.14.2019.06.27.23.58.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 23:58:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cPfQczMz;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ESOloCsNcWCvH+ErqVz8d4Y7PTRFELsUnE8Q8N0c9F8=;
        b=cPfQczMzOGRhzVVdyaDMEZQqANzQXsxUWKM6wKbDjvR9EjM5liVHJj2hXhmMYQ4p2d
         SxfP7NELbXSMLJgFtdEMdPiNYeCjZkekvRwbdjVkDhniuQWhhdcoKpvbXCLMuTGtT8WA
         x//uhO4+UKisqdjb9sgik/CWwXq+DixrsErqgiCB7XAFnW6+LBRLwU6iBjZ8QMM9RiIG
         9uEKx+/0i/p1tiWB1O/tTL/q2ApPnVrgowFcV/8wKnIG40J1/MoDdDLTWkNhib1AoCSl
         2audka5M3j9V0W1VLln+JGAs/HPCW+VFwfhpjYlmQ6sx0zd97NWhHAeRkGJM14wTRkq6
         uEAQ==
X-Google-Smtp-Source: APXvYqwfKUDWg9fQDdZpcFB0UFQ6fNBj8ReG1Mi5PygU/MFko/2H+xa33hSscS56hsUEKpb+vPlYaA==
X-Received: by 2002:a17:902:2889:: with SMTP id f9mr9162225plb.230.1561705102997;
        Thu, 27 Jun 2019 23:58:22 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id y8sm1250367pfn.52.2019.06.27.23.58.19
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 23:58:21 -0700 (PDT)
Date: Fri, 28 Jun 2019 15:58:17 +0900
From: Minchan Kim <minchan@kernel.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628065817.GB251482@google.com>
References: <20190619080835.GA68312@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619080835.GA68312@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kuo-Hsin,

On Wed, Jun 19, 2019 at 04:08:35PM +0800, Kuo-Hsin Yang wrote:
> When file refaults are detected and there are many inactive file pages,
> the system never reclaim anonymous pages, the file pages are dropped
> aggressively when there are still a lot of cold anonymous pages and
> system thrashes. This issue impacts the performance of applications with
> large executable, e.g. chrome.
> 
> When file refaults are detected. inactive_list_is_low() may return
> different values depends on the actual_reclaim parameter, the following
> 2 conditions could be satisfied at the same time.
> 
> 1) inactive_list_is_low() returns false in get_scan_count() to trigger
>    scanning file lists only.
> 2) inactive_list_is_low() returns true in shrink_list() to allow
>    scanning active file list.
> 
> In that case vmscan would only scan file lists, and as active file list
> is also scanned, inactive_list_is_low() may keep returning false in
> get_scan_count() until file cache is very low.
> 
> Before commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in
> cache workingset transition"), inactive_list_is_low() never returns
> different value in get_scan_count() and shrink_list() in one
> shrink_node_memcg() run. The original design should be that when
> inactive_list_is_low() returns false for file lists, vmscan only scan
> inactive file list. As only inactive file list is scanned,
> inactive_list_is_low() would soon return true.
> 
> This patch makes the return value of inactive_list_is_low() independent
> of actual_reclaim.
> 
> The problem can be reproduced by the following test program.
> 
> ---8<---
> void fallocate_file(const char *filename, off_t size)
> {
> 	struct stat st;
> 	int fd;
> 
> 	if (!stat(filename, &st) && st.st_size >= size)
> 		return;
> 
> 	fd = open(filename, O_WRONLY | O_CREAT, 0600);
> 	if (fd < 0) {
> 		perror("create file");
> 		exit(1);
> 	}
> 	if (posix_fallocate(fd, 0, size)) {
> 		perror("fallocate");
> 		exit(1);
> 	}
> 	close(fd);
> }
> 
> long *alloc_anon(long size)
> {
> 	long *start = malloc(size);
> 	memset(start, 1, size);
> 	return start;
> }
> 
> long access_file(const char *filename, long size, long rounds)
> {
> 	int fd, i;
> 	volatile char *start1, *end1, *start2;
> 	const int page_size = getpagesize();
> 	long sum = 0;
> 
> 	fd = open(filename, O_RDONLY);
> 	if (fd == -1) {
> 		perror("open");
> 		exit(1);
> 	}
> 
> 	/*
> 	 * Some applications, e.g. chrome, use a lot of executable file
> 	 * pages, map some of the pages with PROT_EXEC flag to simulate
> 	 * the behavior.
> 	 */
> 	start1 = mmap(NULL, size / 2, PROT_READ | PROT_EXEC, MAP_SHARED,
> 		      fd, 0);
> 	if (start1 == MAP_FAILED) {
> 		perror("mmap");
> 		exit(1);
> 	}
> 	end1 = start1 + size / 2;
> 
> 	start2 = mmap(NULL, size / 2, PROT_READ, MAP_SHARED, fd, size / 2);
> 	if (start2 == MAP_FAILED) {
> 		perror("mmap");
> 		exit(1);
> 	}
> 
> 	for (i = 0; i < rounds; ++i) {
> 		struct timeval before, after;
> 		volatile char *ptr1 = start1, *ptr2 = start2;
> 		gettimeofday(&before, NULL);
> 		for (; ptr1 < end1; ptr1 += page_size, ptr2 += page_size)
> 			sum += *ptr1 + *ptr2;
> 		gettimeofday(&after, NULL);
> 		printf("File access time, round %d: %f (sec)\n", i,
> 		       (after.tv_sec - before.tv_sec) +
> 		       (after.tv_usec - before.tv_usec) / 1000000.0);
> 	}
> 	return sum;
> }
> 
> int main(int argc, char *argv[])
> {
> 	const long MB = 1024 * 1024;
> 	long anon_mb, file_mb, file_rounds;
> 	const char filename[] = "large";
> 	long *ret1;
> 	long ret2;
> 
> 	if (argc != 4) {
> 		printf("usage: thrash ANON_MB FILE_MB FILE_ROUNDS\n");
> 		exit(0);
> 	}
> 	anon_mb = atoi(argv[1]);
> 	file_mb = atoi(argv[2]);
> 	file_rounds = atoi(argv[3]);
> 
> 	fallocate_file(filename, file_mb * MB);
> 	printf("Allocate %ld MB anonymous pages\n", anon_mb);
> 	ret1 = alloc_anon(anon_mb * MB);
> 	printf("Access %ld MB file pages\n", file_mb);
> 	ret2 = access_file(filename, file_mb * MB, file_rounds);
> 	printf("Print result to prevent optimization: %ld\n",
> 	       *ret1 + ret2);
> 	return 0;
> }
> ---8<---
> 
> Running the test program on 2GB RAM VM with kernel 5.2.0-rc5, the
> program fills ram with 2048 MB memory, access a 200 MB file for 10
> times. Without this patch, the file cache is dropped aggresively and
> every access to the file is from disk.
> 
>   $ ./thrash 2048 200 10
>   Allocate 2048 MB anonymous pages
>   Access 200 MB file pages
>   File access time, round 0: 2.489316 (sec)
>   File access time, round 1: 2.581277 (sec)
>   File access time, round 2: 2.487624 (sec)
>   File access time, round 3: 2.449100 (sec)
>   File access time, round 4: 2.420423 (sec)
>   File access time, round 5: 2.343411 (sec)
>   File access time, round 6: 2.454833 (sec)
>   File access time, round 7: 2.483398 (sec)
>   File access time, round 8: 2.572701 (sec)
>   File access time, round 9: 2.493014 (sec)
> 
> With this patch, these file pages can be cached.
> 
>   $ ./thrash 2048 200 10
>   Allocate 2048 MB anonymous pages
>   Access 200 MB file pages
>   File access time, round 0: 2.475189 (sec)
>   File access time, round 1: 2.440777 (sec)
>   File access time, round 2: 2.411671 (sec)
>   File access time, round 3: 1.955267 (sec)
>   File access time, round 4: 0.029924 (sec)
>   File access time, round 5: 0.000808 (sec)
>   File access time, round 6: 0.000771 (sec)
>   File access time, round 7: 0.000746 (sec)
>   File access time, round 8: 0.000738 (sec)
>   File access time, round 9: 0.000747 (sec)
> 
> Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7889f583ced9f..b95d05fe828d1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2151,7 +2151,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  	 * rid of the stale workingset quickly.
>  	 */
>  	refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
> -	if (file && actual_reclaim && lruvec->refaults != refaults) {
> +	if (file && lruvec->refaults != refaults) {

Just a nit:

So, now "actual_reclaim" just aims for the tracing purpose. In that case,
we could rollback the naming to "trace", again.


