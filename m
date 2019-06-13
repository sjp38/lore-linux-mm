Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38050C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:27:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D05F620851
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:27:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="crvCEGgk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D05F620851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 613B68E0002; Thu, 13 Jun 2019 14:27:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C3B18E0001; Thu, 13 Jun 2019 14:27:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B2538E0002; Thu, 13 Jun 2019 14:27:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18BCB8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:27:53 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x27so9671345ote.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:27:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=MQQWIXbMnO77ZtHyX2kfFVvlpzWpGkMLz/R1+ir3QOA=;
        b=RSzE8b5pL+mAwIm/hll7a4DyErcyjROUOHmfPHXw8NykP4N02GNdNEvZbJj9X8yafU
         5GDVZGiRLGIez2HpHq8yxvDn/TpLusaw22RQT4TW+7gWViLoZ55buNi1D5+re4rAdG2c
         TGkXdEiEq8DKPHVrbwY+U3MCq28RzAM5e4tVkF+G3ID/mnnLvOL9VbaNfTQdnEJyLSNj
         Gi4JlxWh1rUcCj9OBmMmp2+GnVn78LcFC85Z5dzwOCBZ6PzkPJNxDyS3/NaIHCLNvXih
         eO9pclbBsAdcfr1D9AbiGy0Rd/cjvqhcD71fYHAykVnxdUsCFX7NrXeLuf4mn5GQTHOJ
         PQDA==
X-Gm-Message-State: APjAAAUB7o8Ns7cz2lc5XzinrHPcQnRv0E6B2/Tf+yy+S/OKY+hnTwtr
	Lio6r/ErYklir5kQPUBVm6SMPeiDhf9oJSgN2Lr+tccTcRqIrFB+lzLBxd5ZhkIymrO5oi2QpTs
	GdwI4WjtEutWO0NXuScK0Dj7oZDIsPC4AXHptMEXrJ5qzGLdV+jILUvMW5WnRJ28Glw==
X-Received: by 2002:a9d:711e:: with SMTP id n30mr9637820otj.97.1560450472734;
        Thu, 13 Jun 2019 11:27:52 -0700 (PDT)
X-Received: by 2002:a9d:711e:: with SMTP id n30mr9637777otj.97.1560450471921;
        Thu, 13 Jun 2019 11:27:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560450471; cv=none;
        d=google.com; s=arc-20160816;
        b=W2AZ7w/9/AW/9vIhdNDJJvelD90jnGnOcPQle3UNH9Fqlp2Sdkqqp4MypcbN8s3IVt
         uEAf19dRSaL68hJPz1ACP/gZs78C1n1qD890vlNGUD7w3Y3KU72a2ywcYwQ8R+U/sqzm
         l3+23wLDYTjy+2fs3h+B0Y6Yx/m/5I5+wgCwrP14qhFD6H+pdoBvkkDn9xNX+wq27n43
         KsGqeUVwb8Y92julga8DDbB0FhdvNY3Q7s/R3BHepf62SjxmBUsmAjR+8Y4yYHAOZHXa
         w7zLFEFrCX8RHhhgEqxB1VlIiXqNSjH3n1owBgLOGFkVm6ICnodTtt5BH9iTHddwfgRb
         YooA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=MQQWIXbMnO77ZtHyX2kfFVvlpzWpGkMLz/R1+ir3QOA=;
        b=J+Nkyxocxs++xZdQYkbIqipuSPcb1G6awNWS+96NUbWsV7u02SqFUQKbQz4GmA6vgi
         M4m/36j/+YwCpYsoss8Pue/w3zYfPdo/Xzxl6NTXgrL8d8pOXDzypdwSF6pnfqvQPTie
         vvX/I5tsP2K+kfOsI3UzjyNrudrLfp4A5r89y/EUxvSIS5izx1RU0me+P4n37atMeB7M
         WXBpl9/H2m+SbMXVzWaNSmcxM0K0Ya6PtkJ/whDaknUmFWynvKEVH8jRn0msg1m1L8Rz
         iUXJmsrbTR9vMeSCYSL0e2UtECiF4Su7Y3xazgbDTyvCnKO9P6WzdsgvheGqvDKsUvhi
         63ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=crvCEGgk;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v191sor220008oif.12.2019.06.13.11.27.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 11:27:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=crvCEGgk;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=MQQWIXbMnO77ZtHyX2kfFVvlpzWpGkMLz/R1+ir3QOA=;
        b=crvCEGgkqd+iu3jPAVCgc0rO9kwagRqhiuh9lqc2Ju8CbgOGid+cpJ19wpMCBIaSji
         U8Mz0dX1Um88VCqaKkUNTGuID9Bzc63KYSiIdoNpp/7dpBf8k6fFGIdSQ7ELDhxa2lhq
         O+Cm1rdZssbK5qGXuJrRKvIFe20o9RjF63pnvwmTOEXNE3m0kL4mYXXHPHnWB7iNGKvf
         IRmvCqhPr54CoqyHGAWbyFjtaCU9quXmW4KMHVoz5mhnnS/xbbV6lznIglpAz1QTbisQ
         VH8TIrLDYodoKV2w14PaLsUgipHZwL/KVe25acJc00UDmNqVKP+RWr4Mjo9Lxw4wybxj
         3jlw==
