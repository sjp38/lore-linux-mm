Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91462C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55D3A20840
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:24:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55D3A20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02AE66B0269; Fri,  7 Jun 2019 12:24:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1D6E6B026A; Fri,  7 Jun 2019 12:24:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E2C6B026B; Fri,  7 Jun 2019 12:24:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7EED6B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:24:29 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q6so1672572pll.22
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:24:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=khwjtWt+EPNSdS26DemWy8Deo79ZR9ZNMZIN4xypnsQ=;
        b=rJc5mbJh5uBiqqwIj1proeic3ki79p/ZmOkNlrFqK8zwSUu/9T8qd1icFAgan+vyCw
         e4Wj5H1hkwx+RyFzPSzLESxHG7MnvZ5DSG6wSlGHdy1eafnB5k2IoEL+ZhposGwFx4RU
         SYJc+Vr9ANA+u1zcbmuKLA+QyBm+9QKqe9n1Fjq+scYq+de5sQGWAesHScAkAxEgMTYq
         NeKQ/xO9C3tlhTkYFffZx57oAhVmrhag6yucn0WSkifefPflqiGtxxzQjTR81jgUj3bk
         1GzInvxIgYFrnUzOz53b9DaVUExesYF3DXpDkXnZ6zEJBFmEl6B2V5hY/KrgVu2F0xx5
         tQGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFjl053+H6s5iR7Rj0ALu+i2rRJlmiIcO2ahewebqssCKTgLPW
	yFohUVtj+Y0oRkrWWl8W4JN2blGRUH5uwZ1TmNIDVIvpghQglyPWgfBWG0MO1hJHmTqPkHo6QoI
	vt9exsnOAxqNEJ6YkAGwrAYasRW9MtK5iFeMW9xZliFzC//3o/Yd6R1zGNXXyK5rMAA==
X-Received: by 2002:a62:6143:: with SMTP id v64mr22967031pfb.42.1559924669354;
        Fri, 07 Jun 2019 09:24:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz27tTzrAjCvcQ48l9XjaPfrfaV3fQ56jI980cp6l6PgYFtS3hKdq3pxsHDhx1mIcSsNhgS
X-Received: by 2002:a62:6143:: with SMTP id v64mr22966934pfb.42.1559924668491;
        Fri, 07 Jun 2019 09:24:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559924668; cv=none;
        d=google.com; s=arc-20160816;
        b=x3o+/bHH3kdInfHDM2LDYuHWuQeYvr2Jvm4WXSwrqCvfrJTGH9qkcBpfBchXKgsGzj
         g/mtK07cR/VE3Kxj3ZE760XxreUVkpspVdx8KRzaOMxMax8+5dX/kRF+Ox8P+8U+gjNr
         aVOlhtidZWTy/BwQOEjJQJte6MktNsUEgjC6wY4y/RIUmV1msf946CsLhBtLAiaLOVcI
         IxX06Wxt9Sf+QBpHE2QhBchiOpHF451vSozxp80hEM0iNzQ/pot8eReEHOKzN06GOFLc
         zjN0V8y0z/8vnWQi4vymlNUpWb96+KWvtlHmfBwx9yaZlyceFnsLt+nwjojVNeB7d7D/
         V01Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=khwjtWt+EPNSdS26DemWy8Deo79ZR9ZNMZIN4xypnsQ=;
        b=SzEm//mqT6inCMvlLKN/csTvdPFbg8jhTcqxGjRmyce0z+lVHPGxOYMDl0fOxdT5++
         m2kBiMYWvqQVbJyeQe5AvVZjhmYwx5Irk22F3U0WjFm9AJ3wgefHHWY+qLvZcg0IRBSj
         IZoA1i4b/jk8z8cCB8Q7UeS8xIIOgRpG5sEG4pvvb+kNN2wHqfYA2RxQ/0NOKJv3JtF2
         N1W6J92kEHXVzP+T8ge9HNYYEMTMaolTH5O7pH3WXCuE1rIJXqAy9ykoyOe2M9a0qHPF
         S1Vec6wyxTzkNSrjbo4aKdWwB6Dt428QCOa9rcXT0pQo2S+sGYxFcGX2zFF8yfUrN14e
         i5hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b8si2340179pff.119.2019.06.07.09.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:24:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:24:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,563,1557212400"; 
   d="scan'208";a="182719826"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 09:24:27 -0700
Message-ID: <ea07ae367f9d130cfe7a3e508d478956c2bf47a7.camel@intel.com>
Subject: Re: [PATCH v7 18/27] mm: Introduce do_mmap_locked()
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 09:16:26 -0700
In-Reply-To: <20190607074707.GD3463@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-19-yu-cheng.yu@intel.com>
	 <20190607074322.GP3419@hirez.programming.kicks-ass.net>
	 <20190607074707.GD3463@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 09:47 +0200, Peter Zijlstra wrote:
> On Fri, Jun 07, 2019 at 09:43:22AM +0200, Peter Zijlstra wrote:
> > On Thu, Jun 06, 2019 at 01:06:37PM -0700, Yu-cheng Yu wrote:
> > > There are a few places that need do_mmap() with mm->mmap_sem held.
> > > Create an in-line function for that.
> > > 
> > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > > ---
> > >  include/linux/mm.h | 18 ++++++++++++++++++
> > >  1 file changed, 18 insertions(+)
> > > 
> > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > index 398f1e1c35e5..7cf014604848 100644
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -2411,6 +2411,24 @@ static inline void mm_populate(unsigned long addr,
> > > unsigned long len)
> > >  static inline void mm_populate(unsigned long addr, unsigned long len) {}
> > >  #endif
> > >  
> > > +static inline unsigned long do_mmap_locked(unsigned long addr,
> > > +	unsigned long len, unsigned long prot, unsigned long flags,
> > > +	vm_flags_t vm_flags)
> > > +{
> > > +	struct mm_struct *mm = current->mm;
> > > +	unsigned long populate;
> > > +
> > > +	down_write(&mm->mmap_sem);
> > > +	addr = do_mmap(NULL, addr, len, prot, flags, vm_flags, 0,
> > > +		       &populate, NULL);
> > 
> > Funny thing how do_mmap() takes a file pointer as first argument and
> > this thing explicitly NULLs that. That more or less invalidates the name
> > do_mmap_locked().
> > 
> > > +	up_write(&mm->mmap_sem);
> > > +
> > > +	if (populate)
> > > +		mm_populate(addr, populate);
> > > +
> > > +	return addr;
> > > +}
> 
> You also don't retain that last @uf argument.
> 
> I'm thikning you're better off adding a helper to the cet.c file; call
> it cet_mmap() or whatever.

Ok, I will fix that.

Yu-cheng

