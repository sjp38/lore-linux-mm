Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7925C06513
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 11:09:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A166D2189E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 11:09:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A166D2189E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39E3E6B0006; Thu,  4 Jul 2019 07:09:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3288B8E0003; Thu,  4 Jul 2019 07:09:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 216758E0001; Thu,  4 Jul 2019 07:09:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6CCE6B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 07:09:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so3600323edd.22
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 04:09:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=M/22PoqfVFOfHuHgoZSm1ND+5XjV4UZvWCMNb+oeUSk=;
        b=Par6n/jTe1BkdEKmG5VcpwQRENEtNDEdFXO5qNrJ7yo0uSojaHGH21nTH3g0sPFapj
         StMU2KsrbtDdiEGjbgRs6R48tZXbwU8VmODSClsdx7w51F9ObH6itENGpGfV3mcE4LJ9
         /9qpEnIqkhVPfi0tdza7/LucGtaQRX9S/bSRc0HmzoJesizb5FABLoNXDssoqHCv24Hh
         ZxC2aJX+Arz6RFYF1Skqs0UQYrzI8wp/S0iXDVi0j2q6b1GULJ9buXz9eHnlLVXi721H
         zj+5bLDik5duqgHOLouq2AJsjfx2VLmUXr4HOCK+wR9QLcrxbOLFypd6TlHCc5gWEkZ5
         rTLg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXokKWyvWgRK6YJJuNd0wzGdzgBh6yEYO8MpBIZe1h0wuxFtgLD
	yMhyUtaM7tmhdE/vFGAFwHhISwYaOwjrJEaJHC73U58gn9eesru51QH6wKNa8ohK6w6egTP4we6
	TOyKJi8Ta06zHat0CjAmsnJB9NW5i5B9mqb34oDJG7QTMlngYkqHAOx6ihI0NqD0=
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr47516594edh.189.1562238545292;
        Thu, 04 Jul 2019 04:09:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOMS3kQMm6Ia3ySp0fy6+rrAXplITnB6VCsCrEftDNI+ZD8dCcxOj3lSsVwFSVLsD7H+HC
X-Received: by 2002:a50:c8c3:: with SMTP id k3mr47516521edh.189.1562238544537;
        Thu, 04 Jul 2019 04:09:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562238544; cv=none;
        d=google.com; s=arc-20160816;
        b=XoodS3UPZLYknf/Y9Iqw0gZg3r439XFKRuk8G1/MzKXkVgHimm3Z+k5X6mW6Edvkv/
         imSldtd3/noPwmUnba2InDS0w5EP3SdTsMALnnYl8Vqx3qplLd/UyYTQThrFngPYDn02
         mmwV91EtTdIJfqpDxXWHaDBAvB8k8K3PH9GA+AWvLtDLBMZd5IZ4bpd0yJx9k0TB6npp
         GpePYBqQVKcq4q3RAaL/JzOQcagGYcq1l9EzCR2o8KVN1+1ZtJvfeW5FcLDtxevSloej
         DifYyUObVUbBQm00IRN0T0bJcgE4aYxXM9q6fvAm41iPKeiE1IMfFTM8wTTpl032+EYj
         5reQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=M/22PoqfVFOfHuHgoZSm1ND+5XjV4UZvWCMNb+oeUSk=;
        b=kesHI+2RSiXgjFcppWmDCKtKL1OSaX3s7HQQqIh6+/EToaHhkhYxujwrrV+xd5J2QO
         12nHh7Q4pevEnf2wKiF66IoScI3dhu6fDONebHec+xou08cYECuFXBYakORDi1NgMN50
         yaGixB8y+z78JcPKzIOXZDGOEiPOBz6qzEkW4OZI0+KfMP03ZFUBRzB0xVcxnn6zMIRG
         Gf1MPq5kvV3N5mL1REsNln+1KQRVXnuw0iURSX7o9CstujZoBTbFpmMo1zVHQqXj10gN
         kL1NCpwQEhaZGpmJPeFSE5nyvB9FDyTN34lCmbytP9dedv1b4RAaE6FTaAQU1aG5Gx6E
         0brg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k19si3520758ejk.233.2019.07.04.04.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 04:09:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1B698AEAF;
	Thu,  4 Jul 2019 11:09:04 +0000 (UTC)
Date: Thu, 4 Jul 2019 13:09:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190704110903.GE5620@dhcp22.suse.cz>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
 <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
 <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
 <20190701085920.GB2812@suse.de>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <20190703094325.GB2737@techsingularity.net>
 <571d5557-2153-59ea-334b-8636cc1a49c9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <571d5557-2153-59ea-334b-8636cc1a49c9@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-07-19 16:54:35, Mike Kravetz wrote:
> On 7/3/19 2:43 AM, Mel Gorman wrote:
> > Indeed. I'm getting knocked offline shortly so I didn't give this the
> > time it deserves but it appears that part of this problem is
> > hugetlb-specific when one node is full and can enter into this continual
> > loop due to __GFP_RETRY_MAYFAIL requiring both nr_reclaimed and
> > nr_scanned to be zero.
> 
> Yes, I am not aware of any other large order allocations consistently made
> with __GFP_RETRY_MAYFAIL.  But, I did not look too closely.  Michal believes
> that hugetlb pages allocations should use __GFP_RETRY_MAYFAIL.

Yes. The argument is that this is controlable by an admin and failures
should be prevented as much as possible. I didn't get to understand
should_continue_reclaim part of the problem but I have a strong feeling
that __GFP_RETRY_MAYFAIL handling at that layer is not correct. What
happens if it is simply removed and we rely only on the retry mechanism
from the page allocator instead? Does the success rate is reduced
considerably?
-- 
Michal Hocko
SUSE Labs

