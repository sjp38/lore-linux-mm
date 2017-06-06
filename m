Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 086E56B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 10:02:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w91so13687755wrb.13
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 07:02:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si14630433edb.297.2017.06.06.07.02.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 07:02:13 -0700 (PDT)
Subject: Re: Sleeping BUG in khugepaged for i586
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
Date: Tue, 6 Jun 2017 16:02:10 +0200
MIME-Version: 1.0
In-Reply-To: <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Larry Finger <Larry.Finger@lwfinger.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/05/2017 11:44 PM, Andrew Morton wrote:
> On Sat, 3 Jun 2017 14:24:26 -0500 Larry Finger <Larry.Finger@lwfinger.net> wrote:
> 
>> I recently turned on locking diagnostics for a Dell Latitude D600 laptop, which 
>> requires a 32-bit kernel. In the log I found the following:
>>
>> BUG: sleeping function called from invalid context at mm/khugepaged.c:655
>> in_atomic(): 1, irqs_disabled(): 0, pid: 20, name: khugepaged
>> 1 lock held by khugepaged/20:
>>   #0:  (&mm->mmap_sem){++++++}, at: [<c03d6609>] 
>> collapse_huge_page.isra.47+0x439/0x1240
>> CPU: 0 PID: 20 Comm: khugepaged Tainted: G        W 

W means thre was WARN earler. Could be related... Got logs?

>> 4.12.0-rc1-wl-12125-g952a068 #80

What is "wl-12125-g952a068"? What patches on top of mainline?

>> Hardware name: Dell Computer Corporation Latitude D600 
>> /03U652, BIOS A05 05/29/2003
>> Call Trace:
>>   dump_stack+0x76/0xb2
>>   ___might_sleep+0x174/0x230
>>   collapse_huge_page.isra.47+0xacf/0x1240
>>   khugepaged_scan_mm_slot+0x41e/0xc00
>>   ? _raw_spin_lock+0x46/0x50
>>   khugepaged+0x277/0x4f0
>>   ? prepare_to_wait_event+0xe0/0xe0
>>   kthread+0xeb/0x120
>>   ? khugepaged_scan_mm_slot+0xc00/0xc00
>>   ? kthread_create_on_node+0x30/0x30
>>   ret_from_fork+0x21/0x30
>>
>> I have no idea when this problem was introduced. Of course, I will test any 
>> proposed fixes.
>>
> 
> Odd.  There's nothing wrong with cond_resched() while holding mmap_sem.
> It looks like khugepaged forgot to do a spin_unlock somewhere and we
> leaked a preempt_count.

Hmm I'd expect such spin lock to be reported together with mmap_sem in
the debugging "locks held" message?

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
