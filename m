Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 574158D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 19:36:04 -0400 (EDT)
Message-ID: <4D87E0A5.7080609@fiec.espol.edu.ec>
Date: Mon, 21 Mar 2011 18:35:01 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <20110317144727.87a461f9.akpm@linux-foundation.org> <20110318111300.GF707@csn.ul.ie> <4D839EDB.9080703@fiec.espol.edu.ec> <20110319134628.GG707@csn.ul.ie> <4D84D3F2.4010200@fiec.espol.edu.ec> <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random> <20110321163742.GA24244@csn.ul.ie> <4D878564.6080608@fiec.espol.edu.ec> <20110321201641.GA5698@random.random>
In-Reply-To: <20110321201641.GA5698@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 21/03/11 15:16, Andrea Arcangeli escribio:
> On Mon, Mar 21, 2011 at 12:05:40PM -0500, Alex Villaci-s Lasso wrote:
>> El 21/03/11 11:37, Mel Gorman escribio:
>>> On Mon, Mar 21, 2011 at 02:48:32PM +0100, Andrea Arcangeli wrote:
>>>
>>> Nothing bad jumped out at me. Lets see how it gets on with testing.
>>>
>>> Thanks
>>>
>> As with the previous patch, this one did not completely solve the freezing tasks issue. However, as with the previous patch, the freezes took longer to appear, and now lasted less (10 to 12 seconds instead of freezing until the end of the usb copy).
>>
>> I have attached the new sysrq-w trace to the bug report.
> migrate and compaction disappeared from the traces as we hoped
> for. The THP allocations left throttles on writeback during reclaim
> like any 4k allocation would do:
>
> [ 2629.256809]  [<ffffffff810e43c3>] wait_on_page_writeback+0x1b/0x1d
> [ 2629.256812]  [<ffffffff810e5992>] shrink_page_list+0x134/0x478
> [ 2629.256815]  [<ffffffff810e614f>] shrink_inactive_list+0x29f/0x39a
> [ 2629.256818]  [<ffffffff810dbd55>] ? zone_watermark_ok+0x1f/0x21
> [ 2629.256820]  [<ffffffff810dfe81>] ? determine_dirtyable_memory+0x1d/0x27
> [ 2629.256823]  [<ffffffff810e6849>] shrink_zone+0x362/0x464
> [ 2629.256827]  [<ffffffff810e6c87>] do_try_to_free_pages+0xdd/0x2e3
> [ 2629.256830]  [<ffffffff810e70eb>] try_to_free_pages+0xaa/0xef
> [ 2629.256833]  [<ffffffff810deede>] __alloc_pages_nodemask+0x4cc/0x772
> [ 2629.256837]  [<ffffffff8110c0ea>] alloc_pages_vma+0xec/0xf1
> [ 2629.256840]  [<ffffffff8111be94>] do_huge_pmd_anonymous_page+0xbf/0x267
> [ 2629.256844]  [<ffffffff810f24a3>] ? pmd_offset+0x19/0x40
> [ 2629.256846]  [<ffffffff810f5c7c>] handle_mm_fault+0x15d/0x20f
> [ 2629.256850]  [<ffffffff8100f298>] ? arch_get_unmapped_area_topdown+0x1c3/0x28f
> [ 2629.256853]  [<ffffffff814818cc>] do_page_fault+0x33b/0x35d
> [ 2629.256856]  [<ffffffff810fb089>] ? do_mmap_pgoff+0x29a/0x2f4
> [ 2629.256859]  [<ffffffff8112dd66>] ? path_put+0x22/0x27
> [ 2629.256861]  [<ffffffff8147f285>] page_fault+0x25/0x30
>
> They throttle on writeback I/O completion like kswapd too:
>
> [ 2849.098751]  [<ffffffff8147d00b>] io_schedule+0x47/0x62
> [ 2849.098756]  [<ffffffff8121c47b>] get_request_wait+0x10a/0x197
> [ 2849.098760]  [<ffffffff8106cd77>] ? autoremove_wake_function+0x0/0x3d
> [ 2849.098763]  [<ffffffff8121cd3c>] __make_request+0x2c8/0x3e0
> [ 2849.098767]  [<ffffffff81114889>] ? kmem_cache_alloc+0x73/0xeb
> [ 2849.098771]  [<ffffffff8121bbdf>] generic_make_request+0x2bc/0x336
> [ 2849.098774]  [<ffffffff8121bd39>] submit_bio+0xe0/0xff
> [ 2849.098777]  [<ffffffff8114d7a5>] ? bio_alloc_bioset+0x4d/0xc4
> [ 2849.098781]  [<ffffffff810edf2b>] ? inc_zone_page_state+0x2d/0x2f
> [ 2849.098785]  [<ffffffff811492ec>] submit_bh+0xe8/0x10e
> [ 2849.098788]  [<ffffffff8114ba72>] __block_write_full_page+0x1ea/0x2da
> [ 2849.098793]  [<ffffffffa06e5202>] ? udf_get_block+0x0/0x115 [udf]
> [ 2849.098796]  [<ffffffff8114a6b8>] ? end_buffer_async_write+0x0/0x12d
> [ 2849.098799]  [<ffffffff8114a6b8>] ? end_buffer_async_write+0x0/0x12d
> [ 2849.098802]  [<ffffffffa06e5202>] ? udf_get_block+0x0/0x115 [udf]
> [ 2849.098805]  [<ffffffff8114bbee>] block_write_full_page_endio+0x8c/0x98
> [ 2849.098808]  [<ffffffff8114bc0f>] block_write_full_page+0x15/0x17
> [ 2849.098811]  [<ffffffffa06e2027>] udf_writepage+0x18/0x1a [udf]
> [ 2849.098814]  [<ffffffff810e44fd>] pageout+0x138/0x255
> [ 2849.098817]  [<ffffffff810e5ad7>] shrink_page_list+0x279/0x478
> [ 2849.098820]  [<ffffffff810e60ec>] shrink_inactive_list+0x23c/0x39a
> [ 2849.098824]  [<ffffffff81481a46>] ? add_preempt_count+0xae/0xb2
> [ 2849.098828]  [<ffffffff810dfe81>] ? determine_dirtyable_memory+0x1d/0x27
> [ 2849.098831]  [<ffffffff810e6849>] shrink_zone+0x362/0x464
> [ 2849.098834]  [<ffffffff810dbdf8>] ? zone_watermark_ok_safe+0xa1/0xae
> [ 2849.098837]  [<ffffffff810e773f>] kswapd+0x51c/0x89f
>
> I'm unsure if there's any other problem left that can be attributed to
> compaction/migrate (especially considering the THP allocations have no
> __GFP_REPEAT set and should_continue_reclaim should break the loop if
> nr_reclaim is zero, plus compaction_suitable requires not much more
> memory to be reclaimed if compared to no-compaction).
>
> I'd suggest to try a few more times with "echo never>
> /sys/kernel/mm/transparent_hugepage/enabled" and see if it still makes
> a difference.
>
> I doubt udf is as optimal as other fs in optimizing locks and
> writebacks but that may not be relevant to this issue (or at least it
> most certainly wasn't until now and the same we had so far probably
> applied to all fs, from this point things aren't as clear as before if
> responsiveness is still worse than without THP). Anther thing that I
> find confusing is the udf vs USB stick, I'd expect udf on a usb dvd
> not a usbstick flash drive, I'd use vfat or ext4 on a flash drive.
>
By echoing "never" to /sys/kernel/mm/transparent_hugepage/enabled , the copy still goes smoothly without any application freezes, even with the recent patch applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
