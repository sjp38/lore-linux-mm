Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75BD86B0007
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:45:40 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id x1-v6so14434369itb.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:45:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j81-v6sor7963746ioj.150.2018.04.25.07.45.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 07:45:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419093306.rn5bz264nxsn7d7c@node.shutemov.name>
References: <cover.1524077494.git.andreyknvl@google.com> <20180419093306.rn5bz264nxsn7d7c@node.shutemov.name>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 25 Apr 2018 16:45:37 +0200
Message-ID: <CAAeHK+yb-U3h0666i3u3fF3=8XVcZUo1nxZ5CnOd9oUiDFP=Ng@mail.gmail.com>
Subject: Re: [PATCH 0/6] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Thu, Apr 19, 2018 at 11:33 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Apr 18, 2018 at 08:53:09PM +0200, Andrey Konovalov wrote:
>> Hi!
>>
>> arm64 has a feature called Top Byte Ignore, which allows to embed pointer
>> tags into the top byte of each pointer. Userspace programs (such as
>> HWASan, a memory debugging tool [1]) might use this feature and pass
>> tagged user pointers to the kernel through syscalls or other interfaces.
>>
>> This patch makes a few of the kernel interfaces accept tagged user
>> pointers. The kernel is already able to handle user faults with tagged
>> pointers and has the untagged_addr macro, which this patchset reuses.
>>
>> We're not trying to cover all possible ways the kernel accepts user
>> pointers in one patchset, so this one should be considered as a start.
>
> How many changes do you anticipate?
>
> This patchset looks small and reasonable, but I see a potential to become a
> boilerplate. Would we need to change every driver which implements ioctl()
> to strip these bits?

I've replied to somewhat similar question in one of the previous
versions of the patchset.

"""
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
"""

So if we go with the first way, we'll need to go through every syscall
and ioctl handler, which doesn't seem feasible.
