Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72809C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:22:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2793A20652
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:22:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HoOGFZ6I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2793A20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C08D78E0004; Mon, 17 Jun 2019 04:22:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB9D78E0001; Mon, 17 Jun 2019 04:22:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A81978E0004; Mon, 17 Jun 2019 04:22:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89A128E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:22:35 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y13so11342648iol.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:22:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FGXkU7eOmJXcfpTdOS3rFhVnp4//dWioBuU5JvbAozk=;
        b=IJRLMA7PAdmZYMC80n/TAqbG0mDTQUNoUm3xbJNcO1f7StdA5tjyXhKk518Laxet6f
         sEm1FoP7JZoelfE5SY7RfecHMI4E10RVKRoPYmq8Zkawn6PI3l3efjcjRgaOtvfuTWd9
         Nbk+AAi+7QYLNHupygdMfWRqH99385miicxiAUUzD2rfEOJrF7TgHjRu6fdt0JQ0V435
         A8csrJNDIF5PkqzuTm5H6jxOfJhwOq2+avzPCC686rhfYsGoQCxyUzfI/UjyKqu31STS
         bWQAsz0dTEZJmKZ6Vw8MirC5tLsNzv7dmRwt5j2Ipi/o1ewHg2/XTbf8fFI5jDOwadvs
         eUGw==
X-Gm-Message-State: APjAAAXYMmgSMSPG3tT769Fqiz7QdM7ROYmyJQCbroplMthaj56oSIGg
	6bT2Bvuhvq7iraQic4njsB+DQkIuSGP18deDOO7P/r3yDA2K4kJVz86rn91OVDxuFgjZqPaqJJH
	0NUeRiFCZ4zIfZNA3Tf+kjnEtbvYaPzZ9x2lSdltMpuiOdiPnf5A+FHUwGLFvvMs/wQ==
X-Received: by 2002:a6b:e615:: with SMTP id g21mr16054869ioh.178.1560759755177;
        Mon, 17 Jun 2019 01:22:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjS3Z7IxUCAIXzkAc06BjH4N6VMYcPrNXq81OBUFhNszrz4V1Aa64x0/rtnKAf8rPXgz0P
X-Received: by 2002:a6b:e615:: with SMTP id g21mr16054808ioh.178.1560759753888;
        Mon, 17 Jun 2019 01:22:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560759753; cv=none;
        d=google.com; s=arc-20160816;
        b=CENNruZ7vgrMHwuDc6OYhY/3oggA876PXSGKAbAqPSaHdBFX34CzqXdpAOvK0jKa9K
         4yAqhnXDzMsO9qwUS8LCWc18JU8my2d8FnPtZHz1YVw+Ohek0/Gh+Ch81cVaCW8FWCBw
         /h7JoMmGkpi0t+P3FtIDPILFRhsx26R82ah85F7LKGgxgsjA/18Zij2Ih4BPDMNIAYlL
         Q5qQmvlTceHw12wA6GXfPZ7FOz4PYjSZZRHO6XUlAl9rNhopznBV+yX2F6xXJ9446N1l
         Qc4VDH3FfD/9k9xBU4HuUiMsQeriWYBqe/eMiF2vp+W2t3Xz8P33ViwZLDEjfmWE42lN
         NhBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FGXkU7eOmJXcfpTdOS3rFhVnp4//dWioBuU5JvbAozk=;
        b=1GUQ14OnlxgrcDuflW1VKqNSQLbz0IEaZ4qPWjzTv2j9VZSc0xFfM8BcqQe2Xp7QGn
         hJYy+Ptqfa/placx/W3kWWFDY+4xZspN1WJn2op4H7kXA5IpcY33bn64/95RKVc8i70Y
         5se2sMyilif/rMfFwwy+/ge4xdgjDKQJcdNlZrizzvo4oHSKiiSUJGCbX0XygDRM1LJ4
         4fuuPtPyx0pIIdeiPnda4nOoY7g3je97m2+yj2QnkS7Mm7UeAM2PejHX33cm3cQ41q50
         lNP7+FjSQhQMAHibBE0PjjMtA5HMcZ0vPLBhtsJ7V3Uvo0bCSGmcMJBnYQsusw+9yn14
         MtKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HoOGFZ6I;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id y5si15265156iof.64.2019.06.17.01.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:22:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HoOGFZ6I;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5H8EDPq036975;
	Mon, 17 Jun 2019 08:22:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=FGXkU7eOmJXcfpTdOS3rFhVnp4//dWioBuU5JvbAozk=;
 b=HoOGFZ6IDRsf/WaCfXo2ZTPgY5pwDJWXjo1xX+qTvLOMlZocWpKu1Sf00Bmkx3VFzyma
 10WCt0cIJkIFz7mHW+wD9GUOEQ0ivHG8jDJ0t4TRvpEWC+TsmSyquhiRY045QRVvKMqd
 BIDabSi8xq4vX0L9MhRibAwTnUvf3DfPIk//8VY7MahBLoeLEZ2KraHUQ39ijiOHMNDT
 8ndBBvPX7iRqpB2l3z33gYX+RiPyyzfIf8yD1/MNNifpDFIZvAldxXl3FHTYVYXdGTMe
 /6jx2aoi8UlUxIMQRg+jUh/JipGQ+5QpEWrsTOM8x9vyDm7cYa5WG5PQ0L40CVIPJPpn iA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2t4r3td2pj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 08:22:24 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5H8LV8W126648;
	Mon, 17 Jun 2019 08:22:24 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2t59gd3q66-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 08:22:24 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5H8M5I4026605;
	Mon, 17 Jun 2019 08:22:05 GMT
