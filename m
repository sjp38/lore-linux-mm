Date: Thu, 26 Feb 2004 22:58:09 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mapped page in prep_new_page()..
Message-Id: <20040226225809.669d275a.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
References: <Pine.LNX.4.58.0402262230040.2563@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: hch@infradead.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@osdl.org> wrote:
>
> Hmm.. I've never seen this before myself, but I know there have been
> similar reports.

There have been a few.  I don't recall seeing any against x86.

> Earlier today I got
> 
> 	Bad page state at prep_new_page
> 	flags:0x00000000 mapping:0000000000000000 mapped:1 count:0

But you did not get a trace for a mapped page being freed up prior to this?

> which I didn't even notice initially (it happened at 4:04 AM, apparently 
> during the nigthly cron run). Now, it claims to try to fix things up, but 
> for "page_mapped(page)" that isn't true - it leaves the page pte pointers 
> alone (it should probably clear the rmap list).

Yes, I don't think we can sanely fix all these conditions.  If we really
want to keep limping along we should just leak the page in
__free_pages_ok(), and leak the page then pick a new one in
__alloc_pages().  This shouldn't be worth the effort, of course.

> 	Oops: Kernel access of bad area, sig: 11 [#1]
> 	SMP NR_CPUS=2 
> 	NIP: C00000000008D7C4 XER: 0000000020000000 LR: C000000000086F70
> 	REGS: c00000007a43b7f0 TRAP: 0300    Not tainted
> 	MSR: 9000000000009032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
> 	DAR: 0000005f00000008, DSISR: 0000000040000000
> 	TASK: c000000059819b20[8510] 'bk' THREAD: c00000007a438000 CPU: 0
> 	GPR00: 0000000000000000 C00000007A43BA70 C0000000006AD0D0 C000000000FFFFC0 
> 	GPR04: C00000002CBC30F0 C000000032F2F200 C000000002FD64D0 C0000000004D8050 
> 	GPR08: 0000000002AFE480 0000000000000000 0000005F00000000 0000000000000004 
> 	GPR12: 0000000042008488 C0000000004E0000 0000000002000000 0000000011A1E004 
> 	GPR16: C00000005EC23400 0000000000000050 C000000054447000 4000000000000000 
> 	GPR20: C0000000005714C8 C0000000006F6B80 0000000000001580 C000000032F2F200 
> 	GPR24: 0000000000532000 0000000000000532 C00000000072FFB8 C000000000FFFFC0 
> 	GPR28: CCCCCCCCCCCCCCCD 00000001A88C0397 C000000000586978 C00000002CBC30F0 
> 	NIP [c00000000008d7c4] .page_add_rmap+0xb4/0x1b4
> 	LR [c000000000086f70] .do_anonymous_page+0x314/0x50c
> 	Call Trace:
> 	[c000000000087204] .do_no_page+0x9c/0x570
> 	[c0000000000879b0] .handle_mm_fault+0x1b0/0x26c
> 	[c0000000000431c8] .do_page_fault+0x120/0x3f8
> 	[c00000000000aa94] stab_bolted_user_return+0x118/0x11c

So what is the access address here?  That will tell us what value was in
page.pte.chain.


>  - does anybody have any idea why the page had been left mapped when 
>    free'd, without the test triggering in free_pages_check()? Memory 
>    corruption? Has anybody ever seen any pattern to this?

I've seen no pattern to it - there have only been two or three reports I
think.  Probably we should print the entire pageframe, see if that pte
pointer looks like a real address.

It's interesting that the page->flags is zero all the time.  Tends to
indicate that nobody is using it for much.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
