Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 137486B0007
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 11:48:43 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 199so4482881wmi.6
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 08:48:43 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id k2si2432262wmd.221.2018.02.25.08.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Feb 2018 08:48:41 -0800 (PST)
Date: Sun, 25 Feb 2018 17:48:40 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [mmotm:master 110/152] fs/proc/inode.c:382:3-9: preceding lock on
 line 378 (fwd)
Message-ID: <alpine.DEB.2.20.1802251747480.4584@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

Please check whether an unlock is missing before line 382.

julia

---------- Forwarded message ----------
Date: Mon, 26 Feb 2018 00:11:20 +0800
From: kbuild test robot <fengguang.wu@intel.com>
To: kbuild@01.org
Cc: Julia Lawall <julia.lawall@lip6.fr>
Subject: [mmotm:master 110/152] fs/proc/inode.c:382:3-9: preceding lock on line
    378

CC: kbuild-all@01.org
TO: Alexey Dobriyan <adobriyan@gmail.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   745388a34645dd2b69f5e7115ad47fea7a218726
commit: 2e2d47fa3e1f9dff0e77de6edb123f024bf7841b [110/152] proc: do less stuff under ->pde_unload_lock
:::::: branch date: 4 days ago
:::::: commit date: 4 days ago

>> fs/proc/inode.c:382:3-9: preceding lock on line 378

git remote add mmotm git://git.cmpxchg.org/linux-mmotm.git
git remote update mmotm
git checkout 2e2d47fa3e1f9dff0e77de6edb123f024bf7841b
vim +382 fs/proc/inode.c

786d7e16 Alexey Dobriyan 2007-07-15  373
786d7e16 Alexey Dobriyan 2007-07-15  374  static int proc_reg_release(struct inode *inode, struct file *file)
786d7e16 Alexey Dobriyan 2007-07-15  375  {
786d7e16 Alexey Dobriyan 2007-07-15  376  	struct proc_dir_entry *pde = PDE(inode);
881adb85 Alexey Dobriyan 2008-07-25  377  	struct pde_opener *pdeo;
786d7e16 Alexey Dobriyan 2007-07-15 @378  	spin_lock(&pde->pde_unload_lock);
ca469f35 Al Viro         2013-04-03  379  	list_for_each_entry(pdeo, &pde->pde_openers, lh) {
ca469f35 Al Viro         2013-04-03  380  		if (pdeo->file == file) {
ca469f35 Al Viro         2013-04-03  381  			close_pdeo(pde, pdeo);
2e2d47fa Alexey Dobriyan 2018-02-21 @382  			return 0;
786d7e16 Alexey Dobriyan 2007-07-15  383  		}
881adb85 Alexey Dobriyan 2008-07-25  384  	}
786d7e16 Alexey Dobriyan 2007-07-15  385  	spin_unlock(&pde->pde_unload_lock);
ca469f35 Al Viro         2013-04-03  386  	return 0;
786d7e16 Alexey Dobriyan 2007-07-15  387  }
786d7e16 Alexey Dobriyan 2007-07-15  388

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
