Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9831C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:41:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D284218AF
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:41:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="N2Tbyi0N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D284218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F01C18E0004; Wed,  6 Feb 2019 18:41:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE968E0002; Wed,  6 Feb 2019 18:41:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4FC28E0004; Wed,  6 Feb 2019 18:41:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8268E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:41:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id o23so6092684pll.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:41:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wtlvdaQ2RfnmKMMXLaG2vLlY5kmAjKB9ewwZ6+Q/zrE=;
        b=itsgvAScSmX9jAMaSLbahvovK9ihsghdbicz6V0c2piEgRPyV5wrkfIb1pM1Y6s89O
         N8wHmcOv5U11a2mgv8ieNx6xD3enOWyAJmyVbpgJqVu/PQSwDz3YY+M3HNsvHyPPptlZ
         g437OjkcbdQNrGt+Sr+oyT6T8dd0DlWw+9UPhP7ufkCxbc8++K9qt6qLwZ9OhAelOnmH
         vVupgTtP7CcMMQ1G4dPQbaGPUgRCRsVm6jM3JGgkCxSGKHOt7CwVrzJ5tIQ/zWDarbRK
         CjzvQN11N2GxlTFPfx+v7D39Yc5KvNhVj0rDnoCwn/T/oxZJhVkwrIMH5Ve81IyR9XP4
         kETw==
X-Gm-Message-State: AHQUAuYRs6Etq7SmVBFoKVj1/FFpDVfpWTefK2GoXwCOBhvPavHbTYIE
	EOifsz+krFonE5z9/YDwSNBWPrD1BJFUsnx3Z395gGB/Whz7kiNCUxqbfG6d3FjgY8eghmeAAke
	KADKnpJVFR05tzqPrryFfo4dtsmAjCCry38ehWJljZJM+W92CTcF7Y4I4BCnmAMWlEZGK4Quu6K
	pKHOpjzXk6rNFeMv+BOyI1kSnR0OTfpMbXbRpCULqW7OvtU68/Euk70qrOEwDqmnRbQfWgOEddJ
	6NkKlxSQITexK8Idf7+jaORxDMx96shtVhbK8eZIkzgioneVeezYv7N3CbXAlraCHNQ05xpnS98
	CHkBiI0hZER8kHqgTIQqGXPAle4vCo9KE4cCP2oMAmjZqDjzaRR8bzHMEc5qjwrZb1CeVn+AaAd
	8
X-Received: by 2002:a62:8893:: with SMTP id l141mr13031845pfd.1.1549496495141;
        Wed, 06 Feb 2019 15:41:35 -0800 (PST)
X-Received: by 2002:a62:8893:: with SMTP id l141mr13031812pfd.1.1549496494414;
        Wed, 06 Feb 2019 15:41:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549496494; cv=none;
        d=google.com; s=arc-20160816;
        b=eoIcZsEG7JbvD988xYZJFYthwy56wGBWNhnwuc+rShQZWsv8jPqdXWaHRv49HGUt+/
         un+Dogc8uQ1MAfhpJ4Y69nig/8j/YSfDM0lpFN3YUZtInVsSpfJfbyy/zvKoISPCzQnr
         JLhw+aMLjfCXxyn9MjWAzYjQcBejOrw2vkEqursURUbt+ka1EluCXfJxa2RaAQgZmNm1
         5z+hnYgMjD+s2pL0ypgtM4XyPCJBHaly0kxFnSrod2+xVWngl4+5Q1/L2jd+S5CAjDIF
         qvjRc5dpb0OstyYRAfx4YMvk4Mp6TuXpOs8sisjokBxHWOw/Y26KTkNRG0hb22R+Hwx4
         xIJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wtlvdaQ2RfnmKMMXLaG2vLlY5kmAjKB9ewwZ6+Q/zrE=;
        b=lk0ieUC3B3Zjs2jLf/vDNzpmsiEtxFJLqlWS6LQJQeACiav1EeHLOKUaGJzEGzmwmd
         eDqKwEbIuPudOL6uoyhHn9gDJ+CWVu+3kcjVelVc+4Kb1kNYvh7HW4m+qQMlpsQA1G8M
         beUUjBU5abps+ZJDEXFOV0IidGBJ0IIjoOzt6T9jH9hZMJkATnDmG8SfFP/vnXEzHuFg
         xyQ6ZhPqhj4dxMwWJQ4LISUVSmtGqQAjSNZyDsX9W9xfiQzYbak8P0bMsHD8BL0DIcpO
         dr5MHNvNmbnqVsuahqLalag4NEyDvAkWrrTrTxfSIR+k6tYCbdNIRWc17RvUh8MqAu9H
         hAjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N2Tbyi0N;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n87sor12118871pfh.64.2019.02.06.15.41.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 15:41:34 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N2Tbyi0N;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wtlvdaQ2RfnmKMMXLaG2vLlY5kmAjKB9ewwZ6+Q/zrE=;
        b=N2Tbyi0NYtdj8kT2fMOgphDLJEkRu8Ve7ZbN85OU/bQbcY2ohxaRJxVu7xpTbHlXaz
         r6FrDdc/NGokzSrOKPsEKte53jDC2z3GLhsH5X9tBP4JVBYg1jZ6Dgr8uP28kwHMgXNw
         3I7uhRUVtBRYFLBAyOx+9VlYyWwzL18DlMjooUqe82Wc6lsJIDWYXqqY1twhdcd/jpR0
         s+Ieocxx4JcXuueUFPNDNBXSo/9RN+165tVmt+tNrC37G8fgRpEXqB9X/w9ZGkgBpFMC
         1S1KAtTAWGotwZ3Tw8vdQorheqAg3TpQm22oB6kKfD1QPYDsaDOO2aMfn+BYMgjnYfSj
         qrXA==
