Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE230C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B162C2084C
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:54:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B162C2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 527EA8E0004; Tue, 29 Jan 2019 14:54:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D8468E0002; Tue, 29 Jan 2019 14:54:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39FE88E0004; Tue, 29 Jan 2019 14:54:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA438E0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:54:30 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j5so25712519qtk.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=OM+pDS/9K2ZXGPk3uIIgj17R028y5yzodiRWNWiNb4Y=;
        b=Gq8NIwRjVHZQXXlt1ri0PTOdGf+XqlWulZeZiXxboB+qBzeOiGXsRn2gPtmMEXAZ0g
         jCLJ7KsRs7btMuccVV7w7R5ltDfmwGbx/yY/++FO3Oc9LGe+UT0xK7rjE1ue4EaWQkgQ
         yAp6j4VIGGeGN6xF03sUSoUGlmigNCoaicPx64psWUYgvJEI2UYpJ52kDpvhkZbswchp
         IiYfdDLqS22VuK0HIYhybyh2LOKUF62mWxSzLyPMrRdwn8SoCZAlVUv4cj3q4IrqzqfN
         7hgVzT5nR8OBy7MZCaeudgvPyrslGBB2aJk+gRZxJNPWsZJd9tA2381h8pCgbUZR5rnX
         VRBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfb9iMN3WBDPpUwn9BrP/EtqAUs2PIH9Iwt9bIMu+v28tr/RegV
	GqkPltWpFNCHByEfkb/PrHVhvJaNM1EyCbVvdPBgPlmspg6pSTxVoajXXZUNFZ0J9MAh+qFZuYi
	kjzyCCFliKY4hKMhcE4F211jmTE9zB9Tiu12k+2B8SeVwJkleb08uixv5bDxxBiz6Gw==
X-Received: by 2002:a0c:9471:: with SMTP id i46mr25698474qvi.120.1548791669849;
        Tue, 29 Jan 2019 11:54:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7e4/AXzIE2AOqbhhPXImhzmCHvxByms4eZy0cEH+esOdQhQY8IMT4QyHf5lAm3OXLJhN6h
X-Received: by 2002:a0c:9471:: with SMTP id i46mr25698452qvi.120.1548791669422;
        Tue, 29 Jan 2019 11:54:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791669; cv=none;
        d=google.com; s=arc-20160816;
        b=taVoH9oWk42R3N7ZicPz6OwsNANaef2I0uVVqigldDH1Ik/7t35ZAk2ilCjiHU4yYQ
         xUyLWAt6X4SkaIGhL1mx3iwUNK9JTc4toCpJV3uhG8ucYSg9XYldbReBvHTYOzwQLaFe
         25rkK1c3+frTxQF+jMrDISkOLLOsK9ABAKSFMbCiVgAoaNShu0U9n8VdWHb+9l0HhAos
         1he3Ms9Kq8vmWjm9vMNUUdxPHY9WnqxgCLu7pRVn6PemtS2zaR6zFHsRcYBWP7fUVlhn
         LYVdhh+IGH76A1qxJfsob31kWf7YUZZ0XCezQAEl4tFozU34nQXgYncDz0Xa8fzLKibH
         0mLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=OM+pDS/9K2ZXGPk3uIIgj17R028y5yzodiRWNWiNb4Y=;
        b=pA8WRWpnurDBN2trPbUCs9M0geeOn12PIqKqKFrUtVlv5UduDtzFkQa+h0zhgf0ih7
         adfGCduIynrXb29GXmxSy45XrZwcXIsIAXG2Z0vS5rEpUWMkPHV7Htk2OrPfS5ScEsyU
         oX+iQiQ0PZhZyqW2dyotTjGxv9y8Y9yj72c2oxbJeCvVM53M+TBoEmB8iOJLQ3gOAiP8
         zUBZQMXNpV0aE2QXYHubXsQscHFFj3OlOGntl/NgnvwV8rMvDtTfHeOvSCzWYXodF4D9
         1m9a8CyXJtRaU81kTVMaSnVO+Mrht7OfDismJsU/TnTdavy69XQKidD2ryHA5/YL/htc
         fS3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k35si1513371qtc.318.2019.01.29.11.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:54:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 49AA689AC5;
	Tue, 29 Jan 2019 19:54:28 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 537BF600CC;
	Tue, 29 Jan 2019 19:54:25 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:54:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 2/5] drivers/base: add a function to test peer to
 peer capability
Message-ID: <20190129195421.GJ3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-3-jglisse@redhat.com>
 <98d345af-7928-2a50-7bc4-582916dfac80@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <98d345af-7928-2a50-7bc4-582916dfac80@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 19:54:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:26:01AM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > device_test_p2p() return true if two devices can peer to peer to
> > each other. We add a generic function as different inter-connect
> > can support peer to peer and we want to genericaly test this no
> > matter what the inter-connect might be. However this version only
> > support PCIE for now.
> 
> This doesn't appear to be used in any of the further patches; so it's
> very confusing.
> 
> I'm not sure a struct device wrapper is really necessary...

I wanted to allow other non pci device to join in the fun but
yes right now i have only be doing this on pci devices.

Jérôme

