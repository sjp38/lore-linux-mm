Date: Tue, 28 Feb 2006 14:05:40 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: unuse_pte: set pte dirty if the page is dirty
In-Reply-To: <Pine.LNX.4.64.0602272117180.15738@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602281346060.7504@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602271731410.14242@schroedinger.engr.sgi.com>
 <20060227175324.229860ca.akpm@osdl.org> <Pine.LNX.4.64.0602271755070.14367@schroedinger.engr.sgi.com>
 <20060227182137.3106a4cf.akpm@osdl.org> <Pine.LNX.4.64.0602272009100.15012@schroedinger.engr.sgi.com>
 <20060227203923.24e9336c.akpm@osdl.org> <Pine.LNX.4.64.0602272117180.15738@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Christoph Lameter wrote:
> 
> unuse_pte is used:
> 
> 1. To switch off a swap device.
> 
> 2. To reestablish ptes for a migrated anonymous page.
> 
> In both cases we are only dealing with anonymous pages. The only writer 
> can be the swap code and as far as I can tell the only risk is writing a 
> swap page out once again. That is if it would be cleaned by pageout().

I shared Andrew's unease, but couldn't put my finger on any actual
problem.  But in the course of writing a much more hesitant reply,
came to realize the patch is just bogus.  Did you ever measure any
improvement from it, on any architecture?  0% is my estimate.

I was recommending that the VM_WRITE test be replaced by a pte_write
test, when I remembered that vm_page_prot on any vma which contains
anonymous pages (excepting the very rare Linus ptrace case) will not
grant write access (see comment above unuse_pte).  So if this pte is
actually written to afterwards, you'll have to handle a write fault
on it, won't you?  No saving whatever from presetting dirty - or am
I misunderstanding how the architecture closest to your heart works?

I guess you could work around that by checking mapcount+swapcount
and granting write access in the common uniquely-mapped case; but
swapoff has never bothered to do so.  Unless you can come up with
convincing numbers, I'd say let it die - halve the time of a
significant migration testcase?  yes, we should make a patch;
shave 5% off it?  no, for peace of mind let's not worry about it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
