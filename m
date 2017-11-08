Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A16944403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 01:18:24 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id h6so1365970oia.17
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 22:18:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o70si1443341oik.207.2017.11.07.22.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 22:18:23 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
 <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
 <c5586546-1e7e-0f0f-a8b3-680fadb38dcf@redhat.com>
 <20171107114422.bgnm5k6w2zqjoazc@node.shutemov.name>
 <7fc1641b-361c-2ee2-c510-f7c64d173bf8@redhat.com>
 <20171107131616.342goolaujjsnjge@node.shutemov.name>
 <87vail2tgr.fsf@concordia.ellerman.id.au>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <9d5c86e9-d011-76b4-6357-b6009a201cdb@redhat.com>
Date: Wed, 8 Nov 2017 07:18:17 +0100
MIME-Version: 1.0
In-Reply-To: <87vail2tgr.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kees Cook <keescook@chromium.org>
Cc: linux-arch@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nicholas Piggin <npiggin@gmail.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm <linux-mm@kvack.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 11/08/2017 07:08 AM, Michael Ellerman wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
>> On Tue, Nov 07, 2017 at 02:05:42PM +0100, Florian Weimer wrote:
>>> On 11/07/2017 12:44 PM, Kirill A. Shutemov wrote:
>>>> On Tue, Nov 07, 2017 at 12:26:12PM +0100, Florian Weimer wrote:
>>>>> On 11/07/2017 12:15 PM, Kirill A. Shutemov wrote:
>>>>>
>>>>>>> First of all, using addr and MAP_FIXED to develop our heuristic can
>>>>>>> never really give unchanged ABI. It's an in-band signal. brk() is a
>>>>>>> good example that steadily keeps incrementing address, so depending
>>>>>>> on malloc usage and address space randomization, you will get a brk()
>>>>>>> that ends exactly at 128T, then the next one will be >
>>>>>>> DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.
>>>>>>
>>>>>> No, it won't. You will hit stack first.
>>>>>
>>>>> That's not actually true on POWER in some cases.  See the process maps I
>>>>> posted here:
>>>>>
>>>>>     <https://marc.info/?l=linuxppc-embedded&m=150988538106263&w=2>
>>>>
>>>> Hm? I see that in all three cases the [stack] is the last mapping.
>>>> Do I miss something?
>>>
>>> Hah, I had not noticed.  Occasionally, the order of heap and stack is
>>> reversed.  This happens in approximately 15% of the runs.
>>
>> Heh. I guess ASLR on Power is too fancy :)
> 
> Fancy implies we're doing it on purpose :P
> 
>> That's strange layout. It doesn't give that much (relatively speaking)
>> virtual address space for both stack and heap to grow.
> 
> I'm pretty sure it only happens when you're running an ELF interpreter
> directly, because of Kees patch which changed the logic to load ELF
> interpreters in the mmap region, vs PIE binaries which go to
> ELF_ET_DYN_BASE. (eab09532d400 ("binfmt_elf: use ELF_ET_DYN_BASE only
> for PIE"))

 From that commit:

+                   * There are effectively two types of ET_DYN
+                   * binaries: programs (i.e. PIE: ET_DYN with INTERP)
+                   * and loaders (ET_DYN without INTERP, since they
+                   * _are_ the ELF interpreter). The loaders must

Note that the comment is a bit misleading: statically linked PIE 
binaries are ET_DYN without INTERP, too.

So any oddity which is observable today with an explicitly ld.so 
invocation only will gain more relevance once we get static PIE support 
in user space because it will then affect regular applications, too. 
(Well, statically linked ones.)  In this sense, process layouts which 
cause premature brk failure or insufficient stack allocations are real bugs.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
