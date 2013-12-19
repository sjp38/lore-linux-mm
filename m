Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4A02F6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:21:01 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so511131eae.19
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:21:00 -0800 (PST)
Received: from smtpgw.stone-is.be (smtp03.stone-is.org. [87.238.162.66])
        by mx.google.com with ESMTP id l44si4608506eem.19.2013.12.19.06.21.00
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 06:21:00 -0800 (PST)
Message-ID: <52B300C7.7090808@acm.org>
Date: Thu, 19 Dec 2013 15:20:55 +0100
From: Bart Van Assche <bvanassche@acm.org>
MIME-Version: 1.0
Subject: Re: netfilter: active obj WARN when cleaning up
References: <20131127233415.GB19270@kroah.com> <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com> <20131202164039.GA19937@kroah.com> <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com> <20131202172615.GA4722@kroah.com> <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com> <20131202190814.GA2267@kroah.com> <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com> <20131202212235.GA1297@kroah.com> <00000142b54f6694-c51e81b1-f1a2-483b-a1ce-a2d4cb6b155c-000000@email.amazonses.com> <20131202222208.GB13034@kroah.com> <00000142b90da700-19f6b465-ff15-4b2b-9bcd-b91d71958b7f-000000@email.amazonses.com> <52B0ABB6.8090205@oracle.com> <52B2E2B9.1040706@acm.org>
In-Reply-To: <52B2E2B9.1040706@acm.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Greg KH <greg@kroah.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 12/19/13 13:12, Bart Van Assche wrote:
> On 12/17/13 20:53, Sasha Levin wrote:
>> I'm still seeing warnings with this patch applied:
>>
>> [   24.900482] WARNING: CPU: 12 PID: 3654 at lib/debugobjects.c:260
>> debug_print_object+0x8d/0xb0()
>> [   24.900482] ODEBUG: free active (active state 0) object type:
>> timer_list hint: delayed_work_timer_fn+0x0/0x20
>> [   24.900482] Modules linked in:
>> [   24.900482] CPU: 12 PID: 3654 Comm: kworker/12:1 Tainted: G       
>> W    3.13.0-rc4-n
>> ext-20131217-sasha-00013-ga878504-dirty #4149
>> [   24.900482] Workqueue: events kobject_delayed_cleanup
>> [   24.900482]  0000000000000104 ffff8804f429bae8 ffffffff8439501c
>> ffffffff8555a92c
>> [   24.900482]  ffff8804f429bb38 ffff8804f429bb28 ffffffff8112f8ac
>> ffff8804f429bb58
>> [   24.900482]  ffffffff856a9413 ffff880826333530 ffffffff85c68c40
>> ffffffff8801bb58
>> [   24.900482] Call Trace:
>> [   24.900482]  [<ffffffff8439501c>] dump_stack+0x52/0x7f
>> [   24.900482]  [<ffffffff8112f8ac>] warn_slowpath_common+0x8c/0xc0
>> [   24.900482]  [<ffffffff8112f996>] warn_slowpath_fmt+0x46/0x50
>> [   24.900482]  [<ffffffff81adb50d>] debug_print_object+0x8d/0xb0
>> [   24.900482]  [<ffffffff81153090>] ? __queue_work+0x3f0/0x3f0
>> [   24.900482]  [<ffffffff81adbd15>] __debug_check_no_obj_freed+0xa5/0x220
>> [   24.900482]  [<ffffffff832b1acb>] ? rtc_device_release+0x2b/0x40
>> [   24.900482]  [<ffffffff832b1acb>] ? rtc_device_release+0x2b/0x40
>> [   24.900482]  [<ffffffff81adbea5>] debug_check_no_obj_freed+0x15/0x20
>> [   24.900482]  [<ffffffff812ad54f>] kfree+0x21f/0x2e0
>> [   24.900482]  [<ffffffff832b1acb>] rtc_device_release+0x2b/0x40
>> [   24.900482]  [<ffffffff8207efd5>] device_release+0x65/0xc0
>> [   24.900482]  [<ffffffff81ab05e5>] kobject_cleanup+0x145/0x190
>> [   24.900482]  [<ffffffff81ab063d>] kobject_delayed_cleanup+0xd/0x10
>> [   24.900482]  [<ffffffff81153a60>] process_one_work+0x320/0x530
>> [   24.900482]  [<ffffffff81153940>] ? process_one_work+0x200/0x530
>> [   24.900482]  [<ffffffff81155fe5>] worker_thread+0x215/0x350
>> [   24.900482]  [<ffffffff81155dd0>] ? manage_workers+0x180/0x180
>> [   24.900482]  [<ffffffff8115c9c5>] kthread+0x105/0x110
>> [   24.900482]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
>> [   24.900482]  [<ffffffff843a5e7c>] ret_from_fork+0x7c/0xb0
>> [   24.900482]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
>> [   24.900482] ---[ end trace 45529ebf79b2573e ]---
> 
> Can anyone tell me whether the patch below makes sense ?
> 
> [ ... ]

(replying to my own e-mail)

Please ignore the patch in the previous e-mail - it did not make sense.

Regarding the warning above: the "delayed_work_timer_fn+0x0/0x20" hint
probably indicates an attempt to free a delayed_work structure that is
embedded in struct rtc_device and that is still scheduled. It's
unfortunate that debug_check_no_obj_freed() does not print the address
of the offending object and the argument passed to kfree(). That
information would allow to compute the offset of the embedded
delayed_work structure make it easier to figure out what's going on.

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
