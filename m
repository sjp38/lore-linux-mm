Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8AF7B6B0031
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 12:08:22 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1377100012.2738.28.camel@menhir>
References: <1377099441-2224-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1377100012.2738.28.camel@menhir>
Subject: Re: [PATCH] mm, fs: avoid page allocation beyond i_size on read
Content-Transfer-Encoding: 7bit
Message-Id: <20130821160817.940D3E0090@blue.fi.intel.com>
Date: Wed, 21 Aug 2013 19:08:17 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Steven Whitehouse wrote:
> Hi,
> 
> On Wed, 2013-08-21 at 18:37 +0300, Kirill A. Shutemov wrote:
> > I've noticed that we allocated unneeded page for cache on read beyond
> > i_size. Simple test case (I checked it on ramfs):
> > 
> > $ touch testfile
> > $ cat testfile
> > 
> > It triggers 'no_cached_page' code path in do_generic_file_read().
> > 
> > Looks like it's regression since commit a32ea1e. Let's fix it.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Acked-by: NeilBrown <neilb@suse.de>
> > ---
> >  mm/filemap.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 1905f0e..b1a4d35 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1163,6 +1163,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
> >  		loff_t isize;
> >  		unsigned long nr, ret;
> >  
> > +		isize = i_size_read(inode);
> > +		if (!isize || index > (isize - 1) >> PAGE_CACHE_SHIFT)
> > +			goto out;
> > +
> >  		cond_resched();
> >  find_page:
> >  		page = find_get_page(mapping, index);
> 
> Please don't do that... there is no reason to think that i_size will be
> correct at that moment. Why not just get readpage(s) to return the
> correct return code in that case?

I work on THP for page cache. Allocation and clearing a huge page for
nothing is pretty expensive.

I don't think the change is harmful. The worst case scenario is race with
write or truncate, but it's valid to return EOF in this case.

What scenario do you have in mind?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