Received: from kadam (/41.57.98.10)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 17 Jun 2019 01:22:05 -0700
Date: Mon, 17 Jun 2019 11:21:48 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
        Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
        David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
        Jani Nikula <jani.nikula@linux.intel.com>,
        Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
        Rodrigo Vivi <rodrigo.vivi@intel.com>, Ian Abbott <abbotti@mev.co.uk>,
        H Hartley Sweeten <hsweeten@visionengravers.com>,
        devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
        Intel Linux Wireless <linuxwifi@intel.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, intel-gfx@lists.freedesktop.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        dri-devel@lists.freedesktop.org, linux-mm@kvack.org,
        iommu@lists.linux-foundation.org,
        "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
        linux-media@vger.kernel.org
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190617082148.GF28859@kadam>
References: <20190614134726.3827-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614134726.3827-1-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9290 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=782
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906170078
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9290 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=820 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906170078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I once wrote a Smatch check based on a commit message that said we can't
pass dma_alloc_coherent() pointers to virt_to_phys().  But then I never
felt like I understood the rules enough to actually report the warnings
as bugs.

drivers/platform/x86/dcdbas.c:108 smi_data_buf_realloc() error: 'buf' came from dma_alloc_coherent() so we can't do virt_to_phys()
drivers/net/caif/caif_virtio.c:414 cfv_create_genpool() error: 'cfv->alloc_addr' came from dma_alloc_coherent() so we can't do virt_to_phys()
drivers/infiniband/hw/cxgb4/qp.c:135 alloc_host_sq() error: 'sq->queue' came from dma_alloc_coherent() so we can't do virt_to_phys()
drivers/infiniband/hw/cxgb4/qp.c:272 create_qp() error: 'wq->rq.queue' came from dma_alloc_coherent() so we can't do virt_to_phys()
drivers/infiniband/hw/cxgb4/qp.c:2628 alloc_srq_queue() error: 'wq->queue' came from dma_alloc_coherent() so we can't do virt_to_phys()
drivers/infiniband/hw/ocrdma/ocrdma_verbs.c:494 ocrdma_alloc_ucontext() error: 'ctx->ah_tbl.va' came from dma_alloc_coherent() so we can't do virt_to_phys()

drivers/infiniband/hw/cxgb4/qp.c
   129  static int alloc_host_sq(struct c4iw_rdev *rdev, struct t4_sq *sq)
   130  {
   131          sq->queue = dma_alloc_coherent(&(rdev->lldi.pdev->dev), sq->memsize,
   132                                         &(sq->dma_addr), GFP_KERNEL);
   133          if (!sq->queue)
   134                  return -ENOMEM;
   135          sq->phys_addr = virt_to_phys(sq->queue);
   136          dma_unmap_addr_set(sq, mapping, sq->dma_addr);
   137          return 0;
   138  }

Is this a bug?

regards,
dan carpenter

