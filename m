Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2BF76B028D
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:43:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x4so3320349pgv.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:43:57 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 5si2569769plx.696.2018.01.16.11.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:43:56 -0800 (PST)
Date: Tue, 16 Jan 2018 11:43:55 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCHv2-resend] x86/mm, mm/hwpoison: Don't unconditionally
 unmap kernel 1:1 pages.
Message-ID: <20180116194354.ifutrgs4z2skq6hz@agluck-desk>
References: <20171129192446.21090-1-tony.luck@intel.com>
 <20180110201947.32727-1-tony.luck@intel.com>
 <20180116030932.itshfy2i4326bvoo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116030932.itshfy2i4326bvoo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@suse.de>, Denys Vlasenko <dvlasenk@redhat.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Brian Gerst <brgerst@gmail.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Robert (Persistent Memory)" <elliott@hpe.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jan 16, 2018 at 04:09:32AM +0100, Ingo Molnar wrote:
> 
> * Tony Luck <tony.luck@intel.com> wrote:
> 
> > v1->v2 0-day reported a build warning on 32-bit. Don't do 32-bit (see comment
> > at end of commit message). This fixed the build error, but then discussion on
> > the list went quiet. Repost to wake things up.
> 
> It seems dubious to me to introduce a difference in behavior on 32-bit:
> 
> > +static void mce_unmap_kpfn(unsigned long pfn)
> > +{
> > +#ifdef CONFIG_X86_64
> > +	unsigned long decoy_addr;
> 
> > +	if (set_memory_np(decoy_addr, 1))
> > +		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
> > +#endif
> 
> ... to fix a build warning?
> 
> 32-bit kernels might be under-tested, but if it's supposed to work I don't think 
> we should bifurcate the behavior and uglify the code here.

I glossed over the issue in the commit message with this text:

    All of this only applies to 64-bit systems. 32-bit kernel doesn't map
    all of memory into kernel space. It isn't worth adding the code to unmap
    the piece that is mapped because nobody would run a 32-bit kernel on a
    machine that has recoverable machine checks.

Here's some more detail on *why* I believe nobody will need this on 32-bit:

Recoverable machine checks are only supported on Xeon-E7 from IvyBridge to
Broadwell, and on the "Gold" and "Platinum" Skylake models.

These are all intended for use in 4 socket systems.

To keep the high number of cores on these busy, you need good memory
bandwidth. So any sane configuration will have a minimum of on DIMM per
memory channel, so we can interleave across as many channels as possible.

So that's either 24 or 32 DIMMs (depending on 6 or 8 channels per socket).

So on the oldest of those systems (IvyBridge) with teeny 4GB DIMMs, we have 128GB.

Which doesn't boot on 32-bit (all "low" memory is used for "struct page").

But maybe a crazy person didn't populate all channels? Or booted with "mem=32G".

They still (mostly) don't need this. Most of their memory isn't mapped 1:1
because they don't have the virtual space for it. So the majority of errors
would be in HIGMMEM ... and so not mapped.

So is this worth adding code for some hypothetical user running 32-bit who
is somehow worried about the 800MB or so that is mapped 1:1

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
