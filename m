Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA9328E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:21:31 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so8904997pgq.12
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:21:31 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id p23si8632304pgk.312.2019.01.11.10.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:21:30 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <7e3b2c4b-51ff-2027-3a53-8c798c2ca588@oracle.com>
Date: Fri, 11 Jan 2019 11:21:04 -0700
MIME-Version: 1.0
In-Reply-To: <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
Content-Type: multipart/mixed;
 boundary="------------CF7DB4497E0E08B56DB0F0CA"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>

This is a multi-part message in MIME format.
--------------CF7DB4497E0E08B56DB0F0CA
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Dave,

Thanks for looking at this and providing feedback.

On 1/10/19 4:40 PM, Dave Hansen wrote:
> First of all, thanks for picking this back up.  It looks to be going in=

> a very positive direction!
>=20
> On 1/10/19 1:09 PM, Khalid Aziz wrote:
>> I implemented a solution to reduce performance penalty and
>> that has had large impact. When XPFO code flushes stale TLB entries,
>> it does so for all CPUs on the system which may include CPUs that
>> may not have any matching TLB entries or may never be scheduled to
>> run the userspace task causing TLB flush.
> ...
>> A rogue process can launch a ret2dir attack only from a CPU that has=20
>> dual mapping for its pages in physmap in its TLB. We can hence defer=20
>> TLB flush on a CPU until a process that would have caused a TLB
>> flush is scheduled on that CPU.
>=20
> This logic is a bit suspect to me.  Imagine a situation where we have
> two attacker processes: one which is causing page to go from
> kernel->user (and be unmapped from the kernel) and a second process tha=
t
> *was* accessing that page.
>=20
> The second process could easily have the page's old TLB entry.  It coul=
d
> abuse that entry as long as that CPU doesn't context switch
> (switch_mm_irqs_off()) or otherwise flush the TLB entry.

That is an interesting scenario. Working through this scenario, physmap
TLB entry for a page is flushed on the local processor when the page is
allocated to userspace, in xpfo_alloc_pages(). When the userspace passes
page back into kernel, that page is mapped into kernel space using a va
from kmap pool in xpfo_kmap() which can be different for each new
mapping of the same page. The physical page is unmapped from kernel on
the way back from kernel to userspace by xpfo_kunmap(). So two processes
on different CPUs sharing same physical page might not be seeing the
same virtual address for that page while they are in the kernel, as long
as it is an address from kmap pool. ret2dir attack relies upon being
able to craft a predictable virtual address in the kernel physmap for a
physical page and redirect execution to that address. Does that sound rig=
ht?

Now what happens if only one of these cooperating processes allocates
the page, places malicious payload on that page and passes the address
of this page to the other process which can deduce physmap for the page
through /proc and exploit the physmap entry for the page on its CPU.
That must be the scenario you are referring to.

>=20
> As for where to flush the TLB...  As you know, using synchronous IPIs i=
s
> obviously the most bulletproof from a mitigation perspective.  If you
> can batch the IPIs, you can get the overhead down, but you need to do
> the flushes for a bunch of pages at once, which I think is what you wer=
e
> exploring but haven't gotten working yet.
>=20
> Anything else you do will have *some* reduced mitigation value, which
> isn't a deal-breaker (to me at least).  Some ideas:

Even without batched IPIs working reliably, I was able to measure the
performance impact of this partially working solution. With just batched
IPIs and no delayed TLB flushes, performance improved by a factor of 2.
The 26x system time went down to 12x-13x but it was still too high and a
non-starter. Combining batched IPI with delayed TLB flushes improved
performance to about 1.1x as opposed to 1.33x with delayed TLB flush
alone. Those numbers are very rough since the batching implementation is
incomplete.

>=20
> Take a look at the SWITCH_TO_KERNEL_CR3 in head_64.S.  Every time that
> gets called, we've (potentially) just done a user->kernel transition an=
d
> might benefit from flushing the TLB.  We're always doing a CR3 write (o=
n
> Meltdown-vulnerable hardware) and it can do a full TLB flush based on i=
f
> X86_CR3_PCID_NOFLUSH_BIT is set.  So, when you need a TLB flush, you
> would set a bit that ADJUST_KERNEL_CR3 would see on the next
> user->kernel transition on *each* CPU.  Potentially, multiple TLB
> flushes could be coalesced this way.  The downside of this is that
> you're exposed to the old TLB entries if a flush is needed while you ar=
e
> already *in* the kernel.
>=20
> You could also potentially do this from C code, like in the syscall
> entry code, or in sensitive places, like when you're returning from a
> guest after a VMEXIT in the kvm code.
>=20

Good suggestions. Thanks.

I think benefit will be highest from batching TLB flushes. I see a lot
of time consumed by full TLB flushes on other processors when local
processor did only a limited TLB flush. I will continue to debug the
batch TLB updates.

--
Khalid

--------------CF7DB4497E0E08B56DB0F0CA
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

