Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4196B0261
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:28:58 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so181500365pfb.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:28:58 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id xe5si1424148pab.215.2016.07.11.07.28.56
        for <linux-mm@kvack.org>;
        Mon, 11 Jul 2016 07:28:56 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <20160711073534.GA19615@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5783AD25.8020303@sr71.net>
Date: Mon, 11 Jul 2016 07:28:53 -0700
MIME-Version: 1.0
In-Reply-To: <20160711073534.GA19615@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@amacapital.net>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 07/11/2016 12:35 AM, Ingo Molnar wrote:
> * Andy Lutomirski <luto@amacapital.net> wrote:
> mprotect_pkey()'s effects are per MM, but the system calls related to managing the 
> keys (alloc/free/get/set) are fundamentally per CPU.
> 
> Here's an example of how this could matter to applications:
> 
>  - 'writer thread' gets a RW- key into index 1 to a specific data area
>  - a pool of 'reader threads' may get the same pkey index 1 R-- to read the data 
>    area.
> 
> Same page tables, same index, two protections and two purposes.
> 
> With a global, per MM allocation of keys we'd have to use two indices: index 1 and 2.

I'm not sure how this would work.  A piece of data mapped at only one
virtual address can have only one key associated with it.  For a data
area, you would need to indicate between threads which key they needed
in order to access the data.  Both threads need to agree on the virtual
address *and* the key used for access.

Remember, PKRU is just a *bitmap*.  The only place keys are stored is in
the page tables.

Here's how this ends up looking in practice when we have an initializer,
a reader and a writer:

	/* allocator: */
	pkey = pkey_alloc();
	data = mmap(PAGE_SIZE, PROT_NONE, ...);
	pkey_mprotect(data, PROT_WRITE|PROT_READ, pkey);
	metadata[data].pkey = pkey;

	/* reader */
	pkey_set(metadata[data].pkey, PKEY_DENY_WRITE);
	readerfoo = *data;
	pkey_set(metadata[data].pkey, PKEY_DENY_WRITE|ACCESS);

	/* writer */
	pkey_set(metadata[data].pkey, 0); /* 0 == deny nothing */
	*data = bar;
	pkey_set(metadata[data].pkey, PKEY_DENY_WRITE|ACCESS);


I'm also not sure what the indexes are that you're referring to.

> Depending on how scarce the index space turns out to be making the key indices per 
> thread is probably the right model.

Yeah, I'm totally confused about what you mean by indexes.

>> There are still two issues that I think we need to address, though:
>>
>> 1. Signal delivery shouldn't unconditionally clear PKRU.  That's what
>> the current patches do, and it's unsafe.  I'd rather set PKRU to the
>> maximally locked down state on signal delivery (except for the
>> PROT_EXEC key), although that might cause its own set of problems.
> 
> Right now the historic pattern for signal handlers is that they safely and 
> transparently stack on top of existing FPU related resources and do a save/restore 
> of them. In that sense saving+clearing+restoring the pkeys state would be the 
> correct approach that follows that pattern. There are two extra considerations:
> 
> - If we think of pkeys as a temporary register that can be used to access/unaccess 
>   normally unaccessible memory regions then this makes sense, in fact it's more 
>   secure: signal handlers cannot accidentally stomp on an encryption key or on a
>   database area, unless they intentionally gain access to them.
> 
> - If we think of pkeys as permanent memory mappings that enhance existing MM
>   permissions then it would be correct to let them leak into signal handler state. 
>   The globl true-PROT_EXEC key would fall into this category.
> 
> So I agree, mostly: the correct approach is to save+clear+restore the first 14 
> pkey indices, and to leave alone the two 'global' indices.

The current scheme is the most permissive, but it has an important
property: it's the most _flexible_.  You can implement almost any scheme
you want in userspace on top of it.  The first userspace instruction of
the handler could easily be WRKRU to fully lock down access in whatever
scheme a program wants.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
