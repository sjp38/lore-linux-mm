Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3E0AC46470
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 09:05:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D5B121707
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 09:05:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D5B121707
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA62E6B0010; Sat,  1 Jun 2019 05:05:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D58BD6B0266; Sat,  1 Jun 2019 05:05:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C44C86B0269; Sat,  1 Jun 2019 05:05:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7506B0010
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 05:05:03 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i2so5206638wrp.12
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 02:05:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=IADaInJrVv/oTpHiw3xxIPQ766Jb32uMKAbaXh1a/0rFNA6JUgbnjpUEhxPcEcJbeb
         cPp9CAOdTvkKiVnIl97/ZSsCd8JjjAwaFEsA/u/ZESu7T2xeeRw4QP/WMY300pueO9kI
         /oB04JrXHGnz3KIkY/pckQdr+UsQiFrPY8a9xhdYSrWFPskkCVfJvMxrvzuUwD9UXmCB
         WXkvn7Js+uALNeXEyUN1++VxeBta6D8/C0/0jf54Cme3Dc6LPEBtxoUIlv2cg0XkNChN
         2J07wS05uPGWc3vXE6gDBuWjDhbuowBbd7ISzP0uTFMNCUdIpnRf49cDGsN3LxbVJ9Bz
         n94A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWX+UMUQBfzMSt2F7BhyApVvb94zBZqtZ9hhZ5Or4jji+4e7N3t
	6u06ORSMGwxsGEtcjyJAzO4dEEVEFLRxsLIQn48PIZZKE3ifCeVd27wulgSwvI5mwUN0WmnTva3
	OqBrcctSQDP8Nvq4i0ce2f85o3Kga5BEVJPvopxfC3HVvQOlNdFrXRrGvfLl9+9OBXg==
X-Received: by 2002:a05:600c:22cb:: with SMTP id 11mr8223250wmg.159.1559379903132;
        Sat, 01 Jun 2019 02:05:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxahfeDPYV5F4WDqBXuM/WieCZQ3G8LHrgifz9PF3tVbjiLGpA8jTSBN3E0YAHJw96sIBd3
X-Received: by 2002:a05:600c:22cb:: with SMTP id 11mr8223206wmg.159.1559379902158;
        Sat, 01 Jun 2019 02:05:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559379902; cv=none;
        d=google.com; s=arc-20160816;
        b=plT4Xj5CeVjEHqBHV4WFKhkRTNCrTCv3wVT31f++2a4gsL/bI/Eotlz3A0Ne4orn5o
         NY3C+WZW/di9Mijs3YyzrK6OXn24BTQzMgdT+3EzFrRpiwIB7BbiRDG0+MZGt7e5fI+k
         zRTiDRkYDzKG7YasQiy44wUJrrLtdcpKo/rLPhiGLeRAi8UqVTxQFNQQC9z1atCrpHN1
         CkoSZD7cxwx+On7zSIvcQsUMbzz05GBFnK7ZrEAK6iKrFjz0WUvyUPvQX6OL7/EwpbQm
         OAN0naJk0HmW16bjL5p24AM38EXOMWl0DoZ+4sZYUHCLZFgtkwruDEoK8eMUwoDXqSMH
         Z7JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=s75j4awiXzgtIm1YxqlGVpXNwOCj4DGaRT/e+1jWs7CZYGLO2dYo+fcRqObIZ+6x1R
         OZqrMA2PWrA7c411VZ8z/F4RJQLo2bvYryeNsp2IE7qtMeIGbjf48I95GuQYVZn0Hv0R
         IRixyvulHocS61gTSaVyWGuPx2m4u6uK09Bs1eViIBeK/wrAHo0f8fLCGi6qRG8a8ge0
         sar0qFBRbaP4FitIZLXwtMxTapgWtstDLtfT787EE6Zr/DLOftCbClgRHaLnfbOi18Sh
         UWQEKkIfhlZ0QPlZKZALliubWaTUSN8hGOIRspx4YVUjPhIE+qW+kzjoDRzdVbRBqDmi
         gJxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d63si5863497wmf.4.2019.06.01.02.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 02:05:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5A06068AFE; Sat,  1 Jun 2019 11:04:37 +0200 (CEST)
Date: Sat, 1 Jun 2019 11:04:37 +0200
From: Christoph Hellwig <hch@lst.de>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 05/14] arm64, mm: Make randomization selected by
 generic topdown mmap layout
Message-ID: <20190601090437.GF6453@lst.de>
References: <20190526134746.9315-1-alex@ghiti.fr> <20190526134746.9315-6-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-6-alex@ghiti.fr>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

