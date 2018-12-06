Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 265486B7B61
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:10:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so803110pgv.23
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:10:59 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q17si1001507pfc.198.2018.12.06.11.10.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 11:10:57 -0800 (PST)
Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 27F04214E0
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 19:10:57 +0000 (UTC)
Received: by mail-wr1-f54.google.com with SMTP id j2so1614787wrw.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:10:57 -0800 (PST)
MIME-Version: 1.0
References: <cover.1543903910.git.alison.schofield@intel.com>
 <CALCETrUqqQiHR_LJoKB2JE6hCZ-e7LiFprEhmo-qoegDZJ9uYQ@mail.gmail.com>
 <c610138f-32dd-a24c-dc52-4e0006a21409@intel.com> <CALCETrU34U3berTaEQbvNt0rfCdsjwj+xDb8x7bgAMFHEo=eUw@mail.gmail.com>
 <5e97e1bf-536c-ef73-576e-54145eee1ae9@intel.com>
In-Reply-To: <5e97e1bf-536c-ef73-576e-54145eee1ae9@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Dec 2018 11:10:43 -0800
Message-ID: <CALCETrVPhay-ziRVjL9dDCwJQHhr4HfG5aGJzYh06k6HEMZTiQ@mail.gmail.com>
Subject: Re: [RFC v2 00/13] Multi-Key Total Memory Encryption API (MKTME)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Alison Schofield <alison.schofield@intel.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, David Howells <dhowells@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, James Morris <jmorris@namei.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kai.huang@intel.com, Jun Nakajima <jun.nakajima@intel.com>, "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>, keyrings@vger.kernel.org, LSM List <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

> On Dec 6, 2018, at 7:39 AM, Dave Hansen <dave.hansen@intel.com> wrote:

>>>> the direct map as well, probably using the pageattr.c code.
>>>
>>> The current, public hardware spec has a description of what's required
>>> to maintain cache coherency.  Basically, you can keep as many mappings
>>> of a physical page as you want, but only write to one mapping at a time=
,
>>> and clflush the old one when you want to write to a new one.
>>
>> Surely you at least have to clflush the old mapping and then the new
>> mapping, since the new mapping could have been speculatively read.
>
> Nope.  The coherency is "fine" unless you have writeback of an older
> cacheline that blows away newer data.  CPUs that support MKTME are
> guaranteed to never do writeback of the lines that could be established
> speculatively or from prefetching.

How is that sufficient?  Suppose I have some physical page mapped with
keys 1 and 2. #1 is logically live and I write to it.  Then I prefetch
or otherwise populate mapping 2 into the cache (in the S state,
presumably).  Now I clflush mapping 1 and read 2.  It contains garbage
in the cache, but the garbage in the cache is inconsistent with the
garbage in memory.  This can=E2=80=99t be a good thing, even if no writebac=
k
occurs.

I suppose the right fix is to clflush the old mapping and then to zero
the new mapping.

>
>>>> Finally, If you're going to teach the kernel how to have some user
>>>> pages that aren't in the direct map, you've essentially done XPO,
>>>> which is nifty but expensive.  And I think that doing this gets you
>>>> essentially all the benefit of MKTME for the non-pmem use case.  Why
>>>> exactly would any software want to use anything other than a
>>>> CPU-managed key for anything other than pmem?
>>>
>>> It is handy, for one, to let you "cluster" key usage.  If you have 5
>>> Pepsi VMs and 5 Coke VMs, each Pepsi one using the same key and each
>>> Coke one using the same key, you can boil it down to only 2 hardware
>>> keyid slots that get used, and do this transparently.
>>
>> I understand this from a marketing perspective but not a security
>> perspective.  Say I'm Coke and you've sold me some VMs that are
>> "encrypted with a Coke-specific key and no other VMs get to use that
>> key."  I can't think of *any* not-exceedingly-contrived attack in
>> which this makes the slightest difference.  If Pepsi tries to attack
>> Coke without MKTME, then they'll either need to get the hypervisor to
>> leak Coke's data through the direct map or they'll have to find some
>> way to corrupt a page table or use something like L1TF to read from a
>> physical address Coke owns.  With MKTME, if they can read through the
>> host direct map, then they'll get Coke's cleartext, and if they can
>> corrupt a page table or use L1TF to read from your memory, they'll get
>> Coke's cleartext.
>
> The design definitely has the hypervisor in the trust boundary.  If the
> hypervisor is evil, or if someone evil compromises the hypervisor, MKTME
> obviously provides less protection.
>
> I guess the question ends up being if this makes its protections weak
> enough that we should not bother merging it in its current form.

Indeed, but I=E2=80=99d ask another question too: I expect that MKTME is we=
ak
enough that it will be improved, and without seeing the improvement,
it seems quite plausible that using the improvement will require
radically reworking the kernel implementation.

As a straw man, suppose we get a way to say =E2=80=9Cthis key may only be
accessed through such-and-such VPID or by using a special new
restricted facility for the hypervisor to request access=E2=80=9D.    Now w=
e
have some degree of serious protection, but it doesn=E2=80=99t work, by
design, for anonymous memory.  Similarly, something that looks more
like AMD's SEV would be very very awkward to support with anything
like the current API proposal.

>
> I still have the homework assignment to go figure out why folks want the
> protections as they stand.
