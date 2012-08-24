Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5D6066B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 17:52:16 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep AS_HWPOISON sticky
Date: Fri, 24 Aug 2012 17:52:07 -0400
Message-Id: <1345845127-13650-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1345753903-31389-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi.kleen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Thu, Aug 23, 2012 at 04:31:43PM -0400, Naoya Horiguchi wrote:
> On Thu, Aug 23, 2012 at 05:11:25PM +0800, Fengguang Wu wrote:
> > On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
...
> > > diff --git v3.6-rc1.orig/fs/inode.c v3.6-rc1/fs/inode.c
> > > index ac8d904..8742397 100644
> > > --- v3.6-rc1.orig/fs/inode.c
> > > +++ v3.6-rc1/fs/inode.c
> > > @@ -717,6 +717,15 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
> > >  		}
> > >  
> > >  		/*
> > > +		 * Keep inode caches on memory for user processes to certainly
> > > +		 * be aware of memory errors.
> > > +		 */
> > > +		if (unlikely(mapping_hwpoison(inode->i_mapping))) {
> > > +			spin_unlock(&inode->i_lock);
> > > +			continue;
> > > +		}
> > 
> > That chunk prevents reclaiming all the cached pages. However the intention
> > is only to keep the struct inode together with the hwpoison bit?
> 
> Yes, we can not reclaim pagecaches from shrink_slab(), but we can do from
> shrink_zone(). So it shouldn't happen that cached pages on hwpoisoned file
> remain for long under high memory pressure.

I might lose your point. Are you suggesting this chunk should come after
if (inode_has_buffers(inode) || inode->i_data.nrpages) { ... } block,
aren't you?  I think that's right, so I'll try and test it this weekend.

> > > +		/*
> > >  		 * Referenced or dirty inodes are still in use. Give them
> > >  		 * another pass through the LRU as we canot reclaim them now.
> > >  		 */
> > > @@ -1405,6 +1414,9 @@ static void iput_final(struct inode *inode)
> > >  		inode->i_state &= ~I_WILL_FREE;
> > >  	}
> > >  
> > > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && drop))
> > > +		mapping_clear_hwpoison(inode->i_mapping);
> > 
> > Is that clear necessary? Because the bit will be gone with the inode
> > struct: it's going to be de-allocated anyway.
> 
> With the chunk in prune_icache_sb() we keep the inode struct with
> AS_HWPOISON set on memory, so in order to remove it, we need explicitly
> clear the bit.
> Without this clear, the inode remains until system reboot.

And again, you are right here. Without this clear, this inode will be
cleared in destroy_inode().

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
