Date: Sun, 21 Aug 2005 20:32:37 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use deltas to replace atomic inc
In-Reply-To: <20050820005843.21ba4d9b.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
 <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
 <20050820005843.21ba4d9b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 20 Aug 2005, Andrew Morton wrote:

> Christoph Lameter <clameter@engr.sgi.com> wrote:
> >
> >  @@ -508,6 +508,16 @@ static int unuse_mm(struct mm_struct *mm
> >   {
> >   	struct vm_area_struct *vma;
> >   
> >  +	/*
> >  +	 * Ensure that existing deltas are charged to the current mm since
> >  +	 * we will charge the next batch manually to the target mm
> >  +	 */
> >  +	if (current->mm && mm_counter_updates_pending(current)) {
> 
> Is there a race window right here?

Why? current is tied to a thread.

The thing that bothers me more is that schedule() can be called both by 
handle_mm_fault as well as during unuse_mm. We may need some flag 
PF_NO_COUNTER_UPDATES or so there to insure that schedule() does not add 
deltas to the current->mm.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
