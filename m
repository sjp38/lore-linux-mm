Date: Mon, 26 Mar 2007 15:25:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch resend v4] update ctime and mtime for mmaped write
Message-Id: <20070326152539.51d654ed.akpm@linux-foundation.org>
In-Reply-To: <20070326211008.GS10459@waste.org>
References: <E1HVZyn-0008T8-00@dorka.pomaz.szeredi.hu>
	<20070326140036.f3352f81.akpm@linux-foundation.org>
	<20070326211008.GS10459@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Mar 2007 16:10:09 -0500
Matt Mackall <mpm@selenic.com> wrote:

> On Mon, Mar 26, 2007 at 02:00:36PM -0700, Andrew Morton wrote:
> > On Sun, 25 Mar 2007 23:10:21 +0200
> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > 
> > > This patch makes writing to shared memory mappings update st_ctime and
> > > st_mtime as defined by SUSv3:
> > 
> > Boy this is complicated.
> > 
> > Is there a simpler way of doing all this?  Say, we define a new page flag
> > PG_dirtiedbywrite and we do SetPageDirtiedByWrite() inside write() and
> > ClearPageDirtiedByWrite() whenever we propagate pte-dirtiness into
> > page-dirtiness.  Then, when performing writeback we look to see if any of
> > the dirty pages are !PageDirtiedByWrite() and, if so, we update [mc]time to
> > current-time.
> > 
> > Or something like that - I'm just thinking out loud and picking holes in
> > the above doesn't shut me up ;) We're adding complexity and some overhead
> > and we're losing our recent msync() simplifications and this all hurts.  Is
> > there some other way?  I think burning a page flag to avoid this additional
> > complexity would be worthwhile.  
> 
> Aren't we basically out of those?

Rafael has liberated a couple of the flags which swsusp was using.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
