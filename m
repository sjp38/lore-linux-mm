Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5959CC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 304672084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 19:17:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 304672084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AAED6B0005; Thu, 20 Jun 2019 15:17:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95C388E0002; Thu, 20 Jun 2019 15:17:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8231C8E0001; Thu, 20 Jun 2019 15:17:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 041626B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 15:17:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so5569100edr.7
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:17:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kcuZzDkyR0cG9A0A5wthFG7BtlA+fRo5OzImTqrKEjI=;
        b=pVQVANZgwHsNSovM2aKpVVXbS1THJvrF+g6PYC2j6AfZCpbycAzG9O86c7VUILp7g6
         Ip5BOmnLqkiiWwbrI9217KX8WC8gTuOiqCealvl9Bbzi8LM1J4krP+tJGpDDOqfqVBLK
         JkCG4sl0FZ4EdAhfJ/aQCeUtRs7HWj4BMQQ6lxqBFKq1zrpoJI73DJ7k9ZTqdFNbznpx
         rW5HWPoT3w4AGgQUSFvrSt4olGHRYAnEtiHYO+VRfnxVjYTFZB+WsVLQ5LZhEzAScmce
         GBWeJ6M462gZ9uRUOR/Rd2hGNtRxNbRUNORNK2kmL9x3PJVdaHB1yJJI+u38PrEspaSr
         hKXA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVTeUoxwJMRsqRSRs7e+PjZBzpwp37VnPEeoo//KG6UBFZBDdg3
	5CkvFsQtLZZNWgPWTe2IK8UgYc381SpXbIgR4pXNQ/uCGxT56wMJJXnER36wMNnlG8xgupZd0pn
	3GWr3RyRhfNbzUFTWpBhECbSNzCdn1amIdG738gZOZSUBpjR3nYUHMgexL8Hyx9Q=
X-Received: by 2002:a50:8d84:: with SMTP id r4mr17967641edh.48.1561058257595;
        Thu, 20 Jun 2019 12:17:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm1zPpKLUa3sYiqiOO/jh7DkMKVP7lLBdTwpW9XIc2XgqbSYjUscav022/zqQfCVQmQMtL
X-Received: by 2002:a50:8d84:: with SMTP id r4mr17967571edh.48.1561058256871;
        Thu, 20 Jun 2019 12:17:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561058256; cv=none;
        d=google.com; s=arc-20160816;
        b=QRaCF3c6ZwOfsiqEeO56b2GD25J9KlMHaeESTc0yO7LTQnc0pU8ZpKeIo2E40ZgYZA
         etR8Z68NTIHELviOBJ49lu1h0x0Quf8tmCxwl3XAztKht8PBcQ/o4oUOKAhwEfjkKu7U
         LJFsSJeAxEk/AtDpFeYOAUbLFzCouRsajNTR85Ly6y7Tha+B6xkLfGhsC2W7kiMcKoOp
         O3bbvtfJPTZfaExGapwDzSw48SMojigAZf85Rmc+TO21fcFrOW/TWeudmsBKtEey2SHy
         U0aiNHrH96gCD2sJUqhYRx014jI1DTuUTK/D6/FiIGY7gIkJ+s6XAFRIrNHBPcFY8GyS
         1Hkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kcuZzDkyR0cG9A0A5wthFG7BtlA+fRo5OzImTqrKEjI=;
        b=hI4BZlio/Ny5N9Kwpt19jX2ba0fF1w147iWyUq0d0ZI25LIWkiEH/aGc3tAL95uSCz
         ZUot3JCdr16HC1YHOFpBlHAYPfnKX/comqCk5C5Hz3ThpLqnUhGX0b/poqgf6aOOK5t9
         JfO4oZLkkl6RUSuF18I4Y7NJX4ZMbHA5r8wI58Ae+E9e8y8Fca0VH2AzxRNz7XZb+Kkd
         wH6dqVNEnZrmE6JRGjuMBXYvW0k8XUEaBD0Pc5uKDMcM7gyWBHqBzyYOrKoBlMuhaSIz
         wZy4MqeHqjXjCCCi8dUwkI8orDCBPCtR6O8a94ZUjkd/rO+vxxb9v25g4HTOGBIkILJ4
         mJAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si359266ejp.292.2019.06.20.12.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 12:17:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D58A5AB92;
	Thu, 20 Jun 2019 19:17:35 +0000 (UTC)
Date: Thu, 20 Jun 2019 21:17:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
Message-ID: <20190620191733.GH12083@dhcp22.suse.cz>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-6-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613094326.24093-6-hch@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 11:43:08, Christoph Hellwig wrote:
> noveau is currently using this through an odd hmm wrapper, and I plan
> to switch it to the real thing later in this series.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/mempolicy.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01600d80ae01..f9023b5fba37 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2098,6 +2098,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  out:
>  	return page;
>  }
> +EXPORT_SYMBOL_GPL(alloc_pages_vma);

All allocator exported symbols are EXPORT_SYMBOL, what is a reason to
have this one special?

-- 
Michal Hocko
SUSE Labs

