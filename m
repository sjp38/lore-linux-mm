Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D9DC282DC
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 23:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAA112175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 23:01:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="YKKo0pgc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAA112175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F5A86B026D; Fri,  5 Apr 2019 19:01:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3CE6B026E; Fri,  5 Apr 2019 19:01:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B9DC6B026F; Fri,  5 Apr 2019 19:01:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6B636B026D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 19:01:18 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id k3so4418019wmi.7
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 16:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=S5YPihc8ey3XnTK6jsq2AQbOX0mAfD6UZn+XISxNaVc=;
        b=YSnKd41/t+ArJAZyEq3cUBV8LfZ3bh31MTk+HkvinIk3IzZasnMkqgYXs6uaoYtrCE
         F6GvW6YK+aBgniyRpyejYjx7hz17/d32lEsrbv4POc9WF/ixwn7XOWKZzdcCyEdLtNP6
         Nv0c386EE03xwP6kzO7i6EdTfmvTyz/XxJCwCdmYObLkQWF6Ws0n4Fd916iyq2wDQ8D/
         t1ABaVqkjw0/rvSKWc8/wEaIwjw8r2Zt3ngZlpRJLCI2FDmFEhblnppED4w8tJKWCdrT
         t7efaaTjXjHpKR8OoDXEbHpfyiFZYIhW+tFbsxP2lBQhh18ASLPE2QOTbek8oIgOJLvn
         4Jbw==
X-Gm-Message-State: APjAAAXEQcGtrRYj8q16t8yYuktseKTAd+plndXJc3zO1f2+zfes5/wo
	K7Nyji/QL+KQMgwBSffa5oWS7kt8sxms1zoi8qyCAvVVqbhGkqdvIPZdPrmJrRrGlrwbByG7EDm
	ViTNEtiOu4dGu+wvLWMRhh5wctAh+0JR8oPkpma8AL8hw++lt6jqxN6il88Ft8HwzTg==
X-Received: by 2002:a05:6000:1286:: with SMTP id f6mr5220294wrx.93.1554505278080;
        Fri, 05 Apr 2019 16:01:18 -0700 (PDT)
X-Received: by 2002:a05:6000:1286:: with SMTP id f6mr5220256wrx.93.1554505277214;
        Fri, 05 Apr 2019 16:01:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554505277; cv=none;
        d=google.com; s=arc-20160816;
        b=DGOoss/lKoBBSkRTBG7UZjvo7pgQkCuiJykdQFiBQX8PsOzrqe767XMVmiOzKv6+8E
         FmDWJVD5LBX5XT2e5O2xTp931rd+c2qFuc1UrPUajMlOd/xU7DzxXrPQ5EUPiyoAq3n6
         kvP9jLmHyakJt7vmGHadUoTw44Z4sk7GPZksjFzLo+2K3CnyJVeGbqmV27EuGL85fC5r
         SfQ+Dg/0bhjC8+Z9GyESPFyZ6XcbEFAHFMfqjZJl4AY5UrBvKc+s6RkxZEsYJ5p389IT
         ao1DW/ljjw3VgegTeazUFki1yduQ6v2VRdFUfVd6kIQpKm2S6dPM0ylYZE3QfGEZGtUp
         5L+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=S5YPihc8ey3XnTK6jsq2AQbOX0mAfD6UZn+XISxNaVc=;
        b=zHMN9XaTSPxrjP1BR7wbEzNOWxXvP8A1NqdF4xoA/TBQ3W2ANxp/Bk+3q2Dy6KZTK/
         T3E5l8ohGQ0yM5lGVXUvBXPtJXx8/KYNcR8seuvv5T8+TvZaJA0eqnOLI7DZs86uwT1C
         RTMYKmEipZWoQ5dNXtHKnNQi/vf+j4YlBew1l/S0rtLK9eV2THsmR3usG9j1nvMKupqM
         68fsPxX9oq8NSVtjfkkhBqGolkeFRJwEJ4uQAxilcwLPRfSkuW+J24AST5XLleVNBp/J
         iiG2CwkZSL4+ej0SR5E/dUj/bMiabsQg8J0Nc4qmOJgm3QIUyxuHMWzPd5X08rROOfo5
         tsBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YKKo0pgc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor2265159wmb.29.2019.04.05.16.01.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 16:01:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YKKo0pgc;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=S5YPihc8ey3XnTK6jsq2AQbOX0mAfD6UZn+XISxNaVc=;
        b=YKKo0pgco/Kx9aPOEKbF+EH3xPmDvr0+YAOQh0qpAS+f2SY/oziisv2Gs2yRBksk33
         mbpLyDlVN8cvelPYumARTahsE9dfPglsUP4ZNE5perqQ2SxhntRgSNbvY0rb8qqJyZA6
         fEKiBD8uNogBFXZUgEpogoiLCEpKxj93CYh3ptSciVcGGHiH0dws+Ef4gvnqDUU3e0Z+
         P7Xh3o5RHHTlBIE6RxhzVO/Hkl0zqRrJZ1oMd3dJzARyp5Nta1dSOxZd1pGlLK2hgdFC
         NLJPzaIAqF21AlPZ7vrbXcaYHkoSbuuqOKPbZBScgbDLhboTKjVGSadfTAbgVhy/zBnq
         U8uA==
