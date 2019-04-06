Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70EC4C282DA
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 22:59:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F41B921019
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 22:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="YzlnuhjH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F41B921019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AFA86B026D; Sat,  6 Apr 2019 18:59:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 460396B026E; Sat,  6 Apr 2019 18:59:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 376ED6B026F; Sat,  6 Apr 2019 18:59:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 148F06B026D
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 18:59:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l26so8956197qtk.18
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 15:59:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=dB4pAQEYeJLbgCkf7uLDDCPVAJv3hzEyEmEQnyQak1Y=;
        b=grPWUXB3lYpY/+r7telWWgIaM7864zHgfCetPuBqCXdvtrT2SCtBrHStL6VZ3ZKO1Y
         DpUIxwO8TQZFFF4TxYEJyIiiYz3nnWCctTDkkmyS90xgkg5U8AHWUoZ6hhi5o2u0hYJ+
         YRo2dqeaycoQSxBTOSZ2TLBx3y3uT9K6RNUa4rIDbfuFyS+/BKhBu9T4ZaGCF42Y+kUt
         1wnAazFvJB4ZYyBQTVkIHEp/FPIpI+a/Lj4KoUg5mSob8g31VBZXnHX1TEkbC5i+FX+E
         sONehYUrAarey/YkmqAXhLLtaPoTZxJqEjuJDeQSSfhpmPpWQaY8FnGVSJatkF57jD8y
         I2nA==
X-Gm-Message-State: APjAAAUmgWSUipmGeAxJWVAX4EYXs7FDqRN9oQE4XXXtLoR7HvibOJkI
	8Xelgfr5u4SzfzIEY8grKlwKu/Q6bQleR9X0e5vEVjCylmm/sgsrs407CmrruZLfQ/nqso/v+TA
	I/hIhUYlnUy42npi0y4jZIwgzybq44hksOtvAR/ApXKE1rYqjMZGzB7xta1kDXkn2/w==
X-Received: by 2002:a37:6812:: with SMTP id d18mr17118097qkc.28.1554591580762;
        Sat, 06 Apr 2019 15:59:40 -0700 (PDT)
X-Received: by 2002:a37:6812:: with SMTP id d18mr17118069qkc.28.1554591579702;
        Sat, 06 Apr 2019 15:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554591579; cv=none;
        d=google.com; s=arc-20160816;
        b=i0L4pz9Upz1KYxKDjOzhPHcUUCU/tyNso9tU4BBSTiO6PsuoHmYbdPVwv/Nes0oVyd
         Ti7PxjpjrM8XDXDZosbEnD88Rutg/y+vGhHnxrzZDRWD1XpP9uzpioUbebbMmR16nG6O
         H0A1FrG+yUj+5S1Vcj3Pi8KE0Q/2bBsiCfmOom9pfHsjGv4ftGvF+/zZ8wdyRbDfzXsD
         OOHn4+H4+0M7sJ1qdK1IIDvx0YhWRh5Lv9fBGvGpW5qdTJLZ+rnDP+aQndnWu6cMb6bY
         LlrHAS1tLxHzOwoWt2qf6yRSlp3BUEjdCgqbX8cTmTv/qd6TRs3A13UGnFmQnuomgJbm
         /86A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=dB4pAQEYeJLbgCkf7uLDDCPVAJv3hzEyEmEQnyQak1Y=;
        b=dn9LjfaRsWiRJnr58JxkT1WQtNwSngVxlkhEYG4jh41yz69AH8bDRWqcVxc3kz8H2i
         XJvTk8ucadP9KCuhWORzOO41Xdl+8MZGVd3UNpaAk4RCuZNcNTpcOHuPsbwd3NH8T7UB
         sLw5OBk/oLJgOW55b/K80Ny6eOnIPOWHvttj+C+Xdw+DX/KpXirac4Q1cNoaY2tZIolc
         j8f/vWlx0uiShM/rBpJTxY05Z68GiVnAVnK5dbF9f4654VdpRdUH+aXdJnXqRxRQrqZk
         R42COnXs34sqWX42rDrPBAdvhyMVa3TQOyS0S4nC8MTh49KKBVVpCogHTzKRclSe6pxT
         ZFmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YzlnuhjH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i31sor26219082qvc.47.2019.04.06.15.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Apr 2019 15:59:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=YzlnuhjH;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=dB4pAQEYeJLbgCkf7uLDDCPVAJv3hzEyEmEQnyQak1Y=;
        b=YzlnuhjHbnZtedtq9lxZSt102ihZxwGY6KhGVHTYQpl1ocdqALUzh1MEQwS/iLKqjd
         zMwRC8Mnk/JnfFW7AZnk4brmtvbqcZQf5W1S5leTjf3yAWM8Jrxg9XnRlOovcdepkF38
         CNfeDQI2jY9RndX4zcACJ5kpx+r3fMfc4r6f7ooGiP06k/AXelK57LY+U9VGyR6H3i5d
         CPTfuJXP8lUNaLxmmhwG+FYMT2M/G03NNp1dW4Ne6XI5caxttElS683d42XEHLGk9N4y
         ZUwkjKAVKdcyXCjA9hJO5DWGfETJ63J1cTIAIWBPF/QT9XFjpgRxn8X0XrQyc4mpxuLT
         NdmQ==
