From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Date: Thu, 28 Jun 2007 00:01:16 +0200
References: <20070625195224.21210.89898.sendpatchset@localhost> <1182968078.4948.30.camel@localhost> <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200706280001.16383.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

> The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> RCU lock must be held over the call into the page allocator with reclaim 
> etc etc. Note that the zonelist is part of the policy structure.

Yes I realized this at some point too. RCU doesn't work here because
__alloc_pages can sleep. Have to use the reference counts even though
it adds atomic operations.

> I think one prerequisite to memory policy uses like this is work out how a 
> memory policy can be handled by the page allocator in such a way that
> 
> 1. The use is lightweight and does not impact performance.

The current mempolicies are all lightweight and zero cost in the main
allocator path.

The only outlier is still cpusets which does strange stuff, but you
can't blame mempolicies for that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
