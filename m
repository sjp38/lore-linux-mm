Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 911C66B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 03:48:01 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id z13so20343469ykd.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 00:48:01 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id d128si857606ybh.191.2016.03.04.00.46.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Mar 2016 00:48:00 -0800 (PST)
Message-ID: <56D9491E.1020905@huawei.com>
Date: Fri, 4 Mar 2016 16:36:46 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: A oops occur when it calls kmem_cache_alloc
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xishi Qiu <qiuxishi@huawei.com>

The vmcore file show the collapse reason that the page had been removed
when we acqure the page and  prepare to remove the page from the slub
 partial list.

The list is protected by the spin_lock from concurrent operation. And I find
that other core is wating the lock to alloc memory.  Therefore , The concurrent
access should be impossible.

what situatios can happen ?  or it is a kernel bug potentially.  This question
almost impossible to produce again. The following is the call statck belonging to
the module.




PID: 114258  TASK: ffff8806aafc3300  CPU: 11  COMMAND: "JEM_UserTpool"
 #0 [ffff8806aafc9050] machine_kexec at ffffffff810286ea
 #1 [ffff8806aafc90b0] crash_kexec at ffffffff810a2503
 #2 [ffff8806aafc9180] oops_end at ffffffff814593c8
 #3 [ffff8806aafc91b0] die at ffffffff81005623
 #4 [ffff8806aafc91e0] do_general_protection at ffffffff81458ed2
 #5 [ffff8806aafc9210] general_protection at ffffffff814587c5
    [exception RIP: get_partial_node+511]
    RIP: ffffffff81450426  RSP: ffff8806aafc92c0  RFLAGS: 00010002
    RAX: dead000000200200  RBX: 0000000000000000  RCX: 0000000180100010
    RDX: dead000000100100  RSI: ffff8807e24e4000  RDI: dead000000100100
    RBP: ffff8806aafc9370   R8: dead000000200200   R9: ffff880c41817000
    R10: 20c49ba5e353f7cf  R11: 0000000000000000  R12: ffff880bf90bb900
    R13: ffffea0031060400  R14: 0000000000000000  R15: ffff8807e24e4000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #6 [ffff8806aafc9378] __slab_alloc at ffffffff814508da
 #7 [ffff8806aafc9478] kmem_cache_alloc at ffffffff8114a827
 #8 [ffff8806aafc94c8] LIB_MemCacheAlloc at ffffffffa2998136 [libcfs]
 #9 [ffff8806aafc94f8] RPC_PrepReqPool at ffffffffa5844949 [ptlrpc]
#10 [ffff8806aafc9578] RPC_PrepReq at ffffffffa5844b85 [ptlrpc]
#11 [ffff8806aafc95a8] Base_RpcPrepReq at ffffffffa5844c69 [ptlrpc]
#12 [ffff8806aafc9618] FC_MsgSendRequest at ffffffffa5cab26c [snas_fc]
#13 [ffff8806aafc96b8] FCC_DiskTrySendAllocWalReq at ffffffffa5caf47e [snas_fc]
#14 [ffff8806aafc96f8] FCC_DiskTrySendRequest at ffffffffa5cafe08 [snas_fc]
#15 [ffff8806aafc9768] FCC_AdClientSendRequest at ffffffffa5cb04e6 [snas_fc]
#16 [ffff8806aafc9828] Base_RpcAsynSendReq at ffffffffa5cabc2e [snas_fc]
#17 [ffff8806aafc9848] DS_RpcAsynSendReq at ffffffffa6330c80 [snas_ds]
#18 [ffff8806aafc9898] OPM_SendTransmitReqMsg at ffffffffa62f9c8c [snas_ds]
#19 [ffff8806aafc9958] OPM_SendWriteOthersMsg at ffffffffa63256de [snas_ds]
#20 [ffff8806aafc9988] OPM_WriteOthers at ffffffffa63259ba [snas_ds]
#21 [ffff8806aafc9a98] OPM_HandleWriteOthers at ffffffffa6325c09 [snas_ds]
#22 [ffff8806aafc9ae8] OPM_WriteHandle at ffffffffa632a8f8 [snas_ds]
#23 [ffff8806aafc9c08] OPM_Write at ffffffffa632b39f [snas_ds]
#24 [ffff8806aafc9e08] JEM_HandleUserRequest at ffffffffa62f2387 [snas_ds]
#25 [ffff8806aafc9e98] TP_WorkThreadMain at ffffffffa103cd6d [snas_base]
#26 [ffff8806aafc9ee8] kthread at ffffffff81060aee
#27 [ffff8806aafc9f48] kernel_thread_helper at ffffffff814613b4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
