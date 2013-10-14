Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C14206B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 06:21:24 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so7089185pbc.26
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 03:21:24 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUN004OEM0U5U30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 14 Oct 2013 11:19:52 +0100 (BST)
Message-id: <1381745990.24685.45.camel@AMDC1943>
Subject: Re: [PATCH] swap: fix set_blocksize race during swapon/swapoff
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Mon, 14 Oct 2013 12:19:50 +0200
In-reply-to: <20131011115542.a81a9215d9b876706ec58a72@linux-foundation.org>
References: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
 <20131011115542.a81a9215d9b876706ec58a72@linux-foundation.org>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Fri, 2013-10-11 at 11:55 -0700, Andrew Morton wrote:
> On Fri, 11 Oct 2013 11:54:22 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> 
> > Swapoff used old_block_size from swap_info which could be overwritten by
> > concurrent swapon.
> 
> Better changelogs, please.  What were the user-visible effects of the
> bug, and how is it triggered?
Let me update a little the changelog:
--------
Fix race between swapoff and swapon. Swapoff used old_block_size from
swap_info outside of swapon_mutex so it could be overwritten by
concurrent swapon.

The race has visible effect only if more than one swap block device
exists with different block sizes (e.g. /dev/sda1 with block size 4096
and /dev/sdb1 with 512). In such case it leads to setting the blocksize
of swapped off device with wrong blocksize.

The bug can be triggered with multiple concurrent swapoff and swapon:
0. Swap for some device is on.
1. swapoff:
First the swapoff is called on this device and "struct swap_info_struct
*p" is assigned. This is done under swap_lock however this lock is
released for the call try_to_unuse().

2. swapon:
After the assignment above (and before acquiring swapon_mutex &
swap_lock by swapoff) the swapon is called on the same device.
The p->old_block_size is assigned to the value of block_size the device.
This block size should be the same as previous but sometimes it is not.
The swapon ends successfully.

3. swapoff:
Swapoff resumes, grabs the locks and mutex and continues to disable this
swap device. Now it sets the block size to value taken from swap_info
which was overwritten by swapon in 2.
--------

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
