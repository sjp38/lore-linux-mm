Return-Path: <SRS0=Pe7y=QC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC0B4C282C0
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 01:57:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0C7A21855
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 01:57:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0C7A21855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27D478E00F7; Fri, 25 Jan 2019 20:57:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22E628E00F6; Fri, 25 Jan 2019 20:57:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11CDA8E00F7; Fri, 25 Jan 2019 20:57:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D84118E00F6
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 20:57:20 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id h85so5407180oib.9
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 17:57:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vCQigGJo5Mn6zVHWDFJ7kjPYzxP/O+aT6X8KSRh95JY=;
        b=jK+qD7pgsEh1WhZmiX5WXd83l4cRsT5SCx9OeV4Wcmjbx0l6oggKT+6PBrNVuauAiT
         MsMK+ysvXb8Ueh/gwe+WZb/dL7kpu6TgPLOienEKu5ftcapEZFyUWhOST3Of5zkyrsnc
         ddN4NllvYZ3h8uZseE+06kt4gg+VWLXtSITkjQz6+QuEtMIM5Xk3TPUZelwsHXNajosJ
         eomzoRJMs+IYcZgHoODT8WJhUgnBv5nJ/F87kQudf3is84PgU9jHCd/G/DHmUjXUDfLS
         sTxuMbgs3FrVOH4fCGiz0eIljCTebvdWu11IpHlb0brfrTvWTalTzqLlVxebxwL+2aMu
         raig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukcs/5AB3Sg1ZU1BAF8kBj3sbce2cuGVXPufc7Pt6iy1fxqWtHI9
	OdAiQOT22fUiHkoTwl/qkoQLkWPpchiLIaAn4oNDWpW1q9hBHrM1PUB+vQsEoXWpZ/wbkMd2EyC
	TbAiT/n1ztUibNKFhcs3WSgoqN0NZEZPnZTLBnWA65XnblN2APom+DaEwyOwoWAeWgg==
X-Received: by 2002:aca:a881:: with SMTP id r123mr372179oie.207.1548467840549;
        Fri, 25 Jan 2019 17:57:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6fiSlilEFLCbCrdA2FudZdwayyARL7tAyWB5Wch2JTHciH85V4iM88KiVejAq9uvjpjL2y
X-Received: by 2002:aca:a881:: with SMTP id r123mr372149oie.207.1548467839751;
        Fri, 25 Jan 2019 17:57:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548467839; cv=none;
        d=google.com; s=arc-20160816;
        b=jXZyNn0dog2d8GAdE4ksMKk6kNyTswhfvnQD6o9j49gVwP3iYpxLTiRArHCxMnhzqH
         hEOrrjPWbX2yXraeEiSUALs4Y7h83qRxDgdNcyQfDDaYf2tc5s+3aVKBaDi9S5zW7gxf
         Lu/AHDJKYwUtxoYWqvyH9hNma+zE55nKPdWvR4WbouVDcztpzX4JyqGVvgR5GJQCNEPt
         QEzsZ+YiAQaYShTdpT4G30T1GMfxTJnhqNY0oU5XmQMegyqmFmv54K07rASoBHU93/qX
         YYyHcL23o5gLUtQZNzwv/n6IHoTex/0LBPX8R9AQ27n/4m06+iQ5tSGuZbDzdREOMYRi
         1tWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vCQigGJo5Mn6zVHWDFJ7kjPYzxP/O+aT6X8KSRh95JY=;
        b=LZPxLD6M40rQBFjGfkvAFhKT+NInGV47RqS3iZ+kFRGK44o88s2PaMt+7y8SD0KMhb
         QzXgkNqs6eHqfLJxZ4Jh/rWBZsH8FzIQwE1XPd8Cjf9frjKplOPz6SvfK4S8jFgq7kDZ
         4IvvaC3AeacOPfRgN6BXdfVjJ6iBvvM+uGkSJpEh/8dedT/2zRyeIfbNnmkflhHyJnpq
         RnIr6LkCv3i4VMV4o3FFcgYgmoKvPPgEzuETTmc+iTl4u0gGVGw4iLhHpWw4P1N9CDwQ
         sA4HVq+ZctAtK711hUpw6HjocxWe2wMFVBxDNO4clim5zltASUQUS/yBwpdjZYloT9OH
         cs2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i203si2011993oih.81.2019.01.25.17.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 17:57:19 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0Q1v3dZ074969;
	Sat, 26 Jan 2019 10:57:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Sat, 26 Jan 2019 10:57:03 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0Q1v3aU074964
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 26 Jan 2019 10:57:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: possible deadlock in __do_page_fault
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>,
        syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com,
        ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz,
        jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org, mawilcox@microsoft.com,
        mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com,
        =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?=
 <arve@android.com>,
        Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp>
 <20190123155751.GA168927@google.com>
 <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
 <20190124134646.GA53008@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <06b4806c-6b53-85a5-84db-fa432ea4ccd0@i-love.sakura.ne.jp>
