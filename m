Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83125C3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:00:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AE832087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:00:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AE832087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC4A78E0008; Tue, 29 Jan 2019 15:00:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C747A8E0002; Tue, 29 Jan 2019 15:00:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B63ED8E0008; Tue, 29 Jan 2019 15:00:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89BEA8E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:00:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id j125so22734173qke.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:00:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=LwWLg6bgs2iH8R66wtBVdrUx6rgGVOVpL4fXsziSVD8=;
        b=KO2hWJsPape7PR6em9Lg5My5QxyRmvJuqwNS5TNJok5toH8EVm/ltTjko+al3ax0yE
         Oucr5dIIfsX1lX09WhDTbHwmHi93cpy8kTEf9EtfrH7Mg9AQGZZMZgHGzeID2xG6Js2u
         U9mqmbvN6LNZ7x++8RnRI8xR5xsx4WZJJkQnxAZMy2+8erJNkMh9xRYcVq1QgKF6n3HW
         wFW7plvcpYrt/XSZjoWTDjp3LRyFyLl2CSwJUDRoRpWgbx8tFkkgKon7C0B1crw+xgfz
         lrgSvCX37DgmmfV2PO9kv5Ck+Y4AU6sv4YlqO3uuW+eFMeXhT3ivhAw0RgHpLHWukys5
         GrgQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdchaLjxTtsEKKJZrAwbQs7Tz9PlBesJcVyoyyLc6Yt72Dtwja0
	ecTaj3RwAUDlgvMTvGIw0ddAaFKMAGjNqRuEy1TgJht8SKKn2uflbUtUtdPdz//7Q1TX2/146Kb
	cP1gReaHXnt6TV1i2cxPATLCV7teNlHdb2vVShsEUz3xUTLnO92AS0k29CLQPvpCCdw==
X-Received: by 2002:a0c:f805:: with SMTP id r5mr26173059qvn.130.1548792037295;
        Tue, 29 Jan 2019 12:00:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7f00AjZTHxrsWE1sz0OWhDTjREGKO7GsOfz9jD0j0aCMA0dlvmbW+vDmJ9v+1idfkIetD2
X-Received: by 2002:a0c:f805:: with SMTP id r5mr26173026qvn.130.1548792036792;
        Tue, 29 Jan 2019 12:00:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548792036; cv=none;
        d=google.com; s=arc-20160816;
        b=pbSSJfi4dEpYl8PlWuHTXoZhlmWAhY35VtHKgVttmkL0gIjnj7iMNbCzVohRYU2Pzs
         Xi321VHibBwdEydU9bKWSB2+uEWq1U2F4IVq4ISnMsguVq23i/Bm9Wvc+f8obWutmidj
         PvAoJXvOpv5nxkfMGEYYxBRpyKPBHQf312RM/2qwiTNvIWu9MshSiKX+hSxAeYD9UrhU
         x7l2B9Yait5obfRys8DrWK40o65/2bh/i3HGBdhM4Y+H5tlLsrv7fOjpOzViLpwOQOL5
         eu89h4DKxeZT9cSYikKFLCc+lG3ff0lz0cepdS58bp77f1d+1BmuLQoEufytNiHm8oFy
         gOkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=LwWLg6bgs2iH8R66wtBVdrUx6rgGVOVpL4fXsziSVD8=;
        b=q/Qf4ZZuA/vMU5AxKHHHXZ+aaC8oRkS8j7O6eqqS7se2HUdoWbBFMNVibwY/SxaJiL
         luIUimZbbxP5dFC0bKP906M41GwXGnB/VO7srRqoOV7RbgzfGKe6+/JOY3wTrIBgTybE
         MTn19L8ZfrXuhGCgCRWb911ZSv06ys+etivwQ/5eXTm+pYsmOWy8IyZLlj2JPFLvFmGq
         2faOGFnGVDom2I3K6KNKV7K7GKDHandpNf0PdJ7G4pF5Bzuims5NxfPw1UqlFFWuiNyy
         /hGyTM6QLvANDdACAmCaVCw5OtHKPHbGZ42eqPTCRsluY/oQd9x1fvikpepZ99O7pVUH
         GlGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n7si375801qkc.20.2019.01.29.12.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 12:00:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9EFEB811D8;
	Tue, 29 Jan 2019 20:00:35 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 618B45C239;
	Tue, 29 Jan 2019 20:00:33 +0000 (UTC)
Date: Tue, 29 Jan 2019 15:00:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Alex Deucher <alexdeucher@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Joerg Roedel <jroedel@suse.de>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Jason Gunthorpe <jgg@mellanox.com>,
	Linux PCI <linux-pci@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
Message-ID: <20190129200031.GL3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CADnq5_N8QLA_80j+iCtMHvSZhc-WFpzdZhpk6jR9yhoNoUDFZA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 29 Jan 2019 20:00:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 02:56:38PM -0500, Alex Deucher wrote:
> On Tue, Jan 29, 2019 at 12:47 PM <jglisse@redhat.com> wrote:
> >
> > From: Jérôme Glisse <jglisse@redhat.com>
> >
> > device_test_p2p() return true if two devices can peer to peer to
> > each other. We add a generic function as different inter-connect
> > can support peer to peer and we want to genericaly test this no
> > matter what the inter-connect might be. However this version only
> > support PCIE for now.
> >
> 
> What about something like these patches:
> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=4fab9ff69cb968183f717551441b475fabce6c1c
> https://cgit.freedesktop.org/~deathsimple/linux/commit/?h=p2p&id=f90b12d41c277335d08c9dab62433f27c0fadbe5
> They are a bit more thorough.

Yes it would be better, i forgot about those. I can include them
next time i post. Thank you for reminding me about those :)

Cheers,
Jérôme

