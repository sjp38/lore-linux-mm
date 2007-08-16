Subject: Re: [PATCH/RFC] memoryless nodes - fixup uses of node_online_map
	in generic code
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708161130570.16816@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
	 <1186085994.5040.98.camel@localhost>
	 <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
	 <1186611582.5055.95.camel@localhost>
	 <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
	 <1187273853.5900.21.camel@localhost>
	 <Pine.LNX.4.64.0708161130570.16816@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 16 Aug 2007 15:15:04 -0400
Message-Id: <1187291704.5900.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-16 at 11:33 -0700, Christoph Lameter wrote:
> On Thu, 16 Aug 2007, Lee Schermerhorn wrote:
> 
> > Note questions about use of N_HIGH_MEMORY in find_next_best_node() and
> > population of N_HIGH_MEMORY in early_calculate_totalpages().
> > 
> > Comments?
> 
> The changes in early_calculate_totalpages duplicate the setting of the bit 
> in the N_HIGH_MEMORY map. But that could be removed with an additional 
> patch if we are sure that early_calculate_totalpages is always called.
> 
> Otherwise it looks fine.
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> > mm/page_alloc.c:find_next_best_node()
> > 
> > 	skip nodes w/o memory.
> > 	N_HIGH_MEMORY state mask may not be initialized at this time,
> > 	unless we want to depend on early_calculate_totalpages() [see
> > 	below].  Will ZONE_MOVABLE ever be configurable?
> 
> Hopefully it will be removed at some point.

That was my concern.  I've heard that mentioned, so I didn't want to
depend on the early_calculate_totalpages().  It's only called from the
zone_movable setup, so I expect it will go away when zone movable goes.

Maybe we could move the populating of N_*_MEMORY to
free_area_init_nodes().  There's a loop over all on-line nodes there
that calls free_area_init_node() from whence calculate_node_totalpages()
is called.  On return from free_area_init_node(), the node's
node_present_pages has been set.   I'll work up and test an additional
patch.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
