Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5682EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:12:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25994205F4
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25994205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB21D6B0003; Fri,  2 Aug 2019 05:12:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A63696B0005; Fri,  2 Aug 2019 05:12:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 951906B0006; Fri,  2 Aug 2019 05:12:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 477ED6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:12:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so46554658edx.12
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xDMaIKJ3eqki9Hr/c8pax1SD09nlwwoubgEtYUZaCik=;
        b=TbqL9PMswrpNqYwgAMlunmtwTdAbfZWaksz58qbH+arasnJnVA3tYNmkTnCi0xy5DQ
         byrY2Fd7w6NPvMnDNw/01nLcghxVZUg8brp96rjbm6ey7HrDzrb3LhQvVDjld9PrqhzM
         JVCRelr425X5pht0B21OXPoOuNd4eeBEsiVZ69O8I7iffPFZw4p0XP7CL72y/PVrcGVB
         yiROx2FGEmZxBpikpCcBkKY4lorXTLeMkdzOeQL0HcWRf7/nscDZnTh+toY4UlR0Z4sd
         Rj5/7nxIBJJdkThRH1rdJMdAibIF+JkZsbS2nl38ZgJ1zXPI99Q71CdQsYYdYE1Gpxjj
         1NMA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUoZdF4rgIJnX+KXZXuwIqlfBLXwPPHR5nBI2tAbYfknC18f1IP
	TYuZaydM2o0uT2PKreDrAXW6v9El3W71wobV62dWV4nLPsMpCFrekF8v+Y96N1PNfSgZZ5XiU76
	u2RWg2Yk4mfmSbOUTWRcJ0xbOsNuXDZLcczaLpHZvjpYNvku/4E07yqcNz2ni09w=
X-Received: by 2002:a17:906:718:: with SMTP id y24mr104191518ejb.71.1564737168856;
        Fri, 02 Aug 2019 02:12:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKvhdP9uXY6Xipbjlq2Ta5H4NCiCiBjKU4O8mk9gPZXEIcMCdKk3yv3XEvU4KtZrBuPtQ8
X-Received: by 2002:a17:906:718:: with SMTP id y24mr104191472ejb.71.1564737168170;
        Fri, 02 Aug 2019 02:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564737168; cv=none;
        d=google.com; s=arc-20160816;
        b=1KAmfgeZ9mVoQQuxUNCuwJva7xkDVNXJV0kxOVYwBspaxDX3y8uOzlDNrpdpCnXdjN
         dG5DaUqXLmJAGa2l9wYnkzT97JUDpmn9nD7MwcGRqwiscYVEfMfKgySC4lTHmOsh11tU
         1DZOw75Py9ONQ1EImfs+Svvcj0GAVof6E9b34ffyEQPheraemjLF8IPctsA3RXTQiiwO
         6E64M30RZqQYGG5pFdx1HmNN8e+oFyC/eIoNP1NTbFElqNOwt4ASe3phqPxTMB9G8+4j
         hfYSgsbwELp4QZLI4pD3cNRNFs0bRGfXLZewic5Kzpo8lKQuI+Df/XbuvKVypmlbMuWT
         NfeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xDMaIKJ3eqki9Hr/c8pax1SD09nlwwoubgEtYUZaCik=;
        b=ySz0eVLQSQNPcBTk/JucVxI7TJEAQiipap0REui/oi/FX0CLWnsO0xDBO6GVvUl25X
         mxybnb+8HVbOo6FYJyUNmXq773bcGAHjyYdMQLU++URtSsCzL3ojxLFnpLrGeRkjJt2J
         lI6fLTnWBX12xZarDS/WR6AgpyEhZXechXFNv/IZtdBNmZgjLoj+cnwCX8pw3VEruMuI
         Efua5Ml9nCLhnuWSF4wU8zpWgKooQzKsvcPXmMa0oZHR7FosgrxeQ6ocF6y6hK7SqKtx
         zAlJZKZwBsTsOTYRYe+E47Pc4NbCHC2xrOpgvR0vhXZMuLguUPEKQKvlQ2jEZYkW8pLE
         aREA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si23793131ede.381.2019.08.02.02.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 02:12:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4990DAFE2;
	Fri,  2 Aug 2019 09:12:47 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:12:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190802091244.GD6461@dhcp22.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
[...]
> 2) Convert all of the call sites for get_user_pages*(), to
> invoke put_user_page*(), instead of put_page(). This involves dozens of
> call sites, and will take some time.

How do we make sure this is the case and it will remain the case in the
future? There must be some automagic to enforce/check that. It is simply
not manageable to do it every now and then because then 3) will simply
be never safe.

Have you considered coccinele or some other scripted way to do the
transition? I have no idea how to deal with future changes that would
break the balance though.
-- 
Michal Hocko
SUSE Labs

