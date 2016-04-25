Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4F7C6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:51:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so267842495pac.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 04:51:19 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id z13si6442456pfi.155.2016.04.25.04.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 04:51:18 -0700 (PDT)
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
 <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
 <5719E494.20302@codeaurora.org> <20160422094430.GA7336@node.shutemov.name>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <fdc23a2a-b42a-f0af-d403-41ea4e755084@codeaurora.org>
Date: Mon, 25 Apr 2016 17:21:11 +0530
MIME-Version: 1.0
In-Reply-To: <20160422094430.GA7336@node.shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com



On 4/22/2016 3:14 PM, Kirill A. Shutemov wrote:
> On Fri, Apr 22, 2016 at 02:15:08PM +0530, Vinayak Menon wrote:
>> On 04/22/2016 05:31 AM, Andrew Morton wrote:
>>> On Mon, 18 Apr 2016 20:47:16 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:
>>>
>>>> Mapping pages around fault is found to cause performance degradation
>>>> in certain use cases. The test performed here is launch of 10 apps
>>>> one by one, doing something with the app each time, and then repeating
>>>> the same sequence once more, on an ARM 64-bit Android device with 2GB
>>>> of RAM. The time taken to launch the apps is found to be better when
>>>> fault around feature is disabled by setting fault_around_bytes to page
>>>> size (4096 in this case).
>>> Well that's one workload, and a somewhat strange one.  What is the
>>> effect on other workloads (of which there are a lot!).
>>>
>> This workload emulates the way a user would use his mobile device, opening
>> an application, using it for some time, switching to next, and then coming
>> back to the same application later. Another stat which shows significant
>> degradation on Android with fault_around is device boot up time. I have not
>> tried any other workload other than these.
>>
>>>> The tests were done on 3.18 kernel. 4 extra vmstat counters were added
>>>> for debugging. pgpgoutclean accounts the clean pages reclaimed via
>>>> __delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
>>>> and pageref_keep accounts the mapped file pages activated and retained
>>>> by page_check_references.
>>>>
>>>> === Without swap ===
>>>>                           3.18             3.18-fault_around_bytes=4096
>>>> -----------------------------------------------------------------------
>>>> workingset_refault        691100           664339
>>>> workingset_activate       210379           179139
>>>> pgpgin                    4676096          4492780
>>>> pgpgout                   163967           96711
>>>> pgpgoutclean              1090664          990659
>>>> pgalloc_dma               3463111          3328299
>>>> pgfree                    3502365          3363866
>>>> pgactivate                568134           238570
>>>> pgdeactivate              752260           392138
>>>> pageref_activate          315078           121705
>>>> pageref_activate_vm_exec  162940           55815
>>>> pageref_keep              141354           51011
>>>> pgmajfault                24863            23633
>>>> pgrefill_dma              1116370          544042
>>>> pgscan_kswapd_dma         1735186          1234622
>>>> pgsteal_kswapd_dma        1121769          1005725
>>>> pgscan_direct_dma         12966            1090
>>>> pgsteal_direct_dma        6209             967
>>>> slabs_scanned             1539849          977351
>>>> pageoutrun                1260             1333
>>>> allocstall                47               7
>>>>
>>>> === With swap ===
>>>>                           3.18             3.18-fault_around_bytes=4096
>>>> -----------------------------------------------------------------------
>>>> workingset_refault        597687           878109
>>>> workingset_activate       167169           254037
>>>> pgpgin                    4035424          5157348
>>>> pgpgout                   162151           85231
>>>> pgpgoutclean              928587           1225029
>>>> pswpin                    46033            17100
>>>> pswpout                   237952           127686
>>>> pgalloc_dma               3305034          3542614
>>>> pgfree                    3354989          3592132
>>>> pgactivate                626468           355275
>>>> pgdeactivate              990205           771902
>>>> pageref_activate          294780           157106
>>>> pageref_activate_vm_exec  141722           63469
>>>> pageref_keep              121931           63028
>>>> pgmajfault                67818            45643
>>>> pgrefill_dma              1324023          977192
>>>> pgscan_kswapd_dma         1825267          1720322
>>>> pgsteal_kswapd_dma        1181882          1365500
>>>> pgscan_direct_dma         41957            9622
>>>> pgsteal_direct_dma        25136            6759
>>>> slabs_scanned             689575           542705
>>>> pageoutrun                1234             1538
>>>> allocstall                110              26
>>>>
>>>> Looks like with fault_around, there is more pressure on reclaim because
>>>> of the presence of more mapped pages, resulting in more IO activity,
>>>> more faults, more swapping, and allocstalls.
>>> A few of those things did get a bit worse?
>> I think some numbers (like workingset, pgpgin, pgpgoutclean etc) looks
>> better with fault_around because, increased number of mapped pages is
>> resulting in less number of file pages being reclaimed (pageref_activate,
>> pageref_activate_vm_exec, pageref_keep above), but increased swapping.
>> Latency numbers are far bad with fault_around_bytes + swap, possibly because
>> of increased swapping, decrease in kswapd efficiency and increase in
>> allocstalls.
>> So the problem looks to be that unwanted pages are mapped around the fault
>> and page_check_references is unaware of this.
> Hm. It makes me think we should make ptes setup by faultaround old.
>
> Although, it would defeat (to some extend) purpose of faultaround on
> architectures without HW accessed bit :-/
>
> Could you check if the patch below changes the situation?
> It would require some more work to not mark the pte we've got fault for old.

Column at the end shows the values with the patch

                  3.18   3.18-fab=4096  3.18-Kirill's-fix

---------------------------------------------------------

workingset_refault        597687   878109   790207

workingset_activate       167169   254037   207912

pgpgin                    4035424  5157348  4793116

pgpgout                   162151   85231    85539

pgpgoutclean              928587   1225029  1129088

pswpin                    46033    17100    8926

pswpout                   237952   127686   103435

pgalloc_dma               3305034  3542614  3401000

pgfree                    3354989  3592132  3457783

pgactivate                626468   355275   326716

pgdeactivate              990205   771902   697392

pageref_activate          294780   157106   138451

pageref_activate_vm_exec  141722   63469    64585

pageref_keep              121931   63028    65811

pgmajfault                67818    45643    34944

pgrefill_dma              1324023  977192   874497

pgscan_kswapd_dma         1825267  1720322  1577483

pgsteal_kswapd_dma        1181882  1365500  1243968

pgscan_direct_dma         41957    9622     9387

pgsteal_direct_dma        25136    6759     7108

slabs_scanned             689575   542705   618839

pageoutrun                1234     1538     1450

allocstall                110      26       13

Everything seems to have improved except slabs_scanned, possibly because
of this check which Minchan pointed out, that results in higher pressure on slabs.

if (page_mapped(page) || PageSwapCache(page))

    sc->nr_scanned++;

I had added some traces to monitor the vmpressure values. Those also seems to
be high, possibly because of the same reason.

Should the pressure be doubled only if page is mapped and referenced ?

There is big improvement in avg latency, but still 5% higher than with fault_around
disabled. I will try to debug this further.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
