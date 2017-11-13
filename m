Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3688A6B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 16:07:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s28so10471603pfg.6
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 13:07:07 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j33si14762315pld.56.2017.11.13.13.07.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 13:07:05 -0800 (PST)
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
 <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com>
 <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
 <27b55108-1e72-cb3d-d5d8-ffe0238245aa@linux.intel.com>
 <CALCETrXy-K5fKzvjF-Dr6gVpJ+ui4c-GjrT6Oruh5ePvPudPpg@mail.gmail.com>
 <4c8c441e-d65c-fcec-7718-6997bd010971@linux.intel.com>
 <CALCETrXzmtoS-vHF3AHVZtuf0LsDsFLDUMSk0TjT0eOfGHjHkQ@mail.gmail.com>
 <f5483db4-018c-3474-0819-65336cacdb1d@linux.intel.com>
 <CALCETrVoud2iVxAky5UGQkyiDgNiN7Zc-LfahG_1P-x3JQzopg@mail.gmail.com>
 <7ec56785-8e18-4ac8-ebe8-ebdd3ac265da@linux.intel.com>
 <CALCETrWyagW0YV_-4xhiCxrxDBXTW7MBfZbSDbMY_mBYtsPRaA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <8b23c090-f7c3-5110-011b-07e5131eb996@linux.intel.com>
Date: Mon, 13 Nov 2017 13:07:03 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrWyagW0YV_-4xhiCxrxDBXTW7MBfZbSDbMY_mBYtsPRaA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/12/2017 07:52 PM, Andy Lutomirski wrote:
> On Fri, Nov 10, 2017 at 3:04 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> On 11/10/2017 02:06 PM, Andy Lutomirski wrote:
>>> I have nothing against disabling native.  I object to breaking the
>>> weird binary tracing behavior in the emulation mode, especially if
>>> it's tangled up with KAISER.  I got all kinds of flak in an earlier
>>> version of the vsyscall emulation patches when I broke that use case.
>>> KAISER may get very widely backported -- let's not make changes that
>>> are already known to break things.
>>
>> Is the thing that broke a "user mode program that actually looks at the
>> vsyscall page"?  Like Linus is referring to here:
>>
> Yes.  But I disagree with Linus.  I think it would be perfectly
> reasonable to enable KAISER and to use a tool like pin on a legacy
> binary from some enterprise distribution.  I bet there are lots of
> enterprise distributions that are still supported that use vsyscalls.

All we need to do in the end here is to re-set _PAGE_USER on the user
page table PGD that is used by the vsyscall page.  We should be able to
do that with a line or two of code in kaiser_init().  We can do it
conditionally on when the VDSO is not compile-time disabled.

I can do this as a follow-on patch, or as the last one in the KAISER
series and leave it up to our esteemed maintainers to decide whether
they want to do it or not.  Sound good?

Are there any userspace tests around that I can use for this, or will I
have to cook something up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
