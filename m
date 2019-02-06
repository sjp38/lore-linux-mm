Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCA11C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 06:31:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6987720818
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 06:31:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6987720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3B118E00AC; Wed,  6 Feb 2019 01:31:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC0F48E00AB; Wed,  6 Feb 2019 01:31:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A61EB8E00AC; Wed,  6 Feb 2019 01:31:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1AB8E00AB
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 01:31:34 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p20so4182322plr.22
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 22:31:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:references:in-reply-to
         :content-transfer-encoding;
        bh=JsnAGGnust96FsoWIyv2VHQNcRrrDuvA/6CAzyg8HbM=;
        b=kIW2cDO12tQXFirwipHYB2ZKXlxCAbGp1Yfjld5vMXmJ4Uab03n2pGZ5GlNTKVo8/5
         EHIZ4+4LTttAQVDzd1SNx1NzLNMvTlCSb3rZVLSiSOFzg0t4CNKl3RDBLBqUOZYXnHRI
         BlP16HJKstaYjBms6/rCrwS9tskcGc1S4R2jJerBr96MKP3g2xeBC1dNphDwYYLRMoYL
         +1zbM1Dce97OxS7GGPiwtNuchZMX1GeybJG4n+J0GsOJZTcrRlEzOnUpq6wE3DvRgTJJ
         YQ3kiicilurghp8tSO1jK704+bhEzMHAzjYrCA9aIoaMwaxVsxeNor8Gq0WfE0nSixE7
         AUVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZO9W5dmNchjA7mca2uAozU7XRUM0huW9dn8q7d1kgxyvgZJnbq
	8wvs91CjqdmhaR/KAAxBb2kZs0dxpt0ua7mToeVUzf50iSSwr+bBkDrmbX1Epu2784juO6/XN3G
	3GMxJq8LhEmcg+SqKa2zY0Apr4GZ1i6y90rSEQvAhJ1rGsS0dmVUT71rUVbeCsYJU3Q==
X-Received: by 2002:a63:cc12:: with SMTP id x18mr8157133pgf.33.1549434693896;
        Tue, 05 Feb 2019 22:31:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQA8qlpG/MM2TpbFf7ufTqYb9przz3wLVRI4mdkD78JBLtMn1qyqkkEvAXRACbcrHBjIx8
X-Received: by 2002:a63:cc12:: with SMTP id x18mr8157066pgf.33.1549434692915;
        Tue, 05 Feb 2019 22:31:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549434692; cv=none;
        d=google.com; s=arc-20160816;
        b=Dk6FIxop8r4eLIqhvioRJC71tx98hCY9zIdT/mgqvr92ubPpCYmY/zyqkIrwo4ID6V
         WLwUCY05NZeSBGOEf37oLZukazs4aEd/60qnUdqUdlIcTL8FmGTYTMctZjnnJLZmQimC
         pHH7e/RRKfJ2bnmBK9OBxjMPW4W9ujvOby1os2nsLP2Dhcsrq9QpOw7RjRrM0jTJStSF
         AMRaeMISOHjjFTVbeeFeP9BCiTUwm1KFkDYJRJI/xP2syhWldDq+sGkVuNthveOYBmmo
         FsmwRXE9IhzCLNHjtbrcsHUatmL1OEju3GPxUy+HBj2YZCTXZXCzQT1TnW/qSORiu18t
         JAfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:date:mime-version
         :cc:to:from:subject:message-id;
        bh=JsnAGGnust96FsoWIyv2VHQNcRrrDuvA/6CAzyg8HbM=;
        b=T8D8eu7r1E4YAz129yAxT87Ty8KIFZsGxbv9UKmZDhMLWxs+LDNaz/ZI+IFgMBB5Go
         z8pt1mqQ5FTc8mcMkDEw/zgk6TmXrrXnB8azw1XDox9IHB27Hg19fTnbempZfiQeJ5AU
         jBPhD7ZFpIJFKY0gB+cH9gwGlHLuYxk72IqZagYKZd5V/rUzDVxHTx87LLOId2BzR1Np
         gcxXESGKcNfqKKXtSZ4L0jN6IjfpopslyuLIu8x4QCF54HbXgez7Ly6OOdjhQfWrJ88e
         fb8CYmFTwCGfhHTNEivyUYTr8DFzPGq2tvFN2gDsiMJt5KIVUHlLzZEbrzaNF5IGJatc
         WOvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n1si5150670pgh.172.2019.02.05.22.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 22:31:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav105.sakura.ne.jp (fsav105.sakura.ne.jp [27.133.134.232])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x166V9CZ014756;
	Wed, 6 Feb 2019 15:31:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav105.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp);
 Wed, 06 Feb 2019 15:31:09 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav105.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x166V9cf014751;
	Wed, 6 Feb 2019 15:31:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x166V9J8014750;
	Wed, 6 Feb 2019 15:31:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201902060631.x166V9J8014750@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: Re: linux-next: tracebacks in =?ISO-2022-JP?B?d29ya3F1ZXVlLmMvX19mbHVz?=
 =?ISO-2022-JP?B?aF93b3JrKCk=?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Guenter Roeck <linux@roeck-us.net>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>
