Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B28F6B0083
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 14:32:32 -0500 (EST)
References: <715599.77204.qm@web50111.mail.re2.yahoo.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 30 Jan 2009 11:32:38 -0800
In-Reply-To: <715599.77204.qm@web50111.mail.re2.yahoo.com> (Doug Thompson's message of "Fri\, 30 Jan 2009 08\:50\:51 -0800 \(PST\)")
Message-ID: <m1wscc7fop.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: marching through all physical memory in software
Sender: owner-linux-mm@kvack.org
To: Doug Thompson <norsk5@yahoo.com>
Cc: ncunningham-lkml@crca.org.au, Pavel Machek <pavel@suse.cz>, Chris Friesen <cfriesen@nortel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bluesmoke-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Doug Thompson <norsk5@yahoo.com> writes:

> Nigel Cunningham <ncunningham-lkml@crca.org.au> wrote:
>
>     Hi again.
>
>     On Fri, 2009-01-30 at 10:13 +0100, Pavel Machek wrote:
>     > > Hi.
>     > >
>     > > On Wed, 2009-01-28 at 20:38 +0100, Pavel Machek wrote:
>     > > > You can do the scrubbing today by echo reboot > /sys/power/disk; echo
>     > > > disk > /sys/power/state :-)... or using uswsusp APIs.
>     > >
>     > > That won't work. The RAM retains its contents across a reboot, and even
>     > > for a little while after powering off.
>     >
>     > Yes, and the original goal was to rewrite all the memory with same
>     > contents so that parity errors don't accumulate. SO scrubbing here !=
>     > trying to clear it.
>
>     Sorry - I think I missed something.
>
>     AFAICS, hibernating is going to be a noop as far as doing anything to
>     memory that's not touched by the process of hibernating goes. It won't
>     clear it or scrub it or anything else.

A background software scrubber simply has the job of rewritting memory
to it's current content so that the data and the ecc check bits are
guaranteed to be in sync keeping correctable ecc errors caused by
environmental factors from accumulating.

Pavel's original comment was that the hibernation code has to walk all
of memory to save it to disk so it would be a good place to look to
figure out how to walk all of memory.  And incidentally hibernation
would serve as a crud way of rewritting all of memory.


> Even if hibernating worked, it does not touch the issue of scrubbing memory
> that doesn't have hardware support AND the requirement of thousands of nodes in
> cluster who MUST remain operational for days on end.

But it may still serve as an example of how to walk through all of memory.

> Sicortex's MIPS based system fits that exactly.  When I did their EDAC driver
> they wanted to have a software scrubber at a NICE run level to scan memory and
> do this operation without shutting down the system.
>
> We never got to it, but it would be a nice for some to have a background
> software scrubber.  But I would need help from the memory guys on a proper
> interface.
>
> The goal would be have a "loose" target of attempting to all most memory if not
> all.  Sometime of iteration over the memory set.

Thinking about it.  We only care about memory the kernel is using so the memory
maps the BIOS supplies the kernel should be sufficient.  We have weird corner
cases like ACPI but not handling those in the first pass and getting
something working should be fine.

There are other silly things such as wanting to only scrub memory on it's native
NUMA node (if possible) for both performance and scalability.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
