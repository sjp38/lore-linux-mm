Message-ID: <4213D283.5090809@sgi.com>
Date: Wed, 16 Feb 2005 17:08:51 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: manual page migration -- issue list
References: <42128B25.9030206@sgi.com>	<20050215165106.61fd4954.pj@sgi.com>	<20050216015622.GB28354@lnx-holt.americas.sgi.com>	<20050215202214.4b833bf3.pj@sgi.com>	<20050216092011.GA6616@lnx-holt.americas.sgi.com> <20050216022009.7afb2e6d.pj@sgi.com>
In-Reply-To: <20050216022009.7afb2e6d.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Robin wrote:
> 
>>What that would result in is a syscall for each
>>non-overlapping vma per node.
> 
> 
> My latest, most radical, proposal did not take an address range.  It was
> simply:
> 
>     sys_page_migrate(pid, oldnode, newnode)
> 
> It would be called once per node.  In your example, this would be 128
> calls.  Nothing "for each non-overlapping vma".  Just per node.
> 
> Until I drove you to near distraction, and you spelled out the details
> of an example that migrated 96% of the address space in the first call,
> and only need 3 calls total, I would have presumed that the API:
> 
>     sys_page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes)
> 
> would have required one call per pid, or 256 calls, for your example.
> 
> My method did not look insanely worse to me, indeed it would have looked
> better in this example with two tasks per node, since I did one call per
> node, and I thought you did one per task.
> 
> ... However, I see now that you can routinely get by with dramatically
> fewer calls than the number of tasks, by noticing what portions of the
> typically huge shared address space have already been covered, and not
> covering them again.

Right, that was our original plan.  So you only had to make as many
system calls as there were address ranges that needed to be migrated,
more or less.  This assumes we have stopped processes and can read and
make sense of /proc/*/maps.

> 
> There is no need to convince me that 384 syscalls and 128 full scans
> is insanely worse than 3 syscalls with 1 full scan, and no need to
> get frustrated that I cannot see the insanity of it.
> 
> However, you might have wanted to allow for the possibility, when you
> reduced what you thought I was proposing to insanity, that rather than
> my proposing something insane, perhaps we had different numbers ... as
> happened here.  Your numbers for the array API had 80 times fewer system
> calls than I would have expected, and your numbers for the single
> parameter call had 3 times _more_ system calls than I had in mind (I had
> one call per node, period, not one per node per vma or whatever).
> 
> 
>>How much opposition is there to the array of integers?
> 
> 
> My opposition to the array was not profound.  It needed to provide
> an advantage, which I didn't see it much did.
> 
> I now see it provides an advantage, dramatically reducing the number of
> system calls and scans in typical cases, to substantially fewer than
> either the number of tasks or of nodes.
> 
> Ok ... onward.  I'll take the node arrays.
> 
> The next concern that rises to the top for me was best expressed by Andi:
> 
>>The main reasons for that is that I don't think external
>>processes should mess with virtual addresses of another process.
>>It just feels unclean and has many drawbacks (parsing /proc/*/maps
>>needs complicated user code, racy, locking difficult).  
>>
>>In kernel space handling full VMs is much easier and safer due to better 
>>locking facilities.
> 
> 
> I share Andi's concerns, but I don't see what to do about this.  Andi's
> recommendations seem to be about memory policies (which guide future
> allocations), and not about migration of already allocated physical
> pages.  So for now at least, his recommendations don't seem like answers
> to me.
> 


-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
