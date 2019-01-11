Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8D48E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:45:56 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id 128so3518279itw.8
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:45:56 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f133si1329791itc.27.2019.01.11.13.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 13:45:55 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
 <CALCETrVWjdo6C53eFz8Gc99q4HFsGpwf4kDXR5OG8E96t-gSLw@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <5dc08118-a406-0ae6-f0fa-12e8d194810c@oracle.com>
Date: Fri, 11 Jan 2019 14:45:37 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrVWjdo6C53eFz8Gc99q4HFsGpwf4kDXR5OG8E96t-gSLw@mail.gmail.com>
Content-Type: multipart/mixed;
 boundary="------------9F41D4AFF400C7C034CFF85C"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

This is a multi-part message in MIME format.
--------------9F41D4AFF400C7C034CFF85C
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 1/10/19 5:44 PM, Andy Lutomirski wrote:
> On Thu, Jan 10, 2019 at 3:07 PM Kees Cook <keescook@chromium.org> wrote=
:
>>
>> On Thu, Jan 10, 2019 at 1:10 PM Khalid Aziz <khalid.aziz@oracle.com> w=
rote:
>>> I implemented a solution to reduce performance penalty and
>>> that has had large impact. When XPFO code flushes stale TLB entries,
>>> it does so for all CPUs on the system which may include CPUs that
>>> may not have any matching TLB entries or may never be scheduled to
>>> run the userspace task causing TLB flush. Problem is made worse by
>>> the fact that if number of entries being flushed exceeds
>>> tlb_single_page_flush_ceiling, it results in a full TLB flush on
>>> every CPU. A rogue process can launch a ret2dir attack only from a
>>> CPU that has dual mapping for its pages in physmap in its TLB. We
>>> can hence defer TLB flush on a CPU until a process that would have
>>> caused a TLB flush is scheduled on that CPU. I have added a cpumask
>>> to task_struct which is then used to post pending TLB flush on CPUs
>>> other than the one a process is running on. This cpumask is checked
>>> when a process migrates to a new CPU and TLB is flushed at that
>>> time. I measured system time for parallel make with unmodified 4.20
>>> kernel, 4.20 with XPFO patches before this optimization and then
>>> again after applying this optimization. Here are the results:
>=20
> I wasn't cc'd on the patch, so I don't know the exact details.
>=20
> I'm assuming that "ret2dir" means that you corrupt the kernel into
> using a direct-map page as its stack.  If so, then I don't see why the
> task in whose context the attack is launched needs to be the same
> process as the one that has the page mapped for user access.

You are right. More work is needed to refine delayed TLB flush to close
this gap.

>=20
> My advice would be to attempt an entirely different optimization: try
> to avoid putting pages *back* into the direct map when they're freed
> until there is an actual need to use them for kernel purposes.

I had thought about that but it turns out the performance impact happens
on the initial allocation of the page and resulting TLB flushes, not
from putting the pages back into direct map. The way we could benefit
from not adding page back to direct map is if we change page allocation
to prefer pages not in direct map. That way we incur the cost of TLB
flushes initially but then satisfy multiple allocation requests after
that from those "xpfo cost" free pages. More changes will be needed to
pick which of these pages can be added back to direct map without
degenerating into worst case scenario of a page bouncing constantly
between this list of preferred pages and direct mapped pages. It started
to get complex enough that I decided to put this in my back pocket and
attempt simpler approaches first :)

>=20
> How are you handing page cache?  Presumably MAP_SHARED PROT_WRITE
> pages are still in the direct map so that IO works.
>=20

Since Juerg wrote the actual implementation of XPFO, he probably
understands it better. XPFO tackles only the page allocation requests
from userspace and does not touch page cache pages.

--
Khalid

--------------9F41D4AFF400C7C034CFF85C
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

--------------9F41D4AFF400C7C034CFF85C--
