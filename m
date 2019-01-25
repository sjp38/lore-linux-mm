Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3422C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 16:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F00B218D0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 16:02:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F00B218D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7E28E00D8; Fri, 25 Jan 2019 11:02:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E75A78E00D7; Fri, 25 Jan 2019 11:02:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D674A8E00D8; Fri, 25 Jan 2019 11:02:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABBD28E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:02:28 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id k133so5991985ite.4
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 08:02:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CqCtzfmNIlsjjr37EaboZ+t7nVgdj0ZPM+y425F5GJQ=;
        b=t34WhCgTPb/ifFtnI01HsTRDVQ5YEuJ3zRd28JOA1rjpAvb6BHZtb3hZ1C+p89DRoR
         0ouUPMHI93TdJN4IRjDZWjpXqkhCsrGh23UW5t1mSGTu6/0iP9jJEIoQrfxDz8OQ+xcj
         nAS9bx4g1PDDkiatdvoPaEFoFvLDX4XvMMOCPdv2iKp4LrEmvI1gVkqsZRObk+uCq1qO
         fw81j39N7lrWcX4ayJgWuDhxerWU80l4b4RPl19hg6jXynWGe++At3UG/89aRYtOMnb2
         Rx7TVFoW9omMta302O31OMKQgRrlBPP/2Bq+HFVhgOoHBunzkaclv3whXhmH0OfSHYlQ
         o2vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukesW8nUkOhP0wtqKUpQsVS6Il8gAwxviNaHuNtYWash9k0rjdI5
	ZENDhTMmtfxeRQMW+eZP2opjwQA2qZ314hhohlU2xFXngs1A0CmISyW+i+7xThcT8kUB/flN0d8
	9NSYrsopOSqevVRsnUnFOh5RcIsMuBB4C6nlM1ht/xoPJhrvxo43ArGpPU7rDqmMwpQ==
X-Received: by 2002:a02:a791:: with SMTP id e17mr7930925jaj.104.1548432148356;
        Fri, 25 Jan 2019 08:02:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7xJ1YhEIg1hJWn1WPdAnlEeJnqtU2dBRQWFGdKqbDbWFXW4lKJ4CZdbN2wTND7imr9yibz
X-Received: by 2002:a02:a791:: with SMTP id e17mr7930872jaj.104.1548432147389;
        Fri, 25 Jan 2019 08:02:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548432147; cv=none;
        d=google.com; s=arc-20160816;
        b=QCKKj8CSUZyfbYyyw9nnGRB622ojG+XkhyVZ8UakGpUjPjNz8zhtPcDh8r5wxQKTva
         t4m1dWMq1vGvIP2y9y4M4RVVxraP/FOcqnIXQ9D4zUJTYgwAaaRy+H01Z+w2x1VZGw3W
         JnodtjWFGnR93pe3PIr2g4rVcoZ5iqi5SqxXuARFIzP9X6JvzdsDuuskjjJT1S3yLzZV
         HsSdmlphMKkP4S7PxUncnWclW8G9HzzjIE17mMjK+ezceDztsKhLugqB63roG33Cz1Dh
         0BiDEBXeGXetz6UjLVY4OJnTnztpaZ8vY7EaSOivkR4T8hZLrxmQ3UnjWLd7tL+YDRVC
         EasA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CqCtzfmNIlsjjr37EaboZ+t7nVgdj0ZPM+y425F5GJQ=;
        b=TtO3zVqQJBJ2mD9iK+z1gcc0/ZLatKQs6a/23zLHQW2TMpziQ+0CQ3NSJOw5/fQ8NZ
         NcEUJJ1ZPWkhbP25BfP/6M9fjeoNeVFdlIhHkwZ5LkYknqVCU26R1H08ocWAVPDu4FJ4
         v/4WoMfZYC+YfU+/REk/OZED3w14krjbCrRMV3LcVfrOF+oW6STCeYG24f/nmbi6ySQ+
         3UqxZVugAPykr5n5MJNmJ5ozNSNAkKcsEkdm3+/3mbnE7iQnvkgX6EQ3gZbGeaUyxJKF
         hb6I+2cEAAq660okfO8q4uljgbeEkMpKiAFGAVgxyXJaTVRz97BAZmffAjGhOgSsoV+z
         OD4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 8si5800709jak.74.2019.01.25.08.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 08:02:27 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0PG26fg055728;
	Sat, 26 Jan 2019 01:02:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Sat, 26 Jan 2019 01:02:06 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0PG26Rv055723
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 26 Jan 2019 01:02:06 +0900 (JST)
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
Message-ID: <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
Date: Sat, 26 Jan 2019 01:02:06 +0900
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
Message-ID: <20190125160206.Lfyx0PANeYIdIaPchF-v6h4CR00qVm2tFHf2jEck24s@z>

