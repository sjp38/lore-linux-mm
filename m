Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A76946B03A3
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:14:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n129so76760229pga.22
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:14:01 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id 5si5549279plc.165.2017.04.07.09.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 09:14:00 -0700 (PDT)
Date: Fri, 07 Apr 2017 09:09:27 -0700
In-Reply-To: <20170407155945.7lyapjbwacg3ikw6@node.shutemov.name>
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com> <20170406140106.78087-9-kirill.shutemov@linux.intel.com> <8d68093b-670a-7d7e-2216-bf64b19c7a48@linux.vnet.ibm.com> <20170407155945.7lyapjbwacg3ikw6@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above 47-bits
From: hpa@zytor.com
Message-ID: <2A1F4E56-9374-4C41-876C-6E6CBD16DB22@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <dsafonov@virtuozzo.com>

On April 7, 2017 8:59:45 AM PDT, "Kirill A=2E Shutemov" <kirill@shutemov=2E=
name> wrote:
>On Fri, Apr 07, 2017 at 07:05:26PM +0530, Anshuman Khandual wrote:
>> On 04/06/2017 07:31 PM, Kirill A=2E Shutemov wrote:
>> > On x86, 5-level paging enables 56-bit userspace virtual address
>space=2E
>> > Not all user space is ready to handle wide addresses=2E It's known
>that
>> > at least some JIT compilers use higher bits in pointers to encode
>their
>> > information=2E It collides with valid pointers with 5-level paging
>and
>> > leads to crashes=2E
>> >=20
>> > To mitigate this, we are not going to allocate virtual address
>space
>> > above 47-bit by default=2E
>>=20
>> I am wondering if the commitment of virtual space range to the
>> user space is kind of an API which needs to be maintained there
>> after=2E If that is the case then we need to have some plans when
>> increasing it from the current level=2E
>
>I don't think we should ever enable full address space for all
>applications=2E There's no point=2E
>
>/bin/true doesn't need more than 64TB of virtual memory=2E
>And I hope never will=2E
>
>By increasing virtual address space for everybody we will pay (assuming
>current page table format) at least one extra page per process for
>moving
>stack at very end of address space=2E
>
>Yes, you can gain something in security by having more bits for ASLR,
>but
>I don't think it worth the cost=2E
>
>> Will those JIT compilers keep using the higher bit positions of
>> the pointer for ever ? Then it will limit the ability of the
>> kernel to expand the virtual address range later as well=2E I am
>> not saying we should not increase till the extent it does not
>> affect any *known* user but then we should not increase twice
>> for now, create the hint mechanism to be passed from the user
>> to avail beyond that (which will settle in as a expectation
>> from the kernel later on)=2E Do the same thing again while
>> expanding the address range next time around=2E I think we need
>> to have a plan for this and particularly around 'hint' mechanism
>> and whether it should be decided per mmap() request or at the
>> task level=2E
>
>I think the reasonable way for an application to claim it's 63-bit
>clean
>is to make allocations with (void *)-1 as hint address=2E

You realize that people have said that about just about every memory thres=
hold from 64K onward?
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
