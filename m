Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14DC5C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF536274A9
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF536274A9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B59A6B0269; Mon,  3 Jun 2019 13:04:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640476B0284; Mon,  3 Jun 2019 13:04:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B7106B0285; Mon,  3 Jun 2019 13:04:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FAD46B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:04:13 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d62so9231349otb.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:04:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=JAsYO7ok7QGSPzWKWGArwjPYggdUfjkgNDp3P3esyFU=;
        b=AIHFmgBBJ7vnQXXnCb1SgmAntIVKmrxi7JdruoQXXigKiTrqonsef07bthwv2Baf9h
         BzEEGQAyEfDNAry1M9X54GW5iBxqspYF9GOiDHrHo2kF4zEVjFm3RtvU/4gitl+1Eluv
         tHAY6dT7mnYA6qwrP9gOW7FnmoNnAYv/AjwPfTfuAf3Fgxwo1U8ljSBwHQn6jwGAsBXG
         sHHGojTg2ht+vnsYZ0c4lrHSaPv05Gqw2g5xZgqgYq5MnKA9e2UGYPY4Boqygo+/FSSH
         ylsNiCiDRHWixNfzaGGZrFiGMmZzcnIWdVS3uN6B4ti5QgzEEQYMd0T2CuiWae68w12q
         ojMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQsEABozmzMgzuOCLCA9k7eaT3EAg9iJJTS4yZyJNwH7jzArn/
	Vis0wC0LqjDcoLeGRU0hzjo8EWH8XunJ34HueVLc3n0uY3xcq3CwRhOGiY1vsPIAgsEdYd89xYS
	KguYS1WqUYOVzc0ipEcq2u3gPz4NsxaAWKAl7G7yASph32Nbdzh/DnRRXCwhUPn9Rtw==
X-Received: by 2002:aca:d7c3:: with SMTP id o186mr1555344oig.20.1559581452756;
        Mon, 03 Jun 2019 10:04:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk5EwBaig/ooPRbqCDN5TrtIu3ijd7Jqv8475mG48OJJvVsjwbQJpIXHc1uIgSZ64SLOq8
X-Received: by 2002:aca:d7c3:: with SMTP id o186mr1555274oig.20.1559581451573;
        Mon, 03 Jun 2019 10:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581451; cv=none;
        d=google.com; s=arc-20160816;
        b=poaY3hbBRn/DFSFJXPm9mo+HwvY5LBbZjZuWO27TkCLjfQSpjkWri/w5c3H7qHRGl8
         vpB+HopeE2XNmq538mesLQoD9cLaJX/8DbgSMi398UUL2GEOsn/9yYgdj4jN8HuEpErn
         xpI800OvKVmgZkglwe6AKvlK31nklyISL7BT+ttHAAjiAaeVTwh2c8LDkE/oNTPokRwv
         kk4DQeRM7ZRec+zcon0oYJNccIAinGaxJxV5/zAafIKfeXvvPxaRXNiMbkleVOmSWHjF
         0j3QE/YKQFYabkhr+SHo3+eUvPDQvHnSkspO7M3cQQy7ptUCrdyy6lqmNtns/yCVYCmD
         ASLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from;
        bh=JAsYO7ok7QGSPzWKWGArwjPYggdUfjkgNDp3P3esyFU=;
        b=L2WkbJcBGenPoP1sGic8Hjn/iXjLNRyah6momqsDTZikO6IesWJ87PM41EF8N20G8m
         cjr2fHh8bFutc4Lb4/4m3ykuoY53YHACnU1QcKEfWnRruXBTBh2621QyPNMilqch5NSw
         MtxIt9paYr7sdoS0p1zm/dawVUnPeS0PNdAUiyF/hzoixUpvrBB/dA92cuCeoYLquGOf
         iBputFApoREbDjQzcw3v7THgHF3gRS94xwbo/Htdzb9asg74WGY1oo9e0tViQ8IgIO6r
         nxOJUHuTW85D2yLsw0ZRDmGTivNIBBCO4TWDbb25Dj2lvUcHxcoY1iK8XlmvOBF11YZf
         Y3KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e23si8700338otf.94.2019.06.03.10.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D267AC028353;
	Mon,  3 Jun 2019 17:03:55 +0000 (UTC)