MIME-Version: 1.0
Date: Wed, 06 Feb 2019 15:31:09 +0900
References: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp> <87munc306z.fsf@rustcorp.com.au>
In-Reply-To: <87munc306z.fsf@rustcorp.com.au>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Adding linux-arch ML.)

Rusty Russell wrote:
> Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
> > (Adding Chris Metcalf and Rusty Russell.)
> >
> > If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
> > evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
> > previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
> > commits listed below.
> >
> >   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
> >   expects that has_work is evaluated by for_each_cpu().
> >
> >   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
> >   assumes that for_each_cpu() does not need to evaluate has_work.
> >
> >   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
> >   expects that has_work is evaluated by for_each_cpu().
> >
> > What should we do? Do we explicitly evaluate has_work if NR_CPUS == 1 ?
> 
> No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.
> 
> Doing anything else would be horrible, IMHO.
> 

Fixing 2d3854a37e8b767a might involve subtle changes. If we do

----------
diff --git a/include/linux/cpumask.h b/include/linux/cpumask.h
index 147bdec..1ec5321 100644
--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
@@ -129,7 +129,7 @@ static inline unsigned int cpumask_check(unsigned int cpu)
 	return cpu;
 }
 
-#if NR_CPUS == 1
+#if NR_CPUS == 1 && 0
 /* Uniprocessor.  Assume all masks are "1". */
 static inline unsigned int cpumask_first(const struct cpumask *srcp)
 {
diff --git a/lib/Makefile b/lib/Makefile
index e1b59da..da6f99c 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -28,7 +28,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 
 lib-$(CONFIG_PRINTK) += dump_stack.o
 lib-$(CONFIG_MMU) += ioremap.o
-lib-$(CONFIG_SMP) += cpumask.o
+lib-y += cpumask.o
 
 lib-y	+= kobject.o klist.o
 obj-y	+= lockref.o
----------

then we get e.g. a build failure like below.

----------
arch/x86/kernel/cpu/cacheinfo.o: In function `_populate_cache_leaves':
cacheinfo.c:(.text+0xb20): undefined reference to `cpu_llc_shared_map'
cacheinfo.c:(.text+0xb48): undefined reference to `cpu_llc_shared_map'
cacheinfo.c:(.text+0xb64): undefined reference to `cpu_llc_shared_map'
make: *** [vmlinux] Error 1
----------

This build failure is caused due to the

  DEFINE_PER_CPU_READ_MOSTLY(cpumask_var_t, cpu_llc_shared_map);

line which cpu_llc_shared_mask() depends on is in arch/x86/kernel/smpboot.c
and the

  obj-$(CONFIG_SMP)               += smpboot.o

line is in arch/x86/kernel/Makefile . We could try

----------
diff --git a/arch/x86/kernel/cpu/cacheinfo.c b/arch/x86/kernel/cpu/cacheinfo.c
index c4d1023..bf95da3 100644
--- a/arch/x86/kernel/cpu/cacheinfo.c
+++ b/arch/x86/kernel/cpu/cacheinfo.c
@@ -23,6 +23,10 @@
 
 #include "cpu.h"
 
+#ifndef CONFIG_SMP
+DEFINE_PER_CPU_READ_MOSTLY(cpumask_var_t, cpu_llc_shared_map);
+#endif
+
 #define LVL_1_INST	1
 #define LVL_1_DATA	2
 #define LVL_2		3
----------

or

----------
diff --git a/arch/x86/kernel/cpu/cacheinfo.c b/arch/x86/kernel/cpu/cacheinfo.c
index c4d1023..b8a22b6 100644
--- a/arch/x86/kernel/cpu/cacheinfo.c
+++ b/arch/x86/kernel/cpu/cacheinfo.c
@@ -886,6 +886,7 @@ static int __cache_amd_cpumap_setup(unsigned int cpu, int index,
 	 * to derive shared_cpu_map.
 	 */
 	if (index == 3) {
+#ifdef CONFIG_SMP
 		for_each_cpu(i, cpu_llc_shared_mask(cpu)) {
 			this_cpu_ci = get_cpu_cacheinfo(i);
 			if (!this_cpu_ci->info_list)
@@ -898,6 +899,7 @@ static int __cache_amd_cpumap_setup(unsigned int cpu, int index,
 						&this_leaf->shared_cpu_map);
 			}
 		}
+#endif
 	} else if (boot_cpu_has(X86_FEATURE_TOPOEXT)) {
 		unsigned int apicid, nshared, first, last;
 
----------

but I don't know whether this is a correct fix, for for_each_cpu() currently
always executes the loop because for_each_cpu() does not evaluate
cpu_llc_shared_mask(cpu) argument. But if cpu_llc_shared_mask(cpu) argument
is evaluated by for_each_cpu(), and given that nobody updates cpu_llc_shared_map
if CONFIG_SMP=n, I guess that this for_each_cpu() becomes a no-op loop. I can't
evaluate whether this change is safe, and there might be similar code in other
architectures.

