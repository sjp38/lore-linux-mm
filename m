Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50B9EC06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:57:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 243A121721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 19:57:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 243A121721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5D7E6B0003; Mon,  1 Jul 2019 15:57:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0E408E0003; Mon,  1 Jul 2019 15:57:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FCB68E0002; Mon,  1 Jul 2019 15:57:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5DD6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 15:57:17 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id f18so1585607pgb.10
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 12:57:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jXYUgVoeg0Ab1pwU7lf8dCL3mrqrPDKb0dW0TJUKuuU=;
        b=VaX2HRtFA/RAYCYiunRsSBxuVXwekmeTicK9gebQlyilYf4WyQD7UJcSElF7Topleh
         BjOZAtksvCInugx8teP4VuEq5gAUQQzmf2+7qhC6QmQVK0mTu5V87Rme3Kbl/a8fXEtO
         txD2mHlHoS4rFOvxM16h7oqbLUukP8t9ulEhVTBCqqtdDcDP4yAN37+KutsMHgZn1W/6
         3ioiAQa9+gUuFFgcrGLvpvAFADk1+cYPUKIJy4y3cisPr/yRWeoM7eXyGdh7rcNk1ofN
         ANprgyABo+mLYkWMGVEdW4XJ+6laC9PvZcI+52tdZ86FdBZznUsbOAHw+o/NnPOH7+D7
         /iVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXB4SKY3rtfV2RzcYyD6cJlvmUlSggImRsEMDzr1aF4MauOJWef
	c/X4BV7TcFy9Bv9BiDD6BL0iYWEp0/e4SWxnBdC/j+J12gEy8u4H66qZjtwP0Es8IaE3jM7yS36
	RWcixTfTACrY4zZ1/y01Tv4WvjlWeMSZQHalqdrXC5N0xdK+25YNOCFmlgOuhmLCm4g==
X-Received: by 2002:a63:f1c:: with SMTP id e28mr26104565pgl.147.1562011037003;
        Mon, 01 Jul 2019 12:57:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSdxFJ5/gayf1jS0eCF8I/8XdAsMzHE/6iPGvW4gHSIaNobcjyVTAPRYk8j2++q6xfhjOm
X-Received: by 2002:a63:f1c:: with SMTP id e28mr26104515pgl.147.1562011036322;
        Mon, 01 Jul 2019 12:57:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562011036; cv=none;
        d=google.com; s=arc-20160816;
        b=tUAi+8t+kBelpF3rJq9yXmDZ7ac5+C4yGhpL4y2gIgxN8cJEbuxa7NAOJ/zXrCWdoB
         ax0RJx8IG5dYu1i+xk5/UD90+NupDu0Ic8Hogc70yK2uDBTAYIZja8mAn07ugCZZdkGn
         WxWWuW8VYig4jGSYu0gnASC8Vkaxa7BwrxNqJ25rwhtKHg7xfgsuGwr9l/qABILiui5F
         7L8P02F4EnTbd2GPSlq5b2wLMpqDuanOulvCw80KVG+poXE3HgMDOrRExdEjwTC5YZ2R
         /tmty9VfB3DXmUfFhd0SZ3Cr+FpoelRfnRLv2tJJm24fgo46r/KsjmsaFt3/w5Lokqe7
         VACg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=jXYUgVoeg0Ab1pwU7lf8dCL3mrqrPDKb0dW0TJUKuuU=;
        b=gbuaLng5Odrixgq+IL3SMGXVd3LiWrL+TjNpp/ioPEa++1caOyQddBJuGGAWNH3La5
         OUH77MlwzlCR9Gm9YHn/ZzdfUKB5hICTAtz2lvpgXjlJxwH8oY9Pu7t2fPc+7eEZPiXL
         0LddQsjvgjpI3cKPGzDumDILqfKXGJWQaYWwQTzA4vx4+axyeJKFExk3S51c7SRq2Wz6
         Xo5urj/adxUdizENrXyjOPtspnNUorh1MEBY7GWuUfHHbk6v/5YUT3heUwJY7iaG7gy9
         dI3BZ/vIESgeKkIwKBaoSOk+XWMMKwyFllIr3PqoDTVmhw2ECpDND5OXWQUXGtZchzvq
         Ki5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z10si9965426pgh.30.2019.07.01.12.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 12:57:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Jul 2019 12:57:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,440,1557212400"; 
   d="scan'208";a="361947326"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga005.fm.intel.com with ESMTP; 01 Jul 2019 12:57:15 -0700
Message-ID: <c99aa450d6cc9a0d23d24734a165e5ffbd9ecc7a.camel@intel.com>
Subject: Re: [RFC PATCH 3/3] Prevent user from writing to IBT bitmap.
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION"
 <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch
 <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd
 Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav
 Petkov <bp@alien8.de>,  Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit
 <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Mon, 01 Jul 2019 12:48:56 -0700
In-Reply-To: <CALCETrXsXXJWTSJxUO8YxHUo=QJKmHyJa7iz+jOBjWMRhno4rA@mail.gmail.com>
References: <20190628194158.2431-1-yu-cheng.yu@intel.com>
	 <20190628194158.2431-3-yu-cheng.yu@intel.com>
	 <CALCETrXsXXJWTSJxUO8YxHUo=QJKmHyJa7iz+jOBjWMRhno4rA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-06-29 at 16:44 -0700, Andy Lutomirski wrote:
> On Fri, Jun 28, 2019 at 12:50 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > The IBT bitmap is visiable from user-mode, but not writable.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > 
> > ---
> >  arch/x86/mm/fault.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index 59f4f66e4f2e..231196abb62e 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -1454,6 +1454,13 @@ void do_user_addr_fault(struct pt_regs *regs,
> >          * we can handle it..
> >          */
> >  good_area:
> > +#define USER_MODE_WRITE (FAULT_FLAG_WRITE | FAULT_FLAG_USER)
> > +       if (((flags & USER_MODE_WRITE)  == USER_MODE_WRITE) &&
> > +           (vma->vm_flags & VM_IBT)) {
> > +               bad_area_access_error(regs, hw_error_code, address, vma);
> > +               return;
> > +       }
> > +
> 
> Just make the VMA have VM_WRITE and VM_MAYWRITE clear.  No new code
> like this should be required.

Ok, I will work on that.

Thanks,
Yu-cheng

