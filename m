Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 45C046B006E
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 21:15:07 -0500 (EST)
Message-ID: <50CA8B92.6070001@huawei.com>
Date: Fri, 14 Dec 2012 10:14:42 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V4 0/3 RESEND] MCE: fix an error of mce_bad_pages statistics
References: <50C7FB6A.9030209@huawei.com>
In-Reply-To: <50C7FB6A.9030209@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

$ echo paddr > /sys/devices/system/memory/soft_offline_page to offline a
*free* page, the value of mce_bad_pages will be added, and the page is set
HWPoison flag, but it is still managed by page buddy alocator.

$ cat /proc/meminfo | grep HardwareCorrupted shows the value.

If we offline the same page, the value of mce_bad_pages will be added
*again*, this means the value is incorrect now. Assume the page is
still free during this short time.

soft_offline_page()
	get_any_page()
		"else if (is_free_buddy_page(p))" branch return 0
			"goto done";
				"atomic_long_add(1, &mce_bad_pages);"

Changelog:
V4:
	-use num_poisoned_pages instead of mce_bad_pages
	-remove page lock
V3:
	-add page lock when set HWPoison flag
	-adjust the function structure
V2 and V1:
	-fix the error

Xishi Qiu (3):
  move-poisoned-page-check-at-the-beginning-of-the-function
  fix-function-structure
  use-num_poisoned_pages-instead-of-mce_bad_pages

 fs/proc/meminfo.c   |    2 +-
 include/linux/mm.h  |    2 +-
 mm/memory-failure.c |   76 ++++++++++++++++++++++++++-------------------------
 3 files changed, 41 insertions(+), 39 deletions(-)


.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
