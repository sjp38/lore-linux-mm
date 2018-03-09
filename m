Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 477E26B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 10:58:36 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id y8so5204609ote.15
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 07:58:36 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f2si373176oth.315.2018.03.09.07.58.35
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 07:58:35 -0800 (PST)
Date: Fri, 9 Mar 2018 15:58:29 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 2/6] arm64: untag user addresses in copy_from_user
 and others
Message-ID: <20180309155829.2fzgevhsxj3gnyly@armageddon.cambridge.arm.com>
References: <cover.1520600533.git.andreyknvl@google.com>
 <d681c0dee907ee5cc55d313e2f843237c6087bf0.1520600533.git.andreyknvl@google.com>
 <20180309150309.4sue2zj6teehx6e3@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180309150309.4sue2zj6teehx6e3@lakrids.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Fri, Mar 09, 2018 at 03:03:09PM +0000, Mark Rutland wrote:
> On Fri, Mar 09, 2018 at 03:02:00PM +0100, Andrey Konovalov wrote:
> > copy_from_user (and a few other similar functions) are used to copy data
> > from user memory into the kernel memory or vice versa. Since a user can
> > provided a tagged pointer to one of the syscalls that use copy_from_user,
> > we need to correctly handle such pointers.
> 
> I don't think it makes sense to do this in the low-level uaccess
> primitives, given we're going to have to untag pointers before common
> code can use them, e.g. for comparisons against TASK_SIZE or
> user_addr_max().
> 
> I think we'll end up with subtle bugs unless we consistently untag
> pointers before we get to uaccess primitives. If core code does untag
> pointers, then it's redundant to do so here.

A quick "hack" below clears the tag on syscall entry (where the argument
is a __user pointer). However, we still have cases in core code where
the pointer is read from a structure or even passed as an unsigned long
as part of a command + argument (like in ptrace).

The "hack":

---------------------------------8<--------------------------
