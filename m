Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from
	MPOL_INTERLEAVE masks
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070802173825.GA7815@linux.intel.com>
References: <1185566878.5069.123.camel@localhost>
	 <200708011233.02103.ak@suse.de> <20070801110120.GA9449@linux-sh.org>
	 <200708011307.44189.ak@suse.de> <20070801112116.GA9617@linux-sh.org>
	 <1185976446.5059.27.camel@localhost>
	 <20070802173825.GA7815@linux.intel.com>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 14:46:03 -0400
Message-Id: <1186080363.5040.63.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 10:38 -0700, Mark Gross wrote:
> On Wed, Aug 01, 2007 at 09:54:06AM -0400, Lee Schermerhorn wrote:
> > On Wed, 2007-08-01 at 20:21 +0900, Paul Mundt wrote:
> > > On Wed, Aug 01, 2007 at 01:07:43PM +0200, Andi Kleen wrote:
> > > > 
> > > > > As long as interleaving is possible after boot, then yes. It's only the
> > > > > boot-time interleave that we would like to avoid,
> > > > 
> > > > But when anybody does interleaving later it could just as easily
> > > > fill up your small nodes, couldn't it?
> > > > 
> > > Yes, but these are in embedded environments where we have control over
> > > what the applications are doing. Most of these sorts of things are for
> > > applications where we know what sort of latency requires we have to deal
> > > with, and so the workload is very much tied to the worst-case range of
> > > nodes, or just to a particular node. We might only have certain buffers
> > > that need to be backed by faster memory as well, so while most of the
> > > application pages will come from node 0 (system memory), certain other
> > > allocations will come from other nodes. We've been experimenting with
> > > doing that through tmpfs with mpol tuning.
> > > 
> > > In the general case however it's fairly safe to include the tiny nodes as
> > > part of a larger set with a prefer policy so we don't immediately OOM.
> > > 
> > > > Boot time allocations are small compared to what user space
> > > > later can allocate.
> > > > 
> > > Yes, we only want certain applications to explicitly poke at those nodes,
> > > but they do have a use case for interleave, so it is not functionality I
> > > would want to lose completely.
> > 
> > This is why I wanted to use an "obscure boot option".  I don't see this
> > as strictly an architectural/platform issue.  Rather, it's a combination
> > of the arch/platform and how it's being used for specific applications.
> > So, I don't see how one could accomplish this with a heuristic.
> > 
> > As Paul mentioned, in embedded systems, one has a bit more control over
> > what applications are doing.  In that case, I could envision a config
> > option to specify the initial/default value for the no_interleave_nodes
> > at kernel build time and dispense with the boot option.  [Any interest
> 
> Having the interleave as a build time option won't work for some power
> managed memory applications.  I posted an RFC a few months back and will
> be coming back to it in a few weeks, so take this comment with a grain
> of salt.  But I want to be able to switch on some ACPI table entries to
> trigger the non-interleave boot time allocation behavior for some FBDIM
> based platforms.  My needs are in surprising alignment with Paul's on
> this stuff.
> 
> 
> --mgross
<snip>

Mark:  you mean "boot time option", right?

When you get back to it, can you verify that this patch won't affect
what you want to do in policy init [boot time interleave mask]--?  ...as
long as no one specifies any no_interleave_nodes, of course.  And even
then, all that happens is that maybe more nodes get excluded from the
boot time policy mask than you would have excluded based on ACPI info.  

Until you have the ACPI table info and parsing in place [or maybe you
already have this], this patch could allow you to test with the desired
nodes excluded...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
