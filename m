Date: Thu, 23 Oct 2008 11:52:11 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023105211.GA8011@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <20081022222316.GI15154@wotan.suse.de> <20081023095949.GB6640@fogou.chygwyn.com> <20081023102100.GA23694@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081023102100.GA23694@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mark Fasheh <mfasheh@suse.com>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Oct 23, 2008 at 12:21:00PM +0200, Nick Piggin wrote:
> On Thu, Oct 23, 2008 at 10:59:49AM +0100, steve@chygwyn.com wrote:
> > > Btw, at least for the readpage case, a return of AOP_TRUNCATED_PAGE should
> > > be checked for, which would indicate (along with !PageUptodate()) whether we
> > > need to retry the read. page_mkwrite though, as you point out, is a
> > > different story.
> > > 	--Mark
> > >
> > Yes, and although I probably didn't make it clear I was thinking
> > specifically of the page fault path there where both readpage and
> > page_mkwrite hang out.
> > 
> > Also, I've looked through all the current GFS2 code and it seems to
> > be correct in relation to Miklos' point on PageUptodate() vs
> > page->mapping == NULL so I don't think any changes are required there,
> > but obviously that needs to be taken into account in filemap_fault wrt
> > to retrying in the lock demotion case. In other words we should be
> > testing for page->mapping == NULL rather than !PageUptodate() in that
> > case,
> 
> PageUptodate is OK for the filemap_fault check AFAIKS, because it does
> a find_lock_page and runs the check under lock (so it can't be truncated
> or invalidated), in order to prevent fault vs truncate / invalidate races.
> 

Ah yes, I see now. Sorry, my fault (no pun intended!). Its the test after
readpage that I was thinking of, for which I'd previously posted a
patch under the subject "Potential fix to filemap_fault()" and you'd
reponded with a more comprehensive patch, back in July,

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
