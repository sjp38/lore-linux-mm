Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88BDBC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CFEB2087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BHCfXCdC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CFEB2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4E026B0006; Mon,  6 May 2019 19:30:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFE736B0007; Mon,  6 May 2019 19:30:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC6586B0008; Mon,  6 May 2019 19:30:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 68AF96B0006
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:30:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 17so8873907pfi.12
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:30:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=8eIkxvqHvVaScHU2FC2TXtOhyiZOmYmAEq4GJNLP4D8=;
        b=YUE7xNY4xqFk6kFRAypvTPPnE5vbTTRs54ZFnSqOf9aZY+xe0fBCdDJIMdnMR2FuAK
         Cax6ygSumVuOAMJssHH7pVFVYAzf1XaeX6CL4ACT1NkQw4ByjYmwW6Uo8kiTFBIgTl6D
         YS7ZNYZMIMRBw3ZFuV0+uzkwkzvMmhQwMpGy71Fr5LAQNh0SePIJMSLim7X8SNLD7S6S
         S7vYPMC+9ClrWFf9juPpGDMRkFkXYWQoqVlZIS0CAs0eQM9tXT5PsgRe5OjPrGHvDi/q
         f8Gf5G0MPqkUkbAo3hEfnbLBaBE+Xx9xcWO5O9dbu38FLPaTfC6dsi/4krmRaZsdPguX
         1nhQ==
X-Gm-Message-State: APjAAAWCaCPscYo+rvZn5ywskk7kf6o0+FVXDuwOtKx4KKFatLZ97ERt
	Odos9ssKqrrzgsj+QmbqRCUyA+anOish8Ycy7aZY4nQBCFtvv/dEhtYE/kaKntKV/8ghEh13gI9
	KbMJJ6myl9+UbM42wX9oyiKxPKNXJVOlpwbXhfzA7q751Wb3yecRbfI0kMxnAU3DNUA==
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr36100241plb.236.1557185444995;
        Mon, 06 May 2019 16:30:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGbX0vMJNB8fuiC1sj46CBJPNHx9XtHkzWKTEJ1ga+CrrVy8Dr5qVaADlVuqPXDFsWbkF3
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr36100142plb.236.1557185443841;
        Mon, 06 May 2019 16:30:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185443; cv=none;
        d=google.com; s=arc-20160816;
        b=i8XKNDFcvKs6O/4brM08g3uuYsfkowBGs8SmlLPsDE/+lNJgkix7rXwclbcHdKHSkU
         cal7gIFV4eIKlAPSfA1hOK5MmuubMtX9xqVsiCN9KVsm+bbtn+l98JwQhPMPhRlQIvST
         qHCX3ia2pPWhxlmWaJSCg6WC7008dUg8z2EVIjLX6w+T+J0OdrK45eFlddBeoQW/Rf7L
         PRIByP2tApCiXyxxNEkAJHvKoAOqtpcpxwizHCQCB2JPp2F3FhDngrIxLZwMQkkIZJLJ
         4m7dsQudSeEarhULPuZSMsH/QA0Bojrj860YcNZELjLfhdcdNy93QpBEbe9RjThCQNKB
         K2EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=8eIkxvqHvVaScHU2FC2TXtOhyiZOmYmAEq4GJNLP4D8=;
        b=yqZzpouBq1FTCJ7v4H0tx7fGTDxMEkWt2R+szYN9oEmc38yfA6Ao3qvE1niynh2HVn
         H4IuyKnoUK1nEYDk7PAccvy6+nS4QRhSJzFAQf0mPXXWeBxmZMwMo7rEIgxpmRCthRGL
         C/i3NbLPaQFJBikE1MHpzwGRdNvlWPLUUBCtnStu9uX8gpNgwMQlrhvQotUAjlPNwKQd
         A60hbodmv8XeSndhit48vaReCM40Bzbm4rjAyXX/qjbcLi7ql0aGJ5tEnsXMSxtBq5rs
         mzMZv6dEtJdlz0AozG3CyX+UP2jyfCRAjpT0jRx8pJ8hNU0BSCPv/+4vUrxYG5a9trD2
         Anhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BHCfXCdC;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 1si16657196pgx.176.2019.05.06.16.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:30:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=BHCfXCdC;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd0c39f0000>; Mon, 06 May 2019 16:30:39 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 06 May 2019 16:30:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 06 May 2019 16:30:43 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 6 May
 2019 23:30:42 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir
 Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Souptick Joarder
	<jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH 1/5] mm/hmm: Update HMM documentation
