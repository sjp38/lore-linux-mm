Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3924C31E44
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 01:10:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E6AA21841
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 01:10:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E6AA21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3950C6B0006; Fri, 14 Jun 2019 21:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 346CB6B0007; Fri, 14 Jun 2019 21:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 235336B0008; Fri, 14 Jun 2019 21:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2F766B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 21:10:54 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n4so4846646ioc.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 18:10:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=W2jwYuNh5PBAuFJ+GMFbQ7qrbQqV37CEDEDewPHtdnI=;
        b=YdR2PPrKz9L+Ifq/p4minKi+IotPLx+hhERR27nOeADtecFfAbMFoC+sanOM3hqVls
         6MzowBPQnKEMrpq9QCbhZbbpIciR7x/beK0QW3NQjoH6ev/4Ti/SVPIv0tECyVw6tEI5
         Y6nDmTqJeE7djsxxWkUcooMLcOLvPq3YIbdHZ1E4FPaoCZwkIv630qRB3WGP9wiNGO6L
         7FHWh0E1mAAXJt9cfuleb9Fzuqs4+3WKkK4ecxgpQmD5UkN3bEbl2ejwPOlsEFqlCYVE
         IBt+KsEkYyZusXpCRSvO5kru6Qjp7mz5KmDQ747Lmg0OTreRpHn/RvwtMnUXgOjazzcz
         x20g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUn7ffggqWQ/Q64swgS0xhAXJpTt0if5IfR/C4DdKTUqEKfO+GF
	Ysbu2nNIjhu85WzoVQxS4VePTrxw5mThxq8UcSQp4a+xuv1zdTyoF1EgewzzCKBysu77RD8eie6
	Ul5FcIF3oMx1nBAbi7Rzv7dvHj2RpWHF3o80EVWOEiP4m05zmag21SUW1B+DGnvkyfw==
X-Received: by 2002:a6b:5106:: with SMTP id f6mr7823252iob.15.1560561054719;
        Fri, 14 Jun 2019 18:10:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxReKYPbwaTEJWY328z/PCGYdf0AouPfIgrnOWy8C0EzckMGsEcYriLYBQkdjoRGyStvHtE
X-Received: by 2002:a6b:5106:: with SMTP id f6mr7823200iob.15.1560561053969;
        Fri, 14 Jun 2019 18:10:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560561053; cv=none;
        d=google.com; s=arc-20160816;
        b=AGWnvYMcNRjuDj3pDu3479D5h6s2JTsX76PYUBm5EwhRYhUEMyZBM6XwoTobFsWUaY
         Ld0yYrDjSI0CKJ51p128xZNd8T3rpjRmpufeDXDljq0sjJwvcTOZTd5O5A+TYeaZQA3n
         +Xn6FOAsTkcSup9Xbt5ixs6lJv11BYYGpG+nRuB1zcg/mXuVwJtVQhVQ6+YkKlbi6i/N
         yjXRudO0oTyJL9mHHQQs2B5Qeu6qqIAa9kHtSEVy3XZDgtB+rNJcVFECNscDrRZvprX4
         zzUoBoRYwAIyfKqt54dGI08x2ZAVsrag8tnrubcMGyIH3fN6qtd8SoDt/wmwOUvg2g4O
         bkLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject;
        bh=W2jwYuNh5PBAuFJ+GMFbQ7qrbQqV37CEDEDewPHtdnI=;
        b=F/WCvnq8qNWmQGvFoiRFW2VUodO5YriyX9y6WWDBXZ9qlBcz4PKcGmyxYf8QeN4rpf
         YrW3L31Xr0SY2uuQ/uEFA2bpQHt2KRrZonfrAcAs0Rx1VDEE//5spYO8w/kbqKvDVtTZ
         OBuyUu8xPNrECQnyqERqreFgrAikgoWOaAUVAOUwSXlzZXKjIrLdmX67mqCBUfmVRns4
         r63I62sbiRVHY5QSqH+1Jewb8LLOvuCjBgvjDvxr3Xv6hHmGSfRziTiQGBtmQe9A+UCr
         lt8R5YBwTH+5fN0xKbV7K18DbVLX4e8BPBHs9qehXeEoOBpdOF3QU5zERNKjNpi5NuPc
         YC4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 129si5463342jae.94.2019.06.14.18.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 18:10:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav110.sakura.ne.jp (fsav110.sakura.ne.jp [27.133.134.237])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5F19xU0035307;
	Sat, 15 Jun 2019 10:09:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav110.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp);
 Sat, 15 Jun 2019 10:09:59 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav110.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5F19xuD035300
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 15 Jun 2019 10:09:59 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
To: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
        akpm@linux-foundation.org, mhocko@kernel.org
