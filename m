Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D40C96B027B
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:04:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f6-v6so7917289pgs.13
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:04:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v81-v6si11852695pfi.22.2018.05.15.05.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 15 May 2018 05:04:00 -0700 (PDT)
Date: Tue, 15 May 2018 05:03:55 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180515120355.GE31599@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, May 15, 2018 at 02:41:41PM +0300, Boaz Harrosh wrote:
> That would be very hard. Because that program would:
> - need to be root
> - need to start and pretend it is zus Server with the all mount
>   thread thing, register new filesystem, grab some pmem devices.
> - Mount the said filesystem on said pmem. Create core-pinned ZT threads
>   for all CPUs, start accepting IO.
> - And only then it can start leaking the pointer and do bad things.

All of these things you've done for me by writing zus Server.  All I
have to do now is compromise zus Server.

>   The bad things it can do to the application, not to the Kernel.
>   And as a full filesystem it can do those bad things to the application
>   through the front door directly not needing the mismatch tlb at all.

That's not true.  When I have a TLB entry that points to a page of kernel
ram, I can do almost anything, depending on what the kernel decides to
do with that ram next.  Maybe it's page cache again, in which case I can
affect whatever application happens to get it allocated.  Maybe it's a
kmalloc page next, in which case I can affect any part of the kernel.
Maybe it's a page table, then I can affect any process.

> That said. It brings up a very important point that I wanted to talk about.
> In this design the zuf(Kernel) and the zus(um Server) are part of the distribution.
> I would like to have the zus module be signed by the distro's Kernel's key and
> checked on loadtime. I know there is an effort by Redhat guys to try and sign all
> /sbin/* servers and have Kernel check these. So this is not the first time people
> have thought about that.

You're getting dangerously close to admitting that the entire point
of this exercise is so that you can link non-GPL NetApp code into the
kernel in clear violation of the GPL.
