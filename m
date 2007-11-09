Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9IGCOW032250
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:16:12 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lA9IGC4n457758
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:16:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9IGBe1011360
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 13:16:12 -0500
Date: Fri, 9 Nov 2007 10:16:07 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
Message-ID: <20071109181607.GI7507@us.ibm.com>
References: <20071109143226.23540.12907.sendpatchset@skynet.skynet.ie> <20071109143426.23540.44459.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0711090741120.13932@schroedinger.engr.sgi.com> <20071109161455.GB32088@skynet.ie> <20071109164537.GG7507@us.ibm.com> <1194628732.5296.14.camel@localhost> <Pine.LNX.4.64.0711090924210.14572@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711090924210.14572@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On 09.11.2007 [09:26:01 -0800], Christoph Lameter wrote:
> On Fri, 9 Nov 2007, Lee Schermerhorn wrote:
> 
> > > On the other hand, if we call alloc_pages() with GFP_THISNODE set, there
> > > is no nid to base the allocation on, so we "fallback" to numa_node_id()
> > > [ almost like the nid had been specified as -1 ].
> > > 
> > > So I guess this is logical -- but I wonder, do we have any callers of
> > > alloc_pages(GFP_THISNODE) ? It seems like an odd thing to do, when
> > > alloc_pages_node() exists?
> > 
> > I don't know if we have any current callers that do this, but absent any
> > documentation specifying otherwise, Mel's implementation matches what
> > I'd expect the behavior to be if I DID call alloc_pages with 'THISNODE.
> > However, we could specify that THISNODE is ignored in __alloc_pages()
> > and recommend the use of alloc_pages_node() passing numa_node_id() as
> > the nid parameter to achieve the behavior.  This would eliminate the
> > check for 'THISNODE in __alloc_pages().  Just mask it off before calling
> > down to __alloc_pages_internal().
> > 
> > Does this make sense?
> 
> I like consistency. If someone absolutely wants a local page then
> specifying GFP_THISNODE to __alloc_pages is okay. Leave as is I guess. 

Fair enough.

> What happens though if an MPOL_BIND policy is in effect? The node used
> must then be the nearest node from the policy mask....

Indeed, this probably needs to be validated... Sigh, more interleaving
of policies and everything else...

-Nish


-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
