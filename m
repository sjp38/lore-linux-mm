Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD3E2C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AF5720862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 15:55:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AF5720862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28BF56B026C; Mon, 10 Jun 2019 11:55:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23C426B026D; Mon, 10 Jun 2019 11:55:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12C2B6B026E; Mon, 10 Jun 2019 11:55:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D02D66B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:55:54 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so5970821plk.11
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 08:55:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZrrMMxf68rYUQrjsizo1vq0YK1i87Qr/FZ/0HM6pY08=;
        b=Pu4Wiy9JZ8/h/nTAL9y3KLz/MDwMnadjl4gxUiW5mKdKaeTj3dimNQ6KdIxqZWGufw
         gWT0GNvD/E90ckDcWw6ewIFxGW1QmVOipX9bdrRMqSWzjGWQshoEPhdR+6/V1ybUwZDc
         isJGUr2bRQk4i+3bYT7T+0bqej73n3usMbxthS3dU/9PqcS7aB+JrICa23OO6FeAPC5g
         5/bpL0WyvvCwgYe8yGytlqSmbyABy9Gx8eUBTz5xrAj6buSRdikHYg2aGa4eav7/pAAI
         61qY6LtxZ81kdwK5bZCQ3LmEJCAcQ8k/7Cwn/aSJnY1hroHC8kXE+fbTmzkLNBS/eepv
         5BHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWdQubLOqauN8sSCmaMF/f1BMfcTsCEk1jZLiCDm0+M6cWNGWBN
	312FWSLH7FP02IDdLZkrQ8yBkhu/C1HaZU7H/A0NFR3NM+ODUNK5q6StsWy0t+3jOZI+pBYBn7J
	A+xvsTIjQKoT7O+T/Ej+GDELhOq03PMrvZUKYmtCnmLdG8iIUE6CFdlzxU4eVekj7BQ==
X-Received: by 2002:a17:902:f20b:: with SMTP id gn11mr70465701plb.126.1560182154436;
        Mon, 10 Jun 2019 08:55:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyP3hKN+5Lx8lkh+HCNHY93elK8xEnmdzf/3lQvNAHDQJqXeXsddPMUwHYWZ2JwYgV25uTu
X-Received: by 2002:a17:902:f20b:: with SMTP id gn11mr70465652plb.126.1560182153651;
        Mon, 10 Jun 2019 08:55:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560182153; cv=none;
        d=google.com; s=arc-20160816;
        b=XCDesNJrgRejiQExf2lXYkpshwhXZDGDA19CsljMF4GMPKzCLRIaH6z307tdelwaz0
         dyFiDGNc4MWuH9TM/gRdGXND4TDjGXmZsSPzwDg/KNu2d35UxUHFRgDJY8AdslbVHKL1
         LUzH33bknoW7Rukf+xGc+CQdc8ZYNb+TibpXa0tl4SPh0S0PKUBu2Xdfn2p756z/LUVV
         tGRCB9MXvrzFd8Lood7xznlSy/32HAvbQ4dXqCam5MlmH0DN9WP+5Qw96XcW0ooY2lIb
         dKdS47Fk6OxNnpwf7NpDUSqPYdtJNlUnq+2r+BWjLy9yLgEIAbqnbbWWDen02cqp5b6N
         R9PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ZrrMMxf68rYUQrjsizo1vq0YK1i87Qr/FZ/0HM6pY08=;
        b=Hw1JJuWfB3H7c6KxfU++Seac7WrwTxbfB46/QHVA2ANUzeiqum+iXmbKp6DugsRkws
         5sX5jrUB1GylDpcgrJZ2iUpLh2fWyXjWzrGzsx25KlqKK0zDShXu57ZIIVymfHMy3dKJ
         +BYwhXyQioyPGSfZ19/L6tcRHF66pUO3VsIFOUZ+R541QhwNzy4qjwcy4yhLMg7PeWhs
         AutJSbFfP5mI0qGUECTcADUY7vIfzJ90pRcawpHA1ZTdXxXd2SZaB8gggrfPkZldJZ33
         yrMYAjZEMP+Zlv6MyIZ+/wo2Mb5WNF+XdAFQiaUY7bZ/2CIRotgm9C2WStYpeSghOl3/
         0sUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s62si9837541pjc.75.2019.06.10.08.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 08:55:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 08:55:53 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga004.jf.intel.com with ESMTP; 10 Jun 2019 08:55:51 -0700
Message-ID: <e1543e7beb0eb55d6febcd847ccab9b219e60338.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,  Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, 
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Randy Dunlap
 <rdunlap@infradead.org>,  "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Mon, 10 Jun 2019 08:47:45 -0700
In-Reply-To: <20190608205218.GA2359@xo-6d-61-c0.localdomain>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <20190608205218.GA2359@xo-6d-61-c0.localdomain>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-06-08 at 22:52 +0200, Pavel Machek wrote:
> Hi!
> 
> > > I've no idea what the kernel should do; since you failed to answer the
> > > question what happens when you point this to garbage.
> > > 
> > > Does it then fault or what?
> > 
> > Yeah, I think you'll fault with a rather mysterious CR2 value since
> > you'll go look at the instruction that faulted and not see any
> > references to the CR2 value.
> > 
> > I think this new MSR probably needs to get included in oops output when
> > CET is enabled.
> > 
> > Why don't we require that a VMA be in place for the entire bitmap?
> > Don't we need a "get" prctl function too in case something like a JIT is
> > running and needs to find the location of this bitmap to set bits itself?
> > 
> > Or, do we just go whole-hog and have the kernel manage the bitmap
> > itself. Our interface here could be:
> > 
> > 	prctl(PR_MARK_CODE_AS_LEGACY, start, size);
> > 
> > and then have the kernel allocate and set the bitmap for those code
> > locations.
> 
> For the record, that sounds like a better interface than userspace knowing
> about the bitmap formats...
> 									Pavel

Initially we implemented the bitmap that way.  To manage the bitmap, every time
the application issues a syscall for a .so it loads, and the kernel does
copy_from_user() & copy_to_user() (or similar things).  If a system has a few
legacy .so files and every application does the same, it can take a long time to
boot up.

Yu-cheng

