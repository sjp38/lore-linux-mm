Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FADDC072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620EB21850
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 06:31:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620EB21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF0076B0003; Wed, 22 May 2019 02:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA1486B0006; Wed, 22 May 2019 02:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB6076B0007; Wed, 22 May 2019 02:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A44086B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 02:31:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y22so2075196eds.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 23:31:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HsOrSSPU5BV9Q3gQc0wMFK8uVEORXt1Yr0TT9XOkgG4=;
        b=Q6zE0w6JOkcUGNhowNxISQX8Q3npt8To3UbYvxAxLAivp17r9q1leq7PjxHydHMbMR
         EXsbD9YnmLB6fsGXKqDAWn91qQqqzqsW+Pd49PQQNKlOnnQgpIRiulgJWOHbYwC1VOag
         tX+ZwfYEdyJShbisrRnP9T3FP2ATmL5qhKQ/drfNjz6oSbMCDQA+kSBm392WsbRjapHX
         bkph3RcRvPPDVLgwW6XWCH18/80AKGmZlCs9WpphBt35o3wjSkSicISPftG3BM2OTViV
         T2YNg3X6cPQo0E4ESsLjMYhq4fNaZ1AO38hKf/GqAGPkPy716l1BKB1oMVdtb361BfPB
         QunQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAWSom82t15I6mpddhndySnI0/AAn0XPwZyiAUNFFBMdgUKzEG3K
	ZnK2c2xYTXpPWGmUfCqQVUAaA1z21jx+tPNPdklvN53b0XaOU+VuXBoDzp/Q9MZDmzrrgVD+wQl
	h1i6oo31h1Fy2trCArSmyA7o5NXzidg6zApd4FOlLRLKd4IeXtvscxmAGGhqfpk2Zfg==
X-Received: by 2002:a17:906:4e56:: with SMTP id g22mr61393021ejw.51.1558506706162;
        Tue, 21 May 2019 23:31:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHulg8hW3Z83ZoK0GuzzSbIQ7TWIFBn96Z7O70oVFGoJ1CggGRMfqDnqBsLbQLvGDZKt9z
X-Received: by 2002:a17:906:4e56:: with SMTP id g22mr61392958ejw.51.1558506705221;
        Tue, 21 May 2019 23:31:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558506705; cv=none;
        d=google.com; s=arc-20160816;
        b=Wl7bGbFfBjPDfO9ZDQi+IU9ZrXqNTVP/ZQN3ifMpjg9duyNaiBadjjwVHd5L7P2i2y
         daNdUckvmPEDdawmbOVwutfC9m4KtaTZPNPRTbAWZYiyJaYRDz/pNMXuzB7w3NLbmniG
         MCxlFLgvnspB3tJ2qMXQYJQdSS5WMcHQ8/TAvhSjNbPRtFJ5aBk1a8q/Xr1p05YGFYHx
         uUT71QVP4lxnNZVj7W5dxZTX8euxM/7YD1xjU0NHNRNeq/ooVXXEomH8jLXHh7Fa5Auf
         GCe+78NRMUJH++xN+389CBfDlrtIxepPV2rAbMx8j8lnLfr+IzdBNgeukH7oQzn8iaCF
         bDIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=HsOrSSPU5BV9Q3gQc0wMFK8uVEORXt1Yr0TT9XOkgG4=;
        b=xt9As5hrAVIh3sRyicciQOSfxAzjrBn9CLhQtlUfN33SWQsEwcoRD4m4PAKAdQNQPI
         Hz3rhSvarvQTpv1W3DG+fNU8NlXd9eZ/fv1Y3EwFyqQN1aVjq81NMnSded2PhDLTI1LY
         yx3vzUcb38Q4oqlhq8KNi7PLIsVnBYSKbYIy3fugIsv2t5d4Gw5Il/ZKubBIoTPYTdCu
         hYl/YzKU03CJeaGV8Nh+rBeA4HId5Pks6cIn4N0SeDdfENDY//6bX3B+40X+0hQpVUMj
         w33MctCc10UaMaEEZP3CHtkioLts6DD9dOo1Y9xIYNqX6kqieOcYCq1Y01xxSnPQXdqL
         Rnlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si9742641eds.136.2019.05.21.23.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 23:31:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B08E1B01F;
	Wed, 22 May 2019 06:31:44 +0000 (UTC)
Message-ID: <1558506702.12672.28.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Jaewon Kim <jaewon31.kim@gmail.com>, Christoph Hellwig
 <hch@infradead.org>,  linux-mm@kvack.org, gregkh@linuxfoundation.org,
 Jaewon Kim <jaewon31.kim@samsung.com>, m.szyprowski@samsung.com,
 ytk.lee@samsung.com,  linux-kernel@vger.kernel.org,
 linux-usb@vger.kernel.org
Date: Wed, 22 May 2019 08:31:42 +0200
In-Reply-To: <Pine.LNX.4.44L0.1905210950170.1634-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.1905210950170.1634-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Di, 2019-05-21 at 10:00 -0400, Alan Stern wrote:
> 
> Changing configurations amounts to much the same as disconnecting,
> because both operations destroy all the existing interfaces.
> 
> Disconnect can arise in two different ways.
> 
>         Physical hot-unplug: All I/O operations will fail.
> 
>         Rmmod or unbind: I/O operations will succeed.
> 
> The second case is probably okay.  The first we can do nothing about.  
> However, in either case we do need to make sure that memory allocations
> do not require any writebacks.  This suggests that we need to call
> memalloc_noio_save() from within usb_unbind_interface().

I agree with the problem, but I fail to see why this issue would be
specific to USB. Shouldn't this be done in the device core layer?

	Regards
		Oliver

