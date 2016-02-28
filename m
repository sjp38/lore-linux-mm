Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8446B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 00:31:19 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id x65so74929535pfb.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 21:31:19 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id r86si32577234pfb.219.2016.02.27.21.31.18
        for <linux-mm@kvack.org>;
        Sat, 27 Feb 2016 21:31:18 -0800 (PST)
Date: Sun, 28 Feb 2016 13:30:46 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 3/3] radix-tree: support locking of individual exception
 entries.
Message-ID: <201602281346.L3iqRWKF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Content-Disposition: inline
In-Reply-To: <145663616983.3865.11911049648442320016.stgit@notabene>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: kbuild-all@01.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi NeilBrown,

[auto build test ERROR on v4.5-rc5]
[also build test ERROR on next-20160226]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/NeilBrown/RFC-improvements-to-radix-tree-related-to-DAX/20160228-132214
config: i386-tinyconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   lib/radix-tree.c: In function 'radix_tree_lookup_lock':
>> lib/radix-tree.c:1616:5: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
        TASK_UNINTERRUPTIBLE);
        ^
   lib/radix-tree.c:1616:5: note: each undeclared identifier is reported only once for each function it appears in
>> lib/radix-tree.c:1621:3: error: implicit declaration of function 'schedule' [-Werror=implicit-function-declaration]
      schedule();
      ^
   lib/radix-tree.c: In function 'radix_tree_unlock':
>> lib/radix-tree.c:1644:17: error: 'TASK_NORMAL' undeclared (first use in this function)
      __wake_up(wq, TASK_NORMAL, 1, &key);
                    ^
   lib/radix-tree.c: In function 'radix_tree_delete_unlock':
   lib/radix-tree.c:1657:17: error: 'TASK_NORMAL' undeclared (first use in this function)
      __wake_up(wq, TASK_NORMAL, 1, &key);
                    ^
   cc1: some warnings being treated as errors

vim +/TASK_UNINTERRUPTIBLE +1616 lib/radix-tree.c

  1610		wait.state = SLOT_WAITING;
  1611		wait.root = root;
  1612		wait.index = index;
  1613		wait.ret = NULL;
  1614		for (;;) {
  1615			prepare_to_wait(wq, &wait.wait,
> 1616					TASK_UNINTERRUPTIBLE);
  1617			if (wait.state != SLOT_WAITING)
  1618				break;
  1619	
  1620			spin_unlock(lock);
> 1621			schedule();
  1622			spin_lock(lock);
  1623		}
  1624		finish_wait(wq, &wait.wait);
  1625		return wait.ret;
  1626	}
  1627	EXPORT_SYMBOL(radix_tree_lookup_lock);
  1628	
  1629	void radix_tree_unlock(struct radix_tree_root *root, wait_queue_head_t *wq,
  1630				unsigned long index)
  1631	{
  1632		void *ret, **slot;
  1633	
  1634		ret = __radix_tree_lookup(root, index, NULL, &slot);
  1635		if (WARN_ON_ONCE(!ret || !radix_tree_exceptional_entry(ret)))
  1636			return;
  1637		if (WARN_ON_ONCE(!slot_locked(slot)))
  1638			return;
  1639		unlock_slot(slot);
  1640	
  1641		if (waitqueue_active(wq)) {
  1642			struct wait_bit_key key = {.flags = root, .bit_nr = -2,
  1643						   .timeout = index};
> 1644			__wake_up(wq, TASK_NORMAL, 1, &key);
  1645		}
  1646	}
  1647	EXPORT_SYMBOL(radix_tree_unlock);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--+HP7ph2BbKc20aGI
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--+HP7ph2BbKc20aGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
