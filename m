Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44EFDC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 187D2212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:31:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 187D2212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A256C6B000A; Fri,  7 Jun 2019 15:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D4E86B000C; Fri,  7 Jun 2019 15:31:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4CF6B000E; Fri,  7 Jun 2019 15:31:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 530606B000A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:31:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id i3so1984154plb.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:31:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n/ovFP11O8q6ZHjiRlA4PMy2pv31Pw4CkyK6Pr4NpCI=;
        b=HKBhcTlTWAFU2qk5TfIixhiPJy3iK9jTKmyb0OmDuVsZGR/neccKgnmH9/juaDIV5x
         jNfvac3pRQ+IEncSZJRrpqG9BzFYlkKZY2OGXm0wdnmR9rISIsXGhY0695ST0iFBtkWy
         FvY2KuVYuPvSSOs2somhKWCNKsnxT+n4HiT6C3cgjO1KrajkaVmHvuqiAIx8tzlJxo8W
         ujlC1AThyCtbF1+C/EDwXlltzMxqU5rJ7dGcsNJoq8yaWsMdluey38ojktideGhWwUu7
         99LPoeKpFvsMMR4h2TshzYhKMj7Nyg6PTyxq0xyfc5ejjYfkIip8WBhK+xZ2FLDORWkp
         MxBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUgiu51e8sZGqH013JrBgFtmMdArVc4G1j4iHeBCLm7Yd5urYRQ
	XZvQov2+d6VWU1FdtOCzNVA3Tf+TF2gBQmXOJkMUEsRV+aN9rDDC3BhWgZxS8bhTSu6VvKGbIWw
	8mywXin0TzIYrmR5/W7wFc7LTieYdJyh9OVw/MC84glqRK1ZHE7g++gJ4NeWLdkiqaA==
X-Received: by 2002:a63:4d0f:: with SMTP id a15mr4688035pgb.59.1559935910933;
        Fri, 07 Jun 2019 12:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1ibBscm4RbtYVR92+5mpIfat4KNScElbik7EarcFwT+HrbyhvTZpf0x7txfSU7MzEU40J
X-Received: by 2002:a63:4d0f:: with SMTP id a15mr4687981pgb.59.1559935910161;
        Fri, 07 Jun 2019 12:31:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559935910; cv=none;
        d=google.com; s=arc-20160816;
        b=EOF/aWi03pgjReldKOZRFUv+pAkNAp5MYlRdy7bi96M6+cGpfqLzMjkRXyQ+MpsFor
         au6eNwz+6kiiXdImlumYDsdJBhlWgbxZQL9gr2Lo/eXTx/i7TMGmxZcV6yPQYujS8C19
         8+Rh7CDQJ9kaWlVB7lh7svaVuE4xAMQ6warZtcI0t5KAGoORiQwwldXEyPnCvU4QzwbU
         f8jYxB4MjN90JRDwgAS5b4IJ2E0Jknl9Y01W2l4+GDI00IUvsb8FdFSaDbKgFZbJ2+UP
         AijWZxWmRvC+6YpWW3MKVC17JQY2Vy+CJdD4PlCCz1kN4ob0MiGRLQbg1DepBxZVSoRI
         URqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :to:from:subject:message-id;
        bh=n/ovFP11O8q6ZHjiRlA4PMy2pv31Pw4CkyK6Pr4NpCI=;
        b=aR5CPOeClH+/nwLb3K46Ec0sFiijjztzFl/z/A6GUK8DOOVdSBVVvrzdhbe+vCa6H6
         5efRCC+mqU69R9IpYAwOaMeYUpybnUyxW/CjHZR+yTCcxekTZ0V+A5BL4YMpZcWKlFio
         vJ8cCy+kwCGUOWDGm1AeNsvstR+FDCojupXk3q6A/M1Chvrh1+AsMbcroLa82Skufqaw
         XNa+0HHBZD9DZAOhwCy9RBnR8Jc8qh7LcUpmSYJQBhmnmRv4fjmGkzFPmELDr6lAEHCJ
         vmtZCs/ZtlSDZfYmpNGOOKaABLbvYxNivYNgbjB0V1dIczBoRQOAi3e1qgsF8SHE6Mfr
         Na7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id v32si3031193plg.3.2019.06.07.12.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:31:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 12:31:49 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga005.jf.intel.com with ESMTP; 07 Jun 2019 12:31:48 -0700
Message-ID: <997ef050c13e3654dee6a862d810cffcafce249b.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, "H. Peter Anvin"
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
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 12:23:46 -0700
In-Reply-To: <c5c21778-f10f-cef8-c937-1e8ad1e2a7cf@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <c5c21778-f10f-cef8-c937-1e8ad1e2a7cf@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 12:03 -0700, Dave Hansen wrote:
> On 6/6/19 1:09 PM, Yu-cheng Yu wrote:
> > +	modify_fpu_regs_begin();
> > +	rdmsrl(MSR_IA32_U_CET, r);
> > +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> > +	wrmsrl(MSR_IA32_U_CET, r);
> > +	modify_fpu_regs_end();
> 
> Isn't there a bunch of other stuff in this MSR?  It seems like the
> bitmap value would allow overwriting lots of bits in the MSR that have
> nothing to do with the bitmap... in a prctl() that's supposed to only be
> dealing with the bitmap.

Yes, the bitmap address should have been masked, although it is checked for page
alignment (which has the same effect).  I will fix it.

Yu-cheng

