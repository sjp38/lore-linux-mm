Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71D71C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38AD121927
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:04:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38AD121927
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9FB78E0002; Thu, 14 Feb 2019 12:04:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C4EC08E0001; Thu, 14 Feb 2019 12:04:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4DD08E0002; Thu, 14 Feb 2019 12:04:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 730638E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:04:18 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id q126so2367802wme.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:04:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7zSfffeno1mkkf8zl8gV2WyGhl7w1qzEMvLhs8wkDFE=;
        b=hO26ESSaEJl3DmmSocPRfZBs4WDzM0tFIef0iOW/D/UuSjxvRwnTpPYGC5MssJg5gU
         2n5/Kak28sFDnI1WZCetWR7+6MP12t5to5ObR1klffCG3mOJTBFCO8qvqQXa7hIxxpcA
         ZLD7aHI2AlAhOz2BW9tQD6Ynux+AqRY7MOoBV+Z4/bRab6yhyjAuL5ww9vtBBwlsxev7
         /9ESFIqqypKJqDoVFzsFNwiAyQIvIt8Xk7EUH1yVdXb8tSEjq4efiJpTQaxiSHQYPQZy
         rYRWP1gJfbftCyjf1dJv1WZILORHnUHQTH6bg8LOrxWPulQDfBUcjxre/PZ9RbNHEiG7
         BgRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYZn8mNQTd3tBGsqDJNo9gX9jCjX4BAx4uQ1OfYfF6J+4XaeNq8
	fXYmTVIrQPGMS4Zu5WHu7bG7wCl41BjYfUVHvoqVEFWJuz697DsUTFShRc25ps1ALZr3adbhzQX
	Kd4LhLjuoQg4N9Vt2FPiLa6hg+4t3qekotoRTNkWewyPygSTZh/sVnXVSyaG/Jey7sw==
X-Received: by 2002:a5d:434c:: with SMTP id u12mr3707357wrr.14.1550163857972;
        Thu, 14 Feb 2019 09:04:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbM9TEM7wUC+9FekJlnRqC7DTO+rBhn3zk45yhttIKNtT+W/qHY09LNc7A81L4ypYdzEqm1
X-Received: by 2002:a5d:434c:: with SMTP id u12mr3707312wrr.14.1550163857245;
        Thu, 14 Feb 2019 09:04:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550163857; cv=none;
        d=google.com; s=arc-20160816;
        b=MUqtLJe+qysUkkEG7M240nxeAbwEfDp2RGSwQksWdGhbPoDZAAvH94/3pB6pnWTavM
         MANZ5NZx6I+nZY9xunV/50uXyFbaEcQw+0BeEhpwDHqg9dEdM1OysDSQTwHdbKqKXp3D
         3ZGAQy9JVF/tq19MJtJ8/jFNPbOWgxaWheLlVvDDEi04ZdG0wCB+XLDvYHw0E9JZaYjw
         6/CY5vmEuuUek26XG7W3k/sN4yIXiZaIxHgv+TIP2jh1oxpYpj740EPj8xxpJKD8GH0X
         twaN87xFf4H3z73+lflni/CYLwPJp1jnQEE7ChIN7lGBLAe5L14gxZ6mlSTigG70yt2Q
         cNkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7zSfffeno1mkkf8zl8gV2WyGhl7w1qzEMvLhs8wkDFE=;
        b=Fdsf6J0/1V4rtDsSClbFJNXHfIV5UThzpr+gQSV1TRYH9FjXXOGn4PklE/F3zdjmZ0
         W4tr3BOQ0CbNfRgm1w7tfnagu4+FuhAVMA850BkmPhsAUhM2I1pmOGVbAS4mUlwkmP+B
         TrwnEi1OSfE7i0/ksFJ7yfUQ2No+P2MVF5DOmIFVLe+ExW6GdD+sEl6X+32QC/vQOWAY
         f4iwR//vK1KtBT3KvQ1v+bCiPTN5yFAuXI4s+0fXF9ROsYH+EYoMAOJQVxZ3gquWMi6q
         agtNQxSIcFe0Yb+ODlFIRBHP2L7ARCbj6DoLi23R3rqVCQDJBaHACG4t6Bd0yE3Oi3Ea
         /SfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f15si2135435wrh.240.2019.02.14.09.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:04:17 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 900266FA8C; Thu, 14 Feb 2019 18:04:16 +0100 (CET)
Date: Thu, 14 Feb 2019 18:04:16 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
	Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
	linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-riscv@lists.infradead.org
Subject: Re: [PATCH 0/4] provide a generic free_initmem implementation
Message-ID: <20190214170416.GA32441@lst.de>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This look fine to me, but I'm a little worried that as-is this will
just create conflicts with my series..

