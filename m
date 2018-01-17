Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07F10280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:49:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so3255524wmh.4
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:49:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 90sor295155wrp.23.2018.01.16.18.49.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 18:49:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180116145240.GD30073@bombadil.infradead.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
From: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 17 Jan 2018 10:49:24 +0800
Message-ID: <CACVXFVPqJ6xYq31Ve5tXCKiNne_S1ve8csA+j_wCPnnZCPahvg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>

On Tue, Jan 16, 2018 at 10:52 PM, Matthew Wilcox <willy@infradead.org> wrote:
>
> I see the improvements that Facebook have been making to the nbd driver,
> and I think that's a wonderful thing.  Maybe the outcome of this topic
> is simply: "Shut up, Matthew, this is good enough".
>
> It's clear that there's an appetite for userspace block devices; not for
> swap devices or the root device, but for accessing data that's stored
> in that silo over there, and I really don't want to bring that entire
> mess of CORBA / Go / Rust / whatever into the kernel to get to it,
> but it would be really handy to present it as a block device.

I like the idea, and one line code of Python/... may need thousands
of C code to be done in kernel.

>
> I've looked at a few block-driver-in-userspace projects that exist, and
> they all seem pretty bad.  For example, one API maps a few gigabytes of
> address space and plays games with vm_insert_page() to put page cache
> pages into the address space of the client process.  Of course, the TLB
> flush overhead of that solution is criminal.
>
> I've looked at pipes, and they're not an awful solution.  We've almost
> got enough syscalls to treat other objects as pipes.  The problem is
> that they're not seekable.  So essentially you're looking at having one
> pipe per outstanding command.  If yu want to make good use of a modern
> NAND device, you want a few hundred outstanding commands, and that's a
> bit of a shoddy interface.
>
> Right now, I'm leaning towards combining these two approaches; adding
> a VM_NOTLB flag so the mmaped bits of the page cache never make it into
> the process's address space, so the TLB shootdown can be safely skipped.
> Then check it in follow_page_mask() and return the appropriate struct
> page.  As long as the userspace process does everything using O_DIRECT,
> I think this will work.
>
> It's either that or make pipes seekable ...

Userfaultfd might be another choice:

1) map the block LBA space into a range of process vm space

2) when READ/WRITE req comes, convert it to page fault on the
mapped range, and let userland to take control of it, and meantime
kernel req context is slept

3) IO req context in kernel side is waken up after userspace completed
the IO request via userfaultfd

4) kernel side continue to complete the IO, such as copying page from
storage range to req(bio) pages.

Seems READ should be fine since it is very similar with the use case
of QEMU postcopy live migration, WRITE can be a bit different, and
maybe need some change on userfaultfd.

-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
