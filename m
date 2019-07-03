Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10CC3C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA2BA218A4
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:31:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA2BA218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64F6C6B0003; Wed,  3 Jul 2019 10:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FE988E0003; Wed,  3 Jul 2019 10:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C9878E0001; Wed,  3 Jul 2019 10:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00B006B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 10:31:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c27so1834177edn.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 07:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aymayfheh4NTbUMjrZGECjsvaS5WW1lfzjYtxfajXyo=;
        b=LuyePyHetMli9Qm0q6GBdmfng7GiiuTVNXBr7Nd/OkStBaXMMDhQIiOT81pSbkkGzl
         6s3F5MX2TF8Thf6K0gGlj7MGbm6Avgh0g/v3KCLUTHD6vtN/Da+HmDYHayog+HVv5uJN
         9ZLTdY1S6eVvOU4fpBML3R1sJQ5wTBIDiof0Zr0K+4d5rZjjT7kCWzTRUnCaBjoaRvNi
         5cOlcQCwZv+VVCM+4kb4VM04AgSslvPzqApF22a1XC9WruTTGSk3kvYCResB1M5BhAed
         5/IbPKB/kAzmDFid+D2PYdP7jU0DmV+x2SxJpd4TubiGCP3SGiCoOAYOsmLFLZuGnb06
         F6fQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVHhbdGL8OP16n25UZC6E8D9BnQLiYyG+YtvsK0VIA6V8k4axnZ
	CGx00wdafKOKFFRA7mOlUzo6T60iEwx5fM+ublVYRVoLrwdb+dtpJVhx7rR438GV29OXP+VmfeT
	TkERv81O/j7QCv7sGRVsan5wvEDxGBrN7fHgIjz/UFgZAodvmLo1WHPJZJMWFCnI=
X-Received: by 2002:a17:906:264a:: with SMTP id i10mr34578470ejc.10.1562164260551;
        Wed, 03 Jul 2019 07:31:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwb94lO2sDAY1iL+2youZR3Hjl+B2C7Qz4Bd/umoCNDaVRm0DhINQkfiNdPC+YO7BlNbgHe
X-Received: by 2002:a17:906:264a:: with SMTP id i10mr34578365ejc.10.1562164259477;
        Wed, 03 Jul 2019 07:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562164259; cv=none;
        d=google.com; s=arc-20160816;
        b=G7jk7BV/n9GGoisXD8k3K8ICx3K6NjrA9C6Hhmw0FXcqmEIgArjmbZ9eeAB8oLk94h
         YHhDoWfRker7BVjwYbd/FaC9XaaVZ6bbzkEtNrcbCp7YgpTV7b8NVTL8wBGM/VxU0S5f
         ToEPyCiRH+LM7SUk8NEC6tYfUTYb11KQSSXKds6fAJxS4rid0djpKIXOdltHqaBPXyBr
         SSzgmaGwV73CpME9Lxe2MY6CjttW4cvS4roTAI1IVAoJufvAN8OvSZ2S9ocViHxQInzd
         e5yC9YS1sIb01prQXzyHXonWEr5dlFCRdzm4u1Taa1wQ7ao4WMftluEKo85qRMcGYhEn
         HH1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aymayfheh4NTbUMjrZGECjsvaS5WW1lfzjYtxfajXyo=;
        b=vGfpu+xxNocSGPGl8sP7Amu8H+dSrk1ZdmJT1d9SBsz9cKz5eY+DClTHk6EDB688F3
         MuYcKmWxabLe4CnQsMY3TaKmdZoteYQRrzLL3eq7HDrjceSAa76Jwj0DEe1yU/9z6zPM
         tXSpy9bvhuIWz5vnh946+JrWidO+8CmeGXvUgRdicvehb9YJIJTFfJL6t3mtiizYbpDx
         t64bb7rnFOMrd4Zjus8+pJa0l8/eWBs7vb3/t3twW72yoUHdGI5Q2qCCcdU8ttSGMn22
         u/7Vn8Ny87WNkiImBvy5u56NwLjajVXoQO6xXnIQPdkIh/XBlYtIzi1WWtPd/BAUjYzP
         gx9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si1820575ejo.176.2019.07.03.07.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 07:30:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3C80AD76;
	Wed,  3 Jul 2019 14:30:58 +0000 (UTC)
Date: Wed, 3 Jul 2019 16:30:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Minchan Kim <minchan@kernel.org>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: scan anonymous pages on file refaults
Message-ID: <20190703143057.GQ978@dhcp22.suse.cz>
References: <20190628111627.GA107040@google.com>
 <20190701081038.GA83398@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701081038.GA83398@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 16:10:38, Kuo-Hsin Yang wrote:
> When file refaults are detected and there are many inactive file pages,
> the system never reclaim anonymous pages, the file pages are dropped
> aggressively when there are still a lot of cold anonymous pages and
> system thrashes.  This issue impacts the performance of applications
> with large executable, e.g. chrome.
> 
> With this patch, when file refault is detected, inactive_list_is_low()
> always returns true for file pages in get_scan_count() to enable
> scanning anonymous pages.
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
> times.  Without this patch, the file cache is dropped aggresively and
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

How does the reclaim behave with workloads with file backed data set
not fitting into the memory? Aren't we going to to swap a lot -
something that the heuristic is protecting from?

> Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
> Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")
> Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: <stable@vger.kernel.org> # 4.12+

-- 
Michal Hocko
SUSE Labs

