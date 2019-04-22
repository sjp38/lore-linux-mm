Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28143C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:56:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D81A4204EC
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:56:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D81A4204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83A466B0274; Mon, 22 Apr 2019 15:56:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E96E6B0275; Mon, 22 Apr 2019 15:56:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B1DC6B0276; Mon, 22 Apr 2019 15:56:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E34F6B0274
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:56:53 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b12so482825wmj.0
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:56:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=W+apRcsrFc4+lG2jgQ85petICsz0fGJV6mCARZXILGD94gPL/CgHVxWKvRjP9hyGyR
         apu/gyHmHx0ThppokIYBsBdDZxozIlA5EMPjcX2NUJHZDxFJ8EqZxbeNczNlacigc2HF
         lNZcvyRlepEUPrLofmCyBT6aqgEO1mOURq3NOYsWojXQlpHxozOx303aXNnLLHZTnWfB
         MbQ2t3p+UhZg94ZsDHP8EL5bBRAM1yC5K1ZKmb/fuNRTyYNUBWnhxT2Hel76YmHWWa9h
         WVPMwOT8ZwS2UwkL4Ii7bzpfV6aNljYexlTcFixjHDDLHigY/yUkUaAVjoZl4HDvwCXk
         K4nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUOJ0XIYP+1WofQlC8ymh2Bz6MYQC2ZkcuUcq+fjbK37C0mXs7R
	qSOOVhkZGfHY5hqYhVolbrsQJSMN8oYbzUDH1YIf49U8+ep0FkOYEXBMVduWyDY9qryo2fdaRD+
	ioPmtZ+fATixdtfkT5bJbb2g18tzfuUHNy/SwIjNtpyhP+dVKj6QsRBuxUixhhU6p1A==
X-Received: by 2002:a5d:4a4f:: with SMTP id v15mr13545569wrs.5.1555963012760;
        Mon, 22 Apr 2019 12:56:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdOsntWzmGJXubjYi29AOtXQKxZk9iX8EdO86Fmg8M9mofud5dNjpDsHqeo5ffGgK0pDuM
X-Received: by 2002:a5d:4a4f:: with SMTP id v15mr13545547wrs.5.1555963012223;
        Mon, 22 Apr 2019 12:56:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555963012; cv=none;
        d=google.com; s=arc-20160816;
        b=XbCpZ+E+8uwctqFEX8cYt/JQ1WsrOBvqol2Tpz8nPbok7tl1qVUaxMIxhgd6aNxJay
         vmXBBPhWsRjaSf/KKFxIvTNxfBhgr+OfzY0JRMUzVfBdO+zYPW4k5Rjnh/YfRI9JV8Y1
         u2oGAw1ixsRRhkHTYk5C4fR+PJQla3jm4X9c5GmIOQaxJWyv/OXWYOD9GzH8MUBrBlpz
         Aag0Lx+zBNCwTF/ot07SIJaPjmsCCZ8nSyDtnSh26wiBVHjbcE0VzGwqTc+fFOc/BKXq
         NL5jgSO7lzDRXVhdncvvfnGoDNUTJj8oMNYjasfQQMitPR20aGVWYYSWfSMsH8UflDQU
         k/iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=KjVW7myLGEvji61m6LoQ1zFBpAi/UyYIE6LG+ZdwugN/C16JffzbL4Qe6mumZjLX55
         DKfuPXJOnNdtFT9Y19KkJwQwrSnp5MhKj2LtStkiZfT+0iFgwQACcjezvJvJ+YSIqdkW
         nwW2XLalR35F4hkdwJRaATZLFumcV5J+GgbCf7uJZPID3BkrYeITjWwQIT7yXN5YRcEq
         eLaYf41ySikMPemIBLi2W6uMH1kHwAmtTd6ndm0lLob3LbvQmL8evZMHYIFxh/GsIwus
         G3tCu6XA2+IoIaD+TfjOaanLRWxUTPotk0ghHJ6N2+rXvyo9xnaffOvX1AuuYejWNj2/
         Uhug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n8si10344845wrp.138.2019.04.22.12.56.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:56:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 6446E68AFE; Mon, 22 Apr 2019 21:56:38 +0200 (CEST)
Date: Mon, 22 Apr 2019 21:56:38 +0200
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
Subject: Re: [PATCH v3 11/11] riscv: Make mmap allocation top-down by
 default
Message-ID: <20190422195638.GE2224@lst.de>
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-12-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417052247.17809-12-alex@ghiti.fr>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

