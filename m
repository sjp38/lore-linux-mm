Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A46E1C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:15:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E6DD2082C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:15:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=mev.co.uk header.i=@mev.co.uk header.b="Nl+Gx2+K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E6DD2082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mev.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009EF8E0004; Mon, 17 Jun 2019 09:15:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC328E0001; Mon, 17 Jun 2019 09:15:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC4248E0004; Mon, 17 Jun 2019 09:15:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE0058E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:15:50 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so12088199ioh.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:15:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OAH/i0C4BitMyEnhJFmKuUQtfcBAFIUqc/xTAr0Am1U=;
        b=Mu6pKs+O+60ir9M2CJwPwDPI+43ti+mc1GBTLkETTONuia8ifpamhB89JyQphVIzdm
         SU9FDFRhrOgx7+6tqvxJX9IKzTpxbWsJTu3y1sW6v6Rnu0plBPgSi8olt8f76owGSy82
         WFLWJ2ZNeeHmojhObmsBAPg1TWpd22BrahxwPXgyuSBIGzb7Ii83sPaWWlOdpqaMt7+X
         5Jbg4MhUdGIo5gxHdYIXsrHiMJzyfb03LDGa3m/YUKNsfGllliFrzPWPHlrorohWJlDr
         rqA1sRQ8VrwK74UoKSUfhnk6FZXz7vl3sUMjlyUKJcagpqdBEnxE/CccnIuC0NXyUEtx
         4gYQ==
X-Gm-Message-State: APjAAAVZF/76liaP9+ZbG5P9oyhDbsE7uiN+fKNfwUHMxW53N0O2yJ9f
	bbhO2tPFq0KNuLJTIp3fQC+SSfSn3ab2fG1MB9kjVyvoPsn5RyX2Lc9VKwRBk05bbnasW+9/xPB
	qgI2BezAclWrknjM1Ptc3y1aRcg1FvuP8NX89NCnUt66ebMhVvsXvR31k8wtbJ1LITQ==
X-Received: by 2002:a5d:8252:: with SMTP id n18mr890600ioo.230.1560777350521;
        Mon, 17 Jun 2019 06:15:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt8VTRqYk4jFb127CE/rOjDDlFazPsuN/o2Ae3la3EafTyEucY09YMnUIGZrF7DRaABDG+
X-Received: by 2002:a5d:8252:: with SMTP id n18mr890490ioo.230.1560777349297;
        Mon, 17 Jun 2019 06:15:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560777349; cv=none;
        d=google.com; s=arc-20160816;
        b=tw04SyunIemEFw+CIlI2aonr7QNU7Ym6vywAXf5DV++jpkzMi4sEiQ9hxqQTXCmgyF
         SzwQqqpnT63DY6u+ZdEPRHJ3TLV4p6sx81wzoIwGCLzuXIpYxQncDd1nj9Oxa3RAmg/t
         VPNLEi9w6ZUECsgw5j44nzHZEbpUm2o1xu5uW5M2EB/0UvB/xVilKaWSzQgGk4iR7DGP
         PnNILb3zvZu3GpwCRGWIPDS3SBp9yxqVoJgiTycEVEYqCXEAr0HfKZ8PLC/GT9BtfIXW
         s7t+zLVu2JU+9CR66yR1jmPr6rcBy1m+ue1ltGap8ojSojMUZlJCGr2ugNsyvekNjw34
         2lEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=OAH/i0C4BitMyEnhJFmKuUQtfcBAFIUqc/xTAr0Am1U=;
        b=kOJFfKkRCC29jpZZ/JELi2sqVKdWPAuUhgz4deq7tBUSl8txjoEkEJuZpPx0fcAZns
         B+rlGP6VxIEHW7yct5ApwOMIhtDHn7zpmZ50JHYYJ7WbIemWkKlMWJMwV0nyX397AU+U
         mMTZ6KTU1IZozMe65B3pux9F5jcHFpgKONgzI6Xgl/K1hsU0bgAmEuxpKYB43zPyKUsd
         CZZGgRsmXvm1WwC53fBez3DHxk/dWxXGtjUrl6zBHcNrV0WT63/zTSXdrR48MMZoaqg0
         R2himNyVt5bssXQVCrL7g0vydCfbvC949KCM4yw8XIplMDOOfIxj0JlLNVQG2b2CPI0p
         IWNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mev.co.uk header.s=20190130-41we5z8j header.b=Nl+Gx2+K;
       spf=pass (google.com: domain of abbotti@mev.co.uk designates 108.166.43.116 as permitted sender) smtp.mailfrom=abbotti@mev.co.uk
