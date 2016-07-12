Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 45A326B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:39:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so38602933pfb.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:39:11 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id w69si4527353pfd.81.2016.07.12.08.39.09
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 08:39:09 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <20160711073534.GA19615@gmail.com> <5783AD25.8020303@sr71.net>
 <20160712071305.GA13444@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57850F1B.4080306@sr71.net>
Date: Tue, 12 Jul 2016 08:39:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160712071305.GA13444@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 07/12/2016 12:13 AM, Ingo Molnar wrote:
>> > Remember, PKRU is just a *bitmap*.  The only place keys are stored is in the 
>> > page tables.
> A pkey is an index *and* a protection mask. So by representing it as a bitmask we 
> lose per thread information. This is what I meant by 'incomplete shadowing' - for 
> example the debug code couldn't work: if we cleared a pkey in a task we wouldn't 
> know what to restore it to with the current data structures, right?

Right.  I actually have some code to do the shadowing that I wrote to
explore how to do different PKRU values in signal handlers.  The code
only shadowed the keys that were currently allocated, and used the
(mm-wide) allocation map to figure that out.  It did not have a separate
per-thread concept of which parts of PKRU need to be shadowed.

It essentially populated the shadow value on all pkru_set() calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
