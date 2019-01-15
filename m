Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0709C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 10:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8713B20651
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 10:06:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8713B20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E438E0004; Tue, 15 Jan 2019 05:06:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0FDE8E0002; Tue, 15 Jan 2019 05:06:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFE7C8E0004; Tue, 15 Jan 2019 05:06:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7894B8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 05:06:49 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so935849edi.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:06:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=3soo2zXXEsAUGQTSn/XKo/T95oMR2WN7I70JsnvNftA=;
        b=Xw75yd69JvCdD+G6xQVVHXrZ4jYU0Omn2W7Brfc5+/O90qCkkpfqxa5mYAV9t68slx
         NdWIDu378GZGF+QV9fs3Y8rc1/CIgoVFLv3ayWubEq8MlcV2yOddnFt2ZQmGX/irFC2q
         gRs8pmr/Ys8JEA7CqzFJBXWRINiOfcpAidof3hnWaJPzdm8mYmuJzbZ36ay3A+aC0Ych
         luwIMl8vMDs05V+eRRZiC/OIAjHkKXu4H/Fc9cnfoRdkJMSOpTfSOfA5SHfqy4f6hVdy
         rm3WfBga+qiPN73U2FP3cNanaYWVE/h2+uppasD1YX7zKPKbZE7UFGdsfbiT2jwdqe7M
         ZP6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUuke4PcCegGB87gOA7eoBXPN5JtU/z00FJ/KUj5e6L/itVTs3Yewh
	wCGNyDB3xOeEpqgqE2i2g4cJbkxGOTf9f9yBNaVF7Y5y74wqmJZ7sfTB48mU0wwzf7Z8r8a82sT
	PkWCdn6cbU9FehY8P51ExGofssX5PL9E3J+KXTdeEuxppQtprCJUVbp691foSuMJaog==
X-Received: by 2002:aa7:d29a:: with SMTP id w26mr2867426edq.30.1547546809029;
        Tue, 15 Jan 2019 02:06:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN775te5QocilJi8BY9Xg9Ss7+V6/HCd2G3gm5l6yP82PSlv1TmxpcBcc2Uyfyu3sePzXE6B
X-Received: by 2002:aa7:d29a:: with SMTP id w26mr2867360edq.30.1547546807813;
        Tue, 15 Jan 2019 02:06:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547546807; cv=none;
        d=google.com; s=arc-20160816;
        b=EFPRQZH4ZEnTBVXcK3Tc1XJxyCWplmjhLA6EsV9UDBZTirZaQ7TMz62vA0cKBFAZlM
         0J1s8oeLLwrPgKPab74JzhyM8tk1oY+B9DFxATKWSBlddgmEncu5Rw+3Lsy+TvQsiu9Z
         OckF02v5K0dloQYVDAZCZUsEbRNb7mcMSP12fRXKRDiRcm0runLYJl2+fXftXFcJ5E7e
         OZ3qmtCwrsyOn8E8gkpkIFqLXnWZuTSJJ0vmbzGY3VsyL8YLprmsRAB7166CN5h78znh
         6lr7pWew66iFlc2fotfvsU+yBXXNtLmxY32JJm8PVkkOs0p89KV9kP9adlZJiSoKdRuu
         3lKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=3soo2zXXEsAUGQTSn/XKo/T95oMR2WN7I70JsnvNftA=;
        b=Tq6g9iG7pz5Q6mGUuiPA0CB6awAKQBqSZn8qrXYZ7qeKr6RGvVprUHOSbXqy2NOE2A
         XaduXqQ7jEN2FEAKSEA1hiCXjfmASGA37TjrdJRj1MEh7+XCYRC/UxHx28XQ7zFwYA4s
         6cnvxOsZfGEzAotbWtr1U3ALhzRWM81piSlO30btgSAIRhJDvQdyKUu2GBTsMxuewKKb
         adYurvwsxtMjc/15dMqs2OgDkYvKLTM0somMzjHsoBzwpRCKH8qtcdZEqIjYRNg5W0tL
         U/jZbBAxWCCRIica0FDQ0byIuLjUDLKzz8jvUhwQ2Dykyhdw8M9HZFDBds8awf/IfsTl
         JFGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si503457ejc.189.2019.01.15.02.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 02:06:47 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 05C79ADF5;
	Tue, 15 Jan 2019 10:06:46 +0000 (UTC)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>,
 syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Alexander Potapenko <glider@google.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>,
 David Rientjes <rientjes@google.com>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com,
 zhong jiang <zhongjiang@huawei.com>
