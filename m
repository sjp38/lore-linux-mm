Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C42EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:32:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CFE0218BA
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:32:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CFE0218BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6A936B0006; Fri,  2 Aug 2019 04:32:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1B816B000A; Fri,  2 Aug 2019 04:32:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C31C36B000C; Fri,  2 Aug 2019 04:32:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 909616B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:32:33 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t76so17903339wmt.9
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:32:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RX+XrhTRDThahj9YMbo2fzyu5amiqvcFL1ThmTcPgvw=;
        b=XccV/Kp0JuJngaGImONcRlH/EldVShau5C/K1eqSAa1k7vN5AQwo40Iul3TPCeZeft
         WqlkD58g5Tl3fBABsyvaZ9vCBUU2+2WbWWAUqQd4qsU/fmYgWh+KUxJXXXYMnOazrGtw
         Bfm2LxcvTurs8pRh/SRqXzauoAgcGllbGp708AKx6uz1dvxkqEJeU+02oAkLtTyBxKrL
         QYsfN0UnrwNgm3I6UFPtGLpvv+Ov+k/lac8Nu7Jo8OCbN3/wdFzv27pQ1l0rcGy+uzDK
         NXW39ZND+w7GsWZTNqTsTUHi2qtkADa9yOfOJTWGHmLIV8nqm4jil7govAxD5Yw4DtgU
         rYSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW3sXL+jGYeyRGC+uuHxkjee8pdC3Kb0XTCTX1cYtrCFp751U6P
	YsMTPK/V1Xqml4dWJPLGJljkBnOr8Pnu6+94XWWe1JxhuuYMaB6hgYiS8qCrNdPzydTHxUX363y
	NdhXw2EWNMd51ukjnxyL6D0B1hEdtfgjGhIV1qDl0rspAh5y2pN++EekIIKZDVkWXvg==
X-Received: by 2002:a1c:8017:: with SMTP id b23mr3275558wmd.117.1564734753150;
        Fri, 02 Aug 2019 01:32:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Xij5/BP3kBulZgvzjp3GUnxIsON7RrcjlrKmo4rD+mCOmf+jL5YK4d6Th5cT+5yRbzD8
X-Received: by 2002:a1c:8017:: with SMTP id b23mr3275479wmd.117.1564734752412;
        Fri, 02 Aug 2019 01:32:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564734752; cv=none;
        d=google.com; s=arc-20160816;
        b=PEMEdCKMQuvSS6EIiK/nFPraW9xMRL1J/IgySDgkJIrbi4/1ZyVHtktp9LrIKP+wJy
         hV5MedY11df+MRrxh2SDsPpKuWT8lGj4ecAJpl0s6+CBqtCtW0aqZ4AtbbluIeLevO0+
         7Y+JCKihS8crATYg6UXQt+TTVelCOq5O8Dh2qrKm1dcYwA8qwvOZ1hnHHFWpU5jPWzjD
         cK8me2Ac/psR1doZxY7AbRimGWjB7Wv7aFBUm3jhweu+2xuuDKADYNpJnIPvO2A1QLXY
         BMk9reqBo2PMuDdqnfLFiKNLIaZT0UI58zopWNCC0U8FfSDEK4GWTym1zZJnwPnNNcsz
         bq1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RX+XrhTRDThahj9YMbo2fzyu5amiqvcFL1ThmTcPgvw=;
        b=gGfyAJuf3BJtYc41CAKaEXUmiSAjtrgPWUr9RnbVJdhGioGbNfC/xkf33nwJqcpCvd
         6s+2uX32Ix8dA/QLBhizKzswkmoTP7rxE+STRjbqhmGHoI3RO804k+w9D8NzOoJsW704
         i7KhXES8kX8Ytdb0aO2f5wvtLuenqJwO1WTdU20prsWpywaV4zulyVrARcfT2n9+ugQ3
         umZxHukReYCKPDFsIuIuLVBQ7CXa3MT7WOZy7Rqp68kkK0oUNsKh+jaAb3/l+yCCTz7E
         0YYCxn1WgSA3LRHK+Pd5alaJemZdq+/Lwfdq7wnF9rmcTAMtg/WYjJy/vfpuXUnWc1kV
         eDRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id x185si55098082wmb.21.2019.08.02.01.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:32:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 86EAE68C7B; Fri,  2 Aug 2019 10:32:30 +0200 (CEST)
Date: Fri, 2 Aug 2019 10:32:30 +0200
From: Christoph Hellwig <hch@lst.de>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] memremap: move from kernel/ to mm/
Message-ID: <20190802083230.GB11000@lst.de>
References: <20190722094143.18387-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722094143.18387-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

I've seen you've queued this up in -mm, but the explicit intent here was
to quickly merge this after -rc1 so that the move doesn't conflict with
further development for 5.3.  Any chance you could send this patch on
to Linus?

