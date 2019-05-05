Return-Path: <SRS0=X77i=TF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7A3EC004C9
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 14:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F1E5206DF
	for <linux-mm@archiver.kernel.org>; Sun,  5 May 2019 14:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F1E5206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E80ED6B0005; Sun,  5 May 2019 10:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E309D6B0006; Sun,  5 May 2019 10:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D214A6B0007; Sun,  5 May 2019 10:10:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B49046B0005
	for <linux-mm@kvack.org>; Sun,  5 May 2019 10:10:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s46so1658186qtj.4
        for <linux-mm@kvack.org>; Sun, 05 May 2019 07:10:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=gOsawLXWlD3op8IPdLOVlyL/W2wRBfNDVGnQJh7Td9Y=;
        b=RK8iqbCwnd3tmxyPNsiGvpEa+L+OwHA7XXgqC/Ana1dCJx41FmrjMb6G+jVRDzXGVP
         cviZn1FKEYwKIzxfzBFDJD8JnPHP5or36X8c6AEkbDN19PuwGXIbxLD/35MkiyHHw0wC
         GUJAZVCdrM0QbKgdzXWrdG0ga3/9NE1AB4mcpxwS6IvaCEjh+FQZ0+WiPbE3kVSQMxoc
         vb+se//87VY5AhUSxH8SfMD33u/Pa7eK6x0VV+Bi41nE1X5Jujx/jzdf+WWgWqa+52V5
         At5+IlTGtphl8gVyaroODy3ZjJmJJB5y/89vpC2kB++hLxmMlT7hPqUFKEw2sO1aHQuZ
         Mcdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0FSrTBKVMwt6xg0kMsQU+jLDIPva7Q6wn+PMp9Nrtm/R0ZUOO
	YmvqHPVtYvTRMf0LjLR7IME8dMTUbolGkOcsWT25R/Z+qzM0L+afKH/qQBUZfgbnYSUVi51x/md
	meJ4OrShhc67UKeH8TaFR4HxINlIWITeU93hZCQQsjr+RiR+0eoJwrm3FALtOWMLH0Q==
X-Received: by 2002:ac8:743:: with SMTP id k3mr14288481qth.207.1557065451371;
        Sun, 05 May 2019 07:10:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqP0cydHGiWxrwM+znedZyde3ZHKCnALIwqOxGIjCRcePuG34zRFsGksy/qTNFX3gxqZtx
X-Received: by 2002:ac8:743:: with SMTP id k3mr14288411qth.207.1557065450383;
        Sun, 05 May 2019 07:10:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557065450; cv=none;
        d=google.com; s=arc-20160816;
        b=t1yFrjIuLIvLgJFjjW6a0BIWNqzFiRD0hpG/98fbwhsVWqdwHm09597chD3uLpr+IF
         bnIembtUcQmwLwci/u4pSq3URX/JdCuzHDvCd2jrobnmixrEXyEDuygsQ7TRc0l2U+kg
         T6QmhH3q5j1c21MQwDaRyRh1n+C+NBXaU7y/0IhyKSLr8C1CKwu7zJ5e11ux9g0yLHfi
         szaEcFjKQwPAK/IoWBvKB5tsz1bCklbSVg2vDjjhU41kWLD0i8HxxHejIQypF+cN/GiM
         ndExKieqFfStzMMv/ixuWpSM+qoLwtUybGtQcWcurLrptMnnh21HWPeT6lvnTJ6W3gEQ
         q6JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:in-reply-to:message-id:cc:to:from:date;
        bh=gOsawLXWlD3op8IPdLOVlyL/W2wRBfNDVGnQJh7Td9Y=;
        b=M4Y7vlHWExp8EH5UFozaTBXZFEcjdHs/45yRiFsKSzxEQViMU1J/QGFBHXExB50KVt
         xQH+j8Okic4NTumTd81x2x5FZY8Oz0RQWFekFA4dBb1iUVwN/oyPS92ubD7CMm55TzKt
         9MUvX1OseZdDMaMzKCkn4rYHnTUVAWnanIpzbsgAXfzSzBKBxH6cS8z7YYhsZuaSeW9b
         vWvS07eKhBlQvxOOWLHN7u8XuDjFOpFXbSTHAMt1KFKFPYZatgyJ2CPWyC3C6dOt9DC6
         corR/AdPm7k2l9DXx4ed2P/DjHMwoqX5ryvCzKIBvl4fsfwvg6pqYMIGIV5jHbRzrANK
         2Zxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j11si862080qkl.199.2019.05.05.07.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 May 2019 07:10:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F1FF4C06645C;
	Sun,  5 May 2019 14:10:48 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C7B5A60C43;
	Sun,  5 May 2019 14:10:48 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 4EEA718089C8;
	Sun,  5 May 2019 14:10:48 +0000 (UTC)
Date: Sun, 5 May 2019 10:10:45 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: yang shi <yang.shi@linux.alibaba.com>, kirill@shutemov.name, 
	willy@infradead.org, 
	kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, 
	Waiman Long <longman@redhat.com>, Jan Stancek <jstancek@redhat.com>
