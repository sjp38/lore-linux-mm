Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF897C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AB992075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:11:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="zjoAxtmU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AB992075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33D56B026A; Wed,  5 Jun 2019 12:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE48C6B026B; Wed,  5 Jun 2019 12:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE6B6B026C; Wed,  5 Jun 2019 12:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6406B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:11:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so16368703pla.7
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KwGTPhlO4F01V7ggP/cBc9JouzklE/A9aHOmDIgUHBk=;
        b=QEo0h03H85r5Vd48xN7RHjdUGZ2iyXDYtT4L0tOt3QZeoLo0ZaCHHC/Afmmztu9KDp
         cOvXFCMjoYsKKVXhs2QEXEhmBYOjuzcZh7JYCANFrzb2ovg0b0CV/X3t2UbpucKc8pKV
         yTBUUxpS0Mni0tR2LcX799fRza5QHJZDkjebRMYwdvjI37pS3jpVLCOWaPgTdb17zp8K
         3zz4pRLAQcfmJ+JEsxa+GOx9P1VkI8T+rQXPJGbauzYcPD4VDBQvSOM705aIf8+xL5KZ
         rS70RB7hVkNcYSrkxh2mv0ji4aY0BoB/uQ68QUjevJr1cQID7zv7nW7JkPQT29MrsNUb
         YlJA==
X-Gm-Message-State: APjAAAVD7KgLJbYhBi6dBLHX9nIQ5iwmvOMlfKiAJYp2h/r1vafWDG0M
	m8rkAHIy6Yaqi7labb+CCymNSlzYl/9/dL4vKXBCDLTgNPyNvF+uD76xY24xdB52ZoAJsrL5jxb
	7Lc0Wa5qw5q2si5CrUQ3Mv+p+6AVi0LeJGfQ6trFF4mk/OgkLJA1OUhDeUyOK6mKIWw==
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr31306739ply.342.1559751100147;
        Wed, 05 Jun 2019 09:11:40 -0700 (PDT)
X-Received: by 2002:a17:902:d695:: with SMTP id v21mr31306619ply.342.1559751098996;
        Wed, 05 Jun 2019 09:11:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559751098; cv=none;
        d=google.com; s=arc-20160816;
        b=yo6MfgRz8jvpBtOB/3eXbGbuKhTjtk1jDR3hQUWsBexzBviQUZ6V9ooS1coe2k80K/
         a2ryTe5sjNH+pKvuQhDU0zhgzrvlplZW+Ho6W2XpY5pQfoc8ptGAwmE10pWAo2aGNATY
         8O0eqUFkdcWVpHctGh+7KYm1MCngoUd1wao2Z80LoUm/NUjDvBK3ZtN+lxf0CegLDbIG
         BtIBImyCrJg87zq5deHPPKdMiLejVF15rXTiWt1Ms5zb7qK/7ufpOH/oEZkiLCS8n+gp
         RA1sAwEv5mjr9UF5u8vpzmuqJvYAEfx4cd7AaxxefYARox4aM72iInW6lkj4nR3MXXf/
         02aQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KwGTPhlO4F01V7ggP/cBc9JouzklE/A9aHOmDIgUHBk=;
        b=jN09cEYRSB3Akian2xh9/Ium5+lkkcc+sBn6RAiOJjqJ9YyAlZHoTC+1bWsP8EOz2B
         NT5pHDXU0sAOIpDytPkizlMroQolqVbYalhwdf7KZH4ZR8dsEOnspPZqPM52BfM4/z9P
         4vXEJiEDWI38kyfvmpwO4isSGjzbaHYuZEAMKxZbffhDbM61yxmIwYG2O1Ryav1OpUUB
         D6WvMZE5VWim+hvfjnfjVYAzgfdohShBEErgGcUXgyW84geUNpFZo7/RsAHHntc4wLp7
         15D15z1I6r3nzaynh+sJBuSBP0LPt0M6zYQ0k7at64bM7V+Zd2WVE2hy/Mey4/5BJw17
         NgwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=zjoAxtmU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h90sor5344443plb.26.2019.06.05.09.11.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 09:11:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=zjoAxtmU;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KwGTPhlO4F01V7ggP/cBc9JouzklE/A9aHOmDIgUHBk=;
        b=zjoAxtmU+7WyTYQ00sJFDH6OJqtCjZpplgs9SVN+RWNg6guyKEzFqHxWvkeWD5xfQx
         3viyeJVCAPj+8k0LO4Z+bc2QpTkfCW9m8xZE9z6fUdeDh7YFKe1UZZyi0rL238e8zESs
         MYs+yNFzM+DRnW6HrIeF6FbVmC7ddiFnlLH2M9Lor+6Q+h9+zxEHT4bocMkRdEW4SE1O
         tCd8Z2lNM9FmEhZvR0Aq+vQRXZxxJ1ZRDemdOvmtML38bbyLZbowaKM5F0TdIWZ+tBA3
         yyUMzaBENQiqhfUXhFhSk3/uadr0bUA4xkuQeThSRBjkw90iT+SCdxg/HHsZwmrIAtTf
         UMfQ==
