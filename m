Subject: Re: [RFC] Event counters [1/3]: Basic counter functionality
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <20060102214016.GA13905@dmt.cnet>
References: <20051220235733.30925.55642.sendpatchset@schroedinger.engr.sgi.com>
	 <20051231064615.GB11069@dmt.cnet> <43B63931.6000307@yahoo.com.au>
	 <20051231202602.GC3903@dmt.cnet>  <20060102214016.GA13905@dmt.cnet>
Content-Type: text/plain
Date: Tue, 03 Jan 2006 16:11:46 +1100
Message-Id: <1136265106.5261.34.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@sgi.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-01-02 at 19:40 -0200, Marcelo Tosatti wrote:

> Nick, 
> 
> The following patch:
> 
> - Moves the lightweight "inc/dec" versions of mod_page_state variants
> to three underscores, making those the default for locations where enough
> locks are held.
> 

I guess I was hoping to try to keep it simple, and just have two
variants, the __ version would require the caller to do the locking.
In cases like eg. allocstall, they should happen infrequently enough
that the extra complexity is probably not worth worrying about.

I don't think I commented about the preempt race though (and requirement
to have preempt off from process context), which obviously can be a
problem as you say (though I think things are currently safe?).

> - Make the two-underscore version disable and enable preemption, which 
> is required to avoid preempt-related races which can result in missed
> updates.
> 
> - Extends the lightweight version usage in page reclaim, 
> pte allocation, and a few other codepaths.
> 

I guess nr_dirty looks OK in the places it can be put under tree_lock.

nr_page_table_pages is OK because ptl should be held to prevent preempt.

pgrotated and pgactivate should be good because of lru_lock.

Thanks for going through these!

-- 
SUSE Labs, Novell Inc.



Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
