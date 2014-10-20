Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 810AB6B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 09:12:09 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so5210965pad.3
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 06:12:09 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id so6si7764488pac.164.2014.10.20.06.12.08
        for <linux-mm@kvack.org>;
        Mon, 20 Oct 2014 06:12:08 -0700 (PDT)
Message-ID: <1413810719.7906.268.camel@sauron.fi.intel.com>
Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Mon, 20 Oct 2014 16:11:59 +0300
In-Reply-To: <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
References: 
	<BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
	 <1413805935.7906.225.camel@sauron.fi.intel.com>
	 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Cc: Jijiagang <jijiagang@hisilicon.com>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "Wanli (welly)" <welly.wan@hisilicon.com>

Hi,

first of all, what is your architecture? ARM? And how easily can you
reproduce this? And can you try a kernel newer than 3.10?

And for fs-devel and mm people, here is the link to the original report:
http://lists.infradead.org/pipermail/linux-mtd/2014-October/055930.html, 

On Mon, 2014-10-20 at 12:01 +0000, Caizhiyong wrote:
> Here is part of the log, linux version 3.10:
>    cache 16240kB is below limit 16384kB for oom_score_adj 529
>    Free memory is -1820kB above reserved
> lowmemorykiller: Killing '.networkupgrade' (6924), adj 705,
>    to free 20968kB on behalf of 'kswapd0' (543) because
>    cache 16240kB is below limit 16384kB for oom_score_adj 529
>    Free memory is -2192kB above reserved

OK, no memory and OOM starts. So your system is in trouble anyway :-)

> UBIFS assert failed in ubifs_set_page_dirty at 1421 (pid 543)

UBIFS complain here that someone marks a page as dirty "directly", not
through one of the UBIFS functions. And that someone is the page reclaim
path.

Now, I do not really know what is going on here, so I am CCing a couple
of mailing lists, may be someone will help.

Here is what I see is going on.

1. UBIFS wants to make sure that no one marks UBIFS-backed pages (and
actually inodes too) as dirty directly. UBIFS wants everyone to ask
UBIFS to mark a page as dirty.

2. This is because for every dirty page, UBIFS needs to reserve certain
amount of space on the flash media, because all writes are out-of-place,
even when you are changing an existing file.

3. There are exactly 2 places where UBIFS-backed pages may be marked as
dirty:

  a) ubifs_write_end() [->wirte_end] - the file write path
  b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path

4. If anything calls 'ubifs_set_page_dirty()' directly (not through
write_end()/mkwrite()), and the page was not dirty, UBIFS will complain
with the assertion that you see.

> CPU: 3 PID: 543 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #1
> [<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x20/0x24)
> [<80019f44>] (show_stack+0x20/0x24) from [<80af2ef8>] (dump_stack+0x24/0x2c)
> [<80af2ef8>] (dump_stack+0x24/0x2c) from [<80297234>] (ubifs_set_page_dirty+0x54/0x5c)
> [<80297234>] (ubifs_set_page_dirty+0x54/0x5c) from [<800cea60>] (set_page_dirty+0x50/0x78)
> [<800cea60>] (set_page_dirty+0x50/0x78) from [<800f4be4>] (try_to_unmap_one+0x1f8/0x3d0)
> [<800f4be4>] (try_to_unmap_one+0x1f8/0x3d0) from [<800f4f44>] (try_to_unmap_file+0x9c/0x740)
> [<800f4f44>] (try_to_unmap_file+0x9c/0x740) from [<800f5678>] (try_to_unmap+0x40/0x78)
> [<800f5678>] (try_to_unmap+0x40/0x78) from [<800d6a04>] (shrink_page_list+0x23c/0x884)
> [<800d6a04>] (shrink_page_list+0x23c/0x884) from [<800d76c8>] (shrink_inactive_list+0x21c/0x3c8)
> [<800d76c8>] (shrink_inactive_list+0x21c/0x3c8) from [<800d7c20>] (shrink_lruvec+0x3ac/0x524)
> [<800d7c20>] (shrink_lruvec+0x3ac/0x524) from [<800d8970>] (kswapd+0x854/0xdc0)
> [<800d8970>] (kswapd+0x854/0xdc0) from [<80051e28>] (kthread+0xc8/0xcc)
> [<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20)


So the reclaim path seems to be marking UBIFS-backed pages as dirty
directly, I do not know why, the reclaim path is extremely complex and I
am no expert there. But may be someone on the MM list may help.

Note, this warning is not necessarily fatal. It just indicates that
UBIFS sees something which it believes should not happen.

> UBIFS assert failed in do_writepage at 936 (pid 543)
> CPU: 1 PID: 543 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #1
> [<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x20/0x24)
> [<80019f44>] (show_stack+0x20/0x24) from [<80af2ef8>] (dump_stack+0x24/0x2c)
> [<80af2ef8>] (dump_stack+0x24/0x2c) from [<802990b8>] (do_writepage+0x1b8/0x1c4)
> [<802990b8>] (do_writepage+0x1b8/0x1c4) from [<802991e8>] (ubifs_writepage+0x124/0x1dc)
> [<802991e8>] (ubifs_writepage+0x124/0x1dc) from [<800d6eb8>] (shrink_page_list+0x6f0/0x884)
> [<800d6eb8>] (shrink_page_list+0x6f0/0x884) from [<800d76c8>] (shrink_inactive_list+0x21c/0x3c8)
> [<800d76c8>] (shrink_inactive_list+0x21c/0x3c8) from [<800d7c20>] (shrink_lruvec+0x3ac/0x524)
> [<800d7c20>] (shrink_lruvec+0x3ac/0x524) from [<800d8970>] (kswapd+0x854/0xdc0)
> [<800d8970>] (kswapd+0x854/0xdc0) from [<80051e28>] (kthread+0xc8/0xcc)
> [<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20)

And here UBIFS sees a page being writted, but there is no budget
allocated for it, so the write may fail with -ENOSPC (no space), which
is not supposed to ever happen.

This is not necessarily fatal either, but indicates that UBIFS's
assumptions about how the system functions are wrong.

Now the question is: is it UBIFS which has incorrect assumptions, or
this is the Linux MM which is not doing the right thing? I do not know
the answer, let's see if the MM list may give us a clue.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
