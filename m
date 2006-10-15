Subject: Re: [patch 6/6] mm: fix pagecache write deadlocks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061014041927.GA14467@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site>
	 <20061013143616.15438.77140.sendpatchset@linux.site>
	 <20061013151457.81bb7f03.akpm@osdl.org>
	 <20061014041927.GA14467@wotan.suse.de>
Content-Type: text/plain
Date: Sun, 15 Oct 2006 13:35:47 +0200
Message-Id: <1160912147.5230.21.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-10-14 at 06:19 +0200, Nick Piggin wrote:
> On Fri, Oct 13, 2006 at 03:14:57PM -0700, Andrew Morton wrote:
> > On Fri, 13 Oct 2006 18:44:52 +0200 (CEST)
> > Nick Piggin <npiggin@suse.de> wrote:

> > > @@ -2450,6 +2436,7 @@ int nobh_truncate_page(struct address_sp
> > >  		memset(kaddr + offset, 0, PAGE_CACHE_SIZE - offset);
> > >  		flush_dcache_page(page);
> > >  		kunmap_atomic(kaddr, KM_USER0);
> > > +		SetPageUptodate(page);
> > >  		set_page_dirty(page);
> > >  	}
> > >  	unlock_page(page);
> > 
> > I've already forgotten why this was added.  Comment, please ;)
> 
> Well, nobh_prepare_write no longer sets it uptodate, so we need to if
> we're going to set_page_dirty. OTOH, why does truncate_page need to
> zero the pagecache anyway? I wonder if we couldn't delete this whole
> function? (not in this patchset!)

It zeros the tail end of the page so we don't leak old data?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