X-Google-Smtp-Source: APXvYqz3wcIgBwJUcDYOSjnelbMxOwMXqTVTHmB+Mkh/cuW1JsK3pbfE+G7JmIbpLGXPu2kLclGA3g==
X-Received: by 2002:a0c:c950:: with SMTP id v16mr17520467qvj.204.1554591579347;
        Sat, 06 Apr 2019 15:59:39 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id a47sm17785002qtb.79.2019.04.06.15.59.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Apr 2019 15:59:38 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	tj@kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: fix a crash by reading /proc/slab_allocators
Date: Sat,  6 Apr 2019 18:59:01 -0400
Message-Id: <20190406225901.35465-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 510ded33e075 ("slab: implement slab_root_caches list")
changes the name of the list node within "struct kmem_cache" from
"list" to "root_caches_node", but leaks_show() still use the "list"
which causes a crash when reading /proc/slab_allocators.

BUG: unable to handle kernel NULL pointer dereference at
00000000000000aa
PGD 0 P4D 0
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC PTI
CPU: 3 PID: 5925 Comm: ldd Not tainted 5.1.0-rc3-mm1+ #6
RIP: 0010:__lock_acquire.isra.14+0x4b4/0xa50
Call Trace:
 <IRQ>
 lock_acquire+0xa3/0x180
 _raw_spin_lock+0x2f/0x40
 do_drain+0x61/0xc0
 flush_smp_call_function_queue+0x3a/0x110
 generic_smp_call_function_single_interrupt+0x13/0x2b
 smp_call_function_interrupt+0x66/0x1a0
 call_function_interrupt+0xf/0x20
 </IRQ>
RIP: 0010:__tlb_remove_page_size+0x8c/0xe0
 zap_pte_range+0x39f/0xc80
 unmap_page_range+0x38a/0x550
 unmap_single_vma+0x7d/0xe0
 unmap_vmas+0xae/0xd0
 exit_mmap+0xae/0x190
 mmput+0x7a/0x150
 do_exit+0x2d9/0xd40
 do_group_exit+0x41/0xd0
 __x64_sys_exit_group+0x18/0x20
 do_syscall_64+0x68/0x381
 entry_SYSCALL_64_after_hwframe+0x44/0xa9

Fixes: 510ded33e075 ("slab: implement slab_root_caches list")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 46a6e084222b..9142ee992493 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4307,7 +4307,8 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 
 static int leaks_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
+					       root_caches_node);
 	struct page *page;
 	struct kmem_cache_node *n;
 	const char *name;
-- 
2.17.2 (Apple Git-113)