X-Google-Smtp-Source: APXvYqwS3UGoJsEHP8JK1xPznND3LFKZmK0TBwbTuAL+csM43V1iR6xbM76Rxv8Te4jLIHldpTP2/DzDl/DDdZFYcCo=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr4031867oii.0.1560450471426;
 Thu, 13 Jun 2019 11:27:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de>
In-Reply-To: <20190613094326.24093-1-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 11:27:39 -0700
Message-ID: <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
Subject: Re: dev_pagemap related cleanups
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 2:43 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Hi Dan, J=C3=A9r=C3=B4me and Jason,
>
> below is a series that cleans up the dev_pagemap interface so that
> it is more easily usable, which removes the need to wrap it in hmm
> and thus allowing to kill a lot of code
>
> Diffstat:
>
>  22 files changed, 245 insertions(+), 802 deletions(-)

Hooray!

> Git tree:
>
>     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup

I just realized this collides with the dev_pagemap release rework in
Andrew's tree (commit ids below are from next.git and are not stable)

4422ee8476f0 mm/devm_memremap_pages: fix final page put race
771f0714d0dc PCI/P2PDMA: track pgmap references per resource, not globally
af37085de906 lib/genalloc: introduce chunk owners
e0047ff8aa77 PCI/P2PDMA: fix the gen_pool_add_virt() failure path
0315d47d6ae9 mm/devm_memremap_pages: introduce devm_memunmap_pages
216475c7eaa8 drivers/base/devres: introduce devm_release_action()

CONFLICT (content): Merge conflict in tools/testing/nvdimm/test/iomap.c
CONFLICT (content): Merge conflict in mm/hmm.c
CONFLICT (content): Merge conflict in kernel/memremap.c
CONFLICT (content): Merge conflict in include/linux/memremap.h
CONFLICT (content): Merge conflict in drivers/pci/p2pdma.c
CONFLICT (content): Merge conflict in drivers/nvdimm/pmem.c
CONFLICT (content): Merge conflict in drivers/dax/device.c
CONFLICT (content): Merge conflict in drivers/dax/dax-private.h

Perhaps we should pull those out and resend them through hmm.git?

It also turns out the nvdimm unit tests crash with this signature on
that branch where base v5.2-rc3 passes:

    BUG: kernel NULL pointer dereference, address: 0000000000000008
    [..]
    CPU: 15 PID: 1414 Comm: lt-libndctl Tainted: G           OE
5.2.0-rc3+ #3399
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 0.0.0 02/06=
/2015
    RIP: 0010:percpu_ref_kill_and_confirm+0x1e/0x180
    [..]
    Call Trace:
     release_nodes+0x234/0x280
     device_release_driver_internal+0xe8/0x1b0
     bus_remove_device+0xf2/0x160
     device_del+0x166/0x370
     unregister_dev_dax+0x23/0x50
     release_nodes+0x234/0x280
     device_release_driver_internal+0xe8/0x1b0
     unbind_store+0x94/0x120
     kernfs_fop_write+0xf0/0x1a0
     vfs_write+0xb7/0x1b0
     ksys_write+0x5c/0xd0
     do_syscall_64+0x60/0x240

The crash bisects to:

    d8cc8bbe108c device-dax: use the dev_pagemap internal refcount

