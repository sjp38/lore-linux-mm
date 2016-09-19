Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 167B26B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 18:55:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so357619741pfb.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 15:55:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q17si30474716pfg.98.2016.09.19.15.55.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 15:55:13 -0700 (PDT)
Date: Mon, 19 Sep 2016 15:55:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,ksm: fix endless looping in allocating memory when
 ksm enable
Message-Id: <20160919155512.72bd9a42dc6f1ac9ae2b0268@linux-foundation.org>
In-Reply-To: <1474165570-44398-1-git-send-email-zhongjiang@huawei.com>
References: <1474165570-44398-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: hughd@google.com, mhocko@suse.cz, qiuxishi@huawei.com, guohanjun@huawei.com, linux-mm@kvack.org

On Sun, 18 Sep 2016 10:26:10 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> I hit the following issue when run a OOM case of the LTP and
> ksm enable.
> 
> Call trace:
> [<ffffffc000086a88>] __switch_to+0x74/0x8c
> [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
> [<ffffffc000a1c09c>] schedule+0x3c/0x94
> [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
> [<ffffffc000a1e32c>] down_write+0x64/0x80
> [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
> [<ffffffc0000be650>] mmput+0x118/0x11c
> [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
> [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
> [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
> [<ffffffc000089fcc>] do_signal+0x1d8/0x450
> [<ffffffc00008a35c>] do_notify_resume+0x70/0x78
> 
> it will leads to a hung task because the exiting task cannot get the
> mmap sem for write. but the root cause is that the ksmd holds it for
> read while allocateing memory which just takes ages to complete.
> and ksmd  will loop in the following path.
> 
>  scan_get_next_rmap_item
>           down_read
>                 get_next_rmap_item
>                         alloc_rmap_item   #ksmd will loop permanently.
> 
> we fix it by changing the GFP to allow the allocation sometimes fail, and
> we're not at all interested in hearing abot that.

It would be better if the changelog were to describe *why* this is
harmless.  I assume that if the allocation fails,
scan_get_next_rmap_item() will bale out and ksmd just gives up and
takes a sleep?

Also, did you instead consider changing scan_get_next_rmap_item() to
simply not hold mmap_sem for so long?  Scan a megabyte or so then drop
mmap_sem for a while, then scan some more?  The whole thing is driven by
ksm.scan_address so handling the races should be simple.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
