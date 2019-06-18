Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D798C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:13:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3A482070B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 13:13:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="IpiFSBFY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3A482070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71DFE6B0005; Tue, 18 Jun 2019 09:13:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CF2A8E0002; Tue, 18 Jun 2019 09:13:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 547D68E0001; Tue, 18 Jun 2019 09:13:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE916B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:13:27 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t196so12235855qke.0
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 06:13:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xfhednnMko0J/Gc2EkI7pHwdsX7U0u0gJ5ATooY4GNw=;
        b=Jcpa0kuoCD8FlJTIKMrXGkAeE6T+zpq6KN2etPnjK7Ik4BC3+LU0Myd+FDAxD0aQwl
         NDce5OxqDHDvlZ65PYploc1KIxM2lrRRH/fMBkMP6fbCMoxksUO+L8MFkypTvU5o8IcG
         2En1BcGOHYfmDCSF3m/coAiIRp/5sVRsfhzLs4Qdt7p2yNB+aCk7P0A0xaAhtBzhJmrB
         WCNjwwL2iDZ3L4s+n27+9MXHNGEKTcwL/6rjhnb6q1xu896l8NM90aEKQ1iGfeGEsTeu
         GENMJ1ddLyyyMJyfPYAll+iB1TGMZUerPcEKc5vzdfJu3NT4Ww+uTywwCVDgoFAYWd6S
         in0Q==
X-Gm-Message-State: APjAAAVZWA7aJh1vGANdVBSUueSaoEyawyBMbx+yRmL6w9UtGsYELJCP
	EBiGwSfxO6spZTMjV+Pdj2sSEzEmfmmzr0nfp8sBNq8ZGROAsqr5HCtJEc+JkkMouIqrlREdRFI
	lW/2mg591yTL/6vBJSZeq8R1dcS0kUnkoSZwoiHBv3vgI0W0Mpp4Uv9UiW5EZMbRz6g==
X-Received: by 2002:a0c:ae50:: with SMTP id z16mr26339754qvc.60.1560863606916;
        Tue, 18 Jun 2019 06:13:26 -0700 (PDT)
X-Received: by 2002:a0c:ae50:: with SMTP id z16mr26339663qvc.60.1560863606043;
        Tue, 18 Jun 2019 06:13:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560863606; cv=none;
        d=google.com; s=arc-20160816;
        b=haKOLTO/7vqSM2cVcXB02CIEEVdEpzD4/NqzNE2ZD1hToYbKPCFIzbs/9yCS6/XtSn
         gERp5ecXubmxMstw33zZMNA91nlfSHozA9TqnhsG1D+OjYIh+pHJlW/D7Czql4zuQ6aB
         LXAHUHi3uH93jmnhawXBwzw4i9H2BAeywWD+MsrccTi2KnfPz1NvJ6k+H7RN94qgCDq1
         Cxtk9iu3kJ3wGixvMbMXVCx92WtdQWNh/GoYKzFqJW6r4dmd8TubBL3McDKkGL0Dq8H7
         BMimMgJ+zEsdQEIgkKS1ypOtyJdrRDod9dAVuR79LmRPh+GXu1BNCAcSfhyw9V25ZggM
         HmhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xfhednnMko0J/Gc2EkI7pHwdsX7U0u0gJ5ATooY4GNw=;
        b=OH7FsnNOFCYtBo5D0rJr0RZl0LWbANOyFDJqMh23ooehWC0rBXlcoL8RmHgkdw1SeF
         Eh9mD3LlwX/ORdpSgxivlJNU+yGX2oGZjoCImgKnuvHKbzDv1Ike96JCH67OuVBrGjow
         cJFOYtDiFjYr6IceFXMZoTUqvYP2CC7IlLY7g7pllkXymRX45RS625bBx553EYdo+m1c
         1k2GFYAf2UtJlHI7QV3csRxXubPsKlgTd96pYSUCB/3c2xSgakLMo8+3fBR2cXqZ4BDo
         H++6j2+Y0hn97wBDLwkhfEqjk5dbXN6MEu9mwTZJFNltLmpjY+tXAR7cDAuDxTob7k9E
         6oHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=IpiFSBFY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor12111971qvf.10.2019.06.18.06.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 06:13:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=IpiFSBFY;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xfhednnMko0J/Gc2EkI7pHwdsX7U0u0gJ5ATooY4GNw=;
        b=IpiFSBFYBoTwYfqvmxe8FloHMIqrMYqzAICMX/Tb1PQC8juV4R8QgNi8F2dTL850tB
         tOwbQTRNRQoTa3xOCOwC0OMtxDoNRGuOeI46BFC3kNaAvJiY4P/iyf7RzcsFxc8G45SH
         49zuAflb0zkgaDa+XIi2Wbzs2rUuPcOYneeddw2YI9zDMI26K+cYLBKrGFj8ybuggLo0
         cQrcA8DdzOTHcCXD3549+9H4FoxLRnXA5ooKkdIrNAGnGy1kdMiPech7iq2XGAhKkjdI
         ubP4uCFkrQKLP+0w6s5evp9n0tqrCRE+4lbHqXQX1c3CzOmVczeuL07tv7hCBLVhCB3b
         0WjA==
X-Google-Smtp-Source: APXvYqyc4kGixlViSKnI/I5Z67eQQFGhrtX0nDRpvMdx2bumrawkhX26fgDCqWaQXW/nU4uS4gAM1Q==
X-Received: by 2002:a0c:b095:: with SMTP id o21mr27915778qvc.73.1560863605800;
        Tue, 18 Jun 2019 06:13:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f26sm11997359qtf.44.2019.06.18.06.13.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 06:13:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdDvQ-0002cw-RL; Tue, 18 Jun 2019 10:13:24 -0300
Date: Tue, 18 Jun 2019 10:13:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 08/12] mm/hmm: Remove racy protection against
 double-unregistration
Message-ID: <20190618131324.GF6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-9-jgg@ziepe.ca>
 <20190615141612.GH17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141612.GH17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:16:12AM -0700, Christoph Hellwig wrote:
> On Thu, Jun 13, 2019 at 09:44:46PM -0300, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> > 
> > No other register/unregister kernel API attempts to provide this kind of
> > protection as it is inherently racy, so just drop it.
> > 
> > Callers should provide their own protection, it appears nouveau already
> > does, but just in case drop a debugging POISON.
> 
> I don't even think we even need to bother with the POISON, normal list
> debugging will already catch a double unregistration anyway.

mirror->hmm isn't a list so list debugging won't help.

My concern when I wrote this was that one of the in flight patches I
can't see might be depending on this double-unregister-is-safe
behavior, so I wanted them to crash reliably.

It is a really overly conservative thing to do..

Thanks,
Jason

