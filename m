Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l3OMONIv007059
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 18:24:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3OMRGrG180180
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 16:27:16 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3OMRG0I014217
	for <linux-mm@kvack.org>; Tue, 24 Apr 2007 16:27:16 -0600
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20070424130601.4ab89d54.akpm@linux-foundation.org>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 15:27:41 -0700
Message-Id: <1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-24 at 13:06 -0700, Andrew Morton wrote:
> An amd64 machine is crashing badly.
> 
> http://test.kernel.org/abat/84767/debug/console.log
> 
> VFS: Mounted root (ext3 filesystem) readonly.
> Freeing unused kernel memory: 308k freed
> INIT: version 2.86 booting
> Bad page state in process 'init'
> page:ffff81007e492628 flags:0x0100000000000000 mapping:0000000000000000 mapcount:0 count:1
> Trying to fix it up, but a reboot is needed
> Backtrace:
> 
> Call Trace:
>  [<ffffffff80250d3c>] bad_page+0x74/0x10d
>  [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
>  [<ffffffff802531cb>] free_hot_page+0xb/0xd
>  [<ffffffff8025a9b7>] free_pgd_range+0x274/0x467
>  [<ffffffff8025ac2a>] free_pgtables+0x80/0x8f
>  [<ffffffff8026139c>] exit_mmap+0x90/0x11a
>  [<ffffffff802270dd>] mmput+0x29/0x98
> Bad page state in process 'hotplug'
> page:ffff81017e458bb0 flags:0x0a00000000000000 mapping:0000000000000000 mapcount:0 count:1
> Trying to fix it up, but a reboot is needed
> Backtrace:
> 
> Call Trace:
>  [<ffffffff80250d3c>] bad_page+0x74/0x10d
>  [<ffffffff80253090>] free_hot_cold_page+0x8d/0x172
>  [<ffffffff802531cb>] free_hot_page+0xb/0xd
>  [<ffffffff80227074>] __mmdrop+0x68/0xa8
>  [<ffffffff80222911>] schedule_tail+0x48/0x86
>  [<ffffffff8020960c>] ret_from_fork+0xc/0x25
> 
> 
> So free_pgd_range() is freeing a refcount=1 page.  Can anyone see what
> might be causing this?  The quicklist code impacts this area more than
> anything else..
> 
> Naturally, I can't reproduce it (no amd64 boxen).  A bisection search would
> be wonderful.


I am able to reproduce this on my amd64 box also, I will take a look ..
but feel free to beat me to it :)

Bad page state in process 'boot'
page:ffff8101df9550a0 flags:0x0e00000000000000 mapping:0000000000000000
mapcount:0 count:1
Trying to fix it up, but a reboot is needed
Backtrace:

Call Trace:
 [<ffffffff8025dbda>] filemap_fault+0x1ba/0x420
 [<ffffffff8025fdf0>] bad_page+0x70/0x120
 [<ffffffff80260c26>] free_hot_cold_page+0x1b6/0x1d0
 [<ffffffff80260cab>] free_hot_page+0xb/0x10
 [<ffffffff8026ec0d>] free_pgd_range+0x4dd/0x4f0
 [<ffffffff8026ef09>] free_pgtables+0xa9/0xe0
 [<ffffffff802701a6>] exit_mmap+0x96/0x130
 [<ffffffff8022d974>] mmput+0x44/0xc0
 [<ffffffff80231f10>] exit_mm+0x90/0x100
 [<ffffffff80233821>] do_exit+0x151/0x970
 [<ffffffff80234077>] do_group_exit+0x37/0x90
 [<ffffffff802340e2>] sys_exit_group+0x12/0x20
 [<ffffffff80209bae>] system_call+0x7e/0x83




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
