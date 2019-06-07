Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9601FC468BD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:57:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58047208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:57:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58047208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7F8B6B0269; Fri,  7 Jun 2019 15:57:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E08616B026A; Fri,  7 Jun 2019 15:57:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF82F6B026B; Fri,  7 Jun 2019 15:57:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95E586B0269
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:57:32 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d19so2034097pls.1
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:57:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C7dMMVelgZFqoBzwzpyUey5WFKXDTHml338sVXXC/oA=;
        b=hzoy/Ds8uGHalrNb7B5GbWxWCs68pSIcaqeIsIaCZTEvdFzw/j4UJc+53zb3m8chfQ
         phwVCmKXQA7uSReosVS0DOCJ1Jm17xuhqaJtuzZOpkRFkqR18MwxBig0uvzA/TZzai1T
         YNyHtKWY9RCWbtkyuM/V7hQocRdKZVRnKaiti8SSlqh8nqqSNuOyfKVATONZvL6qSfLI
         /RKIRmYvCcEUiuFY+KFZPZjHnUqdUr64E4AopOwOV5U3XPVLb8v8aOlTUc1g9Dkwx4UE
         7NKfCV6pDWMH6QntsAFas35SSXu+o7ZQa/Da/hmeyZbWwDqvgEUSAwWnR03i319PdYH/
         uDuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVPHV6+hP+KpK7YJAA1scAQOqxfbQ7hdz4fEsCoWVq9BSDX/y+B
	V0hFlbuloSCdioFZjnPD2ES6rmvBqAVORJsq7f5515xyZ5v1pvg19Nuum/01//tvsIJXXR04Zte
	xTRt3h09VN2Z2Ys0l8eywo420s+FfFwb3GmAy9xd3096V3jtYExHRF9JQl5rgIQAcDg==
X-Received: by 2002:a17:902:306:: with SMTP id 6mr58592275pld.148.1559937452264;
        Fri, 07 Jun 2019 12:57:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHHxarblyHgmxjDiA3bgoNFDlekrxcUfwZdC5GNfRXqkRvxZyazn1lg/xyySop1Kqqn8IH
X-Received: by 2002:a17:902:306:: with SMTP id 6mr58592245pld.148.1559937451622;
        Fri, 07 Jun 2019 12:57:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937451; cv=none;
        d=google.com; s=arc-20160816;
        b=Ae9z8f6DFhiBIeS8GD4vWtxzJ1utLew1tqUfXj+RD5TSt10idP33/swEXiV7GNIoeN
         8W1CwShDt5W4aoZ2QGOv3s9ZaQigubTkaJk/sTkThzaICp8XPim2HurhzLkwv0lhg+cT
         7ArlLjVzEeJ0wEBYnTtasBDzCqQB2CSalzqXriT2NmrYwjzsNyo9Twk2Ldf6EzGtFADl
         Re1XEdzhssA8iglph2bjXCfW0w/nf5WagIEzanMKX6MK08OVAXe2epscFWnkmGkwAfO8
         pq/qrvgT7Hnk7J7cEbRueEA8GTN/0/XfSiLQHx4GotsSV5l6WcDFOI+/cO+7X6fZgF64
         niUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=C7dMMVelgZFqoBzwzpyUey5WFKXDTHml338sVXXC/oA=;
        b=ST6oRi1VLx81Ch5PwLi2Wxasxyf8BsIsbRJVZYUnjrMW/XiPmOAA2UN+CTcaVpNGfD
         W+gbiZdGLxX6tELxBtc8VuKdeQLRJHMvbvRVPjHwpAdRlAkdz+X9pgptXBYX90NyTCJL
         hZ2b3duOt7zCvjMGd5fSQl/KJ2WpJW6jDIjvyb4nkgvolyCVnjURZ5+dqIx1T/jhu5as
         zpFEgeiQ+xZM3IxrNUMs3QFnvVNwFYpd51G2AlXx91tl7CzXgZMySy8QX4Hrrw7As9ug
         adXE/vrr7B8wyfGqnSNCVYl7F9nKX5ruRgjSuZZuaNz8KAWVIeRHI+yvMaSU6zjArgRT
         hXQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f12si2965257pgg.279.2019.06.07.12.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:57:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 12:57:31 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga008.jf.intel.com with ESMTP; 07 Jun 2019 12:57:29 -0700
Message-ID: <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
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
Date: Fri, 07 Jun 2019 12:49:28 -0700
In-Reply-To: <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 11:29 -0700, Andy Lutomirski wrote:
> > On Jun 7, 2019, at 10:59 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > 
> > > On 6/7/19 10:43 AM, Peter Zijlstra wrote:
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
> 
> This shouldn’t be able to OOPS because it only happens at CPL 3, right?  We
> should put it into core dumps, though.
> 
> > 
> > Why don't we require that a VMA be in place for the entire bitmap?
> > Don't we need a "get" prctl function too in case something like a JIT is
> > running and needs to find the location of this bitmap to set bits itself?
> > 
> > Or, do we just go whole-hog and have the kernel manage the bitmap
> > itself. Our interface here could be:
> > 
> >    prctl(PR_MARK_CODE_AS_LEGACY, start, size);
> > 
> > and then have the kernel allocate and set the bitmap for those code
> > locations.
> 
> Given that the format depends on the VA size, this might be a good idea.  I
> bet we can reuse the special mapping infrastructure for this — the VMA could
> be a MAP_PRIVATE special mapping named [cet_legacy_bitmap] or similar, and we
> can even make special rules to core dump it intelligently if needed.  And we
> can make mremap() on it work correctly if anyone (CRIU?) cares.
> 
> Hmm.  Can we be creative and skip populating it with zeros?  The CPU should
> only ever touch a page if we miss an ENDBR on it, so, in normal operation, we
> don’t need anything to be there.  We could try to prevent anyone from
> *reading* it outside of ENDBR tracking if we want to avoid people accidentally
> wasting lots of memory by forcing it to be fully populated when the read it.
> 
> The one downside is this forces it to be per-mm, but that seems like a
> generally reasonable model anyway.
> 
> This also gives us an excellent opportunity to make it read-only as seen from
> userspace to prevent exploits from just poking it full of ones before
> redirecting execution.

GLIBC sets bits only for legacy code, and then makes the bitmap read-only.  That
avoids most issues:

  To populate bitmap pages, mprotect() is required.
  Reading zero bitmap pages would not waste more physical memory, right?

Yu-cheng

