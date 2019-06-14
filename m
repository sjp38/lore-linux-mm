Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C457C31E4A
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:29:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFE720B7C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:29:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFE720B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1336B000D; Thu, 13 Jun 2019 20:29:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5523C6B000E; Thu, 13 Jun 2019 20:29:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 441A36B0266; Thu, 13 Jun 2019 20:29:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0EF6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:29:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so553466pga.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:29:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HP905bNsLC6ldC99RY7VkCxXT4EtER1tBaFKaF+h3F0=;
        b=lrT0MNiiv4jPmDWdwLcOvhdDkWqQJc1whPpGfeklVKTfDWBYTohB/g8NYGNY4OzHDE
         O368my2KXCqGQ9phHHG5FI3m3+E4qIZhelHLFI1/f7CtrElklX4vNbrBJzLhH15dqSbi
         vPPa0vjXSA4xBmJZ7K1N2aZec8xXGg3vQn7/2T+Ua5Txf7JQgI8cUHGsa+5SR05NplMi
         opZEyVjKOV66rF5y3dqF0LH53lLNDyEUjbM1Z/B/uJsc8WTphsvKoekedozhPeD8hsnW
         8LWH7fRPobvJUxmd8RlsAAFfeiIemhv/QhQiLqfsjWYbQrxeylwE8Yh8yRFuxv04AoGk
         oekA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXI+L6wDsbgOMKYkn9Z0yYAjrSFUUZsQ0VolzYJTcA3BJ/5W597
	ppHcjKIIsRhaEsNvQPew39V2a/PJHi/PkA45UViPU2DYUca1srbLHq1/Yu5hyvXc9wJtzrf4f0P
	CQotyM7wNjUb3SR6UqCg+M1+xSbXVu9qix6+hdp8QOSBfoWWKdPSdU4eZOswCLh85Dg==
X-Received: by 2002:a62:4d04:: with SMTP id a4mr95472793pfb.177.1560472188714;
        Thu, 13 Jun 2019 17:29:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFwC9EZfIz0bnDrSgya20X01bZlFR8l67CmTYu03xWolDo7dA/HRDUwG/pkeiwPbVd5iM/
X-Received: by 2002:a62:4d04:: with SMTP id a4mr95472748pfb.177.1560472187864;
        Thu, 13 Jun 2019 17:29:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560472187; cv=none;
        d=google.com; s=arc-20160816;
        b=w4vfPvRZEC6b6fIsBr1AMc6NRqkPAVF/+0r3OmLYzYy1ls/UnFkDNkWmrHX32P2ZTL
         IiNNcp+/d147euRype04fkCMx/Mg4kjedhbTswYv8m7eXvzQOCHbz3f1k8vdEPQInfTl
         /qr1Jn2t/i1PJcbCJYQmi9WXCZuZbeTAN6u6ZFNjDAR2rxGgtRjd7afoqzZQlaypTagy
         7dXqecv1NroiZcNKtob26qxqurP3dZMuuIAsbxn6AzA7805rGhQXEA27tAwT89LmcXO5
         HCVju8zjpQF37zgjGU3sGn3UuZR/8sLg87nyZSbQKxwUl+giUJajeq6tBPWaTF+ZnuuW
         c77Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=HP905bNsLC6ldC99RY7VkCxXT4EtER1tBaFKaF+h3F0=;
        b=cXGnj7nYNrK+f1hlhISdyHY/4uXK0ul6VQIWTFQaPvSCnRDo3gmARjgoOzPFnw1LBS
         2MpsaTdbeT2RRSQLc56/M25pxefntk7/sU622JQaXSNFjmzYvEXXZr73b3Ir9j+Ek9dK
         wOl9abn/+ll3ZSMKIeTX7TJqBLiAVxCpINsYj15r3FfylRimDxhtsK7U5eQWgQtE2YNC
         RduZx2g5XLW1dSuNXYW0Rjyw3HPyJJhn0h8kGlcQ/5Sa2L1yBr92rL6/69YbDvEekymx
         DR8Ds4y6YD5iSNzXXMB9h3JxGcvuJjPkWldBC3TqmPlT3q6jk01tZX8kZZguWlyKG8YI
         LsNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x123si840809pfx.157.2019.06.13.17.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:29:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 17:29:47 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 13 Jun 2019 17:29:46 -0700
