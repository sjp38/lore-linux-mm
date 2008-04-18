Date: Fri, 18 Apr 2008 07:40:14 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/2]: introduce fast_gup
In-Reply-To: <Pine.LNX.4.64.0804180831000.9489@anakin>
Message-ID: <alpine.LFD.1.00.0804180734530.2879@woody.linux-foundation.org>
References: <20080328025455.GA8083@wotan.suse.de> <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins> <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org> <1208448768.7115.30.camel@twins> <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org>
 <1208450119.7115.36.camel@twins> <alpine.LFD.1.00.0804170940270.2879@woody.linux-foundation.org> <1208453014.7115.39.camel@twins> <Pine.LNX.4.64.0804180831000.9489@anakin>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>


On Fri, 18 Apr 2008, Geert Uytterhoeven wrote:
> On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> > +retry:
> > +	pte.pte_low = ptep->pte_low;
> > +	smp_rmb();
> > +	pte.pte_high = ptep->pte_high;
> > +	smp_rmb();
> > +	if (unlikely(pte.pte_low != ptep->pte_low))
> > +		goto retry;
> 
> What about using `do { ... } while (...)' instead?

Partly because it's not a loop. It's an error and retry event, and it 
generally happens zero times (and sometimes once). I don't think it should 
even _look_ like a loop.

So personally, I just tend to think that it's just more readable when it's 
written as being obviously not a regular loop. I'm not in the "gotos are 
harmful" camp.

And partly because I tend to distrust loops for these thigns is that 
historically gcc sometimes did stupid things for loops (it assumed that 
loops were hot and tried to align them etc, and the same didn't happen for 
branch targets). Of course, these days I suspect gcc can't even tell the 
difference any more (it probably turns it into the same internal 
representation), but old habits die hard.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
