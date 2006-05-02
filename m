Subject: Re: [patch 00/14] remap_file_pages protection support
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4456D5ED.2040202@yahoo.com.au>
References: <20060430172953.409399000@zion.home.lan>
	 <4456D5ED.2040202@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 02 May 2006 13:16:46 -0400
Message-Id: <1146590207.5202.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: blaisorblade@yahoo.it, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-05-02 at 13:45 +1000, Nick Piggin wrote:
> blaisorblade@yahoo.it wrote:
> 
> > The first idea is to use this for UML - it must create a lot of single page
> > mappings, and managing them through separate VMAs is slow.
> 
> I don't know about this. The patches add some complexity, I guess because
> we now have vmas which cannot communicate the protectedness of the pages.
> Still, nobody was too concerned about nonlinear mappings doing the same
> for addressing. But this does seem to add more overhead to the common cases
> in the VM :(
> 
> Now I didn't follow the earlier discussions on this much, but let me try
> making a few silly comments to get things going again (cc'ed linux-mm).
> 
> I think I would rather this all just folded under VM_NONLINEAR rather than
> having this extra MANYPROTS thing, no? (you're already doing that in one
> direction).
<snip>

One way I've seen this done on other systems is to use something like a
prio tree [e.g., see the shared policy support for shmem] for sub-vma
protection ranges.  Most vmas [I'm guessing here] will have only the
original protections or will be reprotected in toto.  So, one need only
allocate/populate the protection tree when sub-vma protections are
requested.   Then, one can test protections via the vma, perhaps with
access/check macros to hide the existence of the protection tree.  Of
course, adding a tree-like structure could introduce locking
complications/overhead in some paths where we'd rather not [just
guessing again].  Might be more overhead than just mucking with the ptes
[for UML], but would keep the ptes in sync with the vma's view of
"protectedness".

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