X-Google-Smtp-Source: APXvYqzRcWHUDNkdKFYTdIkL15U3HOaNWIkBFbGPcJrWTqB/LeooYydW5MnjfgZx/KAQu0s/mvfszA==
X-Received: by 2002:a17:902:b402:: with SMTP id x2mr45364816plr.128.1559751096018;
        Wed, 05 Jun 2019 09:11:36 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:9bd9])
        by smtp.gmail.com with ESMTPSA id k14sm43340134pga.5.2019.06.05.09.11.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 09:11:34 -0700 (PDT)
Date: Wed, 5 Jun 2019 12:11:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: dump memory.stat during cgroup OOM
Message-ID: <20190605161133.GA12453@cmpxchg.org>
References: <20190604210509.9744-1-hannes@cmpxchg.org>
 <20190605120837.GE15685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605120837.GE15685@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:08:37PM +0200, Michal Hocko wrote:
> On Tue 04-06-19 17:05:09, Johannes Weiner wrote:
> > The current cgroup OOM memory info dump doesn't include all the memory
> > we are tracking, nor does it give insight into what the VM tried to do
> > leading up to the OOM. All that useful info is in memory.stat.
> 
> I agree that other memcg counters can provide a useful insight for the OOM
> situation.
> 
> > Furthermore, the recursive printing for every child cgroup can
> > generate absurd amounts of data on the console for larger cgroup
> > trees, and it's not like we provide a per-cgroup breakdown during
> > global OOM kills.
> 
> The idea was that this information might help to identify which subgroup
> is the major contributor to the OOM at a higher level. I have to confess
> that I have never really used that information myself though.

Yeah, same. The thing is that sometimes we have tens or even hundreds
of subgroups, and when an OOM triggers at the top-level the console
will be printing for a while. But often when you have that big of a
shared domain it's because you just run a lot of parallel instances of
the same job, and when the oom triggers it's because you ran too many
jobs rather than one job acting up. In more hybrid setups, we tend to
also configure the limits more locally.

> > When an OOM kill is triggered, print one set of recursive memory.stat
> > items at the level whose limit triggered the OOM condition.
> > 
> > Example output:
> > 
> [...]
> > memory: usage 1024kB, limit 1024kB, failcnt 75131
> > swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> > Memory cgroup stats for /foo:
> > anon 0
> > file 0
> > kernel_stack 36864
> > slab 274432
> > sock 0
> > shmem 0
> > file_mapped 0
> > file_dirty 0
> > file_writeback 0
> > anon_thp 0
> > inactive_anon 126976
> > active_anon 0
> > inactive_file 0
> > active_file 0
> > unevictable 0
> > slab_reclaimable 0
> > slab_unreclaimable 274432
> > pgfault 59466
> > pgmajfault 1617
> > workingset_refault 2145
> > workingset_activate 0
> > workingset_nodereclaim 0
> > pgrefill 98952
> > pgscan 200060
> > pgsteal 59340
> > pgactivate 40095
> > pgdeactivate 96787
> > pglazyfree 0
> > pglazyfreed 0
> > thp_fault_alloc 0
> > thp_collapse_alloc 0
> 
> I am not entirely happy with that many lines in the oom report though. I
> do see that you are trying to reduce code duplication which is fine but
> would it be possible to squeeze all of these counters on a single line?
> The same way we do for the global OOM report?

TBH I really hate those in the global reports because I always
struggle to find what I'm looking for. And smoking guns don't stand
out visually either. I'd rather have newlines there as well.

> > +	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
> 
> What is the reason to use kvmalloc here? It doesn't make much sense to
> me to use it for the page size allocation TBH.

Oh, good spot. I first did something similar to seq_file.c with an
auto-resizing buffer in case we print too much data. Then decided
that's silly since everything that will print into the buffer is right
there, and it's obvious that it'll fit, so I did the fixed allocation
and the WARN_ON instead.

How about a simple kmalloc?. I know it's a page sized buffer, but the
gfp interface seems a bit too low-level and has weird kinks that
kmalloc nicely abstracts into a sane memory allocation interface, with
kmemleak support and so forth...

Thanks for your review.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0907a96ceddf..b0e0e840705d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1371,7 +1371,7 @@ static char *memory_stat_format(struct mem_cgroup *memcg)
 	struct seq_buf s;
 	int i;
 
-	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
+	seq_buf_init(&s, kmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
 	if (!s.buffer)
 		return NULL;
 
@@ -1533,7 +1533,7 @@ void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
 	if (!buf)
 		return;
 	pr_info("%s", buf);
-	kvfree(buf);
+	kfree(buf);
 }
 
 /*
@@ -5775,7 +5775,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	if (!buf)
 		return -ENOMEM;
 	seq_puts(m, buf);
-	kvfree(buf);
+	kfree(buf);
 	return 0;
 }
 

