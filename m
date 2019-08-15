Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1E3BC3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:33:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FF5A2086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 19:33:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DSQnzP2b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FF5A2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0937C6B026B; Thu, 15 Aug 2019 15:33:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 043FA6B027A; Thu, 15 Aug 2019 15:33:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9AC76B0281; Thu, 15 Aug 2019 15:33:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id C8A1C6B026B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 15:33:04 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7C44B8248AB5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:33:04 +0000 (UTC)
X-FDA: 75825660288.06.cord61_54fd62760f823
X-HE-Tag: cord61_54fd62760f823
X-Filterd-Recvd-Size: 4430
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 19:33:03 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id l9so3561076qtu.6
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:33:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=d/Vs2YH0f5xNou4jHOnIZOohEAfDIJUopBMHuRVrEaM=;
        b=DSQnzP2boVVz05frK9Rf9m+2jw7zFPx+9AUXj2jqSyufMDNrAKls4vo+Fb+WrAEgvO
         ktfk/TjL4ijraP2CEooza64EfLjaFdcqjeQ5Vv3suWLQE3AFJsd5YcPid89lanEu0ZoG
         VOQYC/bNeGf1IZi2CVdyacQhQw7JiSZnXckYhCGW/PB/p43g8HasbOXkyAfk/T5vpF3D
         xiyWjGC5nu7KpcLH5DDONB00uambPQIgUVk3jQbczWBzrPFHJZNpEMI+ZlEgjUg+75rH
         LjzpVx3i2jLsC6X0ifOF/LcBrXk/+s6IlAd5gRScNQG9jSmLI4mn6ct4mUNoFB6ybWFo
         /qdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=d/Vs2YH0f5xNou4jHOnIZOohEAfDIJUopBMHuRVrEaM=;
        b=jdzCWkWToR1LYKcQykZ3y0hPo8rxB1chh+bbd9Jw4/VwndgT/fXEr/JZvlVfud/VsB
         AEDlpDiIsMJ3BPpA575be54NGiS3cgR09BiqQAzNfQ+Jpu1THUUFGxgezFtlywmvbxdn
         zekkGAES7E7sOBCyF9PLfAqk1sJ/xFZGgs7XR6hAMLKNh4ODk2RqjdIgASBXvjnEP566
         A8EHG0RLEn0mtJu+S3XchN0vwWDlPpcb4P7iwCxa7gE9bX0HPOWQ9igJqUN38nHWaH1L
         7hg77Fo0afgtg+y2qFbELmgxOz0piEtV81m8V0/MNU4Gdu+AH8FadXfjki/bdzRS3vHZ
         4/Jw==
X-Gm-Message-State: APjAAAUXeUbMi0BuhBOekyLV4HMf+aCg+e5rIzQstSf+gA1ptmBNaN0y
	96oxcW3A87ijDpoLCrfDFyDV7Q==
X-Google-Smtp-Source: APXvYqzizPYl2LrtkxXjbmjRPnD30yqIwKDY6KgNsz0NbhIueWjJnIkysTmtYLAdQWA6iei+yUmzJQ==
X-Received: by 2002:ac8:5343:: with SMTP id d3mr5516461qto.50.1565897583402;
        Thu, 15 Aug 2019 12:33:03 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s4sm1862094qkb.130.2019.08.15.12.33.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 12:33:03 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyLUc-0008Aa-AF; Thu, 15 Aug 2019 16:33:02 -0300
Date: Thu, 15 Aug 2019 16:33:02 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 0/9] Fixes for vhost metadata acceleration
Message-ID: <20190815193302.GT21596@ziepe.ca>
References: <20190809054851.20118-1-jasowang@redhat.com>
 <20190810134948-mutt-send-email-mst@kernel.org>
 <360a3b91-1ac5-84c0-d34b-a4243fa748c4@redhat.com>
 <20190812054429-mutt-send-email-mst@kernel.org>
 <20190812130252.GE24457@ziepe.ca>
 <9a9641fe-b48f-f32a-eecc-af9c2f4fbe0e@redhat.com>
 <20190813115707.GC29508@ziepe.ca>
 <74838e61-3a5e-0f51-2092-f4a16d144b45@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <74838e61-3a5e-0f51-2092-f4a16d144b45@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 11:26:46AM +0800, Jason Wang wrote:
>=20
> On 2019/8/13 =E4=B8=8B=E5=8D=887:57, Jason Gunthorpe wrote:
> > On Tue, Aug 13, 2019 at 04:31:07PM +0800, Jason Wang wrote:
> >=20
> > > What kind of issues do you see? Spinlock is to synchronize GUP with=
 MMU
> > > notifier in this series.
> > A GUP that can't sleep can't pagefault which makes it a really weird
> > pattern
>=20
>=20
> My understanding is __get_user_pages_fast() assumes caller can fail or =
have
> fallback. And we have graceful fallback to copy_{to|from}_user().

My point is that if you can fall back to copy_user then it is weird to
call the special non-sleeping GUP under a spinlock.

AFAIK the only reason this is done is because of the way the notifier
is being locked...

Jason

