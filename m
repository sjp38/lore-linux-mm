Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05AC2C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:23:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1272086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 08:23:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1272086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE0276B000D; Tue, 14 May 2019 04:23:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D682E6B000E; Tue, 14 May 2019 04:23:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C081E6B0010; Tue, 14 May 2019 04:23:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF326B000D
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:23:43 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b81so11269155ywc.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 01:23:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=kKiJvBWnvz3OUZGCU+wkVsmbgL26LhwAtAT9BoEI3bk=;
        b=lgnjRgu1RFvL32xTsCH1DN3IMhhxowSW5xw6Now2Y0fESEdIY3WX+v7nRkbMLBFSaW
         Sm54Rz3B1lo0wZH1mkwuuPZd4+akHX2WsSTq4lIzSFUqfIo+jBmqnFSjZGqhbia4jsUV
         poKLmPuJTM4L9sSazFg3kVgULbqCsYwlmYFlfqfMhWIUsIxhb79Iv7RuxA4X4SS05FLn
         ahF+kqEDYUwop185eKNFJju3+fss20xfs3sFObJw+ryEYyjujxqm4E/b6FrPjzr6BYpB
         kL5+rLSsX4LLhCZZbcXL9mKjdF0bPPXoQ25rSYLAwRlAryWdjFLgX2sYvbmIjHkJ6vsO
         q+lQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUSRFJ6GDP+SHx1tiRpObQ8RXpQpsULAPvJMPPEzGnUZPQT4j86
	9o8CuXmdluc9gfDmj4MIOWw8OBIfIY5Qtn7GJHhvEuni6H0TBSFBNvAYu4oxlSD2z11SbUXflx+
	bJyRGEp0S2gwhBTvAFixwWh5CJmMb4GrHYHROf/39r8fQH1O1RcnMZNg2pAmUP+7PQw==
X-Received: by 2002:a25:2ac6:: with SMTP id q189mr15707833ybq.310.1557822223358;
        Tue, 14 May 2019 01:23:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpdu6gArV9llX0SsaLdLpACU09tiJjuQLsyAwkbY4Y1HM1VveUJX99woBty9MvDxHHeKDz
X-Received: by 2002:a25:2ac6:: with SMTP id q189mr15707821ybq.310.1557822222653;
        Tue, 14 May 2019 01:23:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557822222; cv=none;
        d=google.com; s=arc-20160816;
        b=mw58PHW2QPOk7M/NmojrO7sMCLwAyLyeGBxaQUScpeGf816Ag+5l8cDWlxU1Nelw2U
         w57humJbtXAnsXb0IsOFy534afFd4aMEQkkY2nS9cM4H7PUk74D3dHI35+eg4+9Ua1s7
         NhzSzCzS0tKlczfkzdx2ip/LjnQd09TQxms5QRY9LJzOeM6QAWhmYdvHvfb+pkh2a1YC
         dcqZF2NMM6XdyiVayn5fYz2arLq5T8lMhnZrTl6DAGlbKNrZG3Ca5j/8cE2hvbdsk+Gb
         U+JWa6qNPhaFlR6vhvLhZ1NuY+S/zsxvlWQVRqlm1e6q8bxI4DJIwd/Zu77h2U0X++MQ
         pbJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=kKiJvBWnvz3OUZGCU+wkVsmbgL26LhwAtAT9BoEI3bk=;
        b=z8WwOX2vWLmz6c99sGvPJ06YO2iix/JWDEuieRGg7y5iOjsT4B96NYHUbMEsEie3FB
         eK3YcDcZ+3GZeH+sY4/VLLs70W9EJ6gWP6ITjv71o0gv/wlEBcqzodob0CHTnDLU82tw
         gSTCsjTDG6mvDeroXKAcVDuy4CiH90+D6FcGSrQf6K+tfXFkXz/d+owt8GdHzBjylH+e
         Td/SRuVl6fohofCd66q/rAqPtLVTqRXK2PNIexxDDLOBMnt3pIF6dIO4xiD4B5pKLl4K
         seffBr4UCPQZCWgxOtJ2WL1eoX7cFAs5Zpi80VrCyufJZtFKr5o3z5qNx5oo0US6oM54
         mbYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i204si4348031ybi.490.2019.05.14.01.23.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 01:23:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4E8MHEo003490
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:23:42 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sfpne89ms-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 May 2019 04:23:41 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 14 May 2019 09:23:39 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 14 May 2019 09:23:37 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4E8Na4951970092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 14 May 2019 08:23:36 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 12FFF52051;
	Tue, 14 May 2019 08:23:36 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id A12D952050;
	Tue, 14 May 2019 08:23:34 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Tue, 14 May 2019 11:23:34 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] docs: reorder memory-hotplug documentation