Received: from smtp116.ord1c.emailsrvr.com (smtp116.ord1c.emailsrvr.com. [108.166.43.116])
        by mx.google.com with ESMTPS id q84si17293879jaq.79.2019.06.17.06.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 06:15:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of abbotti@mev.co.uk designates 108.166.43.116 as permitted sender) client-ip=108.166.43.116;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mev.co.uk header.s=20190130-41we5z8j header.b=Nl+Gx2+K;
       spf=pass (google.com: domain of abbotti@mev.co.uk designates 108.166.43.116 as permitted sender) smtp.mailfrom=abbotti@mev.co.uk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mev.co.uk;
	s=20190130-41we5z8j; t=1560777347;
	bh=ZvJvYkjr7iE1RIXRXDlijzKzJL0BitvNBM9T5FqQAmw=;
	h=Subject:To:From:Date:From;
	b=Nl+Gx2+KTHlZUrgrlD4OPdHaDIh8UJfTuRA5MZVnySfiilIiWgnddpiJk4/aln5DA
	 OAo8bcON3aHKJNRIUHN2qprmbAq2BRvH2IUzshdVkvRvYeZuB2iOeftPYIjVWn6ziI
	 KuJnFj51kem220yEC5D7kahxijPjmtFu66j0THaY=
X-Auth-ID: abbotti@mev.co.uk
Received: by smtp7.relay.ord1c.emailsrvr.com (Authenticated sender: abbotti-AT-mev.co.uk) with ESMTPSA id D9002A01B2;
	Mon, 17 Jun 2019 09:15:44 -0400 (EDT)
X-Sender-Id: abbotti@mev.co.uk
Received: from [10.0.0.62] (remote.quintadena.com [81.133.34.160])
	(using TLSv1.2 with cipher AES128-SHA)
	by 0.0.0.0:465 (trex/5.7.12);
	Mon, 17 Jun 2019 09:15:47 -0400
Subject: Re: [PATCH 12/16] staging/comedi: mark as broken
To: Christoph Hellwig <hch@lst.de>, Greg KH <gregkh@linuxfoundation.org>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
 David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
 Jani Nikula <jani.nikula@linux.intel.com>,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>,
 H Hartley Sweeten <hsweeten@visionengravers.com>,
 devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 Intel Linux Wireless <linuxwifi@intel.com>, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
 iommu@lists.linux-foundation.org,
 "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
 linux-media@vger.kernel.org
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-13-hch@lst.de> <20190614140239.GA7234@kroah.com>
 <20190614144857.GA9088@lst.de> <20190614153032.GD18049@kroah.com>
 <20190614153428.GA10008@lst.de>
From: Ian Abbott <abbotti@mev.co.uk>
Organization: MEV Ltd.
Message-ID: <60c6af3d-d8e4-5745-8d2b-9791a2f4ff56@mev.co.uk>
Date: Mon, 17 Jun 2019 14:15:43 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614153428.GA10008@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/06/2019 16:34, Christoph Hellwig wrote:
> On Fri, Jun 14, 2019 at 05:30:32PM +0200, Greg KH wrote:
>> On Fri, Jun 14, 2019 at 04:48:57PM +0200, Christoph Hellwig wrote:
>>> On Fri, Jun 14, 2019 at 04:02:39PM +0200, Greg KH wrote:
>>>> Perhaps a hint as to how we can fix this up?  This is the first time
>>>> I've heard of the comedi code not handling dma properly.
>>>
>>> It can be fixed by:
>>>
>>>   a) never calling virt_to_page (or vmalloc_to_page for that matter)
>>>      on dma allocation
>>>   b) never remapping dma allocation with conflicting cache modes
>>>      (no remapping should be doable after a) anyway).
>>
>> Ok, fair enough, have any pointers of drivers/core code that does this
>> correctly?  I can put it on my todo list, but might take a week or so...
> 
> Just about everyone else.  They just need to remove the vmap and
> either do one large allocation, or live with the fact that they need
> helpers to access multiple array elements instead of one net vmap,
> which most of the users already seem to do anyway, with just a few
> using the vmap (which might explain why we didn't see blowups yet).

Avoiding the vmap in comedi should be do-able as it already has other 
means to get at the buffer pages.

When comedi makes the buffer from DMA coherent memory, it currently 
allocates it as a series of page-sized chunks.  That cannot be mmap'ed 
in one go with dma_mmap_coherent(), so I see the following solutions.

1. Change the buffer allocation to allocate a single chunk of DMA 
coherent memory and use dma_mmap_coherent() to mmap it.

2. Call dma_mmap_coherent() in a loop, adjusting vma->vm_start and 
vma->vm_end for each iteration (vma->vm_pgoff will be 0), and restoring 
the vma->vm_start and vma->vm_end at the end.

I'm not sure if 2 is a legal option.

-- 
-=( Ian Abbott <abbotti@mev.co.uk> || Web: www.mev.co.uk )=-
-=( MEV Ltd. is a company registered in England & Wales. )=-
-=( Registered number: 02862268.  Registered address:    )=-
-=( 15 West Park Road, Bramhall, STOCKPORT, SK7 3JZ, UK. )=-

