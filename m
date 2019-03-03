Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FDBEC43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEC7820857
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 07:28:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEC7820857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 614B88E0008; Sun,  3 Mar 2019 02:28:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59B7C8E0001; Sun,  3 Mar 2019 02:28:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 417828E0008; Sun,  3 Mar 2019 02:28:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 142608E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 02:28:23 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id e1so2108255qth.23
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 23:28:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=aGshcIcYUYC+ZsnLZfetgFjKCxaDoKNhcCgeJHUaBic=;
        b=PdOXBCssrPvYh5Xh+RL5Sc8V9OXtBWNJ23Dty9g35J8qg0JcF5kjsoWlv7Q9PKA+O6
         YOPrbwlwFvsyN0nJt4TwV7oMl0NKirf9TcqGetTKd2ljF35AcM8jhwu8W2VcFs2p5Twf
         0PnFQooQ4ZFFtEwLo38onsRgSVicwL1r4v2CzPoC64JxGt4NIk2UaVAK048JgC2zoGTt
         ouHW3LONW3kzirnDKlCzx5/pwrdBa5oGY45cwCfjQ/8iyfmf7bKa8B0auioxp34W3CNp
         b47NMku9sWq/8XtQe1wzZbG7a14sKh2mSOtBsAwzYyXwcnRF9fxVDe5r7qOo8JZFpnF0
         O8mQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX1Uba9evF3VHgHLcca9CY04debp79IB/eYJZGFehGUIa/mz4WZ
	+vORiNRqcfTi8Ax2srp8s/LsIt2RGXSg2k7VLNqEjp2rp3jgqoT9P+vQ6dA/idGCdbu9JjPK45O
	MtZwKEevyGCeqR1BeZwF4ViwEu2roqPzC5sSzXiMlYOkCUUBdyrNvlLVL/kNp8AjlMQ==
X-Received: by 2002:a0c:8186:: with SMTP id 6mr10136959qvd.139.1551598102842;
        Sat, 02 Mar 2019 23:28:22 -0800 (PST)
X-Google-Smtp-Source: APXvYqy2zLAV/7rNtynOiciFM5k0VYjbkeX7S6ftWN3yAs1bLAkNXk602Fe83Yd+r7jKWGrBXJkW
X-Received: by 2002:a0c:8186:: with SMTP id 6mr10136937qvd.139.1551598102141;
        Sat, 02 Mar 2019 23:28:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551598102; cv=none;
        d=google.com; s=arc-20160816;
        b=v7wExUzImrzwBEE5U68aNCk0o0nye/dRm/YqXgdzLxSilln45gRBmQL5qZGrMK2WuY
         xb6YZiFyh271Dz7j6AINeeHrMVV+nJJSz/bPAXggPA9x/EsPCKyixRWFd5pgBJzhAR47
         R7icm65IWQf+2scp5Kv0DW3/ZCi4+Kb0Ffd2C4Dpg0X4OMvPBIcpVtt3y+fGw1wuxwpf
         udr3tOwNGBcahVwnDjJ6agQ3T2HcLy8v798tMxgWk4ysYPG1D3/i9ntm2Nc3EPaIAC+J
         rTRh+Z1y/lRU3bMwWnPEwYL2aiWdY7IFoz23mW+XniqUnVbxl09zaksLsBAeE8R+LokK
         NZug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=aGshcIcYUYC+ZsnLZfetgFjKCxaDoKNhcCgeJHUaBic=;
        b=UIcYNFz6x747PAxzPr3i7te3awd/j0fYYyPeZwzDB8eseXaEFZmfmANQO522d/lCh6
         i3/3k7NSijXU4buVmuBRA45RVOecjWv9GaVDWqr0fycp/F9ljgW9RDNdvPYhIEp/zdYV
         aUHSlp2Q4jN4loqUHT8vfi0MFs7iymEIU0rEdTqT4v12/Bj8Bf25Gb/JZYn7SNtwiQR5
         WBLYa/ZmfsRnlk0bHuPWIjVhU7OmluFGJf1QceDeW1mUHmEqvfaMEPdehST9umQmNZOC
         lIKO9W5X/oJcNxU3zaY6Ql27D78NWLh3Dvec1oJIMlta0nrIiK6j4p8YKDN2vbKYSg3L
         Qk2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e81si634278qkj.150.2019.03.02.23.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 23:28:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 44AEE308339D;
	Sun,  3 Mar 2019 07:28:21 +0000 (UTC)
