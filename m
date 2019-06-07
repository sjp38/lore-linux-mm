Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA09EC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:53:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A53142083D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:53:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A53142083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34AFF6B0271; Fri,  7 Jun 2019 12:53:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D53C6B0272; Fri,  7 Jun 2019 12:53:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14EDE6B0273; Fri,  7 Jun 2019 12:53:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD2A16B0271
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:53:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g65so1734588plb.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=heFTqGzCxa74r/Tzp5AQMtuX2XXW0TdT0dTj8bKZOHM=;
        b=INPc0rOpFWRDLqrXq25SpnTuzgHu2Q+wrVai8Wxzlpcdp1nTRfx58wp8S9mddxEbAI
         21bNdA+mc7qO0uWyjYL7yi+aapE24hax/A5xLN3ZbpZ0ZZh1goUxnZHBUf40MqWmR4nC
         9DnD41yU0T2efp/Ep8VmNJQRDYpPz5N/YQL/P9uGD7WbPDBwm4Vj9aXru96ScVnIKZJV
         YG718LojnW/H2+h4YDYrKPt527uStyuh4ceWcyUeUBCw52dLY4yPMSzkAAOiKBRu0fpC
         19OFNR9F16F0L6sihHLF1ZYdtxPPgRkY1gwLAJcXKGiiBgswOThGPc4u5gn56+B+C7bA
         UEeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXb5sMfCrBY3dDlkCee8WaTah/Da/WQxIo4moh5D8Z6oe7/9OkL
	nhAF0MHLxazC7Ceb5YqwK5u1n/ugszptmCff2IbzPgaQHVtI7Gs08p36cv6DJ1G8YxcyAgHQeEJ
	k2Fo//XKDooE/12ymwIeQDlhUgcIrQYXzxlqooBonZOV8PM30Eca/NVXdxTsy1Bb2IA==
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr6887879pje.0.1559926385356;
        Fri, 07 Jun 2019 09:53:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzp29B+Mt8CJ+VhBTIEh5vHrYNn6N54ZkDuCnYrkqEPGbvzSKVqE9Gk11nfrElAHwTQu3ri
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr6887788pje.0.1559926384528;
        Fri, 07 Jun 2019 09:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559926384; cv=none;
        d=google.com; s=arc-20160816;
        b=D0bNOeQ3m1hCJULlf+lC7xvvn9MQU/46VqZp0hteL3Vf0FfvwFBoX7jKa1tWP4F6y5
         7VrJ2ZCmfeFJLWvvJG9RdATDwOGxwsMjJfXwNeGYr5QaWGgDJx5MUJSYQcRp/94X6YDn
         YUjIVh9QPh6bT6Dju56TMr1geNAGVURlnCNSXCnXv1I+YKfhPgXj/z38Hoe21hOp+Yhr
         Gcp3vOaWrhhzA/n133tgrsLxDX9j7dURFUGs2WoE9PtoSSnt6g260KB7SRXX/ofljyMh
         WFefOax+qAcsqk2xmnE+knWuoYR/1gBr7bLH2qjAWBu/wRsBJ+DrLZPxCAg1fNXZIt/h
         Y8pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=heFTqGzCxa74r/Tzp5AQMtuX2XXW0TdT0dTj8bKZOHM=;
        b=dQ6rp2V5OPB4NeZTPoppz5fykD0P8CZDbzPWbytYPu4P/Axrij2QfKyHHn0iL3+bsE
         LQg4219KC13o3iIWAXVa0Xrb9IKZsTKry0/9bYR5MtkMym4mfnvpGC4md2GDTAb0odrB
         cNLkDIhnspHy2IlKJbNLVtZjVaFDrtL4iRtJzjwwOyK7ekbJMS8yRR8BtfaC3Aov0APw
         BsibhhrQxC2/QdHvEqjbMZEtl4X4Er7Jg6PcTFsniAqfTg4pSXDQ+LMrlGpDEIEabzO5
         Z1iM/vNkwMyoJEMBKp1IdAKdONRN8/RPtZ/eePVyFbXULm5G5xzV0xE/dGgssd484pim
         BBKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id p16si2378264pgd.370.2019.06.07.09.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:53:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:53:04 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga005.fm.intel.com with ESMTP; 07 Jun 2019 09:53:03 -0700
Message-ID: <ac8827d7b516f4b58e1df20f45b94998d36c418c.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Andy Lutomirski <luto@amacapital.net>
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
Date: Fri, 07 Jun 2019 09:45:02 -0700
In-Reply-To: <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <76B7B1AE-3AEA-4162-B539-990EF3CCE2C2@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 09:35 -0700, Andy Lutomirski wrote:
> > On Jun 7, 2019, at 9:23 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > 
> > > On Fri, 2019-06-07 at 10:08 +0200, Peter Zijlstra wrote:
> > > > On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
> > > > Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
> > > > that allows execution of legacy, non-IBT compatible library by an
> > > > IBT-enabled application.  When set, each bit in the bitmap indicates
> > > > one page of legacy code.
> > > > 
> > > > The bitmap is allocated and setup from the application.
> > > > +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
> > > > +{
> > > > +    u64 r;
> > > > +
> > > > +    if (!current->thread.cet.ibt_enabled)
> > > > +        return -EINVAL;
> > > > +
> > > > +    if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
> > > > +        return -EINVAL;
> > > > +
> > > > +    current->thread.cet.ibt_bitmap_addr = bitmap;
> > > > +    current->thread.cet.ibt_bitmap_size = size;
> > > > +
> > > > +    /*
> > > > +     * Turn on IBT legacy bitmap.
> > > > +     */
> > > > +    modify_fpu_regs_begin();
> > > > +    rdmsrl(MSR_IA32_U_CET, r);
> > > > +    r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> > > > +    wrmsrl(MSR_IA32_U_CET, r);
> > > > +    modify_fpu_regs_end();
> > > > +
> > > > +    return 0;
> > > > +}
> > > 
> > > So you just program a random user supplied address into the hardware.
> > > What happens if there's not actually anything at that address or the
> > > user munmap()s the data after doing this?
> > 
> > This function checks the bitmap's alignment and size, and anything else is
> > the
> > app's responsibility.  What else do you think the kernel should check?
> > 
> 
> One might reasonably wonder why this state is privileged in the first place
> and, given that, why we’re allowing it to be written like this.
> 
> Arguably we should have another prctl to lock these values (until exec) as a
> gardening measure.

We can prevent the bitmap from being set more than once.  I will test it.

Yu-cheng

