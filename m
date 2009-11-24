Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F76E6B0083
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 06:56:41 -0500 (EST)
Message-ID: <4B0BC9E3.6070504@nokia.com>
Date: Tue, 24 Nov 2009 13:56:19 +0200
From: Adrian Hunter <adrian.hunter@nokia.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] nandsim: Don't use PF_MEMALLOC
References: <1258988417.18407.44.camel@localhost> <4B0AEA33.3010306@nokia.com> <20091124194532.AFC2.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091124194532.AFC2.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ext KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Bityutskiy Artem (Nokia-D/Helsinki)" <Artem.Bityutskiy@nokia.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Woodhouse <David.Woodhouse@intel.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>
List-ID: <linux-mm.kvack.org>

ext KOSAKI Motohiro wrote:
> Hi
> 
> Thank you for this useful comments.
> 
>>> I vaguely remember Adrian (CCed) did this on purpose. This is for the
>>> case when nandsim emulates NAND flash on top of a file. So there are 2
>>> file-systems involved: one sits on top of nandsim (e.g. UBIFS) and the
>>> other owns the file which nandsim uses (e.g., ext3).
>>>
>>> And I really cannot remember off the top of my head why he needed
>>> PF_MEMALLOC, but I think Adrian wanted to prevent the direct reclaim
>>> path to re-enter, say UBIFS, and cause deadlock. But I'd thing that all
>>> the allocations in vfs_read()/vfs_write() should be GFP_NOFS, so that
>>> should not be a probelm?
>>>
>> Yes it needs PF_MEMALLOC to prevent deadlock because there can be a
>> file system on top of nandsim which, in this case, is on top of another
>> file system.
>>
>> I do not see how mempools will help here.
>>
>> Please offer an alternative solution.
> 
> I have few questions.
> 
> Can you please explain more detail? Another stackable filesystam
> (e.g. ecryptfs) don't have such problem. Why nandsim have its issue?
> What lock cause deadlock?
> 
> 
> 

The file systems are not stacked.  One is over nandsim, which nandsim
does not know about because it is just a lowly NAND device, and, with
the file cache option, one file system below to provide the file cache.

The deadlock is the kernel writing out dirty pages to the top file system
which writes to nandsim which writes to the bottom file system which
allocates memory which causes dirty pages to be written out to the top
file system, which tries to write to nandsim => deadlock.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
