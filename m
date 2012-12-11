Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id DC8286B0062
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 07:18:45 -0500 (EST)
Message-ID: <50C7248F.8030409@huawei.com>
Date: Tue, 11 Dec 2012 20:18:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3 0/2] MCE: fix an error of mce_bad_pages statistics
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WuJianguo <wujianguo@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When we use "/sys/devices/system/memory/soft_offline_page" to offline a
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
V3:
	-add page lock when set HWPoison flag
	-adjust the function structure
V2 and V1:
	-fix the error

Xishi Qiu (2):
  move poisoned page check at the beginning of the function
  fix the function structure

 mm/memory-failure.c |   69 ++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 31 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
