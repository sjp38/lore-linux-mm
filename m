Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC306B0253
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 04:57:04 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so190811560pac.3
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 01:57:04 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id vt7si51750169pbc.242.2015.10.26.01.57.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Oct 2015 01:57:03 -0700 (PDT)
Message-ID: <562DE9E3.8090807@huawei.com>
Date: Mon, 26 Oct 2015 16:52:51 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question] A panic when reboot --force the system
References: <562A01D5.20207@huawei.com>
In-Reply-To: <562A01D5.20207@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Xiang <rui.xiang@huawei.com>
Cc: sysvinit-devel@nongnu.org, systemd-devel@lists.freedesktop.org, Miao
 Xie <miaoxie@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/10/23 17:45, Rui Xiang wrote:

> Hii 1/4 ?list
> 
> I encounter a panic about init process.
> 
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000007
> 
> Pid: 1, comm: init Tainted: G  R        O 3.4.24.19-0.11-default #1
> Call Trace:
>  [<ffffffff8144dd24>] panic+0xc1/0x1e2
>  [<ffffffff8104483b>] do_exit+0x7db/0x8d0
>  [<ffffffff81044c7a>] do_group_exit+0x3a/0xa0
>  [<ffffffff8105394b>] get_signal_to_deliver+0x1ab/0x5e0
>  [<ffffffff81002270>] do_signal+0x60/0x5f0
>  [<ffffffff8145bf97>] ? do_page_fault+0x4a7/0x4d0
>  [<ffffffff81170d2c>] ? poll_select_copy_remaining+0xec/0x140
>  [<ffffffff81002885>] do_notify_resume+0x65/0x80
>  [<ffffffff8124ca7e>] ? trace_hardirqs_on_thunk+0x3a/0x3c
>  [<ffffffff814587ab>] retint_signal+0x4d/0x92
> 
> The system has a little memory left, then reboot it, and get the panic.
> 
> In our host, kswapd would be wake up while using a lot of memory, and then reclaim
> some pages from init process. If we execute *"reboot"* or *"reboot -f"* to reboot
> host through sysvinit, reboot process will call sys_reboot and shut down the sas
> driver(disk), then will trigger the panic of init process.
> 
> As follow,
> 
> 		HOST					reboot process			init process
> use a lot of memory
>  wake up kswapd
>    reclaim some pages
>    (these pages are code segment
> 	or data segment of init process)
>    from init thread (pid=1)
> 								reboot
> 								  sys_reboot
> 									shutdown disk driver
> 	


												init thread read data from disk

Hi,

Does anyone know will init thread read data from disk after shutdown
the disk driver?

Thanks,
Xishi Qiu

> 														  page_fault
> 															filemap_fault
> 															  readpage failed because the disk is closed
> 															return VM_FAULT_SIGBUS
> 															send signal SIGBUS
> 														  do_signal
> 															do_exit
> 															trigger the panic
> 
> 
> It seems that reboot or force reboot through *sysvinit* have the problem.
> Furthermore, using reboot -f in *systemd* should also have this problem, right?
> 
> And is that a bug for current reboot process in sysvinit or systemd?
> 
> All comments are welcome, thanks.
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
