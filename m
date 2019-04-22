Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47F4DC282E3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:12:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 033C02087B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 033C02087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F83F6B0007; Sun, 21 Apr 2019 22:12:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 980736B0008; Sun, 21 Apr 2019 22:12:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 849D26B000A; Sun, 21 Apr 2019 22:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476B56B0007
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 22:12:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id l74so6704919pfb.23
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 19:12:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=pY40CoSYGz8qeu59Gtp+cDe+haKFoPl7cbgES2o6vTk=;
        b=DTlNZxGR6hgp/uQUUMRGJN1Ch0KY3uVY8IqhyTi4TaTCrEkwlmZS7apuVPd+WoIID7
         lCSUYvWjycJ1+C5AmLRrdujqBu9f/zplep+wEWLObRYQU5YG9T67o0Mj5sx4tHfnbTTa
         ppGQXSUjf0AyHx/m/Uc5idrhVykuyTifNKlCi6eUvuyRC2vO6umeF7THWmWv1JaWfgAe
         dglPMrQsTlbMHUJYCQ8Lt0EHj4dvXPVdM4H/lh/aXdR1kmnlSwLZ1RLDMFCi5GeaWp3g
         Ue0mW7ArYPJF6BXjtQg+CoZWGlIHZkR9kctcc6pPiz70LMzCaOaec5K5OLs6ULQkqbqx
         ZY5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUUhbCqyxh1M9IIoDml1CFB8DBL+qp6s+7iO2wNjplItbVtaCt8
	N5z9WskVOqW3lgCr3xkYkpTOhWYQc5TFmLbqNAn2S9x6FYgIx853kCrLgyU/ZzKnm8POfg/7cjH
	5J2P0U5SWRM14xiM+UuAm5d6gZ19d3pfgu0OR2GVdEI43A5bWiB3311z6Vuf8sTKNLg==
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr18068804pld.25.1555899144955;
        Sun, 21 Apr 2019 19:12:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0NgfwGu844kUb3FjEkbaNPg57RaG47ionom/L6IsSb//AiAMS4B84RjNyzF3eYG4xiNTi
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr18068743pld.25.1555899143851;
        Sun, 21 Apr 2019 19:12:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555899143; cv=none;
        d=google.com; s=arc-20160816;
        b=TdpPb0CSEbHuFeIsnnWwdpNbq6GsCRbdu7PVc76SMoIh3EtlSzuqzPIwZKvwzJGcJw
         z4OudmYPb9e9uv7qmsj9toaP5xRJXGi8sShC7HbMlYyushfZctAfptDQWQeKrMvSUzpB
         aBJp82Lva/bPw09ADgPTr6pZEgbqkdUtPwTcLhmFpz4IPBEz4dYcGcKwKK2qxiN1vvSk
         71R7YAi5yopLPgnoWJFKEVt8hkXlxa+P5Re9GyTBQkmA76cb8W8gEA1e6vf1FcDPeFAg
         TE/nOfb3J6Bbk31O49ILvZPgQjovYj9DGjVs9w3NRCecUQhyPiyPqA0pHjpMxxjTfEfH
         L9aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=pY40CoSYGz8qeu59Gtp+cDe+haKFoPl7cbgES2o6vTk=;
        b=MrdmQpMRgFHHU62NJQ/UjF2Opgfigao1Bmicatl/Nhpi3Ynt1MV3QTmPT9HdTPctK3
         oSYXEodNoiD24jtiU5EGcBhPLTbcRNwKf0AjJUD0zx7gYs4EwWRvAulPJenhuNh604GK
         NXF3SOv21g3CLfbw61PV4YecMHhEFyK9IuW+7QkXwwNySQJhNx0s6ZfxcAcRKuS6EA74
         TL9AqALRuZTcb7Ayaj8t9FlXWed17ywgK5GVwRvZPaqyvsBGAyu/T70n0a7whUWcvuZz
         y3wcQZpKOJ8KgFY5WQqAbNAB5KUAj8M2Vz5E+cq7xQDp8C4+Has/pIi17ALbDX9druZm
         51Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id t9si11743680plo.98.2019.04.21.19.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 19:12:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPtsv3i_1555899140;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TPtsv3i_1555899140)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Apr 2019 10:12:21 +0800
Subject: [RFC PATCH 2/5] numa: append per-node execution info in
 memory.numa_stat
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Message-ID: <7be82809-79d3-f6a1-dfe8-dd14d2b35219@linux.alibaba.com>
Date: Mon, 22 Apr 2019 10:12:20 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
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

  exectime 24399843 27865444

which means the tasks of this cgroup executed 24399843 ticks on node 0,
and 27865444 ticks on node 1.

Combined with the memory node info, we can estimate the numa efficiency,
for example the memory.numa_stat show:

  total=4613257 N0=6849 N1=3928327
  ...
  exectime 24399843 27865444

there could be unmovable or cache pages on N1, then good locality could
mean nothing since we are not tracing these type of pages, thus bind the
workloads on the cpus of N1 worth a try, in order to achieve the maximum
performance bonus.

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/memcontrol.h |  1 +
 mm/memcontrol.c            | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bb62e6294484..e784d6252d5e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -197,6 +197,7 @@ enum memcg_numa_locality_interval {

 struct memcg_stat_numa {
 	u64 locality[NR_NL_INTERVAL];
+	u64 exectime;
 };

 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b810d4e9c906..91bcd71fc38a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3409,6 +3409,18 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, " %llu", sum);
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
+		seq_printf(m, " %llu", sum);
+	}
+	seq_putc(m, '\n');
 #endif

 	return 0;
@@ -3437,6 +3449,7 @@ void memcg_stat_numa_update(struct task_struct *p)
 	memcg = mem_cgroup_from_task(p);
 	if (idx != -1)
 		this_cpu_inc(memcg->stat_numa->locality[idx]);
+	this_cpu_inc(memcg->stat_numa->exectime);
 	rcu_read_unlock();
 }
 #endif
-- 
2.14.4.44.g2045bb6