X-Google-Smtp-Source: APXvYqxCrYc9pFeXiakCF1G8nrTZNXMtwpV8VNxw85t8B13v+EJ70dhIkCS2h6lj+NAHvoI86BgUQnhG3KiGVp7hzEQ=
X-Received: by 2002:a1c:40d6:: with SMTP id n205mr8824562wma.140.1554505276628;
 Fri, 05 Apr 2019 16:01:16 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
 <20180125072351.GA11093@infradead.org> <20180125160802.GD10706@ziepe.ca>
 <20180125164750.GB31752@infradead.org> <CAPcyv4hi98RDD=F1rhumgCF+UiOisidmeAVrDePrTzF1ArXj4A@mail.gmail.com>
In-Reply-To: <CAPcyv4hi98RDD=F1rhumgCF+UiOisidmeAVrDePrTzF1ArXj4A@mail.gmail.com>
From: Jason Gunthorpe <jgg@ziepe.ca>
Date: Fri, 5 Apr 2019 20:01:05 -0300
Message-ID: <CALEgSQvkUHLeS_7nBtrqoiEJ__Du4ZwZ4fFr_TSxZy-FhBWO-w@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, lsf-pc@lists.linux-foundation.org, 
	Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-rdma <linux-rdma@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 26, 2018 at 10:50 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Thu, Jan 25, 2018 at 8:47 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > On Thu, Jan 25, 2018 at 09:08:02AM -0700, Jason Gunthorpe wrote:
> >> On Wed, Jan 24, 2018 at 11:23:51PM -0800, Christoph Hellwig wrote:
> >> > On Wed, Jan 24, 2018 at 07:56:02PM -0800, Dan Williams wrote:
> >> > > Particular people that would be useful to have in attendance are
> >> > > Michal Hocko, Christoph Hellwig, and Jason Gunthorpe (cc'd).
> >> >
> >> > I won't be able to make it - I'll have to do election work and
> >> > count the ballots for our city council and mayor election.
> >>
> >> I also have a travel conflict for that week in April and cannot make
> >> it.
> >
> > Are any of you going to be in the Bay Area in February for Usenix
> > FAST / LinuxFAST?
>
> I'll be around, but that said I still think it's worthwhile to have
> this conversation at LSF/MM. While we have a plan for filesystem-dax
> vs RDMA, there's still the open implications for the mm in other
> scenarios. I see Michal has also proposed this topic.

I also didn't make the cut for LSF/MM - is there some other conference
people will be at to discuss this intersection with RDMA, prior to
plumbers?

Jason

