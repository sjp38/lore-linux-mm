Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 967C46B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:23:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so5205568wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:23:51 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id q7si1448378wra.198.2017.06.28.03.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 03:23:50 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id 62so48839498wmw.1
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:23:50 -0700 (PDT)
Date: Wed, 28 Jun 2017 13:15:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp, mm: Fix crash due race in MADV_FREE handling
Message-ID: <20170628101550.7uybtgfaejtxd7jv@node.shutemov.name>
References: <20170628101249.17879-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628101249.17879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Wed, Jun 28, 2017 at 01:12:49PM +0300, Kirill A. Shutemov wrote:
> Reinette reported following crash:
> 
>   BUG: Bad page state in process log2exe  pfn:57600
>   page:ffffea00015d8000 count:0 mapcount:0 mapping:          (null) index:0x20200
>   flags: 0x4000000000040019(locked|uptodate|dirty|swapbacked)
>   raw: 4000000000040019 0000000000000000 0000000000020200 00000000ffffffff
>   raw: ffffea00015d8020 ffffea00015d8020 0000000000000000 0000000000000000
>   page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
>   bad because of flags: 0x1(locked)
>   Modules linked in: rfcomm 8021q bnep intel_rapl x86_pkg_temp_thermal coretemp efivars btusb btrtl btbcm pwm_lpss_pci snd_hda_codec_hdmi btintel pwm_lpss snd_hda_codec_realtek snd_soc_skl snd_hda_codec_generic snd_soc_skl_ipc spi_pxa2xx_platform snd_soc_sst_ipc snd_soc_sst_dsp i2c_designware_platform i2c_designware_core snd_hda_ext_core snd_soc_sst_match snd_hda_intel snd_hda_codec mei_me snd_hda_core mei snd_soc_rt286 snd_soc_rl6347a snd_soc_core efivarfs
>   CPU: 1 PID: 354 Comm: log2exe Not tainted 4.12.0-rc7-test-test #19
>   Hardware name: Intel corporation NUC6CAYS/NUC6CAYB, BIOS AYAPLCEL.86A.0027.2016.1108.1529 11/08/2016
>   Call Trace:
>    dump_stack+0x95/0xeb
>    bad_page+0x16a/0x1f0
>    free_pages_check_bad+0x117/0x190
>    ? rcu_read_lock_sched_held+0xa8/0x130
>    free_hot_cold_page+0x7b1/0xad0
>    __put_page+0x70/0xa0
>    madvise_free_huge_pmd+0x627/0x7b0
>    madvise_free_pte_range+0x6f8/0x1150
>    ? debug_check_no_locks_freed+0x280/0x280
>    ? swapin_walk_pmd_entry+0x380/0x380
>    __walk_page_range+0x6b5/0xe30
>    walk_page_range+0x13b/0x310
>    madvise_free_page_range.isra.16+0xad/0xd0
>    ? force_swapin_readahead+0x110/0x110
>    ? swapin_walk_pmd_entry+0x380/0x380
>    ? lru_add_drain_cpu+0x160/0x320
>    madvise_free_single_vma+0x2e4/0x470
>    ? madvise_free_page_range.isra.16+0xd0/0xd0
>    ? vmacache_update+0x100/0x130
>    ? find_vma+0x35/0x160
>    SyS_madvise+0x8ce/0x1450
> 
> If somebody frees the page under us and we hold the last reference to
> it, put_page() would attempt to free the page before unlocking it.
> 
> The fix is trivial reorder of operations.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Reinette Chatre <reinette.chatre@intel.com>
> Fixes: 9818b8cde622 ("madvise_free, thp: fix madvise_free_huge_pmd return value after splitting")

Sorry, the wrong Fixes. The right one:

Fixes: b8d3c4c3009d ("mm/huge_memory.c: don't split THP page when MADV_FREE syscall is called")

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
