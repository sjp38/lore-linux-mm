Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7DADC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C82C218F0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nZqEhfFR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C82C218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA5F08E0003; Thu, 25 Jul 2019 14:09:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E56958E0002; Thu, 25 Jul 2019 14:09:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D46318E0003; Thu, 25 Jul 2019 14:09:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2FB18E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:09:18 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id v135so22028433vke.4
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:09:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yQkJfAq6w2vHWXCGY8CJlX7sAf5KrI5hGh5G/DWUbSE=;
        b=OnSi0Eds3P87bFMhQnkOdRSuBgtnI6ohQ3fXsqnYG2HrXD4qEZCmGdJpuJXm+vaKDy
         B/6x/nxXoLOvxxW5Zl8KiHEBQG0om38JZ1gzpSkBTNhdoL/aYoRPi3qyX39KaqBxRNyz
         AWSa2NwVZhQkRHL5mEdqRiWy9rtIHvg9hC0sPKZ6kUjerNTxxkJzhAc2JHpG1VJBopsY
         zeu2VjSmU4dLs6Rz00J7TFzHbkv6I7lPlK/wPf71pkkKrlszzNITyY93W7jny2BSTrmC
         UC0XrCrRhpQQiNO0QpPH9JYAok9Ny2fX1+Vu/LI9lneqVKkbA1xdWnlJ3NEHM/z1mB/9
         47bA==
X-Gm-Message-State: APjAAAVJg8pxqus5thLsBzq9Dcc9yxIeqAP+nYSK081irg1yS/sDuthC
	wK99+yg8pdLZZetaX310/NpyolRByx0phPxhigOwUEAvLi0FlC8brjpWgqanPuXz6t1K71XsJ27
	tQXDRhf6pg0408d6AucWI7omhn4JcxInWHlbxmKFTeAlEe3jCXt/DWYBqmnRnKAm/yQ==
X-Received: by 2002:a67:2d0f:: with SMTP id t15mr54990810vst.26.1564078158377;
        Thu, 25 Jul 2019 11:09:18 -0700 (PDT)
X-Received: by 2002:a67:2d0f:: with SMTP id t15mr54990739vst.26.1564078157658;
        Thu, 25 Jul 2019 11:09:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564078157; cv=none;
        d=google.com; s=arc-20160816;
        b=En1glfdK3/yf/uMKzRv0KAqPJwx84PdRTsTjxhA2L7YX2D/0A1v12qSV4Y39TANOFy
         g6dkEbaQbD6fSFmh8hGl29GJcI+KnkYf3ic6socwIkhPVPslNuR7w6BtfDk9UuJLEP6J
         17bJmUYkTjakSXiPs8MxMQtq5L3ixJwis+6nsVQK5+a+ydRgYnlbFK653rAvHVXStfEA
         n3DOE7y3qr3kkTY2I5TZCLasSiowSUb+Z/mhzNrttUEk5xroKq0QC7gsrfwOFfxWRXDK
         hpr68EXAN2FTUoaIyGDgRtnsUWAmrcNKimcwJQzgAxvjr+ywXzZoktBnIKP+vDR1121a
         AiFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yQkJfAq6w2vHWXCGY8CJlX7sAf5KrI5hGh5G/DWUbSE=;
        b=rJnavGIRc87l9VBK1nHazc3F2Ju0MYesRqhzYVI5uj10TImT/QK6vw/SSJoWIUX+Vo
         j/K4/MvBzrch/nxnlcAEnAHRYY8LGTlwrT8qevTpOjHZ7yegKt8A86ZeNNy2+uqLwkqm
         m/1eIe4L2d4WEZQeatOLeZ95ozLYw2hljau+g1M7iviMhPqPJJj87gV4EVpHD0FXmbRW
         E1/DL4VfOEvDCQly2v36J9VQnBzh940OZ/fjPMrVjYWzaY7WM9PEf4NWvO05P6pNtYo4
         CMGl0bG9sUU0x9fsu1xEr++ZC2TpWlBZwDrulPDWaI9I5w6O11p8rGOXkcRbjDRJk7bZ
         4GrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nZqEhfFR;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor25133064vsj.93.2019.07.25.11.09.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:09:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nZqEhfFR;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yQkJfAq6w2vHWXCGY8CJlX7sAf5KrI5hGh5G/DWUbSE=;
        b=nZqEhfFRSm0yhJHGECsERx8km+FW6sLeuBozoNXLRjEwXSQkj/j4YsA+L4+TVOTFy8
         ZMlqrqE8BdCPn5504Lui8tNIIXrqzuoDpXFipkd7MrmCbOJ0EHdsYiBARVFk05UIDxRC
         8dcGpYtkf3xgVrilvgs5mUAIPcS4h6BW0dsqz7woQ3R8UzzN9tylqY9SNtOkMu50tsJp
         MY0920heANbwqrtwpmZofFxHb3Yb4NNcWBMhhETgETdbb7fjjlJH3jAvE3FWUfPniEsO
         EH3oc+RUZL5c63fFpfL48Ex+/Nq7bNPe11l4tZddmkW3aewOmgRpiX2QqRnjJ1eOcpi4
         JnmA==
