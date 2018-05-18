Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC2C06B05C5
	for <linux-mm@kvack.org>; Fri, 18 May 2018 05:00:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z7-v6so4936745wrg.11
        for <linux-mm@kvack.org>; Fri, 18 May 2018 02:00:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43-v6si832940eds.123.2018.05.18.02.00.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 May 2018 02:00:56 -0700 (PDT)
Date: Fri, 18 May 2018 11:00:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
 CONFIG_DEV_PAGEMAP_OPS
Message-ID: <20180518090055.o2q5wrawk67v6ppr@quack2.suse.cz>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu 17-05-18 13:06:54, Dan Williams wrote:
> In preparation for fixing dax-dma-vs-unmap issues, filesystems need to
> be able to rely on the fact that they will get wakeups on dev_pagemap
> page-idle events. Introduce MEMORY_DEVICE_FS_DAX and
> generic_dax_page_free() as common indicator / infrastructure for dax
> filesytems to require. With this change there are no users of the
> MEMORY_DEVICE_HOST designation, so remove it.
> 
> The HMM sub-system extended dev_pagemap to arrange a callback when a
> dev_pagemap managed page is freed. Since a dev_pagemap page is free /
> idle when its reference count is 1 it requires an additional branch to
> check the page-type at put_page() time. Given put_page() is a hot-path
> we do not want to incur that check if HMM is not in use, so a static
> branch is used to avoid that overhead when not necessary.
> 
> Now, the FS_DAX implementation wants to reuse this mechanism for
> receiving dev_pagemap ->page_free() callbacks. Rework the HMM-specific
> static-key into a generic mechanism that either HMM or FS_DAX code paths
> can enable.
> 
> For ARCH=um builds, and any other arch that lacks ZONE_DEVICE support,
> care must be taken to compile out the DEV_PAGEMAP_OPS infrastructure.
> However, we still need to support FS_DAX in the FS_DAX_LIMITED case
> implemented by the s390/dcssblk driver.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Reported-by: kbuild test robot <lkp@intel.com>
> Reported-by: Thomas Meyer <thomas@m3y3r.de>
> Reported-by: Dave Jiang <dave.jiang@intel.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Yeah, it looks simpler than original patches and it looks OK to me. You can
add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
