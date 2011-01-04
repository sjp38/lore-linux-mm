Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 525E46B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 18:55:11 -0500 (EST)
Received: by qwa26 with SMTP id 26so15114454qwa.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 15:55:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTinJ9P_B_0p+Y4VsuN+SjiWz2ai9WrNJFHwk=Mm+@mail.gmail.com>
References: <bug-25042-27@https.bugzilla.kernel.org/>
	<20110104135148.112d89c5.akpm@linux-foundation.org>
	<AANLkTinJ9P_B_0p+Y4VsuN+SjiWz2ai9WrNJFHwk=Mm+@mail.gmail.com>
Date: Tue, 4 Jan 2011 15:55:09 -0800
Message-ID: <AANLkTik0pMQJQgK656QsrMokxtF1q_6=UKxgMa5WVM-R@mail.gmail.com>
Subject: Re: [Bug 25042] New: RAM buffer I/O resource badly interacts with
 memory hot-add
From: Petr Vandrovec <petr@vandrovec.name>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, akataria@vmware.com, Bjorn Helgaas <bjorn.helgaas@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 4, 2011 at 2:32 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Jan 4, 2011 at 1:51 PM, Andrew Morton <akpm@linux-foundation.org>=
 wrote:
>>> Linus's commit 45fbe3ee01b8e463b28c2751b5dcc0cbdc142d90 in May 2009 add=
ed code
>>> to create 'RAM buffer' above top of RAM to ensure that I/O resources do=
 not
>>> start immediately after RAM, but sometime later. =A0Originally it was e=
nforcing
>>> 32MB alignment, now it enforces 64MB. =A0Which means that in VMs with m=
emory size
>>> which is not multiple of 64MB there will be additional 'RAM buffer' res=
ource
>>> present:
>>>
>>> 100000000-1003fffff : System RAM
>>> 100400000-103ffffff : RAM buffer
>
> I'd suggest just working around it by hotplugging in 64MB chunks.

Unfortunately that does not work - kernels configured for sparsemem
hate adding memory in chunks smaller than section size - regions with
end aligned to 128MB, and at least 128MB large is requirement for
x86-64.  If smaller region is added, then either non-existent memory
is activated, or nothing happens at all, depending on exact values and
kernel versions.  So we align end of the hot-added region to 128MB on
x86-64, and 1GB on ia32.  But we do not align start because there was
no need...

> IOW, the old "it hurts when I do that - don't do that then" solution
> to the problem. There is no reason why a VM should export some random
> 8MB-aligned region that I can see.

It just adds memory where it ended - power-on memory ended at
0x1003ffff, and so it now platform naturally tries to continue where
it left off - from 0x10040000 to 0x10ffffff.  It has no idea that OS
inside has some special requirements, and OS inside unfortunately does
not support _PRS/_SRS on memory devices either, so we cannot offer
possible choices hoping that guest will pick one it likes more than
default placement/size.

> That said, I do repeat: why the hell do you keep digging that hole in
> the first place. Do memory hotplug in 256MB chunks, naturally aligned,
> and don't bother with any of this crazy crap.

So that we can provide contiguous memory area to the VM, and layout of
VM created with some amount of memory is same as VM which was
hot-added to the required size - that's important for supporting
hibernate, and it is easier to implement than discontiguous ranges.

I've modified code so that we hot-add two regions, first to align
memory size to 256MB (that one is not activated successfully if memory
size is not multiple of 64MB, but we cannot do smaller due to
sparsemem restrictions listed above), and add remaining (if more than
256MB is added) from there.  That makes workaround similar to clash
between OPROM base addresses assigned by kernel and ranges reserved in
SRAT for memory hot-add...

Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
