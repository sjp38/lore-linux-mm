Date: Mon, 2 Oct 2006 01:41:21 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061002014121.28b759da.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<20061001231811.26f91c47.pj@sgi.com>
	<Pine.LNX.4.64N.0610012330110.10476@attu4.cs.washington.edu>
	<20061001234858.fe91109e.pj@sgi.com>
	<Pine.LNX.4.64N.0610020001240.7510@attu3.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

David wrote:
> I'm talking about this:
> 
> +struct zonelist_faster {
> +	nodemask_t fullnodes;		/* nodes recently lacking free memory */
> +	unsigned long last_full_zap;	/* jiffies when fullnodes last zero'd */
> +	unsigned short node_id[MAX_NUMNODES * MAX_NR_ZONES]; /* zone -> nid */
> +};
> 
> With NODES_SHIFT equal to 10 as you recommend, you can't get away with an 
> unsigned short there. 


Apparently it's time for me to be a stupid git again.  That's ok; I'm
getting quite accustomed to it.

Could you spell out exactly why I can't get away with an unsigned short
node_id if NODES_SHIFT is 10?

I was thinking that limiting node_id to an unsigned short just meant
that we couldn't have more than 65536 nodes on the system.  That should
be enough, for a while anyway.

Indeed, given this line in include/linux/mempolicy.h:

	short            preferred_node;

I didn't even think I was being very original in this.


> Likewise, your nodemask_t would need to be 128 bytes.

Yes - big honkin NUMA iron calls for big nodemasks.  That's part of
why I spent the better part of a year driving Andrew to drink with
my cpumask/nodemask patches from hell.

Is there a problem with a 128 byte nodemask_t that I'm missing?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
