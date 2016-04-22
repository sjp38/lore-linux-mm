Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B557E830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 20:01:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so92325760pfy.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:01:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e6si3250012pfa.118.2016.04.21.17.01.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 17:01:51 -0700 (PDT)
Date: Thu, 21 Apr 2016 17:01:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
Message-Id: <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
In-Reply-To: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com

On Mon, 18 Apr 2016 20:47:16 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:

> Mapping pages around fault is found to cause performance degradation
> in certain use cases. The test performed here is launch of 10 apps
> one by one, doing something with the app each time, and then repeating
> the same sequence once more, on an ARM 64-bit Android device with 2GB
> of RAM. The time taken to launch the apps is found to be better when
> fault around feature is disabled by setting fault_around_bytes to page
> size (4096 in this case).

Well that's one workload, and a somewhat strange one.  What is the
effect on other workloads (of which there are a lot!).

> The tests were done on 3.18 kernel. 4 extra vmstat counters were added
> for debugging. pgpgoutclean accounts the clean pages reclaimed via
> __delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
> and pageref_keep accounts the mapped file pages activated and retained
> by page_check_references.
> 
> === Without swap ===
>                           3.18             3.18-fault_around_bytes=4096
> -----------------------------------------------------------------------
> workingset_refault        691100           664339
> workingset_activate       210379           179139
> pgpgin                    4676096          4492780
> pgpgout                   163967           96711
> pgpgoutclean              1090664          990659
> pgalloc_dma               3463111          3328299
> pgfree                    3502365          3363866
> pgactivate                568134           238570
> pgdeactivate              752260           392138
> pageref_activate          315078           121705
> pageref_activate_vm_exec  162940           55815
> pageref_keep              141354           51011
> pgmajfault                24863            23633
> pgrefill_dma              1116370          544042
> pgscan_kswapd_dma         1735186          1234622
> pgsteal_kswapd_dma        1121769          1005725
> pgscan_direct_dma         12966            1090
> pgsteal_direct_dma        6209             967
> slabs_scanned             1539849          977351
> pageoutrun                1260             1333
> allocstall                47               7
> 
> === With swap ===
>                           3.18             3.18-fault_around_bytes=4096
> -----------------------------------------------------------------------
> workingset_refault        597687           878109
> workingset_activate       167169           254037
> pgpgin                    4035424          5157348
> pgpgout                   162151           85231
> pgpgoutclean              928587           1225029
> pswpin                    46033            17100
> pswpout                   237952           127686
> pgalloc_dma               3305034          3542614
> pgfree                    3354989          3592132
> pgactivate                626468           355275
> pgdeactivate              990205           771902
> pageref_activate          294780           157106
> pageref_activate_vm_exec  141722           63469
> pageref_keep              121931           63028
> pgmajfault                67818            45643
> pgrefill_dma              1324023          977192
> pgscan_kswapd_dma         1825267          1720322
> pgsteal_kswapd_dma        1181882          1365500
> pgscan_direct_dma         41957            9622
> pgsteal_direct_dma        25136            6759
> slabs_scanned             689575           542705
> pageoutrun                1234             1538
> allocstall                110              26
> 
> Looks like with fault_around, there is more pressure on reclaim because
> of the presence of more mapped pages, resulting in more IO activity,
> more faults, more swapping, and allocstalls.

A few of those things did get a bit worse?

Do you have any data on actual wall-time changes?  How much faster do
things become with the patch?  If it is "0.1%" then I'd say "umm, no".

> Make fault_around_bytes configurable so that it can be tuned to avoid
> performance degradation.

It sounds like we need to be smarter about auto-tuning this thing. 
Maybe the refault code could be taught to provide the feedback path but
that sounds hard.

Still.  I do think it would be better to make this configurable at
runtime.  Move the existing debugfs tunable into /proc/sys/vm (and
document it!).  I do dislkie adding even more tunables but this one
does make sense.  People will want to run their workloads with various
values until they find the peak throughput, and requiring a kernel
rebuild for that is a huge pain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
