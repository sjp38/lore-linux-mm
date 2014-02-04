Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 61C396B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 23:21:03 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so7697848pdj.12
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 20:21:03 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id bq5si22964532pbb.78.2014.02.03.20.21.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 20:21:02 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so7930485pad.22
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 20:21:02 -0800 (PST)
Date: Mon, 3 Feb 2014 20:20:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/8] mm/swap: prevent concurrent swapon on the same
 S_ISBLK blockdev
In-Reply-To: <20140203153628.5e186b0e4e81400773faa7ac@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1402032014140.29889@eggly.anvils>
References: <000c01cf1b47$ce280170$6a780450$%yang@samsung.com> <20140203153628.5e186b0e4e81400773faa7ac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, hughd@google.com, Minchan Kim <minchan@kernel.org>, shli@kernel.org, Bob Liu <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, Seth Jennings <sjennings@variantweb.net>, Heesub Shin <heesub.shin@samsung.com>, mquzik@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Mon, 3 Feb 2014, Andrew Morton wrote:
> On Mon, 27 Jan 2014 18:03:04 +0800 Weijie Yang <weijie.yang@samsung.com> wrote:
> 
> > When swapon the same S_ISBLK blockdev concurrent, the allocated two
> > swap_info could hold the same block_device, because claim_swapfile()
> > allow the same holder(here, it is sys_swapon function).
> > 
> > To prevent this situation, This patch adds swap_lock protect to ensure
> > we can find this situation and return -EBUSY for one swapon call.
> > 
> > As for S_ISREG swapfile, claim_swapfile() already prevent this scenario
> > by holding inode->i_mutex.
> > 
> > This patch is just for a rare scenario, aim to correct of code.
> > 
> 
> hm, OK.  Would it be saner to pass a unique `holder' to
> claim_swapfile()?  Say, `p'?
> 
> Truly, I am fed up with silly swapon/swapoff races.  How often does
> anyone call these things?  Let's slap a huge lock around the whole
> thing and be done with it?

That answer makes me sad: we can't be bothered to get it right,
even when Weijie goes to the trouble of presenting a series to do so.
But I sure don't deserve a vote until I've actually looked through it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
