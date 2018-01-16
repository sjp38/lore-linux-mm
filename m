Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 39B846B0253
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:52:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q8so6421155pfh.12
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 06:52:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y2si1737582pgo.759.2018.01.16.06.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 06:52:41 -0800 (PST)
Date: Tue, 16 Jan 2018 06:52:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [LSF/MM TOPIC] A high-performance userspace block driver
Message-ID: <20180116145240.GD30073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org


I see the improvements that Facebook have been making to the nbd driver,
and I think that's a wonderful thing.  Maybe the outcome of this topic
is simply: "Shut up, Matthew, this is good enough".

It's clear that there's an appetite for userspace block devices; not for
swap devices or the root device, but for accessing data that's stored
in that silo over there, and I really don't want to bring that entire
mess of CORBA / Go / Rust / whatever into the kernel to get to it,
but it would be really handy to present it as a block device.

I've looked at a few block-driver-in-userspace projects that exist, and
they all seem pretty bad.  For example, one API maps a few gigabytes of
address space and plays games with vm_insert_page() to put page cache
pages into the address space of the client process.  Of course, the TLB
flush overhead of that solution is criminal.

I've looked at pipes, and they're not an awful solution.  We've almost
got enough syscalls to treat other objects as pipes.  The problem is
that they're not seekable.  So essentially you're looking at having one
pipe per outstanding command.  If yu want to make good use of a modern
NAND device, you want a few hundred outstanding commands, and that's a
bit of a shoddy interface.

Right now, I'm leaning towards combining these two approaches; adding
a VM_NOTLB flag so the mmaped bits of the page cache never make it into
the process's address space, so the TLB shootdown can be safely skipped.
Then check it in follow_page_mask() and return the appropriate struct
page.  As long as the userspace process does everything using O_DIRECT,
I think this will work.

It's either that or make pipes seekable ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
