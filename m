Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 59CBD6B0035
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 15:34:08 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j5so5589872qaq.28
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 12:34:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id di5si6830028qcb.56.2014.04.27.12.34.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 12:34:07 -0700 (PDT)
Date: Sun, 27 Apr 2014 21:33:55 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Dirty/Access bits vs. page content
Message-ID: <20140427193355.GA17778@laptop.programming.kicks-ass.net>
References: <1398393700.8437.22.camel@pasglop>
 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
 <5359CD7C.5020604@zytor.com>
 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
 <20140425135101.GE11096@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
 <20140426180711.GM26782@laptop.programming.kicks-ass.net>
 <20140427072034.GC1429@laptop.programming.kicks-ass.net>
 <alpine.LSU.2.11.1404270459160.2688@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404270459160.2688@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On Sun, Apr 27, 2014 at 05:20:25AM -0700, Hugh Dickins wrote:
> On Sun, 27 Apr 2014, Peter Zijlstra wrote:
> > Will the hardware fault when it does a translation and needs to update
> > the dirty/access bits while the PTE entry is !present?
> 
> Yes - but I'm sure you know that, just not while you wrote the mail ;)

Possibly, but all of a sudden I was fearing hardware was 'creative' and
we'd need something along the lines of what Linus proposed:

    entry = atomic_xchg(pte, 0);
    flush_tlb();
    entry |= *pte;

Or possible event:

   *ptep = pte_wrprotect(*ptep);
   flush_tlb();
   entry = atomic_xchg(ptep, 0);
   flush_tlb();

The horrible things one fears.. :-) The latter option would be required
if TLBs would have a write-back dirty bit cache, *shudder*.

> But it will not fault while it still has the entry in its TLB,
> with dirty (and access) bits set in that entry in its TLB.
> 
> The problem is with those entries, which already have dirty set
> in the TLB, although it's now cleared in the page table itself.
> 
> I'm answering this mail because it only seems to need "Yes";
> but well aware that I've not yet answered your yesterday's mail.
> Sorry, my yesterday had to be spent on... other stuff.

Yeah, not worries, I spend most of the weekend preparing and then having
a birthday party for my (now 3 year old) daughter :-)

> I'm sleeping at present (well, not quite) and preparing a reply in
> the interstices of my sleep - if I don't change my mind before
> answering, I still think shmem needs Linus's (or my) patch.

Oh, absolutely. I wasn't arguing it didn't need it. I was merely
pointing out that if one was to add to Linus' patch such that we'd only
do the force_flush for mapping_cap_account_dirty() we wouldn't need
extra things to deal with shmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
