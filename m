Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA529C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A4892175B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:33:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A4892175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03CD06B000A; Fri, 14 Jun 2019 11:33:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07C06B000D; Fri, 14 Jun 2019 11:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA8666B000E; Fri, 14 Jun 2019 11:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4996B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:33:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so1796732plk.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aH3gK9v8tKykePmoqb2fTSoLTmJZNNo3+edMZP+r0Gk=;
        b=WgXPRs/YKJrUnTVflL3+yXfHENaT0b0VDlncYebYPkCDiygrS0k1DxJZS+aYedBWt0
         UdREp6EZJxHPvYcFxUTUFpXy8JcMsFB+gXtr2MW5zLTTPwITwcUr0kg/yveUlaVNN8an
         Rufxmc37S0L6kmjhGu5nhdw6XIQR94u7Xmlx5PR4jJWjAOucQVgVEwkPEKPlRbh70cMc
         I3g+and5SpV9ee8WbZBIwJmGvc/D06i6p30UTYQf351NuU5ZV2lwuiEjJNgqXBdj1g5N
         ZfGNkeklRKtIOZ74yYn1jiUmEsiTS+35y9y1qb84YlujNJFnejT9SwY8Zl92iOgqRQPt
         0fjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU+YwZwIXCsUHicqkstnRo/R0k8NXI1jAK7U1QC42pyf/Kt1sAE
	wDDTYl/aIHx0aBdQTOonFWlOhGvkS+OgWMyXNEM5GyOGUNE5WxvYEZ9/2VL8ME4K78dCFQPXjvz
	FFVvzfbd7c3OrzQghlaBhsMLkhn2BdtkcUhrgA8uo9lM/4jZWHG991LZPQWeIVHrBuQ==
X-Received: by 2002:a63:82c7:: with SMTP id w190mr35106743pgd.444.1560526402205;
        Fri, 14 Jun 2019 08:33:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE3vSRGkNrne87a3t53ctn+dG5gGy1UeqO/a+NDm48u9LCjmHE+DSJTjp20zVNKIuMRlUF
X-Received: by 2002:a63:82c7:: with SMTP id w190mr35106692pgd.444.1560526401296;
        Fri, 14 Jun 2019 08:33:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560526401; cv=none;
        d=google.com; s=arc-20160816;
        b=F0iUh2rAzzf3OXk1+ztCVtCru0OV9jyNWqXxkpBHUmLFnYUL1mfdZXK4ihwAVSbOP3
         Ui9KgvzDMdJDFs2BTDS8kd4/uGh7YMYFZ3d9i21CWxpG12WsKnhTdce0Eg+RYSwDH4pL
         YzZND20DVekhDY9vdIrT7/19tx1q9q3XwJYSmehw9lfoow5qB9+0OBTyKuob7v7EVGcr
         t1TJmfukG53U4TlY6wjKXYTHCvgFkBa4uFi286NgKCPEWImyssAVgeuxAN6EXOR5NRd5
         xbhgPJMAP6rBq75jQIph1Lqsx22kDeum9Xu8bqof2eSTF/0Sv3tIRmadFqt0GlSg7bHB
         93cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=aH3gK9v8tKykePmoqb2fTSoLTmJZNNo3+edMZP+r0Gk=;
        b=MVW7gUkxG078Y39uUN6dnHnzEPjasTmNyP9mVzZ/m9UZsOQjkoGSg7k8xdMY9v4mK4
         ZLVWBbsZViEwyB5Z62ZT0rsVcbeu6OuJ1gkhR8xAXAi3t71yu1V4Y9W+2ZXadGwqf8IB
         CW+IyY7Hk2K73+s8DK6htIapU+NuPe7PF5Vc1YZCQP5jeCctd0d5lXNnkGYFmANk/c3j
         6q5AslQ7vWQGWTriV4ZAF312h6WMw4zRgs0Fb90h21EBcgEJVeckLh5pMPvHdlZJ4QSz
         xEcT3OW+Xixib7F3pPnK05ezryxdW2/lD/qoR3aIhGiAqkWftKcXj6YfOYUHmvIF1UFS
         6nag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g7si2903786pgd.32.2019.06.14.08.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:33:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 08:33:20 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga001.fm.intel.com with ESMTP; 14 Jun 2019 08:33:20 -0700
Message-ID: <cf0d1470e95e0a8b88742651d06601a53d6655c1.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
 <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene
 Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Fri, 14 Jun 2019 08:25:16 -0700
In-Reply-To: <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
	 <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
	 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
	 <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
	 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
	 <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
	 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
	 <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
	 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 15:59 -0700, Dave Hansen wrote:
> On 6/10/19 3:40 PM, Yu-cheng Yu wrote:
> > Ok, we will go back to do_mmap() with MAP_PRIVATE, MAP_NORESERVE and
> > VM_DONTDUMP.  The bitmap will cover only 48-bit address space.
> 
> Could you make sure to discuss the downsides of only doing a 48-bit
> address space?

The downside is that we cannot load legacy lib's above 48-bit address space, but
currently ld-linux does not do that.  Should ld-linux do that in the future,
dlopen() fails.  Considering CRIU migration, we probably need to do this anyway?

> What are the reasons behind and implications of VM_DONTDUMP?

The bitmap is very big.

In GDB, it should be easy to tell why a control-protection fault occurred
without the bitmap.

Yu-cheng

