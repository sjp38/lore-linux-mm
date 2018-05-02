Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10EFB6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 11:12:54 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id s4-v6so10195709ybg.2
        for <linux-mm@kvack.org>; Wed, 02 May 2018 08:12:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m2si2889949ual.3.2018.05.02.08.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 08:12:53 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
Date: Wed, 2 May 2018 17:12:50 +0200
MIME-Version: 1.0
In-Reply-To: <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-x86_64@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: linuxram@us.ibm.com

On 05/02/2018 04:30 PM, Dave Hansen wrote:
> On 05/02/2018 06:26 AM, Florian Weimer wrote:
>> pkeys support for IBM POWER intends to inherited the access rights of
>> the current thread in signal handlers.  The advantage is that this
>> preserves access to memory regions associated with non-default keys,
>> enabling additional usage scenarios for memory protection keys which
>> currently do not work on x86 due to the unconditional reset to the
>> (configurable) default key in signal handlers.
> 
> What's the usage scenario that does not work?

Here's what I want to do:

Nick Clifton wrote a binutils patch which puts the .got.plt section on 
separate pages.  We allocate a protection key for it, assign it to all 
such sections in the process image, and change the access rights of the 
main thread to disallow writes via that key during process startup.  In 
_dl_fixup, we enable write access to the GOT, update the GOT entry, and 
then disable it again.

This way, we have a pretty safe form of lazy binding, without having to 
resort to BIND_NOW.

With the current kernel behavior on x86, we cannot do that because 
signal handlers revert to the default (deny) access rights, so the GOT 
turns inaccessible.

>> Consequently, this commit updates the x86 implementation to preserve
>> the PKRU register value of the interrupted context in signal handlers.
>> If a key is allocated successfully with the PKEY_ALLOC_SIGNALINHERIT
>> flag, the application can assume this signal inheritance behavior.
> 
> I think this is a pretty gross misuse of the API.  Adding an argument to
> pkey_alloc() is something that folks would assume would impact the key
> being *allocated*, not pkeys behavior across the process as a whole.

 From the application point of view, only the allocated key is 
affecteda??it has specific semantics that were undefined before and varied 
between x86 and POWER.

>> This change does not affect the init_pkru optimization because if the
>> thread's PKRU register is zero due to the init_pkru setting, it will
>> remain zero in the signal handler through inheritance from the
>> interrupted context.
> 
> I think you are right, but it's rather convoluted.  It does:
> 
> 1. Running with PKRU in the init state
> 2. Kernel saves off init-state-PKRU XSAVE signal buffer
> 3. Enter signal, kernel XRSTOR (may) set the init state again
> 4. fpu__clear() does __write_pkru(), takes it out of the init state
> 5. Signal handler runs, exits
> 6. fpu__restore_sig() XRSTOR's the state from #2, taking PKRU back to
>     the init state

Isn't that just the cost of not hard-coding the XSAVE area layout?

> But, about the patch in general:
> 
> I'm not a big fan of doing this in such a PKRU-specific way.  It would
> be nice to have this available for all XSAVE states.  It would also keep
> you from so unnecessarily frobbing with WRPKRU in fpu__clear().  You
> could just clear the PKRU bit in the Requested Feature BitMap (RFBM)
> passed to XRSTOR.  That would be much straightforward and able to be
> more easily extended to more states.

I don't see where I could plug this into the current kernel sources. 
Would you please provide some pointers?

> PKRU is now preserved on signal entry, but not signal exit.  Was that
> intentional?  That seems like odd behavior, and also differs from the
> POWER implementation as I understand it.

Ram, would you please comment?

I think it is a bug not restore the access rights to the former value in 
the interrupted context.  In userspace, we have exactly this problem 
with errno, and it can lead to subtle bugs.

Thanks,
Florian
