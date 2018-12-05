Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA4D6B76F5
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 18:49:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so12159595pgv.19
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 15:49:45 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p12si20384486plk.77.2018.12.05.15.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 15:49:44 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
Date: Wed, 5 Dec 2018 15:49:43 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, alison.schofield@intel.com, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>
Cc: David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On 12/4/18 11:19 AM, Andy Lutomirski wrote:
> I'm not Thomas, but I think it's the wrong direction.  As it stands,
> encrypt_mprotect() is an incomplete version of mprotect() (since it's
> missing the protection key support),

I thought about this when I added mprotect_pkey().  We start with:

	mprotect(addr, len, prot);

then

	mprotect_pkey(addr, len, prot);

then

	mprotect_pkey_encrypt(addr, len, prot, key);

That doesn't scale because we eventually have
mprotect_and_a_history_of_mm_features(). :)

What I was hoping to see was them do this (apologies for the horrible
indentation:

	ptr = mmap(..., PROT_NONE);
	mprotect_pkey(   addr, len, PROT_NONE, pkey);
	mprotect_encrypt(addr, len, PROT_NONE, keyid);
	mprotect(        addr, len, real_prot);

The point is that you *can* stack these things and don't have to have an
mprotect_kitchen_sink() if you use PROT_NONE for intermediate
permissions during setup.

> and it's also functionally just MADV_DONTNEED.  In other words, the
> sole user-visible effect appears to be that the existing pages are
> blown away.  The fact that it changes the key in use doesn't seem
> terribly useful, since it's anonymous memory,

It's functionally MADV_DONTNEED, plus a future promise that your writes
will never show up as plaintext on the DIMM.

We also haven't settled on the file-backed properties.  For file-backed,
my hope was that you could do:

	ptr = mmap(fd, size, prot);
	printf("ciphertext: %x\n", *ptr);
	mprotect_encrypt(ptr, len, prot, keyid);
	printf("plaintext: %x\n", *ptr);

> and the most secure choice is to use CPU-managed keying, which
> appears to be the default anyway on TME systems.  It also has totally
> unclear semantics WRT swap, and, off the top of my head, it looks
> like it may have serious cache-coherency issues and like swapping the
> pages might corrupt them, both because there are no flushes and
> because the direct-map alias looks like it will use the default key
> and therefore appear to contain the wrong data.

I think we fleshed this out on IRC a bit, but the other part of the
implementation is described here: https://lwn.net/Articles/758313/, and
contains a direct map per keyid.  When you do phys_to_virt() and
friends, you get the correct, decrypted view direct map which is
appropriate for the physical page.  And, yes, this has very
consequential security implications.

> I would propose a very different direction: don't try to support MKTME
> at all for anonymous memory, and instead figure out the important use
> cases and support them directly.  The use cases that I can think of
> off the top of my head are:
> 
> 1. pmem.  This should probably use a very different API.
> 
> 2. Some kind of VM hardening, where a VM's memory can be protected a
> little tiny bit from the main kernel.  But I don't see why this is any
> better than XPO (eXclusive Page-frame Ownership), which brings to
> mind:

The XPO approach is "fun", and would certainly be a way to keep the
direct map from being exploited to get access to plain-text mappings of
ciphertext.

But, it also has massive performance implications and we didn't quite
want to go there quite yet.

> The main implementation concern I have with this patch set is cache
> coherency and handling of the direct map.  Unless I missed something,
> you're not doing anything about the direct map, which means that you
> have RW aliases of the same memory with different keys.  For use case
> #2, this probably means that you need to either get rid of the direct
> map and make get_user_pages() fail, or you need to change the key on
> the direct map as well, probably using the pageattr.c code.

The current, public hardware spec has a description of what's required
to maintain cache coherency.  Basically, you can keep as many mappings
of a physical page as you want, but only write to one mapping at a time,
and clflush the old one when you want to write to a new one.

> As for caching, As far as I can tell from reading the preliminary
> docs, Intel's MKTME, much like AMD's SME, is basically invisible to
> the hardware cache coherency mechanism.  So, if you modify a physical
> address with one key (or SME-enable bit), and you read it with
> another, you get garbage unless you flush.  And, if you modify memory
> with one key then remap it with a different key without flushing in
> the mean time, you risk corruption.

Yes, all true (at least with respect to Intel's implementation).

> And, what's worse, if I'm reading
> between the lines in the docs correctly, if you use PCONFIG to change
> a key, you may need to do a bunch of cache flushing to ensure you get
> reasonable effects.  (If you have dirty cache lines for some (PA, key)
> and you PCONFIG to change the underlying key, you get different
> results depending on whether the writeback happens before or after the
> package doing the writeback notices the PCONFIG.)

We're not going to allow a key to be PCONFIG'd while there are any
physical pages still associated with it.  There are per-VMA refcounts
tied back to the keyid slots, IIRC.  So, before PCONFIG can happen, we
just need to make sure that all the VMAs are gone, all the pages are
freed, and all dirty cachelines have been clflushed.

This is where get_user_pages() is our mortal enemy, though.  I hope we
got that right.  Kirill/Alison, we should chat about this one. :)

> Finally, If you're going to teach the kernel how to have some user
> pages that aren't in the direct map, you've essentially done XPO,
> which is nifty but expensive.  And I think that doing this gets you
> essentially all the benefit of MKTME for the non-pmem use case.  Why
> exactly would any software want to use anything other than a
> CPU-managed key for anything other than pmem?

It is handy, for one, to let you "cluster" key usage.  If you have 5
Pepsi VMs and 5 Coke VMs, each Pepsi one using the same key and each
Coke one using the same key, you can boil it down to only 2 hardware
keyid slots that get used, and do this transparently.

But, I think what you're implying is that the security properties of
user-supplied keys can only be *worse* than using CPU-generated keys
(assuming the CPU does a good job generating it).  So, why bother
allowing user-specified keys in the first place?

It's a good question and I don't have a solid answer for why folks want
this.  I'll find out.
