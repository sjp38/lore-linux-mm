Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39F666B7AAD
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 10:39:11 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x7so464595pll.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 07:39:11 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h3si489893pgl.468.2018.12.06.07.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 07:39:09 -0800 (PST)
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com>
 <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5e97e1bf-536c-ef73-576e-54145eee1ae9@intel.com>
Date: Thu, 6 Dec 2018 07:39:07 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: alison.schofield@intel.com, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On 12/5/18 5:09 PM, Andy Lutomirski wrote:
> On Wed, Dec 5, 2018 at 3:49 PM Dave Hansen <dave.hansen@intel.com> wrote:
>> What I was hoping to see was them do this (apologies for the horrible
>> indentation:
>>
>>         ptr = mmap(..., PROT_NONE);
>>         mprotect_pkey(   addr, len, PROT_NONE, pkey);
>>         mprotect_encrypt(addr, len, PROT_NONE, keyid);
>>         mprotect(        addr, len, real_prot);
>>
>> The point is that you *can* stack these things and don't have to have an
>> mprotect_kitchen_sink() if you use PROT_NONE for intermediate
>> permissions during setup.
> 
> Sure, but then why call it mprotect at all?  How about:
> 
> mmap(..., PROT_NONE);
> mencrypt(..., keyid);
> mprotect_pkey(...);

That would totally work too.  I just like the idea of a family of
mprotect() syscalls that do mprotect() plus one other thing.  What
you're proposing is totally equivalent where we have mprotect_pkey()
always being the *last* thing that gets called, plus a family of things
that we expect to get called on something that's probably PROT_NONE.

> But wouldn't this be much nicer:
> 
> int fd = memfd_create(...);
> memfd_set_tme_key(fd, keyid);  /* fails if len != 0 */
> mmap(fd, ...);

No. :)

One really big advantage with protection keys, or this implementation is
that you don't have to implement an allocator.  You can use it with any
old malloc() as long as you own a whole page.

The pages also fundamentally *stay* anonymous in the VM and get all the
goodness that comes with that, like THP.

>>> and it's also functionally just MADV_DONTNEED.  In other words, the
>>> sole user-visible effect appears to be that the existing pages are
>>> blown away.  The fact that it changes the key in use doesn't seem
>>> terribly useful, since it's anonymous memory,
>>
>> It's functionally MADV_DONTNEED, plus a future promise that your writes
>> will never show up as plaintext on the DIMM.
> 
> But that's mostly vacuous.  If I read the docs right, MKTME systems
> also support TME, so you *already* have that promise, unless the
> firmware totally blew it.  If we want a boot option to have the kernel
> use MKTME to forcibly encrypt everything regardless of what the TME
> MSRs say, I'd be entirely on board.  Heck, the implementation would be
> quite simple because we mostly reuse the SME code.

Yeah, that's true.  I seem to always forget about the TME case! :)

"It's functionally MADV_DONTNEED, plus a future promise that your writes
will never be written to the DIMM with the TME key."

But, this gets us back to your very good question about what good this
does in the end.  What value does _that_ scheme provide over TME?  We're
admittedly weak on specific examples there, but I'm working on it.

>>> the direct map as well, probably using the pageattr.c code.
>>
>> The current, public hardware spec has a description of what's required
>> to maintain cache coherency.  Basically, you can keep as many mappings
>> of a physical page as you want, but only write to one mapping at a time,
>> and clflush the old one when you want to write to a new one.
> 
> Surely you at least have to clflush the old mapping and then the new
> mapping, since the new mapping could have been speculatively read.

Nope.  The coherency is "fine" unless you have writeback of an older
cacheline that blows away newer data.  CPUs that support MKTME are
guaranteed to never do writeback of the lines that could be established
speculatively or from prefetching.

>>> Finally, If you're going to teach the kernel how to have some user
>>> pages that aren't in the direct map, you've essentially done XPO,
>>> which is nifty but expensive.  And I think that doing this gets you
>>> essentially all the benefit of MKTME for the non-pmem use case.  Why
>>> exactly would any software want to use anything other than a
>>> CPU-managed key for anything other than pmem?
>>
>> It is handy, for one, to let you "cluster" key usage.  If you have 5
>> Pepsi VMs and 5 Coke VMs, each Pepsi one using the same key and each
>> Coke one using the same key, you can boil it down to only 2 hardware
>> keyid slots that get used, and do this transparently.
> 
> I understand this from a marketing perspective but not a security
> perspective.  Say I'm Coke and you've sold me some VMs that are
> "encrypted with a Coke-specific key and no other VMs get to use that
> key."  I can't think of *any* not-exceedingly-contrived attack in
> which this makes the slightest difference.  If Pepsi tries to attack
> Coke without MKTME, then they'll either need to get the hypervisor to
> leak Coke's data through the direct map or they'll have to find some
> way to corrupt a page table or use something like L1TF to read from a
> physical address Coke owns.  With MKTME, if they can read through the
> host direct map, then they'll get Coke's cleartext, and if they can
> corrupt a page table or use L1TF to read from your memory, they'll get
> Coke's cleartext.

The design definitely has the hypervisor in the trust boundary.  If the
hypervisor is evil, or if someone evil compromises the hypervisor, MKTME
obviously provides less protection.

I guess the question ends up being if this makes its protections weak
enough that we should not bother merging it in its current form.

I still have the homework assignment to go figure out why folks want the
protections as they stand.
