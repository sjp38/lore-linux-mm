Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 75E796B0031
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 12:44:04 -0400 (EDT)
Subject: Re: [PATCH] mm, fs: avoid page allocation beyond i_size on read
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20130821160817.940D3E0090@blue.fi.intel.com>
References: 
	 <1377099441-2224-1-git-send-email-kirill.shutemov@linux.intel.com>
	 <1377100012.2738.28.camel@menhir>
	 <20130821160817.940D3E0090@blue.fi.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 21 Aug 2013 17:42:12 +0100
Message-ID: <1377103332.2738.37.camel@menhir>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, NeilBrown <neilb@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Wed, 2013-08-21 at 19:08 +0300, Kirill A. Shutemov wrote:
> Steven Whitehouse wrote:
> > Hi,
> > 
> > On Wed, 2013-08-21 at 18:37 +0300, Kirill A. Shutemov wrote:
> > > I've noticed that we allocated unneeded page for cache on read beyond
> > > i_size. Simple test case (I checked it on ramfs):
> > > 
> > > $ touch testfile
> > > $ cat testfile
> > > 
> > > It triggers 'no_cached_page' code path in do_generic_file_read().
> > > 
> > > Looks like it's regression since commit a32ea1e. Let's fix it.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Acked-by: NeilBrown <neilb@suse.de>
> > > ---
> > >  mm/filemap.c | 4 ++++
> > >  1 file changed, 4 insertions(+)
> > > 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index 1905f0e..b1a4d35 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -1163,6 +1163,10 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
> > >  		loff_t isize;
> > >  		unsigned long nr, ret;
> > >  
> > > +		isize = i_size_read(inode);
> > > +		if (!isize || index > (isize - 1) >> PAGE_CACHE_SHIFT)
> > > +			goto out;
> > > +
> > >  		cond_resched();
> > >  find_page:
> > >  		page = find_get_page(mapping, index);
> > 
> > Please don't do that... there is no reason to think that i_size will be
> > correct at that moment. Why not just get readpage(s) to return the
> > correct return code in that case?
> 
> I work on THP for page cache. Allocation and clearing a huge page for
> nothing is pretty expensive.
> 
Hmm, thats true, but I wonder how often it is likely to happen...

> I don't think the change is harmful. The worst case scenario is race with
> write or truncate, but it's valid to return EOF in this case.
> 
> What scenario do you have in mind?
> 

1. File open on node A
2. Someone updates it on node B by extending the file
3. Someone reads the file on node A beyond end of original file size,
but within end of new file size as updated by node B. Without the patch
this works, with it, it will fail. The reason being the i_size would not
be up to date until after readpage(s) has been called.

I think this is likely to be an issue for any distributed fs using
do_generic_file_read(), although it would certainly affect GFS2, since
the locking is done at page cache level,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
