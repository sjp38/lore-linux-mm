Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 530346B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 18:36:31 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so7715122pbb.9
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 15:36:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ay1si15078326pbd.186.2014.02.03.15.36.30
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 15:36:30 -0800 (PST)
Date: Mon, 3 Feb 2014 15:36:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/8] mm/swap: prevent concurrent swapon on the same
 S_ISBLK blockdev
Message-Id: <20140203153628.5e186b0e4e81400773faa7ac@linux-foundation.org>
In-Reply-To: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com>
References: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: hughd@google.com, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon, 27 Jan 2014 18:03:04 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:

> When swapon the same S_ISBLK blockdev concurrent, the allocated two
> swap_info could hold the same block_device, because claim_swapfile()
> allow the same holder(here, it is sys_swapon function).
> 
> To prevent this situation, This patch adds swap_lock protect to ensure
> we can find this situation and return -EBUSY for one swapon call.
> 
> As for S_ISREG swapfile, claim_swapfile() already prevent this scenario
> by holding inode->i_mutex.
> 
> This patch is just for a rare scenario, aim to correct of code.
> 

hm, OK.  Would it be saner to pass a unique `holder' to
claim_swapfile()?  Say, `p'?

Truly, I am fed up with silly swapon/swapoff races.  How often does
anyone call these things?  Let's slap a huge lock around the whole
thing and be done with it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