X-Google-Smtp-Source: AHgI3IZOZlROKcj7vcS2xqLMIe3x5syV5VU7DSATGgwTxc0rzKS1U6azoHkiMfw1/uA8lDCseSvfzA==
X-Received: by 2002:a62:1d4c:: with SMTP id d73mr13262967pfd.90.1549496493841;
        Wed, 06 Feb 2019 15:41:33 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id u186sm10338671pfu.51.2019.02.06.15.41.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Feb 2019 15:41:33 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grWou-0004D9-Hy; Wed, 06 Feb 2019 16:41:32 -0700
Date: Wed, 6 Feb 2019 16:41:32 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Doug Ledford <dledford@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206234132.GB15234@ziepe.ca>
References: <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org>
 <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
 <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca>
 <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com>
 <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com>
 <20190206232130.GK12227@ziepe.ca>
 <CAPcyv4g2r=L3jfSDoRPt4VG7D_2CxCgv3s+JLu4FQRUSRWg+4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g2r=L3jfSDoRPt4VG7D_2CxCgv3s+JLu4FQRUSRWg+4Q@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:30:27PM -0800, Dan Williams wrote:
> On Wed, Feb 6, 2019 at 3:21 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Wed, Feb 06, 2019 at 02:44:45PM -0800, Dan Williams wrote:
> >
> > > > Do they need to stick with xfs?
> > >
> > > Can you clarify the motivation for that question? This problem exists
> > > for any filesystem that implements an mmap that where the physical
> > > page backing the mapping is identical to the physical storage location
> > > for the file data.
> >
> > .. and needs to dynamicaly change that mapping. Which is not really
> > something inherent to the general idea of a filesystem. A file system
> > that had *strictly static* block assignments would work fine.
> >
> > Not all filesystem even implement hole punch.
> >
> > Not all filesystem implement reflink.
> >
> > ftruncate doesn't *have* to instantly return the free blocks to
> > allocation pool.
> >
> > ie this is not a DAX & RDMA issue but a XFS & RDMA issue.
> >
> > Replacing XFS is probably not be reasonable, but I wonder if a XFS--
> > operating mode could exist that had enough features removed to be
> > safe?
> 
> You're describing the current situation, i.e. Linux already implements
> this, it's called Device-DAX and some users of RDMA find it
> insufficient. The choices are to continue to tell them "no", or say
> "yes, but you need to submit to lease coordination".

Device-DAX is not what I'm imagining when I say XFS--.

I mean more like XFS with all features that require rellocation of
blocks disabled.

Forbidding hold punch, reflink, cow, etc, doesn't devolve back to
device-dax.

Jason

