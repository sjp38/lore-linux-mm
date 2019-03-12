Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C945FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BC822173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 23:32:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BC822173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCB0E8E0003; Tue, 12 Mar 2019 19:32:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7A888E0002; Tue, 12 Mar 2019 19:32:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A689C8E0003; Tue, 12 Mar 2019 19:32:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61ACB8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 19:32:08 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j10so4832799pfn.13
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:32:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0iQObOkZ72kLNPB4QTa5CPExJBocYoE5w6OoqUu1CKw=;
        b=C8Zg8mvdPdOPfYEkR9+8I/qVfBpDVyxLxtSlm579GwxGjfB2IXAgnh1F14PjVjwgWF
         M3o34bBmxMvMRFc5SZSMGGeo7roDu7j3WWrLdNSTHqX49O6PYI9LsdyY2bQ/01Y/oqp3
         J9GTkaBgz6hj0eShDjUp8hhpoIFWVBJgbEikuD7NHn99O7WdqAvi0m6Efrt2cLptHcv8
         5YephYMVOkggZjHy0HyXl0/iygDkbO7JM/TdBO4LRTShbNJaZ/XT2xlMPORUdxBFUuKK
         3YMs65hhVy2toSBCaTIgWqvk/MecL1OMRDZdBxaasHInyXZa4AZuexuaL0cXkJfZUu2r
         ga8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXDV22wvwwPqyG1Z6cKKnksO85LCtXEb77wmbzZ7wfmzwz37UBX
	Wm2zDeRb0TJE0oaCf74tmbGwL38CBIkXJE6vOAgcgE7ITfIvMM/RWk4/B5vg+I2CfqJjCJTxIky
	miG1OqlE7q9p0oYNzNmDC8qhSAs8zRB5dhDEDNmhrdIZugVQCTI2WohVgwIbQBIA6fw==
X-Received: by 2002:a17:902:7e49:: with SMTP id a9mr40102943pln.303.1552433526531;
        Tue, 12 Mar 2019 16:32:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6SVGOFT/CGb+1E5zqzIcV/d8HygttSAOqt5UfVi0U4ERc6qTOIPS78dwgkaHAl8dkGQd3
X-Received: by 2002:a17:902:7e49:: with SMTP id a9mr40102758pln.303.1552433523367;
        Tue, 12 Mar 2019 16:32:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552433523; cv=none;
        d=google.com; s=arc-20160816;
        b=WQDf1l6fP5pO813DoJLKJGIAnUkcvhKJ1OE3oohIwW/KQJJVy6hHiJVM/+vaA3i4RP
         E2b3PD4LqITWs1g+dMgvO0Ywa8weJkfmx9bTRf9od29uZS2Uw2jwFYyljSWRUn+E+Chi
         SKfkiVOUEtdzB2YkbXmKC1KOakb35EIABauyIraiGL8/1oPP1dr/6BR6ADCR3QGkvip7
         pexfXAb3T2qQSWHkbSHqbvJPjAvolBvD9gEpc9QeXF7QXo/SgqFkqEj41vpZ6Fw/DgXo
         NXKTE0xhneZVxjQcq3k0GeCUusL41sV1AiVgz+jBPwxVfmQDYwEg1e8ZGe10DCE7qIiQ
         +jkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0iQObOkZ72kLNPB4QTa5CPExJBocYoE5w6OoqUu1CKw=;
        b=03UKkaayhrRT4f+7VTdiIJEcZopT3lQmpupt/S+5cIruwK9iFuotpRYrrO0tu5/0/v
         6zBvMfPsIEri3bpO8ygsMLhrm5QzuJjTkZuyAUu+9wpcsDAJP87yp8Nwj2W2hSPd6i7G
         ZHPPCeqeYUxZJsTFULgD/AclRiVOr9U9LJWc4Jv8USs1D78+GCXq7i5YmhVeuKc5oMhD
         v20pqEbgKOmlerKKqQFnlFipMSmaO4My4X3MOrCQrVUY/xI9WMwh7Fa+6M4QQjYaSecx
         O222oqhZ1r3uBuZmWVENpt/KEX+B7trlWq09E0UxvV0hKNnKLJDyhTekpC3w11Vp+Q5B
         vXxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u2si8587985pgp.549.2019.03.12.16.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 16:32:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Mar 2019 16:32:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,472,1544515200"; 
   d="scan'208";a="328052848"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 12 Mar 2019 16:32:02 -0700
