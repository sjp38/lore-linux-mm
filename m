Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C15D7C468D8
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:11:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9263620862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:11:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9263620862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CDE56B026B; Mon, 10 Jun 2019 12:11:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27FE86B026D; Mon, 10 Jun 2019 12:11:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1208A6B026E; Mon, 10 Jun 2019 12:11:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFC476B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:11:12 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 140so7480404pfa.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:11:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7FynTzfNS8wGbP6wCU8qyDZECZ9kJrnfMNsGD1nf+r8=;
        b=cnFwNjsDaJzUE6kcbkldC3cmsEKr5pSu6x5TP6IgFLZ1FxR9ysj5cuDEre4C7g1r0z
         /13xYHvmq6NHtMTB33gnAHiwoGSXbX+/BrLO7UFXpE6ktK7KP2UGijjTVric8aV+eM0F
         cZJ01LO7pW7iw/GcprNBDzfjJNY+2QyCoP9OXiW4EKozDQYU6kE9H6Y1nimt+I+6xNq0
         mNpjd30G9F+XS1Ij9TfWCnbRcEdtG9ZFIj4qEfB5BVq7vaM8AjBbVSFKIO4/Xv3v3B5d
         PrAyyiPKMhrg6XTkAQSAhKYBPye5AJuGruRQZ64aT+Bi0nz4EBZVvJad28EEUVayLvZ6
         CaKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXxaxxXILDXUk92d2b1SAaLIBsSM5shxxr+MQw1ZGu31H3VJvXy
	sHq6OO3f0WKqN4NP7GAbuA2c1+BhLotN9nUL1fn+hDfHUlIK6uEWweILCFKKSvm6QKJu2oJfsND
	eTnCV/mq33dZh7ibBV1Q6cZgutsW0R8HgbJamaqWVw6ay+8FWwqWVRdVBxn7ItLaBKA==
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr70446019plb.334.1560183072531;
        Mon, 10 Jun 2019 09:11:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl9SoLO8zQstBfAkk2Nik5NFj2KW3EsZsB00q2BdoC4ipPUzO/xaLZ+/dPq0fAp4MBX4ZH
X-Received: by 2002:a17:902:2ba7:: with SMTP id l36mr70445981plb.334.1560183071957;
        Mon, 10 Jun 2019 09:11:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560183071; cv=none;
        d=google.com; s=arc-20160816;
        b=m/TsoBL9vfrYAig8idN5j1Ain4CPGSebyYgz8O0GWTRX24c3Hxe6eiHP7aJ5ppbEqV
         Tn9OrJqVt6gl9V6Eix1pQAXwy40Au144AHifQsrm+d1mpB40RZ5TwkOR0wV77FtRGrgT
         9gryyCnU1Y+PupdTv4sIC5kSp47LnYcCiolKpQdHEMRYslkyZUOtYFVTBRtcDPmmRqR8
         D9NEeU0fnDwHJYGgxI/bd/9jQrW0Gwrbp2wcPEDLzWVZzQNsGywb/fqn9+cNpnWm7JAm
         4oLGzA5VIGsHR6kfHxkTFBuX09rvvR/oyQcmYY9aW04lWCnTYiAGT+J08MwRpT1R8VEt
         ZgjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=7FynTzfNS8wGbP6wCU8qyDZECZ9kJrnfMNsGD1nf+r8=;
        b=WgaNKuyEkJ03IwAJp21eokhUeOO32JXOKl4lD+tHihT+SiAib6kAokY1IisxMPyG/K
         E7mTzgv9hI9JiQBjLuts+9Znwe8gb+0efW8L4bzPA7bg5KcNj4gB1Zey4BVMwPLeIQgJ
         U3JLPGfTaAfHiIBXzQB5KWYgkdiaUrqhxGh6szL7vRIdZdisATDJ/+ZK9wjYAYaACAx5
         u0Sa8oFa9rOI0sgdlMwMtz5WIYDCef5HkCdVznvDumC10ajKUMOaLTi4pCHUATmpqtNb
         CpDoSeXFJ2GTDYcXQYYreM4TJ4iVKzJu15iRIJMx9Tyq8/SBKmN4gwWgvi+Dp0uab2eF
         SSqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id u21si10142899pgm.431.2019.06.10.09.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:11:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 09:11:11 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 10 Jun 2019 09:11:11 -0700
Message-ID: <d699f179b7daefc6269174867a04868c9157ebe4.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Andy Lutomirski <luto@amacapital.net>, Dave Hansen
 <dave.hansen@intel.com>
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
Date: Mon, 10 Jun 2019 09:03:04 -0700
In-Reply-To: <4F7D0C3C-F239-4B67-BB05-31350F809293@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <4b448cde-ee4e-1c95-0f7f-4fe694be7db6@intel.com>
	 <0e505563f7dae3849b57fb327f578f41b760b6f7.camel@intel.com>
	 <f6de9073-9939-a20d-2196-25fa223cf3fc@intel.com>
	 <4F7D0C3C-F239-4B67-BB05-31350F809293@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 15:27 -0700, Andy Lutomirski wrote:
> > On Jun 7, 2019, at 2:09 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> > 
> > On 6/7/19 1:06 PM, Yu-cheng Yu wrote:
> > > > Huh, how does glibc know about all possible past and future legacy code
> > > > in the application?
> > > 
> > > When dlopen() gets a legacy binary and the policy allows that, it will
> > > manage
> > > the bitmap:
> > > 
> > >  If a bitmap has not been created, create one.
> > >  Set bits for the legacy code being loaded.
> > 
> > I was thinking about code that doesn't go through GLIBC like JITs.
> 
> CRIU is another consideration: it would be rather annoying if CET programs
> can’t migrate between LA57 and normal machines.

When a machine migrates, does its applications' addresses change?
If no, then the bitmap should still work, right?

Yu-cheng

