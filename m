Date: Wed, 21 Jun 2006 10:06:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/14] Zoned VM counters V5
In-Reply-To: <44997596.7050903@google.com>
Message-ID: <Pine.LNX.4.64.0606211001370.19596@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <44997596.7050903@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: akpm@osdl.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Martin J. Bligh wrote:

> Having the per-cpu counters with a global overflow seems like a really
> nice way to do counters to me - is it worth doing this as a more
> generalized counter type so that others could use it?

Yes later patches also use the counters for other things. Please check out 
the patch that uses these for numa counters etc.

> OTOH, I'm unsure why we're only using 8 bits in struct zone, which isn't
> size critical. Is it just so you can pack vast numbers of different stats into
> a single cacheline?

I would like to add some stats in the future. 8 bits is sufficient if the 
threshold is less than 64 (currently its 32). If we ever get higher then 
we can simply go to a bigger base size.

However, the space used by that array is
 
<nr-of-counters>*<nr_of_processors>*<nr_of_zones>

There are systems that have around 1k nodes and 4k processors. Lets say 
we have 16 counters then we get to

1k*4k*16 = 64Mbyte just for the counters.

This doubles for a short and quadruples for an int.

Also smaller counters help keep the pcp structure in one cacheline and 
reduces the cache footprint. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