mQGNBFwdSxMBDACs4wtsihnZ9TVeZBZYPzcj1sl7hz41PYvHKAq8FfBOl4yC6ghp
U0FDo3h8R7ze0VGU6n5b+M6fbKvOpIYT1r02cfWsKVtcssCyNhkeeL5A5X9z5vgt
QnDDhnDdNQr4GmJVwA9XPvB/Pa4wOMGz9TbepWfhsyPtWsDXjvjFLVScOorPddrL
/lFhriUssPrlffmNOMKdxhqGu6saUZN2QBoYjiQnUimfUbM6rs2dcSX4SVeNwl9B
2LfyF3kRxmjk964WCrIp0A2mB7UUOizSvhr5LqzHCXyP0HLgwfRd3s6KNqb2etes
FU3bINxNpYvwLCy0xOw4DYcerEyS1AasrTgh2jr3T4wtPcUXBKyObJWxr5sWx3sz
/DpkJ9jupI5ZBw7rzbUfoSV3wNc5KBZhmqjSrc8G1mDHcx/B4Rv47LsdihbWkeeB
PVzB9QbNqS1tjzuyEAaRpfmYrmGM2/9HNz0p2cOTsk2iXSaObx/EbOZuhAMYu4zH
y744QoC+Wf08N5UAEQEAAbQkS2hhbGlkIEF6aXogPGtoYWxpZC5heml6QG9yYWNs
ZS5jb20+iQHUBBMBCAA+FiEErS+7JMqGyVyRyPqp4t2wFa8wz0MFAlwdSxQCGwMF
CQHhM4AFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AACgkQ4t2wFa8wz0PaZwv/b55t
AIoG8+KHig+IwVqXwWTpolhs+19mauBqRAK+/vPU6wvmrzJ1cz9FTgrmQf0GAPOI
YZvSpH8Z563kAGRxCi9LKX1vM8TA60+0oazWIP8epLudAsQ3xbFFedc0LLoyWCGN
u/VikES6QIn+2XaSKaYfXC/qhiXYJ0fOOXnXWv/t2eHtaGC1H+/kYEG5rFtLnILL
fyFnxO3wf0r4FtLrvxftb6U0YCe4DSAed+27HqpLeaLCVpv/U+XOfe4/Loo1yIpm
KZwiXvc0G2UUK19mNjp5AgDKJHwZHn3tS/1IV/mFtDT9YkKEzNs4jYkA5FzDMwB7
RD5l/EVf4tXPk4/xmc4Rw7eB3X8z8VGw5V8kDZ5I8xGIxkLpgzh56Fg420H54a7m
714aI0ruDWfVyC0pACcURTsMLAl4aN6E0v8rAUQ1vCLVobjNhLmfyJEwLUDqkwph
rDUagtEwWgIzekcyPW8UaalyS1gG7uKNutZpe/c9Vr5Djxo2PzM7+dmSMB81uQGN
BFwdSxMBDAC8uFhUTc5o/m49LCBTYSX79415K1EluskQkIAzGrtLgE/8DHrt8rtQ
FSum+RYcA1L2aIS2eIw7M9Nut9IOR7YDGDDP+lcEJLa6L2LQpRtO65IHKqDQ1TB9
la4qi+QqS8WFo9DLaisOJS0jS6kO6ySYF0zRikje/hlsfKwxfq/RvZiKlkazRWjx
RBnGhm+niiRD5jOJEAeckbNBhg+6QIizLo+g4xTnmAhxYR8eye2kG1tX1VbIYRX1
3SrdObgEKj5JGUGVRQnf/BM4pqYAy9szEeRcVB9ZXuHmy2mILaX3pbhQF2MssYE1
KjYhT+/U3RHfNZQq5sUMDpU/VntCd2fN6FGHNY0SHbMAMK7CZamwlvJQC0WzYFa+
jq1t9ei4P/HC8yLkYWpJW2yuxTpD8QP9yZ6zY+htiNx1mrlf95epwQOy/9oS86Dn
MYWnX9VP8gSuiESUSx87gD6UeftGkBjoG2eX9jcwZOSu1YMhKxTBn8tgGH3LqR5U
QLSSR1ozTC0AEQEAAYkBvAQYAQgAJhYhBK0vuyTKhslckcj6qeLdsBWvMM9DBQJc
HUsTAhsMBQkB4TOAAAoJEOLdsBWvMM9D8YsL/0rMCewC6L15TTwer6GzVpRwbTuP
rLtTcDumy90jkJfaKVUnbjvoYFAcRKceTUP8rz4seM/R1ai78BS78fx4j3j9qeWH
rX3C0k2aviqjaF0zQ86KEx6xhdHWYPjmtpt3DwSYcV4Gqefh31Ryl5zO5FIz5yQy
Z+lHCH+oBD51LMxrgobUmKmT3NOhbAIcYnOHEqsWyGrXD9qi0oj1Cos/t6B2oFaY
IrLdMkklt+aJYV4wu3gWRW/HXypgeo0uDWOowfZSVi/u5lkn9WMUUOjIeL1IGJ7x
U4JTAvt+f0BbX6b1BIC0nygMgdVe3tgKPIlniQc24Cj8pW8D8v+K7bVuNxxmdhT4
71XsoNYYmmB96Z3g6u2s9MY9h/0nC7FI6XSk/z584lGzzlwzPRpTOxW7fi/E/38o
E6wtYze9oihz8mbNHY3jtUGajTsv/F7Jl42rmnbeukwfN2H/4gTDV1sB/D8z5G1+
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------CF7DB4497E0E08B56DB0F0CA--
