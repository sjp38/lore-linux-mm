Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC796B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 10:17:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so10137971wme.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 07:17:20 -0700 (PDT)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id p194si4899642lfb.106.2016.04.22.07.17.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 07:17:19 -0700 (PDT)
Received: by mail-lf0-x22c.google.com with SMTP id c126so80237190lfb.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 07:17:18 -0700 (PDT)
Date: Fri, 22 Apr 2016 17:17:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
Message-ID: <20160422141716.GD7336@node.shutemov.name>
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
 <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
 <5719E494.20302@codeaurora.org>
 <20160422140153.GA2840@blaptop>
 <20160422141141.GC7336@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160422141141.GC7336@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com

On Fri, Apr 22, 2016 at 05:11:41PM +0300, Kirill A. Shutemov wrote:
> On Fri, Apr 22, 2016 at 11:02:16PM +0900, Minchan Kim wrote:
> > On Fri, Apr 22, 2016 at 02:15:08PM +0530, Vinayak Menon wrote:
> > > On 04/22/2016 05:31 AM, Andrew Morton wrote:
> > > >On Mon, 18 Apr 2016 20:47:16 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:
> > > >
> > > >>Mapping pages around fault is found to cause performance degradation
> > > >>in certain use cases. The test performed here is launch of 10 apps
> > > >>one by one, doing something with the app each time, and then repeating
> > > >>the same sequence once more, on an ARM 64-bit Android device with 2GB
> > > >>of RAM. The time taken to launch the apps is found to be better when
> > > >>fault around feature is disabled by setting fault_around_bytes to page
> > > >>size (4096 in this case).
> > > >
> > > >Well that's one workload, and a somewhat strange one.  What is the
> > > >effect on other workloads (of which there are a lot!).
> > > >
> > > This workload emulates the way a user would use his mobile device, opening
> > > an application, using it for some time, switching to next, and then coming
> > > back to the same application later. Another stat which shows significant
> > > degradation on Android with fault_around is device boot up time. I have not
> > > tried any other workload other than these.
> > > 
> > > >>The tests were done on 3.18 kernel. 4 extra vmstat counters were added
> > > >>for debugging. pgpgoutclean accounts the clean pages reclaimed via
> > > >>__delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
> > > >>and pageref_keep accounts the mapped file pages activated and retained
> > > >>by page_check_references.
> > > >>
> > > >>=== Without swap ===
> > > >>                           3.18             3.18-fault_around_bytes=4096
> > > >>-----------------------------------------------------------------------
> > > >>workingset_refault        691100           664339
> > > >>workingset_activate       210379           179139
> > > >>pgpgin                    4676096          4492780
> > > >>pgpgout                   163967           96711
> > > >>pgpgoutclean              1090664          990659
> > > >>pgalloc_dma               3463111          3328299
> > > >>pgfree                    3502365          3363866
> > > >>pgactivate                568134           238570
> > > >>pgdeactivate              752260           392138
> > > >>pageref_activate          315078           121705
> > > >>pageref_activate_vm_exec  162940           55815
> > > >>pageref_keep              141354           51011
> > > >>pgmajfault                24863            23633
> > > >>pgrefill_dma              1116370          544042
> > > >>pgscan_kswapd_dma         1735186          1234622
> > > >>pgsteal_kswapd_dma        1121769          1005725
> > > >>pgscan_direct_dma         12966            1090
> > > >>pgsteal_direct_dma        6209             967
> > > >>slabs_scanned             1539849          977351
> > > >>pageoutrun                1260             1333
> > > >>allocstall                47               7
> > > >>
> > > >>=== With swap ===
> > > >>                           3.18             3.18-fault_around_bytes=4096
> > > >>-----------------------------------------------------------------------
> > > >>workingset_refault        597687           878109
> > > >>workingset_activate       167169           254037
> > > >>pgpgin                    4035424          5157348
> > > >>pgpgout                   162151           85231
> > > >>pgpgoutclean              928587           1225029
> > > >>pswpin                    46033            17100
> > > >>pswpout                   237952           127686
> > > >>pgalloc_dma               3305034          3542614
> > > >>pgfree                    3354989          3592132
> > > >>pgactivate                626468           355275
> > > >>pgdeactivate              990205           771902
> > > >>pageref_activate          294780           157106
> > > >>pageref_activate_vm_exec  141722           63469
> > > >>pageref_keep              121931           63028
> > > >>pgmajfault                67818            45643
> > > >>pgrefill_dma              1324023          977192
> > > >>pgscan_kswapd_dma         1825267          1720322
> > > >>pgsteal_kswapd_dma        1181882          1365500
> > > >>pgscan_direct_dma         41957            9622
> > > >>pgsteal_direct_dma        25136            6759
> > > >>slabs_scanned             689575           542705
> > > >>pageoutrun                1234             1538
> > > >>allocstall                110              26
> > > >>
> > > >>Looks like with fault_around, there is more pressure on reclaim because
> > > >>of the presence of more mapped pages, resulting in more IO activity,
> > > >>more faults, more swapping, and allocstalls.
> > > >
> > > >A few of those things did get a bit worse?
> > > I think some numbers (like workingset, pgpgin, pgpgoutclean etc) looks
> > > better with fault_around because, increased number of mapped pages is
> > > resulting in less number of file pages being reclaimed (pageref_activate,
> > > pageref_activate_vm_exec, pageref_keep above), but increased swapping.
> > > Latency numbers are far bad with fault_around_bytes + swap, possibly because
> > > of increased swapping, decrease in kswapd efficiency and increase in
> > > allocstalls.
> > > So the problem looks to be that unwanted pages are mapped around the fault
> > > and page_check_references is unaware of this.
> > 
> > The page_check_references makes difference only when pte has marked access_bit.
> > 
> > enum page_references page_check_references(struct page *page)
> > {
> > 	referenced_ptes = page_referenced(page);
> > 	if (referenced_ptes) {
> > 		...
> > 			return PAGEREF_ACTIVATE
> > 	}
> > }
> > 
> > But map_pages doesn't mark ahead pages as pte_mkyoung. IOW, ptes are already
> > pte_mkold. So, I think page_check_reference shouldn't make any difference.
> 
> Actually, I've checked and mk_pte() produces young ptes for me. Not sure
> why.

Ah. Okay, _PAGE_ACCESSED included into pgprot mask, which is reasonable to
have if you handle page fault for the address. But it should be adjusted
for faultaround.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