Date: Mon, 6 May 2019 16:29:38 -0700
Message-ID: <20190506232942.12623-2-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557185439; bh=8eIkxvqHvVaScHU2FC2TXtOhyiZOmYmAEq4GJNLP4D8=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 X-Originating-IP:X-ClientProxiedBy:Content-Transfer-Encoding:
	 Content-Type;
	b=BHCfXCdCMEMnATb8ROceswf+RLdd7AVuKfz+AfK3qZAAww/Q1APkIlzDzbITSNvKA
	 ORcxD8aYXT+9iAhoKG/0465WmmPcYqJZ/47cbvCm80SdAOeVu7Osr4xUQxzqJaAtn+
	 9l8Ac1pH4AR+oU8QDNOgkg+YOwzmUIRqRZ50nw9FFR0Bpa5ZcvrAYg9ue5zV1V55Y3
	 aHb+CkhVDF8ZZsNThelTq8dCAFoK8b9TUtoR8mUNPp1r/bgz7UOpbV+aU2Cl7efV1c
	 PJkI3Ux8u7SgnZWn4SwJgOco6EuC6UPN8vgnH4b6HraOnlZTc+QQwexus9oDTD8exp
	 u8bLlIVMiDGsQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

Update the HMM documentation to reflect the latest API and make a few minor
wording changes.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 Documentation/vm/hmm.rst | 139 ++++++++++++++++++++-------------------
 1 file changed, 73 insertions(+), 66 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index ec1efa32af3c..7c1e929931a0 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -10,7 +10,7 @@ of this being specialized struct page for such memory (se=
e sections 5 to 7 of
 this document).
=20
 HMM also provides optional helpers for SVM (Share Virtual Memory), i.e.,
-allowing a device to transparently access program address coherently with
+allowing a device to transparently access program addresses coherently wit=
h
 the CPU meaning that any valid pointer on the CPU is also a valid pointer
 for the device. This is becoming mandatory to simplify the use of advanced
 heterogeneous computing where GPU, DSP, or FPGA are used to perform variou=
s
@@ -22,8 +22,8 @@ expose the hardware limitations that are inherent to many=
 platforms. The third
 section gives an overview of the HMM design. The fourth section explains h=
ow
 CPU page-table mirroring works and the purpose of HMM in this context. The
 fifth section deals with how device memory is represented inside the kerne=
l.
-Finally, the last section presents a new migration helper that allows leve=
r-
-aging the device DMA engine.
+Finally, the last section presents a new migration helper that allows
+leveraging the device DMA engine.
=20
 .. contents:: :local:
=20
@@ -39,20 +39,20 @@ address space. I use shared address space to refer to t=
he opposite situation:
 i.e., one in which any application memory region can be used by a device
 transparently.
=20
-Split address space happens because device can only access memory allocate=
d
-through device specific API. This implies that all memory objects in a pro=
gram
+Split address space happens because devices can only access memory allocat=
ed
+through a device specific API. This implies that all memory objects in a p=
rogram
 are not equal from the device point of view which complicates large progra=
ms
 that rely on a wide set of libraries.