Received: from dustball.brq.redhat.com (unknown [10.43.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4235C19C56;
	Sun,  3 Mar 2019 07:28:15 +0000 (UTC)
From: Jan Stancek <jstancek@redhat.com>
To: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	willy@infradead.org,
	peterz@infradead.org,
	riel@surriel.com,
	mhocko@suse.com,
	ying.huang@intel.com,
	jrdr.linux@gmail.com,
	jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com,
	david@redhat.com,
	aarcange@redhat.com,
	raquini@redhat.com,
	rientjes@google.com,
	kirill@shutemov.name,
	mgorman@techsingularity.net,
	jstancek@redhat.com
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH v3] mm/memory.c: do_fault: avoid usage of stale vm_area_struct
Date: Sun,  3 Mar 2019 08:28:04 +0100
Message-Id: <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
In-Reply-To: <20190302185144.GD31083@redhat.com>
References: <20190302185144.GD31083@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Sun, 03 Mar 2019 07:28:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
This is a stress test, where one thread mmaps/writes/munmaps memory area
and other thread is trying to read from it:

  CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
  Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
  Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
  Call Trace:
  ([<0000000000000000>]           (null))
   [<00000000001adae4>] lock_acquire+0xec/0x258
   [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
   [<000000000012a780>] page_table_free+0x48/0x1a8
   [<00000000002f6e54>] do_fault+0xdc/0x670
   [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
   [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
   [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
   [<000000000080e5ee>] pgm_check_handler+0x19e/0x200

page_table_free() is called with NULL mm parameter, but because
"0" is a valid address on s390 (see S390_lowcore), it keeps
going until it eventually crashes in lockdep's lock_acquire.
This crash is reproducible at least since 4.14.

Problem is that "vmf->vma" used in do_fault() can become stale.
Because mmap_sem may be released, other threads can come in,
call munmap() and cause "vma" be returned to kmem cache, and
get zeroed/re-initialized and re-used:

handle_mm_fault                           |
  __handle_mm_fault                       |
    do_fault                              |
      vma = vmf->vma                      |
      do_read_fault                       |
        __do_fault                        |
          vma->vm_ops->fault(vmf);        |
            mmap_sem is released          |
                                          |
                                          | do_munmap()
                                          |   remove_vma_list()
                                          |     remove_vma()
                                          |       vm_area_free()
                                          |         # vma is released
                                          | ...
                                          | # same vma is allocated
                                          | # from kmem cache
                                          | do_mmap()
                                          |   vm_area_alloc()
                                          |     memset(vma, 0, ...)
                                          |
      pte_free(vma->vm_mm, ...);          |
        page_table_free                   |
          spin_lock_bh(&mm->context.lock);|
            <crash>                       |

Cache mm_struct to avoid using potentially stale "vma".

[1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c

Signed-off-by: Jan Stancek <jstancek@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/memory.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e11ca9dd823f..e8d69ade5acc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3517,10 +3517,13 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
  * but allow concurrent faults).
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
+ * If mmap_sem is released, vma may become invalid (for example
+ * by other thread calling munmap()).
  */
 static vm_fault_t do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
+	struct mm_struct *vm_mm = vma->vm_mm;
 	vm_fault_t ret;
 
 	/*
@@ -3561,7 +3564,7 @@ static vm_fault_t do_fault(struct vm_fault *vmf)
 
 	/* preallocated pagetable is unused: free it */
 	if (vmf->prealloc_pte) {
-		pte_free(vma->vm_mm, vmf->prealloc_pte);
+		pte_free(vm_mm, vmf->prealloc_pte);
 		vmf->prealloc_pte = NULL;
 	}
 	return ret;
-- 
1.8.3.1

