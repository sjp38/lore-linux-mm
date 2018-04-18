Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23ADF6B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 15:32:36 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id j69-v6so852117lfg.6
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 12:32:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l188-v6sor539191lfe.15.2018.04.18.12.32.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 12:32:33 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V6 0/2 RESEND] KSM replace hash algo with faster hash
Date: Wed, 18 Apr 2018 22:32:18 +0300
Message-Id: <20180418193220.4603-1-timofey.titovets@synesis.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

From: Timofey Titovets <nefelim4ag@gmail.com>

Currently used jhash are slow enough and replace it allow as to make KSM
less cpu hungry.

About speed (in kernel):
        ksm: crc32c   hash() 12081 MB/s
        ksm: xxh64    hash()  8770 MB/s
        ksm: xxh32    hash()  4529 MB/s
        ksm: jhash2   hash()  1569 MB/s

By sioh Lee tests (copy from other mail):
Test platform: openstack cloud platform (NEWTON version)
Experiment node: openstack based cloud compute node (CPU: xeon E5-2620 v3, memory 64gb)
VM: (2 VCPU, RAM 4GB, DISK 20GB) * 4
Linux kernel: 4.14 (latest version)
KSM setup - sleep_millisecs: 200ms, pages_to_scan: 200

Experiment process
Firstly, we turn off KSM and launch 4 VMs.
Then we turn on the KSM and measure the checksum computation time until full_scans become two.

The experimental results (the experimental value is the average of the measured values)
crc32c_intel: 1084.10ns
crc32c (no hardware acceleration): 7012.51ns
xxhash32: 2227.75ns
xxhash64: 1413.16ns
jhash2: 5128.30ns

In summary, the result shows that crc32c_intel has advantages over all 
of the hash function used in the experiment. (decreased by 84.54% compared to crc32c,
78.86% compared to jhash2, 51.33% xxhash32, 23.28% compared to xxhash64)
the results are similar to those of Timofey.

So:
  - Fisrt patch implement compile time pickup of fastest implementation of xxhash
    for target platform.
  - Second implement logic in ksm, what test speed of hashes and pickup fastest hash
  
Thanks.

CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
CC: leesioh <solee@os.korea.ac.kr>

Timofey Titovets (2):
  xxHash: create arch dependent 32/64-bit xxhash()
  ksm: replace jhash2 with faster hash

 include/linux/xxhash.h | 23 +++++++++++++
 mm/Kconfig             |  2 ++
 mm/ksm.c               | 93 +++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 114 insertions(+), 4 deletions(-)

-- 
2.14.1
