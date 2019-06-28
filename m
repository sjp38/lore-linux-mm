Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9DEC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 14:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 763F8205C9
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 14:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="rdY63TdC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 763F8205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 151C18E0003; Fri, 28 Jun 2019 10:32:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 103448E0002; Fri, 28 Jun 2019 10:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F34C38E0003; Fri, 28 Jun 2019 10:32:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D24198E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:32:08 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v58so6264072qta.2
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 07:32:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CfBxdKK+RW6h34KCEm0a8LsqSSwL+A0Ki+xU4tcOBSU=;
        b=VVXmVxQLCpBmhBgsX/DM/xEr0h5RvroLA1iPXKrbXZQ8nv0V74f8AmOPOsPmcw3x7M
         772o24SLaroBemNQ1ja79SFohHK6R0bN5HgnMIooDSBzHWzgV0UhTdzsplBQurzJXKAA
         v7QdvoDvHmZPSL/TAc5WEp8lPb5JbxXk3wuFHcFY8GAJ74ZpFJGZpwRcSdpeyyidRR3y
         pA27DUhvBK0sjbFE9exZIf9JgK+98DkCtvQGMUbZk5r7NKnUqR8RIPdbTQBysJNcI3fP
         cAWsW86ZibeyoT+I1bfgfjIBXiVERH6CK6LfGtjfa0f56j18rfPLJIqKWOD2WyW6J3Jy
         Y3hA==
X-Gm-Message-State: APjAAAW2RPZk5U+7lbJl1mnzE8uhb+Rd4xxhUFYA8GHEsLhzA6jhVNBq
	fjOfC/tMTtcWrYgj06zqLJ6l4JZVE0uN/yVrIHdETgwUYw6c93WRWF3gnQJaZUQLiG7hx0cqY1k
	l2n8N9s3bu0Tg+EiwgSpmUqmP1YDV2Y6jcwkwpOJ+ZSEOaA/sYOJmNDhwI4JlFb3BZQ==
X-Received: by 2002:ac8:25e7:: with SMTP id f36mr8385417qtf.139.1561732328616;
        Fri, 28 Jun 2019 07:32:08 -0700 (PDT)
X-Received: by 2002:ac8:25e7:: with SMTP id f36mr8385345qtf.139.1561732327735;
        Fri, 28 Jun 2019 07:32:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561732327; cv=none;
        d=google.com; s=arc-20160816;
        b=KcK3eCOymUb5f7hOLY/shd355MSvluJelsnWVy+bBZ3amL4c13rODW/Fopm0oOw/TK
         Mgyc9Q98gXwPwAARzFUhArNToNHjnymaM+Ms8cqLrhWT8QnoYD6NX0fPhdawNvqcb5a2
         Xq3ATKO57z7F9zg4vGtal21i6LuawS8a1UpqjZG9Rk4WPtimSVkgrv+Tbi/WpaQLhvhk
         ZYyismMxKhVt/pZMoa6z1mpLuYcfhUSHwgxhZfdFfV2anSC3UY8fhgzx4331hT7B7G2q
         jz4JxjtPDzRuwd4ldEL/MuZb19gU3gTn70WkRQbsDU+gZJLfQgHk5/oYseT6kGyZiWqT
         66WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CfBxdKK+RW6h34KCEm0a8LsqSSwL+A0Ki+xU4tcOBSU=;
        b=uPSU8GGgFGU0FZKHN4ZL4R9GxbWZBwZyKd/zmGb+T7sZBOJmlQDBhW6KBKke6Tszcn
         feb0u15yjarT4LdInoaQnlgVl2IrhZAM7s7rc7y/PxZ3hsVjOLNREjoE56zvjkW//fbX
         Xr3BSgtQ+uTcmLeXtz+WG51kcNSp5kuDHecBLaPEk1kLBcXpnde6GFjq1C3BlwK+erPF
         RQzlvKx8RUXoCyv/uGjpUo/Th6H+Nu1Wxs+9rhRD4CofO9WvzAclwKLg/Or9li0I8OGn
         O0aloz9hXi2jImgMPQ06+f8KXcL40XPRFJVGKrdBSwlHjeTwuBg6X3cZLVBV9Tmigqvn
         wkKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rdY63TdC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i47sor2033401qvi.54.2019.06.28.07.32.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 07:32:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=rdY63TdC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CfBxdKK+RW6h34KCEm0a8LsqSSwL+A0Ki+xU4tcOBSU=;
        b=rdY63TdCLzqf1IoUW+uJOW10qLkglQwr+qkcRV/yAxEkJjmolhBiG0qlwKTtKHQHZc
         m/Tg/DeM43wkROSwiJw6jgVBloQOM1ZZLBrjxYhT89sTAH6k/JhjmZbf1Zu9BWcEkYPK
         FIlB8PRsrHtOt2ZaphrytIdPKnN7xGylZTPlq+SBJBPvTz6BN07/2l4ZTD70yITZz5dz
         xfJ6q54mRL/W5hBbk1E2NDFc/mvY+XUQxi8lDmUkJo7EL2xYR/IwqDe6OOgvOyS0t0s2
         7AR1qzpAlDeABChjkFFp9QdzBzluYFygp+BH8MMUfEHnzuSp34Pe3ZEmQNj4riKB1Kht
         NbdQ==
X-Google-Smtp-Source: APXvYqyb7+naelNcLjxlj+hk/ascFI/dJST0XLT4HuP0CSw8DZGvpk4lsZtj7sgeA1s/YIsPKlV5QQ==
X-Received: by 2002:a0c:880f:: with SMTP id 15mr8218923qvl.126.1561732322885;
        Fri, 28 Jun 2019 07:32:02 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id s134sm1230855qke.51.2019.06.28.07.32.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 07:32:02 -0700 (PDT)
Date: Fri, 28 Jun 2019 10:32:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Sonny Rao <sonnyrao@chromium.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628143201.GB17212@cmpxchg.org>
References: <20190619080835.GA68312@google.com>
 <20190628111627.GA107040@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628111627.GA107040@google.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 07:16:27PM +0800, Kuo-Hsin Yang wrote:
> When file refaults are detected and there are many inactive file pages,
> the system never reclaim anonymous pages, the file pages are dropped
> aggressively when there are still a lot of cold anonymous pages and
> system thrashes.  This issue impacts the performance of applications
> with large executable, e.g. chrome.

This is good.

> Commit 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache
> workingset transition") introduced actual_reclaim parameter.  When file
> refaults are detected, inactive_list_is_low() may return different
> values depends on the actual_reclaim parameter.  Vmscan would only scan
> active/inactive file lists at file thrashing state when the following 2
> conditions are satisfied.
> 
> 1) inactive_list_is_low() returns false in get_scan_count() to trigger
>    scanning file lists only.
> 2) inactive_list_is_low() returns true in shrink_list() to allow
>    scanning active file list.
> 
> This patch makes the return value of inactive_list_is_low() independent
> of actual_reclaim and rename the parameter back to trace.

This is not. The root cause for the problem you describe isn't the
patch you point to. The root cause is our decision to force-scan the
file LRU based on relative inactive:active size alone, without taking
file thrashing into account at all. This is a much older problem.

After the referenced patch, we're taking thrashing into account when
deciding whether to deactivate active file pages or not. To solve the
problem pointed out here, we can extend that same principle to the
decision whether to force-scan files and skip the anon LRUs.

The patch you're pointing to isn't the culprit. On the contrary, it
provides the infrastructure to solve a much older problem.

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

This is all good again.

> Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")

Please replace this line with the two Fixes: lines that I provided
earlier in this thread.

Thanks.

