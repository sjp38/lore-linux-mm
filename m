Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B43E6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 18:56:41 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so2714594igb.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 15:56:41 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id w27si29328581ioi.95.2015.10.07.15.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 15:56:37 -0700 (PDT)
Message-ID: <5615A31D.60800@deltatee.com>
Date: Wed, 07 Oct 2015 16:56:29 -0600
From: Logan Gunthorpe <logang@deltatee.com>
MIME-Version: 1.0
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com> <20150923044206.36490.79829.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923044206.36490.79829.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 10/15] block, dax: fix lifetime of in-kernel dax mappings
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Jens Axboe <axboe@kernel.dk>, Boaz Harrosh <boaz@plexistor.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Stephen Bates <Stephen.Bates@pmcs.com>

Hi Dan,

We've uncovered another issue during testing with these patches. We get 
a kernel panic sometimes just while using a DAX filesystem. I've traced 
the issue back to this patch. (There's a stack trace at the end of this 
email.)

On 22/09/15 10:42 PM, Dan Williams wrote:
> +static void dax_unmap_bh(const struct buffer_head *bh, void __pmem *addr)
> +{
> +	struct block_device *bdev = bh->b_bdev;
> +	struct request_queue *q = bdev->bd_queue;
> +
> +	if (IS_ERR(addr))
> +		return;
> +	blk_dax_put(q);
>   }
>
> @@ -127,9 +159,8 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
>   			if (pos == bh_max) {
>   				bh->b_size = PAGE_ALIGN(end - pos);
>   				bh->b_state = 0;
> -				retval = get_block(inode, block, bh,
> -						   iov_iter_rw(iter) == WRITE);
> -				if (retval)
> +				rc = get_block(inode, block, bh, rw == WRITE);
> +				if (rc)
>   					break;
>   				if (!buffer_size_valid(bh))
>   					bh->b_size = 1 << blkbits;
> @@ -178,8 +213,9 @@ static ssize_t dax_io(struct inode *inode, struct iov_iter *iter,
>
>   	if (need_wmb)
>   		wmb_pmem();
> +	dax_unmap_bh(bh, kmap);
>
> -	return (pos == start) ? retval : pos - start;
> +	return (pos == start) ? rc : pos - start;
>   }

The problem is if get_block fails and returns an error code, it will 
still call dax_unmap_bh which tries to dereference bh->b_bdev. However, 
seeing get_block failed, that pointer is NULL. Maybe a null check in 
dax_unmap_bh would be sufficient?


Thanks,

Logan

--

> [   35.391790] BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
> [   35.393306] IP: [<ffffffff811d1731>] dax_unmap_bh+0x41/0x70
> [   35.394253] PGD 7c7ed067 PUD 7c01f067 PMD 0
> [   35.395020] Oops: 0000 [#1] SMP
> [   35.395597] Modules linked in: mtramonb(O)
> [   35.396320] CPU: 0 PID: 1501 Comm: dd Tainted: G           O    4.3.0-rc2+ #51
> [   35.397500] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
> [   35.399728] task: ffff88007bc6d600 ti: ffff880079250000 task.ti: ffff880079250000
> [   35.401006] RIP: 0010:[<ffffffff811d1731>]  [<ffffffff811d1731>] dax_unmap_bh+0x41/0x70
> [   35.402402] RSP: 0018:ffff880079253ab8  EFLAGS: 00010246
> [   35.403321] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000012
> [   35.404550] RDX: 0000000000000007 RSI: 0000000000000246 RDI: ffffffff8181f630
> [   35.405783] RBP: ffff880079253ac8 R08: 000000000000000a R09: 000000000000fffe
> [   35.407011] R10: ffff88007fc1ad90 R11: 0000000000006abc R12: fffffffffffffffb
> [   35.408237] R13: 000000000038e000 R14: 000000000038e000 R15: 000000000038e000
> [   35.409466] FS:  00007f0e81476700(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> [   35.410830] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   35.411796] CR2: 00000000000000a0 CR3: 000000007926f000 CR4: 00000000000006f0
> [   35.412990] Stack:
> [   35.413340]  00000000ffffffe4 ffff880079253cf0 ffff880079253be0 ffffffff811d2259
> [   35.414670]  0000000000000246 ffffffff81203120 ffff880079253e68 0000000000000000
> [   35.415981]  000000017c394800 000000000038e000 0000000100000000 fffffffffffffffb
> [   35.417298] Call Trace:
> [   35.417727]  [<ffffffff811d2259>] dax_do_io+0x199/0x700
> [   35.418615]  [<ffffffff81203120>] ? _ext4_get_block+0x200/0x200
> [   35.419819]  [<ffffffff81249700>] ? jbd2_journal_stop+0x60/0x390
> [   35.420886]  [<ffffffff8123e7fd>] ext4_ind_direct_IO+0x8d/0x410
> [   35.421908]  [<ffffffff8120205a>] ext4_direct_IO+0x2da/0x540
> [   35.422859]  [<ffffffff8120887c>] ? ext4_dirty_inode+0x5c/0x70
> [   35.423841]  [<ffffffff8113306a>] generic_file_direct_write+0xaa/0x170
> [   35.424931]  [<ffffffff811331f2>] __generic_file_write_iter+0xc2/0x1f0
> [   35.426027]  [<ffffffff811fcdcb>] ext4_file_write_iter+0x13b/0x420
> [   35.427066]  [<ffffffff81084ca2>] ? pick_next_entity+0xb2/0x190
> [   35.428061]  [<ffffffff811891f7>] __vfs_write+0xa7/0xf0
> [   35.428940]  [<ffffffff81189b59>] vfs_write+0xa9/0x190
> [   35.429810]  [<ffffffff81189a94>] ? vfs_read+0x114/0x130
> [   35.430706]  [<ffffffff8118a786>] SyS_write+0x46/0xa0
> [   35.431561]  [<ffffffff815f742e>] entry_SYSCALL_64_fastpath+0x12/0x71
> [   35.432637] Code: fe 48 c7 c7 4c 63 7e 81 e8 11 ec f5 ff 48 8b 5b 30 48 c7 c7 52 63 7e 81 31 c0 48 89 de e8 fc eb f5 ff 31 c0 48 c7 c7 30 f6 81 81 <48> 8b 9b a0 00 00 00 e8 e7 eb f5 ff 49 81 fc 00 f0 ff ff 77 08
> [   35.437029] RIP  [<ffffffff811d1731>] dax_unmap_bh+0x41/0x70
> [   35.438005]  RSP <ffff880079253ab8>
> [   35.438608] CR2: 00000000000000a0
> [   35.439194] ---[ end trace 323695b29b46dd96 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
