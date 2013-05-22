Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E2D126B00C7
	for <linux-mm@kvack.org>; Wed, 22 May 2013 10:20:11 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BF8A0.5000103@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-27-git-send-email-kirill.shutemov@linux.intel.com>
 <519BF8A0.5000103@sr71.net>
Subject: Re: [PATCHv4 26/39] ramfs: enable transparent huge page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20130522142236.315C7E0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 17:22:36 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > ramfs is the most simple fs from page cache point of view. Let's start
> > transparent huge page cache enabling here.
> > 
> > For now we allocate only non-movable huge page. ramfs pages cannot be
> > moved yet.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  fs/ramfs/inode.c |    6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
> > index c24f1e1..54d69c7 100644
> > --- a/fs/ramfs/inode.c
> > +++ b/fs/ramfs/inode.c
> > @@ -61,7 +61,11 @@ struct inode *ramfs_get_inode(struct super_block *sb,
> >  		inode_init_owner(inode, dir, mode);
> >  		inode->i_mapping->a_ops = &ramfs_aops;
> >  		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
> > -		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
> > +		/*
> > +		 * TODO: make ramfs pages movable
> > +		 */
> > +		mapping_set_gfp_mask(inode->i_mapping,
> > +				GFP_TRANSHUGE & ~__GFP_MOVABLE);
> 
> So, before these patches, ramfs was movable.  Now, even on architectures
> or configurations that have no chance of using THP-pagecache, ramfs
> pages are no longer movable.  Right?

No, it wasn't movable. GFP_HIGHUSER is not GFP_HIGHUSER_MOVABLE (yeah,
names of gfp constants could be more consistent).

ramfs should be fixed to use movable pages, but it's outside the scope of the
patchset.

See more details: http://lkml.org/lkml/2013/4/2/720

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
