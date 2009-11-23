Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DFA06B0085
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 15:02:04 -0500 (EST)
Message-ID: <4B0AEA33.3010306@nokia.com>
Date: Mon, 23 Nov 2009 22:01:55 +0200
From: Adrian Hunter <adrian.hunter@nokia.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/7] nandsim: Don't use PF_MEMALLOC
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>	 <20091117161843.3DE0.A69D9226@jp.fujitsu.com> <1258988417.18407.44.camel@localhost>
In-Reply-To: <1258988417.18407.44.camel@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Bityutskiy Artem (Nokia-D/Helsinki)" <Artem.Bityutskiy@nokia.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Woodhouse <David.Woodhouse@intel.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>
List-ID: <linux-mm.kvack.org>

Bityutskiy Artem (Nokia-D/Helsinki) wrote:
> On Tue, 2009-11-17 at 16:19 +0900, KOSAKI Motohiro wrote:
>> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
>> memory, anyone must not prevent it. Otherwise the system cause
>> mysterious hang-up and/or OOM Killer invokation.
>>
>> Cc: David Woodhouse <David.Woodhouse@intel.com>
>> Cc: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
>> Cc: linux-mtd@lists.infradead.org
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> ---
>>  drivers/mtd/nand/nandsim.c |   22 ++--------------------
>>  1 files changed, 2 insertions(+), 20 deletions(-)
>>
>> diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
>> index cd0711b..97a8bbb 100644
>> --- a/drivers/mtd/nand/nandsim.c
>> +++ b/drivers/mtd/nand/nandsim.c
>> @@ -1322,34 +1322,18 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
>>  	return 0;
>>  }
>>  
>> -static int set_memalloc(void)
>> -{
>> -	if (current->flags & PF_MEMALLOC)
>> -		return 0;
>> -	current->flags |= PF_MEMALLOC;
>> -	return 1;
>> -}
>> -
>> -static void clear_memalloc(int memalloc)
>> -{
>> -	if (memalloc)
>> -		current->flags &= ~PF_MEMALLOC;
>> -}
>> -
>>  static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t *pos)
>>  {
>>  	mm_segment_t old_fs;
>>  	ssize_t tx;
>> -	int err, memalloc;
>> +	int err;
>>  
>>  	err = get_pages(ns, file, count, *pos);
>>  	if (err)
>>  		return err;
>>  	old_fs = get_fs();
>>  	set_fs(get_ds());
>> -	memalloc = set_memalloc();
>>  	tx = vfs_read(file, (char __user *)buf, count, pos);
>> -	clear_memalloc(memalloc);
>>  	set_fs(old_fs);
>>  	put_pages(ns);
>>  	return tx;
>> @@ -1359,16 +1343,14 @@ static ssize_t write_file(struct nandsim *ns, struct file *file, void *buf, size
>>  {
>>  	mm_segment_t old_fs;
>>  	ssize_t tx;
>> -	int err, memalloc;
>> +	int err;
>>  
>>  	err = get_pages(ns, file, count, *pos);
>>  	if (err)
>>  		return err;
>>  	old_fs = get_fs();
>>  	set_fs(get_ds());
>> -	memalloc = set_memalloc();
>>  	tx = vfs_write(file, (char __user *)buf, count, pos);
>> -	clear_memalloc(memalloc);
>>  	set_fs(old_fs);
>>  	put_pages(ns);
>>  	return tx;PF_MEMALLOC,
> 
> I vaguely remember Adrian (CCed) did this on purpose. This is for the
> case when nandsim emulates NAND flash on top of a file. So there are 2
> file-systems involved: one sits on top of nandsim (e.g. UBIFS) and the
> other owns the file which nandsim uses (e.g., ext3).
> 
> And I really cannot remember off the top of my head why he needed
> PF_MEMALLOC, but I think Adrian wanted to prevent the direct reclaim
> path to re-enter, say UBIFS, and cause deadlock. But I'd thing that all
> the allocations in vfs_read()/vfs_write() should be GFP_NOFS, so that
> should not be a probelm?
> 

Yes it needs PF_MEMALLOC to prevent deadlock because there can be a
file system on top of nandsim which, in this case, is on top of another
file system.

I do not see how mempools will help here.

Please offer an alternative solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