Date: Tue, 12 Mar 2019 08:30:33 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190312153033.GG1119@iweiny-DESK2.sc.intel.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190306235455.26348-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:54:55PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Introduces put_user_page(), which simply calls put_page().
> This provides a way to update all get_user_pages*() callers,
> so that they call put_user_page(), instead of put_page().

So I've been running with these patches for a while but today while ramping up
my testing I hit the following:

[ 1355.557819] ------------[ cut here ]------------
[ 1355.563436] get_user_pages pin count overflowed
[ 1355.563446] WARNING: CPU: 1 PID: 1740 at mm/gup.c:73 get_gup_pin_page+0xa5/0xb0
[ 1355.577391] Modules linked in: ib_isert iscsi_target_mod ib_srpt target_core_mod ib_srp scsi_transpo
rt_srp ext4 mbcache jbd2 mlx4_ib opa_vnic rpcrdma sunrpc rdma_ucm ib_iser rdma_cm ib_umad iw_cm libiscs
i ib_ipoib scsi_transport_iscsi ib_cm sb_edac x86_pkg_temp_thermal intel_powerclamp coretemp kvm irqbyp
ass snd_hda_codec_realtek ib_uverbs snd_hda_codec_generic crct10dif_pclmul ledtrig_audio snd_hda_intel
crc32_pclmul snd_hda_codec snd_hda_core ghash_clmulni_intel snd_hwdep snd_pcm aesni_intel crypto_simd s
nd_timer ib_core cryptd snd glue_helper dax_pmem soundcore nd_pmem ipmi_si device_dax nd_btt ioatdma nd
_e820 ipmi_devintf ipmi_msghandler iTCO_wdt i2c_i801 iTCO_vendor_support libnvdimm pcspkr lpc_ich mei_m
e mei mfd_core wmi pcc_cpufreq acpi_cpufreq sch_fq_codel xfs libcrc32c mlx4_en sr_mod cdrom sd_mod mgag
200 drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops mlx4_core ttm crc32c_intel igb isci ah
ci dca libsas firewire_ohci drm i2c_algo_bit libahci scsi_transport_sas
[ 1355.577429]  firewire_core crc_itu_t i2c_core libata dm_mod [last unloaded: rdmavt]
[ 1355.686703] CPU: 1 PID: 1740 Comm: reg-mr Not tainted 5.0.0+ #10
[ 1355.693851] Hardware name: Intel Corporation W2600CR/W2600CR, BIOS SE5C600.86B.02.04.0003.1023201411
38 10/23/2014
[ 1355.705750] RIP: 0010:get_gup_pin_page+0xa5/0xb0
[ 1355.711348] Code: e8 40 02 ff ff 80 3d ba a2 fb 00 00 b8 b5 ff ff ff 75 bb 48 c7 c7 48 0a e9 81 89 4
4 24 04 c6 05 a1 a2 fb 00 01 e8 35 63 e8 ff <0f> 0b 8b 44 24 04 eb 9c 0f 1f 00 66 66 66 66 90 41 57 49
bf 00 00
[ 1355.733244] RSP: 0018:ffffc90005a23b30 EFLAGS: 00010286
[ 1355.739536] RAX: 0000000000000000 RBX: ffffea0014220000 RCX: 0000000000000000
[ 1355.748005] RDX: 0000000000000003 RSI: ffffffff827d94a3 RDI: 0000000000000246
[ 1355.756453] RBP: ffffea0014220000 R08: 0000000000000002 R09: 0000000000022400
[ 1355.764907] R10: 0009ccf0ad0c4203 R11: 0000000000000001 R12: 0000000000010207
[ 1355.773369] R13: ffff8884130b7040 R14: fff0000000000fff R15: 000fffffffe00000
[ 1355.781836] FS:  00007f2680d0d740(0000) GS:ffff88842e840000(0000) knlGS:0000000000000000
[ 1355.791384] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1355.798319] CR2: 0000000000589000 CR3: 000000040b05e004 CR4: 00000000000606e0
[ 1355.806809] Call Trace:
[ 1355.810078]  follow_page_pte+0x4f3/0x5c0
[ 1355.814987]  __get_user_pages+0x1eb/0x730
[ 1355.820020]  get_user_pages+0x3e/0x50
[ 1355.824657]  ib_umem_get+0x283/0x500 [ib_uverbs]
[ 1355.830340]  ? _cond_resched+0x15/0x30
[ 1355.835065]  mlx4_ib_reg_user_mr+0x75/0x1e0 [mlx4_ib]
[ 1355.841235]  ib_uverbs_reg_mr+0x10c/0x220 [ib_uverbs]
[ 1355.847400]  ib_uverbs_write+0x2f9/0x4d0 [ib_uverbs]
[ 1355.853473]  __vfs_write+0x36/0x1b0
[ 1355.857904]  ? selinux_file_permission+0xf0/0x130
[ 1355.863702]  ? security_file_permission+0x2e/0xe0
[ 1355.869503]  vfs_write+0xa5/0x1a0
[ 1355.873751]  ksys_write+0x4f/0xb0
[ 1355.878009]  do_syscall_64+0x5b/0x180
[ 1355.882656]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 1355.888862] RIP: 0033:0x7f2680ec3ed8
[ 1355.893420] Code: 89 02 48 c7 c0 ff ff ff ff eb b3 0f 1f 80 00 00 00 00 f3 0f 1e fa 48 8d 05 45 78 0
d 00 8b 00 85 c0 75 17 b8 01 00 00 00 0f 05 <48> 3d 00 f0 ff ff 77 58 c3 0f 1f 80 00 00 00 00 41 54 49
89 d4 55
[ 1355.915573] RSP: 002b:00007ffe65d50bc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
[ 1355.924621] RAX: ffffffffffffffda RBX: 00007ffe65d50c74 RCX: 00007f2680ec3ed8
[ 1355.933195] RDX: 0000000000000030 RSI: 00007ffe65d50c80 RDI: 0000000000000003
[ 1355.941760] RBP: 0000000000000030 R08: 0000000000000007 R09: 0000000000581260
[ 1355.950326] R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000581930
[ 1355.958885] R13: 000000000000000c R14: 0000000000581260 R15: 0000000000000000
[ 1355.967430] ---[ end trace bc771ac6189977a2 ]---


