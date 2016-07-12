Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 147AB6B0265
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:13:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so6575067wma.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:13:11 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id 72si1752304wmm.73.2016.07.12.00.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 00:13:09 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id i5so1146521wmg.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:13:09 -0700 (PDT)
Date: Tue, 12 Jul 2016 09:13:05 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160712071305.GA13444@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com>
 <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <20160711073534.GA19615@gmail.com>
 <5783AD25.8020303@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5783AD25.8020303@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>


* Dave Hansen <dave@sr71.net> wrote:

> On 07/11/2016 12:35 AM, Ingo Molnar wrote:
> > * Andy Lutomirski <luto@amacapital.net> wrote:
> > mprotect_pkey()'s effects are per MM, but the system calls related to managing the 
> > keys (alloc/free/get/set) are fundamentally per CPU.
> > 
> > Here's an example of how this could matter to applications:
> > 
> >  - 'writer thread' gets a RW- key into index 1 to a specific data area
> >  - a pool of 'reader threads' may get the same pkey index 1 R-- to read the data 
> >    area.
> > 
> > Same page tables, same index, two protections and two purposes.
> > 
> > With a global, per MM allocation of keys we'd have to use two indices: index 1 and 2.
> 
> I'm not sure how this would work.  A piece of data mapped at only one virtual 
> address can have only one key associated with it.

Yeah, indeed, got myself confused there - but the actual protection bits are per 
CPU (per task).

> Remember, PKRU is just a *bitmap*.  The only place keys are stored is in the 
> page tables.

A pkey is an index *and* a protection mask. So by representing it as a bitmask we 
lose per thread information. This is what I meant by 'incomplete shadowing' - for 
example the debug code couldn't work: if we cleared a pkey in a task we wouldn't 
know what to restore it to with the current data structures, right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
