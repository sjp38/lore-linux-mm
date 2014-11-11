Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B54086B0113
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 07:57:51 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id n3so1531238wiv.12
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:57:51 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id ex8si17562768wjb.33.2014.11.11.04.57.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 04:57:50 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id n3so1530008wiv.8
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 04:57:50 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V3 0/4] KSM: Mark new vma for deduplication
Date: Tue, 11 Nov 2014 15:57:32 +0300
Message-Id: <1415710656-29296-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nefelim4ag@gmail.com, marco.antonio.780@gmail.com, linux-kernel@vger.kernel.org, tonyb@cybernetics.com, killertofu@gmail.com

Good time of day List,
this tiny series of patches implement feature for auto deduping all anonymous memory.
mark_new_vma - new ksm sysfs interface
Every time then new vma created and mark_new_vma set to 1, then will be vma marked as VM_MERGEABLE and added to ksm queue.
This can produce small overheads
(I have not catch any problems or slowdown)

This is useful for:
Android (CM) devs which implement ksm support with patching system.
Users of tiny pc.
Servers what not use KVM but use something very releated, like containers.

Can be pulled from:
https://github.com/Nefelim4ag/linux.git ksm_improvements

For tests:
I have tested it and it working very good. For testing apply it and enable ksm:
echo 1 | sudo tee /sys/kernel/mm/ksm/run
This show how much memory saved:
echo $[$(cat /sys/kernel/mm/ksm/pages_shared)*$(getconf PAGE_SIZE)/1024 ]KB

On my system i save ~1% of memory 26 Mb/2100 Mb (deduped)/(used)

v2:
	Added Kconfig for control default value of mark_new_vma
	Added sysfs interface for control mark_new_vma
	Splitted in several patches

v3:
	Documentation for ksm changed for clarify new cha

Timofey Titovets (4):
  KSM: Add auto flag new VMA as VM_MERGEABLE
  KSM: Add to sysfs - mark_new_vma
  KSM: Add config to control mark_new_vma
  KSM: mark_new_vma added to Documentation.

 Documentation/vm/ksm.txt |  7 +++++++
 include/linux/ksm.h      | 39 +++++++++++++++++++++++++++++++++++++++
 mm/Kconfig               |  7 +++++++
 mm/ksm.c                 | 39 ++++++++++++++++++++++++++++++++++++++-
 mm/mmap.c                | 17 +++++++++++++++++
 5 files changed, 108 insertions(+), 1 deletion(-)

-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
