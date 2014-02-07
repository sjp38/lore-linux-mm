Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id A280D6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:45:36 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id w61so2348311wes.26
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:45:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lp8si1652691wic.73.2014.02.07.07.45.34
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 07:45:35 -0800 (PST)
Date: Fri, 7 Feb 2014 13:45:24 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
Message-ID: <20140207154523.GB30718@localhost.localdomain>
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
 <20140207103924.25ec5baa@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207103924.25ec5baa@tlielax.poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com, jstancek@redhat.com, mgorman@suse.de, riel@redhat.com, linux-nfs@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Feb 07, 2014 at 10:39:24AM -0500, Jeff Layton wrote:
> On Fri,  7 Feb 2014 13:19:54 -0200
> Rafael Aquini <aquini@redhat.com> wrote:
> 
> > Changes committed by "a0b8cab3 mm: remove lru parameter from
> > __pagevec_lru_add and remove parts of pagevec API" have introduced
> > a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
> > as now the page gets an extra refcount that is not dropped.
> > 
> > Jan Stancek observed and reported the leak effect while running test8 from
> > Connectathon Testsuite. After several iterations over the test case,
> > which creates several symlinks on a NFS mountpoint, the test system was
> > quickly getting into an out-of-memory scenario.
> > 
> > This patch fixes the page leak by dropping that extra refcount 
> > add_to_page_cache_lru() is grabbing. 
> > 
> > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> > Signed-off-by: Rafael Aquini <aquini@redhat.com>
> > ---
> >  fs/nfs/dir.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index be38b57..4a48fe4 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1846,6 +1846,11 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
> >  							GFP_KERNEL)) {
> >  		SetPageUptodate(page);
> >  		unlock_page(page);
> > +		/*
> > +		 * add_to_page_cache_lru() grabs an extra page refcount.
> > +		 * Drop it here to avoid leaking this page later.
> > +		 */
> > +		page_cache_release(page);
> >  	} else
> >  		__free_page(page);
> >  
> 
> Looks reasonable as an interim fix and should almost certainly go to
> stable.
> 
> Longer term, I think it would be best from an API standpoint to fix
> add_to_page_cache_lru not to take this extra reference (or to have it
> drop it itself) and fix up the callers accordingly. That seems like a
> trap for the unwary...
>

100% agreed. I'll look into the long term approach you suggested, but as
you mentioned, the interim fix is the reasonable thing to go with now, for
mainline and stable.

Thanks for looking into it Jeff.

-- Rafael 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