Message-ID: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com>
In-Reply-To: <820667266.20994189.1557058281210.JavaMail.zimbra@redhat.com>
Subject: [bug] aarch64: userspace stalls on page fault after dd2283f2605e
 ("mm: mmap: zap pages with read mmap_sem in munmap")
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.49, 10.4.195.17]
Thread-Topic: aarch64: userspace stalls on page fault after dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Thread-Index: mxi6IavaUitcMtER3aVvUOvUE5iG/g==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Sun, 05 May 2019 14:10:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm seeing userspace program getting stuck on aarch64, on kernels 4.20 and newer.
It stalls from seconds to hours.

I have simplified it to following scenario (reproducer linked below [1]):
  while (1):
    spawn Thread 1: mmap, write, munmap
    spawn Thread 2: <nothing>

Thread 1 is sporadically getting stuck on write to mapped area. User-space is not
moving forward - stdout output stops. Observed CPU usage is however 100%.

At this time, kernel appears to be busy handling page faults (~700k per second):

# perf top -a -g
-   98.97%     8.30%  a.out                     [.] map_write_unmap
   - 23.52% map_write_unmap
      - 24.29% el0_sync
         - 10.42% do_mem_abort
            - 17.81% do_translation_fault
               - 33.01% do_page_fault
                  - 56.18% handle_mm_fault
                       40.26% __handle_mm_fault
                       2.19% __ll_sc___cmpxchg_case_acq_4
                       0.87% mem_cgroup_from_task
                  - 6.18% find_vma
                       5.38% vmacache_find
                    1.35% __ll_sc___cmpxchg_case_acq_8
                    1.23% __ll_sc_atomic64_sub_return_release
                    0.78% down_read_trylock
           0.93% do_translation_fault
   + 8.30% thread_start

#  perf stat -p 8189 -d 
^C
 Performance counter stats for process id '8189':

        984.311350      task-clock (msec)         #    1.000 CPUs utilized
                 0      context-switches          #    0.000 K/sec
                 0      cpu-migrations            #    0.000 K/sec
           723,641      page-faults               #    0.735 M/sec
     2,559,199,434      cycles                    #    2.600 GHz
       711,933,112      instructions              #    0.28  insn per cycle
   <not supported>      branches
           757,658      branch-misses
       205,840,557      L1-dcache-loads           #  209.121 M/sec
        40,561,529      L1-dcache-load-misses     #   19.71% of all L1-dcache hits
   <not supported>      LLC-loads
   <not supported>      LLC-load-misses

       0.984454892 seconds time elapsed

With some extra traces, it appears looping in page fault for same address, over and over:
  do_page_fault // mm_flags: 0x55
    __do_page_fault
      __handle_mm_fault
        handle_pte_fault
          ptep_set_access_flags
            if (pte_same(pte, entry))  // pte: e8000805060f53, entry: e8000805060f53

I had traces in mmap() and munmap() as well, they don't get hit when reproducer
hits the bad state.

Notes:
- I'm not able to reproduce this on x86.
- Attaching GDB or strace immediatelly recovers application from stall.
- It also seems to recover faster when system is busy with other tasks.
- MAP_SHARED vs. MAP_PRIVATE makes no difference.
- Turning off THP makes no difference.
- Reproducer [1] usually hits it within ~minute on HW described below.
- Longman mentioned that "When the rwsem becomes reader-owned, it causes
  all the spinning writers to go to sleep adding wakeup latency to
  the time required to finish the critical sections", but this looks
  like busy loop, so I'm not sure if it's related to rwsem issues identified
  in: https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redhat.com/
- I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza A3 and
  Qualcomm 65-LA-115-151.
  I can reproduce it on both with v5.1-rc7. It's easier to reproduce
  on latter one (for longer periods of time), which has 46 CPUs.
- Sample output of reproducer on otherwise idle system:
  # ./a.out
  [00000314] map_write_unmap took: 26305 ms
  [00000867] map_write_unmap took: 13642 ms
  [00002200] map_write_unmap took: 44237 ms
  [00002851] map_write_unmap took: 992 ms
  [00004725] map_write_unmap took: 542 ms
  [00006443] map_write_unmap took: 5333 ms
  [00006593] map_write_unmap took: 21162 ms
  [00007435] map_write_unmap took: 16982 ms
  [00007488] map_write unmap took: 13 ms^C

I ran a bisect, which identified following commit as first bad one:
  dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")

I can also make the issue go away with following change:
diff --git a/mm/mmap.c b/mm/mmap.c
index 330f12c17fa1..13ce465740e2 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
        profile_munmap(addr);
-       return __vm_munmap(addr, len, true);
+       return __vm_munmap(addr, len, false);
 }

# cat /proc/cpuinfo  | head
processor       : 0
BogoMIPS        : 40.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid asimdrdm
CPU implementer : 0x51
CPU architecture: 8
CPU variant     : 0x0
CPU part        : 0xc00
CPU revision    : 1

# numactl -H
available: 1 nodes (0)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
node 0 size: 97938 MB
node 0 free: 95732 MB
node distances:
node   0 
  0:  10 

Regards,
Jan

[1] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap5.c
[2] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/config

