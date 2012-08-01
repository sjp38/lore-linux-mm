Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 1FE196B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 02:51:16 -0400 (EDT)
Date: Wed, 1 Aug 2012 08:51:10 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] list corruption by gather_surp
Message-ID: <20120801065110.GA4436@tiehlicka.suse.cz>
References: <E1Sut4x-0001K1-7N@eag09.americas.sgi.com>
 <20120730122224.GA12680@tiehlicka.suse.cz>
 <20120731231306.GA25248@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120731231306.GA25248@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: cmetcalf@tilera.com, dave@linux.vnet.ibm.com, dhillf@gmail.com, dwg@au1.ibm.com, kamezawa.hiroyuki@gmail.com, khlebnikov@openvz.org, lee.schermerhorn@hp.com, mgorman@suse.de, shhuiw@gmail.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org

On Tue 31-07-12 18:13:06, Cliff Wickman wrote:
> 
> On Mon, Jul 30, 2012 at 02:22:24PM +0200, Michal Hocko wrote:
> > On Fri 27-07-12 17:32:15, Cliff Wickman wrote:
> > > From: Cliff Wickman <cpw@sgi.com>
> > > 
> > > v2: diff'd against linux-next
> > > 
> > > I am seeing list corruption occurring from within gather_surplus_pages()
> > > (mm/hugetlb.c).  The problem occurs in a RHEL6 kernel under a heavy load,
> > > and seems to be because this function drops the hugetlb_lock.
> > > The list_add() in gather_surplus_pages() seems to need to be protected by
> > > the lock.
> > > (I don't have a similar test for a linux-next kernel)
> > 
> > Because you cannot reproduce or you just didn't test it with linux-next?
> > 
> > > I have CONFIG_DEBUG_LIST=y, and am running an MPI application with 64 threads
> > > and a library that creates a large heap of hugetlbfs pages for it.
> > > 
> > > The below patch fixes the problem.
> > > The gist of this patch is that gather_surplus_pages() does not have to drop
> > 
> > But you cannot hold spinlock while allocating memory because the
> > allocation is not atomic and you could deadlock easily.
> > 
> > > the lock if alloc_buddy_huge_page() is told whether the lock is already held.
> > 
> > The changelog doesn't actually explain how does the list gets corrupted.
> > alloc_buddy_huge_page doesn't provide the freshly allocated page to use
> > so nobody could get and free it. enqueue_huge_page happens under hugetlb_lock.
> > I am sorry but I do not see how we could race here.
> 
> I finally got my test running on a linux-next kernel and could not
> reproduce the problem.  
> So I agree that no race seems possible now.   Disregard this patch.
> 
> I'll offer the fix to the distro of the old kernel on which I saw the
> problem.

But please note that the patch is not correct as mentioned above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
