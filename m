Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADBCE6B57A7
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 11:26:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 2-v6so6195283plc.11
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:26:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor3457296plu.100.2018.08.31.08.26.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 08:26:50 -0700 (PDT)
Date: Fri, 31 Aug 2018 09:26:47 -0600
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20180831152647.GC15213@cisco.cisco.com>
References: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
 <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ciirm8a7p3alos.fsf@u54ee758033e858cfa736.ant.amazon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Stecklina <jsteckli@amazon.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Thu, Aug 30, 2018 at 06:00:51PM +0200, Julian Stecklina wrote:
> Hey everyone,
> 
> On Mon, 20 Aug 2018 15:27 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > On Mon, Aug 20, 2018 at 3:02 PM Woodhouse, David <dwmw@amazon.co.uk> wrote:
> >>
> >> It's the *kernel* we don't want being able to access those pages,
> >> because of the multitude of unfixable cache load gadgets.
> >
> > Ahh.
> > 
> > I guess the proof is in the pudding. Did somebody try to forward-port
> > that patch set and see what the performance is like?
> 
> I've been spending some cycles on the XPFO patch set this week. For the
> patch set as it was posted for v4.13, the performance overhead of
> compiling a Linux kernel is ~40% on x86_64[1]. The overhead comes almost
> completely from TLB flushing. If we can live with stale TLB entries
> allowing temporary access (which I think is reasonable), we can remove
> all TLB flushing (on x86). This reduces the overhead to 2-3% for
> kernel compile.

Cool, thanks for doing this! Do you have any thoughts about what the
2-3% is? It seems to me like if we're not doing the TLB flushes, the
rest of this should be *really* cheap, even cheaper than 2-3%. Dave
Hansen had suggested coalescing things on a per mapping basis vs.
doing it per page, which might help?

> > It used to be just 500 LOC. Was that because they took horrible
> > shortcuts?
> 
> The patch is still fairly small. As for the horrible shortcuts, I let
> others comment on that.

Heh, things like xpfo_temp_map() aren't awesome, but that can
hopefully be fixed by keeping a little bit of memory around for use
where we are mapping things and can't fail. I remember some discussion
about hopefully not having to sprinkle xpfo mapping calls everywhere
in the kernel, so perhaps we could get rid of it entirely?

Anyway, I'm working on some other stuff for the kernel right now, but
I hope (:D) that it should be close to done, and I'll have more cycles
to work on this soon too.

Tycho
