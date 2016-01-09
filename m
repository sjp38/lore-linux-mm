Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 117EC828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 21:20:19 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id bx1so341693258obb.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 18:20:19 -0800 (PST)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id v85si9807625oif.102.2016.01.08.18.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 18:20:18 -0800 (PST)
Received: by mail-ob0-x235.google.com with SMTP id bx1so341693066obb.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 18:20:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <569053F9.7060002@linux.intel.com>
References: <cover.1452294700.git.luto@kernel.org> <c4125ff6333c97d3ce00e5886b809b7c20594585.1452294700.git.luto@kernel.org>
 <569053F9.7060002@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 8 Jan 2016 18:19:58 -0800
Message-ID: <CALCETrWNPJg_P0Qf0fNR-G-saUqTpoz4X13hj1UHirYzDYq2fA@mail.gmail.com>
Subject: Re: [RFC 13/13] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 8, 2016 at 4:27 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> On 01/08/2016 03:15 PM, Andy Lutomirski wrote:
>> + * The guiding principle of this code is that TLB entries that have
>> + * survived more than a small number of context switches are mostly
>> + * useless, so we don't try very hard not to evict them.
>
> Big ack on that.  The original approach tried to keep track of the full
> 4k worth of possible PCIDs, it also needed an additional cpumask (which
> it dynamically allocated) for where the PCID was active in addition to
> the normal "where has this mm been" mask.

My patch has a similar extra cpumask, but at least I didn't
dynamically allocate it.  I did it because I need a 100% reliable way
to tell whether a given mm has a valid PCID in a cpu's PCID LRU list,
as opposed to just matching due to struct mm reuse or similar.  I also
need the ability to blow away old mappings, which I can do by clearing
the cpumask.  This happens in init_new_context and in
propagate_tlb_flush.

The other way to do it would be to store some kind of generation
counter in the per-cpu list.  I could use a global 64-bit atomic
counter to allocate never-reused mm ids (it's highly unlikely that a
system will run long enough for such a counter to overflow -- it could
only ever be incremented every few ns, giving hundreds of years of
safety), but that's kind of expensive.  I could use a per-cpu
allocator, but 54 bits per cpu is uncomfortably small unless we have
wraparound handling.  We could do 64 bits per cpu for very cheap
counter allocation, but then the "zap the pcid" logic gets much
nastier in that neither the percpu entries nor the per-mm generation
counter entries don't fit in a word any more.  Maybe that's fine.

What we can't do easily is have a per-mm generation counter, because
freeing an mm and reallocating it in the same place needs to reliably
zap the pcid on all CPUs.

Anyway, this problem is clearly solvable, but I haven't thought of a
straightforward solution that doesn't involve rarely-executed code
paths, and that makes me a bit nervous.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
