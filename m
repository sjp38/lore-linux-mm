Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8396B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 13:44:27 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id t15so132376689igr.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 10:44:27 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id 66si6372769ioc.169.2016.01.21.10.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 10:44:26 -0800 (PST)
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id D75E620B87
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 13:44:23 -0500 (EST)
Message-Id: <1453401863.2441764.498860018.3039293C@webmail.messagingengine.com>
From: suse.dev@fea.st
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
Subject: Re: kernel 4.4.0 OOPS: "x86/mm: Found insecure W+X mapping at address
 ..."
Date: Thu, 21 Jan 2016 10:44:23 -0800
In-Reply-To: <1453398243.2408446.498798962.17B9E6CB@webmail.messagingengine.com>
References: <1453398243.2408446.498798962.17B9E6CB@webmail.messagingengine.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

(seems a cc: here wasn't sufficient from lkml; need to subscribe here too ...)

On Thu, Jan 21, 2016, at 09:44 AM, suse.dev@fea.st wrote:
> I'm booting kernel 4.4.x + xen 4.6 -- recently upgraded from kernel 4.3.x,
> 
> 	uname -rm
> 		4.4.0-3.g0567b9b-default x86_64
> 
> kernel pkgs are from opensuse repos @
> 
> 	http://download.opensuse.org/repositories/Kernel:/stable/standard
> 
> Post-upgrade, I'm seeing the following OOPS on boot; apparently non-fatal, as the system _does_ subsequently complete boot.
> 
> There are a couple of prior mentions on LKML, as yet unaddressed
> 
> 	https://lkml.org/lkml/2015/11/7/57
> 	https://lkml.org/lkml/2016/1/19/134
> 
> as well as on Xen ML
> 
> 	http://lists.xen.org/archives/html/xen-devel/2015-11/msg00514.html
> 
> Here's the trace,
> 
> 	Jan 20 17:43:49 x001 kernel: ------------[ cut here ]------------
> 	Jan 20 17:43:49 x001 kernel: WARNING: CPU: 0 PID: 1 at ../arch/x86/mm/dump_pagetables.c:225 note_page+0x5e1/0x780()
> 	Jan 20 17:43:49 x001 kernel: x86/mm: Found insecure W+X mapping at address ffff880000000000/0xffff880000000000
> 	Jan 20 17:43:49 x001 kernel: Modules linked in:
> 	Jan 20 17:43:49 x001 kernel: CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.4.0-3.g0567b9b-default #1
> 	Jan 20 17:43:49 x001 kernel: Hardware name: Supermicro X10SAT/X10SAT, BIOS 3.0 05/26/2015
> 	Jan 20 17:43:49 x001 kernel:  ffffffff81a44e20 ffff880169f57d58 ffffffff8137f639 ffff880169f57da0
> 	Jan 20 17:43:49 x001 kernel:  ffff880169f57d90 ffffffff8107d132 ffff880169f57e98 0010000000000027
> 	Jan 20 17:43:49 x001 kernel:  0000000000000004 0000000000000000 0000000000000000 ffff880169f57df0
> 	Jan 20 17:43:49 x001 kernel: Call Trace:
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8101a095>] try_stack_unwind+0x175/0x190
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff81018fe9>] dump_trace+0x69/0x3a0
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8101a0fb>] show_trace_log_lvl+0x4b/0x60
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8101942c>] show_stack_log_lvl+0x10c/0x180
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8101a195>] show_stack+0x25/0x50
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8137f639>] dump_stack+0x4b/0x72
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8107d132>] warn_slowpath_common+0x82/0xc0
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8107d1bc>] warn_slowpath_fmt+0x4c/0x50
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8106e2b1>] note_page+0x5e1/0x780
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8106e73e>] ptdump_walk_pgd_level_core+0x2ee/0x420
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8106e8a7>] ptdump_walk_pgd_level_checkwx+0x17/0x20
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff81064b2f>] mark_rodata_ro+0xef/0x100
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8169d72d>] kernel_init+0x1d/0xe0
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff816aa40f>] ret_from_fork+0x3f/0x70
> 	Jan 20 17:43:49 x001 kernel: DWARF2 unwinder stuck at ret_from_fork+0x3f/0x70
> 	Jan 20 17:43:49 x001 kernel:
> 	Jan 20 17:43:49 x001 kernel: Leftover inexact backtrace:
> 	Jan 20 17:43:49 x001 kernel:  [<ffffffff8169d710>] ? rest_init+0x90/0x90
> 	Jan 20 17:43:49 x001 kernel: ---[ end trace 3cc91a447d30cdcf ]---
> 	Jan 20 17:43:49 x001 kernel: x86/mm: Checked W+X mappings: FAILED, 4090 W+X pages found.
> 
> No sure what additional info's helpful; let me know specific, and I can provide.
> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
