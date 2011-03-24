Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B8E0B8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:23:52 -0400 (EDT)
Date: Thu, 24 Mar 2011 20:23:33 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Call Trace:Re: [boot crash #2] Re: [GIT PULL] SLAB changes for
 v2.6.39-rc1
Message-ID: <20110324192333.GA6397@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
 <20110324142146.GA11682@elte.hu>
 <alpine.DEB.2.00.1103240940570.32226@router.home>
 <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
 <20110324172653.GA28507@elte.hu>
 <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242011230.31464@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103242011230.31464@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, npiggin@kernel.dk, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ville Tervo <ville.tervo@nokia.com>, "Gustavo F. Padovan" <padovan@profusion.mobi>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> After we made debugobjects working again, we got the following:
> 
> WARNING: at lib/debugobjects.c:262 debug_print_object+0x8e/0xb0()
> Hardware name: System Product Name
> ODEBUG: free active (active state 0) object type: timer_list hint: hci_cmd_timer+0x0/0x60
> Pid: 2125, comm: dmsetup Tainted: G        W   2.6.38-06707-gc62b389 #110375
> Call Trace:
>  [<ffffffff8104700a>] warn_slowpath_common+0x7a/0xb0
>  [<ffffffff810470b6>] warn_slowpath_fmt+0x46/0x50
>  [<ffffffff812d3a5e>] debug_print_object+0x8e/0xb0
>  [<ffffffff81bd8810>] ? hci_cmd_timer+0x0/0x60
>  [<ffffffff812d4685>] debug_check_no_obj_freed+0x125/0x230
>  [<ffffffff810f1063>] ? check_object+0xb3/0x2b0
>  [<ffffffff810f3630>] kfree+0x150/0x190
>  [<ffffffff81be4d06>] ? bt_host_release+0x16/0x20
>  [<ffffffff81be4d06>] bt_host_release+0x16/0x20
>  [<ffffffff813a1907>] device_release+0x27/0xa0
>  [<ffffffff812c519c>] kobject_release+0x4c/0xa0
>  [<ffffffff812c5150>] ? kobject_release+0x0/0xa0
>  [<ffffffff812c61f6>] kref_put+0x36/0x70
>  [<ffffffff812c4d37>] kobject_put+0x27/0x60
>  [<ffffffff813a21f7>] put_device+0x17/0x20
>  [<ffffffff81bda4f9>] hci_free_dev+0x29/0x30
>  [<ffffffff81928be6>] vhci_release+0x36/0x70
>  [<ffffffff810fb366>] fput+0xd6/0x1f0
>  [<ffffffff810f8fe6>] filp_close+0x66/0x90
>  [<ffffffff810f90a9>] sys_close+0x99/0xf0
>  [<ffffffff81d4c96b>] system_call_fastpath+0x16/0x1b
> 
> That timer was introduced with commit 6bd32326cda(Bluetooth: Use
> proper timer for hci command timout)
> 
> Timer seems to be running when the thing is closed. Removing the timer
> unconditionally fixes the problem. And yes, it needs to be fixed
> before the HCI_UP check.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  net/bluetooth/hci_core.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/net/bluetooth/hci_core.c
> ===================================================================
> --- linux-2.6.orig/net/bluetooth/hci_core.c
> +++ linux-2.6/net/bluetooth/hci_core.c
> @@ -584,6 +584,9 @@ static int hci_dev_do_close(struct hci_d
>  	hci_req_cancel(hdev, ENODEV);
>  	hci_req_lock(hdev);
>  
> +	/* Stop timer, it might be running */
> +	del_timer_sync(&hdev->cmd_timer);
> +
>  	if (!test_and_clear_bit(HCI_UP, &hdev->flags)) {
>  		hci_req_unlock(hdev);
>  		return 0;
> @@ -623,7 +626,6 @@ static int hci_dev_do_close(struct hci_d
>  
>  	/* Drop last sent command */
>  	if (hdev->sent_cmd) {
> -		del_timer_sync(&hdev->cmd_timer);
>  		kfree_skb(hdev->sent_cmd);
>  		hdev->sent_cmd = NULL;
>  	}

Yes, this fixes the warning.

Tested-by: Ingo Molnar <mingo@elte.hu>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
