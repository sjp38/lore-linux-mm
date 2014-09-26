Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3827D6B0039
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 10:36:48 -0400 (EDT)
Received: by mail-yk0-f170.google.com with SMTP id 19so3925710ykq.1
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 07:36:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 24si4886419yhd.26.2014.09.26.07.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Sep 2014 07:36:47 -0700 (PDT)
Date: Fri, 26 Sep 2014 17:36:37 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [kbuild] [mmotm:master 57/427] fs/ocfs2/journal.c:2204:9: sparse:
 context imbalance in 'ocfs2_recover_orphans' - different lock contexts for
 basic block
Message-ID: <20140926143636.GA3414@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild@01.org, WeiWei Wang <wangww631@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   065f1d86a58cc88249cd8371b29a57c97483753a
commit: 8a09937cacc099da21313223443237cbc84d5876 [57/427] ocfs2: add orphan recovery types in ocfs2_recover_orphans
reproduce:
  # apt-get install sparse
  git checkout 8a09937cacc099da21313223443237cbc84d5876
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__

   fs/ocfs2/journal.c:111:6: sparse: symbol 'ocfs2_replay_map_set_state' was not declared. Should it be static?
   fs/ocfs2/journal.c:156:6: sparse: symbol 'ocfs2_queue_replay_slots' was not declared. Should it be static?
   fs/ocfs2/journal.c:176:6: sparse: symbol 'ocfs2_free_replay_slots' was not declared. Should it be static?
   fs/ocfs2/journal.c:1888:6: sparse: symbol 'ocfs2_queue_orphan_scan' was not declared. Should it be static?
   fs/ocfs2/journal.c:1937:6: sparse: symbol 'ocfs2_orphan_scan_work' was not declared. Should it be static?
>> fs/ocfs2/journal.c:2204:9: sparse: context imbalance in 'ocfs2_recover_orphans' - different lock contexts for basic block

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout 8a09937cacc099da21313223443237cbc84d5876
vim +/ocfs2_recover_orphans +2204 fs/ocfs2/journal.c

8a09937c WeiWei Wang 2014-09-26  2188  		 * if the orphan scan work, continue to process the
8a09937c WeiWei Wang 2014-09-26  2189  		 * next orphan.
8a09937c WeiWei Wang 2014-09-26  2190  		 */
8a09937c WeiWei Wang 2014-09-26  2191  		else if (orphan_reco_type == ORPHAN_SCAN_WORK) {
8a09937c WeiWei Wang 2014-09-26  2192  			spin_unlock(&oi->ip_lock);
8a09937c WeiWei Wang 2014-09-26  2193  			inode = iter;
8a09937c WeiWei Wang 2014-09-26  2194  			continue;
8a09937c WeiWei Wang 2014-09-26  2195  		}
ccd979bd Mark Fasheh 2005-12-15  2196  		spin_unlock(&oi->ip_lock);
ccd979bd Mark Fasheh 2005-12-15  2197  
ccd979bd Mark Fasheh 2005-12-15  2198  		iput(inode);
ccd979bd Mark Fasheh 2005-12-15  2199  
ccd979bd Mark Fasheh 2005-12-15  2200  		inode = iter;
ccd979bd Mark Fasheh 2005-12-15  2201  	}
ccd979bd Mark Fasheh 2005-12-15  2202  
8a09937c WeiWei Wang 2014-09-26  2203  out:

Sparse error messages are hard to understand.  It's saying that there is
a missing unlock if ocfs2_start_trans() fails and we "goto out;"

"out" labels are the worst btw.  The name is too vague.  Sometimes they
do something and sometimes they don't do anything but the name doesn't
give any clue what it does.  In theory, out labels future proof the code
from locking bugs but they don't work.  It just means you have to jump
around like a rabbit to follow all the goto paths.  A return statement
is easier to understand.

b4df6ed8 Mark Fasheh 2006-02-22 @2204  	return ret;
ccd979bd Mark Fasheh 2005-12-15  2205  }
ccd979bd Mark Fasheh 2005-12-15  2206  
19ece546 Jan Kara    2008-08-21  2207  static int __ocfs2_wait_on_mount(struct ocfs2_super *osb, int quota)
ccd979bd Mark Fasheh 2005-12-15  2208  {
ccd979bd Mark Fasheh 2005-12-15  2209  	/* This check is good because ocfs2 will wait on our recovery
ccd979bd Mark Fasheh 2005-12-15  2210  	 * thread before changing it to something other than MOUNTED
ccd979bd Mark Fasheh 2005-12-15  2211  	 * or DISABLED. */
ccd979bd Mark Fasheh 2005-12-15  2212  	wait_event(osb->osb_mount_event,

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
_______________________________________________
kbuild mailing list
kbuild@lists.01.org
https://lists.01.org/mailman/listinfo/kbuild

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
