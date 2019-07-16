Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2129BC76188
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D09242171F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:40:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D09242171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CA656B0006; Mon, 15 Jul 2019 23:40:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653956B0008; Mon, 15 Jul 2019 23:40:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 543456B000A; Mon, 15 Jul 2019 23:40:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBE66B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:40:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so11514004pfw.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:40:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=sfGqnlwv/x1QcG6+i4QvvMRPlbSgoi7oOhYWSwfokLo=;
        b=MgzHfizcuBPcOSPHBcz5q5ksMzrWIzag5M9Xo5DW+5AjupAQE0RKexyHKDQg7DNKVv
         TInPohIg93HT6xg3Aiu+9SbUJ8L3el19zzGp6RObb+JnsjvYP/u2GMD8UHgZguNGyQSH
         ggfewzqZGKoyGgDjHHJd4DyyAgB1JipWuwro46Bkhk4ahlkO43y6Njyk3PBE54R0bI95
         +WMocnzlE/8ckFJVutnW9xz+zucbWTNx+ocwf/9+xRJLDqsz05LimjzYHB1uktDdBx5b
         kxSNn8ROExtGCUsrBaBu26p55cSIO01+S4Q/qxMh9cJ06j/dZ4bzXBvXATRGFuoTld7F
         tXJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW+IwR3hPDYkL8BA7PxP1zf6hMfyt4DNXEHRuPLQ0pHv5SoatZK
	9QlYacXxy6nSoL2EQPScGBBcP/ShKwakXEmMPoh8uVVNE6nk85zFkJ5YWCazxU72YSyQZIEwRd1
	RdSBqj7f1wnrcB3PWZbrSypfbsYhoJkiGCPXCe29DxlFwhj3CavOy3p4pLG+7bTqC0Q==
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr32751312ple.192.1563248441787;
        Mon, 15 Jul 2019 20:40:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMIWYRitHGPZ/4PA65LkdM4VVPmez3ZsJcsVFIN8bzR+Ub+lbNH9R/UcD/wYcjspCWFhVv
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr32751203ple.192.1563248440578;
        Mon, 15 Jul 2019 20:40:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563248440; cv=none;
        d=google.com; s=arc-20160816;
        b=QYbPaW58yH0+w6MtOP6pIbx7bgMp9b8WmKylexe4jDg8w3KbWSNBg1h2+qt+XRE/bq
         t5j0GTUm0QxR8cmaHq3RmkdH6/gC78KBS8pWiLHChs7AtP1pHh+8smpr5uFf6B4mNfT6
         PrYpY+us88ExjijvphPCnf8UFuwYTkWrg9p8Rp0FaNfUXNMz9PFKx+Lv5qXHnRi7KQQB
         Kp6U7vtcDwt4WtSWOIWKSVS0Y3Kfm0aVo7ecKHetY2TI4HwaS4sAMm8HWpl8ZO6fMQTh
         Uv+RmLeWnuuSWfPJ3Yz3CcHBD4qd23x4YfLq7o5NTkRezCVOdKc0fVlR0wFz3CNQFXjY
         KmgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=sfGqnlwv/x1QcG6+i4QvvMRPlbSgoi7oOhYWSwfokLo=;
        b=Z32v891zaDFDyPeMeCxQ0k3konpR7l/ul1mOnUCheNMdcvErv3/KFsMn8sehxT11Yz
         TRZd1IF092uaOMMuJF9wLHDNktB4Cw/Ln6XpNyKH9qOiUGYZ06XWrc91HNkiQ7LnePu4
         mPYkC7fyezzYUlY+fapmqyCk+xP4Zk9RTHNs7GFG8hYET7cb8m2F9yZ34uZnjicP6uoe
         3rtG1dVXiPZR5wf4h341Rh3XXGY4KDAPcbdccFzb7T8kNFl4EhQviGksubi5fD5Ad9lG
         JigexxXMcdv6EtOZVVIrjynlxNXtvz1Gy8L+7/42sElXZEdq3B59jpp1Z1Zpvww8MlZj
         lcMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id q42si18227829pjc.103.2019.07.15.20.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 20:40:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R531e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TX1TAFc_1563248435;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TX1TAFc_1563248435)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 11:40:36 +0800
Subject: [PATCH v2 2/4] numa: append per-node execution time in cpu.numa_stat
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
 Hillf Danton <hdanton@sina.com>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Message-ID: <6973a1bf-88f2-b54e-726d-8b7d95d80197@linux.alibaba.com>
Date: Tue, 16 Jul 2019 11:40:35 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <65c1987f-bcce-2165-8c30-cf8cf3454591@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduced numa execution time information, to imply the numa
efficiency.

By doing 'cat /sys/fs/cgroup/cpu/CGROUP_PATH/cpu.numa_stat', we see new
output line heading with 'exectime', like:

  exectime 311900 407166

which means the tasks of this cgroup executed 311900 micro seconds on
node 0, and 407166 ms on node 1.

Combined with the memory node info from memory cgroup, we can estimate
the numa efficiency, for example if the memory.numa_stat show:

  total=206892 N0=21933 N1=185171

By monitoring the increments, if the topology keep in this way and
locality is not nice, then it imply numa balancing can't help migrate
the memory from node 1 to 0 which is accessing by tasks on node 0, or
tasks can't migrate to node 1 for some reason, then you may consider
to bind the workloads on the cpus of node 1.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
Since v1:
  * move implementation from memory cgroup into cpu group
  * exectime now accounting in hierarchical way
  * change member name into jiffies

 kernel/sched/core.c  | 12 ++++++++++++
 kernel/sched/fair.c  |  2 ++
 kernel/sched/sched.h |  1 +
 3 files changed, 15 insertions(+)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 71a8d3ed8495..f8aa73aa879b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7307,6 +7307,18 @@ static int cpu_numa_stat_show(struct seq_file *sf, void *v)
 	}
 	seq_putc(sf, '\n');

+	seq_puts(sf, "exectime");
+	for_each_online_node(nr) {
+		int cpu;
+		u64 sum = 0;
+
+		for_each_cpu(cpu, cpumask_of_node(nr))
+			sum += per_cpu(tg->numa_stat->jiffies, cpu);
+
+		seq_printf(sf, " %u", jiffies_to_msecs(sum));
+	}
+	seq_putc(sf, '\n');
+
 	return 0;
 }
 #endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index cd716355d70e..2c362266af76 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2652,6 +2652,8 @@ static void update_tg_numa_stat(struct task_struct *p)
 		if (idx != -1)
 			this_cpu_inc(tg->numa_stat->locality[idx]);

+		this_cpu_inc(tg->numa_stat->jiffies);
+
 		tg = tg->parent;
 	}

diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
index 685a9e670880..456f83f7f595 100644
--- a/kernel/sched/sched.h
+++ b/kernel/sched/sched.h
@@ -360,6 +360,7 @@ struct cfs_bandwidth {

 struct numa_stat {
 	u64 locality[NR_NL_INTERVAL];
+	u64 jiffies;
 };

 #endif
-- 
2.14.4.44.g2045bb6

