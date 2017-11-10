Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CAC82802A5
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 18:04:14 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s2so10463942pge.19
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 15:04:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 207si10327203pfz.5.2017.11.10.15.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 15:04:12 -0800 (PST)
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
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <7ec56785-8e18-4ac8-ebe8-ebdd3ac265da@linux.intel.com>
Date: Fri, 10 Nov 2017 15:04:07 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVoud2iVxAky5UGQkyiDgNiN7Zc-LfahG_1P-x3JQzopg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On 11/10/2017 02:06 PM, Andy Lutomirski wrote:
> On Thu, Nov 9, 2017 at 10:31 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>> On 11/09/2017 06:25 PM, Andy Lutomirski wrote:
>>> Here are two proposals to address this without breaking vsyscalls.
>>>
>>> 1. Set NX on low mappings that are _PAGE_USER.  Don't set NX on high
>>> mappings but, optionally, warn if you see _PAGE_USER on any address
>>> that isn't the vsyscall page.
>>>
>>> 2. Ignore _PAGE_USER entirely and just mark the EFI mm as special so
>>> KAISER doesn't muck with it.
>>
>> These are totally doable.  But, what's the big deal with breaking native
>> vsyscall?  We can still do the emulation so nothing breaks: it is just slow.
> 
> I have nothing against disabling native.  I object to breaking the
> weird binary tracing behavior in the emulation mode, especially if
> it's tangled up with KAISER.  I got all kinds of flak in an earlier
> version of the vsyscall emulation patches when I broke that use case.
> KAISER may get very widely backported -- let's not make changes that
> are already known to break things.

Is the thing that broke a "user mode program that actually looks at the
vsyscall page"?  Like Linus is referring to here:

> http://lkml.kernel.org/r/CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
