Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5ML3AtC248462
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 17:03:10 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5ML398X182054
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 15:03:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5ML39w5031523
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 15:03:09 -0600
Subject: Re: 2.6.12-mm1 & 2K lun testing  (JFS problem ?)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <1119448252.9262.12.camel@localhost>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616002451.01f7e9ed.akpm@osdl.org>
	 <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616133730.1924fca3.akpm@osdl.org>
	 <1118965381.4301.488.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616175130.22572451.akpm@osdl.org> <42B2E7D2.9080705@us.ibm.com>
	 <20050617141331.078e5f8f.akpm@osdl.org>
	 <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
	 <1119448252.9262.12.camel@localhost>
Content-Type: text/plain
Date: Wed, 22 Jun 2005 14:02:26 -0700
Message-Id: <1119474166.13376.10.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2005-06-22 at 08:50 -0500, Dave Kleikamp wrote:

> > But, I am running into JFS problem. I can't kill my
> > "dd" process.
> 
> Assuming you built the kernel with CONFIG_JFS_STATISTICS, can you send
> me the contents of /proc/fs/jfs/txstats?

Reproduced the problem. Here are the stats..

JFS TxStats
===========
calls to txBegin = 26783
txBegin blocked by sync barrier = 0
txBegin blocked by tlocks low = 0
txBegin blocked by no free tid = 930528
calls to txBeginAnon = 8700659
txBeginAnon blocked by sync barrier = 0
txBeginAnon blocked by tlocks low = 0
calls to txLockAlloc = 50601
tLockAlloc blocked by no free lock = 0


> Looks like txBegin is the problem.  Probably ran out of txBlocks.  Maybe
> a stack trace of jfsCommit, jfsIO, and jfsSync threads might be useful
> too.

I don't see the stacks for these jfs threads in the sysrq-t
output. I wonder why sysrq-t is skipping them. Any Idea ?

elm3b29:/proc/sys/fs # ps -aef | grep -i jfs
root       174     1  0 02:11 ?        00:00:00 [jfsIO]
root       175     1  0 02:11 ?        00:00:01 [jfsCommit]
root       176     1  0 02:11 ?        00:00:01 [jfsCommit]
root       177     1  0 02:11 ?        00:00:02 [jfsCommit]
root       178     1  0 02:11 ?        00:00:02 [jfsCommit]
root       179     1  0 02:11 ?        00:00:00 [jfsSync]
root      7200  7759  0 05:54 pts/1    00:00:00 grep -i jfs

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
