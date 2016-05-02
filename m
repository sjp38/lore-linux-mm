Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 892EB6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 09:16:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so76689289wme.2
        for <linux-mm@kvack.org>; Mon, 02 May 2016 06:16:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si34127606wjz.119.2016.05.02.06.16.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 May 2016 06:16:39 -0700 (PDT)
Date: Mon, 2 May 2016 15:16:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 11/18] dax: Fix condition for filling of PMD holes
Message-ID: <20160502131636.GF17362@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-12-git-send-email-jack@suse.cz>
 <20160429190805.GF5888@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160429190805.GF5888@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Fri 29-04-16 13:08:05, Ross Zwisler wrote:
> On Mon, Apr 18, 2016 at 11:35:34PM +0200, Jan Kara wrote:
> > Currently dax_pmd_fault() decides to fill a PMD-sized hole only if
> > returned buffer has BH_Uptodate set. However that doesn't get set for
> > any mapping buffer so that branch is actually a dead code. The
> > BH_Uptodate check doesn't make any sense so just remove it.
> 
> I'm not sure about this one.  In my testing (which was a while ago) I was
> also never able to exercise this code path and create huge zero pages.   My
> concern is that by removing the buffer_uptodate() check, we will all of a
> sudden start running through a code path that was previously unreachable.
> 
> AFAICT the buffer_uptodate() was part of the original PMD commit.  Did we ever
> get buffers with BH_Uptodate set?  Has this code ever been run?  Does it work?
> 
> I suppose this concern is mitigated by the fact that later in this series you 
> disable the PMD path entirely, but maybe we should just leave it as is and
> turn it off, then clean it up if/when we reenable it when we add multi-order
> radix tree locking for PMDs?

Well, I did this as a separate commit exactly because I'm not sure about
the impact since nobody was actually able to test this code. So we can
easily bisect later if we find issues. The code just didn't make sense to
me that way and later in the series I update it to use radix tree locking
which would be hard to do without having code which actually makes some
sense. So I'd prefer to keep this change...

								Honza

> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/dax.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 237581441bc1..42bf65b4e752 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -878,7 +878,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
> >  		goto fallback;
> >  	}
> >  
> > -	if (!write && !buffer_mapped(&bh) && buffer_uptodate(&bh)) {
> > +	if (!write && !buffer_mapped(&bh)) {
> >  		spinlock_t *ptl;
> >  		pmd_t entry;
> >  		struct page *zero_page = get_huge_zero_page();
> > -- 
> > 2.6.6
> > 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
