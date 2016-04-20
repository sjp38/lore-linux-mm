Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 456C5828E1
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 13:42:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so73463961pac.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 10:42:37 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id 191si21326887pfc.127.2016.04.20.10.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 10:42:33 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id er2so19859198pad.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 10:42:33 -0700 (PDT)
From: "Shi, Yang" <yang.shi@linaro.org>
Subject: [BUG linux-next] KASAN bug is raised on linux-next-20160414 with huge
 tmpfs on
Message-ID: <5717BF85.1090800@linaro.org>
Date: Wed, 20 Apr 2016 10:42:29 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, sfr@canb.auug.org.au, hughd@google.com, aryabinin@virtuozzo.com, trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, yang.shi@linaro.org

Hi folks,

When I run the below test on my ARM64 machine with NFS mounted rootfs, I 
got KASAN bug report. The test runs well if mnt is not mounted with 
"huge=1".

# mount -t tmpfs -o huge=1 tmpfs /mnt
# cp -a /opt/ltp /mnt/

BUG: KASAN: use-after-free in nfs_readdir+0x2c4/0x848 at addr 
ffff80000b7f4000
Read of size 4 by task crond/446
page:ffff7bffc02dfd00 count:2 mapcount:0 mapping:ffff80001c2cae98 index:0x0
flags: 0x6c(referenced|uptodate|lru|active)
page dumped because: kasan: bad access detected
page->mem_cgroup:ffff80002402da80
CPU: 0 PID: 446 Comm: crond Tainted: G        W 
4.6.0-rc3-next-20160414-WR8.0.0.0_standard+ #13
Hardware name: Freescale Layerscape 2085a RDB Board (DT)
Call trace:
[<ffff20000820bc90>] dump_backtrace+0x0/0x2b8
[<ffff20000820bf6c>] show_stack+0x24/0x30
[<ffff200008a28928>] dump_stack+0xb0/0xe8
[<ffff2000084c2cf0>] kasan_report_error+0x518/0x5c0
[<ffff2000084c32c0>] kasan_report+0x60/0x70
[<ffff2000084c1854>] __asan_load4+0x64/0x80
[<ffff20000868e1dc>] nfs_readdir+0x2c4/0x848
[<ffff2000085189d8>] iterate_dir+0x120/0x1d8
[<ffff2000085190dc>] SyS_getdents64+0xdc/0x170
[<ffff200008204ee0>] __sys_trace_return+0x0/0x4
Memory state around the buggy address:
  ffff80000b7f3f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
  ffff80000b7f3f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
 >ffff80000b7f4000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
                    ^
  ffff80000b7f4080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
  ffff80000b7f4100: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

BUG: KASAN: use-after-free in nfs_do_filldir+0x88/0x298 at addr 
ffff80000b7f4000
Read of size 4 by task crond/446
page:ffff7bffc02dfd00 count:2 mapcount:0 mapping:ffff80001c2cae98 index:0x0
flags: 0x6c(referenced|uptodate|lru|active)
page dumped because: kasan: bad access detected
page->mem_cgroup:ffff80002402da80
CPU: 0 PID: 446 Comm: crond Tainted: G    B   W 
4.6.0-rc3-next-20160414-WR8.0.0.0_standard+ #13
Hardware name: Freescale Layerscape 2085a RDB Board (DT)
Call trace:
[<ffff20000820bc90>] dump_backtrace+0x0/0x2b8
[<ffff20000820bf6c>] show_stack+0x24/0x30
[<ffff200008a28928>] dump_stack+0xb0/0xe8
[<ffff2000084c2cf0>] kasan_report_error+0x518/0x5c0
[<ffff2000084c32c0>] kasan_report+0x60/0x70
[<ffff2000084c1854>] __asan_load4+0x64/0x80
[<ffff20000868cb98>] nfs_do_filldir+0x88/0x298
[<ffff20000868e3a0>] nfs_readdir+0x488/0x848
[<ffff2000085189d8>] iterate_dir+0x120/0x1d8
[<ffff2000085190dc>] SyS_getdents64+0xdc/0x170
[<ffff200008204ee0>] __sys_trace_return+0x0/0x4
Memory state around the buggy address:
  ffff80000b7f3f00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
  ffff80000b7f3f80: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
 >ffff80000b7f4000: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
                    ^
  ffff80000b7f4080: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
  ffff80000b7f4100: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Thanks,
Yang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
