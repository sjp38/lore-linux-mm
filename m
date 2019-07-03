Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6CE8C06510
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:29:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AE0821721
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 03:29:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AE0821721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C4FA8E0003; Tue,  2 Jul 2019 23:29:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 274C18E0001; Tue,  2 Jul 2019 23:29:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D418E0003; Tue,  2 Jul 2019 23:29:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2AA28E0001
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 23:29:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s5so724414pgr.4
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 20:29:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=LkTAJVk/Jxzg+/wDCqXpwXHmb37Vnl6quR1WAtWAYUY=;
        b=ugZt3PuNlczLVxPVT9QN9HdNWxD8Y5lsf9+jTfgDOk3MGTRAnvhD/wimxePgM4nBbU
         aLEm+fg9elPQrQl9yV3WU4Ut/NEgBj35e88YCr54qI71GY0KEwko+kViB+5YH5psFsBs
         Al5Y/5uok91Sc4KPS0LbGNZ1I0F/AbLbf/qN+CsOZA/nRmval/+dgIqd6HXyvf6+039M
         lKjZir5xrDhT/BXQGVAvrmE1l9wrg+xuJ8me5zGP5rbNf1OvqNxF3I2uVqPHLuJdrtkE
         2J8jXf7a5lSJgHfVEmEpNUbj4hscZMX7ODkOz+C88Fcs15KRP1dkKFZsEukdbRHvlLWM
         cmmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVShOSKzy1WfU74xRPlBif3SqNuPY4Oi8jUzjzymU/lTfGitIa+
	yyNXykY6CDWaiYmvjRtXC8feVkFkvDuvgBrf8KKAmGZIBEzOghC/5t0Pak0i+RFz3/ywAc34EAl
	ym2rsLAQoKGxRPoOdlR7arTZJJrRpqgBMbgQDr5YxkZRVlBcRZpCV/59pEsthSupIrg==
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr9707779pjn.134.1562124559546;
        Tue, 02 Jul 2019 20:29:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmiJ3khZq5+KNEP0506PwaHDApvzaxCGXLZ8GkeoLZVt8/g32MmgAAnUT7hzIoXOH9bY+9
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr9707690pjn.134.1562124558758;
        Tue, 02 Jul 2019 20:29:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562124558; cv=none;
        d=google.com; s=arc-20160816;
        b=vduvm1+Tl3PM6NLPOHcRHD0p66h2CpPkqFkpWk8157BCvlCT1N5JTn7j5X4j84Wm9R
         0L4/tRcXBhsW5ir64yzl+fVMNApthKPRRyTJp593wXnNsTNsH1jPhWEK9we97JECWsak
         edwNn44M79UYnil3aMNxzWBQvsn7roCMaT55DgwtPyappRuvU3Ms257AGDKKhyT5TYEg
         p7+5GVe17BXmUqFRgqJBXk0fro+Or3PjpoKxRSLNojmuO21fGkQCiCrt9Wg2fyRxrSWi
         AUS3zWUE7KUlEDQ2tdOmxgotSmb6RY6t9M7mpZCQjKldI797bgJnvJ+d+NCYK4QSfCmq
         MlQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=LkTAJVk/Jxzg+/wDCqXpwXHmb37Vnl6quR1WAtWAYUY=;
        b=I2uWif5XWFDGKcP/wWTwRtugISCNK0uTdHV5WQA5CrqfXyLwdHT2J7EEe1OuQNUwg2
         0l979s47FBs+kOdSXDcbZCWk/SsZdpHr7CaeQzcWJuWmXZGMIIyjQkgLjv5dbZHip+UG
         d1vo7Wu1UBnFUnQAzPSBCQKtrB4EHMNw3dPMIdK1xYP+np9WtRZOL8mN4SxKEy6dhqgS
         AS3eIFdpF9IVVp/chVTTh0ACDS7HeydfQK8Vu7Y0QU8+iJvHcqEobRlNKD4V5TqLSnIk
         jerZpRC4IdK43LJK5go1r62aDQKsiCELRftZfslX9gOMsnzamNzhbnvoUMLlw6CLCYpC
         WDAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id r19si875034pfh.50.2019.07.02.20.29.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 20:29:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVvOVSB_1562124555;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TVvOVSB_1562124555)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 03 Jul 2019 11:29:16 +0800
Subject: [PATCH 2/4] numa: append per-node execution info in memory.numa_stat
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@kernel.org,
 keescook@chromium.org, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Message-ID: <825ebaf0-9f71-bbe1-f054-7fa585d61af1@linux.alibaba.com>
Date: Wed, 3 Jul 2019 11:29:15 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduced numa execution information, to imply the numa
efficiency.

By doing 'cat /sys/fs/cgroup/memory/CGROUP_PATH/memory.numa_stat', we
see new output line heading with 'exectime', like:

  exectime 311900 407166

which means the tasks of this cgroup executed 311900 micro seconds on
node 0, and 407166 ms on node 1.

Combined with the memory node info, we can estimate the numa efficiency,
for example if the node memory info is:

  total=206892 N0=21933 N1=185171

By monitoring the increments, if the topology keep in this way and
locality is not nice, then it imply numa balancing can't help migrate
the memory from node 1 to 0 which is accessing by tasks on node 0, or
tasks can't migrate to node 1 for some reason, then you may consider
to bind the cgroup on the cpus of node 1.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0a30d14c9f43..deeca9db17d8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -190,6 +190,7 @@ enum memcg_numa_locality_interval {

 struct memcg_stat_numa {
 	u64 locality[NR_NL_INTERVAL];
+	u64 exectime;
 };

 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2edf3f5ac4b9..d5f48365770f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3575,6 +3575,18 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, " %u", jiffies_to_msecs(sum));
 	}
 	seq_putc(m, '\n');
+
+	seq_puts(m, "exectime");
+	for_each_online_node(nr) {
+		int cpu;
+		u64 sum = 0;
+
+		for_each_cpu(cpu, cpumask_of_node(nr))
+			sum += per_cpu(memcg->stat_numa->exectime, cpu);
+
+		seq_printf(m, " %llu", jiffies_to_msecs(sum));
+	}
+	seq_putc(m, '\n');
 #endif

 	return 0;
@@ -3606,6 +3618,7 @@ void memcg_stat_numa_update(struct task_struct *p)
 	memcg = mem_cgroup_from_task(p);
 	if (idx != -1)
 		this_cpu_inc(memcg->stat_numa->locality[idx]);
+	this_cpu_inc(memcg->stat_numa->exectime);
 	rcu_read_unlock();
 }
 #endif
-- 
2.14.4.44.g2045bb6

