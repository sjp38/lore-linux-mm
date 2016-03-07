Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id CD66C6B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 13:53:43 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ts10so114274477obc.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 10:53:43 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id oi10si12937785oeb.67.2016.03.07.10.53.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 10:53:43 -0800 (PST)
Received: by mail-oi0-x235.google.com with SMTP id m82so86028418oif.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 10:53:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56DDCAD3.3090106@oracle.com>
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net> <56DD9949.1000106@oracle.com>
 <56DD9E94.70201@oracle.com> <CALCETrXey2_xEXhzjgHtZmf-dLp-9pec===d-8chLxrp8wgRXg@mail.gmail.com>
 <56DDA6FD.4040404@oracle.com> <56DDBE68.6080709@linux.intel.com>
 <CALCETrWPeFsyGsDNyehMpub1QrjZxyWpG_x_2A0yKqROXYfJ5A@mail.gmail.com>
 <56DDC47C.8010206@linux.intel.com> <56DDCAD3.3090106@oracle.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 7 Mar 2016 10:53:23 -0800
Message-ID: <CALCETrVNM7ZcN7WnmLRMDqGrcYXn9xYWJfjMVwFLdiQS63-TcA@mail.gmail.com>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity (ADI)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rob Gardner <rob.gardner@oracle.com>, David Miller <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, chris.hyser@oracle.com, Richard Weinberger <richard@nod.at>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andrew Lutomirski <luto@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Benjamin Segall <bsegall@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Mar 7, 2016 at 10:39 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
> On 03/07/2016 11:12 AM, Dave Hansen wrote:
>>
>> On 03/07/2016 09:53 AM, Andy Lutomirski wrote:
>>>
>>> Also, what am I missing?  Tying these tags to the physical page seems
>>> like a poor design to me.  This seems really awkward to use.
>>
>>
>> Yeah, can you describe the structures that store these things?  Surely
>> the hardware has some kind of lookup tables for them and stores them in
>> memory _somewhere_.
>>
>
> Version tags are tied to virtual addresses, not physical pages.
>
> Where exactly are the tags stored is part of processor architecture and I am
> not privy to that. MMU stores these lookup tables somewhere and uses it to
> authenticate access to virtual addresses. It really is irrelevant to kernel
> how MMU implements access controls as long as we have access to the
> knowledge of how to use it.
>

Can you translate this for people who don't know all the SPARC acronyms?

x86 has an upcoming feature called protection keys.  A page of virtual
memory has a protection key, which is a number from 0 through 16.  The
master copy is in the PTE, i.e. page table entry, which is a
software-managed data structure in memory and is exactly the thing
that Linux calls "pte".  The processor can cache that value in the TLB
(translation lookaside buffer), which is a hardware cache that caches
PTEs.  On access to a page of virtual memory, the processor does a
certain calculation involving a new register called PKRU and the
protection key and may deny access.

Hopefully that description makes sense even to people completely
unfamiliar with x86.

Can you try something similar for SPARC?  So far I'm lost, because
you've said that the ADI tag is associated with a VA, but it has to
match for aliases, and you've mentioned a bunch of acronyms, and I
have no clue what's going on.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
