Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3E1F6B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:26:22 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id c13-v6so397664wmb.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:26:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p127-v6sor1700527wmd.28.2018.10.23.11.26.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 11:26:20 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH RESEND V8 0/2] Currently used jhash are slow enough and replace it allow as to make KSM
Date: Tue, 23 Oct 2018 21:25:52 +0300
Message-Id: <20181023182554.23464-1-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <timofey.titovets@synesis.ru>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

From: Timofey Titovets <timofey.titovets@synesis.ru>

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

But,
use only xxhash for now, because for using crc32c,
cryptoapi must be initialized first - that require some
tricky solution to work good in all situations.

So:
  - Fisrt patch implement compile time pickup of fastest implementation of xxhash
    for target platform.
  - Second replace jhash2 with xxhash

Thanks.

CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
CC: leesioh <solee@os.korea.ac.kr>

Timofey Titovets (2):
  xxHash: create arch dependent 32/64-bit xxhash()
  ksm: replace jhash2 with xxhash

 include/linux/xxhash.h | 23 +++++++++++++++++++++++
 mm/Kconfig             |  1 +
 mm/ksm.c               |  4 ++--
 3 files changed, 26 insertions(+), 2 deletions(-)

-- 
2.19.0
