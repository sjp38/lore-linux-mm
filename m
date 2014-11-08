Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5103682BEF
	for <linux-mm@kvack.org>; Sat,  8 Nov 2014 18:01:50 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id ex7so7449991wid.8
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 15:01:49 -0800 (PST)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id xv4si22261050wjb.167.2014.11.08.15.01.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Nov 2014 15:01:49 -0800 (PST)
Received: by mail-wi0-f182.google.com with SMTP id d1so7417462wiv.15
        for <linux-mm@kvack.org>; Sat, 08 Nov 2014 15:01:49 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v2 0/3] KSM: Mark new vma for deduplication
Date: Sun,  9 Nov 2014 02:01:40 +0300
Message-Id: <1415487703-1824-1-git-send-email-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: nefelim4ag@gmail.com, marco.antonio.780@gmail.com

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

For tests:
I have tested it and it working very good. For testing apply it and enable ksm:
echo 1 | sudo tee /sys/kernel/mm/ksm/run
This show how much memory saved:
echo $[$(cat /sys/kernel/mm/ksm/pages_shared)*$(getconf PAGE_SIZE)/1024 ]KB

On my system i save ~1% of memory 26 Mb/2100 Mb (deduped)/(used)

Timofey Titovets (3):
  KSM: Add auto flag new VMA as VM_MERGEABLE
  KSM: Add to sysfs - mark_new_vma
  KSM: Add config to control mark_new_vma

 include/linux/ksm.h | 39 +++++++++++++++++++++++++++++++++++++++
 mm/Kconfig          |  7 +++++++
 mm/ksm.c            | 39 ++++++++++++++++++++++++++++++++++++++-
 mm/mmap.c           | 17 +++++++++++++++++
 4 files changed, 101 insertions(+), 1 deletion(-)

--
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