References: <000000000000c06550057e4cac7c@google.com>
 <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
 <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
 <20190104172802.ce9c4b77577a9c2810f04171@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <73da3e9c-cc84-509e-17d9-0c434bb9967d@suse.cz>
Date: Tue, 15 Jan 2019 11:06:44 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190104172802.ce9c4b77577a9c2810f04171@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115100644.EESIAcWDYK2hAmShJa5QkmSY1ESoGeABw3TfuK0qib4@z>

On 1/5/19 2:28 AM, Andrew Morton wrote:
> On Fri, 4 Jan 2019 09:50:31 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
>>> Yes, it doesn't and it's not trivial to do. The tool reports uses of
>>> unint _values_. Values don't necessary reside in memory. It can be a
>>> register, that come from another register that was calculated as a sum
>>> of two other values, which may come from a function argument, etc.
>>
>> I see. BTW, the patch I sent will be picked up for testing, or does it
>> have to be in mmotm/linux-next first?
> 
> I grabbed it.  To go further we'd need a changelog, a signoff,
> description of testing status, reviews, a Fixes: and perhaps a
> cc:stable ;)

Here's the full patch. Since there was no reproducer, there probably
won't be any conclusive testing, but we might interpret lack of further
KSMSAN reports as a success :)

----8<----

From 81ad0c822cb022cacea9b69565e12aac96dfb3fc Mon Sep 17 00:00:00 2001
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 3 Jan 2019 09:31:59 +0100
Subject: [PATCH] mm, mempolicy: fix uninit memory access

Syzbot with KMSAN reports (excerpt):

==================================================================
BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
CPU: 1 PID: 17420 Comm: syz-executor4 Not tainted 4.20.0-rc7+ #15
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x173/0x1d0 lib/dump_stack.c:113
  kmsan_report+0x12e/0x2a0 mm/kmsan/kmsan.c:613
  __msan_warning+0x82/0xf0 mm/kmsan/kmsan_instr.c:295
  mpol_rebind_policy mm/mempolicy.c:353 [inline]
  mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
  update_tasks_nodemask+0x608/0xca0 kernel/cgroup/cpuset.c:1120
  update_nodemasks_hier kernel/cgroup/cpuset.c:1185 [inline]
  update_nodemask kernel/cgroup/cpuset.c:1253 [inline]
  cpuset_write_resmask+0x2a98/0x34b0 kernel/cgroup/cpuset.c:1728

...

Uninit was created at:
  kmsan_save_stack_with_flags mm/kmsan/kmsan.c:204 [inline]
  kmsan_internal_poison_shadow+0x92/0x150 mm/kmsan/kmsan.c:158
  kmsan_kmalloc+0xa6/0x130 mm/kmsan/kmsan_hooks.c:176
  kmem_cache_alloc+0x572/0xb90 mm/slub.c:2777
  mpol_new mm/mempolicy.c:276 [inline]
  do_mbind mm/mempolicy.c:1180 [inline]
  kernel_mbind+0x8a7/0x31a0 mm/mempolicy.c:1347
  __do_sys_mbind mm/mempolicy.c:1354 [inline]

As it's difficult to report where exactly the uninit value resides in the
mempolicy object, we have to guess a bit. mm/mempolicy.c:353 contains this
part of mpol_rebind_policy():

        if (!mpol_store_user_nodemask(pol) &&
            nodes_equal(pol->w.cpuset_mems_allowed, *newmask))

"mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't ever
see being uninitialized after leaving mpol_new(). So I'll guess it's actually
about accessing pol->w.cpuset_mems_allowed on line 354, but still part of
statement starting on line 353.

For w.cpuset_mems_allowed to be not initialized, and the nodes_equal()
reachable for a mempolicy where mpol_set_nodemask() is called in do_mbind(), it
seems the only possibility is a MPOL_PREFERRED policy with empty set of nodes,
i.e. MPOL_LOCAL equivalent, with MPOL_F_LOCAL flag. Let's exclude such policies
from the nodes_equal() check. Note the uninit access should be benign anyway,
as rebinding this kind of policy is always a no-op. Therefore no actual need for
stable inclusion.

Link: http://lkml.kernel.org/r/a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz
Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>
Cc: zhong jiang <zhongjiang@huawei.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d4496d9d34f5..a0b7487b9112 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) &&
+	if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
2.20.1

