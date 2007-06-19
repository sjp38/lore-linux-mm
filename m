Date: Tue, 19 Jun 2007 16:52:39 +0100
Subject: Re: [PATCH 1/7] KAMEZAWA Hiroyuki hot-remove patches
Message-ID: <20070619155239.GB17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618092841.7790.48917.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0706180954320.4751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706180954320.4751@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (18/06/07 09:56), Christoph Lameter didst pronounce:
> On Mon, 18 Jun 2007, Mel Gorman wrote:
> 
> > @@ -632,18 +632,27 @@ static int unmap_and_move(new_page_t get
> >  			goto unlock;
> >  		wait_on_page_writeback(page);
> >  	}
> > -
> > +	/* anon_vma should not be freed while migration. */
> > +	if (PageAnon(page)) {
> > +		rcu_read_lock();
> > +		rcu_locked = 1;
> > +	}
> 
> We agreed on doing rcu_read_lock removing the status variable 
> and checking for PageAnon(). Doing so deuglifies the 
> function.

It makes it less ugly but when making the retry-logic for migration better I
was also routinely locking up my test-box hard. I intend to run this inside
a simulator so I can use gdb to figure out what is going wrong but for the
moment I've actually gone back to using a slightly modified anon_vma patch.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
