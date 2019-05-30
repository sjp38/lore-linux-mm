Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63919C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:58:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 236DF25EE5
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:58:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="V8J8o0JH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 236DF25EE5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0E4D6B000E; Thu, 30 May 2019 13:58:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABF496B026D; Thu, 30 May 2019 13:58:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AF626B026E; Thu, 30 May 2019 13:58:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBCF6B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:58:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i3so4410688plb.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:58:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UdtCpjjQ91i6JdeO1o6cmQH2Jj5NVts/neyKdRuf9u0=;
        b=p2Lw1Ob9ccSdSuHJQ9puGxFUoGcu97eWYNrsygcmUpBlUp+uGrl6UrPQyvLmGeJ0Es
         TMmMLVhSV1GtogcvsGK+l/cRoM4RF9Gy4hmy81CBmbMmwH9rrNAP2CBiso8uR/mVspSX
         M8iKeFNTskeppaXDUwFjmp+HTmkedrGumNtO8A5fCX6GWb4HpSLcaYOQZ06oY/BzgTbE
         O/RZmXOhx45ChXFICILT7SqtWyAWU2uahMeBdTJTzy/pdYiDcAY7alV6kSy193+yl7pU
         klijV4lp2v9BXL0KsHhK8qvzvYPMcKQ/ATXtzX8CjSllqp0FSv5vjAQxENJ371o94iz7
         zeMA==
X-Gm-Message-State: APjAAAVC9O/Rzl9jpNa9q2R5Q0skrxdv5rpRvo+Ko/eVo0Ar2KOqflPy
	4Ao5VdAwCbEMNGXqQtuV0MtodW8Z25N0mUX18wB689EdjvENyAeLxdpq62Cdo9Q5osOjLItnmri
	vq6vdAn8v9OWwL3epO3O9si2dnb8e4lgJbhmBkJ0X0OY1daHqloKYMYnSGSR9cU8N3A==
X-Received: by 2002:a17:902:b695:: with SMTP id c21mr4736055pls.160.1559239085014;
        Thu, 30 May 2019 10:58:05 -0700 (PDT)
X-Received: by 2002:a17:902:b695:: with SMTP id c21mr4736026pls.160.1559239084341;
        Thu, 30 May 2019 10:58:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559239084; cv=none;
        d=google.com; s=arc-20160816;
        b=FmuBccP+1nt0OOqa1woauWH2EiNGjDr3c8wwV0Z5/MzQl09bVbiLTSZ7NYEfwFw9+I
         uQot5TQ14xCVDssrU2G0okhSitAK0+P2VuAaAcqRx0mywNgrcgZPTk2ioG4W7k5Ygs4i
         v4WOeYJQHvx6iKZiimgt+hVlT+/4Ho4oKxerFjOvmTmgtsjZVVm8hgN5izBjeHtLM0Jg
         Cpb+3Nrm5/X9nVwr1vHvgmv5M6PU/fvEfxe1+VP95FIH55oFw20lsPWGlyhUKwGYDMv2
         DkJ5pAMPrKT/GK5VBTe0mnCpBgr4NZi9OeEQ4N/3H/E9FUNpsI4XOQipT0LoIEiXapwp
         6PiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UdtCpjjQ91i6JdeO1o6cmQH2Jj5NVts/neyKdRuf9u0=;
        b=PCycpptAGHWluUzytLXazZ33u7M5ZfC5YayI8slsmY2AxwnCocSjUb1IQz43JaptaF
         tCmu+ljYjfMe54kl0UDT7/lh5PhPw9Jb9+igJxfR0QBlRpd4j65aJeiz1+RKJdoLrVTl
         kHs7Swl4uXKlOIfcHq26Asy1dgpAjmlK8SYIgXfpZMncT6YHdttj+1exs4/vLKEMqZwo
         GHeFRW1WVkbUmxMwX1Quy4noDVvQSOc0J41nqE+ym8zdPfAc8h+H0umzbbN3WGRhGDXs
         TsEHU0MWEcVmkE3ODx0rlg6agXsHUghfoBh1ljiV2FAF+WydQff5gsvlm/i5cJ9XYlYv
         +llQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=V8J8o0JH;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 142sor4068382pfu.13.2019.05.30.10.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 10:58:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=V8J8o0JH;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UdtCpjjQ91i6JdeO1o6cmQH2Jj5NVts/neyKdRuf9u0=;
        b=V8J8o0JH07x2wsBm99n7DGytzSCB9uQ7i73/R7tiHi2EW+jlFvc9gPYtl/fH4Vtxfk
         8+4Cfa4e63aA5rrFDRaRFWVlXZO4x+21PiB/3o4FZZJOF0sMkYhr4qoWdTzCynaKwyPZ
         kBcIAAH67jJTafpsCBQrUe1ANdMKdiKshInIwRJ+BUPz/kaCKBTlvGwLD0vk0Cy79OFL
         pQV8FyejxTWwBSkNkb2i0W+gU4dNKH5fQz3CURzx8VpGqok0gIMOvcEsrvCSRBvJK1VB
         UpIQ+Vac+NqKi2v6odcKj9Za3/R+Om3zqq5+o43oUOnVrotaFmWZapzBt60tB2lW5z7V
         S6vQ==
X-Google-Smtp-Source: APXvYqzy2V8ZQUSqq4q5Py2O0ZZ+w6f/HjgTMagL9FbXBX1DIOdqD+h8jSz65+ynIN0EAeD3DVxpFw==
X-Received: by 2002:a63:fe51:: with SMTP id x17mr4712540pgj.339.1559239083470;
        Thu, 30 May 2019 10:58:03 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::7ef9])
        by smtp.gmail.com with ESMTPSA id d186sm3003141pgc.58.2019.05.30.10.58.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 10:58:02 -0700 (PDT)
Date: Thu, 30 May 2019 13:58:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190530175800.GA10941@cmpxchg.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
 <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org>
 <20190530161548.GA8415@cmpxchg.org>
 <20190530171356.GA19630@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530171356.GA19630@bombadil.infradead.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 10:13:56AM -0700, Matthew Wilcox wrote:
> On Thu, May 30, 2019 at 12:15:48PM -0400, Johannes Weiner wrote:
> > Are there any objections or feedback on the proposed fix below? This
> > is kind of a serious regression.
> 
> I'll drop it into the xarray tree for merging in a week, if that's ok
> with you?

That sounds great, thank you.

