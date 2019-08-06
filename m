Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3F3DC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 960EC20B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 12:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 960EC20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27F116B0005; Tue,  6 Aug 2019 08:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 230E86B0006; Tue,  6 Aug 2019 08:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F72D6B0007; Tue,  6 Aug 2019 08:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id D60A96B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 08:48:35 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id x18so49203418otp.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 05:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=r+AYLnfKGfufrO8W6cq39b4l7nQ4liUYXfHMkw9/XLM=;
        b=fKOBhVbkqtJAStsbk+nXIGcH6r5ewHvZR3I1C4ICzHv2kMi7N3mVI4558AlRFea4BU
         GGmHgPfUOp6UXYqzI2NHYAgvikf82kI2xJ2BTpldzsMCKruNGnRUFS2fUpgatIrGXy5K
         wI500S+/ahV9d3TwjI7KsoEXBKqpHUbfUhw8ocXoNvji2EGyJF9Yod4yJw7Hk4Ayzy4t
         4VM2uLQ6mf/6vDfrAlvebmowM8DigfomVCKK6Z75cz0oW2YDDgKLOr3FalXzN90J/dOw
         +VfEG89augdo7hz5GIKiEcU7YjHt0Bw1Ks5KWzPfLS4Jd0h6qML3UW7L74YLnRWzznnN
         xuFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUPRFryMQ/yo/Y0Kg53uzHMKxza58U45UVb45qZ4XIEIHyil2JV
	UwHZqE1UodBDfcgkrJdDUSfTy4NbnhZvKwewS/pYwGxbdur8TMMIAjYrA+VtWOofpdamALLmksk
	G/h6YWaMKCCQHRgXsJqASjupFzcjJac+GF4gy01Pdf44rEkiQDPPuwHb9mPGUh+ziFA==
X-Received: by 2002:a6b:8f0d:: with SMTP id r13mr3265957iod.121.1565095715460;
        Tue, 06 Aug 2019 05:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTq0eKMDRlR01j3w5+tPU9AeZMnO60NnhMFiPmhTXhIY9T/dGxd9rMnkzXkon32EHxSliA
X-Received: by 2002:a6b:8f0d:: with SMTP id r13mr3265826iod.121.1565095713704;
        Tue, 06 Aug 2019 05:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565095713; cv=none;
        d=google.com; s=arc-20160816;
        b=CVEV1WdrMebJhGoS78zDQvEgxyIjOFaRVzO6Tmi+NUAMtmxu3l84eugJ7mfPLQnTXz
         pAHKp/p3yjKj8jqS3IsSWiqfygtLGVlMs075PCMUKUMRnrtvzA0zWL1JnAvzCGV+1dsd
         vBM7gd6GyOqotmCLL67quJ3nQY56B2r/cujggomRfTs86blfTPof4tKE/ifculTtdSsp
         Qoah7sKum+7B7idXRHZ7NigukZ9JhcXwKqICcV94b/QXuy1y4cVFfj/rcb4TMbnW2U0J
         4uSPXtR9g1CoZsJQ+HAdamN4ZYpe5/xJ/v5wARm8KMrJaOfJnbt2zAcScB7AStXyA3fb
         WhYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=r+AYLnfKGfufrO8W6cq39b4l7nQ4liUYXfHMkw9/XLM=;
        b=z6gYqKZGs0O2Snh+1Fu6EX2c/kNwr3gAFD5pX0UUHJrfKOpOHoJk9NzotOWI06L2FU
         JeExil+9HjBep/8uEG5pMxPWJ5Zaudx4FmrO/tiHuXu1JsuTg1HUSd4pWQRIinyp2G9h
         hfuE3oAzGCkkXwuI8UpyA0x+LzU1EHi7F9kPgv1jHXfGP6tOYnq7lFjCnrt0xP5jh6Ck
         M89Pg4nudKQkH7a4Wcka2j2i0jYzUR+406DHelkf3aNz2F6aYOubabf4wtbCsFAzBNZU
         2Y//Q4La6UMKjX2msOZE6fVIdmk9M6Um/hI+8C5f9dn1rdSv62idshwAjcSSe3cZBqd0
         Lz7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k11si6500934ior.16.2019.08.06.05.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 05:48:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav108.sakura.ne.jp (fsav108.sakura.ne.jp [27.133.134.235])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x76CmKp6070017;
	Tue, 6 Aug 2019 21:48:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav108.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp);
 Tue, 06 Aug 2019 21:48:20 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav108.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x76CmFiB069797
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Tue, 6 Aug 2019 21:48:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: [PATCH v3] memcg, oom: don't require __GFP_FS when invoking memcg OOM
 killer
