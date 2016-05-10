Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B00FE6B007E
	for <linux-mm@kvack.org>; Mon,  9 May 2016 23:27:08 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so6371947iod.2
        for <linux-mm@kvack.org>; Mon, 09 May 2016 20:27:08 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y7si587551igl.65.2016.05.09.20.27.06
        for <linux-mm@kvack.org>;
        Mon, 09 May 2016 20:27:07 -0700 (PDT)
Date: Tue, 10 May 2016 11:48:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
Message-ID: <20160510024842.GC4426@bbox>
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
 <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
 <5719E494.20302@codeaurora.org>
 <20160422094430.GA7336@node.shutemov.name>
 <fdc23a2a-b42a-f0af-d403-41ea4e755084@codeaurora.org>
 <20160509073251.GA5434@blaptop>
MIME-Version: 1.0
In-Reply-To: <20160509073251.GA5434@blaptop>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com

On Mon, May 09, 2016 at 04:32:51PM +0900, Minchan Kim wrote:
> Hello,
> 
> On Mon, Apr 25, 2016 at 05:21:11PM +0530, Vinayak Menon wrote:
> > 
> > 
> > On 4/22/2016 3:14 PM, Kirill A. Shutemov wrote:
> > > On Fri, Apr 22, 2016 at 02:15:08PM +0530, Vinayak Menon wrote:
> > >> On 04/22/2016 05:31 AM, Andrew Morton wrote:
> > >>> On Mon, 18 Apr 2016 20:47:16 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:
> > >>>
> > >>>> Mapping pages around fault is found to cause performance degradation
> > >>>> in certain use cases. The test performed here is launch of 10 apps
> > >>>> one by one, doing something with the app each time, and then repeating
> > >>>> the same sequence once more, on an ARM 64-bit Android device with 2GB
> > >>>> of RAM. The time taken to launch the apps is found to be better when
> > >>>> fault around feature is disabled by setting fault_around_bytes to page
> > >>>> size (4096 in this case).
> > >>> Well that's one workload, and a somewhat strange one.  What is the
> > >>> effect on other workloads (of which there are a lot!).
> > >>>
> > >> This workload emulates the way a user would use his mobile device, opening
> > >> an application, using it for some time, switching to next, and then coming
> > >> back to the same application later. Another stat which shows significant
> > >> degradation on Android with fault_around is device boot up time. I have not
> > >> tried any other workload other than these.
> > >>
> > >>>> The tests were done on 3.18 kernel. 4 extra vmstat counters were added
> > >>>> for debugging. pgpgoutclean accounts the clean pages reclaimed via
> > >>>> __delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
> > >>>> and pageref_keep accounts the mapped file pages activated and retained
> > >>>> by page_check_references.
> > >>>>
> > >>>> === Without swap ===
> > >>>>                           3.18             3.18-fault_around_bytes=4096
> > >>>> -----------------------------------------------------------------------
> > >>>> workingset_refault        691100           664339
> > >>>> workingset_activate       210379           179139
> > >>>> pgpgin                    4676096          4492780
> > >>>> pgpgout                   163967           96711
> > >>>> pgpgoutclean              1090664          990659
> > >>>> pgalloc_dma               3463111          3328299
> > >>>> pgfree                    3502365          3363866
> > >>>> pgactivate                568134           238570
> > >>>> pgdeactivate              752260           392138
> > >>>> pageref_activate          315078           121705
> > >>>> pageref_activate_vm_exec  162940           55815
> > >>>> pageref_keep              141354           51011
> > >>>> pgmajfault                24863            23633
> > >>>> pgrefill_dma              1116370          544042
> > >>>> pgscan_kswapd_dma         1735186          1234622
> > >>>> pgsteal_kswapd_dma        1121769          1005725
> > >>>> pgscan_direct_dma         12966            1090
> > >>>> pgsteal_direct_dma        6209             967
> > >>>> slabs_scanned             1539849          977351
> > >>>> pageoutrun                1260             1333
> > >>>> allocstall                47               7
> > >>>>
> > >>>> === With swap ===
> > >>>>                           3.18             3.18-fault_around_bytes=4096
> > >>>> -----------------------------------------------------------------------
> > >>>> workingset_refault        597687           878109
> > >>>> workingset_activate       167169           254037
> > >>>> pgpgin                    4035424          5157348
> > >>>> pgpgout                   162151           85231
> > >>>> pgpgoutclean              928587           1225029
> > >>>> pswpin                    46033            17100
> > >>>> pswpout                   237952           127686
> > >>>> pgalloc_dma               3305034          3542614
> > >>>> pgfree                    3354989          3592132
> > >>>> pgactivate                626468           355275
> > >>>> pgdeactivate              990205           771902
> > >>>> pageref_activate          294780           157106
> > >>>> pageref_activate_vm_exec  141722           63469
> > >>>> pageref_keep              121931           63028
> > >>>> pgmajfault                67818            45643
> > >>>> pgrefill_dma              1324023          977192
> > >>>> pgscan_kswapd_dma         1825267          1720322
> > >>>> pgsteal_kswapd_dma        1181882          1365500
> > >>>> pgscan_direct_dma         41957            9622
> > >>>> pgsteal_direct_dma        25136            6759
> > >>>> slabs_scanned             689575           542705
> > >>>> pageoutrun                1234             1538
> > >>>> allocstall                110              26
> > >>>>
> > >>>> Looks like with fault_around, there is more pressure on reclaim because
> > >>>> of the presence of more mapped pages, resulting in more IO activity,
> > >>>> more faults, more swapping, and allocstalls.
> > >>> A few of those things did get a bit worse?
> > >> I think some numbers (like workingset, pgpgin, pgpgoutclean etc) looks
> > >> better with fault_around because, increased number of mapped pages is
> > >> resulting in less number of file pages being reclaimed (pageref_activate,
> > >> pageref_activate_vm_exec, pageref_keep above), but increased swapping.
> > >> Latency numbers are far bad with fault_around_bytes + swap, possibly because
> > >> of increased swapping, decrease in kswapd efficiency and increase in
> > >> allocstalls.
> > >> So the problem looks to be that unwanted pages are mapped around the fault
> > >> and page_check_references is unaware of this.
> > > Hm. It makes me think we should make ptes setup by faultaround old.
> > >
> > > Although, it would defeat (to some extend) purpose of faultaround on
> > > architectures without HW accessed bit :-/
> > >
> > > Could you check if the patch below changes the situation?
> > > It would require some more work to not mark the pte we've got fault for old.
> > 
> > Column at the end shows the values with the patch
> > 
> >                   3.18   3.18-fab=4096  3.18-Kirill's-fix
> > 
> > ---------------------------------------------------------
> > 
> > workingset_refault        597687   878109   790207
> > 
> > workingset_activate       167169   254037   207912
> > 
> > pgpgin                    4035424  5157348  4793116
> > 
> > pgpgout                   162151   85231    85539
> > 
> > pgpgoutclean              928587   1225029  1129088
> > 
> > pswpin                    46033    17100    8926
> > 
> > pswpout                   237952   127686   103435
> > 
> > pgalloc_dma               3305034  3542614  3401000
> > 
> > pgfree                    3354989  3592132  3457783
> > 
> > pgactivate                626468   355275   326716
> > 
> > pgdeactivate              990205   771902   697392
> > 
> > pageref_activate          294780   157106   138451
> > 
> > pageref_activate_vm_exec  141722   63469    64585
> > 
> > pageref_keep              121931   63028    65811
> > 
> > pgmajfault                67818    45643    34944
> > 
> > pgrefill_dma              1324023  977192   874497
> > 
> > pgscan_kswapd_dma         1825267  1720322  1577483
> > 
> > pgsteal_kswapd_dma        1181882  1365500  1243968
> > 
> > pgscan_direct_dma         41957    9622     9387
> > 
> > pgsteal_direct_dma        25136    6759     7108
> > 
> > slabs_scanned             689575   542705   618839
> > 
> > pageoutrun                1234     1538     1450
> > 
> > allocstall                110      26       13
> > 
> > Everything seems to have improved except slabs_scanned, possibly because
> > of this check which Minchan pointed out, that results in higher pressure on slabs.
> > 
> > if (page_mapped(page) || PageSwapCache(page))
> > 
> >     sc->nr_scanned++;
> > 
> > I had added some traces to monitor the vmpressure values. Those also seems to
> > be high, possibly because of the same reason.
> > 
> > Should the pressure be doubled only if page is mapped and referenced ?
> 
> Yes, pte_mkold is not perfect at the moment.
> 
> Anyway, above heuristic has been in there for a long time since I was born
> maybe :) (I don't want to argue why it's there and whether it's right) So,
> I'm really hesitant to change it that it might bite some workloads.
> (But I don't mean I'm against it but just don't want to make it by myself
> to avoid potential blame). IOW, Kirill's fault_around broke it too so it
> could bite some workloads.
> 
> At least, as Vinayak mentioned, it would change vmpressure level so users of
> vmpressure can be affected. AFAIK, some vendors in embedded side relies on
> vmpressure to control memory management so it will hurt them.
> As well, slab shrinking behavior was changed, too. Unfortunately, I don't
> know any workload is dependent with it.
> 
> As other regression in my company product, we have snapshot a process
> with workingset for later fast resume. For that, we have considered
> pte-mapped pages as workingset for snapshot but snapshot start to include
> non-workingset pages since fault-around is merged. It means snapshot
> image size is increased so that we need more storage space and it starts
> the thing slow down. I guess mincore(2) users will be affected.
> 
> Additional Note: There are lots of products with ARM which is non-HW access
> bit system in embedded world although ARM start to support it recenlty and
> sequential file access workload is not important compared to memory reclaim
> So, fault_around's benefit could be higly limited compared to HW-access bit
> architectures on server workload.
> 
> I want to ask again.
> I guess we could disable fault_around by kernel parameter but does it
> sound reasonable to enable fault_around by default for every arches
> at the cost of above regression?
> 
> I'm not against for that. Just what I want is some fixes about the
> regression should go to -stable.
> 
> > 
> > There is big improvement in avg latency, but still 5% higher than with fault_around
> > disabled. I will try to debug this further.

I did quick test in my ARM machine.

512M file mmap sequential every word read

= vanilla fault_around=4096 =
minor fault: 131291
elapsed time(usec): 6686236

= vanilla fault_around=65536 =
minor fault: 12577
elapsed time(usec): 6586959

I tested 3 times and result seemed to be stable.
90% minor fault was reduced. It's huge win but as looking at elapsed time,
it's not huge win. Just about 1.5%.

= pte_mkold applied fault_around=4096 =
minor fault: 131291
elapsed time(usec): 6608358

= pte_mkold applied fault_around=65536 =
minor fault: 143609
elapsed time(usec): 6772520

I tested 3 times and result seemed to be stable.
minor fault was rather increased and elapsed time was slow with
fault_around.
Gain is really not clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
