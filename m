Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E55F6B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:55:37 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id w205so12518896ywd.21
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 02:55:37 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b202si527819yba.426.2018.01.31.02.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 02:55:35 -0800 (PST)
Date: Wed, 31 Jan 2018 13:50:04 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [linux-next:master 10644/11012] fs/ocfs2/alloc.c:6761
 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array
 'new_eb_bh[i]'
Message-ID: <20180131105004.xdig2mzgrmiagf5l@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Changwei Ge <ge.changwei@h3c.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Dan Carpenter <dan.carpenter@oracle.com>


tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   761914dd2975bc443024f0ec10a66a26b7186ec2
commit: 0d3e622b2ac768ac5a94f8d9ede80a051154ea9e [10644/11012] ocfs2: try to reuse extent block in dealloc without meta_alloc

New smatch warnings:
fs/ocfs2/alloc.c:6761 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array 'new_eb_bh[i]'
fs/ocfs2/alloc.c:6761 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array 'new_eb_bh[i]'

Old smatch warnings:
fs/ocfs2/alloc.c:6762 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array 'new_eb_bh[i]'
fs/ocfs2/alloc.c:6762 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array 'new_eb_bh[i]'
fs/ocfs2/alloc.c:6887 ocfs2_zero_cluster_pages() warn: should '(page->index + 1) << 12' be a 64 bit type?

# https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/commit/?id=0d3e622b2ac768ac5a94f8d9ede80a051154ea9e
git remote add linux-next https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git remote update linux-next
git checkout 0d3e622b2ac768ac5a94f8d9ede80a051154ea9e
vim +6761 fs/ocfs2/alloc.c

