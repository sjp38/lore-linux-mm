Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5EDCC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:02:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FBB9218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:02:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FBB9218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F0988E0002; Thu, 31 Jan 2019 03:02:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99FA18E0001; Thu, 31 Jan 2019 03:02:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88EB88E0002; Thu, 31 Jan 2019 03:02:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3239D8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:02:06 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f198so658709wmd.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:02:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=M815sQPZJBiuAr8+2NsanYc1ImHdLp2bPwqA4pLQ1p4=;
        b=W7zOOWMrzDGTcjcjz7bfwmlU066FiH/jVioZ7NYHxzngw7ns89YkPWuycncHOkchvK
         INVO9onwz9ZZPOoXpwI2kd+xPJ9NBOxZbK8zMYLkXtsTxxgvpMElEdYKKPuuNF2A0qP9
         I+SA7nb10mgtad661B2BOQVn8TC5flMka9yoXbROcljPP8yeuE4XE1VinotQIpWCtuer
         v2w4wUrxBqHxWJCI93IRkfUkwtGPggX0BRuGqga1dcgmlA8EAunhnvXbg99EuKOjWKlS
         FYwNRkmHL59TutDVfI0c51wRCOODIp0MFAtH7gz5Fyw8Ki7TvmQCb3z9h22mTg1Tz5nr
         IuDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukdivXa/zgcFrNXZIGgGjsECMExQbcMwUhYfzdNHSH3eaEWWAAY2
	i1rTt6sy+aQfLO4cl3wKwHNCuzZBMJDpJvQNX5UhrIGeoQHaoHAs4Jv7RrdCdmcitKnBoSDUv4K
	CUXCFAuvUrlEcuCt9W1Rs2jOTszLojmA8q3P6TNF1n+v8BmLdHGxTWubBfLh2udp0CQ==
X-Received: by 2002:a1c:e913:: with SMTP id q19mr28958041wmc.55.1548921725658;
        Thu, 31 Jan 2019 00:02:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5pKwBSxGfx/HFApgdEiZPyvBdy0lVAwUgS2ONGm4tKDe/NZmDuT/WfJ/llXvho+VxmFr7P
X-Received: by 2002:a1c:e913:: with SMTP id q19mr28957956wmc.55.1548921724584;
        Thu, 31 Jan 2019 00:02:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548921724; cv=none;
        d=google.com; s=arc-20160816;
        b=E87SRSTKHgXaDF57girL0FO2/QzYq1BMYNazFBJLWgRxF4txbdBfz/S0s+/gIzma3Y
         K7ce31mfObXGZe5bBEKSdbIR4afmS3KZxJPMP++pne7RghOMjYBNozh02E3Ixq/ah3NR
         wNW6gMlaQzGLdG3UroavH04QHklj9dXvpRxrkL6iQqoE30Qec9gtBS0kRjKrkzzOGYUr
         qGuR2xHGkPKpzQpUSnkKow/XGq941rQ3o7wTyseqcUehafOuDUTt/h630nmlDmUtQ0+U
         jgIzHgCz7xAssQ1N+UU7WnLoXmqt8g64DM/YNTyeBmgd1hUGS6mfMvINFf8/TsjwsTnJ
         /rkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=M815sQPZJBiuAr8+2NsanYc1ImHdLp2bPwqA4pLQ1p4=;
        b=kDT2q8MWwmhusDHqkyEmbPebY1V/eD81z132ji4htCNNTRzD/UQiDWFDoI9ct1gHOT
         ZP/SzkIr7f+QXm1f2D90cVd1ysQ96/z+qJejHXDg6MXI5xd2eRKHAoNxO2XqRr2RUto6
         FiN0TdkNXoBKhoT2oQ83YYGNEwmmMtKHBnfcX2otkOkSQ1ccr8vOHR90psHvbIo8xfY/
         pUltreHMMdo/JQ+XOzK1szmO3iT50u0A+X90f6loS+ADSW0AoZOr/HSsFLt4F0HTSaPn
         tl865goXhCPazrrHwNEAziuxbmOzy9NxQLWtDgpPVm7vdVwNmXgUOdtwWRON8nSqR4Ra
         vWng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g187si3076279wmg.188.2019.01.31.00.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:02:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id A164168CEB; Thu, 31 Jan 2019 09:02:03 +0100 (CET)
Date: Thu, 31 Jan 2019 09:02:03 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190131080203.GA26495@lst.de>
References: <20190129174728.6430-4-jglisse@redhat.com> <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com> <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com> <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com> <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de> <20190130174424.GA17080@mellanox.com> <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com> <20190130185027.GC5061@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130185027.GC5061@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 01:50:27PM -0500, Jerome Glisse wrote:
> I do not see how VMA changes are any different than using struct page
> in respect to userspace exposure. Those vma callback do not need to be
> set by everyone, in fact expectation is that only handful of driver
> will set those.
> 
> How can we do p2p between RDMA and GPU for instance, without exposure
> to userspace ? At some point you need to tell userspace hey this kernel
> does allow you to do that :)

To do RDMA on a memory region you need struct page backіng to start
with..

