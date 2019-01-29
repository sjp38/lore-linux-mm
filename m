Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92765C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7D62147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:44:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7D62147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D55DB8E0005; Tue, 29 Jan 2019 05:44:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D061F8E0001; Tue, 29 Jan 2019 05:44:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCE288E0005; Tue, 29 Jan 2019 05:44:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 946708E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:44:26 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id x2so16227447ioa.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:44:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6X4PokfNECEk4apyNdbjJvZKfXHjUlslrcq9nWqP/LQ=;
        b=LzDaB3s1RZn/mCzhx3L3wA7GvZ63oPc6ENzbVOhTEPedJGDud6W2wMVVjgDRMatU2M
         swVZUMS3dAb0Yje6SrzQ1m99MZd+eL4Xo++i7GmceHcauGh4ofX1vLsGyu63i4pBgxM1
         OVcc106+Vny37tA3E4o0vpXaGuolM59HA5aZtWbbCZ3WfEAAj1s7L2m8n3uJJAvAze8G
         uSkKwSLaQDnpEE4+9Y/Flb5hCQdrHyDfpzoOkxnWhOQuNw/2M9Nz0NDW2ndr0IHWjVbB
         ZZhaKDI0erviekc9EAe/ppkm7ia+ex0tLMdh5ZjQBF/sbRDPB6eo0kAc3kVr3Opbp8F4
         b60Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukdnEaagyQAWKOFltkKEOuebIixhui5UCbjpPuF0/oaLLY7CkN1E
	AbXc40WJefbWwA/8ZNMPBr4KG9Ifg7PktJW3vpeJlbZ4Wey6+V6h3T2uFx3cWz3poAe+iOt1RQw
	UG1Sem/ffii3F5qxCLDecSmt2j9vOjF9ojR8+/gK08YmYR6xWZP4MXH5dkGINT7Q+sg==
X-Received: by 2002:a24:1115:: with SMTP id 21mr14326740itf.5.1548758666388;
        Tue, 29 Jan 2019 02:44:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7skGbTiRcG+GIJi+GztG5SnhIOWO95Z7NDNquQfWu9ZNJWXM7GQcU/v2Tp7AiBy7gcPIUQ
X-Received: by 2002:a24:1115:: with SMTP id 21mr14326718itf.5.1548758665590;
        Tue, 29 Jan 2019 02:44:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548758665; cv=none;
        d=google.com; s=arc-20160816;
        b=mJjnTSirExs8MnB4HSFU3iqGh0/r6dXglXieHUTtt4Rh46BPBsIquFdp2dYD1eQlUr
         GOomGMc2szokiS7SpktdgHNCBuRRD1LXy08ZyxzJOcbpprdtjIVK2g6/QiI1sysCeQ7V
         VrKOYUHGIXfLRJS2Mz+cbxVwFVjPawlndRWwp0dza2i2JoIHqq01G25VBvW8apl84m5E
         hHpvflgHAUQZ3QKl5TXWAuzuP4kpcCFLdmv4v3FIXH9PHvwUTWyQ+VFXXJDb1GC7sU1M
         AoaKXZ3nG37zOojymZA/TtmB+bxUlUg402Wjx8Iuw+fYvopdcYRqLft+qzmNRLDJzu5u
         1U/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6X4PokfNECEk4apyNdbjJvZKfXHjUlslrcq9nWqP/LQ=;
        b=Z5Oueov0aKZy+pkAnIsVUxY9FPLzG4n9Dxb8BXSjOqM9ucPoMHSMKkkmjZO+oPEypG
         D3o6hVK2qy6qMfgD1VWP6EWrZp0rh4HPNO6GxaG65lQMlSdGtPlTRybTSW+EVP6eFb8D
         hxC7Kf7cmpIHlEI5aexNgxb06k1LSr0V2DC74Nb4VLsnzG5P+gxkj7zXoW6E3sNlcDm8
         nhFelleNkSyo20SRuQ88inv5fKmHGX5wwhXtiyLQpX7+fR2row/KaM265VkpwzHelkyO
         v42biIhvJYndhZ0pcSI5P7ZBnZECpX8+EoKoWKe+fY+HqZ+vDAgPs7I9akn1LgJZsuV1
         qHNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g7si1629851jac.44.2019.01.29.02.44.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:44:25 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav302.sakura.ne.jp (fsav302.sakura.ne.jp [153.120.85.133])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0TAi6Pr059092;
	Tue, 29 Jan 2019 19:44:06 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav302.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav302.sakura.ne.jp);
 Tue, 29 Jan 2019 19:44:06 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav302.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0TAi59p059088
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 29 Jan 2019 19:44:06 +0900 (JST)
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
 <d736c8f5-eba1-2da8-000f-4b2a80ad74ff@i-love.sakura.ne.jp>
 <20190128164502.GA260885@google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <17f26aab-4a25-dba9-7d39-40df80d1eadb@i-love.sakura.ne.jp>
Date: Tue, 29 Jan 2019 19:44:02 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190128164502.GA260885@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/01/29 1:45, Joel Fernandes wrote:
>>  		freed += range_size(range);
>> +		mutex_unlock(&ashmem_mutex);
>> +		f->f_op->fallocate(f,
>> +				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
>> +				   start, end - start);
>> +		fput(f);
>> +		if (atomic_dec_and_test(&ashmem_shrink_inflight))
>> +			wake_up_all(&ashmem_shrink_wait);
>> +		mutex_lock(&ashmem_mutex);
> 
> Let us replace mutex_lock with mutex_trylock, as done before the loop? Here
> is there is an opportunity to not block other ashmem operations. Otherwise
> LGTM. Also, CC stable.

If shrinker succeeded to grab ashmem_mutex using mutex_trylock(), it is
guaranteed that that thread is not inside

  mutex_lock(&ashmem_mutex);
  kmalloc(GFP_KERNEL);
  mutex_unlock(&ashmem_mutex);

block. Therefore, I think that it is safe to use mutex_lock() here.

Nonetheless, although syzbot did not find other dependency, I can update this
patch to use mutex_trylock() if you worry about not-yet-discovered dependency.



From fd850fecd248951ad1ad26b37ec5bf84afe41cbb Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 29 Jan 2019 10:56:47 +0900
Subject: [PATCH v2] staging: android: ashmem: Don't call fallocate() with ashmem_mutex held.

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
Cc: stable@vger.kernel.org
---
 drivers/staging/android/ashmem.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 90a8a9f1ac7d..ade8438a827a 100644
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
@@ -448,21 +450,33 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
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
+		if (!mutex_trylock(&ashmem_mutex))
+			goto out;
 		if (--sc->nr_to_scan <= 0)
 			break;
 	}
 	mutex_unlock(&ashmem_mutex);
+out:
 	return freed;
 }
 
@@ -713,6 +727,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 		return -EFAULT;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
 
 	if (!asma->file)
 		goto out_unlock;
-- 
2.17.1


