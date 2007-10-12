Date: Fri, 12 Oct 2007 13:50:40 +0100
Subject: Re: [Libhugetlbfs-devel] [PATCH 2/4] hugetlb: Try to grow hugetlb pool for MAP_PRIVATE mappings
Message-ID: <20071012125039.GB27254@skynet.ie>
References: <20071001151736.12825.75984.stgit@kernel> <20071001151758.12825.26569.stgit@kernel> <1192140583.20859.40.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1192140583.20859.40.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, libhugetlbfs-devel@lists.sourceforge.net, Dave McCracken <dave.mccracken@oracle.com>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Bill Irwin <bill.irwin@oracle.com>
List-ID: <linux-mm.kvack.org>

On (11/10/07 15:09), Dave Hansen didst pronounce:
> On Mon, 2007-10-01 at 08:17 -0700, Adam Litke wrote:
> > 
> >         spin_lock(&hugetlb_lock);
> > -       enqueue_huge_page(page);
> > +       if (surplus_huge_pages_node[nid]) {
> > +               update_and_free_page(page);
> > +               surplus_huge_pages--;
> > +               surplus_huge_pages_node[nid]--;
> > +       } else {
> > +               enqueue_huge_page(page);
> > +       }
> >         spin_unlock(&hugetlb_lock);
> >  } 
> 
> Why does it matter that these surplus pages are tracked per-node?
> 

Because presumably one does not want to end up in a situation whereby
the pools were initially filled with balanced nodes for MPOL_INTERLEAVE
and get screwed up by dynamic page resizing. The per-node surplus
counting should be ensuring the node balancing remains the same.

(have not verified this is the case, it just makes sense)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
