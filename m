Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 748A4C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B7D62075D
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 10:59:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="ZrPmNar5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B7D62075D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C26618E008B; Fri,  8 Feb 2019 05:59:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD5D08E008A; Fri,  8 Feb 2019 05:59:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEB968E008B; Fri,  8 Feb 2019 05:59:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 596068E008A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 05:59:21 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id m7so680611wrn.15
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 02:59:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=5vM19Mse6Fg0iyC0wbkxDF21CFIQD2YJabqo5tMcP3Y=;
        b=i1P+V2u6qgToCQkhzsEoRneTaNtrv0Shkw0BIBOAy9YnkhrNcdKQvLobkRRh+tlE9u
         +f4lopvFgglHf8RSnfdT3gD+FhY3X8Qivg7JC+xwxRTqmcc1CCMCgU0NY3ZvRakrvc7+
         +3BrH/5Dxf8ttllDuPoArhknvjfsOrCJW2E+aGHIgfLtA7/hi03G4fzmXDC6rBuHRf05
         JUcaAKc0pxBi7pp463gRBS0x161V+S9yyzcUrI20Tfrou0msf/KwHbEQ7O5LKTUMz04/
         1zqkyZZl3GvdQG7W2V0GP9M749Z6i6xlxZQv+Mmyzc/XwfdGJKSwtp8lYjLNx4eAVFjJ
         0OzQ==
X-Gm-Message-State: AHQUAuY3WUbe3RCQyYxMsggI01A3fqsZPr3RRr5NTvcjgz6irtZOOW0A
	RfJ309COCOdlSIv5JmL5hLsOdzhDalET8rstYejEG5ODWC46BvGFUWBxZxdeCuJVA4RIyhJdAky
	7ak4q5X9xb0OTCXDNIk1mrwlPDY3sjXMDw+orMIX44baUQTuvIppF3osqoD3vE78VYQ==
X-Received: by 2002:a1c:f901:: with SMTP id x1mr2557326wmh.84.1549623560899;
        Fri, 08 Feb 2019 02:59:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/1+z6M8grdPtxBD8FyfVY7qOzlML+0/N4zX1eOT/IeC1o7XqY5BrDCPVDp1AtR/wK2I+s
X-Received: by 2002:a1c:f901:: with SMTP id x1mr2557260wmh.84.1549623559918;
        Fri, 08 Feb 2019 02:59:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549623559; cv=none;
        d=google.com; s=arc-20160816;
        b=v4skTa437+faHnXqP/AR917RprulXCn5rb+RYVbc6Y5UWls9DJPFPbER0opepuPnVv
         /3bvOfDedMDEjRpxsxyBh/rceeuWrsNPmC+gonQg1meLKW6omi01uPL8G8GdeJhD8Qog
         t/+mC23iuvEWKqpszxYDryMmi/xP0vmjo95JuwrIr91WVyEx14bpc6/svslLkYcX0g/D
         Qw3DnTfv9ETbbTz+fyP5j1AgTkEIeAKD0tbCqZWlwdXFPTEsMI1dVp2GKAbbNdh2fB/Y
         fZLQWHTkgEV46jo5WdnoO6gkdnPQ6momdT2AWbTjXKZ4CqVFxWG/gMByGXum8kIuKtpy
         KD9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=5vM19Mse6Fg0iyC0wbkxDF21CFIQD2YJabqo5tMcP3Y=;
        b=C/MfaUszWFT8iekBv8Ra1XcXc94WlNoJKGuiTD/cxyPhbrQZvato0DJoK17WliYi5z
         /Of02fWQnTh6ub6U2Rf6F3CK++B/k5yxy+oXiYkj2HoneucJD6QY66W0ChdSI5u1qIIA
         z3H9aX4jW/mqyXKN76e+JmUYJaMlR96wwc84hUWgQ+PQFc5k/0viNOLJQjFyg0DY5r3Q
         ZshNup0Pm/ZltHI4xmElRV8Bs9W9iQOZUy6L9yUbPWHPhNHQZb266UPt6DlEG11zNIIx
         iljqeK0WPdKWR5CN4sd3y1IuggS3kTgIYPebi8+BRHjdLvhmU5X1b5LZCXLqCNF3t+mB
         g+7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=ZrPmNar5;
       spf=neutral (google.com: 2a01:238:20a:202:5301::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::10])
        by mx.google.com with ESMTPS id h10si1250512wrq.159.2019.02.08.02.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 02:59:19 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::10;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=ZrPmNar5;
       spf=neutral (google.com: 2a01:238:20a:202:5301::10 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549623559;
	s=strato-dkim-0002; d=xenosoft.de;
	h=To:References:Message-Id:Cc:Date:In-Reply-To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=5vM19Mse6Fg0iyC0wbkxDF21CFIQD2YJabqo5tMcP3Y=;
	b=ZrPmNar5nkOEw369OAyjUUPNWbfDvrYP7HFrq/e+baVO4PUCGtOfXIW4a9RR7Clq9s
	sk9CUzoDASkViob3LdXEG7tq9Po4/z05msjK0CTakpCsTbeWvmg11l821KS+PbEJyTQM
	JxpFxqF4vpRRuz11N4QPGuXwQCFdD5JnH1pBAOF47DEyqMPGRuCruOWPPXxAPWuXALG6
	uzMSNkttzIBhE49F3/Q4eeeJcc53dEgh/tonvmSeJUmqrERdqYqGkTV7N+6o33iwZKiY
	MM0bk/GxghLuIfF/CHTuoM/4/EtLm9iEI5AKHnG1xg5RP9QPsOBERuuigQzHF074EJHx
	Q+Qw==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGN0rBVhd9dFr6Kxrf+5Dj7x4Ql+BpvNtdS8exno1lfFcAX4Rep/HqzVAjBMh+akM"
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:5097:f73f:b2d2:de7]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv18AxF5ae
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Fri, 8 Feb 2019 11:59:15 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
X-Mailer: iPhone Mail (16C101)
In-Reply-To: <20190208091818.GA23491@lst.de>
Date: Fri, 8 Feb 2019 11:59:14 +0100
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <A289D18C-1239-4296-B58F-FFB0DF1D9C79@xenosoft.de>
References: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de> <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de> <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de>
To: Christoph Hellwig <hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

OK, I will test it.

=E2=80=94 Christian

Sent from my iPhone

> On 8. Feb 2019, at 10:18, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Fri, Feb 08, 2019 at 10:01:46AM +0100, Christian Zigotzky wrote:
>> Hi Christoph,
>>=20
>> Your new patch fixes the problems with the P.A. Semi Ethernet! :-)
>=20
> Thanks a lot once again for testing!
>=20
> Now can you test with this patch and the whole series?
>=20
> I've updated the powerpc-dma.6 branch to include this fix.