References: <0000000000004143a5058b526503@google.com>
Cc: ebiederm@xmission.com, guro@fb.com, hannes@cmpxchg.org, jglisse@redhat.com,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com,
        syzkaller-bugs@googlegroups.com, yuzhoujian@didichuxing.com
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <cc3d5247-855d-a124-041f-64c4659d95c3@i-love.sakura.ne.jp>
Date: Sat, 15 Jun 2019 10:10:00 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0000000000004143a5058b526503@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not sure this patch is correct/safe. Can you try memcg OOM torture
test (including memcg group OOM killing enabled) with this patch applied?
----------------------------------------
From a436624c73d106fad9b880a6cef5abd83b2329a2 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 15 Jun 2019 10:06:00 +0900
Subject: [PATCH] memcg: Protect whole mem_cgroup_scan_tasks() using RCU.

syzbot is reporting a GFP at for_each_thread() from a memcg OOM event [1].
While select_bad_process() in a global OOM event traverses whole threads
under RCU, select_bad_process() in a memcg OOM event is traversing threads
without RCU, and I guess that this can result in traversing bogus pointer.

Suppose a process containing three threads T1, T2, T3 is in a memcg.
T3 invokes memcg OOM killer, and starts traversing from T1. T3 elevates
refcount on T1, but T3 is preempted before oom_unkillable_task(T1) check.
Then, T1 reaches do_exit() and T1 does list_del_rcu(&T1->thread_node).

  do_exit() {
    cgroup_exit() {
      css_set_move_task(tsk, cset, NULL, false);
    }
    exit_notify() {
      release_task() {
        __exit_signal() {
          __unhash_process() {
            list_del_rcu(&p->thread_node);
          }
        }
      }
    }
  }

Then, T2 also reaches do_exit() and does list_del_rcu(&T2->thread_node).
Since the refcount of T1 was kept elevated by T3, T1 cannot be freed. But
since the refcount of T2 was not elevated by T3, T2 can complete do_exit()
and T2 is freed as soon as RCU grace period elapsed. At this point, since
T1 was removed from thread group before T2 was removed, T1's next thread
remains already freed T2. If memory used for T2 was reallocated before T3
resumes execution, accessing T1's next thread will not be reported as
use-after-free but memory referenced as T1's next thread contains bogus
values.

Thus, I think that the rule is: when traversing threads inside a section
between css_task_iter_start() and css_task_iter_end(), each thread must
not involve e.g. for_each_thread() unless whole section is protected by
RCU.

[1] https://syzkaller.appspot.com/bug?id=4559bc383e7c73a35bc6c8336557635459fb7a62

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a..8e01f01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1159,6 +1159,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 
 	BUG_ON(memcg == root_mem_cgroup);
 
+	rcu_read_lock();
 	for_each_mem_cgroup_tree(iter, memcg) {
 		struct css_task_iter it;
 		struct task_struct *task;
@@ -1172,6 +1173,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
 			break;
 		}
 	}
+	rcu_read_unlock();
 	return ret;
 }
 
-- 
1.8.3.1

