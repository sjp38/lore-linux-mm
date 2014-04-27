From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Dirty/Access bits vs. page content
Date: Mon, 28 Apr 2014 09:13:01 +1000
Message-ID: <1398640381.8437.82.camel@pasglop>
References: <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
	 <1398389846.8437.6.camel@pasglop> <1398393700.8437.22.camel@pasglop>
	 <CA+55aFyO+-GehPiOAPy7-N0ejFrsNupWHG+j5hAs=R=RuPQtDg@mail.gmail.com>
	 <5359CD7C.5020604@zytor.com>
	 <CA+55aFzktDDr5zNh-7gDhXW6-7_BP_MvKHEoLi9=td6XvwzaUA@mail.gmail.com>
	 <alpine.LSU.2.11.1404250414590.5198@eggly.anvils>
	 <20140425135101.GE11096@twins.programming.kicks-ass.net>
	 <alpine.LSU.2.11.1404251215280.5909@eggly.anvils>
	 <20140426180711.GM26782@laptop.programming.kicks-ass.net>
	 <20140427072034.GC1429@laptop.programming.kicks-ass.net>
	 <CA+55aFwLumAqA6mYyPKRZYOCr2TRPxUVdCKhHMg0nYN_KbBDbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwLumAqA6mYyPKRZYOCr2TRPxUVdCKhHMg0nYN_KbBDbQ@mail.gmail.com>
Sender: linux-arch-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>
List-Id: linux-mm.kvack.org

On Sun, 2014-04-27 at 09:21 -0700, Linus Torvalds wrote:

> So in theory a CPU could just remember what address it loaded the TLB
> entry from, and do a blind "set the dirty bit" with just an atomic
> "or" operation. In fact, for a while I thought that CPU's could do
> that, and the TLB flushing sequence would be:
> 
>     entry = atomic_xchg(pte, 0);
>     flush_tlb();
>     entry |= *pte;
> 
> so that we'd catch any races with the A/D bit getting set.
>
> It turns out no CPU actually does that, and I'm not sure we ever had
> that code sequence in the kernel (but some code archaeologist might go
> look).

Today hash based powerpc's do the update in the hash table using a byte
store, not an atomic compare. That's one of the reasons we don't
currently exploit the HW facility for dirty/accessed. (There are others,
such as pages being evicted from the hash, we would need a path to
transfer dirty back to the struct page, etc...)

 .../...

> Of course, *If* a CPU were to remember the address it loaded the TLB
> entry from, then such a CPU might as well make the TLB be part of the
> cache-coherency domain, and then we wouldn't need to do any TLB
> flushing at all. I wish.

Hrm... Remembering the address as part of the data is one thing, having
it in the tag for snoops is another :) I can see CPU designers wanting
to do the first and not the second.... Though most CPUs I've seen are 4
or 8 ways set-associative so it's not as bad as adding a big CAM
thankfully.

> > Will the hardware fault when it does a translation and needs to update
> > the dirty/access bits while the PTE entry is !present?
> 
> Yes indeed, see above (but see how broken hardware _could_ work, which
> would be really painful for us).
> 
> What we are fighting is race #3: the TLB happily exists on this or
> other CPU's, an dis _not_ getting updated (so no re-walk), but _is_
> getting used.

Right, and it's little brother which is that the update and the access
that caused it aren't atomic with each other, thus the access can be
seen some time after the R/C update. (This was my original concern until
I realized that it was in fact the same race as the dirty TLB entry
still in the other CPUs).

Cheers,
Ben.