Received: from virtlab512.virt.lab.eng.bos.redhat.com (virtlab512.virt.lab.eng.bos.redhat.com [10.19.152.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9238960C66;
	Mon,  3 Jun 2019 17:03:41 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v10 0/2] mm: Support for page hinting 
Date: Mon,  3 Jun 2019 13:03:04 -0400
Message-Id: <20190603170306.49099-1-nitesh@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 03 Jun 2019 17:04:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch series proposes an efficient mechanism for communicating free memory
from a guest to its hypervisor. It especially enables guests with no page cache
(e.g., nvdimm, virtio-pmem) or with small page caches (e.g., ram > disk) to
rapidly hand back free memory to the hypervisor.
This approach has a minimal impact on the existing core-mm infrastructure.

Measurement results (measurement details appended to this email):
* With active page hinting, 3 more guests could be launched each of 5 GB(total 
5 vs. 2) on a 15GB (single NUMA) system without swapping.
* With active page hinting, on a system with 15 GB of (single NUMA) memory and
4GB of swap, the runtime of "memhog 6G" in 3 guests (run sequentially) resulted
in the last invocation to only need 37s compared to 3m35s without page hinting.

This approach tracks all freed pages of the order MAX_ORDER - 2 in bitmaps.
A new hook after buddy merging is used to set the bits in the bitmap.
Currently, the bits are only cleared when pages are hinted, not when pages are
re-allocated.

Bitmaps are stored on a per-zone basis and are protected by the zone lock. A
workqueue asynchronously processes the bitmaps as soon as a pre-defined memory
threshold is met, trying to isolate and report pages that are still free.

The isolated pages are reported via virtio-balloon, which is responsible for
sending batched pages to the host synchronously. Once the hypervisor processed
the hinting request, the isolated pages are returned back to the buddy.

The key changes made in this series compared to v9[1] are:
* Pages only in the chunks of "MAX_ORDER - 2" are reported to the hypervisor to
not break up the THP.
* At a time only a set of 16 pages can be isolated and reported to the host to
avoids any false OOMs.
* page_hinting.c is moved under mm/ from virt/kvm/ as the feature is dependent
on virtio and not on KVM itself. This would enable any other hypervisor to use
this feature by implementing virtio devices.
* The sysctl variable is replaced with a virtio-balloon parameter to
enable/disable page-hinting.

Pending items:
* Test device assigned guests to ensure that hinting doesn't break it.
* Follow up on VIRTIO_BALLOON_F_PAGE_POISON's device side support.
* Compare reporting free pages via vring with vhost.
* Decide between MADV_DONTNEED and MADV_FREE.
* Look into memory hotplug, more efficient locking, possible races when
disabling.
* Come up with proper/traceable error-message/logs.
* Minor reworks and simplifications (e.g., virtio protocol).

Benefit analysis:
1. Use-case - Number of guests that can be launched without swap usage
NUMA Nodes = 1 with 15 GB memory
Guest Memory = 5 GB
Number of cores in guest = 1
Workload = test allocation program allocates 4GB memory, touches it via memset
and exits.
Procedure =
The first guest is launched and once its console is up, the test allocation
program is executed with 4 GB memory request (Due to this the guest occupies
almost 4-5 GB of memory in the host in a system without page hinting). Once
this program exits at that time another guest is launched in the host and the
same process is followed. It is continued until the swap is not used.

Results:
Without hinting = 3, swap usage at the end 1.1GB.
With hinting = 5, swap usage at the end 0.

2. Use-case - memhog execution time
Guest Memory = 6GB
Number of cores = 4
NUMA Nodes = 1 with 15 GB memory
Process: 3 Guests are launched and the ‘memhog 6G’ execution time is monitored
one after the other in each of them.
Without Hinting - Guest1:47s, Guest2:53s, Guest3:3m35s, End swap usage: 3.5G
With Hinting - Guest1:40s, Guest2:44s, Guest3:37s, End swap usage: 0

Performance analysis:
1. will-it-scale's page_faul1:
Guest Memory = 6GB
Number of cores = 24

Without Hinting:
tasks,processes,processes_idle,threads,threads_idle,linear
0,0,100,0,100,0
1,315890,95.82,317633,95.83,317633
2,570810,91.67,531147,91.94,635266
3,826491,87.54,713545,88.53,952899
4,1087434,83.40,901215,85.30,1270532
5,1277137,79.26,916442,83.74,1588165
6,1503611,75.12,1113832,79.89,1905798
7,1683750,70.99,1140629,78.33,2223431
8,1893105,66.85,1157028,77.40,2541064
9,2046516,62.50,1179445,76.48,2858697
10,2291171,58.57,1209247,74.99,3176330
11,2486198,54.47,1217265,75.13,3493963
12,2656533,50.36,1193392,74.42,3811596
13,2747951,46.21,1185540,73.45,4129229
14,2965757,42.09,1161862,72.20,4446862
15,3049128,37.97,1185923,72.12,4764495
16,3150692,33.83,1163789,70.70,5082128
17,3206023,29.70,1174217,70.11,5399761
18,3211380,25.62,1179660,69.40,5717394
19,3202031,21.44,1181259,67.28,6035027
20,3218245,17.35,1196367,66.75,6352660
21,3228576,13.26,1129561,66.74,6670293
22,3207452,9.15,1166517,66.47,6987926
23,3153800,5.09,1172877,61.57,7305559
24,3184542,0.99,1186244,58.36,7623192

With Hinting:
0,0,100,0,100,0
1,306737,95.82,305130,95.78,306737
2,573207,91.68,530453,91.92,613474
3,810319,87.53,695281,88.58,920211
4,1074116,83.40,880602,85.48,1226948
5,1308283,79.26,1109257,81.23,1533685
6,1501987,75.12,1093661,80.19,1840422
7,1695300,70.99,1104207,79.03,2147159
8,1901523,66.85,1193613,76.90,2453896
9,2051288,62.73,1200913,76.22,2760633
10,2275771,58.60,1192992,75.66,3067370
11,2435016,54.48,1191472,74.66,3374107
12,2623114,50.35,1196911,74.02,3680844
13,2766071,46.22,1178589,73.02,3987581
14,2932163,42.10,1166414,72.96,4294318
15,3000853,37.96,1177177,72.62,4601055
16,3113738,33.85,1165444,70.54,4907792
17,3132135,29.77,1165055,68.51,5214529
18,3175121,25.69,1166969,69.27,5521266
19,3205490,21.61,1159310,65.65,5828003
20,3220855,17.52,1171827,62.04,6134740
21,3182568,13.48,1138918,65.05,6441477
22,3130543,9.30,1128185,60.60,6748214
23,3087426,5.15,1127912,55.36,7054951
24,3099457,1.04,1176100,54.96,7361688

[1] https://lkml.org/lkml/2019/3/6/413