=20
-Concretely this means that code that wants to leverage devices like GPUs n=
eeds
-to copy object between generically allocated memory (malloc, mmap private,=
 mmap
+Concretely, this means that code that wants to leverage devices like GPUs =
needs
+to copy objects between generically allocated memory (malloc, mmap private=
, mmap
 share) and memory allocated through the device driver API (this still ends=
 up
 with an mmap but of the device file).
=20
 For flat data sets (array, grid, image, ...) this isn't too hard to achiev=
e but
-complex data sets (list, tree, ...) are hard to get right. Duplicating a
+for complex data sets (list, tree, ...) it's hard to get right. Duplicatin=
g a
 complex data set needs to re-map all the pointer relations between each of=
 its
-elements. This is error prone and program gets harder to debug because of =
the
+elements. This is error prone and programs get harder to debug because of =
the
 duplicate data set and addresses.
=20
 Split address space also means that libraries cannot transparently use dat=
a
@@ -77,12 +77,12 @@ I/O bus, device memory characteristics
=20
 I/O buses cripple shared address spaces due to a few limitations. Most I/O
 buses only allow basic memory access from device to main memory; even cach=
e
-coherency is often optional. Access to device memory from CPU is even more
+coherency is often optional. Access to device memory from a CPU is even mo=
re
 limited. More often than not, it is not cache coherent.
=20
 If we only consider the PCIE bus, then a device can access main memory (of=
ten
 through an IOMMU) and be cache coherent with the CPUs. However, it only al=
lows
-a limited set of atomic operations from device on main memory. This is wor=
se
+a limited set of atomic operations from the device on main memory. This is=
 worse
 in the other direction: the CPU can only access a limited range of the dev=
ice
 memory and cannot perform atomic operations on it. Thus device memory cann=
ot
 be considered the same as regular memory from the kernel point of view.
@@ -93,20 +93,20 @@ The final limitation is latency. Access to main memory =
from the device has an
 order of magnitude higher latency than when the device accesses its own me=
mory.
=20
 Some platforms are developing new I/O buses or additions/modifications to =
PCIE
-to address some of these limitations (OpenCAPI, CCIX). They mainly allow t=
wo-
-way cache coherency between CPU and device and allow all atomic operations=
 the
+to address some of these limitations (OpenCAPI, CCIX). They mainly allow
+two-way cache coherency between CPU and device and allow all atomic operat=
ions the
 architecture supports. Sadly, not all platforms are following this trend a=
nd
 some major architectures are left without hardware solutions to these prob=
lems.
=20
 So for shared address space to make sense, not only must we allow devices =
to
 access any memory but we must also permit any memory to be migrated to dev=
ice
-memory while device is using it (blocking CPU access while it happens).
+memory while the device is using it (blocking CPU access while it happens)=
.
=20
=20
 Shared address space and migration
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-HMM intends to provide two main features. First one is to share the addres=
s
+HMM intends to provide two main features. The first one is to share the ad=
dress
 space by duplicating the CPU page table in the device page table so the sa=
me
 address points to the same physical memory for any valid main memory addre=
ss in
 the process address space.
@@ -121,14 +121,14 @@ why HMM provides helpers to factor out everything tha=
t can be while leaving the
 hardware specific details to the device driver.
=20
 The second mechanism HMM provides is a new kind of ZONE_DEVICE memory that
-allows allocating a struct page for each page of the device memory. Those =
pages
+allows allocating a struct page for each page of device memory. Those page=
s
 are special because the CPU cannot map them. However, they allow migrating
 main memory to device memory using existing migration mechanisms and every=
thing
-looks like a page is swapped out to disk from the CPU point of view. Using=
 a
-struct page gives the easiest and cleanest integration with existing mm me=
ch-
-anisms. Here again, HMM only provides helpers, first to hotplug new ZONE_D=
EVICE
+looks like a page that is swapped out to disk from the CPU point of view. =
Using a
+struct page gives the easiest and cleanest integration with existing mm
+mechanisms. Here again, HMM only provides helpers, first to hotplug new ZO=
NE_DEVICE
 memory for the device memory and second to perform migration. Policy decis=
ions
-of what and when to migrate things is left to the device driver.
+of what and when to migrate is left to the device driver.
=20
 Note that any CPU access to a device page triggers a page fault and a migr=
ation
 back to main memory. For example, when a page backing a given CPU address =
A is
@@ -136,8 +136,8 @@ migrated from a main memory page to a device page, then=
 any CPU access to
 address A triggers a page fault and initiates a migration back to main mem=
ory.
=20
 With these two features, HMM not only allows a device to mirror process ad=
dress
-space and keeping both CPU and device page table synchronized, but also le=
ver-
-ages device memory by migrating the part of the data set that is actively =
being
+space and keeps both CPU and device page tables synchronized, but also
+leverages device memory by migrating the part of the data set that is acti=
vely being
 used by the device.
=20
=20
@@ -151,21 +151,27 @@ registration of an hmm_mirror struct::
=20
  int hmm_mirror_register(struct hmm_mirror *mirror,
                          struct mm_struct *mm);
- int hmm_mirror_register_locked(struct hmm_mirror *mirror,
-                                struct mm_struct *mm);
=20
-
-The locked variant is to be used when the driver is already holding mmap_s=
em
-of the mm in write mode. The mirror struct has a set of callbacks that are=
 used
+The mirror struct has a set of callbacks that are used
 to propagate CPU page tables::
=20
  struct hmm_mirror_ops {
+     /* release() - release hmm_mirror
+      *
+      * @mirror: pointer to struct hmm_mirror
+      *
+      * This is called when the mm_struct is being released.
+      * The callback should make sure no references to the mirror occur
+      * after the callback returns.
+      */
+     void (*release)(struct hmm_mirror *mirror);
+
      /* sync_cpu_device_pagetables() - synchronize page tables
       *
       * @mirror: pointer to struct hmm_mirror
-      * @update_type: type of update that occurred to the CPU page table
-      * @start: virtual start address of the range to update
-      * @end: virtual end address of the range to update
+      * @update: update information (see struct mmu_notifier_range)
+      * Return: -EAGAIN if update.blockable false and callback need to
+      *         block, 0 otherwise.
       *
       * This callback ultimately originates from mmu_notifiers when the CP=
U
       * page table is updated. The device driver must update its page tabl=
e
@@ -176,14 +182,12 @@ to propagate CPU page tables::
       * page tables are completely updated (TLBs flushed, etc); this is a
       * synchronous call.
       */
-      void (*update)(struct hmm_mirror *mirror,
-                     enum hmm_update action,
-                     unsigned long start,
-                     unsigned long end);
+     int (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
+                                       const struct hmm_update *update);
  };
=20
 The device driver must perform the update action to the range (mark range
-read only, or fully unmap, ...). The device must be done with the update b=
efore
+read only, or fully unmap, etc.). The device must complete the update befo=
re
 the driver callback returns.
