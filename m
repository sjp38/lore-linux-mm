Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B42D96B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 12:23:57 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id i64so347825430ith.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 09:23:57 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0044.outbound.protection.outlook.com. [104.47.34.44])
        by mx.google.com with ESMTPS id j124si7513300oib.65.2016.08.17.09.23.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 09:23:56 -0700 (PDT)
Subject: Re: [PATCH] do_generic_file_read(): Fail immediately if killed
References: <63068e8e-8bee-b208-8441-a3c39a9d9eb6@sandisk.com>
 <20160817100156.GA6254@quack2.suse.cz>
From: Bart Van Assche <bart.vanassche@sandisk.com>
Message-ID: <55935013-1aae-3fe6-9579-dec34625961e@sandisk.com>
Date: Wed, 17 Aug 2016 09:23:46 -0700
MIME-Version: 1.0
In-Reply-To: <20160817100156.GA6254@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 08/17/2016 03:02 AM, Jan Kara wrote:
> On Tue 16-08-16 17:00:43, Bart Van Assche wrote:
>> If a fatal signal has been received, fail immediately instead of
>> trying to read more data.
>>
>> See also commit ebded02788b5 ("mm: filemap: avoid unnecessary
>> calls to lock_page when waiting for IO to complete during a read")
>
> The patch looks good to me. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> BTW: Did you see some real world impact of the change? If yes, it would be
> good to describe in the changelog.

Hello Jan,

Thanks for the review.

This patch has an impact on my tests. However, I do not yet have a full
root-cause analysis for what I observed in my tests. That is why I
hadn't mentioned any further details in the patch description.

While running fio on top of a filesystem (ext4 or xfs), dm-mpath and
the ib_srp driver I noticed that removing and restoring paths triggered
several types of hangs. The call trace of one of these hangs, the one
that made me look at do_generic_file_read(), can be found below. I'm
currently testing a block layer patch to see whether it resolves this
hang.

Bart.


kpartx          D ffff8800409d3be8     0 16392  16355 0x00000000
Call Trace:
 [<ffffffff8161f577>] schedule+0x37/0x90
 [<ffffffff81623bcf>] schedule_timeout+0x27f/0x470
 [<ffffffff8161e94f>] io_schedule_timeout+0x9f/0x110
 [<ffffffff8161fd16>] bit_wait_io+0x16/0x60
 [<ffffffff8161f9a6>] __wait_on_bit+0x56/0x80
 [<ffffffff81152e2d>] wait_on_page_bit_killable+0xbd/0xc0
 [<ffffffff81152f60>] generic_file_read_iter+0x130/0x770
 [<ffffffff812134b0>] blkdev_read_iter+0x30/0x40
 [<ffffffff811d267b>] __vfs_read+0xbb/0x130
 [<ffffffff811d2a61>] vfs_read+0x91/0x130
 [<ffffffff811d3de4>] SyS_read+0x44/0xa0
 [<ffffffff81624fa5>] entry_SYSCALL_64_fastpath+0x18/0xa8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
