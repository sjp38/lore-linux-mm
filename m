Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3DE6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 03:26:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so155394647pgc.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 00:26:07 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id e92si15048253pld.136.2016.11.25.00.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Nov 2016 00:26:06 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC 0/2] Add interface let ZRAM close swap cache
Date: Fri, 25 Nov 2016 16:25:11 +0800
Message-ID: <1480062313-7361-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, dan.j.williams@intel.com, jthumshirn@suse.de, akpm@linux-foundation.org, zhuhui@xiaomi.com, re.emese@gmail.com, andriy.shevchenko@linux.intel.com, vishal.l.verma@intel.com, hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net, vbabka@suse.cz, vdavydov.dev@gmail.com, kirill.shutemov@linux.intel.com, ying.huang@intel.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, willy@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, jmarchan@redhat.com, lstoakes@gmail.com, geliangtang@163.com, viro@zeniv.linux.org.uk, hughd@google.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com

SWAP will keep before swap cache before swap space get full.  It will
make swap space cannot be freed.  It is harmful to the system that use
ZRAM because its space use memory too.

This two patches will add a sysfs switch to ZRAM that open or close swap
cache without check the swap space.
I got good result in real environment with them.  And following part is
the record with vm-scalability case-swap-w-rand and case-swap-w-seq in
a Intel(R) Core(TM)2 Duo CPU, 2G memory and 1G ZRAM swap machine:
4.9.0-rc5 without the patches:
case-swap-w-rand
1129809600 bytes / 2149155959 usecs = 513 KB/s
1129809600 bytes / 2150796138 usecs = 512 KB/s
case-swap-w-rand
1124808768 bytes / 1973130450 usecs = 556 KB/s
1124808768 bytes / 1975142661 usecs = 556 KB/s
case-swap-w-rand
1130677056 bytes / 2154714972 usecs = 512 KB/s
1130677056 bytes / 2157542507 usecs = 511 KB/s
case-swap-w-seq
1117922688 bytes / 6596049 usecs = 165511 KB/s
1117922688 bytes / 6715711 usecs = 162562 KB/s
case-swap-w-seq
1115869824 bytes / 6909262 usecs = 157718 KB/s
1115869824 bytes / 7099283 usecs = 153496 KB/s
case-swap-w-seq
1116472896 bytes / 6451638 usecs = 168996 KB/s
1116472896 bytes / 6647963 usecs = 164005 KB/s
4.9.0-rc5 with the patches:
case-swap-w-rand
1127272896 bytes / 2060906184 usecs = 534 KB/s
1127272896 bytes / 2063671365 usecs = 533 KB/s
case-swap-w-rand
1131846912 bytes / 2097038264 usecs = 527 KB/s
1131846912 bytes / 2100148465 usecs = 526 KB/s
case-swap-w-rand
1129139136 bytes / 2038769367 usecs = 540 KB/s
1129139136 bytes / 2041411431 usecs = 540 KB/s
case-swap-w-seq
1129622976 bytes / 5910625 usecs = 186638 KB/s
1129622976 bytes / 6313311 usecs = 174733 KB/s
case-swap-w-seq
1130053248 bytes / 6771182 usecs = 162980 KB/s
1130053248 bytes / 6666061 usecs = 165550 KB/s
case-swap-w-seq
1126484928 bytes / 6555923 usecs = 167799 KB/s
1126484928 bytes / 6642291 usecs = 165617 KB/s

Hui Zhu (2):
SWAP: add interface to let disk close swap cache
ZRAM: add sysfs switch swap_cache_not_keep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
