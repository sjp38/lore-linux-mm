Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44472C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 040592082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:35:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 040592082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9AA696B026B; Mon, 10 Jun 2019 16:35:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95BA26B026C; Mon, 10 Jun 2019 16:35:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8230D6B026D; Mon, 10 Jun 2019 16:35:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 492B16B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:35:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y187so7599611pgd.1
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:35:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WoHJRrbGpMezDdhM6oKY5c6eYM/DDhOoMIVqpMNuxzI=;
        b=awWS5AA4iV9irYebvujayV1Myb4NIgqxDYai8ozctIOYJtL0neReTUKGr+NNBIU5u6
         WfdCD95cpnTQ9dO11/5qABEmaDsPmBmPA/NpROVJsGwHqP2CJHzdhpYY37eTxHlJQz42
         d9o0FDKCIPlrN3m+lqHuQBfNnH7DDJdttR6acw9ZL9RyYNZ0Zcy3NGsM5pPz1meKH3Vz
         e5qxBvzr6aSB1l29QiV9aLVMM+ZMF1Dr57av8OO1KgIr79f9zs6yKD0gmqrEMPK8CVUg
         8xyhOHoo+qg3ChZSP61AMJTVUaIFpKWTaFk/dLoxB84zJ2fm5tafNZ+CcIobHQFU7SyO
         drpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWEwBymznYHO9i6tgWTEdevJ5o8pCIK0yi7gn7bXtIverewoDqW
	3p24GVMYK8PfTTtGpc+w6DkZH6Q86R3J+WbLdBctiFNFS7oz3bGY+vOQoGXWne0xEhtQ0fwJW0o
	WbSgiV/ED+BOQF3I8mAM0qNkWFkfwg8hdAXzZ2UNsVZRjnSLXBToOlp6naUk7XKRUBA==
X-Received: by 2002:a62:b517:: with SMTP id y23mr79022510pfe.182.1560198915936;
        Mon, 10 Jun 2019 13:35:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJg01iLA6fEnMCB2XywNybwhv/XbJc4KiPre8VwgXh+XWOMwP1ZpGOoZ+zhybYm78KenFp
X-Received: by 2002:a62:b517:: with SMTP id y23mr79022462pfe.182.1560198915202;
        Mon, 10 Jun 2019 13:35:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560198915; cv=none;
        d=google.com; s=arc-20160816;
        b=ELF2i7JNbZvztyhhPsM4gijjLGQ+eR4jSbVIwxzs8hXKS0g8LEGaOYwH2s4Y6cNn3q
         t4+BcHPUQfjgdrvIgGU5GarVy0Eo8rhI3vDpEDTUiccYkf7QZsEKyUSgGet/8iReMILe
         WpVk9SjgGhrTYtti2Si99t2q5edTT48LAvcCGCMM8szO24KDL4rHdxyPyYFxlfb2Q14Q
         bnlTREeUMUTMkS+WLXIsbXZg4C8XJfhNmb7s39LXn6rQ+JdhY6LGWgv72I38VN0MiJp7
         /eDJlI2y2tu4X3UeT2eBnk6BmTY/se2dEZTEa3cZJEmfI4rsu+jkgMTEojtCamnVAmDI
         4CWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=WoHJRrbGpMezDdhM6oKY5c6eYM/DDhOoMIVqpMNuxzI=;
        b=o4L4uCQkhWqy7mFcIwnQTBntZbHtgnr0t/A493OnflKWuGhsHLpiZEnyXulY+sIUMH
         7pjEZKJVtV+KAOWd6RYm24yzO+Lp6yclaHenpGV89WGrHtN3ouG7hPN0fktPe8EHLKPq
         p2zvlmxzXKwzntvQfoAnhsC6CpGZCI+E4MPm/dF/9/5EVBirXjsXETvBwO3ABnqii4a+
         lGc0JzLYXkfRnzUibGrDCWWbT7r1/0LdKtoe2uRBLlMjN77wLRzCxfzCnVZHJ1eY0Sbh
         aKh9yuCKD/MzDIIVR1diU8SMajVm/UfJeDc+vU7bD5k7UYvn8DJnVOVQafcFdtM7G+Eh
         6hHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d7si2668647plj.74.2019.06.10.13.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 13:35:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 13:35:14 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga005.fm.intel.com with ESMTP; 10 Jun 2019 13:35:14 -0700
Message-ID: <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
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
Date: Mon, 10 Jun 2019 13:27:07 -0700
In-Reply-To: <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
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
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 12:52 -0700, Dave Hansen wrote:
> On 6/10/19 12:38 PM, Yu-cheng Yu wrote:
> > > > When an application starts, its highest stack address is determined.
> > > > It uses that as the maximum the bitmap needs to cover.
> > > 
> > > Huh, I didn't think we ran code from the stack. ;)
> > > 
> > > Especially given the way that we implemented the new 5-level-paging
> > > address space, I don't think that expecting code to be below the stack
> > > is a good universal expectation.
> > 
> > Yes, you make a good point.  However, allowing the application manage the
> > bitmap
> > is the most efficient and flexible.  If the loader finds a legacy lib is
> > beyond
> > the bitmap can cover, it can deal with the problem by moving the lib to a
> > lower
> > address; or re-allocate the bitmap.
> 
> How could the loader reallocate the bitmap and coordinate with other
> users of the bitmap?

Assuming the loader actually chooses to re-allocate, it can copy the old bitmap
over to the new before doing the switch.  But, I agree, the other choice is
easier; the loader can simply put the lib at lower address.  AFAIK, the loader
does not request high address in mmap().

> 
> > If the loader cannot allocate a big bitmap to cover all 5-level
> > address space (the bitmap will be large), it can put all legacy lib's
> > at lower address.  We cannot do these easily in the kernel.
> 
> This is actually an argument to do it in the kernel.  The kernel can
> always allocate the virtual space however it wants, no matter how large.
>  If we hide the bitmap behind a kernel API then we can put it at high
> 5-level user addresses because we also don't have to worry about the
> high bits confusing userspace.

We actually tried this.  The kernel needs to reserve the bitmap space in the
beginning for every CET-enabled app, regardless of actual needs.  On each memory
request, the kernel then must consider a percentage of allocated space in its
calculation, and on systems with less memory this quickly becomes a problem.

