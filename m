Date: Tue, 5 Jul 2005 11:11:19 -0400
From: Sonny Rao <sonny@burdell.org>
Subject: Re: [rfc] lockless pagecache
Message-ID: <20050705151119.GA12279@kevlar.burdell.org>
References: <Pine.LNX.4.62.0506271221540.21616@graphe.net> <200506271942.j5RJgig23410@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200506271942.j5RJgig23410@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Christoph Lameter' <christoph@lameter.com>, 'Badari Pulavarty' <pbadari@us.ibm.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>, Lincoln Dale <ltd@cisco.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 12:42:44PM -0700, Chen, Kenneth W wrote:
> Christoph Lameter wrote on Monday, June 27, 2005 12:23 PM
> > On Mon, 27 Jun 2005, Chen, Kenneth W wrote:
> > > I don't recall seeing tree_lock to be a problem for DSS workload either.
> > 
> > I have seen the tree_lock being a problem a number of times with large 
> > scale NUMA type workloads.
> 
> I totally agree!  My earlier posts are strictly referring to industry
> standard db workloads (OLTP, DSS).  I'm not saying it's not a problem
> for everyone :-)  Obviously you just outlined a few ....

I'm a bit late to the party here (was gone on vacation), but I do have
profiles from DSS workloads using page-cache rather than O_DIRECT and
I do see spin_lock_irq() in the profiles which I'm pretty certain are
locks spinning for access to the radix_tree.  I'll talk about it a bit
more up in Ottawa but here's the top 5 on my profile (sorry don't have
the number of ticks at the momement):

1. dedicated_idle (waiting for I/O)
2. __copy_tofrom_user
3. radix_tree_delete
4. _spin_lock_irq
5. __find_get_block

So, yes, if the page-cache is used in a DSS workload then one will see
the tree-lock.  BTW, this was on a PPC64 machine w/ a fairly small
NUMA factor.

Sonny
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
