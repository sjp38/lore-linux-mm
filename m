Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 675AD6B0032
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 05:37:03 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id hy10so7956407vcb.8
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 02:37:03 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id q9si2976562vcf.85.2015.02.28.02.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 02:37:01 -0800 (PST)
Message-ID: <1425119814.4645.114.camel@kernel.crashing.org>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 28 Feb 2015 21:36:54 +1100
In-Reply-To: <1425107646.4645.109.camel@kernel.crashing.org>
References: <1422361485.6648.71.camel@opensuse.org>
	 <54C78756.9090605@suse.cz>
	 <alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	 <1422364084.6648.82.camel@opensuse.org> <s5h7fw8hvdp.wl-tiwai@suse.de>
	 <CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	 <CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	 <CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	 <CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	 <1422836637.17302.9.camel@au1.ibm.com>
	 <CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	 <1425107567.4645.108.camel@kernel.crashing.org>
	 <1425107646.4645.109.camel@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, 2015-02-28 at 18:14 +1100, Benjamin Herrenschmidt wrote:
> On Sat, 2015-02-28 at 18:12 +1100, Benjamin Herrenschmidt wrote:
> > 
> > Let me know what you think of the approach. It's boot tested on x86_64
> > in qemu and 
> 
>  ... and powerpc64 LE on qemu as well :-)

One thing I'd like to do is fold handle_kernel_fault() into
handle_bad_area() (and in fact fold do_sigbus as well).

Basically have a single handle_bad_fault() that takes sig and si_code as
arguments which we call from the generic code for all faults. It will
test for kernel vs. user mode and do the right thing (and we could
handle the sigbus special case by simply comparing sig to sigbus).

The one reason I haven't done it so far is that x86 handle_bad_area()
has the is_f00f_bug() call which isn't do for other cases of
no_context() and I'm not sure generalizing it is safe for all cases (or
maybe I can call it only when sig is SIGSEGV ?) ... I don't actually
understand what it does :)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
