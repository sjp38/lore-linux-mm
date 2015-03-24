Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D44956B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 04:48:20 -0400 (EDT)
Received: by pabxg6 with SMTP id xg6so206433302pab.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 01:48:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q3si4741920pdq.55.2015.03.24.01.48.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 01:48:20 -0700 (PDT)
Date: Tue, 24 Mar 2015 11:48:23 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [next:master 6096/6547] fs/nilfs2/btree.c:1611
 nilfs_btree_seek_key() warn: impossible condition '(start > (~0)) =>
 (0-u64max > u64max)'
Message-ID: <20150324084823.GB16501@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>

[ I suppose this is intentional but this is the first time
  NILFS_BTREE_KEY_MAX has been used since it was introduced in 2009 so
  it's strange. - dan ]

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   50d4d7167355e3ffa6e0a759e88cd277e58a5cb9
commit: 6c302a8684cd06a7ec985fb23f31fa8f3f210eef [6096/6547] nilfs2: add bmap function to seek a valid key

fs/nilfs2/btree.c:1611 nilfs_btree_seek_key() warn: impossible condition '(start > (~0)) => (0-u64max > u64max)'

git remote add next git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git remote update next
git checkout 6c302a8684cd06a7ec985fb23f31fa8f3f210eef
vim +1611 fs/nilfs2/btree.c

17c76b01 Koji Sato       2009-04-06  1595  		goto out;
2e0c2c73 Ryusuke Konishi 2009-08-15  1596  	nilfs_btree_commit_delete(btree, path, level, dat);
be667377 Ryusuke Konishi 2011-03-05  1597  	nilfs_inode_sub_blocks(btree->b_inode, stats.bs_nblocks);
17c76b01 Koji Sato       2009-04-06  1598  
17c76b01 Koji Sato       2009-04-06  1599  out:
6d28f7ea Ryusuke Konishi 2009-08-15  1600  	nilfs_btree_free_path(path);
17c76b01 Koji Sato       2009-04-06  1601  	return ret;
17c76b01 Koji Sato       2009-04-06  1602  }
17c76b01 Koji Sato       2009-04-06  1603  
6c302a86 Ryusuke Konishi 2015-03-20  1604  static int nilfs_btree_seek_key(const struct nilfs_bmap *btree, __u64 start,
6c302a86 Ryusuke Konishi 2015-03-20  1605  				__u64 *keyp)
6c302a86 Ryusuke Konishi 2015-03-20  1606  {
6c302a86 Ryusuke Konishi 2015-03-20  1607  	struct nilfs_btree_path *path;
6c302a86 Ryusuke Konishi 2015-03-20  1608  	const int minlevel = NILFS_BTREE_LEVEL_NODE_MIN;
6c302a86 Ryusuke Konishi 2015-03-20  1609  	int ret;
6c302a86 Ryusuke Konishi 2015-03-20  1610  
6c302a86 Ryusuke Konishi 2015-03-20 @1611  	if (start > NILFS_BTREE_KEY_MAX)
6c302a86 Ryusuke Konishi 2015-03-20  1612  		return -ENOENT;
6c302a86 Ryusuke Konishi 2015-03-20  1613  
6c302a86 Ryusuke Konishi 2015-03-20  1614  	path = nilfs_btree_alloc_path();
6c302a86 Ryusuke Konishi 2015-03-20  1615  	if (!path)
6c302a86 Ryusuke Konishi 2015-03-20  1616  		return -ENOMEM;
6c302a86 Ryusuke Konishi 2015-03-20  1617  
6c302a86 Ryusuke Konishi 2015-03-20  1618  	ret = nilfs_btree_do_lookup(btree, path, start, NULL, minlevel, 0);
6c302a86 Ryusuke Konishi 2015-03-20  1619  	if (!ret)

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
