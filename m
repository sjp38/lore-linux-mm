Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB36628024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:04:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h18so12712881pfi.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 15:04:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor1097651plq.92.2018.01.16.15.04.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 15:04:09 -0800 (PST)
Message-ID: <1516143846.5023.13.camel@slavad-ubuntu-14.04>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
From: Viacheslav Dubeyko <slava@dubeyko.com>
Date: Tue, 16 Jan 2018 15:04:06 -0800
In-Reply-To: <20180116145240.GD30073@bombadil.infradead.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org

On Tue, 2018-01-16 at 06:52 -0800, Matthew Wilcox wrote:
> I see the improvements that Facebook have been making to the nbd driver,
> and I think that's a wonderful thing.  Maybe the outcome of this topic
> is simply: "Shut up, Matthew, this is good enough".
> 
> It's clear that there's an appetite for userspace block devices; not for
> swap devices or the root device, but for accessing data that's stored
> in that silo over there, and I really don't want to bring that entire
> mess of CORBA / Go / Rust / whatever into the kernel to get to it,
> but it would be really handy to present it as a block device.
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

I like the whole idea. But why pipes? What's about shared memory? To
make the pipes seekable sounds like the killing of initial concept.
Usually, we treat pipe as FIFO communication channel. So, to make the
pipe seekable sounds really strange, from my point of view. Maybe, we
need in some new abstraction?

By the way, what's use-case(s) you have in mind for the suggested
approach?

Thanks,
Vyacheslav Dubeyko.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
