Received: by ug-out-1314.google.com with SMTP id s2so632231uge
        for <linux-mm@kvack.org>; Fri, 04 May 2007 15:39:18 -0700 (PDT)
Message-ID: <29495f1d0705041539o7d4d5b60iec870efcb5d8de7b@mail.gmail.com>
Date: Fri, 4 May 2007 15:39:17 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2
In-Reply-To: <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 5/4/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Fri, 4 May 2007, Lee Schermerhorn wrote:
>
> > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > An interesting bug was pointed out to me where we failed to allocate
> > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> >
> > Here's my attempt to fix the problem [I see it on HP platforms as well],
> > without removing the population check in build_zonelists_node().  Seems
> > to work.
>
> I think we need something like for_each_online_node for each node with
> memory otherwise we are going to replicate this all over the place for
> memoryless nodes. Add a nodemap for populated nodes?
>
> I.e.
>
> for_each_mem_node?
>
> Then you do not have to check the zone flags all the time. May avoid a lot
> of mess?

I agree -- and we'd keep hugetlb.c relatively node-unaware. hugetlb.c
would only need the nodemap, I believe, and we could just change

               nid = next_node(nid, node_online_map);
               if (nid == MAX_NUMNODES)
                       nid = first_node(node_online_map);

to use mem_node_map or whatever it would be called (node_mem_map looks
weird to me (why is it node_online_map but for_each_online_node() ?)

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
