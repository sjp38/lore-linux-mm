Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA12540
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 11:58:38 -0700 (PDT)
Message-ID: <3D78FAD6.269EF2FB@digeo.com>
Date: Fri, 06 Sep 2002 11:58:30 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 0-order allocation failures in LTP run of Last nights bk tree
References: <1031322426.30394.4.camel@plars.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> In the nightly ltp run against the bk 2.5 tree last night I saw this
> show up in the logs.
> 
> It happened on the 2-way PIII-550, 2gb physical ram, but not on the
> smaller UP box I test on.
> 
> mtest01: page allocation failure. order:0, mode:0x50

scsi, I assume?

This will be failed bounce buffer allocation attempts.

That's fine, normal.  block will fall back to the mempool
and will wait.

Of course, your shouldn't be bounce buffering at all.  This
is happening because of the block-highmem problem.  There's
a workaround at 
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.33/2.5.33-mm4/broken-out/scsi_hack.patch

But please bear in mind, this "page allocation failure" message
is purely a developer diagnostic thing.  The reason it is there
is so that if some random toaster driver oopses over a failure
to handle an allocation failure, the person who reports the bug
can say "I saw an allocation failure and then your driver crashed".
Which tells the driver developer where to look.

Under heavy load, page allocation attempts _will_ fail, and
that's OK.  The mempool-backed memory will become available.

It's a bit CPU-inefficient, and I have code under test which
changes GFP_NOFS mempool allocators to not even bother trying
to enter page reclaim if the nonblocking allocation attempt
failed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
