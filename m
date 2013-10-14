Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id A3DC96B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 05:47:40 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so7115851pbb.27
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 02:47:40 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUN00CM5KITFN30@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 14 Oct 2013 10:47:36 +0100 (BST)
Message-id: <1381744054.24685.35.camel@AMDC1943>
Subject: Re: [PATCH] swap: fix set_blocksize race during swapon/swapoff
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Mon, 14 Oct 2013 11:47:34 +0200
In-reply-to: <20131011120226.1f4bb32569f370b57b841e79@linux-foundation.org>
References: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
 <20131011120226.1f4bb32569f370b57b841e79@linux-foundation.org>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>

On Fri, 2013-10-11 at 12:02 -0700, Andrew Morton wrote:
> (cc Hugh)
> 
> On Fri, 11 Oct 2013 11:54:22 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> 
> > Swapoff used old_block_size from swap_info which could be overwritten by
> > concurrent swapon.
> > 
> > Reported-by: Weijie Yang <weijie.yang.kh@gmail.com>
> > Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> > ---
> >  mm/swapfile.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 3963fc2..de7c904 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -1824,6 +1824,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	struct filename *pathname;
> >  	int i, type, prev;
> >  	int err;
> > +	unsigned int old_block_size;
> >  
> >  	if (!capable(CAP_SYS_ADMIN))
> >  		return -EPERM;
> > @@ -1914,6 +1915,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	}
> >  
> >  	swap_file = p->swap_file;
> > +	old_block_size = p->old_block_size;
> >  	p->swap_file = NULL;
> >  	p->max = 0;
> >  	swap_map = p->swap_map;
> > @@ -1938,7 +1940,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
> >  	inode = mapping->host;
> >  	if (S_ISBLK(inode->i_mode)) {
> >  		struct block_device *bdev = I_BDEV(inode);
> > -		set_blocksize(bdev, p->old_block_size);
> > +		set_blocksize(bdev, old_block_size);
> >  		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
> >  	} else {
> >  		mutex_lock(&inode->i_mutex);
> 
> I find it worrying that a swapon can run concurrently with any of this
> swapoff code.  It just seem to be asking for trouble and the code
> really isn't set up for this and races here will be poorly tested for
> 
> I'm wondering if we should just extend swapon_mutex a lot and eliminate
> the concurrency?

It seems there are even more races here between swapoff & swapon (and
swapon with swapon). Simple script:
	for i in `seq 1000`
	do
		swapoff -a &
		swapon -a &
	done
causes frequent switches of block size of devices (jumping from 512 to 4096).


Best regards,
Krzysztof



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