=20
 When the device driver wants to populate a range of virtual addresses, it =
can
@@ -194,17 +198,18 @@ use either::
=20
 The first one (hmm_range_snapshot()) will only fetch present CPU page tabl=
e
 entries and will not trigger a page fault on missing or non-present entrie=
s.
-The second one does trigger a page fault on missing or read-only entry if =
the
-write parameter is true. Page faults use the generic mm page fault code pa=
th
-just like a CPU page fault.
+The second one does trigger a page fault on missing or read-only entries i=
f
+write access is requested (see below). Page faults use the generic mm page
+fault code path just like a CPU page fault.
=20
 Both functions copy CPU page table entries into their pfns array argument.=
 Each
 entry in that array corresponds to an address in the virtual range. HMM
 provides a set of flags to help the driver identify special CPU page table
 entries.
=20
-Locking with the update() callback is the most important aspect the driver=
 must
-respect in order to keep things properly synchronized. The usage pattern i=
s::
+Locking within the sync_cpu_device_pagetables() callback is the most impor=
tant
+aspect the driver must respect in order to keep things properly synchroniz=
ed.
+The usage pattern is::
=20
  int driver_populate_range(...)
  {
@@ -243,7 +248,7 @@ respect in order to keep things properly synchronized. =
The usage pattern is::
           return ret;
       }
       take_lock(driver->update);
-      if (!range.valid) {
+      if (!hmm_range_valid(&range)) {
           release_lock(driver->update);
           up_read(&mm->mmap_sem);
           goto again;
@@ -258,8 +263,8 @@ respect in order to keep things properly synchronized. =
The usage pattern is::
  }
=20
 The driver->update lock is the same lock that the driver takes inside its
-update() callback. That lock must be held before checking the range.valid
-field to avoid any race with a concurrent CPU page table update.
+sync_cpu_device_pagetables() callback. That lock must be held before calli=
ng
+hmm_range_valid() to avoid any race with a concurrent CPU page table updat=
e.
=20
 HMM implements all this on top of the mmu_notifier API because we wanted a
 simpler API and also to be able to perform optimizations latter on like do=
ing
@@ -279,44 +284,46 @@ concurrently).
 Leverage default_flags and pfn_flags_mask
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-The hmm_range struct has 2 fields default_flags and pfn_flags_mask that al=
lows
-to set fault or snapshot policy for a whole range instead of having to set=
 them
