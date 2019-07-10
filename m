Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42AF0C73C64
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 12:26:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E64EE2064B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 12:26:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Hd33JvtV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E64EE2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95AD38E0073; Wed, 10 Jul 2019 08:26:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3048E0032; Wed, 10 Jul 2019 08:26:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 783F58E0073; Wed, 10 Jul 2019 08:26:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB988E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 08:26:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 30so1364204pgk.16
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 05:26:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oFDADlC2ju9lttZIwCvIydgfwE/7qWdsHDo+YyNGXHQ=;
        b=aga7RE4DB0B1l5lNU/5vkwfpA69R4mg8PUUq57eWATGG982hT9xuqwo8yUkCz52t41
         LVLpJ7nWhUgb7PjrzsYK3zcYPqAfz5XG/fUUOjgdrvcQTC0GA1qt/ivIn9OsiqEA43OJ
         2NFMNTRgSpq9BKGTbp51dxG6YUfLW4ChLurTJ7c1FJz36+bqNdYlPq/qS56+TCydHf7r
         N4dZOxEcOPzbDoioVCs+/k433QDafJnkIVit2JY7j1615vSIEAW29Xa7kvRxpLOdJCxx
         6DFbQkqYeXY1a/jSI47WXPNSUaP2rhp4ncgpThfnmPQyYE5v/tAt4A00IAcQrPJ4kzh6
         pYlA==
X-Gm-Message-State: APjAAAVgaUHaFz168m82MQFDARWlLf4jqOmB2vO0VPLmiqozWi6kCZb6
	fH7NulLMbOu7Q8fy0dklDqqQqFKwFB6QJCH23KuSS8CQnsh/okHRxLHlWbJ++Csv9w3BqqWoeD1
	eZyqH93weBzftGB6kbxdZ8js4viSxk3iBg9JHmmy1mB2cHW1PobMY4WZtryqXrILkIg==
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr37154985plw.13.1562761565746;
        Wed, 10 Jul 2019 05:26:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9XybD+CSWzkrXDhuiWJ6dMArOY5CykbM1PZ+mSc6s/FVN6uYGrPGH+qO3tHIK8IbvuFUS
X-Received: by 2002:a17:902:e65:: with SMTP id 92mr37154922plw.13.1562761564999;
        Wed, 10 Jul 2019 05:26:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562761564; cv=none;
        d=google.com; s=arc-20160816;
        b=ip8ZSR4iSjwKbaDY0KkyPieVj+3geKtI9VdLZz2lwIxh+nt5dWMYsSkqqUg4TxX/1Z
         rH/E8TIB3E8u8Y8D3H3oVkKzRFbTFGzSks0J+baJrpSuvrDWOdJJ7nyFuktYUfOoCa/W
         EaMNvOg+vQzv3s3KI4SDdP8SftlNM/dpz2o9cfAtORhLBXdyOPIGHixwBzP9txYzecpF
         ZoNuIyduZbHuyBJctc8IFibaNz5XwTOUwvyZx7SHVbQ5o6H2sBZSdo5EeTkRteVbJt46
         gA+c0KU1rZOk9HZUE5PjnBIQg4MWgGVtAVS0fTCzC/7Az9VM4Qox44ouo2W29krecxUO
         0Z5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oFDADlC2ju9lttZIwCvIydgfwE/7qWdsHDo+YyNGXHQ=;
        b=EFJ+yDTuawjGT9AI0BM1yM3Oqmmf1fZoVLyBIPO+kHfYqoECFdHHZisLSFYGg+7xqe
         4LJ2bDYiNfSrwvb3C6V1Y2Gm/WFVdDcpoLsV0Yt3aTB+Zgks96oL6fERejlBHA34Q3iQ
         Pfmdg1RiRVvlgcGlxJQc2NFjj9gtL665zZuvMVJ+wnssIuQLEeFMYPeJd7qC7jo5sp0H
         ywV4bhz74rktrgUaYijR2wUzx8pP1eawexVvC1R8zYMA5UDQ31ot37gr0sxorC/03sp6
         K+SzRDP7P8FHn/TvSQEJuIkBdKra/co8wPdCgTe9ZKgFJQPkq7ryiI3c1RckIM9m4VWx
         YGOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Hd33JvtV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 61si2050196plq.157.2019.07.10.05.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 05:26:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Hd33JvtV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oFDADlC2ju9lttZIwCvIydgfwE/7qWdsHDo+YyNGXHQ=; b=Hd33JvtV6D0Lc+VAeX5f7BDSn
	DZPLB9IpmgMoQ3Lz8zUyiAN5/zX9A0sNVbPwDE+xK5B/XKkN81SSua4C8fuNGp+KsgHdqzv5+hvIt
	MBaMBQ4Zl1TaYR+Vz5fEp3AVfb5neEc7+w77ThFjsJP4C4HuvrBajIohm2dAwiRpDYcalsd/djy0l
	Gh6+B4+dszsX4ysMUMj9uYe2TuiE7ds8mc5z5QMwcz5wo7xMuijMmx6jhlnc2lTbyGBqrgVCGnGEe
	5GHn/aOGvSwJjE8dNeZAHQSUHKsC2Hl0rpMZcS083Ck63zVetnxtnUvi0vf9l//1nAp27AfELFA1P
	S27fnLbXA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hlBfR-000675-Kh; Wed, 10 Jul 2019 12:25:49 +0000
Date: Wed, 10 Jul 2019 05:25:49 -0700
From: Matthew Wilcox <willy@infradead.org>
To: bsauce <bsauce00@gmail.com>
Cc: alexander.h.duyck@intel.com, vbabka@suse.cz, mgorman@suse.de,
	l.stach@pengutronix.de, vdavydov.dev@gmail.com,
	akpm@linux-foundation.org, alex@ghiti.fr, adobriyan@gmail.com,
	mike.kravetz@oracle.com, rientjes@google.com,
	rppt@linux.vnet.ibm.com, mhocko@suse.com, ksspiers@google.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fs/seq_file.c: Fix a UAF vulnerability in seq_release()
Message-ID: <20190710122549.GM32320@bombadil.infradead.org>
References: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562754389-29217-1-git-send-email-bsauce00@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 06:26:29PM +0800, bsauce wrote:
> In seq_release(), 'm->buf' points to a chunk. It is freed but not cleared to null right away. It can be reused by seq_read() or srm_env_proc_write().

Well, no.  The ->release method is called when there are no more file
descriptors referring to this file.  So there's no way to call seq_read()
or srm_env_proc_write() after seq_release() is called.

> For example, /arch/alpha/kernel/srm_env.c provide several interfaces to userspace, like 'single_release', 'seq_read' and 'srm_env_proc_write'.
> Thus in userspace, one can exploit this UAF vulnerability to escape privilege.

Please provide a PoC.