To: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: Masoud Sharbiani <msharbiani@apple.com>,
        Greg KH <gregkh@linuxfoundation.org>, hannes@cmpxchg.org,
        vdavydov.dev@gmail.com, linux-mm@kvack.org, cgroups@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <20190802191430.GO6461@dhcp22.suse.cz>
 <A06C5313-B021-4ADA-9897-CE260A9011CC@apple.com>
 <f7733773-35bc-a1f6-652f-bca01ea90078@I-love.SAKURA.ne.jp>
 <d7efccf4-7f07-10da-077d-a58dafbf627e@I-love.SAKURA.ne.jp>
 <20190805084228.GB7597@dhcp22.suse.cz>
 <7e3c0399-c091-59cd-dbe6-ff53c7c8adc9@i-love.sakura.ne.jp>
 <20190805114434.GK7597@dhcp22.suse.cz>
 <0b817204-29f4-adfb-9b78-4fec5fa8f680@i-love.sakura.ne.jp>
 <20190805142622.GR7597@dhcp22.suse.cz>
 <56d98a71-b77e-0ad7-91ad-62633929c736@i-love.sakura.ne.jp>
 <20190806105004.GS11812@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <cbe54ed1-b6ba-a056-8899-2dc42526371d@i-love.sakura.ne.jp>
