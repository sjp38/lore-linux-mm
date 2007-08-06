Subject: Re: [RFC][PATCH 1/5] Fix hugetlb pool allocation with empty nodes
	V9
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708061136260.3152@schroedinger.engr.sgi.com>
References: <20070806163254.GJ15714@us.ibm.com>
	 <20070806163726.GK15714@us.ibm.com>
	 <Pine.LNX.4.64.0708061059400.24256@schroedinger.engr.sgi.com>
	 <20070806181912.GS15714@us.ibm.com>
	 <Pine.LNX.4.64.0708061136260.3152@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 15:52:21 -0400
Message-Id: <1186429941.5065.24.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, wli@holomorphy.com, melgor@ie.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-06 at 11:37 -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Nishanth Aravamudan wrote:
> 
> > Uh, interleave_nodes() takes a policy. Hence I need a policy to use.
> > This was your suggestion, Christoph and I'm doing exactly what you
> > asked.
> 
> That would make sense if the policy can be overridden. You may be able to 
> avoid exporting mpol_new by callig just the functions that generate the 
> interleave nodes.

I don't understand what you're asking either.  The function that Nish is
allocating the initial free huge page pool.  I thought that the intended
behavior of this function was to distribute new allocated huge pages
evenly across the nodes.  It was broken, in that for systems with
memoryless nodes, the allocation would immediately fall back to the next
node in the zonelist, overloading that node with huge page.  

IMO, we should try to preserve the current behavior of nr_hugepages, as
"fixed" by Nish, and use the new per node sysfs attributes to handle or
fixup asymmetric allocation of hugepages, if required.

That being said, I was never a fan of using mempolicy for this.  Not
strongly opposed, just not a fan.  I'd like to see modification to
nr_hugepages, including incremental increase or decrease, try to keep
the number of huge pages balanced across the nodes.  Without breaking
any extra per node additions or deletions via the sysfs attribute.  I
had something in mind like remembering where the last change in
nr_hugepages left off [like the unpatched code with the static node id
variable did].  Thenm scan the mask of nodes with memory in one
direction when increasing nr_hugepages and in the opposite direction
when decreasing.  It'll be a while before I can put together a patch,
tho'.  In any case, I'd want to wait for the current memoryless node and
hugetlb patch streams to settle down.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
