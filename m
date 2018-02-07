Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 383A56B02F4
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 05:22:38 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id a76so132760lfb.3
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 02:22:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a77sor258120lfa.42.2018.02.07.02.22.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 02:22:36 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V6 0/2 RESEND] KSM replace hash algo with faster hash
Date: Wed,  7 Feb 2018 13:22:22 +0300
Message-Id: <20180207102224.28016-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
