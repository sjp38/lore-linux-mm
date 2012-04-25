Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A48CC6B0092
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 13:56:45 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2174439pbc.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:56:45 -0700 (PDT)
Date: Wed, 25 Apr 2012 10:56:39 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 5/6] zsmalloc: remove unnecessary type casting
Message-ID: <20120425175639.GA14974@kroah.com>
References: <1335334994-22138-1-git-send-email-minchan@kernel.org>
 <1335334994-22138-6-git-send-email-minchan@kernel.org>
 <4F97FD9D.9090105@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F97FD9D.9090105@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 25, 2012 at 09:35:25AM -0400, Nitin Gupta wrote:
> On 04/25/2012 02:23 AM, Minchan Kim wrote:
> 
> > Let's remove unnecessary type casting of (void *).
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zsmalloc/zsmalloc-main.c |    3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> > index b7d31cc..ff089f8 100644
> > --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> > +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> > @@ -644,8 +644,7 @@ void zs_free(struct zs_pool *pool, void *obj)
> >  	spin_lock(&class->lock);
> >  
> >  	/* Insert this object in containing zspage's freelist */
> > -	link = (struct link_free *)((unsigned char *)kmap_atomic(f_page)
> > -							+ f_offset);
> > +	link = (struct link_free *)(kmap_atomic(f_page)	+ f_offset);
> >  	link->next = first_page->freelist;
> >  	kunmap_atomic(link);
> >  	first_page->freelist = obj;
> 
> 
> 
> Incrementing a void pointer looks weired and should not be allowed by C
> compilers though gcc and clang seem to allow this without any warnings.
> (fortunately C++ forbids incrementing void pointers)

Huh?  A void pointer can safely be incremented by C I thought, do you
have a pointer to where in the reference it says it is "unspecified"?

> So, we should keep this cast to unsigned char pointer to avoid relying
> on a non-standard, compiler specific behavior.

I do agree about this, more people are starting to build the kernel with
other compilers than gcc, so it would be nice to ensure that we get
stuff like this right.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
