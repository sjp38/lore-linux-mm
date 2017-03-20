Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A72246B0388
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 14:08:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n11so104380392pfg.7
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 11:08:59 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id x6si13023941pfi.115.2017.03.20.11.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 11:08:58 -0700 (PDT)
Date: Mon, 20 Mar 2017 11:08:41 -0700
In-Reply-To: <CAFZ8GQx2JmEECQHEsKOymP8nDv9YHfLgcK80R75gM+r-1q-owQ@mail.gmail.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com> <20170313055020.69655-27-kirill.shutemov@linux.intel.com> <87a88jg571.fsf@skywalker.in.ibm.com> <20170317175714.3bvpdylaaudf4ig2@node.shutemov.name> <877f3lfzdo.fsf@skywalker.in.ibm.com> <CAFZ8GQx2JmEECQHEsKOymP8nDv9YHfLgcK80R75gM+r-1q-owQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above 47-bits
From: hpa@zytor.com
Message-ID: <95631D05-2CA2-4967-A29E-DB396C76F62D@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On March 19, 2017 1:26:58 AM PDT, "Kirill A=2E Shutemov" <kirill@shutemov=
=2Ename> wrote:
>On Mar 19, 2017 09:25, "Aneesh Kumar K=2EV"
><aneesh=2Ekumar@linux=2Evnet=2Eibm=2Ecom>
>wrote:
>
>"Kirill A=2E Shutemov" <kirill@shutemov=2Ename> writes:
>
>> On Fri, Mar 17, 2017 at 11:23:54PM +0530, Aneesh Kumar K=2EV wrote:
>>> "Kirill A=2E Shutemov" <kirill=2Eshutemov@linux=2Eintel=2Ecom> writes:
>>>
>>> > On x86, 5-level paging enables 56-bit userspace virtual address
>space=2E
>>> > Not all user space is ready to handle wide addresses=2E It's known
>that
>>> > at least some JIT compilers use higher bits in pointers to encode
>their
>>> > information=2E It collides with valid pointers with 5-level paging
>and
>>> > leads to crashes=2E
>>> >
>>> > To mitigate this, we are not going to allocate virtual address
>space
>>> > above 47-bit by default=2E
>>> >
>>> > But userspace can ask for allocation from full address space by
>>> > specifying hint address (with or without MAP_FIXED) above 47-bits=2E
>>> >
>>> > If hint address set above 47-bit, but MAP_FIXED is not specified,
>we
>try
>>> > to look for unmapped area by specified address=2E If it's already
>>> > occupied, we look for unmapped area in *full* address space,
>rather
>than
>>> > from 47-bit window=2E
>>> >
>>> > This approach helps to easily make application's memory allocator
>aware
>>> > about large address space without manually tracking allocated
>virtual
>>> > address space=2E
>>> >
>>>
>>> So if I have done a successful mmap which returned > 128TB what
>should a
>>> following mmap(0,=2E=2E=2E) return ? Should that now search the *full*
>address
>>> space or below 128TB ?
>>
>> No, I don't think so=2E And this implementation doesn't do this=2E
>>
>> It's safer this way: if an library can't handle high addresses, it's
>> better not to switch it automagically to full address space if other
>part
>> of the process requested high address=2E
>>
>
>What is the epectation when the hint addr is below 128TB but addr + len
>>
>128TB ? Should such mmap request fail ?
>
>
>Yes, I believe so=2E

This *better* be conditional on some kind of settable limit=2E  Having a b=
arrier in the middle of the address space for no apparent reason to "clean"=
 software is insane=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