0d3e622b Changwei Ge 2018-01-19  6662  
0d3e622b Changwei Ge 2018-01-19  6663  /* If extent was deleted from tree due to extent rotation and merging, and
0d3e622b Changwei Ge 2018-01-19  6664   * no metadata is reserved ahead of time. Try to reuse some extents
0d3e622b Changwei Ge 2018-01-19  6665   * just deleted. This is only used to reuse extent blocks.
0d3e622b Changwei Ge 2018-01-19  6666   * It is supposed to find enough extent blocks in dealloc if our estimation
0d3e622b Changwei Ge 2018-01-19  6667   * on metadata is accurate.
0d3e622b Changwei Ge 2018-01-19  6668   */
0d3e622b Changwei Ge 2018-01-19  6669  static int ocfs2_reuse_blk_from_dealloc(handle_t *handle,
0d3e622b Changwei Ge 2018-01-19  6670  					struct ocfs2_extent_tree *et,
0d3e622b Changwei Ge 2018-01-19  6671  					struct buffer_head **new_eb_bh,
0d3e622b Changwei Ge 2018-01-19  6672  					int blk_wanted, int *blk_given)
0d3e622b Changwei Ge 2018-01-19  6673  {
0d3e622b Changwei Ge 2018-01-19  6674  	int i, status = 0, real_slot;
0d3e622b Changwei Ge 2018-01-19  6675  	struct ocfs2_cached_dealloc_ctxt *dealloc;
0d3e622b Changwei Ge 2018-01-19  6676  	struct ocfs2_per_slot_free_list *fl;
0d3e622b Changwei Ge 2018-01-19  6677  	struct ocfs2_cached_block_free *bf;
0d3e622b Changwei Ge 2018-01-19  6678  	struct ocfs2_extent_block *eb;
0d3e622b Changwei Ge 2018-01-19  6679  	struct ocfs2_super *osb =
0d3e622b Changwei Ge 2018-01-19  6680  		OCFS2_SB(ocfs2_metadata_cache_get_super(et->et_ci));
0d3e622b Changwei Ge 2018-01-19  6681  
0d3e622b Changwei Ge 2018-01-19  6682  	*blk_given = 0;
0d3e622b Changwei Ge 2018-01-19  6683  
0d3e622b Changwei Ge 2018-01-19  6684  	/* If extent tree doesn't have a dealloc, this is not faulty. Just
0d3e622b Changwei Ge 2018-01-19  6685  	 * tell upper caller dealloc can't provide any block and it should
0d3e622b Changwei Ge 2018-01-19  6686  	 * ask for alloc to claim more space.
0d3e622b Changwei Ge 2018-01-19  6687  	 */
0d3e622b Changwei Ge 2018-01-19  6688  	dealloc = et->et_dealloc;
0d3e622b Changwei Ge 2018-01-19  6689  	if (!dealloc)
0d3e622b Changwei Ge 2018-01-19  6690  		goto bail;
0d3e622b Changwei Ge 2018-01-19  6691  
0d3e622b Changwei Ge 2018-01-19  6692  	for (i = 0; i < blk_wanted; i++) {
0d3e622b Changwei Ge 2018-01-19  6693  		/* Prefer to use local slot */
0d3e622b Changwei Ge 2018-01-19  6694  		fl = ocfs2_find_preferred_free_list(EXTENT_ALLOC_SYSTEM_INODE,
0d3e622b Changwei Ge 2018-01-19  6695  						    osb->slot_num, &real_slot,
0d3e622b Changwei Ge 2018-01-19  6696  						    dealloc);
0d3e622b Changwei Ge 2018-01-19  6697  		/* If no more block can be reused, we should claim more
0d3e622b Changwei Ge 2018-01-19  6698  		 * from alloc. Just return here normally.
0d3e622b Changwei Ge 2018-01-19  6699  		 */
0d3e622b Changwei Ge 2018-01-19  6700  		if (!fl) {
0d3e622b Changwei Ge 2018-01-19  6701  			status = 0;
0d3e622b Changwei Ge 2018-01-19  6702  			break;
0d3e622b Changwei Ge 2018-01-19  6703  		}
0d3e622b Changwei Ge 2018-01-19  6704  
0d3e622b Changwei Ge 2018-01-19  6705  		bf = fl->f_first;
0d3e622b Changwei Ge 2018-01-19  6706  		fl->f_first = bf->free_next;
0d3e622b Changwei Ge 2018-01-19  6707  
0d3e622b Changwei Ge 2018-01-19  6708  		new_eb_bh[i] = sb_getblk(osb->sb, bf->free_blk);
0d3e622b Changwei Ge 2018-01-19  6709  		if (new_eb_bh[i] == NULL) {
0d3e622b Changwei Ge 2018-01-19  6710  			status = -ENOMEM;
0d3e622b Changwei Ge 2018-01-19  6711  			mlog_errno(status);
0d3e622b Changwei Ge 2018-01-19  6712  			goto bail;
0d3e622b Changwei Ge 2018-01-19  6713  		}
0d3e622b Changwei Ge 2018-01-19  6714  
0d3e622b Changwei Ge 2018-01-19  6715  		mlog(0, "Reusing block(%llu) from "
0d3e622b Changwei Ge 2018-01-19  6716  		     "dealloc(local slot:%d, real slot:%d)\n",
0d3e622b Changwei Ge 2018-01-19  6717  		     bf->free_blk, osb->slot_num, real_slot);
0d3e622b Changwei Ge 2018-01-19  6718  
0d3e622b Changwei Ge 2018-01-19  6719  		ocfs2_set_new_buffer_uptodate(et->et_ci, new_eb_bh[i]);
0d3e622b Changwei Ge 2018-01-19  6720  
0d3e622b Changwei Ge 2018-01-19  6721  		status = ocfs2_journal_access_eb(handle, et->et_ci,
0d3e622b Changwei Ge 2018-01-19  6722  						 new_eb_bh[i],
0d3e622b Changwei Ge 2018-01-19  6723  						 OCFS2_JOURNAL_ACCESS_CREATE);
0d3e622b Changwei Ge 2018-01-19  6724  		if (status < 0) {
                                                    ^^^^^^^^^^
The warning is a false positive.  It's caused because the check here is
for less than zero and the check at the end is for non-zero.  The static
checker is thinking that status can be > 0 here.

If both checks were written the same way, that would silence the
warning.

Also if you rebuild your cross function DB a bunch of time that silences
the warning because then Smatch know that ocfs2_journal_access_eb()
returns (-30),(-22),(-5), or 0.  I rebuild my DB every morning on the
latest linux-next so I don't see this warning on my system.

0d3e622b Changwei Ge 2018-01-19  6725  			mlog_errno(status);
0d3e622b Changwei Ge 2018-01-19  6726  			goto bail;
0d3e622b Changwei Ge 2018-01-19  6727  		}
0d3e622b Changwei Ge 2018-01-19  6728  
0d3e622b Changwei Ge 2018-01-19  6729  		memset(new_eb_bh[i]->b_data, 0, osb->sb->s_blocksize);
0d3e622b Changwei Ge 2018-01-19  6730  		eb = (struct ocfs2_extent_block *) new_eb_bh[i]->b_data;
0d3e622b Changwei Ge 2018-01-19  6731  
0d3e622b Changwei Ge 2018-01-19  6732  		/* We can't guarantee that buffer head is still cached, so
0d3e622b Changwei Ge 2018-01-19  6733  		 * polutlate the extent block again.
0d3e622b Changwei Ge 2018-01-19  6734  		 */
0d3e622b Changwei Ge 2018-01-19  6735  		strcpy(eb->h_signature, OCFS2_EXTENT_BLOCK_SIGNATURE);
0d3e622b Changwei Ge 2018-01-19  6736  		eb->h_blkno = cpu_to_le64(bf->free_blk);
0d3e622b Changwei Ge 2018-01-19  6737  		eb->h_fs_generation = cpu_to_le32(osb->fs_generation);
0d3e622b Changwei Ge 2018-01-19  6738  		eb->h_suballoc_slot = cpu_to_le16(real_slot);
0d3e622b Changwei Ge 2018-01-19  6739  		eb->h_suballoc_loc = cpu_to_le64(bf->free_bg);
0d3e622b Changwei Ge 2018-01-19  6740  		eb->h_suballoc_bit = cpu_to_le16(bf->free_bit);
0d3e622b Changwei Ge 2018-01-19  6741  		eb->h_list.l_count =
0d3e622b Changwei Ge 2018-01-19  6742  			cpu_to_le16(ocfs2_extent_recs_per_eb(osb->sb));
0d3e622b Changwei Ge 2018-01-19  6743  
0d3e622b Changwei Ge 2018-01-19  6744  		/* We'll also be dirtied by the caller, so
0d3e622b Changwei Ge 2018-01-19  6745  		 * this isn't absolutely necessary.
0d3e622b Changwei Ge 2018-01-19  6746  		 */
0d3e622b Changwei Ge 2018-01-19  6747  		ocfs2_journal_dirty(handle, new_eb_bh[i]);
0d3e622b Changwei Ge 2018-01-19  6748  
0d3e622b Changwei Ge 2018-01-19  6749  		if (!fl->f_first) {
0d3e622b Changwei Ge 2018-01-19  6750  			dealloc->c_first_suballocator = fl->f_next_suballocator;
0d3e622b Changwei Ge 2018-01-19  6751  			kfree(fl);
0d3e622b Changwei Ge 2018-01-19  6752  		}
0d3e622b Changwei Ge 2018-01-19  6753  		kfree(bf);
0d3e622b Changwei Ge 2018-01-19  6754  	}
0d3e622b Changwei Ge 2018-01-19  6755  
0d3e622b Changwei Ge 2018-01-19  6756  	*blk_given = i;
0d3e622b Changwei Ge 2018-01-19  6757  
0d3e622b Changwei Ge 2018-01-19  6758  bail:
0d3e622b Changwei Ge 2018-01-19  6759  	if (unlikely(status)) {
                                                     ^^^^^^

0d3e622b Changwei Ge 2018-01-19  6760  		for (; i >= 0; i--) {
0d3e622b Changwei Ge 2018-01-19 @6761  			if (new_eb_bh[i])
0d3e622b Changwei Ge 2018-01-19  6762  				brelse(new_eb_bh[i]);
0d3e622b Changwei Ge 2018-01-19  6763  		}
0d3e622b Changwei Ge 2018-01-19  6764  	}
0d3e622b Changwei Ge 2018-01-19  6765  
0d3e622b Changwei Ge 2018-01-19  6766  	return status;
0d3e622b Changwei Ge 2018-01-19  6767  }
0d3e622b Changwei Ge 2018-01-19  6768  

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