Date: Thu, 13 Jun 2019 17:31:08 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190614003107.GC783@iweiny-DESK2.sc.intel.com>
References: <20190613094326.24093-1-hch@lst.de>
 <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
 <20190613204043.GD22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190613204043.GD22062@mellanox.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 08:40:46PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:27:39AM -0700, Dan Williams wrote:
> > On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > Hi Dan, Jérôme and Jason,
> > >
> > > below is a series that cleans up the dev_pagemap interface so that
> > > it is more easily usable, which removes the need to wrap it in hmm
> > > and thus allowing to kill a lot of code
> > >
> > > Diffstat:
> > >
> > >  22 files changed, 245 insertions(+), 802 deletions(-)
> > 
> > Hooray!
> > 
> > > Git tree:
> > >
> > >     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup
> > 
> > I just realized this collides with the dev_pagemap release rework in
> > Andrew's tree (commit ids below are from next.git and are not stable)
> > 
> > 4422ee8476f0 mm/devm_memremap_pages: fix final page put race
> > 771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not globally
> > af37085de906 lib/genalloc: introduce chunk owners
> > e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
> > 0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
> > 216475c7eaa8 drivers/base/devres: introduce devm_release_action()
> > 
> > CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap.c
> > CONFLICT (content): Merge conflict in mm/hmm.c
> > CONFLICT (content): Merge conflict in kernel/memremap.c
> > CONFLICT (content): Merge conflict in include/linux/memremap.h
> > CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
> > CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
> > CONFLICT (content): Merge conflict in drivers/dax/device.c
> > CONFLICT (content): Merge conflict in drivers/dax/dax-private.h
> > 
> > Perhaps we should pull those out and resend them through hmm.git?
> 
> It could be done - but how bad is the conflict resolution?
> 
> I'd be more comfortable to take a PR from you to merge into hmm.git,
> rather than raw patches, then apply CH's series on top. I think.
> 
> That way if something goes wrong you can send your PR to Linus
> directly.
> 
> > It also turns out the nvdimm unit tests crash with this signature on
> > that branch where base v5.2-rc3 passes:
> > 
> >     BUG: kernel NULL pointer dereference, address: 0000000000000008
> >     [..]
> >     CPU: 15 PID: 1414 Comm: lt-libndctl Tainted: G           OE
> > 5.2.0-rc3+ #3399
> >     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.0.0 02/06/2015
> >     RIP: 0010:percpu_ref_kill_and_confirm+0x1e/0x180
> >     [..]
> >     Call Trace:
> >      release_nodes+0x234/0x280
> >      device_release_driver_internal+0xe8/0x1b0
> >      bus_remove_device+0xf2/0x160
> >      device_del+0x166/0x370
> >      unregister_dev_dax+0x23/0x50
> >      release_nodes+0x234/0x280
> >      device_release_driver_internal+0xe8/0x1b0
> >      unbind_store+0x94/0x120
> >      kernfs_fop_write+0xf0/0x1a0
> >      vfs_write+0xb7/0x1b0
> >      ksys_write+0x5c/0xd0
> >      do_syscall_64+0x60/0x240
> 
> Too bad the trace didn't say which devm cleanup triggered it.. Did
> dev_pagemap_percpu_exit get called with a NULL pgmap->ref ?

I would guess something like that.  I did not fully wrap my head around the ref
counting there but I don't think the patch is correct.  See my review.

Ira

> 
> Jason
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

