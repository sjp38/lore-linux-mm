Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2409C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97C9E24A8F
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 07:20:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jyc9jUmp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97C9E24A8F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45ACA6B000A; Tue,  4 Jun 2019 03:20:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 413096B0269; Tue,  4 Jun 2019 03:20:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F8D16B026A; Tue,  4 Jun 2019 03:20:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 102F16B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 03:20:23 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id i133so15826173ioa.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 00:20:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zcQ0XCzyOuqSZq43SdsbTL7y6bYo0YRJAf0OBu/R2Gg=;
        b=F+MDmT+S/7j9v9dpZVzqH/zWpnG1e0C1RV33eMXRqNwAstfyXh6PYD4q9FrD8QflGM
         WWjwc2dltbYVbPU7G4kJNYLUEmQ22AyDLORqg/0rk4zxNegvPCXXR17kXqPKR3BZtJQS
         aVkgupBwSQ86uioIIHdEw1oEX7jGt1g3G6S7Gu/VCIuf9/dGJ2hiBDXZd6uQmCF4wMQY
         lWOdZq07KX4zNCDtIQDWQb+HhuI3WvLhnzlNsnSWTa9IrQXm6r3f5JFsMTNj0MKPs7lM
         pS+ywlLbLBy5bGzTFyb7vWkK3uqTu9CAreRNalTt80UQwvs8XHcBxiikuqeYI7kYX0CV
         JDag==
X-Gm-Message-State: APjAAAXtQbJ4fhfL5/uCoDIAG4yvHWj2BOVI8ia0/7Um90hhaRWe3ye/
	RYbI1GwD4aGw1DlU8gep5yl4pTQstfsNR8xRaKp2bPx21N7URnVxFvhETDJyZL5C/q2cAlbDKu1
	zkxM85d2wi/vjrUiaPw3O683TJyNaeOn19oZb72ttJlnDWv5MGNQKuxLWYa2xHruOpA==
X-Received: by 2002:a5d:9352:: with SMTP id i18mr19805172ioo.177.1559632822810;
        Tue, 04 Jun 2019 00:20:22 -0700 (PDT)
X-Received: by 2002:a5d:9352:: with SMTP id i18mr19805136ioo.177.1559632822238;
        Tue, 04 Jun 2019 00:20:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559632822; cv=none;
        d=google.com; s=arc-20160816;
        b=S+Y3McSC2SniUSe4Q8V06GZCJTEFtIm5mXTOZ3GEu0irMuibbtpwyz8HoOWwoWlrP8
         Iw8lx0t3pDsK+MkFQE9Ki+HFdR9JipV/6tmhKe2aHuOddU0NskOx/eZfs/OadvvSBedL
         XNSqRMorxceLmuwZayqYl+39plh17TLvLoPzrVrmRCwdsXXK+JzgSxvectigu6hpafkP
         D1C9MkrCXtjcKzF3mobIK2O5T1DBz2UfgM6dBSAUU+R5uDEvIBRj3k+XiWG2eseIl7oP
         Q0K2LZ/wll3SjLZ2dtB4JG4qx9Em3LnhUEmpP9tziJX8oMrQ5Cm/tlHkmIq8xdtl1jTN
         o5cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zcQ0XCzyOuqSZq43SdsbTL7y6bYo0YRJAf0OBu/R2Gg=;
        b=IwKt+Zi48dJTZIFQsQvwYTtSrjtW09D0bfTYsmJGuY4/VzOaLNxPffpGnrjRIfS9o8
         vpFWPK4Fj3P3w2F00CgJigzwvED7FBMXjGbQZFELDFrxHldDPCsY/j1+5hfla23GIZD1
         /+BsFFXT6UQYUle4ZO3T9NkkJwgopNfuCJoum3smgF1Bs7QN6EbtOcgmHL4cqd5LTn8W
         C3qvJzm0o0lCi20qNPyfoggHP3YfsVhVqOqskH10ta/yyxKxRHAjhsizZUt//wKsLPvG
         ZxtY1TEMjrfaC9EA53uKHtr3yowHEMc6OTqQ3lYoypMsUf2FMPYcjmfLpzCRwEiSRqBp
         eqIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jyc9jUmp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z203sor5560878itb.28.2019.06.04.00.20.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 00:20:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jyc9jUmp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zcQ0XCzyOuqSZq43SdsbTL7y6bYo0YRJAf0OBu/R2Gg=;
        b=jyc9jUmpnUgySHIKHOeizGxOD/ZSfhC9wTdSu9qr9XzcBxRDi3Wr8XHsdbph8QTBbd
         LQwPzHbnOuFogbzM8Dqb5yomDHmc8kyRkkAQaXUPCLuNcvBzGIht8u2owaX0Rp7wQvcH
         eXwwsTxdr8yrJ53YxILX1l/GgczfQi2loVe4WmtU07Awj37BNVnOPd20+FtrVDbBiRji
         LAws27Q5LwJN3ayHMA0qMwWiyMNdoGoavABtZ5LMHQCkdFS7sCdnW1NRPAtVYbFIQBG5
         toX6s/OLGXz2txpUw2n+HJWlm8RJXuVkIisW5fCBWtLIDk07nFEy2nFtaw6G8BvdMXsy
         GV3g==
X-Google-Smtp-Source: APXvYqwM9oK0yxIHGRN26q+wez3poxvIpKgP7P1vb0fH/ZVDzSvi9jMULHR3irpgfqNRNQT1Aovt0C0qpmXujcKGpRs=
X-Received: by 2002:a24:30d2:: with SMTP id q201mr12259268itq.100.1559632822036;
 Tue, 04 Jun 2019 00:20:22 -0700 (PDT)
MIME-Version: 1.0
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org> <CAFgQCTtUdeq=M=SrVwvggR15Yk+i=ndLkhkw1dxJa7miuDp_AA@mail.gmail.com>
 <20190604071731.GA10044@infradead.org>
In-Reply-To: <20190604071731.GA10044@infradead.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 4 Jun 2019 15:20:10 +0800
Message-ID: <CAFgQCTt1ggP6-_XSDyG7aqw-mg4-zSA6ZNQRb+ep8HkDqAikug@mail.gmail.com>
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	John Hubbard <jhubbard@nvidia.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Keith Busch <keith.busch@intel.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 3:17 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Tue, Jun 04, 2019 at 03:13:21PM +0800, Pingfan Liu wrote:
> > Is it a convention? scripts/checkpatch.pl can not detect it. Could you
> > show me some light so later I can avoid it?
>
> If you look at most kernel code you can see two conventions:
>
>  - double tabe indent
>  - indent to the start of the first agument line
>
> Everything else is rather unusual.
OK.
Thanks

