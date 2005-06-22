Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5MDos1N508726
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 09:50:54 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5MDosBj304582
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 07:50:54 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5MDosKc010438
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 07:50:54 -0600
Subject: Re: 2.6.12-mm1 & 2K lun testing  (JFS problem ?)
From: Dave Kleikamp <shaggy@austin.ibm.com>
In-Reply-To: <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616002451.01f7e9ed.akpm@osdl.org>
	 <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616133730.1924fca3.akpm@osdl.org>
	 <1118965381.4301.488.camel@dyn9047017072.beaverton.ibm.com>
	 <20050616175130.22572451.akpm@osdl.org> <42B2E7D2.9080705@us.ibm.com>
	 <20050617141331.078e5f8f.akpm@osdl.org>
	 <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
Content-Type: text/plain
Date: Wed, 22 Jun 2005 08:50:52 -0500
Message-Id: <1119448252.9262.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-06-21 at 17:34 -0700, Badari Pulavarty wrote:
> Hi Andrew & Shaggy,
> 
> Here is the summary of 2K lun testing on 2.6.12-mm1.
> 
> When I tune dirty ratios and CFQ queue depths, things
> seems to be running fine.
> 
> 	echo 20 > /proc/sys/vm/dirty_ratio
> 	echo 20 > /proc/sys/vm/overcommit_ratio
> 	echo 4 > /sys/block/<device>/queue/nr_requests
> 	
> 
> But, I am running into JFS problem. I can't kill my
> "dd" process.

Assuming you built the kernel with CONFIG_JFS_STATISTICS, can you send
me the contents of /proc/fs/jfs/txstats?

> They all get stuck in:
> 
> (I am going to try ext3).
> 
> dd            D 0000000000000000     0 12943      1               12939
> (NOTLB)
> ffff81010612d8f8 0000000000000086 ffff81019677a380 000000000003ffff
>        00000000d5b95298 ffff81010612d918 0000000000000003
> ffff810169f63880
>        00000076d9f1ea00 0000000000000001
> Call Trace:<ffffffff802fb31f>{submit_bio+223} 
> <ffffffff8026a8e1>{txBegin+625}

Looks like txBegin is the problem.  Probably ran out of txBlocks.  Maybe
a stack trace of jfsCommit, jfsIO, and jfsSync threads might be useful
too.

>        <ffffffff80130540>{default_wake_function+0}
> <ffffffff80130540>{default_wake_function+0}
>        <ffffffff80250a8b>{jfs_commit_inode+155}
> <ffffffff80250daa>{jfs_write_inode+58}
>        <ffffffff801a8857>{__writeback_single_inode+551}
> <ffffffff80250929>{jfs_get_blocks+521}
>        <ffffffff8015dd4c>{find_get_page+92}
> <ffffffff80185555>{__find_get_block_slow+85}
>        <ffffffff801a8e7c>{generic_sync_sb_inodes+524}
> <ffffffff801a91cd>{writeback_inodes+125}
>        <ffffffff80164aa4>{balance_dirty_pages_ratelimited+228}
>        <ffffffff8015eb65>{generic_file_buffered_write+1221}
>        <ffffffff8013b3a5>{current_fs_time+85}
> <ffffffff801a9254>{__mark_inode_dirty+52}
>        <ffffffff8019e4ac>{inode_update_time+188}
> <ffffffff8015effa>{__generic_file_aio_write_nolock+938}
>        <ffffffff8016efa5>{unmap_vmas+965}
> <ffffffff8015f1de>{__generic_file_write_nolock+158}
>        <ffffffff8017149e>{zeromap_page_range+990}
> <ffffffff8014d0c0>{autoremove_wake_function+0}
>        <ffffffff802941b1>{__up_read+33}
> <ffffffff8015f345>{generic_file_write+101}
>        <ffffffff80183b39>{vfs_write+233} <ffffffff80183ce3>{sys_write
> +83}
>        <ffffffff8010dc8e>{system_call+126}
> 

> Thanks,
> Badari

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
