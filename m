Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 7D6926B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 06:30:10 -0500 (EST)
Date: Thu, 14 Feb 2013 11:30:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/11] ksm: reorganize ksm_check_stable_tree
Message-ID: <20130214113005.GA7367@suse.de>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
 <alpine.LNX.2.00.1301251758190.29196@eggly.anvils>
 <20130205164823.GJ21389@suse.de>
 <alpine.LNX.2.00.1302071558100.2133@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1302071558100.2133@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 07, 2013 at 04:07:17PM -0800, Hugh Dickins wrote:
> On Tue, 5 Feb 2013, Mel Gorman wrote:
> > On Fri, Jan 25, 2013 at 05:59:35PM -0800, Hugh Dickins wrote:
> > > Memory hotremove's ksm_check_stable_tree() is pitifully inefficient
> > > (restarting whenever it finds a stale node to remove), but rearrange
> > > so that at least it does not needlessly restart from nid 0 each time.
> > > And add a couple of comments: here is why we keep pfn instead of page.
> > > 
> > > Signed-off-by: Hugh Dickins <hughd@google.com>
> > > ---
> > >  mm/ksm.c |   38 ++++++++++++++++++++++----------------
> > >  1 file changed, 22 insertions(+), 16 deletions(-)
> > > 
> > > --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:52.152205940 -0800
> > > +++ mmotm/mm/ksm.c	2013-01-25 14:36:53.244205966 -0800
> > > @@ -1830,31 +1830,36 @@ void ksm_migrate_page(struct page *newpa
> > >  #endif /* CONFIG_MIGRATION */
> > >  
> > >  #ifdef CONFIG_MEMORY_HOTREMOVE
> > > -static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
> > > -						 unsigned long end_pfn)
> > > +static void ksm_check_stable_tree(unsigned long start_pfn,
> > > +				  unsigned long end_pfn)
> > >  {
> > > +	struct stable_node *stable_node;
> > >  	struct rb_node *node;
> > >  	int nid;
> > >  
> > > -	for (nid = 0; nid < nr_node_ids; nid++)
> > > -		for (node = rb_first(&root_stable_tree[nid]); node;
> > > -				node = rb_next(node)) {
> > > -			struct stable_node *stable_node;
> > > -
> > > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > > +		node = rb_first(&root_stable_tree[nid]);
> > > +		while (node) {
> > 
> > This is not your fault, the old code is wrong too. It is assuming that all
> > nodes are populated in numeric orders with no holes. It won't work if just
> > two nodes 0 and 4 are online. It should be using for_each_online_node().
> 
> If the old code is wrong, it probably would be my fault!  But I believe
> this is okay: these rb_roots we're looking at, they are in memory which
> is not being offlined, and the trees for offline nodes will simply be
> empty, won't they?  Something's badly wrong if otherwise.
> 

I would expect them to be empty but that was not the problem I had in
mind. Unfortunately I mixed up nr_online_ids and nr_node_ids and read
the loop incorrectly. What you have is fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
