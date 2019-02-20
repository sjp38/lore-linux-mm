Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AA54C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:36:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50F2320855
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:36:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50F2320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3DB38E0047; Wed, 20 Feb 2019 18:36:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DECD98E0002; Wed, 20 Feb 2019 18:36:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D037A8E0047; Wed, 20 Feb 2019 18:36:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A337A8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:36:29 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k37so24940717qtb.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:36:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=nvuYWmXHY+qufm6Ds2WTn5QQ89YBOQpWQIdVxC0OR1g=;
        b=XQPTEq6o7v9ZNZW9i4qlO1/my4tnhYLkJbl7bdviSzRTBcMBkE7jBGpSHnuTtSb71M
         hgXp0dRFnZCq8PKh+wnyXhgYUFNqFj1IQLiD7RPIKx8in0vpE9Yctt6NcZx9XphqTf9u
         wPxBKqxeMr4/wJFINnuNAXFfp3pizEzLWMoJYlJphhCDhfImKVUsKoDscRXfEfltVHcw
         orub1TG3j4u0EIOwAVd9vKkl0azDc/E9ekYS5LnFki9PwzBbTOSr6Ky1DLfN3JvXhYhO
         Df2DDPiqvNvviJHApjj0r7q38eGSy+BLaXAyol1HYRzMajR6E6Kn0k8H5CrdNTDjNTQM
         //Zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYBV0AO54QchX+MC25g1pOX+qnYqElwuo6qDNyLA112djRihLzc
	dNMvma8WECRRF0LU29CC3j9+zN3jOFrLLXAlbTrRAxStH/g3pl7Zl1e5LPJftbN31QQ2Y+AJ6Z5
	92YzGUacECfVwfj2irxj5CDHck/vaNUtzRfc3azU4jAvc2Qt1x5oeKk2IV6lqoMCOcA==
X-Received: by 2002:a0c:d687:: with SMTP id k7mr27866220qvi.46.1550705789427;
        Wed, 20 Feb 2019 15:36:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZXnZLmVq/6AzxuJwZAD4fUT5Bn4hz1/eMjbyYCEgzZ3djtPIZ58r/liPLFA/gMn4YsVs5T
X-Received: by 2002:a0c:d687:: with SMTP id k7mr27866185qvi.46.1550705788854;
        Wed, 20 Feb 2019 15:36:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550705788; cv=none;
        d=google.com; s=arc-20160816;
        b=s+MkXqgmXURTBS2hZDThGvwPC1tmfC0qwMypJo6alM2j5ztQlPMghPScyxsApTn1hs
         J2JQqCITasaORSMqU9zaPod3PQx6lYfEiTjet2LP9XoG4aamb6UYi+W/2zVULLoCCYlL
         kzetpK6ovYasVe4Ncrx4hbmBYHKfO1qXywBnTaGoJrhvrIWYxt1DUQBJLZQkbflyJssA
         xOLfLB3gLoMBsxPyXC4u19m16f2x0mwTw3YqbdE/rhhH0eOWbuACt9z7k2dtdagLYc4Y
         7bGLRTCZC92nb/fFD74AXa3jplAw/nWbpJmwAf9WUvSIQ7/UH9qXNbyqqNs/Z3vIw9zU
         6kBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=nvuYWmXHY+qufm6Ds2WTn5QQ89YBOQpWQIdVxC0OR1g=;
        b=CePZ/yKcPJrvXnqDlGfhVVrp48ArdOQVKKhDfoBl41+HmJsDte2wWKrXYBo9HetfkS
         gq64XTbc+ExKXmey1I2K+eAOuwBiRBoYpdAwMQdYT2lqxY88cP3iZxRAurfKdHfx1alo
         GfD54l+IbLUISVHE/x2lnUHFxNFo+/Q1PVhTsjpOl77mk80b44vr/SJj1J9LVauhpab0
         myNx5g/5Q7P9EYJEe1p3or76E+OVB5wu/xZczdjRDf/Xg1WqztnUd3c4jPF0Vk8/v6/m
         2jkbhPk8kAi+L8oaHmxZZk0W3NeizJtiWCxkgkkBC3767LtvahpRqnQ/JlbmmIxA7vz6
         eDkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x53si4610392qvh.161.2019.02.20.15.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:36:28 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D847D308FC23;
	Wed, 20 Feb 2019 23:36:27 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6F8F75D9D2;
	Wed, 20 Feb 2019 23:36:26 +0000 (UTC)
Date: Wed, 20 Feb 2019 18:36:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190220233623.GC11325@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <0dbf7e99-7db4-4d8b-ecca-60893c83a2a9@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0dbf7e99-7db4-4d8b-ecca-60893c83a2a9@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 20 Feb 2019 23:36:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 03:17:58PM -0800, John Hubbard wrote:
> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > This patchset improves the HMM driver API and add support for hugetlbfs
> > and DAX mirroring. The improvement motivation was to make the ODP to HMM
> > conversion easier [1]. Because we have nouveau bits schedule for 5.1 and
> > to avoid any multi-tree synchronization this patchset adds few lines of
> > inline function that wrap the existing HMM driver API to the improved
> > API. The nouveau driver was tested before and after this patchset and it
> > builds and works on both case so there is no merging issue [2]. The
> > nouveau bit are queue up for 5.1 so this is why i added those inline.
> > 
> > If this get merge in 5.1 the plans is to merge the HMM to ODP in 5.2 or
> > 5.3 if testing shows any issues (so far no issues has been found with
> > limited testing but Mellanox will be running heavier testing for longer
> > time).
> > 
> > To avoid spamming mm i would like to not cc mm on ODP or nouveau patches,
> > however if people prefer to see those on mm mailing list then i can keep
> > it cced.
> > 
> > This is also what i intend to use as a base for AMD and Intel patches
> > (v2 with more thing of some rfc which were already posted in the past).
> > 
> 
> Hi Jerome,
> 
> Although Ralph has been testing and looking at this patchset, I just now
> noticed that there hasn't been much public review of it, so I'm doing
> a bit of that now. I don't think it's *quite* too late, because we're
> still not at the 5.1 merge window...sorry for taking so long to get to
> this.
> 
> Ralph, you might want to add ACKs or Tested-by's to some of these
> patches (or even Reviewed-by, if you went that deep, which I suspect you
> did in some cases), according to what you feel comfortable with?

More eyes are always welcome, i tested with nouveau and with infinibanb
mlx5. It seemed to work properly in my testing but i might have miss-
something.

Cheers,
Jérôme

