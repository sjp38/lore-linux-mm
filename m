Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 584C06B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 15:50:28 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so1505520qcz.33
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 12:50:28 -0800 (PST)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com. [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id h45si9637078qgd.59.2014.12.18.12.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 12:50:27 -0800 (PST)
Received: by mail-qa0-f41.google.com with SMTP id f12so1399941qad.28
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 12:50:26 -0800 (PST)
Date: Thu, 18 Dec 2014 15:50:18 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: [LSF/MM TOPIC] Supporting heterogeneous memory architecture (HMM
 patchset).
Message-ID: <20141218205016.GA3986@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.or

Background

Recent trend in computing is the re-birth of specialized co-processing unit,
mainly in the form of GPU. Specialized DSP/FPGA and GPU are so much faster
than CPU for largely parallel algorithm, and are becoming sufficiently more
flexible to a larger set of problem, that their use keep increasing (from
workstation to compute cluster).

If GPU can crunch so much more number than CPU this is mainly because they
have a way bigger memory bandwidth at their disposal (300GB/s for today high
end next generation should reach 400/600GB/s). The memory bandwidth gap btw
CPU and GPU keeps increasing and will do so for foreseeable future.

In order to simplify use of GPU (both programming and debugging) the industry
is moving toward a common address space between GPU and CPU. There is many
way to implement this.

The first and simpler solution is to use system memory and to pin pages that
are in use by GPU. Obvious drawbacks are that this does not allow use of GPU
local memory except for temporary local GPU variables, nor does it fit well
with memory management as it is locking a lot of pages for unpredictable
amount of time.

The second solution involve hardware such as IOMMU with ATS/PASID that allow
the kernel IOMMU driver to trigger page fault on behalf of a device against
a particular process. Again this solution only allow the use of system memory
but it does solve the pinning problem.

A third solution is to modify linux kernel memory management to become aware
of those new kind of memory and to offer ways to leverage GPU local memory
while preserving current expectation for CPU access (ie CPU can keep accessing
memory but not necessarily directly the GPU memory).

------------------------------------------------------------------------------

Linux kernel changes

HMM (Heterogeneous Memory Management) is a patchset that aim to hook itself
with core memory management and provide a common API for device driver to
allow use of local device memory all this while mirroring a process address
space.

>From CPU point of view, device memory is like a special kind of swap which is
inaccessible and require a page fault to migrate data back to system memory.
HMM intends to provide all common code and to expose a simple driver API.

I would like to discuss design and implementation of HMM on several specific
aspect :

[MM-track]
 - Anonymous memory migration.
 - Re-design CPU page table update to better parallelize with GPU page table
   update. Necessary ? Do-able ? Overhead acceptable ?
 - Pining to GPU memory (blocking CPU access) new syscall ?

[FS-track]
 - Migration of file backed page to remote memory
 - Should each filesystem made be aware of this ?
 - Modification of page cache not enough why ? and possible way to fix it ?
 - DAX (persistant memory) use case ? Do we want to allow migration or not ?


Current patchset take the least disruptive path and does not impact any of
existing workload. But for a better integration and performance some of the
above idea might be necessary and i would like to discuss them. I intend
to briefly present each of them through high level patch to guide discussion.

Of course i am also open to discuss other possible use case for HMM.

Cheers,
Jerome Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
