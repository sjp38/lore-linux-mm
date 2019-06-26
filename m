Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 650E9C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A904208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A904208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A0038E0003; Wed, 26 Jun 2019 01:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92A168E0002; Wed, 26 Jun 2019 01:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CA698E0003; Wed, 26 Jun 2019 01:45:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA1F8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:45:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so1469124edr.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:45:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aydUDGa5+QAYmpZPtYMkWwUUvB1zVRCSCYE+QEV0K9Y=;
        b=Mys35rRSfWJird2rfW/kkbeM5Dw+/Xw8pl7U2qQRCtiaJpixYiOHkLdZYDZCGb5KRC
         FRMDOsdP9w9X8Klmh7+9W2lxAZU8N0YyUIrPBSBhd4z1BBkXk8Jx1KnsuXMy4iL8vCUE
         2vx37tumvsY92HTttZ/yX46r3injav4t1kDjQC5ynLI2VUBGAlPSrj5INTx/Ka95xdny
         2Z/K4F13okrAjUFu6relmQ3tCzhMwB+ddQypG96VLmG9f8lQS/BhzWfgIAD281WM7aHK
         zkUxL7Mdt1s3wxrdD5p0zylFvIyAsUXUOUTX2xsBz9rUz1b+xDliVsO9d5KqoAsXnzWh
         vBIw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWbvbMEKbaTNRC7R/9iVBF8fv+jrOcrnaor0JDjhjeFbnsrJLCC
	2cZ3aWI97+whwFOS++gkAM9OYl7fu2LPII4GG1e90SCAdXYAS0uIQGLgt/FUG+f6KVrBaMQkoYs
	OQEVTKm1fHu3RBe8iZboYm4fuKPZYOvj+JDIPAK82MiNTR/XWJHGbwdNoRYLuWvc=
X-Received: by 2002:a50:cc47:: with SMTP id n7mr2967142edi.58.1561527957754;
        Tue, 25 Jun 2019 22:45:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBK03tEezwcipN5qIo6mQlPcDxT1d1UeH4zXsUfyc4dOW5rdC6Cy/WAzrD64/SQQ6qFFsJ
X-Received: by 2002:a50:cc47:: with SMTP id n7mr2967081edi.58.1561527956764;
        Tue, 25 Jun 2019 22:45:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561527956; cv=none;
        d=google.com; s=arc-20160816;
        b=gGDBDN/K9EY5bPi9bESJNh7g55KmuEd48FrGmLw4iPNoBUp2mcEKhTs+/+cxBqL4iB
         z/i2c4pHdt6IMXxllDYlMX6kDLD5ENSU/+W623ogcfs0iUI/V9ZRCmHo5MC4VT81qQZb
         7GAIG8oyHmpKxHzW9dfIcGYnlN2ZrTSbSsvKCdOcbeZxDVzu4lWCgjtkvz320SCQrbaZ
         2ncFRSOzjTwFIxtrK8A5QdmXoD2qPrqEtZZ0OdMwOvfDRH501vyITw/X/T6yw2ds7qm5
         iNGgkrI2Ij6YrJsSNUnahH/JGwNGeQVN9pn8xPPqMbt6BQASu8FWdkem96VxgNzu4DIJ
         Ss7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aydUDGa5+QAYmpZPtYMkWwUUvB1zVRCSCYE+QEV0K9Y=;
        b=QODqH1/dbi9vQOgkPopvhj8Z9FgTbofvz/gKJpW9DOhleKht46JaX/vkoR0eiPnJOM
         kN45K8dOxLm1VenYI89XU/I17BI6ueGfh+S0ThuJNZjwGSJM+2bu3Pt3G1JbocRtHDr9
         /hxHbTrxudjl6RgjJM4faqsBOoGlutgT9QArrYtlXucYvu2IF8wWxR5x7yiEXgiZxlD4
         Z37nkVUZtLJHnp07bCF/xKFDYkn5oQhsw6fJAc49mSMS7+GzvFG3u2xeoC8zmTpaGQaL
         0l3aLVo8KqN1j2u5kxwCY3KzUvLQ9j03HSC1zIeWdcmxTQBd224XR4I6IjP5hezHR2XS
         wz2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b3si1937967ejv.334.2019.06.25.22.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 22:45:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A851EAF25;
	Wed, 26 Jun 2019 05:45:55 +0000 (UTC)
Date: Wed, 26 Jun 2019 07:45:54 +0200
From: Michal Hocko <mhocko@kernel.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Ira Weiny <ira.weiny@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190626054554.GA17798@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de>
 <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
 <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
 <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
 <20190619192719.GO9374@mellanox.com>
 <29f43c79-b454-0477-a799-7850e6571bd3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29f43c79-b454-0477-a799-7850e6571bd3@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 25-06-19 20:15:28, John Hubbard wrote:
> On 6/19/19 12:27 PM, Jason Gunthorpe wrote:
> > On Thu, Jun 13, 2019 at 06:23:04PM -0700, John Hubbard wrote:
> >> On 6/13/19 5:43 PM, Ira Weiny wrote:
> >>> On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
> >>>> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
> >>>>>
> >> ...
> >>> So I think it is ok.  Frankly I was wondering if we should remove the public
> >>> type altogether but conceptually it seems ok.  But I don't see any users of it
> >>> so...  should we get rid of it in the code rather than turning the config off?
> >>>
> >>> Ira
> >>
> >> That seems reasonable. I recall that the hope was for those IBM Power 9
> >> systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
> >> memory, and so the memory really is visible to the CPU. And the IBM team
> >> was thinking of taking advantage of it. But I haven't seen anything on
> >> that front for a while.
> > 
> > Does anyone know who those people are and can we encourage them to
> > send some patches? :)
> > 
> 
> I asked about this, and it seems that the idea was: DEVICE_PUBLIC was there
> in order to provide an alternative way to do things (such as migrate memory
> to and from a device), in case the combination of existing and near-future
> NUMA APIs was insufficient. This probably came as a follow-up to the early
> 2017-ish conversations about NUMA, in which the linux-mm recommendation was
> "try using HMM mechanisms, and if those are inadequate, then maybe we can
> look at enhancing NUMA so that it has better handling of advanced (GPU-like)
> devices".

Yes that was the original idea. It sounds so much better to use a common
framework rather than awkward special cased cpuless NUMA nodes with
a weird semantic. User of the neither of the two has shown up so I guess
that the envisioned HW just didn't materialized. Or has there been a
completely different approach chosen?

> In the end, however, _PUBLIC was never used, nor does anyone in the local
> (NVIDIA + IBM) kernel vicinity seem to have plans to use it.  So it really
> does seem safe to remove, although of course it's good to start with 
> BROKEN and see if anyone pops up and complains.

Well, I do not really see much of a difference. Preserving an unused
code which doesn't have any user in sight just adds a maintenance burden
whether the code depends on BROKEN or not. We can always revert patches
which remove the code once a real user shows up.
-- 
Michal Hocko
SUSE Labs