On 2019/01/24 22:46, Joel Fernandes wrote:
> On Thu, Jan 24, 2019 at 10:52:30AM +0900, Tetsuo Handa wrote:
>> Joel Fernandes wrote:
>>>> Anyway, I need your checks regarding whether this approach is waiting for
>>>> completion at all locations which need to wait for completion.
>>>
>>> I think you are waiting in unwanted locations. The only location you need to
>>> wait in is ashmem_pin_unpin.
>>>
>>> So, to my eyes all that is needed to fix this bug is:
>>>
>>> 1. Delete the range from the ashmem_lru_list
>>> 2. Release the ashmem_mutex
>>> 3. fallocate the range.
>>> 4. Do the completion so that any waiting pin/unpin can proceed.
>>>
>>> Could you clarify why you feel you need to wait for completion at those other
>>> locations?

OK. Here is an updated patch.
Passed syzbot's best-effort testing using reproducers on all three reports.

From f192176dbee54075d41249e9f22918c32cb4d4fc Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 25 Jan 2019 23:43:01 +0900
Subject: [PATCH] staging: android: ashmem: Don't call fallocate() with ashmem_mutex held.

syzbot is hitting lockdep warnings [1][2][3]. This patch tries to fix
the warning by eliminating ashmem_shrink_scan() => {shmem|vfs}_fallocate()
sequence.

[1] https://syzkaller.appspot.com/bug?id=87c399f6fa6955006080b24142e2ce7680295ad4
[2] https://syzkaller.appspot.com/bug?id=7ebea492de7521048355fc84210220e1038a7908
[3] https://syzkaller.appspot.com/bug?id=e02419c12131c24e2a957ea050c2ab6dcbbc3270

Reported-by: syzbot <syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com>
Reported-by: syzbot <syzbot+148c2885d71194f18d28@syzkaller.appspotmail.com>
Reported-by: syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/staging/android/ashmem.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 90a8a9f..d40c1d2 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -75,6 +75,9 @@ struct ashmem_range {
 /* LRU list of unpinned pages, protected by ashmem_mutex */
 static LIST_HEAD(ashmem_lru_list);
 
+static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
+
 /*
  * long lru_count - The count of pages on our LRU list.
  *
@@ -438,7 +441,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 static unsigned long
 ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
-	struct ashmem_range *range, *next;
 	unsigned long freed = 0;
 
 	/* We might recurse into filesystem code, so bail out if necessary */
@@ -448,17 +450,27 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	if (!mutex_trylock(&ashmem_mutex))
 		return -1;
 
-	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
+	while (!list_empty(&ashmem_lru_list)) {
+		struct ashmem_range *range =
+			list_first_entry(&ashmem_lru_list, typeof(*range), lru);
 		loff_t start = range->pgstart * PAGE_SIZE;
 		loff_t end = (range->pgend + 1) * PAGE_SIZE;
+		struct file *f = range->asma->file;
 
-		range->asma->file->f_op->fallocate(range->asma->file,
-				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-				start, end - start);
+		get_file(f);
+		atomic_inc(&ashmem_shrink_inflight);
 		range->purged = ASHMEM_WAS_PURGED;
 		lru_del(range);
 
 		freed += range_size(range);
+		mutex_unlock(&ashmem_mutex);
+		f->f_op->fallocate(f,
+				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				   start, end - start);
+		fput(f);
+		if (atomic_dec_and_test(&ashmem_shrink_inflight))
+			wake_up_all(&ashmem_shrink_wait);
+		mutex_lock(&ashmem_mutex);
 		if (--sc->nr_to_scan <= 0)
 			break;
 	}
@@ -713,6 +725,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 		return -EFAULT;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	if (!asma->file)
 		goto out_unlock;
-- 
1.8.3.1

