Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44C64C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08A38217D4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:55:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JvXeNVjE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08A38217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9DE8E016E; Fri, 12 Jul 2019 19:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85BC98E0003; Fri, 12 Jul 2019 19:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB128E016E; Fri, 12 Jul 2019 19:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 373E48E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 19:55:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a20so6445931pfn.19
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:subject
         :in-reply-to:references:message-id;
        bh=mXR50l6JwVfmjKcZ1LjJAH1JcCPMfD6shGgoUipAO5w=;
        b=XuA3looz7GCrYjbhSuN7Nl1qv+NQLaMUfO9ZiyedJwNGbu2Fbzjd1/+NuzGfIndCIJ
         4Jmryuw3+gKXC5QgUESTqIB1e8q4zcSHKODrLaFu2ZBqVM3F/0ilBzsv3NgeKIR5U9+d
         mG1jAUZ/HF1LVCOjhiufZrPE7mnfpB1s253MfRQRZP4YLVezBYeNNKOxzaNcmqIOUy49
         wU9DBYcEJZcKzq0VFtV/dkBafzSCrH4ITi5L7ZQTsz1JR89k0rUhEjDgYVnzMwKT/Qk/
         7SL7rz8QYKCoTHexljrdY9MmZczmZccgQawu4EfZu44EWdktf/W6yqU2seaycGsiaRLS
         Jn3Q==
X-Gm-Message-State: APjAAAXh4eweRTxUV26NUGTJTxP0fJf1e1x3otDoLP9acm60qbZ/Uwj7
	rr32h89ZJDmSQd5IUQS+CWo+4ZiL+PPjSXVrR7Y1ZF4Tcql3HosGpHLs5T5kmJNEYJ3/NasZMRj
	Y/F4/kxdmtDMO80DULoNhvvEBVJ8ZpOmhVpdSLBqOAZFSpgKeLpjWO5slhGqBr2AeCw==
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr14269585plb.114.1562975726857;
        Fri, 12 Jul 2019 16:55:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDXQo2MrOUdw6L3QTXikKLQT3DBXdcTUfcskQTrRTtcxDL7lLNIMtGvjtvDvVFeL5eErJw
X-Received: by 2002:a17:902:28e9:: with SMTP id f96mr14269534plb.114.1562975726166;
        Fri, 12 Jul 2019 16:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562975726; cv=none;
        d=google.com; s=arc-20160816;
        b=ES/dKr2dYvPVcq2YUo/Lihr0IYdsotEVLk7og7MvMX1iN5YlVRt4btXTarjVTga8Up
         EsdAt3zDzNrt7O7gHcxcFp9GsTAuUuKciLiMQAyF7N1MDZwrGZ2DU8AqkiYRzuzuI8nx
         fEvJ04BdvHifr+1kCEvwE8jZLw0R2t76MK7qYJDMB4lQMtyoP3iftJIatx6iOzdk5hwZ
         7bj4Nwit+hKhZx7QUmmlOjpPev35PnUNHVOuzbiodD0YFvRBOMlSsICxvZYJltzIIEmj
         NfK03TflOfGiR2sVSi7rQXSIfYwK3y+Jj2ZYmAEoHS6O7T2+0/G/iNeLdCR8cw6Im3jO
         18FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:to:to:to:from:date
         :dkim-signature;
        bh=mXR50l6JwVfmjKcZ1LjJAH1JcCPMfD6shGgoUipAO5w=;
        b=UeOupKTkhwajrchwj/932qqYU7gqUOvyPOL1zOkm3TuiGko8euu4np8DyGm2RutUoP
         uiAo/wJIm/LllHVAvMnlNICZgYGJNoG9Pwb5PIFPBsFl7uQExe22A8KhFY/45rigbTvx
         BK7wFF5BoR0OWbEHp0kWJNbcKfCO4J5es/2Onpj2Ty7MiD9p3RYHjP1dkzIuas2re+kf
         oBBSmlk5MDTUbdXVMuI8gho9zyvlnE77yWTeoA0+IqsXaoh22kknfDpCMjgOS51RSbXH
         58fK4wVQznrb9zPeBlPzVh1IzuK4gzQu8WzHe1nMpxhyZX1PRlYDng610ojfo5WKlTEu
         40Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JvXeNVjE;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y70si9937780pfg.184.2019.07.12.16.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 16:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JvXeNVjE;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A145520874;
	Fri, 12 Jul 2019 23:55:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562975725;
	bh=VJEu58fg8OVV+ACQemp+G/XZGGo3QRimEqLYSfOYpuk=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
	b=JvXeNVjEMjH/hHoHWU2c4F49D1EpeeHsT4hqo6IUWwhSD6AgBgHkCskwY8sDEvtrJ
	 Oq6Qc/7DKksPojRlzqqct4SVzCk3fapv52htmNK5RG8AzQZ83APf4P59smj6tDyKen
	 XAzHUHFKvMVC7SYw75KIBgIRsAG+if1iUH9Z8kRc=
Date: Fri, 12 Jul 2019 23:55:24 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
In-Reply-To: <20190711140012.1671-2-jack@suse.cz>
References: <20190711140012.1671-2-jack@suse.cz>
Message-Id: <20190712235525.A145520874@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.2, v5.1.17, v4.19.58, v4.14.133, v4.9.185, v4.4.185.

v5.2: Build OK!
v5.1.17: Build OK!
v4.19.58: Build OK!
v4.14.133: Build failed! Errors:
    mm/madvise.c:314:2: error: implicit declaration of function ‘vfs_fadvise’; did you mean ‘sys_madvise’? [-Werror=implicit-function-declaration]

v4.9.185: Build failed! Errors:
    mm/madvise.c:266:2: error: implicit declaration of function ‘vfs_fadvise’; did you mean ‘sys_madvise’? [-Werror=implicit-function-declaration]

v4.4.185: Build failed! Errors:
    mm/madvise.c:261:2: error: implicit declaration of function ‘vfs_fadvise’; did you mean ‘sys_madvise’? [-Werror=implicit-function-declaration]


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

