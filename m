Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DATE_IN_PAST_96_XX,
	DKIM_SIGNED,DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12F37C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A808320879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:12:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="lUTXZ4qQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A808320879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F28D26B0003; Tue, 14 May 2019 09:12:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED8F46B0006; Tue, 14 May 2019 09:12:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC9E36B0007; Tue, 14 May 2019 09:12:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B48946B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:12:33 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id cc5so2772102plb.12
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:12:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EXvwjH8J7gR03XDOUnXnK06PZXxN4QU5QUZcmQAB43c=;
        b=opa6ACJb3HbB5KLWcP2zrmaPHZIxdRSKekV+Y+dxyKYeX7fdC/DLsuo0sr0or7oMwI
         QbAiomfvHtuds+znMsKs2bmJlgRJxpUOEqzpwuRrL7YlQJ1n2c445TC86+43uaX3xUVc
         wPR6IuiwWBtzom2AdN3C1HbUkAdKOiTqMZJXS4IkVIkV2SKbvB6LT516gvBvp6h4/fgg
         kSxNq4L5L//4ZwGFrOxbIBf3JZ53D4Isd03WXC1SZN8lVQ+vs0ayrED5jaRaW3+WwX+t
         b5phjJq9+PHuLv3SQF/sDnHQnPa+UcetXTONdISfJPhW4JXk4sKS4dkrdBRxVUoa9d9l
         cfhQ==
X-Gm-Message-State: APjAAAWwtf8jdlHkOLJamtSSq8plNCTWYEV6Zba4t7XyixrBKb0C8800
	JecHqD0eSroZZVvGH6+YLhzys+F+UDX9yiXP49Uak+LpTNlQZ8hoSI49DJUVFUczfKgwl5fT0hq
	TXQpVQtCvXdiWeeRgDlKnHaUuJzHx4X5UcnstAJ4U2XirnCbrj6dubQtIBZsOYftYoQ==
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr14427759pld.214.1557839553169;
        Tue, 14 May 2019 06:12:33 -0700 (PDT)
X-Received: by 2002:a17:902:4283:: with SMTP id h3mr14427684pld.214.1557839552331;
        Tue, 14 May 2019 06:12:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557839552; cv=none;
        d=google.com; s=arc-20160816;
        b=YIxsFStA7BZWCCuyxV5K1tHTgUakz4zdXiIpbMQ+EfXmCbhhoxIXQuYPTbh60CxAZ3
         GJrOYGOfl2IwbysSr6PImpDLqRa7fNekFWpt1nIDrX5xDIg6bWIjMMnR5BiowP4zp8b7
         ZTZfxbkgGypuUzd7Ch72tFYH0m+perBlRcM/fYQxFZOcNBrL0yfZ2ARL5fGVZvr8FUw4
         7ub1wpaC0J/2MdHdCLHGv1ORjFNU0Cil/YBGUmCmjyba52h9Y02N6zMcfkaVGDDPfi4T
         ZkqyrLGlvxxG92rEeTZaV9mS7oGqscATxJR24MHT+lIPB88wY7VmAGRxHFd0oo3RMabd
         XgJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EXvwjH8J7gR03XDOUnXnK06PZXxN4QU5QUZcmQAB43c=;
        b=CPZX+z0CkjY9I7puTZZApxZFMni8ym6tmthNpNs91B9TAJ+WZK8FYHMa2f7aimhTLI
         1ogvIFMDj9Ccpnn+UPE7pumaNrEqBpp5NFx1eMUSYrFHtxS4NvI03miRH+fCeZnO1hbX
         WjDATBsV8qecx84vMnkMRx+9AYjbj5WEccc+/1Yf7DiCyXb177GL0ormSwZoHUEBoL+n
         C6S5SdOQ55Fs2LDkEXRsYHSzTwq4kOiWefPcAMuhFVzIdA3BzxuS+vkcfybJNuwKKdyv
         /KwJoYlIX+llRk/QUkb+G6moAyzriov/4fSyUtQmc7P7o5Gr4wQgVkW4Xe40rQxv9kML
         bP+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lUTXZ4qQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor8694999plz.51.2019.05.14.06.12.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:12:32 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=lUTXZ4qQ;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EXvwjH8J7gR03XDOUnXnK06PZXxN4QU5QUZcmQAB43c=;
        b=lUTXZ4qQo5hTI4dlRn8YXiRzaJq+gLzy3oSwSvRnk5c8QgvtVYUgyLP8JhdrRb2D+F
         d1+c3wmWcp8bQ02LGsGbFy7JwdvjwPE9NNtmv6S2Uy75+yn9HwnBb1qA8w+z8040vGa7
         Wzmf9na9GvuGmsBvxwl021zhJMo8p7L6QvdCdYQPitcZfGzlOr9ao8u2OY8CC/+VPThd
         /kUm/oAOeQoQBZwwlTtquyH0o0IrG1MK/n91+ks6aOjWa2krpkMBclfyDur17H/t2De2
         J2Yhg4jTqC/C2Lyel26tunEXAtk/gEO0T9ExjPCS2Rwj6a64OMYU1Crz4BeYmhODaqtj
         kzTQ==
X-Google-Smtp-Source: APXvYqziVHNedLBivvFWoZMf2SJUhhrgEI7kSCOL3IuoLknH2I3QFX1Q1B+J8WKd1SZSVNOfEoGmxw==
X-Received: by 2002:a17:902:2907:: with SMTP id g7mr13087380plb.114.1557839551531;
        Tue, 14 May 2019 06:12:31 -0700 (PDT)
Received: from box.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id i188sm16116807pfe.160.2019.05.14.06.12.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 06:12:30 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 00C64100C34; Thu,  9 May 2019 13:55:15 +0300 (+03)
Date: Thu, 9 May 2019 13:55:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH 01/11] fix function alignment
Message-ID: <20190509105515.rq7mcnb5jjunq2gq@box>
References: <20190507040609.21746-1-willy@infradead.org>
 <20190507040609.21746-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507040609.21746-2-willy@infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 09:05:59PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 

Hm?

-ENOENT;

