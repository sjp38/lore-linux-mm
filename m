Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8160BC46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:14:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5244320851
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:14:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5244320851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA2348E0002; Fri, 14 Jun 2019 02:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4F616B000E; Fri, 14 Jun 2019 02:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C17B98E0002; Fri, 14 Jun 2019 02:14:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EC616B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:14:01 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e6so617058wrv.20
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:14:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ca7S5+bqvqsXVuDmZ9i+7g54tc8OLQbZzbWnZ+MlEfI=;
        b=MuTHUqESuzDYjYdkfwfDwyYFmx++24P5LyHDYQ/+pkHSI9HaF0r//S3jTU5K61SWoz
         U37SinYlSiPVZ4I1xm0nLd/G471251zCH02LEp2kA5IY9l91iY6yg4iz8SX9nSIPRdVP
         OYgklQFm1QvKgBdiR1xPGAy/wSr/LUfCbIYInTEVhDcUhUjGNXfCC1Sa6fBFeB3GMwSf
         gMm6Qedd8Gbx96W03fhV2KM6EHjrmy8HsAtMzUuRGPa86LmrBYwAY0VcN7UWMZ/gb+g/
         qgNz5q7t5EA2FE8Swhit5Ce48ZyKvtemWkzP6NlA9r/JJ1B4AkylW5XM7Kw0nsUqP6DI
         vvuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWB1wsdVasVP6OInWi84qCiwBJtXDtHDOYOWJEJuMY5tNiGxd7g
	7XOOcy8iodV4nhcvUqZoMI90fKyqcahY8GFjyIpf9dxecUbF9WzVYS/Hw4wSba834yL0eXlK/Ul
	2g5VpEJ5m6E7kr5k7PVXq2JabGlFgViV5bSpWwkbI+hZBHlpL7Kim2+TI1ZvGP2/Q8w==
X-Received: by 2002:a1c:b046:: with SMTP id z67mr6010410wme.49.1560492841187;
        Thu, 13 Jun 2019 23:14:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRO0J9wyCZ2wdwgI/V440q8Tf6WZUwKWBDHvj4GBNr3gNpiNEkUG93NcMqwfl+KqxsJ/yT
X-Received: by 2002:a1c:b046:: with SMTP id z67mr6010377wme.49.1560492840555;
        Thu, 13 Jun 2019 23:14:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560492840; cv=none;
        d=google.com; s=arc-20160816;
        b=kmVKzQuKFWHnrsBsHcb/Zc4m0XRldYit4fYun0kKkr3TYL0mbq93Uc/DqUpznM25Ah
         yRphyHAVYSgkGdlxAjhroPn/41fVmUCQI2wnSPYTt9VfS45l006F9B9EUFr+habVB3ED
         yGQsWflb6dqcxkR5UOLcimlcKrbRtybYb0lGJECKrU3XDUEnsFMM0qvJjG1ByeWHoECT
         shjRPH7zRujYF+99C7+xD8wXqzXehSg3HkZB6z/lA6QyP7O5DMaWkJw8GyYPUSFbHp3Q
         LS7EMWNc9pevgSlJJiXxw4BCDVokBP9gDvGtXDiM59Wki//2w3gsDP8ifg775W0i4gm8
         H24Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ca7S5+bqvqsXVuDmZ9i+7g54tc8OLQbZzbWnZ+MlEfI=;
        b=UGtuMJctNVpdKNQXSzbW/maCnAqRg7Y+ZF5abug3zUCej8RA4HSsmOwGxJiUd3oz1x
         vU2dgwU7ya5c4+BoIEKMMgPa8Hl4WZ6UGvhG6C7442zPHZGE5uF2dd+OeaXgq4LS1PV8
         u7d9gpz63e6ud2RMzjX8reZd3g/BNVTCKS0dTnDWeaLUHUxgP/izVS4FXlGG9YioUccZ
         twjIkt8YQTPgim7dXXoCLUtVG7tix3LmhDxn5L1DvDIQakfx/dGrjuRSTJHkNSI6PTWF
         oMXdbGXtfBKNGmIa2nsofojomnhLs+uwABeJnoVVTsBLzswMWWj+PLXdchJU2PVJUaMu
         PwRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id u8si1266846wmc.115.2019.06.13.23.14.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:14:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 6ECF668B02; Fri, 14 Jun 2019 08:13:33 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:13:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190614061333.GC7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:27:39AM -0700, Dan Williams wrote:
> It also turns out the nvdimm unit tests crash with this signature on
> that branch where base v5.2-rc3 passes:

How do you run that test?

