Date: Thu, 19 Feb 2004 08:15:56 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040219161556.GA2472@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040218211035.A13866@infradead.org> <20040218150607.GE1269@us.ibm.com> <20040218222138.A14585@infradead.org> <20040218145132.460214b5.akpm@osdl.org> <20040218230055.A14889@infradead.org> <20040218162858.2a230401.akpm@osdl.org> <20040219123110.A22406@infradead.org> <20040219091129.GD1269@us.ibm.com> <20040219183210.GX14000@marowsky-bree.de> <20040219191633.GD31035@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040219191633.GD31035@parcelfarce.linux.theplanet.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: viro@parcelfarce.linux.theplanet.co.uk
Cc: Lars Marowsky-Bree <lmb@suse.de>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, torvalds@osd.org, arjanv@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 19, 2004 at 07:16:33PM +0000, viro@parcelfarce.linux.theplanet.co.uk wrote:
> On Thu, Feb 19, 2004 at 07:32:10PM +0100, Lars Marowsky-Bree wrote:
> > Only if we can settle this, we can answer this export question. If we
> > want to allow them, the export is a perfectly reasonable thing to ask
> > for. If not, we probably need to add a few more _GPL barriers.
> > 
> > A rule of thumb might be whether any code in the tree uses a given
> > export, and if not, prune it. Anything which even we don't use or export
> > across the user-land boundary certainly qualifies as a kernel interna.
> > 
> > Currently, no kernel module seems to use this export. So I'd think such
> > a point could certainly be made.

Good questions, see below for my nominations for the answers.

> I'm not sure.  I'm all for trimming the export list, but the real questions
> are
> 	* does that export make sense?

		Yes, invalidate_mmap_range() permits a distributed
		filesystem to shoot down mmap()s of a to-be-modified file
		so that all nodes see a consistent view of that file's
		data.  Having an export means that this functionality
		need not be reproduced in each and every DFS, reducing
		DFS intrusiveness.

		Of course, the issue pointed out by Daniel does need
		to be addressed.  More on that shortly.

> 	* does it impose extra restrictions on what we can do with core
> code? (without breaking it, that is)

		The invalidate_mmap_range() API is pretty generic.
		It takes an address_space structure, an offset, and a
		length.  The caller can treat the address_space structure
		pointer as a cookie, so the only sorts of changes that
		could break this API would be ones that entirely did away
		with the concept of an address space.  Or that introduced
		the concept of a file with non-integer offsets, in which
		case invalidate_mmap_range() is the least of our worries.

		Either case could happen, I suppose, but both seem a
		bit unlikely.

> 	* is it needed in the first place?  If it's redundant - to hell it
> goes.

		Yes, to prevent DFSes from having to reach so far
		into the guts of the Linux VM system.

							Thanx, Paul

> Note that majority of the exported symbols fail at least one of the above
> and _that_ is why they should be killed.  Whether their users are GPL or
> not doesn't matter - if they don't make sense, they must die, no matter
> what b0rken code might be using them.
> 
> IMNSHO the questions above should be answered first and AFAICS they hadn't
> been even discussed in that case.
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