Date: Tue, 6 Aug 2019 21:48:11 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806105004.GS11812@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Masoud Sharbiani noticed that commit 29ef680ae7c21110 ("memcg, oom: move
out_of_memory back to the charge path") broke memcg OOM called from
__xfs_filemap_fault() path. It turned out that try_charge() is retrying
forever without making forward progress because mem_cgroup_oom(GFP_NOFS)
cannot invoke the OOM killer due to commit 3da88fb3bacfaa33 ("mm, oom:
move GFP_NOFS check to out_of_memory").

Allowing forced charge due to being unable to invoke memcg OOM killer
will lead to global OOM situation. Also, just returning -ENOMEM will be
risky because OOM path is lost and some paths (e.g. get_user_pages())
will leak -ENOMEM. Therefore, invoking memcg OOM killer (despite GFP_NOFS)
will be the only choice we can choose for now.

Until 29ef680ae7c21110~1, we were able to invoke memcg OOM killer when
GFP_KERNEL reclaim failed [1]. But since 29ef680ae7c21110, we need to
invoke memcg OOM killer when GFP_NOFS reclaim failed [2]. Although in
the past we did invoke memcg OOM killer for GFP_NOFS [3], we might get
pre-mature memcg OOM reports due to this patch.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-and-tested-by: Masoud Sharbiani <msharbiani@apple.com>
Bisected-by: Masoud Sharbiani <msharbiani@apple.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Fixes: 3da88fb3bacfaa33 # necessary after 29ef680ae7c21110
Cc: <stable@vger.kernel.org> # 4.19+


[1]

 leaker invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
 CPU: 0 PID: 2746 Comm: leaker Not tainted 4.18.0+ #19
 Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
 Call Trace:
  dump_stack+0x63/0x88
  dump_header+0x67/0x27a
  ? mem_cgroup_scan_tasks+0x91/0xf0
  oom_kill_process+0x210/0x410
  out_of_memory+0x10a/0x2c0
  mem_cgroup_out_of_memory+0x46/0x80
  mem_cgroup_oom_synchronize+0x2e4/0x310
  ? high_work_func+0x20/0x20
  pagefault_out_of_memory+0x31/0x76
  mm_fault_error+0x55/0x115
  ? handle_mm_fault+0xfd/0x220
  __do_page_fault+0x433/0x4e0
  do_page_fault+0x22/0x30
  ? page_fault+0x8/0x30
  page_fault+0x1e/0x30
 RIP: 0033:0x4009f0
 Code: 03 00 00 00 e8 71 fd ff ff 48 83 f8 ff 49 89 c6 74 74 48 89 c6 bf c0 0c 40 00 31 c0 e8 69 fd ff ff 45 85 ff 7e 21 31 c9 66 90 <41> 0f be 14 0e 01 d3 f7 c1 ff 0f 00 00 75 05 41 c6 04 0e 2a 48 83
 RSP: 002b:00007ffe29ae96f0 EFLAGS: 00010206
 RAX: 000000000000001b RBX: 0000000000000000 RCX: 0000000001ce1000
 RDX: 0000000000000000 RSI: 000000007fffffe5 RDI: 0000000000000000
 RBP: 000000000000000c R08: 0000000000000000 R09: 00007f94be09220d
 R10: 0000000000000002 R11: 0000000000000246 R12: 00000000000186a0
 R13: 0000000000000003 R14: 00007f949d845000 R15: 0000000002800000
 Task in /leaker killed as a result of limit of /leaker
 memory: usage 524288kB, limit 524288kB, failcnt 158965
 memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
 kmem: usage 2016kB, limit 9007199254740988kB, failcnt 0
 Memory cgroup stats for /leaker: cache:844KB rss:521136KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:132KB writeback:0KB inactive_anon:0KB active_anon:521224KB inactive_file:1012KB active_file:8KB unevictable:0KB
 Memory cgroup out of memory: Kill process 2746 (leaker) score 998 or sacrifice child
 Killed process 2746 (leaker) total-vm:536704kB, anon-rss:521176kB, file-rss:1208kB, shmem-rss:0kB
 oom_reaper: reaped process 2746 (leaker), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB


[2]

 leaker invoked oom-killer: gfp_mask=0x600040(GFP_NOFS), nodemask=(null), order=0, oom_score_adj=0
 CPU: 1 PID: 2746 Comm: leaker Not tainted 4.18.0+ #20
 Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
 Call Trace:
  dump_stack+0x63/0x88
  dump_header+0x67/0x27a
  ? mem_cgroup_scan_tasks+0x91/0xf0
  oom_kill_process+0x210/0x410
  out_of_memory+0x109/0x2d0
  mem_cgroup_out_of_memory+0x46/0x80
  try_charge+0x58d/0x650
  ? __radix_tree_replace+0x81/0x100
  mem_cgroup_try_charge+0x7a/0x100
  __add_to_page_cache_locked+0x92/0x180
  add_to_page_cache_lru+0x4d/0xf0
  iomap_readpages_actor+0xde/0x1b0
  ? iomap_zero_range_actor+0x1d0/0x1d0
  iomap_apply+0xaf/0x130
  iomap_readpages+0x9f/0x150
  ? iomap_zero_range_actor+0x1d0/0x1d0
  xfs_vm_readpages+0x18/0x20 [xfs]
  read_pages+0x60/0x140
  __do_page_cache_readahead+0x193/0x1b0
  ondemand_readahead+0x16d/0x2c0
  page_cache_async_readahead+0x9a/0xd0
  filemap_fault+0x403/0x620
  ? alloc_set_pte+0x12c/0x540
  ? _cond_resched+0x14/0x30
  __xfs_filemap_fault+0x66/0x180 [xfs]
  xfs_filemap_fault+0x27/0x30 [xfs]
  __do_fault+0x19/0x40
  __handle_mm_fault+0x8e8/0xb60
  handle_mm_fault+0xfd/0x220
  __do_page_fault+0x238/0x4e0
  do_page_fault+0x22/0x30
  ? page_fault+0x8/0x30
  page_fault+0x1e/0x30
 RIP: 0033:0x4009f0
 Code: 03 00 00 00 e8 71 fd ff ff 48 83 f8 ff 49 89 c6 74 74 48 89 c6 bf c0 0c 40 00 31 c0 e8 69 fd ff ff 45 85 ff 7e 21 31 c9 66 90 <41> 0f be 14 0e 01 d3 f7 c1 ff 0f 00 00 75 05 41 c6 04 0e 2a 48 83
 RSP: 002b:00007ffda45c9290 EFLAGS: 00010206
 RAX: 000000000000001b RBX: 0000000000000000 RCX: 0000000001a1e000
 RDX: 0000000000000000 RSI: 000000007fffffe5 RDI: 0000000000000000
 RBP: 000000000000000c R08: 0000000000000000 R09: 00007f6d061ff20d
 R10: 0000000000000002 R11: 0000000000000246 R12: 00000000000186a0
 R13: 0000000000000003 R14: 00007f6ce59b2000 R15: 0000000002800000
 Task in /leaker killed as a result of limit of /leaker
 memory: usage 524288kB, limit 524288kB, failcnt 7221
 memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
 kmem: usage 1944kB, limit 9007199254740988kB, failcnt 0
 Memory cgroup stats for /leaker: cache:3632KB rss:518232KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB inactive_anon:0KB active_anon:518408KB inactive_file:3908KB active_file:12KB unevictable:0KB
 Memory cgroup out of memory: Kill process 2746 (leaker) score 992 or sacrifice child
 Killed process 2746 (leaker) total-vm:536704kB, anon-rss:518264kB, file-rss:1188kB, shmem-rss:0kB
 oom_reaper: reaped process 2746 (leaker), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB


[3]

 leaker invoked oom-killer: gfp_mask=0x50, order=0, oom_score_adj=0
 leaker cpuset=/ mems_allowed=0
 CPU: 1 PID: 3206 Comm: leaker Not tainted 3.10.0-957.27.2.el7.x86_64 #1
 Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 04/13/2018
 Call Trace:
  [<ffffffffaf364147>] dump_stack+0x19/0x1b
  [<ffffffffaf35eb6a>] dump_header+0x90/0x229
  [<ffffffffaedbb456>] ? find_lock_task_mm+0x56/0xc0
  [<ffffffffaee32a38>] ? try_get_mem_cgroup_from_mm+0x28/0x60
  [<ffffffffaedbb904>] oom_kill_process+0x254/0x3d0
  [<ffffffffaee36c36>] mem_cgroup_oom_synchronize+0x546/0x570
  [<ffffffffaee360b0>] ? mem_cgroup_charge_common+0xc0/0xc0
  [<ffffffffaedbc194>] pagefault_out_of_memory+0x14/0x90
  [<ffffffffaf35d072>] mm_fault_error+0x6a/0x157
  [<ffffffffaf3717c8>] __do_page_fault+0x3c8/0x4f0
  [<ffffffffaf371925>] do_page_fault+0x35/0x90
  [<ffffffffaf36d768>] page_fault+0x28/0x30
 Task in /leaker killed as a result of limit of /leaker
 memory: usage 524288kB, limit 524288kB, failcnt 20628
 memory+swap: usage 524288kB, limit 9007199254740988kB, failcnt 0
 kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
 Memory cgroup stats for /leaker: cache:840KB rss:523448KB rss_huge:0KB mapped_file:0KB swap:0KB inactive_anon:0KB active_anon:523448KB inactive_file:464KB active_file:376KB unevictable:0KB
 Memory cgroup out of memory: Kill process 3206 (leaker) score 970 or sacrifice child
 Killed process 3206 (leaker) total-vm:536692kB, anon-rss:523304kB, file-rss:412kB, shmem-rss:0kB

---
 mm/oom_kill.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..26804ab 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1068,9 +1068,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * The OOM killer does not compensate for IO-less reclaim.
 	 * pagefault_out_of_memory lost its gfp context so we have to
 	 * make sure exclude 0 mask - all other users should have at least
-	 * ___GFP_DIRECT_RECLAIM to get here.
+	 * ___GFP_DIRECT_RECLAIM to get here. But mem_cgroup_oom() has to
+	 * invoke the OOM killer even if it is a GFP_NOFS allocation.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS) && !is_memcg_oom(oc))
 		return true;
 
 	/*
-- 
1.8.3.1