-for each entries in the range.
+The hmm_range struct has 2 fields, default_flags and pfn_flags_mask, that =
specify
+fault or snapshot policy for the whole range instead of having to set them
+for each entry in the pfns array.
+
+For instance, if the device flags for range.flags are::
=20
-For instance if the device flags for device entries are:
-    VALID (1 << 63)
-    WRITE (1 << 62)
+    range.flags[HMM_PFN_VALID] =3D (1 << 63);
+    range.flags[HMM_PFN_WRITE] =3D (1 << 62);
=20
-Now let say that device driver wants to fault with at least read a range t=
hen
-it does set:
-    range->default_flags =3D (1 << 63)
+and the device driver wants pages for a range with at least read permissio=
n,
+it sets::
+
+    range->default_flags =3D (1 << 63);
     range->pfn_flags_mask =3D 0;
=20
-and calls hmm_range_fault() as described above. This will fill fault all p=
age
+and calls hmm_range_fault() as described above. This will fill fault all p=
ages
 in the range with at least read permission.
=20
-Now let say driver wants to do the same except for one page in the range f=
or
-which its want to have write. Now driver set:
+Now let's say the driver wants to do the same except for one page in the r=
ange for
+which it wants to have write permission. Now driver set:
     range->default_flags =3D (1 << 63);
     range->pfn_flags_mask =3D (1 << 62);
     range->pfns[index_of_write] =3D (1 << 62);
=20
-With this HMM will fault in all page with at least read (ie valid) and for=
 the
+With this, HMM will fault in all pages with at least read (i.e., valid) an=
d for the
 address =3D=3D range->start + (index_of_write << PAGE_SHIFT) it will fault=
 with
-write permission ie if the CPU pte does not have write permission set then=
 HMM
+write permission i.e., if the CPU pte does not have write permission set t=
hen HMM
 will call handle_mm_fault().
=20
-Note that HMM will populate the pfns array with write permission for any e=
ntry
-that have write permission within the CPU pte no matter what are the value=
s set
+Note that HMM will populate the pfns array with write permission for any p=
age
+that is mapped with CPU write permission no matter what values are set
 in default_flags or pfn_flags_mask.
=20
=20
 Represent and manage device memory from core kernel point of view
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-Several different designs were tried to support device memory. First one u=
sed
-a device specific data structure to keep information about migrated memory=
 and
-HMM hooked itself in various places of mm code to handle any access to
+Several different designs were tried to support device memory. The first o=
ne
+used a device specific data structure to keep information about migrated m=
emory
+and HMM hooked itself in various places of mm code to handle any access to
 addresses that were backed by device memory. It turns out that this ended =
up
 replicating most of the fields of struct page and also needed many kernel =
code
 paths to be updated to understand this new kind of memory.
@@ -339,7 +346,7 @@ The hmm_devmem_ops is where most of the important thing=
s are::
=20
  struct hmm_devmem_ops {
      void (*free)(struct hmm_devmem *devmem, struct page *page);
-     int (*fault)(struct hmm_devmem *devmem,
+     vm_fault_t (*fault)(struct hmm_devmem *devmem,
                   struct vm_area_struct *vma,
                   unsigned long addr,
                   struct page *page,
@@ -415,9 +422,9 @@ willing to pay to keep all the code simpler.
 Memory cgroup (memcg) and rss accounting
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
-For now device memory is accounted as any regular page in rss counters (ei=
ther
+For now, device memory is accounted as any regular page in rss counters (e=
ither
 anonymous if device page is used for anonymous, file if device page is use=
d for
-file backed page or shmem if device page is used for shared memory). This =
is a
+file backed page, or shmem if device page is used for shared memory). This=
 is a
 deliberate choice to keep existing applications, that might start using de=
vice
 memory without knowing about it, running unimpacted.
=20
@@ -437,6 +444,6 @@ get more experience in how device memory is used and it=
s impact on memory
 resource control.
=20
=20
-Note that device memory can never be pinned by device driver nor through G=
UP
+Note that device memory can never be pinned by a device driver nor through=
 GUP
 and thus such memory is always free upon process exit. Or when last refere=
nce
 is dropped in case of shared memory or file backed memory.
--=20
2.20.1

