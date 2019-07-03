Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8E6DC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:03:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DDEF218B8
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:03:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DDEF218B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16A648E0011; Wed,  3 Jul 2019 14:03:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B878E0001; Wed,  3 Jul 2019 14:03:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25088E0011; Wed,  3 Jul 2019 14:03:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA1D98E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:03:10 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id p13so1381738wru.17
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:03:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kbDbjpmZDx+LsliwwVOTQM5tCHh1s2S059sHbR02UOk=;
        b=CNyHj3OlXGjNrBuqM5WkxEmV1fWsSC3eHbySRpT1V1aKz1WtV287n72g2+nzAMmgFi
         RxWQ3/SlCAwztH0YZW6XN6STsoRnRiwKnsCI0M2yPFV5cfU2xuNlKFlAVSDz66EmyZLa
         jyW99qXcGbel0bWlBPa/Yuaq1Do8iAo/h68EfuVODk3IxXKd85ZgQ8H013ytG0mn/c1G
         jB7xuN/U7l9nqzgUdDOWuoqh9qwiI9TbpsYSOp+C4NBJOct13ihRK/XCReX6N8XcPTCn
         ani2lDNY3dgMOH55enacowtA9xGy+Q+nyo1jgZxsH8DK3L87bgUPum+1Rs2g52oVVRYa
         BGew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV+eeniuW3+ZK0vLsogpnZNNAlHwyLTfYOG41imI9llyvjs/zFM
	bjHdza96H3cUgptLJYfBmPznB9iX9iM/tXruzAf61whtXxpdkqEGXJpveSWTt6udjBEVEEZJQsX
	gPyq6dMHuVXqKsP7+w2bgt1XGVPx9cDZqDLjGMQZ4AIUcy87XWaMq6fx7imvS8uPfgg==
X-Received: by 2002:a1c:6c14:: with SMTP id h20mr9438088wmc.168.1562176990305;
        Wed, 03 Jul 2019 11:03:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1ElsdSAEJQBTUu4zN/dS0EzaVCIoibC7F05Wd98YvoStuMM1cv5BXq0ROGvrynNtagKmZ
X-Received: by 2002:a1c:6c14:: with SMTP id h20mr9438059wmc.168.1562176989595;
        Wed, 03 Jul 2019 11:03:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562176989; cv=none;
        d=google.com; s=arc-20160816;
        b=sHIPH8l65KfdiehYgGzS25rvP6MyCipKO/Cb6kSP/jMHkYwflPwmYOLY1NKMqHaTx4
         5QxEfawMT5rOMcoUfAhSTKzWLgBgOXP9CpSztrstAicKZPn1flon0oFMJDNulvwlKwI/
         0iQeZH+pyqVewZCRbdjyeJK6ddXeHZDNvpuQ+tcE/CWpI9WpzBXobOgO1K8uFzAeGt0D
         2WEbDy8lJfMLcvCPizDCvZTzdQv+E51r5ie0ToEZK7Bmcdy4BZeoKbvA2s8ubnCRSW8T
         nJFRfwj5p4vrb1OGzR/yQQyR0TZDJf4ark49zV11o5KQRiwpuWy2Fz3EfeTPq3FeHVDA
         3Itw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kbDbjpmZDx+LsliwwVOTQM5tCHh1s2S059sHbR02UOk=;
        b=K3iI6AAuXa9Oq26xFv18ls5+k8PMLqwU0FMxX22Q8PVFAN7fePOaq5HJLrQL+hmpel
         i+IMiNuRQZd7laGDMMI+rMBeVrpewjOx8H8aJFAvoaO20Z7pan4VyhKllfshAf+PnLdE
         dOQDNMGE12kxNcmjl2XJ70isx/QIKwwG78iYTxApiOfd2vIZRFC33xDWs9j1UDQkLz/W
         NrDew/+nxpEFqO+PClaw1ez8z2/mwMoRdZnI6bBlTAQpIRJ0WJtGCEuP+7qZZa+vF6ge
         +65qkfG34goCd0NyK002wH69yh1NthVfsOVYh5RJw9f78w3GKQwRw/FeVOmh4O7oqLRn
         UgBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f7si4198271wme.1.2019.07.03.11.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 11:03:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 5C41168B05; Wed,  3 Jul 2019 20:03:08 +0200 (CEST)
Date: Wed, 3 Jul 2019 20:03:08 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 22/22] mm: remove the legacy hmm_pfn_* APIs
Message-ID: <20190703180308.GA13656@lst.de>
References: <20190701062020.19239-1-hch@lst.de> <20190701062020.19239-23-hch@lst.de> <20190703180125.GA18673@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703180125.GA18673@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 03:01:25PM -0300, Jason Gunthorpe wrote:
> Christoph, I guess you didn't mean to send this branch to the mailing
> list?
> 
> In any event some of these, like this one, look obvious and I could
> still grab a few for hmm.git.
> 
> Let me know what you'd like please
> 
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Thanks.  I was going to send this series out as soon as you had
applied the previous one.  Now that it leaked I'm happy to collect
reviews.  But while I've got your attention:  the rdma.git hmm
branch is still at the -rc7 merge and doen't have my series, is that
intentional?