Date: Sat, 26 Jan 2019 10:57:03 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190124134646.GA53008@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190126015703.BIRhhkH76T49XElxQ7zaJWXADnguprkBf7Wp-y8mqtk@z>

On 2019/01/24 22:46, Joel Fernandes wrote:
> On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
>> Then, I'm tempted to eliminate shrinker and LRU list (like a draft patch shown
>> below). I think this is not equivalent to current code because this shrinks
>> upon only range_alloc() time and I don't know whether it is OK to temporarily
>> release ashmem_mutex during range_alloc() at "Case #4" of ashmem_pin(), but
>> can't we go this direction? 
> 
> No, the point of the shrinker is to do a lazy free. We cannot free things
> during unpin since it can be pinned again and we need to find that range by
> going through the list. We also cannot get rid of any lists. Since if
> something is re-pinned, we need to find it and find out if it was purged. We
> also need the list for knowing what was unpinned so the shrinker works.
> 
> By the way, all this may be going away quite soon (the whole driver) as I
> said, so just give it a little bit of time.
> 
> I am happy to fix it soon if that's not the case (which I should know soon -
> like a couple of weeks) but I'd like to hold off till then.
> 
>> By the way, why not to check range_alloc() failure before calling range_shrink() ?
> 
> That would be a nice thing to do. Send a patch?

OK. Here is a patch. I chose __GFP_NOFAIL rather than adding error handling,
for small GFP_KERNEL allocation won't fail unless current thread was killed by
the OOM killer or memory allocation fault injection forces it fail, and
range_alloc() will not be called for multiple times from one syscall.

But note that doing GFP_KERNEL allocation with ashmem_mutex held has a risk of
needlessly invoking the OOM killer because "the point of the shrinker is to do
a lazy free" counts on ashmem_mutex not held by GFP_KERNEL allocating thread.
Although other shrinkers likely make forward progress by releasing memory,
technically you should avoid doing GFP_KERNEL allocation with ashmem_mutex held
if shrinker depends on ashmem_mutex not held.



From e1c4a9b53b0bb11a0743a8f861915c043deb616d Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 26 Jan 2019 10:52:39 +0900
Subject: [PATCH] staging: android: ashmem: Don't allow range_alloc() to fail.

ashmem_pin() is calling range_shrink() without checking whether
range_alloc() succeeded. Since memory allocation fault injection might
force range_alloc() to fail while range_alloc() is called for only once
for one ioctl() request, make range_alloc() not to fail.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/ashmem.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index d40c1d2..a8070a2 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -171,18 +171,14 @@ static inline void lru_del(struct ashmem_range *range)
  * @end:	   The ending page (inclusive)
  *
  * This function is protected by ashmem_mutex.
- *
- * Return: 0 if successful, or -ENOMEM if there is an error
  */
-static int range_alloc(struct ashmem_area *asma,
-		       struct ashmem_range *prev_range, unsigned int purged,
-		       size_t start, size_t end)
+static void range_alloc(struct ashmem_area *asma,
+			struct ashmem_range *prev_range, unsigned int purged,
+			size_t start, size_t end)
 {
 	struct ashmem_range *range;
 
-	range = kmem_cache_zalloc(ashmem_range_cachep, GFP_KERNEL);
-	if (!range)
-		return -ENOMEM;
+	range = kmem_cache_zalloc(ashmem_range_cachep, GFP_KERNEL | __GFP_NOFAIL);
 
 	range->asma = asma;
 	range->pgstart = start;
@@ -193,8 +189,6 @@ static int range_alloc(struct ashmem_area *asma,
 
 	if (range_on_lru(range))
 		lru_add(range);
-
-	return 0;
 }
 
 /**
@@ -687,7 +681,8 @@ static int ashmem_unpin(struct ashmem_area *asma, size_t pgstart, size_t pgend)
 		}
 	}
 
-	return range_alloc(asma, range, purged, pgstart, pgend);
+	range_alloc(asma, range, purged, pgstart, pgend);
+	return 0;
 }
 
 /*
-- 
1.8.3.1

