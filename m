Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBBD5440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 20:22:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v78so6169180pfk.8
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 17:22:35 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w16si7593904plp.765.2017.11.09.17.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 17:22:34 -0800 (PST)
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
 <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
 <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
 <27b55108-1e72-cb3d-d5d8-ffe0238245aa@linux.intel.com>
 <CALCETrXy-K5fKzvjF-Dr6gVpJ+ui4c-GjrT6Oruh5ePvPudPpg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4c8c441e-d65c-fcec-7718-6997bd010971@linux.intel.com>
Date: Thu, 9 Nov 2017 17:22:33 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXy-K5fKzvjF-Dr6gVpJ+ui4c-GjrT6Oruh5ePvPudPpg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/09/2017 05:04 PM, Andy Lutomirski wrote:
> On Thu, Nov 9, 2017 at 4:57 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>> On 11/09/2017 04:53 PM, Andy Lutomirski wrote:
>>>> The KAISER code attempts to "poison" the user portion of the kernel page
>>>> tables.  It detects the entries pages that it wants that it wants to
>>>> poison in two ways:
>>>>  * Looking for addresses >= PAGE_OFFSET
>>>>  * Looking for entries without _PAGE_USER set
>>> What do you mean "poison"?
>>
>> I meant the _PAGE_NX magic that we do in here:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/commit/?h=kaiser-414rc7-20171108&id=c4f7d0819170761f092fcf2327b85b082368e73a
>>
>> to ensure that userspace is unable to run on the kernel PGD.
> 
> Aha, I get it.  Why not just drop the _PAGE_USER check?  You could
> instead warn if you see a _PAGE_USER page that doesn't have the
> correct address for the vsyscall.

The _PAGE_USER check helps us with kernel things that want to create
mappings below PAGE_OFFSET.  The EFI code was the prime user for this.
Without this, we poison the EFI mappings and the EFI calls die.

I think there might have also been a case for the secondary CPU bringup
that needed hacking if we didn't do this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
