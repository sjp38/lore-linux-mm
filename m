Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB706B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 09:55:55 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x21so4750944oie.5
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 06:55:55 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s3si324090oia.221.2018.03.09.06.55.53
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 06:55:54 -0800 (PST)
Date: Fri, 9 Mar 2018 14:55:47 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 0/6] arm64: untag user pointers passed to the kernel
Message-ID: <20180309145547.r25eis5ejy6d6xzu@lakrids.cambridge.arm.com>
References: <cover.1520600533.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1520600533.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

Hi,

[trimming Ccs]

On Fri, Mar 09, 2018 at 03:01:58PM +0100, Andrey Konovalov wrote:
> arm64 has a feature called Top Byte Ignore, which allows to embed pointer
> tags into the top byte of each pointer. Userspace programs (such as
> HWASan, a memory debugging tool [1]) might use this feature and pass
> tagged user pointers to the kernel through syscalls or other interfaces.
> 
> This patch makes a few of the kernel interfaces accept tagged user
> pointers. The kernel is already able to handle user faults with tagged
> pointers and has the untagged_addr macro, which this patchset reuses.
> 
> We're not trying to cover all possible ways the kernel accepts user
> pointers in one patchset, so this one should be considered as a start.
> It would be nice to learn about the interfaces that I missed though.

There are many ways that user pointers can be passed to the kernel, and
I'm not sure that it's feasible to catch them all, especially as user
pointers are often passed in data structures (e.g. iovecs) rather than
direct syscall arguments.

If we *really* want the kernel to support taking tagged addresses, anything
with a __user annotation (or cast to something with a __user annotation)
requires tag removal somewhere in the kernel.

It looks like there are plenty uapi structures and syscalls to look at:

[mark@lakrids:~/src/linux]% git grep __user -- include/uapi | wc -l
216
[mark@lakrids:~/src/linux]% git grep __user | grep SYSCALL_DEFINE | wc -l
308

... in addition to special syscalls like ioctl which multiplex a number
of operations with different arguments, where the tag stripping would
have to occur elsewhere (e.g. in particular drivers).

I also wonder if we ever write any of these pointers back to userspace
memory. If so, we have a nasty ABI problem, since we'll have to marshal
the original tag along with the pointer, to ensure userspace pointer
comparisons continue to work.

Thanks,
Mark.
