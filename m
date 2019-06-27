Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D886AC48BE4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:41:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 903802064A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 18:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="UDng4QJM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 903802064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14D1B6B0003; Thu, 27 Jun 2019 14:41:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12F998E0003; Thu, 27 Jun 2019 14:41:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03B868E0002; Thu, 27 Jun 2019 14:41:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8D826B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:41:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so3437554qkj.10
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:41:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Zp2l4O4LWB1oYN3F7c8FUspudG1FPkSVquIdBgKKNr8=;
        b=cTbC54y1ZDCTk3pUSukxuDazfBU6GloYD2sxgx363fin+797wJoXL3WUx4cTm0NlCQ
         H0lrlUJpqrdkVxVJo09/f8k8KniOi1ZARS8hn2D5JjSQMBEwBwZEJ909FGn9f9V1Yzzm
         pTvyrjoMxS+Ed5jWu9bNNcSWRE3SRfkmfL4Q4zODGnD749/Q24b/65R+yTfCXSmMvYg2
         g+Mv5VW9QecF9KIIR2/fkJMWErwYapuERid/B0Xip7C1tneh8eBZsC/8xkR0MK6kXU/+
         beG+14FSEfEEEDALgz+tAqwDHUUx8iZg+e5OyrH7kU8OjsAKo6bUNCQ2IN2dnHMUpVeb
         n/9w==
X-Gm-Message-State: APjAAAWsSPoKupEZv0ovB832arNT6lcW84wGrvbt4Kcumc7v+vEn/bwN
	L/vNs0UsQJTk8WbptR8mNx4utk00y7JX2eEDVdXmahiB8tgfueDGEwhslzefb0dm5rj7vhlJxN4
	n7FHCtXvdf518jKt0cksRLwpRE31iPVYPAl1h6jDgjexGOf5vVOOqJl7YkYIW4HHC6A==
X-Received: by 2002:a0c:d237:: with SMTP id m52mr4394029qvh.160.1561660893556;
        Thu, 27 Jun 2019 11:41:33 -0700 (PDT)
X-Received: by 2002:a0c:d237:: with SMTP id m52mr4393960qvh.160.1561660892588;
        Thu, 27 Jun 2019 11:41:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561660892; cv=none;
        d=google.com; s=arc-20160816;
        b=khwQ+7DQMQ1pfAweTBb4Q3b3Y0t3GARSFRRZvkz/QF42v31EbAELl9orIfqtSPv8u9
         tH+rAq8Km0jdUm0/jnSoBezO3ucqqhg6QgIu3zu7M4VMhgeAoH4Eo/JoiMZyOxIXk0ig
         30VYi7Vhn29WYy/Fug0Nm6K/xdhxs4y05MYTVsx1AMpGBnPen/LeA62ZUe5UhnZr86Om
         HSoVNEsPkLLoFNSnxoTb+kvrKGjhMGkMwK3dLihmDwN3KRjkbgqwqAxHyQcMPUDGmHSK
         9/M4Hup1mIW5DI+hCbNdqZ2iP3uOXc1Qb1N5g0yn1Y4yITgY7nMF6z3ER5yKMpWZVgwQ
         u5Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Zp2l4O4LWB1oYN3F7c8FUspudG1FPkSVquIdBgKKNr8=;
        b=UaiRg1g1q6Mk4Qkwt2vv8e3V2yP5NXpPZxImnEWFNmnxXxKlqUs5LN+Sy2pbMJbutF
         7NRJ021m1KX5KV2f+iSqEEsyfdvtkbfrupAxoUqIzndHkqrGEjR2rV9GnXrnbr6F+jJi
         bjdXlyBAJxVdMRwEzSKP4DKv5ptuYtKD/XZjy9AS1puUA6DCq2xfLoEmzE0TDty9F3TE
         YeJ1VE5ijjjP8BkUmAW/nhCDdTeyg1UpOUc++gg3ilxzapFpH4eB2UJ/5x7LjZTtvRGF
         +7K55aePWHEK9VWRygojQnIto2SshH1dO7wm4XTXQfrPo2qd7x1wPSn18vaS6L7Q9zXr
         VLzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UDng4QJM;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3sor1886362qkl.6.2019.06.27.11.41.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 11:41:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=UDng4QJM;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Zp2l4O4LWB1oYN3F7c8FUspudG1FPkSVquIdBgKKNr8=;
        b=UDng4QJMv1LWzYnKCztVQrCNsQ7Xm4otaD1vwxegRokBDPjtcWCzhLj1b0tPvoH+5G
         e/wZZXygpBylg98sPuyuv5mbBgHjHPIhEGIY/4sXfGrI6hEsUakCdci1fKEcwYL664EC
         Ltd0eFTtccFg22S/AnCRO2+x3kM7m3mE76PbjYGJA3XX88l8d1RfTL8naCRYhwRRt0hN
         kyZi2ZsrwRjkdf7keArGTkmIEQdAUv5kF+i4bxZDaZkTJbnUfBtuvb8kgZ4DSAN0ClWA
         9uUXZkU+VDLLI8Wljm/1SQ0dpnn2hWHmINCPPoWh84Ec+rb3cevpyvhRbTvWyf7P5pkm
         ioRQ==
X-Google-Smtp-Source: APXvYqzuAHF37eGCzmzOTvKs0gfWaevOeNG3BEuhoGjpmd7NajpcCkq1aEtP0oryKkwjtmcGiGqZAA==
X-Received: by 2002:a05:620a:13b9:: with SMTP id m25mr5020959qki.246.1561660885669;
        Thu, 27 Jun 2019 11:41:25 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id t29sm1418301qtt.42.2019.06.27.11.41.24
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 11:41:24 -0700 (PDT)
Date: Thu, 27 Jun 2019 14:41:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190627184123.GA11181@cmpxchg.org>
References: <20190619080835.GA68312@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619080835.GA68312@google.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Your change makes sense - we should indeed not force cache trimming
only while the page cache is experiencing refaults.

I can't say I fully understand the changelog, though. The problem of
forcing cache trimming while there is enough page cache is older than
the commit you refer to. It could be argued that this commit is
incomplete - it could have added refault detection not just to
inactive:active file balancing, but also the file:anon balancing; but
it didn't *cause* this problem.

Shouldn't this be

Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")

instead?

