Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BEB906B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:22:56 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so8714526pdi.19
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:22:56 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUP00HEDJM0VQ70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 15 Oct 2013 12:22:52 +0100 (BST)
Message-id: <1381836170.18389.13.camel@AMDC1943>
Subject: Re: [PATCH] swap: fix setting PAGE_SIZE blocksize during
 swapoff/swapon race
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 15 Oct 2013 13:22:50 +0200
In-reply-to: <alpine.LNX.2.00.1310150257030.6194@eggly.anvils>
References: <1381759136-8616-1-git-send-email-k.kozlowski@samsung.com>
 <alpine.LNX.2.00.1310150257030.6194@eggly.anvils>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Michal Hocko <mhocko@suse.cz>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Tue, 2013-10-15 at 02:59 -0700, Hugh Dickins wrote:
> On Mon, 14 Oct 2013, Krzysztof Kozlowski wrote:
> 
> > Fix race between swapoff and swapon resulting in setting blocksize of
> > PAGE_SIZE for block devices during swapoff.
> > 
> > The swapon modifies swap_info->old_block_size before acquiring
> > swapon_mutex. It reads block_size of bdev, stores it under
> > swap_info->old_block_size and sets new block_size to PAGE_SIZE.
> > 
> > On the other hand the swapoff sets the device's block_size to
> > old_block_size after releasing swapon_mutex.
> > 
> > This patch locks the swapon_mutex much earlier during swapon. It also
> > releases the swapon_mutex later during swapoff.
> > 
> > The effect of race can be triggered by following scenario:
> >  - One block swap device with block size of 512
> >  - thread 1: Swapon is called, swap is activated,
> >    p->old_block_size = block_size(p->bdev); /512/
> >    block_size(p->bdev) = PAGE_SIZE;
> >    Thread ends.
> > 
> >  - thread 2: Swapoff is called and it goes just after releasing the
> >    swapon_mutex. The swap is now fully disabled except of setting the
> >    block size to old value. The p->bdev->block_size is still equal to
> >    PAGE_SIZE.
> > 
> >  - thread 3: New swapon is called. This swap is disabled so without
> >    acquiring the swapon_mutex:
> >    - p->old_block_size = block_size(p->bdev); /PAGE_SIZE (!!!)/
> >    - block_size(p->bdev) = PAGE_SIZE;
> >    Swap is activated and thread ends.
> > 
> >  - thread 2: resumes work and sets blocksize to old value:
> >    - set_blocksize(bdev, p->old_block_size)
> >    But now the p->old_block_size is equal to PAGE_SIZE.
> > 
> > The patch swap-fix-set_blocksize-race-during-swapon-swapoff does not fix
> > this particular issue. It reduces the possibility of races as the swapon
> > must overwrite p->old_block_size before acquiring swapon_mutex in
> > swapoff.
> > 
> > Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> 
> Sorry you're being blown back and forth on this, but I say Nack to
> this version.  I've not spent the time to check whether it ends up
> correct or not; but your original patch was appropriate to the bug,
> and this one is just unnecessary churn in my view.

Hi,

I still think my previous patch does not solve the issue entirely.
The call set_blocksize() in swapoff quite often sets PAGE_SIZE instead
of valid block size (e.g. 512). I trigger this with:
------
for i in `seq 1000`
do
	swapoff /dev/sdc1 &
	swapon /dev/sdc1 &
	swapon /dev/sdc1 &
done
------
10 seconds run of this script resulted in 50% of set_blocksize(PAGE_SIZE).
Although effect can only be observed after adding printks (block device is
released).

Best regards,
Krzysztof



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