X-Google-Smtp-Source: APXvYqxrHq2+gGn17JuXE8+fJgfmZKHhv5dRuqNmbs504UKMlMZPJgnA5bVtfzJ2LHYPIaZ1PFVLHSc/4HCYmcyyUE4=
X-Received: by 2002:a67:fc19:: with SMTP id o25mr57199329vsq.106.1564078157202;
 Thu, 25 Jul 2019 11:09:17 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo56EoKca9FJCnbztWZAARdUQs+B=dmCs+UxW27yHNu5pzQ@mail.gmail.com>
 <57f8aa35-d460-9933-a547-fbf578ea42d3@arm.com> <20190716121026.GB2388@lst.de>
In-Reply-To: <20190716121026.GB2388@lst.de>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Thu, 25 Jul 2019 23:39:08 +0530
Message-ID: <CACDBo56RWh=kjhEm_eOpzkTuZ+A-VEuCYPnVJW1BYAXrP6LERg@mail.gmail.com>
Subject: Re: cma_remap when using dma_alloc_attr :- DMA_ATTR_NO_KERNEL_MAPPING
To: Christoph Hellwig <hch@lst.de>
Cc: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	iommu@lists.linux-foundation.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>, pankaj.suryawanshi@einfochips.com, minchan@kernel.org, 
	minchan.kim@gmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 5:40 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Tue, Jul 16, 2019 at 01:02:19PM +0100, Robin Murphy wrote:
> >> Lets say 4k video allocation required 300MB cma memory but not required
> >> virtual mapping for all the 300MB, its require only 20MB virtually mapped
> >> at some specific use case/point of video, and unmap virtual mapping after
> >> uses, at that time this functions will be useful, it works like ioremap()
> >> for cma_alloc() using dma apis.
> >
> > Hmm, is there any significant reason that this case couldn't be handled
> > with just get_vm_area() plus dma_mmap_attrs(). I know it's only *intended*
> > for userspace mappings, but since the basic machinery is there...
>
> Because the dma helper really are a black box abstraction.
>
> That being said DMA_ATTR_NO_KERNEL_MAPPING and DMA_ATTR_NON_CONSISTENT
> have been a constant pain in the b**t.  I've been toying with replacing
> them with a dma_alloc_pages or similar abstraction that just returns
> a struct page that is guaranteed to be dma addressable by the passed
> in device.  Then the driver can call dma_map_page / dma_unmap_page /
> dma_sync_* on it at well.  This would replace DMA_ATTR_NON_CONSISTENT
> with a sensible API, and also DMA_ATTR_NO_KERNEL_MAPPING when called
> with PageHighmem, while providing an easy to understand API and
> something that can easily be fed into the various page based APIs
> in the kernel.
>
> That being said until we get arm moved over the common dma direct
> and dma-iommu code, and x86 fully moved over to dma-iommu it just
> seems way too much work to even get it into the various architectures
> that matter, never mind all the fringe IOMMUs.  So for now I've just
> been trying to contain the DMA_ATTR_NON_CONSISTENT and
> DMA_ATTR_NO_KERNEL_MAPPING in fewer places while also killing bogus
> or pointless users of these APIs.


I agree with you Christoph, users want page based api, which is useful
in many scenarios, but
As of now i think we have to move with this type of api which is
useful when dma_alloc (for cma )call with DMA_ATTR_NO_KERNEL_MAPPING,
and mapped again to kernel space, this api is useful mostly for 32-bit
system which has 4GB of limited virtual memory (its very less for
android devices) as we have already dma_mmap_attr() for user space
mapping.
This api is also useful for one who directly want to use cma_alloc()
in their own drivers. For example ion-cma.c.
Please let me know if any recommendation/suggestion/improvement required ?

Regards,
Pankaj

