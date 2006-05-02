Message-ID: <4456D5ED.2040202@yahoo.com.au>
Date: Tue, 02 May 2006 13:45:49 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan>
In-Reply-To: <20060430172953.409399000@zion.home.lan>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: blaisorblade@yahoo.it
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

blaisorblade@yahoo.it wrote:

> The first idea is to use this for UML - it must create a lot of single page
> mappings, and managing them through separate VMAs is slow.

I don't know about this. The patches add some complexity, I guess because
we now have vmas which cannot communicate the protectedness of the pages.
Still, nobody was too concerned about nonlinear mappings doing the same
for addressing. But this does seem to add more overhead to the common cases
in the VM :(

Now I didn't follow the earlier discussions on this much, but let me try
making a few silly comments to get things going again (cc'ed linux-mm).

I think I would rather this all just folded under VM_NONLINEAR rather than
having this extra MANYPROTS thing, no? (you're already doing that in one
direction).

> 
> Additional note: this idea, with some further refinements (which I'll code after
> this chunk is accepted), will allow to reduce the number of used VMAs for most
> userspace programs - in particular, it will allow to avoid creating one VMA for
> one guard pages (which has PROT_NONE) - forcing PROT_NONE on that page will be
> enough.

I think that's silly. Your VM_MANYPROTS|VM_NONLINEAR vmas will cause more
overhead in faulting and reclaim.

It loooks like it would take an hour or two just to code up a patch which
puts a VM_GUARDPAGES flag into the vma, and tells the free area allocator
to skip vm_start-1 .. vm_end+1. What kind of troubles has prevented
something simple and easy like that from going in?

> 
> This will be useful since the VMA lookup at fault time can be a bottleneck for
> some programs (I've received a report about this from Ulrich Drepper and I've
> been told that also Val Henson from Intel is interested about this). I guess
> that since we use RB-trees, the slowness is also due to the poor cache locality
> of RB-trees (since RB nodes are within VMAs but aren't accessed together with
> their content), compared for instance with radix trees where the lookup has high
> cache locality (but they have however space usage problems, possibly bigger, on
> 64-bit machines).

Let's try get back to the good old days when people actually reported
their bugs (togther will *real* numbers) to the mailing lists. That way,
everybody gets to think about and discuss the problem.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
