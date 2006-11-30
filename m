Date: Wed, 29 Nov 2006 18:37:31 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456E3E98.5010706@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291822420.3513@woody.osdl.org>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
 <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
 <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au>
 <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org> <456E36A7.2050401@yahoo.com.au>
 <Pine.LNX.4.64.0611291755310.3513@woody.osdl.org> <456E3E98.5010706@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 30 Nov 2006, Nick Piggin wrote:
>
> > In contrast, a "pdt_t" can be "unsigned long" or an anonymous struct, or
> > anything else. A "u64" can be "unsigned long long" or "unsigned long"
> > depending on architecture, etc. But a "struct kmem_cache" is always a
> > "struct kmem_cache". 
> 
> Oh yeah, I was thinking you could put it in a struct anyway, but I get
> your point about struct passing performance (even if it doesn't happen
> much in the vm code).

These days, we probably could always make "pdt_t" and friends always be 
structures. That particular typedef harks back to an older age, when gcc 
generated much worse code for structures than for "unsigned long" (it 
still does for explicit calls, but for inline functions it _mostly_ 
generates identical code).

So iirc, there was literally a "type safety" config option that turned on 
the structure version (because that one caught misuses with compiler 
typechecking and nasty warnings), and then the totally standard "unsigned 
long" thing (which generated better code).

I don't remember when we got rid of the "structure or unsigned long" 
option, it must have been a long time ago. But it explains why that 
particular thing is a typedef (and by now, I'd hate to untypedef it, 
since the whole "pgt_t pgd" thing has become something of a pattern in 
the VM layer, so it would irritate me mightily to change an existing 
mental pattern that's been around for a decade or more by now).

And it really still is "unsigned long" on some architectures, and I have 
this dim memory of it being because struct passing was really horrid on 
some architecture (like HP-PA that had lots of out-of-line calls because 
of the page table functions needing a lot of massaging? I forget).

[ Oh, actually - looking at <asm-parisc/page.h>, I see that they still 
  have the "STRICT_MM_TYPECHECKS" config option. That's what it was called 
  on i386 too, and it seems the remnants are still around on various 
  architecures. Although it can't have been parisc that had code 
  generation trouble, because that one selects the strict typechecks by 
  default.. Maybe ARM? ]

> I guess I'm not arguing to use the typedef so much as I wanted to know why
> it is being removed (ie. why now). Do you think that avoiding the slab.h
> include when some code just needs a struct kmem_cache * is a good policy?

I don't generally think it's a huge deal, but on general principles I do 
tend to prefer not seeing typedef's unless there's a reason for it, which 
is why I'd support this kind of patch.

This particular one doesn't disturb me the way some have done. I literally 
asked for the "task_t" typedef to be removed (ugh, that one _really_ 
irritated me, especially since code mixed the two, and "struct 
task_struct" was the traditional and long-standing way to do it).

On the other hand, if it actually causes pain (eg merge issues etc), it's 
definitely not important enough to do. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
