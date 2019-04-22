Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCAC4C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A04EE2075A
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 19:53:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A04EE2075A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 491506B026C; Mon, 22 Apr 2019 15:53:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4414F6B026D; Mon, 22 Apr 2019 15:53:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3311A6B026E; Mon, 22 Apr 2019 15:53:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F288C6B026C
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:53:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q16so12810037wrr.22
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 12:53:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8kGSz+tY92Is3cA66QifDz5Ng7liCQ5M7qpxf6bHXik=;
        b=K1Akj9DANCy5Gj1bFqtqiv68gP4HkkDQJYv0WZLIMgZX/ADDEskiifbkCOm5U7785O
         Y3Vi/8kkcvOkPi5tok6d+HoOfDL4ole0/ijZAU/mLs/vaxSM4ijN+wDZJ5iEe4+cqUKK
         7DJo8CaSv6YhpVVMWWFDWxEoRYzDnMegzKWFB9/pQReoawv2dY6uYXM/4Rl6eypNKjkE
         JtVixdKSzydrAnv8NSofiGgopUPXk5LsgKEY1wyCOS/PvuggrjcqR9QyQivtmTGx7UME
         GAfO74gDPvgTJ6XQNeIk1TUiB6yLxvbVIabqmBepOtmvKumoHvyP/u+s/u1+RfHe19XQ
         8nlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV6aPOZRHwf87ODNDDGczfptL/Ebu+05KV+mp3c8dIVIEtiUrMV
	leuc0G8Z8GYy4j4j5CZp6TIreKjZr8ktFLdOrTTxusniy1bdz+UWSE1dzZY8ByYx6pHI7wB4fIn
	eBGBLWaIlzekNcgGf5w2GHsq0GDkVEz6WWYrYewAA9oxevamj3ukb+dS12MwXIcrLeA==
X-Received: by 2002:a7b:ce1a:: with SMTP id m26mr12576079wmc.131.1555962838528;
        Mon, 22 Apr 2019 12:53:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnTWYrVtAjj17fQkmm6so5AcANc6ghqjuJKrFGgOxt45UTL5aCI2xvSSHSxi8n7E/k4bJM
X-Received: by 2002:a7b:ce1a:: with SMTP id m26mr12576051wmc.131.1555962837788;
        Mon, 22 Apr 2019 12:53:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555962837; cv=none;
        d=google.com; s=arc-20160816;
        b=BILdBiDNOgsK16Tenw4nw8aopF9mk4tkdLFAeFv1CUcfGh3qjxhXQGCqn1gi15E7HR
         zEQxtQsF56ek12j+l7wdUyTOeVVcw2HGwb48sOQttmz3/RBDZSTwDxJlfH09dR5hwUlF
         5hVt4BrgAr7nAfmP3Xh+Ic+3Ehk7JDNOrhQQHnCSmFk/6ZLcK5zxdnpxddJx0/4T/tob
         8h2AhQZmZdrjbGyo4xVKu7PX2Rt2JTn3cTVPclGukcAncAcHANJCms9/gMzXO1ztml6+
         hvoICCo3AZw5CmwzY4/t09/a1z79PDJtptDN+cxWBRrZZ7DiDEEm5LT7CAtWxgp3lEoO
         WsrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8kGSz+tY92Is3cA66QifDz5Ng7liCQ5M7qpxf6bHXik=;
        b=nn6buILAM+6MZC9t3okcBA+NNJ/O2waZpP/U3HzL63UHXZvBchLmvIlWFxzp+M9LbX
         eoC4T/z0x8RL+reupYmmPlwR44QI9rNFN5v1mq/J6AYIEJ0TUrnujtnuK4oHeO4SM5iv
         qbQ1DvPxDHf7ED+yDbeuIEMRfEnfp7t9WgUTtvM+gyopQM0cwsMPfdNyCEOPHyPnekI0
         xOjz9by/La87VOX1OCKS8IY42exl5Tx+q/b9UO1PQtULdzyIyUalIzYK0mBpIfmED8C4
         I6Alli3jaMckrXdAT7exsijAUq4AnBX+QH1IBmLQeUF0De+XUlvkZSYfYvmfzyINL/2O
         o7Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o131si9600841wma.30.2019.04.22.12.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 12:53:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 44CDD68B02; Mon, 22 Apr 2019 21:53:43 +0200 (CEST)
Date: Mon, 22 Apr 2019 21:53:41 +0200
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
Subject: Re: [PATCH v3 03/11] arm64: Consider stack randomization for mmap
 base only when necessary
Message-ID: <20190422195341.GB2224@lst.de>
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-4-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417052247.17809-4-alex@ghiti.fr>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 01:22:39AM -0400, Alexandre Ghiti wrote:
> Do not offset mmap base address because of stack randomization if
> current task does not want randomization.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

