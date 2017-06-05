Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2B346B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 17:44:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z70so11378830wrc.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 14:44:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v70si9527975wmd.29.2017.06.05.14.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 14:44:03 -0700 (PDT)
Date: Mon, 5 Jun 2017 14:44:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-Id: <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
In-Reply-To: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sat, 3 Jun 2017 14:24:26 -0500 Larry Finger <Larry.Finger@lwfinger.net> wrote:

> I recently turned on locking diagnostics for a Dell Latitude D600 laptop, which 
> requires a 32-bit kernel. In the log I found the following:
> 
> BUG: sleeping function called from invalid context at mm/khugepaged.c:655
> in_atomic(): 1, irqs_disabled(): 0, pid: 20, name: khugepaged
> 1 lock held by khugepaged/20:
>   #0:  (&mm->mmap_sem){++++++}, at: [<c03d6609>] 
> collapse_huge_page.isra.47+0x439/0x1240
> CPU: 0 PID: 20 Comm: khugepaged Tainted: G        W 
> 4.12.0-rc1-wl-12125-g952a068 #80
> Hardware name: Dell Computer Corporation Latitude D600 
> /03U652, BIOS A05 05/29/2003
> Call Trace:
>   dump_stack+0x76/0xb2
>   ___might_sleep+0x174/0x230
>   collapse_huge_page.isra.47+0xacf/0x1240
>   khugepaged_scan_mm_slot+0x41e/0xc00
>   ? _raw_spin_lock+0x46/0x50
>   khugepaged+0x277/0x4f0
>   ? prepare_to_wait_event+0xe0/0xe0
>   kthread+0xeb/0x120
>   ? khugepaged_scan_mm_slot+0xc00/0xc00
>   ? kthread_create_on_node+0x30/0x30
>   ret_from_fork+0x21/0x30
> 
> I have no idea when this problem was introduced. Of course, I will test any 
> proposed fixes.
> 

Odd.  There's nothing wrong with cond_resched() while holding mmap_sem.
It looks like khugepaged forgot to do a spin_unlock somewhere and we
leaked a preempt_count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
