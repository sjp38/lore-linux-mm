Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C19C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DE4820838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:40:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DE4820838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34AE38E0005; Thu,  1 Aug 2019 03:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FA178E0001; Thu,  1 Aug 2019 03:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C3B78E0005; Thu,  1 Aug 2019 03:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C516F8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:40:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so44129801edd.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:40:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/jGc3/JCEsP768NrzTx/5aigSMBX+P0d6dquZnS8Vlc=;
        b=LSdtOoafQyfLjEVx2nXfDwyQWKGu9nmiMuw62vgYX78MQDEjBMNjUm+1PyymXmf6mb
         dBXv9JT2aaOiulN5GGXzM7saBiWJzQjEsNlqVmm0PJZ1QqTnWMeuq8I3yqn0CSzP5cqN
         D16z9UgQiDZKDyHKCRSWyktZs3kObg3LQ87Q4/WQt6B4tv6QoeGQr9qmgeS8PLEL6ZW0
         Zv39w/49lOYO/yON+/HE8wFA+bkZnZKYxA+mQse0T6IyZGGYX+9hQ3/urIdtFDX97PjU
         0sfo5z+eG3St0VRYxOcC2w4Wlb8atq7R3a+pg5MwYhPXgEW1iyLTwKdth6ZPkPcLOLLW
         NyAw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWsnHiQpcZGO18lvJiLVkfwx8TYuogVvYddmtYSWWuGGz8gahk0
	zWLzCtnlguXy9sSWnooRrSSuSwY1fyeG5z1DjHFQHfxWe3ybRm4zenTg02hVP5wJzjOqsVF5DuA
	I4tXjLG7Lif1X0hVWipLR+grVjOON6d+XD49rknH7UmY3TpgOqA/U+WxMV0uhGJA=
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr98507992ejd.300.1564645210390;
        Thu, 01 Aug 2019 00:40:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3DIB6R+xDiz+Y5URLTS7hlK7S98viU1IElSFj8+RR9IWDCAKBc8I8+wK6GLsZ5/ZN/ht1
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr98507946ejd.300.1564645209750;
        Thu, 01 Aug 2019 00:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564645209; cv=none;
        d=google.com; s=arc-20160816;
        b=pxJM6SiPoFv64IEPXtEPMndzjTt4D9qeE/3g3W0WgCqo0gYUdBSun/bn3fDNUIn/W6
         pD65qnLSxKGvCNXl5sRfEauk2JQ9oDbglU19JPcwsOnicjpbdbYN0agBaVNltjusMHes
         lLRKfsy19HIZhZGAFSopI9SxD+R2nu7Wbcgu9yI68JN5fyBMW6brxNyT+RjLIFN+U9t4
         GY5sv4UMk46hEhtQzo4Y0/sDwl3nBzaq4182l6x3IRqasR4TtURWDdFffMc/VfXSFV7b
         UfrfLJnI0DhKeWfzWrQbHewk4/+YcyVRp8RUpNVGLjBZm55f/pDNyQl33T3tiapysFXm
         vUaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/jGc3/JCEsP768NrzTx/5aigSMBX+P0d6dquZnS8Vlc=;
        b=V94AG6Y52KxPfaz58kbJr27sN3g+D6JJcxB5S+pHEOmDlVSFh68RJ7hyyTuiYIDBEn
         9PirPlzYHumQIOT0cJ8cBWfcoUoZ7QanxlsmXAZ6p2xJSxTG3bPD5e8c43G/THK4Rwx0
         wiElMjclRvC3sbkRicgmanZWcZ6T0N6DG+e6vC88hEDC/ivm0c6cBDpf8icSoS3S2fM9
         8Gu1hDvauOYdn0w/C18C1akRrFej5Nz8pgl/G6Salj/64gyweAsrKyqU6BAocNq0ta38
         1lnf/wmv98skluri1sX3INMh8Kh4Ax6X8vysxeSZGySGcrgqXHIDl1s+Pxc+bwgybEJB
         R6fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w21si22920106eda.367.2019.08.01.00.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:40:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 55B34B11C;
	Thu,  1 Aug 2019 07:40:09 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:39:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Rashmica Gupta <rashmica.g@gmail.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801073957.GH11627@dhcp22.suse.cz>
References: <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
 <20190731120859.GJ9330@dhcp22.suse.cz>
 <4ddee0dd719abd50350f997b8089fa26f6004c0c.camel@gmail.com>
 <20190801071709.GE11627@dhcp22.suse.cz>
 <9bcbd574-7e23-5cfe-f633-646a085f935a@redhat.com>
 <20190801072430.GF11627@dhcp22.suse.cz>
 <e654aa97-6ab1-4069-60e6-fc099539729e@redhat.com>
 <5e6137c9-5269-5756-beaa-d116652be8b9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5e6137c9-5269-5756-beaa-d116652be8b9@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 09:31:09, David Hildenbrand wrote:
> On 01.08.19 09:26, David Hildenbrand wrote:
[...]
> > I am not sure about the implications of having
> > pfn_valid()/pfn_present()/pfn_online() return true but accessing it
> > results in crashes. (suspend, kdump, whatever other technology touches
> > online memory)
> 
> (oneidea: we could of course go ahead and mark the pages PG_offline
> before unmapping the pfn range to work around these issues)

PG_reserved and an elevated reference count should be enough to drive
any pfn walker out. Pfn walkers shouldn't touch any page unless they
know and recognize their type.
-- 
Michal Hocko
SUSE Labs

