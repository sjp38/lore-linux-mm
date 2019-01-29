Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34024C282D1
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC9D921473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:00:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC9D921473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EFA68E0003; Tue, 29 Jan 2019 16:00:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89DD48E0001; Tue, 29 Jan 2019 16:00:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BE38E0003; Tue, 29 Jan 2019 16:00:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5978E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:00:15 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so23305715qke.20
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:00:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/1gIi7T1dRTUHKPk97ncy1O0U6azH8+Kof8HoJbyGiI=;
        b=cv/92xDZf20V3agG7q9kMSLdoRqxOzgqG1yehXeGpPschuWI+HVMjivOVTsNsMrAbP
         vuZJY3FwdCye0FbMMB12yeUVTTSR66+JBLwVHshvJdxrevW13uD2RB8ciEYXUiBl6drR
         UDW5df8UuLS2W0WdaudadDeXYerNoJL+Y3G95s+XNK89ucbRlDm7qGQ8ZorhR/5oYHZc
         jXLSLNksNq+hG3riRu4W3Ub85gYZABMTpIPBCMCBPtE6/gFXEVnP8+4fmoKvPJsYi/dP
         wDnTTUQ5fqsMdFxmqFeZCIGDnsKCIk4BbdkqtGlsiSGLcqIi9Cs0cNI/p9gy6WeNdqWc
         AdSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfmd7Xva+VIqMq/PWVkv9i+lG/ihplizmQBGxUDdQuvOtXTVozf
	dcWN0q3PQYz8LSLlzgXjbPdHFYHZAvLnRcDSoAooqszdjAQ7OBYmCmu9/lqD3e4xH4zBUDdATWc
	sKbI4EKivH6O8VfGNLNPBiX2I36AJERtUI1xUE3xMZXyDmRq/+uybcSc+YRGsDlnaVA==
X-Received: by 2002:a0c:d232:: with SMTP id m47mr26731103qvh.43.1548795615045;
        Tue, 29 Jan 2019 13:00:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4VgmCX+YNhdtthmUWtCXUQooW84fEm+MCkue5HcW9Y0X3jSrLaEPVm3+GiwFUpReoDrIdI
X-Received: by 2002:a0c:d232:: with SMTP id m47mr26731068qvh.43.1548795614550;
        Tue, 29 Jan 2019 13:00:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548795614; cv=none;
        d=google.com; s=arc-20160816;
        b=r33FrkPiVmS3ddCJsYhB4zhW5hxi1WPagrmXW/W84BkxZElCCZWx9InBEdKxW/JvNo
         cz7aReqhIq5FV0ZQXITOxYvnLCXQAPOxe2jaHQwFrzAECh2yn8b2qi3ED9HehU0qpCHp
         FaAcVELK9EMzNVy07ui3DdgTtbiBGwBN++OH7ZyenVTJpApGMS//omDNo+4OE1FcvhyV
         pXfLii4To76NOV0Z8WPPLyTbWXRacgIiI2c4nrgt8pmNExeh74t2/EBW9lAhWIZaQuWD
         uFy9w3EcuIVtma35yo6Y7PjbLH58y3CVJZ8P6mXCi0giSLH2I5zcDIpc2YeSiSC07exM
         WRFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/1gIi7T1dRTUHKPk97ncy1O0U6azH8+Kof8HoJbyGiI=;
        b=a5725gGkkqFmJqA7wyL+y4SwHG+uPG5/B6079sVPGtdSUyqytBHJPTjg0xz14yfyYW
         1UoJWDutYtD+HvCYizyexfbqS6r3T8jgAf0Gmc77WlOvfUKFco8PERtDr1P1kOAVpqw5
         p9+KHeZYa49qgjL83jNI682aqJM4GPLCdCh/enO1pCXgG6qvDlCKPZgg+5WQzTTzU3vF
         ssYiCGCrsFwEVuH7HC/KnvlzzFKkJUFqBOVQb+FAHkQOWXLeoXIBrOUqx4JpAh0blJ8Y
         tMw3UtaNMDTuMBGJeMqd3MjT4hzFzpJWdNJl8s4zVWeqx4xGGbkaSqtho2/33qmAte+N
         sQ0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si1364417qvj.66.2019.01.29.13.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 13:00:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6751D58E22;
	Tue, 29 Jan 2019 21:00:13 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3147460C6E;
	Tue, 29 Jan 2019 21:00:10 +0000 (UTC)
Date: Tue, 29 Jan 2019 16:00:08 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: Re: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer
 capability
Message-ID: <20190129210007.GO3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-2-jglisse@redhat.com>
 <f66ba584-9c4a-f6cd-c647-9b32a93be807@deltatee.com>
 <20190129194426.GB32069@kroah.com>
 <8b4e0157-4eaf-c79a-28d0-7a266abe2207@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8b4e0157-4eaf-c79a-28d0-7a266abe2207@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 29 Jan 2019 21:00:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 01:44:09PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 12:44 p.m., Greg Kroah-Hartman wrote:
> > On Tue, Jan 29, 2019 at 11:24:09AM -0700, Logan Gunthorpe wrote:
> >>
> >>
> >> On 2019-01-29 10:47 a.m., jglisse@redhat.com wrote:
> >>> +bool pci_test_p2p(struct device *devA, struct device *devB)
> >>> +{
> >>> +	struct pci_dev *pciA, *pciB;
> >>> +	bool ret;
> >>> +	int tmp;
> >>> +
> >>> +	/*
> >>> +	 * For now we only support PCIE peer to peer but other inter-connect
> >>> +	 * can be added.
> >>> +	 */
> >>> +	pciA = find_parent_pci_dev(devA);
> >>> +	pciB = find_parent_pci_dev(devB);
> >>> +	if (pciA == NULL || pciB == NULL) {
> >>> +		ret = false;
> >>> +		goto out;
> >>> +	}
> >>> +
> >>> +	tmp = upstream_bridge_distance(pciA, pciB, NULL);
> >>> +	ret = tmp < 0 ? false : true;
> >>> +
> >>> +out:
> >>> +	pci_dev_put(pciB);
> >>> +	pci_dev_put(pciA);
> >>> +	return false;
> >>> +}
> >>> +EXPORT_SYMBOL_GPL(pci_test_p2p);
> >>
> >> This function only ever returns false....
> > 
> > I guess it was nevr actually tested :(
> > 
> > I feel really worried about passing random 'struct device' pointers into
> > the PCI layer.  Are we _sure_ it can handle this properly?
> 
> Yes, there are a couple of pci_p2pdma functions that take struct devices
> directly simply because it's way more convenient for the caller. That's
> what find_parent_pci_dev() takes care of (it returns false if the device
> is not a PCI device). Whether that's appropriate here is hard to say
> seeing we haven't seen any caller code.

Caller code as a reference (i already given that link in other part of
thread but just so that people don't have to follow all branches).

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-p2p&id=401a567696eafb1d4faf7054ab0d7c3a16a5ef06

Cheers,
Jérôme

