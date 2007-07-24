Date: Tue, 24 Jul 2007 09:51:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] fix hugetlb page allocation leak
Message-Id: <20070724095146.bd9fad5e.akpm@linux-foundation.org>
In-Reply-To: <29495f1d0707240844k2f08d210id76bd53c63cc9cd1@mail.gmail.com>
References: <b040c32a0707231711p3ea6b213wff15e7a58ee48f61@mail.gmail.com>
	<20070723172019.376ca936.akpm@linux-foundation.org>
	<29495f1d0707240844k2f08d210id76bd53c63cc9cd1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Ken Chen <kenchen@google.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007 08:44:01 -0700 "Nish Aravamudan" <nish.aravamudan@gmail.com> wrote:

> On 7/23/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Mon, 23 Jul 2007 17:11:49 -0700
> > "Ken Chen" <kenchen@google.com> wrote:
> >
> > > dequeue_huge_page() has a serious memory leak upon hugetlb page
> > > allocation.  The for loop continues on allocating hugetlb pages out of
> > > all allowable zone, where this function is supposedly only dequeue one
> > > and only one pages.
> > >
> > > Fixed it by breaking out of the for loop once a hugetlb page is found.
> > >
> > >
> > > Signed-off-by: Ken Chen <kenchen@google.com>
> > >
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index f127940..d7ca59d 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -84,6 +84,7 @@ static struct page *dequeue_huge_page(st
> > >                       list_del(&page->lru);
> > >                       free_huge_pages--;
> > >                       free_huge_pages_node[nid]--;
> > > +                     break;
> > >               }
> > >       }
> > >       return page;
> >
> > that would be due to some idiot merging untested stuff.
> 
> This would be due to 3abf7afd406866a84276d3ed04f4edf6070c9cb5 right?

yep.

> Now, I wrote 31a5c6e4f25704f51f9a1373f0784034306d4cf1 which I'm
> assuming introduced this compile warning. But on my box, I see no such
> warning. I would like to think I wouldn't have submitted a patch that
> introduce the warning, even if it was trivial like that one. Which
> compiler were you using, Andrew?

I expect it was gcc-4.1.0.

But most gcc's will get confused over that code sequence.

> And if anything, I think it's a gcc bug, no? I don't see how nid could
> be used if it wasn't initialized by the zone_to_nid() call. Shouldn't
> this have got one of those uninitialized_var() things? I guess the
> code reorder (if it had included the 'break') would be just as good,
> but I'm not sure.

Yes, gcc gets things wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
