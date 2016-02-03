Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 288EA6B0255
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 20:10:19 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id z13so6146371ykd.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 17:10:19 -0800 (PST)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id i127si480086ywc.244.2016.02.02.17.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 17:10:18 -0800 (PST)
Received: by mail-yk0-x232.google.com with SMTP id z7so5984665yka.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 17:10:18 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 2 Feb 2016 17:10:18 -0800
Message-ID: <CAPcyv4jtbsc45r4EzZvLJhqCzB4X4nJmKdpQ8cE46gGkMaRB3w@mail.gmail.com>
Subject: [LSF/MM TOPIC] Persistent memory: pmem as storage device vs pmem as memory
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-block@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

The current state of persistent memory enabling in Linux is that a
physical memory range discovered by a device driver is exposed to the
system as a block device.  That block device has the added property of
being capable of DAX which, at its core, allows converting
storage-device-sectors allocated to a file into pages that can be
mmap()ed, DMAed, etc...

In that quick two sentence summary the impacted kernel sub-systems
span mm, fs, block, and a device-driver.  As a result when a
persistent memory design question arises there are mm, fs, block, and
device-driver specific implications to consider.  Are there existing
persistent memory handling features that could be better handled with
a more "memory" vs "device" perspective?  What are we trading off?
More importantly how do our current interfaces hold up when
considering new features?

For example, how to support DAX in coordination with the BTT (atomic
sector update) driver.  That might require a wider interface than the
current bdev_direct_access() to tell the BTT driver when it is free to
remap the block.  A wider ranging example, there are some that would
like to see high capacity persistent memory as just another level in a
system's volatile-memory hierarchy.  Depending on whom you ask that
pmem tier looks like either page cache extensions, reworked/optimized
swap, or a block-device-cache with DAX capabilities.

For LSF/MM, with all the relevant parties in the room, it would be
useful to share some successes/pain-points of the direction to date
and look at the interfaces/coordination we might need between
sub-systems going forward.  Especially with respect to supporting pmem
as one of a set of new performance differentiated memory types that
need to be considered by the mm sub-system.

---

As a maintainer for libnvdimm I'm interested in participating in the
"Persistent Memory Error Handling" from Jeff.  I'm also interested in
the "HMM (heterogeneous memory manager) and GPU" topic from Jerome as
it relates to mm handling of performance differentiated memory types.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
