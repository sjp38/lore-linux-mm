Date: Thu, 4 Aug 2005 10:34:24 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: NUMA policy interface
In-Reply-To: <20050804170803.GB8266@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0508041011590.7314@graphe.net>
References: <20050730181418.65caed1f.pj@sgi.com> <Pine.LNX.4.62.0507301814540.31359@graphe.net>
 <20050730190126.6bec9186.pj@sgi.com> <Pine.LNX.4.62.0507301904420.31882@graphe.net>
 <20050730191228.15b71533.pj@sgi.com> <Pine.LNX.4.62.0508011147030.5541@graphe.net>
 <20050803084849.GB10895@wotan.suse.de> <Pine.LNX.4.62.0508040704590.3319@graphe.net>
 <20050804142942.GY8266@wotan.suse.de> <Pine.LNX.4.62.0508040922110.6650@graphe.net>
 <20050804170803.GB8266@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Aug 2005, Andi Kleen wrote:

> > So your point of view is that there will be no control and monitoring of 
> > the memory usage and policies?
> 
> External control is implemented for named objects and for process policy.
> A process can also monitor its own policies if it wants.

Named objects like files and not processes and/or threads? But then these 
named objects do not have memory allocated to them.

> I think the payoff for external monitoring of policies vs complexity 
> and cleanliness of interface and long term code impact is too bad to make 
> it an attractive option.

Well the implementation has the following issues right now:

1. BIND policy implemented in a way that fills up nodes from the lowest 
   to the higest instead of allocating memory on the local node.

2. No separation between sys_ and do_ functions. Therefore difficult
   to use from kernel context.

3. Functions have weird side effect (f.e. get_nodes updating 
   and using cpuset policies). Code is therefore difficult 
   to maintain.

4. Uses bitmaps instead of nodemask_t.

5. No means to figure out where the memory was allocated although
   mempoliy.c implements scans over ptes that would allow that 
   determination.
 
6. Needs hook into page migration layer to move pages to either conform
   to policy or to move them menually.

The long term impact of this missing functionality is already showing 
in the numbers of workarounds that I have seen at a various sites, 

The code is currently complex and difficult to handle because some of the 
issues mentioned above. We need to fix this in order to have clean code 
and in order to control future complexity.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
