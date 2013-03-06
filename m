Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 5E93A6B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 21:36:44 -0500 (EST)
Date: Tue, 5 Mar 2013 18:36:41 -0800 (PST)
From: Christian Kujau <lists@nerdbynature.de>
Subject: INFO: trying to register non-static key.
Message-ID: <alpine.DEB.2.10.1303051819280.22410@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,

after upgrading from 3.8.0-rc7 to 3.9.0-rc1, the following message appears 
after booting and after dm-crypt (LUKS) partitions are mounted and 
exported via NFS:

-------------------------------
INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
Call Trace:
[eecc3bd0] [c0008e98] show_stack+0x48/0x15c (unreliable)
[eecc3c10] [c0071464] __lock_acquire+0x1734/0x18f4
[eecc3cb0] [c0071a88] lock_acquire+0x50/0x6c
[eecc3cd0] [c004aee8] flush_work+0x3c/0x26c
[eecc3d40] [c004d318] __cancel_work_timer+0x98/0xf0
[eecc3d70] [c04ecebc] xs_destroy+0x1c/0x78
[eecc3d90] [c04ea2e4] xprt_destroy+0x60/0x74
[eecc3da0] [c04e95d8] rpc_free_client+0x138/0x158
[eecc3dc0] [c04e96b8] rpc_shutdown_client+0xc0/0xd4
[eecc3e10] [c04f9834] rpcb_put_local+0x118/0x148
[eecc3e30] [c04f39f0] svc_rpcb_cleanup+0x20/0x34
[eecc3e40] [c017bfcc] nfsd_last_thread+0xf0/0x108
[eecc3e60] [c04f3608] svc_shutdown_net+0x38/0x4c
[eecc3e70] [c017c788] nfsd_destroy+0xe8/0x10c
[eecc3e90] [c017c8a4] nfsd+0xf8/0x11c
[eecc3eb0] [c0052298] kthread+0xa8/0xac
[eecc3f40] [c00107d0] ret_from_kernel_thread+0x64/0x6c
-------------------------------

This has been reported in January[0] and a bad commit has been singled 
out:

  > commit ec8acf20afb8534ed511f6613dd2226b9e301010
  > Author: Shaohua Li <shli@kernel.org>
  > Date:   Fri Feb 22 16:34:38 2013 -0800
  > 
  > swap: add per-partition lock for swapfile  

However, git-revert'ing this commit did not help in my case (powerpc32, 
uni processor). Please find full dmesg & .config here:

  http://nerdbynature.de/bits/3.9.0-rc1/

Thanks,
Christian.

[0] http://www.spinics.net/lists/linux-mm/msg50068.html
-- 
BOFH excuse #63:

not properly grounded, please bury computer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
