Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BA4BC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:18:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA8232075C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 19:18:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA8232075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6823F6B0005; Tue, 19 Mar 2019 15:18:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 632806B0006; Tue, 19 Mar 2019 15:18:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5483B6B0007; Tue, 19 Mar 2019 15:18:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14EDE6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 15:18:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z98so19276ede.3
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:18:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+lzckP/t2I9DmCg94EHqwkdHkrxT5wKfF532B2rO6FA=;
        b=GgwAuL1W626j7YeZEI3OenuY0C+tod8S1XMNwoEuwnryu9adaW9z2bOMta3snetrIi
         yCejwXmXW/sBNnF3Rf8wsCZCdcI73R88bpDjOt47xRaqk/HF85wC0uHsTEbnjzkbAnZs
         RZTr3Cq6fdMXiZyZZnIjVop2mcYtCac8fLSkopJLAjSI/5tHZCXLlOBnTOnMEQJsOGLK
         epR4/wXTZaRoFf+CUp0o6U245bTHdxtqLmDnOUtbtpQkY/5dsKinXFmfzDSkWsH9IerG
         5MTbi8eQfApRH8a2hxredvO2lOcTQkNV9dXOCN3hYammzJZyDDd4ibY3yO8Vu72us4U8
         YSoQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVLy85uGABSx1xIfc/G/7rJ6h5ivPM+2n7UdkPH0qX9uu3ChOeI
	54h93lH3Op96ZLXDytgD0Ho5VbmiTs9MA3MGZfvqrtEEweZa83TaHISw5LdhTn1PLy1vG/Q4mum
	rCzojfghLpxvPuete0BN/17f5F3rRmoouiQYLzXwp3fvULBG1yzE48Nce+nEfiKs=
X-Received: by 2002:a50:ac44:: with SMTP id w4mr3217150edc.241.1553023098535;
        Tue, 19 Mar 2019 12:18:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMDpbw08OF9r6MrakLn+wo2tP4ilz8M6PRxPiebFIWAYC7+QXHz9VE3wm1aHehEJ+76p5i
X-Received: by 2002:a50:ac44:: with SMTP id w4mr3217120edc.241.1553023097701;
        Tue, 19 Mar 2019 12:18:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553023097; cv=none;
        d=google.com; s=arc-20160816;
        b=T7VLEh6gfSued/xM5Uvwl6dN9pYEhvdJ/Ew8fWf6oPStoCboqjdu/eZo2ttQMv0Njm
         OAq0ZK0zUHEB1rI8odAFVUpaq9E8uv9e6G8ZnyT/izVlxyN02ZF8Y2+/oRLqHEqgjV0N
         AjPaP4pnI95Uywozxot43XmXUhBcqDdN5FMR75Em56JyO8kn5lBm3FmGyIuLGwKwXUxi
         h0RWXOLmWdOYRbY8+q0ccfcRqgS2v86zNPE/tdkHdcYIw8wKjhEITrNv9DrZH6Hq0MGM
         5z/5G4Xg41hXvonREARgFBvsp81i+0OoL3Yhd2xuo0ERMdS6tj5QE8K7gojYoHOLGM/s
         CEng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+lzckP/t2I9DmCg94EHqwkdHkrxT5wKfF532B2rO6FA=;
        b=DY3yWUUoSfYiJgeRjt1GKGuEf1/pOJ8HmXa9YHtYeyIh58LZxM5opLHhwHtqbwDuy7
         0IPoUWoAVlpVVyqN5O2uPqAyTsgMBU/WGX1vkBsQpMWAByXyQGy9nTo4QpkrNSm2FDf8
         mMUl4W736nyrkDyBeYJFGPRSJfCMjWDoy8+hNChDtUD/A5hRLrj4pTV8ZCcq5wWfWVC4
         4+WGw+1fmCe5WhK/gn44EZIPpw/AtMM8uRacJ8AcU76NBU77riYqI7mafl/Y2n2C7oW+
         9RhF5L0yGufWfWtcqsSmTjxIpmnHOXThnMkh3uaTLfdmQYngZORdC0UlSO3MXi5eFra+
         WZ7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si2555731edd.201.2019.03.19.12.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 12:18:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4892AE31;
	Tue, 19 Mar 2019 19:18:16 +0000 (UTC)
Date: Tue, 19 Mar 2019 20:18:14 +0100
From: Michal Hocko <mhocko@kernel.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, yong.wu@mediatek.com,
	yingjoe.chen@mediatek.com, yehs1@lenovo.com, willy@infradead.org,
	will.deacon@arm.com, vbabka@suse.cz, tfiga@google.com,
	stable@vger.kernel.org, rppt@linux.vnet.ibm.com,
	robin.murphy@arm.com, rientjes@google.com, penberg@kernel.org,
	mgorman@techsingularity.net, matthias.bgg@gmail.com,
	joro@8bytes.org, iamjoonsoo.kim@lge.com, hsinyi@chromium.org,
	hch@infradead.org, cl@linux.com, Alexander.Levin@microsoft.com,
	drinkcat@chromium.org, linux-mm@kvack.org
Subject: Re: + mm-add-sys-kernel-slab-cache-cache_dma32.patch added to -mm
 tree
Message-ID: <20190319191721.GC30433@dhcp22.suse.cz>
References: <20190319183751.rWqkf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319183751.rWqkf%akpm@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 19-03-19 11:37:51, Andrew Morton wrote:
> From: Nicolas Boichat <drinkcat@chromium.org>
> Subject: mm: add /sys/kernel/slab/cache/cache_dma32
> 
> A previous patch in this series adds support for SLAB_CACHE_DMA32 kmem
> caches.  This adds the corresponding /sys/kernel/slab/cache/cache_dma32
> entries, and fixes slabinfo tool.

I believe I have asked and didn't get a satisfactory answer before IIRC. Who
is going to consume this information?
-- 
Michal Hocko
SUSE Labs