Date: Tue, 14 May 2019 11:23:33 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19051408-4275-0000-0000-000003348A71
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051408-4276-0000-0000-00003844097D
Message-Id: <1557822213-19058-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The "Locking Internals" section of the memory-hotplug documentation is
duplicated in admin-guide and core-api. Drop the admin-guide copy as
locking internals does not belong there.

While on it, move the "Future Work" section to the core-api part.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 Documentation/admin-guide/mm/memory-hotplug.rst | 51 -------------------------
 Documentation/core-api/memory-hotplug.rst       | 11 ++++++
 2 files changed, 11 insertions(+), 51 deletions(-)

diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
index 5c4432c..72090ba 100644
--- a/Documentation/admin-guide/mm/memory-hotplug.rst
+++ b/Documentation/admin-guide/mm/memory-hotplug.rst
@@ -391,54 +391,3 @@ Physical memory remove
 Need more implementation yet....
  - Notification completion of remove works by OS to firmware.
  - Guard from remove if not yet.
-
-
-Locking Internals
-=================
-
-When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
-the device_hotplug_lock should be held to:
-
-- synchronize against online/offline requests (e.g. via sysfs). This way, memory
-  block devices can only be accessed (.online/.state attributes) by user
-  space once memory has been fully added. And when removing memory, we
-  know nobody is in critical sections.
-- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
-
-Especially, there is a possible lock inversion that is avoided using
-device_hotplug_lock when adding memory and user space tries to online that
-memory faster than expected:
-
-- device_online() will first take the device_lock(), followed by
-  mem_hotplug_lock
-- add_memory_resource() will first take the mem_hotplug_lock, followed by
-  the device_lock() (while creating the devices, during bus_add_device()).
-
-As the device is visible to user space before taking the device_lock(), this
-can result in a lock inversion.
-
-onlining/offlining of memory should be done via device_online()/
-device_offline() - to make sure it is properly synchronized to actions
-via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
-
-When adding/removing/onlining/offlining memory or adding/removing
-heterogeneous/device memory, we should always hold the mem_hotplug_lock in
-write mode to serialise memory hotplug (e.g. access to global/zone
-variables).
-
-In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
-mode allows for a quite efficient get_online_mems/put_online_mems
-implementation, so code accessing memory can protect from that memory
-vanishing.
-
-
-Future Work
-===========
-
-  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
-    sysctl or new control file.
-  - showing memory block and physical device relationship.
-  - test and make it better memory offlining.
-  - support HugeTLB page migration and offlining.
-  - memmap removing at memory offline.
-  - physical remove memory.
diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
index de7467e..e08be1c 100644
--- a/Documentation/core-api/memory-hotplug.rst
+++ b/Documentation/core-api/memory-hotplug.rst
@@ -123,3 +123,14 @@ In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
 mode allows for a quite efficient get_online_mems/put_online_mems
 implementation, so code accessing memory can protect from that memory
 vanishing.
+
+Future Work
+===========
+
+  - allowing memory hot-add to ZONE_MOVABLE. maybe we need some switch like
+    sysctl or new control file.
+  - showing memory block and physical device relationship.
+  - test and make it better memory offlining.
+  - support HugeTLB page migration and offlining.
+  - memmap removing at memory offline.
+  - physical remove memory.
-- 
2.7.4

