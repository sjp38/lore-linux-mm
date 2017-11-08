Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C06E4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 01:08:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r18so1650633pgu.9
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 22:08:27 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id m17si3129430pfh.214.2017.11.07.22.08.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 07 Nov 2017 22:08:25 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
In-Reply-To: <20171107131616.342goolaujjsnjge@node.shutemov.name>
References: <20171106174707.19f6c495@roar.ozlabs.ibm.com> <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com> <20171106192524.12ea3187@roar.ozlabs.ibm.com> <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com> <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com> <20171107160705.059e0c2b@roar.ozlabs.ibm.com> <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name> <c5586546-1e7e-0f0f-a8b3-680fadb38dcf@redhat.com> <20171107114422.bgnm5k6w2zqjoazc@node.shutemov.name> <7fc1641b-361c-2ee2-c510-f7c64d173bf8@redhat.com> <20171107131616.342goolaujjsnjge@node.shutemov.name>
Date: Wed, 08 Nov 2017 17:08:20 +1100
Message-ID: <87vail2tgr.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Florian Weimer <fweimer@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: linux-arch@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Nov 07, 2017 at 02:05:42PM +0100, Florian Weimer wrote:
>> On 11/07/2017 12:44 PM, Kirill A. Shutemov wrote:
>> > On Tue, Nov 07, 2017 at 12:26:12PM +0100, Florian Weimer wrote:
>> > > On 11/07/2017 12:15 PM, Kirill A. Shutemov wrote:
>> > > 
>> > > > > First of all, using addr and MAP_FIXED to develop our heuristic can
>> > > > > never really give unchanged ABI. It's an in-band signal. brk() is a
>> > > > > good example that steadily keeps incrementing address, so depending
>> > > > > on malloc usage and address space randomization, you will get a brk()
>> > > > > that ends exactly at 128T, then the next one will be >
>> > > > > DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.
>> > > > 
>> > > > No, it won't. You will hit stack first.
>> > > 
>> > > That's not actually true on POWER in some cases.  See the process maps I
>> > > posted here:
>> > > 
>> > >    <https://marc.info/?l=linuxppc-embedded&m=150988538106263&w=2>
>> > 
>> > Hm? I see that in all three cases the [stack] is the last mapping.
>> > Do I miss something?
>> 
>> Hah, I had not noticed.  Occasionally, the order of heap and stack is
>> reversed.  This happens in approximately 15% of the runs.
>
> Heh. I guess ASLR on Power is too fancy :)

Fancy implies we're doing it on purpose :P

> That's strange layout. It doesn't give that much (relatively speaking)
> virtual address space for both stack and heap to grow.

I'm pretty sure it only happens when you're running an ELF interpreter
directly, because of Kees patch which changed the logic to load ELF
interpreters in the mmap region, vs PIE binaries which go to
ELF_ET_DYN_BASE. (eab09532d400 ("binfmt_elf: use ELF_ET_DYN_BASE only
for PIE"))

It only happens with ASLR enabled. Presumably it's because our brk_rnd()
is overly aggressive in this case, it randomises up to 1GB, and the heap
jumps over the stack.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
