Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 143E96B0273
	for <linux-mm@kvack.org>; Sat, 31 Mar 2018 01:40:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u13so5042467wre.1
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 22:40:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18sor168808wrd.87.2018.03.30.22.39.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 22:40:00 -0700 (PDT)
Date: Sat, 31 Mar 2018 07:39:56 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/11] Use global pages with PTI
Message-ID: <20180331053956.uts5yhxfy7ud4bpf@gmail.com>
References: <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
 <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
 <20180327200719.lvdomez6hszpmo4s@gmail.com>
 <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com>
 <20180330120920.btobga44wqytlkoe@gmail.com>
 <20180330121725.zcklh36ulg7crydw@gmail.com>
 <3cdc23a2-99eb-6f93-6934-f7757fa30a3e@linux.intel.com>
 <alpine.DEB.2.21.1803302230560.1479@nanos.tec.linutronix.de>
 <62a0dbae-75eb-6737-6029-4aaf72ebd199@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62a0dbae-75eb-6737-6029-4aaf72ebd199@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 03/30/2018 01:32 PM, Thomas Gleixner wrote:
> > On Fri, 30 Mar 2018, Dave Hansen wrote:
> > 
> >> On 03/30/2018 05:17 AM, Ingo Molnar wrote:
> >>> BTW., the expectation on !PCID Intel hardware would be for global pages to help 
> >>> even more than the 0.6% and 1.7% you measured on PCID hardware: PCID already 
> >>> _reduces_ the cost of TLB flushes - so if there's not even PCID then global pages 
> >>> should help even more.
> >>>
> >>> In theory at least. Would still be nice to measure it.
> >>
> >> I did the lseek test on a modern, non-PCID system:
> >>
> >> No Global pages (baseline): 6077741 lseeks/sec
> >> 94 Global pages (this set): 8433111 lseeks/sec
> >> 			   +2355370 lseeks/sec (+38.8%)
> > 
> > That's all kernel text, right? What's the result for the case where global
> > is only set for all user/kernel shared pages?
> 
> Yes, that's all kernel text (94 global entries).  Here's the number with
> just the entry data/text set global (88 global entries on this system):
> 
> No Global pages (baseline): 6077741 lseeks/sec
> 88 Global Pages (kentry  ): 7528609 lseeks/sec (+23.9%)
> 94 Global pages (this set): 8433111 lseeks/sec (+38.8%)

Very impressive!

Please incorporate the performance numbers in patches #9 and #11.

There were a couple of valid review comments which need to be addressed as well, 
but other than that it all looks good to me and I plan to apply the next 
iteration.

In fact I think I'll try to put it into the backporting tree: as PGE was really 
the pre PTI status quo and thus we should expect few quirks/bugs in this area, 
plus we still want to share as much core PTI logic with the -stable kernels as 
possible. The performance plus doesn't hurt either ... after so much lost 
performance.

Thanks,

	Ingo
