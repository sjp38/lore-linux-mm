Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECB98E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:20:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f9so7351929pgs.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:20:59 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 69si20253335pla.75.2019.01.10.16.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:20:58 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <e8df9859-4629-52d7-9807-d87f1820a01d@oracle.com>
Date: Thu, 10 Jan 2019 17:20:42 -0700
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------FC7CF09A9847D3FB32FED20B"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

This is a multi-part message in MIME format.
--------------FC7CF09A9847D3FB32FED20B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Thanks for looking this over.

On 1/10/19 4:07 PM, Kees Cook wrote:
> On Thu, Jan 10, 2019 at 1:10 PM Khalid Aziz <khalid.aziz@oracle.com> wr=
ote:
>> I implemented a solution to reduce performance penalty and
>> that has had large impact. When XPFO code flushes stale TLB entries,
>> it does so for all CPUs on the system which may include CPUs that
>> may not have any matching TLB entries or may never be scheduled to
>> run the userspace task causing TLB flush. Problem is made worse by
>> the fact that if number of entries being flushed exceeds
>> tlb_single_page_flush_ceiling, it results in a full TLB flush on
>> every CPU. A rogue process can launch a ret2dir attack only from a
>> CPU that has dual mapping for its pages in physmap in its TLB. We
>> can hence defer TLB flush on a CPU until a process that would have
>> caused a TLB flush is scheduled on that CPU. I have added a cpumask
>> to task_struct which is then used to post pending TLB flush on CPUs
>> other than the one a process is running on. This cpumask is checked
>> when a process migrates to a new CPU and TLB is flushed at that
>> time. I measured system time for parallel make with unmodified 4.20
>> kernel, 4.20 with XPFO patches before this optimization and then
>> again after applying this optimization. Here are the results:
>>
>> Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
>> make -j60 all
>>
>> 4.20                            915.183s
>> 4.20+XPFO                       24129.354s      26.366x
>> 4.20+XPFO+Deferred flush        1216.987s        1.330xx
>>
>>
>> Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
>> make -j4 all
>>
>> 4.20                            607.671s
>> 4.20+XPFO                       1588.646s       2.614x
>> 4.20+XPFO+Deferred flush        794.473s        1.307xx
>=20
> Well that's an impressive improvement! Nice work. :)
>=20
> (Are the cpumask improvements possible to be extended to other TLB
> flushing needs? i.e. could there be other performance gains with that
> code even for a non-XPFO system?)

It may be usable for other situations as well but I have not given it
any thought yet. I will take a look.

>=20
>> 30+% overhead is still very high and there is room for improvement.
>> Dave Hansen had suggested batch updating TLB entries and Tycho had
>> created an initial implementation but I have not been able to get
>> that to work correctly. I am still working on it and I suspect we
>> will see a noticeable improvement in performance with that. In the
>> code I added, I post a pending full TLB flush to all other CPUs even
>> when number of TLB entries being flushed on current CPU does not
>> exceed tlb_single_page_flush_ceiling. There has to be a better way
>> to do this. I just haven't found an efficient way to implemented
>> delayed limited TLB flush on other CPUs.
>>
>> I am not entirely sure if switch_mm_irqs_off() is indeed the right
>> place to perform the pending TLB flush for a CPU. Any feedback on
>> that will be very helpful. Delaying full TLB flushes on other CPUs
>> seems to help tremendously, so if there is a better way to implement
>> the same thing than what I have done in patch 16, I am open to
>> ideas.
>=20
> Dave, Andy, Ingo, Thomas, does anyone have time to look this over?
>=20
>> Performance with this patch set is good enough to use these as
>> starting point for further refinement before we merge it into main
>> kernel, hence RFC.
>>
>> Since not flushing stale TLB entries creates a false sense of
>> security, I would recommend making TLB flush mandatory and eliminate
>> the "xpfotlbflush" kernel parameter (patch "mm, x86: omit TLB
>> flushing by default for XPFO page table modifications").
>=20
> At this point, yes, that does seem to make sense.
>=20
>> What remains to be done beyond this patch series:
>>
>> 1. Performance improvements
>> 2. Remove xpfotlbflush parameter
>> 3. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
>>    from Juerg. I dropped it for now since swiotlb code for ARM has
>>    changed a lot in 4.20.
>> 4. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
>>    CPUs" to other architectures besides x86.
>=20
> This seems like a good plan.
>=20
> I've put this series in one of my tree so that 0day will find it and
> grind tests...
> https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/log/?h=3D=
kspp/xpfo/v7

Thanks for doing that!

--
Khalid

--------------FC7CF09A9847D3FB32FED20B
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------FC7CF09A9847D3FB32FED20B--