I'm not sure what I did to do this and I'm going to work on a reproducer.  At
the time of the Warning I only had 1 GUP user?!?!?!?!

I'm not using ODP, so I don't think the changes we have discussed there are a
problem.

Ira

> 
> Also introduces put_user_pages(), and a few dirty/locked variations,
> as a replacement for release_pages(), and also as a replacement
> for open-coded loops that release multiple pages.
> These may be used for subsequent performance improvements,
> via batching of pages to be released.
> 
> This is the first step of fixing a problem (also described in [1] and
> [2]) with interactions between get_user_pages ("gup") and filesystems.
> 
> Problem description: let's start with a bug report. Below, is what happens
> sometimes, under memory pressure, when a driver pins some pages via gup,
> and then marks those pages dirty, and releases them. Note that the gup
> documentation actually recommends that pattern. The problem is that the
> filesystem may do a writeback while the pages were gup-pinned, and then the
> filesystem believes that the pages are clean. So, when the driver later
> marks the pages as dirty, that conflicts with the filesystem's page
> tracking and results in a BUG(), like this one that I experienced:
> 
>     kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
>     backtrace:
>         ext4_writepage
>         __writepage
>         write_cache_pages
>         ext4_writepages
>         do_writepages
>         __writeback_single_inode
>         writeback_sb_inodes
>         __writeback_inodes_wb
>         wb_writeback
>         wb_workfn
>         process_one_work
>         worker_thread
>         kthread
>         ret_from_fork
> 
> ...which is due to the file system asserting that there are still buffer
> heads attached:
> 
>         ({                                                      \
>                 BUG_ON(!PagePrivate(page));                     \
>                 ((struct buffer_head *)page_private(page));     \
>         })
> 
> Dave Chinner's description of this is very clear:
> 
>     "The fundamental issue is that ->page_mkwrite must be called on every
>     write access to a clean file backed page, not just the first one.
>     How long the GUP reference lasts is irrelevant, if the page is clean
>     and you need to dirty it, you must call ->page_mkwrite before it is
>     marked writeable and dirtied. Every. Time."
> 
> This is just one symptom of the larger design problem: filesystems do not
> actually support get_user_pages() being called on their pages, and letting
> hardware write directly to those pages--even though that patter has been
> going on since about 2005 or so.
> 
> The steps are to fix it are:
> 
> 1) (This patch): provide put_user_page*() routines, intended to be used
>    for releasing pages that were pinned via get_user_pages*().
> 
> 2) Convert all of the call sites for get_user_pages*(), to
>    invoke put_user_page*(), instead of put_page(). This involves dozens of
>    call sites, and will take some time.
> 
> 3) After (2) is complete, use get_user_pages*() and put_user_page*() to
>    implement tracking of these pages. This tracking will be separate from
>    the existing struct page refcounting.
> 
> 4) Use the tracking and identification of these pages, to implement
>    special handling (especially in writeback paths) when the pages are
>    backed by a filesystem.
> 
> [1] https://lwn.net/Articles/774411/ : "DMA and get_user_pages()"
> [2] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"
> 
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>    # docs
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/mm.h | 24 ++++++++++++++
>  mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 106 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..809b7397d41e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -993,6 +993,30 @@ static inline void put_page(struct page *page)
>  		__put_page(page);
>  }
>  
> +/**
> + * put_user_page() - release a gup-pinned page
> + * @page:            pointer to page to be released
> + *
> + * Pages that were pinned via get_user_pages*() must be released via
> + * either put_user_page(), or one of the put_user_pages*() routines
> + * below. This is so that eventually, pages that are pinned via
> + * get_user_pages*() can be separately tracked and uniquely handled. In
> + * particular, interactions with RDMA and filesystems need special
> + * handling.
> + *
> + * put_user_page() and put_page() are not interchangeable, despite this early
> + * implementation that makes them look the same. put_user_page() calls must
> + * be perfectly matched up with get_user_page() calls.
> + */
> +static inline void put_user_page(struct page *page)
> +{
> +	put_page(page);
> +}
> +
> +void put_user_pages_dirty(struct page **pages, unsigned long npages);
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
> +void put_user_pages(struct page **pages, unsigned long npages);
> +
>  #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
>  #define SECTION_IN_PAGE_FLAGS
>  #endif
> diff --git a/mm/swap.c b/mm/swap.c
> index 4d7d37eb3c40..a6b4f693f46d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -133,6 +133,88 @@ void put_pages_list(struct list_head *pages)
>  }
>  EXPORT_SYMBOL(put_pages_list);
>  
> +typedef int (*set_dirty_func)(struct page *page);
> +
> +static void __put_user_pages_dirty(struct page **pages,
> +				   unsigned long npages,
> +				   set_dirty_func sdf)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++) {
> +		struct page *page = compound_head(pages[index]);
> +
> +		if (!PageDirty(page))
> +			sdf(page);
> +
> +		put_user_page(page);
> +	}
> +}
> +
> +/**
> + * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> + * variants called on that page.
> + *
> + * For each page in the @pages array, make that page (or its head page, if a
> + * compound page) dirty, if it was previously listed as clean. Then, release
> + * the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * set_page_dirty(), which does not lock the page, is used here.
> + * Therefore, it is the caller's responsibility to ensure that this is
> + * safe. If not, then put_user_pages_dirty_lock() should be called instead.
> + *
> + */
> +void put_user_pages_dirty(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty);
> +
> +/**
> + * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * For each page in the @pages array, make that page (or its head page, if a
> + * compound page) dirty, if it was previously listed as clean. Then, release
> + * the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + *
> + * This is just like put_user_pages_dirty(), except that it invokes
> + * set_page_dirty_lock(), instead of set_page_dirty().
> + *
> + */
> +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
> +{
> +	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
> +}
> +EXPORT_SYMBOL(put_user_pages_dirty_lock);
> +
> +/**
> + * put_user_pages() - release an array of gup-pinned pages.
> + * @pages:  array of pages to be marked dirty and released.
> + * @npages: number of pages in the @pages array.
> + *
> + * For each page in the @pages array, release the page using put_user_page().
> + *
> + * Please see the put_user_page() documentation for details.
> + */
> +void put_user_pages(struct page **pages, unsigned long npages)
> +{
> +	unsigned long index;
> +
> +	for (index = 0; index < npages; index++)
> +		put_user_page(pages[index]);
> +}
> +EXPORT_SYMBOL(put_user_pages);
> +
>  /*
>   * get_kernel_pages() - pin kernel pages in memory
>   * @kiov:	An array of struct kvec structures
> -- 
> 2.21.0
> 

