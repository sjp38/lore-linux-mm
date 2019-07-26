Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CD09C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDD7122BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 23:52:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hYhyEKJ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDD7122BEF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AAB96B0003; Fri, 26 Jul 2019 19:52:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8337B8E0003; Fri, 26 Jul 2019 19:52:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721B48E0002; Fri, 26 Jul 2019 19:52:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE076B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:52:29 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 8so28641306pgl.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:52:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9kYsvGrj93HXwLSlroYpXY69aW8Jr/qdH76pdbFc6JQ=;
        b=URWMLdY3UHqwUrDWij6KdUmvzNkBPXQx+ByZPKtSpsCcyNl9suHjP4t+62EJ/OqW8u
         HioK0yZtoh1j8IEfiwX9iYVDsnz0uWMzrDeB6tEU41uXWo0AvkeEHwQlQCfmjUW/Mpw3
         gM3+eYQFjMDGdzoYek9tzQLI6ceMaox/wxF0bb+dbSsubgjyUY/ZbfdOO2aGypWXs8v1
         zHndVpz9Z9KwLtVgaOwLW6iKn6RurZg3P6HqqHVp9g+cUZTh008lAHAqme6Nac6e9e3q
         xbDOw3A06S/rA4f1oabOXz4m5lUCtAAh7HQURo9JMALfoEpuWhsTyB5OzRDu8nDNmF3i
         mU5g==
X-Gm-Message-State: APjAAAUW8L67KfPp2/iODtU/CehfecnzwlYbMu2uvXUQb3Kp1SusezD+
	l5RAOHsz2wJCu270hOS0MuQG8HXolUFC6z3NbGwwl5VQFflWYnuz5+RdJkobP274MkwC5ONLlQG
	8JmLtbNrNEMyFreXkwIm63uwSUJZPPu2QxaCGlSmsCMSzmgZ6GazopXodwdd82fhVVQ==
X-Received: by 2002:a63:5754:: with SMTP id h20mr53095420pgm.195.1564185148693;
        Fri, 26 Jul 2019 16:52:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5DpIKW3c90ja53o8UX2Mw7sNCJEQQkgpEqofip44xo+vlESyWlW4b2FPrgsYv0s3OZw6h
X-Received: by 2002:a63:5754:: with SMTP id h20mr53095376pgm.195.1564185147892;
        Fri, 26 Jul 2019 16:52:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564185147; cv=none;
        d=google.com; s=arc-20160816;
        b=sXXifwBgJEuUhutp++4BaVKPJUsrW7uQFnJY7VIeilVu/nPq5f6zIdfkooot9J8J/Q
         zvDhjYYMAgCnuaC07nPgw9SBOjcTkLuqY/WLlnz6IceIUgubycSzpw9YXC9t6l8Q/Rzf
         Cfji4n27CMoG9LVXd7AUSQ0Eh+U/HQsUucj5KeqCa934VMHqAEhGAOqh28KVajZbW74u
         aIky13YPZCL+4xmEBrwcrKJT1EJNZzbqjwYYO5sUdskBK6tgB0eCWwTu4fnHlEr3+QYI
         Qzk6bQr6MtZShnhGQZuzuDXrEg0fsVpI+MUBxSEayPGN7AM2uVvrNuGmogr9tNMpMVgr
         I3iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9kYsvGrj93HXwLSlroYpXY69aW8Jr/qdH76pdbFc6JQ=;
        b=EOSZqJMzJXyyEdTb47iKkwFYOQSWIz5fLZlvaKKWtTVfMS/MsHzdUYEXXt/9sRHYhz
         BsaYtmlpE2CHQc9nfLrp6kULCyhuVb2lf4pmTDXiwaBCEzs4Xlo7LbXRMCv7zejd9DX+
         QTKbDKAkp3VVjewPX1pQ1PbgVk4amO3mDqz+5ULNMQYJeOapdDJfaX5A8FUuV9X2yQa2
         7o2YWRWqLwYS/cc7jDMIxGqTMx2rfe902+Mh6zESS3K8X43PRFEIRhnk7ezQcOMdQq4g
         mDz21DPzuwUlVMOgpToINk9uaZOBVoQkgEKC3Ifas53pSvZcRYNHUiFm1tbCsfSm7dV1
         z4QQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hYhyEKJ6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o6si20622760pgv.273.2019.07.26.16.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 16:52:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hYhyEKJ6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 264F522BE8;
	Fri, 26 Jul 2019 23:52:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564185147;
	bh=duPWZXNISArr/kR1w6uKGNRe0QFiHR2VTP/jsAi4jII=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=hYhyEKJ6315SFImWkhrogq8opXyZESo6nvCUXeRvILhK2r0LDuZ31t9nxJ78gRdGN
	 Boll48yRo/jNq8My/PXPvGMfEI5pMZ/ex+PKcSDBlDuUVLG11jX/b/2+vzX5u6/Njg
	 8aMojsLEWqYzzwbDPg2vBs86CNLrnsOgPnS+Y30M=
Date: Fri, 26 Jul 2019 16:52:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
 "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
 "peterz@infradead.org" <peterz@infradead.org>, "oleg@redhat.com"
 <oleg@redhat.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, Kernel Team
 <Kernel-team@fb.com>, "william.kucharski@oracle.com"
 <william.kucharski@oracle.com>, "srikar@linux.vnet.ibm.com"
 <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 4/4] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Message-Id: <20190726165226.7068704eb54a0104aaead703@linux-foundation.org>
In-Reply-To: <509AB060-6E17-40AB-A773-DF3FB8EBDB62@fb.com>
References: <20190726054654.1623433-1-songliubraving@fb.com>
	<20190726054654.1623433-5-songliubraving@fb.com>
	<20190726160239.68f538a79913df343308b473@linux-foundation.org>
	<509AB060-6E17-40AB-A773-DF3FB8EBDB62@fb.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019 23:44:34 +0000 Song Liu <songliubraving@fb.com> wrote:

> 
> 
> > On Jul 26, 2019, at 4:02 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > On Thu, 25 Jul 2019 22:46:54 -0700 Song Liu <songliubraving@fb.com> wrote:
> > 
> >> This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
> >> regroup of huge pmd after the uprobe is disabled (in next patch).
> > 
> > Confused.  There is no "next patch".
> 
> That was the patch 5, which was in earlier versions. I am working on 
> addressing Kirill's feedback for it. 
> 
> Do I need to resubmit 4/4 with modified change log? 

Please just send new changelog text now.  I assume this [4/4] patch is
useful without patch #5, but a description of why it is useful is
appropriate.

I trust the fifth patch is to be sent soon?

