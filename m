Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B66A3C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:16:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80EF12075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:16:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80EF12075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 132496B0007; Thu, 28 Mar 2019 10:16:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E3AF6B0008; Thu, 28 Mar 2019 10:16:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3B7C6B000A; Thu, 28 Mar 2019 10:16:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A42196B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:16:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l19so8126988edr.12
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:16:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J6su+7OZRspWq5ZW6m3WzaGA6eTHr7d/mGGgYkz6DLg=;
        b=O8E1AMg8FNx0rLSeRfBSkWtdg/oHd0erZRSS4zQ9MsKECYjSsrfBZ4ygxtL4NMs96A
         Ph44mCAMJZQf1I/luYbhBxz2PQLDzeIhnjlw6sB4v/2XPUBP3T+iJAWi7ZJWZxAfVn8F
         rHD2lB3ozToAV0YqwACIDlEbpRj8JRbI7ZU932WCd87JNmhW6YQ0kxNk0MS6ADdbrcXd
         +9n+UznXjfFh65LXkV2xyXahv13mz+OG6/5aSRi4SxUg2JFzA+5OoZNRQwtsH5CMqBOs
         mUMnJpqyTXto5s4C+FdUFva1YbmXU1RNUudl7Dw/FSQfFjbjDthVNb8eNTNegWvxqqrt
         au6g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWiYeoY27hQkvbFauZWMowHKCM1OBQlKVt/alY/g+sKHpdHYIF7
	jvfZk6wmigJxsDjLz8kOT4GRFEM33fzgRJXiZWq7PO9Nl/oLmuZRqzbkzt4XpVZhMmOpVuU1afc
	eD75lrgajIATJy7wMnvUQTGEUXHIFOqR1/J3mCiWCaabrDvRbHXrZL6QNw81tO/E=
X-Received: by 2002:a50:95fa:: with SMTP id x55mr26664120eda.49.1553782594159;
        Thu, 28 Mar 2019 07:16:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSNKvnonTIS6W/Ccu4/Abp0ItkUzs96eLZIn3tQCPlDW9IQBmhAiaBfI1PSc0NxoW+UTSp
X-Received: by 2002:a50:95fa:: with SMTP id x55mr26664069eda.49.1553782593328;
        Thu, 28 Mar 2019 07:16:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553782593; cv=none;
        d=google.com; s=arc-20160816;
        b=a3LOzjJNtAApHyfmmt6Ejt0KLZr8SeikrneiywSfbNSbBkmZeIrcwiPHfWSKBXiFE4
         o7SLSGOgxAZymO8xaJyimyZ2hrgm8i12unC3hZLHfRZSz6zN4fwwKygtLwWdFQWYMUVj
         5zHZUPhBqEEvdLoLMK7pkiOUMUtQ8XXT5Np9kUq3gkLAO5WkgtD2wpiTMLvdbNAQdnuF
         H3EdTi1kONCe+TtNAtNzqksPaHaK0ZsHtTamDyCN/j+ZuM7A7UeC6za84Q1mcgatTEQi
         Imz6plOCyAbfOvNBb/lS9sFkWNpiCB0UevFX7lU8v7WoRzV8P1+zD10Gjw9PY1h2Fjk2
         qvZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J6su+7OZRspWq5ZW6m3WzaGA6eTHr7d/mGGgYkz6DLg=;
        b=npoP3RXmbD4SwYFmezfUvwVDbRsXJV6C3Snq1+eS7Zah7AsFjRgp9n1Wn6b+KIjX/a
         HRUFwZnloBdMiYHC0xM5qKMillOuLwHkZ5cog2tkGTfmA2wTVKMvDCku9lABBlXu2S4M
         SN5xDsEDbBCVKRi2AMvJ0h1diZwbqgXhPI6J2ITK7tK1o7VR1TXOCGhMeMmfC2Z/U3m+
         r6qUnWpVDsj4r/nQesjgRm4+sWsm8c8Rtf63+YZRJYb9MeCnL6X5gd/zoOauv/pPDocd
         weZGYhGxqiwjS5w6skxsGaLLj/4wiFu1TUdovUGgL1DxGcMq/NZTjk26DSFS8Jo5ca/+
         EPxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si2977425eje.165.2019.03.28.07.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 07:16:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C140EB780;
	Thu, 28 Mar 2019 14:16:32 +0000 (UTC)
Date: Thu, 28 Mar 2019 15:16:31 +0100
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
Message-ID: <20190328141631.GB7155@dhcp22.suse.cz>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
 <20190326080408.GC28406@dhcp22.suse.cz>
 <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
 <20190327161306.GM11927@dhcp22.suse.cz>
 <9e769f3d-00f2-a8bb-2d8d-097735cb2a6d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e769f3d-00f2-a8bb-2d8d-097735cb2a6d@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 28-03-19 14:38:15, David Hildenbrand wrote:
> On 27.03.19 17:13, Michal Hocko wrote:
[...]
> > People are asking for a smaller memory hotplug granularity for other
> > usecases (e.g. memory ballooning into VMs) which are quite dubious to
> > be honest and not really worth all the code rework. If we are talking
> > about something that can be worked around elsewhere then it is preferred
> > because the code base is not in an excellent shape and putting more on
> > top is just going to cause more headaches.
> 
> At least for virtio-mem, it will be handled similar to xen-balloon and
> hyper-v balloon, where whole actions are added and some parts are kept
> "soft-offline". But there, one device "owns" the complete section, it
> does not overlap with other devices. One section only has one owner.

This is exactly what I meant by handing at a higher level.

-- 
Michal Hocko
SUSE Labs

