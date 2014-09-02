Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BAC936B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 20:39:14 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so7185414pdb.27
        for <linux-mm@kvack.org>; Mon, 01 Sep 2014 17:39:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bn2si3331260pbc.110.2014.09.01.17.39.13
        for <linux-mm@kvack.org>;
        Mon, 01 Sep 2014 17:39:13 -0700 (PDT)
Date: Tue, 02 Sep 2014 08:38:47 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 2912/2956] fs/autofs4/root.c:466:25: sparse:
 incompatible types in comparison expression (different address spaces)
Message-ID: <54051197.RFhWtLnn7RJUdhpY%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@sirena.org.uk>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   03af78748485f63e8ed21d2e2585b5d1ec862ba6
commit: 1e55998017283d2f630d00f5ebc8b75202edc120 [2912/2956] autofs4: d_manage() should return -EISDIR when appropriate in rcu-walk mode.
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/autofs4/root.c:466:25: sparse: incompatible types in comparison expression (different address spaces)

vim +466 fs/autofs4/root.c

   450		if (status)
   451			return status;
   452	
   453		if (rcu_walk) {
   454			/* We don't need fs_lock in rcu_walk mode,
   455			 * just testing 'AUTOFS_INFO_NO_RCU' is enough.
   456			 * simple_empty() takes a spinlock, so leave it
   457			 * to last.
   458			 * We only return -EISDIR when certain this isn't
   459			 * a mount-trap.
   460			 */
   461			struct inode *inode;
   462			if (ino->flags & (AUTOFS_INF_EXPIRING | AUTOFS_INF_NO_RCU))
   463				return 0;
   464			if (d_mountpoint(dentry))
   465				return 0;
 > 466			inode = rcu_dereference(dentry->d_inode);
   467			if (inode && S_ISLNK(inode->i_mode))
   468				return -EISDIR;
   469			if (list_empty(&dentry->d_subdirs))
   470				return 0;
   471			if (!simple_empty(dentry))
   472				return -EISDIR;
   473			return 0;
   474		}

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
