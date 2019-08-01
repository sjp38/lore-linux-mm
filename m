Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63447C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:13:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32BC5206A3
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:13:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32BC5206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5FF08E0031; Thu,  1 Aug 2019 12:13:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D10108E0001; Thu,  1 Aug 2019 12:13:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4C248E0031; Thu,  1 Aug 2019 12:13:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FE158E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:13:34 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id w11so35629747wrl.7
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:13:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kzSp/Sc6Cb+FmjMNGuO4QgIzakeuGfoggBnC2AGUZXM=;
        b=jHlgBlMSZkwXzONHoGx/MRcRK0aETEFpxWoyUTce4FMEKb/4EwwX6DnS+XGGo+cJhl
         BgomWinIHv3BZecnWMwlCj7ql5XiN40x4ONanzJip7A/DI2Hg0lTOHEnpqiyiQSA1FQ2
         xhiWY8vWYTx8gyTmclCGUM/gANK9oDyZpqzXxChbQ5mbspVwFZkV91Q/aSIgdAAvzvgj
         +x+tL6EYMIjBfq2xGtWZCmAcYfSu21O9RVKiS1oSZrEXtOEcl58MYF/sTDkG2v8E3Swn
         UqWhvUTG8XZcGKI42GZUmy0jTCqNUVh28yuRbAH36yr7+W+E8Ae/MAjp7Ui7SYeWwnxW
         HDRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWG/mciodizp1ZRzepoQONFZi3PKp52w42fZ7w6Bz11TaO1zbv2
	rjZVRuSGAt5ucYhmss8ykSMfbPOoVxoeBftRhbKbEoSbMjSbSj4vLmWOpg45Iqxr5KrDBqwLTp9
	fD+9wbwAvA2DC6H7T2GIes136UNFyRaGdhpuIdPv00ONG95LTyWupULXjQAWjhjVc+A==
X-Received: by 2002:adf:fdcc:: with SMTP id i12mr20715100wrs.88.1564676014183;
        Thu, 01 Aug 2019 09:13:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUOA5bNTBvUFAsxG1evhpIkvTN/Rg5qpWOm+Yxqy4IL8qQkbSH5m3ljzW+IbCrb6z8gBUN
X-Received: by 2002:adf:fdcc:: with SMTP id i12mr20715045wrs.88.1564676013375;
        Thu, 01 Aug 2019 09:13:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564676013; cv=none;
        d=google.com; s=arc-20160816;
        b=dPFSyWGb2U4wES+m2jXclqa/ZiBCptK23HenbWigtKkMjDSBiPrTrit8V142HysHAJ
         PyJDz8oZVB6Kv6NKAHNHAi+oq3ieujnK4DtGcBEzy1wOkQUrUfGkW0JWCoC1DxFume5d
         JwBuI84IzScN9IwwbIZ49z0yMiJ+pqaTNaGP+1sq8DXNHRZWflM/6R7JB+CppcZe6XUk
         maYBfkHlujftw8O8BgHQePtCvTbYBWQjgpOsV9KtVnf/rm9LvUgVrm6vLjgXLPf5qASS
         da1w9e9hNkaEXXhZBdD2lzN75Cy/9TTXgA4j4DEynfU9CxRxk/Ix5o64oX91e78Aw6vU
         Othw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kzSp/Sc6Cb+FmjMNGuO4QgIzakeuGfoggBnC2AGUZXM=;
        b=mA2irS1oUKGIm3+wiXb6SsEcmwcXCNmV0duHdgsAoL81kKN1C4Nt4GRYbWsXYOa357
         g26HLKEKXB0/xcOz7Iick4iCm6Pzl86IL519f6MglwO/5945S5saF0Mf3JctbCMSwa/R
         JozOC0Vgu3i0eLuFjco52hSNh4V4Ik8A3OvbS2bsNTVaog5/R35qJR07ctJ6TDZpgfiC
         qmPQnleaYB5J5P2CdSbZE1zCx5WLFrNsb1ZHrPsNMLYYieOlGktgBdWBrUnZqaexCRtA
         u7dPhRM/C8r2WjEn9cpopzqKwt+9mwFA+Y75s37qD1jOkB1pNIENiJXQ5BmlFdcUwbfk
         mgtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id c6si67583779wrm.290.2019.08.01.09.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 09:13:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id DD40B68AFE; Thu,  1 Aug 2019 18:13:30 +0200 (CEST)
Date: Thu, 1 Aug 2019 18:13:30 +0200
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 2/2] xfs: Support large pages
Message-ID: <20190801161330.GA25871@lst.de>
References: <20190731171734.21601-1-willy@infradead.org> <20190731171734.21601-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731171734.21601-3-willy@infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 10:17:34AM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> Mostly this is just checking the page size of each page instead of
> assuming PAGE_SIZE.  Clean up the logic in writepage a little.
> 
> Based on a patch from Christoph Hellwig.

FYI, all this is pending a move to iomap..

