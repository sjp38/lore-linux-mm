Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74A886B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 12:57:10 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y1so2724684iti.7
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 09:57:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 22sor1183747itj.105.2018.03.09.09.57.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 09:57:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180309155829.2fzgevhsxj3gnyly@armageddon.cambridge.arm.com>
References: <cover.1520600533.git.andreyknvl@google.com> <d681c0dee907ee5cc55d313e2f843237c6087bf0.1520600533.git.andreyknvl@google.com>
 <20180309150309.4sue2zj6teehx6e3@lakrids.cambridge.arm.com> <20180309155829.2fzgevhsxj3gnyly@armageddon.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 9 Mar 2018 18:57:07 +0100
Message-ID: <CAAeHK+zuooh=of9GCLd4UF3TCpFsxd1ECzVhKZ-W7BEG6=rtsA@mail.gmail.com>
Subject: Re: [RFC PATCH 2/6] arm64: untag user addresses in copy_from_user and others
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Fri, Mar 9, 2018 at 4:58 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Fri, Mar 09, 2018 at 03:03:09PM +0000, Mark Rutland wrote:
>> On Fri, Mar 09, 2018 at 03:02:00PM +0100, Andrey Konovalov wrote:
>> > copy_from_user (and a few other similar functions) are used to copy data
>> > from user memory into the kernel memory or vice versa. Since a user can
>> > provided a tagged pointer to one of the syscalls that use copy_from_user,
>> > we need to correctly handle such pointers.
>>
>> I don't think it makes sense to do this in the low-level uaccess
>> primitives, given we're going to have to untag pointers before common
>> code can use them, e.g. for comparisons against TASK_SIZE or
>> user_addr_max().
>>
>> I think we'll end up with subtle bugs unless we consistently untag
>> pointers before we get to uaccess primitives. If core code does untag
>> pointers, then it's redundant to do so here.

There are two different approaches to untagging the user pointers that I see:

1. Untag user pointers right after they are passed to the kernel.

While this might be possible for pointers that are passed to syscalls
as arguments (Catalin's "hack"), this leaves user pointers, that are
embedded into for example structs that are passed to the kernel. Since
there's no specification of the interface between user space and the
kernel, different kernel parts handle user pointers differently and I
don't see an easy way to cover them all.

2. Untag user pointers where they are used in the kernel.

Although there's no specification on the interface between the user
space and the kernel, the kernel still has to use one of a few
specific ways to access user data (copy_from_user, etc.). So the idea
here is to add untagging into them. This patchset mostly takes this
approach (with the exception of memory subsystem syscalls).

If there's a better approach, I'm open to suggestions.
