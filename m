Subject: Re: [PATCH 17/23] mm: count writeback pages per BDI
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708091214330.27092@schroedinger.engr.sgi.com>
References: <20070803123712.987126000@chello.nl>
	 <20070803125237.072937000@chello.nl>
	 <Pine.LNX.4.64.0708091214330.27092@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 09 Aug 2007 21:23:36 +0200
Message-Id: <1186687416.11797.182.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-09 at 12:15 -0700, Christoph Lameter wrote:
> On Fri, 3 Aug 2007, Peter Zijlstra wrote:
> 
> >  						page_index(page),
> >  						PAGECACHE_TAG_WRITEBACK);
> > +			if (bdi_cap_writeback_dirty(bdi))
> > +				__dec_bdi_stat(bdi, BDI_WRITEBACK);
> 
> Why are these not incremented and decremented in the exact location of 
> NR_WRITEBACK?

int test_clear_page_writeback(struct page *page)
{
	struct address_space *mapping = page_mapping(page);
	int ret;

	if (mapping) {
		struct backing_dev_info *bdi = mapping->backing_dev_info;
		unsigned long flags;

		write_lock_irqsave(&mapping->tree_lock, flags);
		ret = TestClearPageWriteback(page);
		if (ret) {
			radix_tree_tag_clear(&mapping->page_tree,
						page_index(page),
						PAGECACHE_TAG_WRITEBACK);
			if (bdi_cap_writeback_dirty(bdi)) {
				__dec_bdi_stat(bdi, BDI_WRITEBACK);
				__bdi_writeout_inc(bdi);
			}
		}
		write_unlock_irqrestore(&mapping->tree_lock, flags);
	} else {
		ret = TestClearPageWriteback(page);
	}
	if (ret)
		dec_zone_page_state(page, NR_WRITEBACK);
	return ret;
}

Less conditionals. We already have a branch for mapping, why create
another?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
