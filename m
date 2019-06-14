Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACA2DC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B3B6217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B3B6217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D84C6B0269; Fri, 14 Jun 2019 13:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0882F6B026A; Fri, 14 Jun 2019 13:21:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E99806B026B; Fri, 14 Jun 2019 13:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEC1F6B0269
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:21:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j36so2326930pgb.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RlatM2SrDmbHde069o7uKlxCxy4yOVtfrXmbT2isUz4=;
        b=hmJ2R8xb4Zsz0XSmgaDzHRmkHS1L0zn6I2nHtcJOpLqeP257Ki0+IsRLk7xinXWe/x
         OVv9pmoO/RmC8Zii6SRXVCP+VFxR34TDxqxOw/O+tzgTFNWOekrx0eRliUkTdS2bVzjq
         sNmEZjJ/sPS8nm42NvaAzhsfPeYYSJjEn1pJVhyjWnAWRlrNYLx7iO7AwVcJH3TskNhK
         F8LcB2bXpAjrX/mS+AaPJMF/LVZ9ARXXPAC70vSKArHtfScPbmF8zw5ygxBiuBhk1au4
         xXyRXnGsr20e/t54950G5OaElzrDVDO6xQUq6Ii94tiK0+fF1DqWr3t5VJjSHGW5xpNv
         hqzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVspyms3A1K/XvX0EB/ASd63H4p6ZWUEnBVmSAlxp9t3LMyJxio
	kwYQcKbBMCnVWpS/RvJQxQ980b8SwHjWoTQ1cQPHBsElyP1aPsVUrqxkkKteYZdvfxPw9AkjgsX
	98/+ZG734dRqkyvso0lxGexcI2iyEZmu26bgFVQnRdFM+zINBmiAa5Nre2tjN2tJKfA==
X-Received: by 2002:a63:d07:: with SMTP id c7mr7652309pgl.394.1560532891227;
        Fri, 14 Jun 2019 10:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzq0r6EXBNub/tdkUCr/GsGws/ReVIy32isXC0Wzl22QpCJB4r9gNtHGjGw/pTzoPrGLEZm
X-Received: by 2002:a63:d07:: with SMTP id c7mr7652240pgl.394.1560532890280;
        Fri, 14 Jun 2019 10:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560532890; cv=none;
        d=google.com; s=arc-20160816;
        b=p08lYxIGbmuVUmd7aVore3pBZDyCd4CnAQC1GxAUzvw+bGZaW3NmuP8o860uAA0OCh
         pdb4iZ2QuRy4/7y2MK5TU4bHzrb+uedsnZU6vu9tgdNNvVNDm3/tNGFD7RylRyxW9WiU
         3aaz69tmAHGybDDm9XJcNyp0a8/6fyX600Z/kIxZyne3ldcs484Tk/1RXdL+5FA9pkEd
         LwE9h/hg33E5IyFnSHvi8iakpBflXxNPnNgQYd0NX9MtqENfPE/XVxdlkvLrr1UQhiwC
         HSIAt6WGDipR0V603BpcmOz5S2nN8cuaZh1Xay+WLzjjZmylbw/ZnNHKw8Ccw2bYcVg5
         Vjag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=RlatM2SrDmbHde069o7uKlxCxy4yOVtfrXmbT2isUz4=;
        b=kev/PPyPVxTJHY7UFAbvcxT1QbGzN0MTjYOhiLG+10BBmw4pJFz3cwPhZzAu5+NAz4
         B+Njd/Mk8eLYENCq/L5kYU7I/if5fUC1UA0U6cwPTytPzMQjFEVKG7FtGj87kRVivZ57
         qwlB72eBYvfl/oXlJ8EW7bh4jpKQObE5RpEV03Mcaiha3dyh3sVoM2MDC5PZ/segTsar
         8U7o9If3AZDNeeghG4ek/F6RXKdZjzqc544oDw1TICf3WZjD6brRt79xOJUr6Sxfhtuq
         R2rR6Big8E2i/ciFa4bvTOMyvg6LbE5vC/cXBjQdJuQ30n71/FeVQzGCWMAOXa3mTKtO
         Ccdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g24si3054396pgh.130.2019.06.14.10.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:21:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,373,1557212400"; 
   d="scan'208";a="185026928"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga002.fm.intel.com with ESMTP; 14 Jun 2019 10:21:29 -0700
Message-ID: <b5a915602020a6ce26ea1254f7f60e239c91bc9f.camel@intel.com>
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
Date: Fri, 14 Jun 2019 10:13:27 -0700
In-Reply-To: <5ddf59e2-c701-3741-eaa1-f63ee741ea55@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
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
	 <cf0d1470e95e0a8b88742651d06601a53d6655c1.camel@intel.com>
	 <5ddf59e2-c701-3741-eaa1-f63ee741ea55@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 09:13 -0700, Dave Hansen wrote:
> On 6/14/19 8:25 AM, Yu-cheng Yu wrote:
> > On Mon, 2019-06-10 at 15:59 -0700, Dave Hansen wrote:
> > > On 6/10/19 3:40 PM, Yu-cheng Yu wrote:
> > > > Ok, we will go back to do_mmap() with MAP_PRIVATE, MAP_NORESERVE and
> > > > VM_DONTDUMP.  The bitmap will cover only 48-bit address space.
> > > 
> > > Could you make sure to discuss the downsides of only doing a 48-bit
> > > address space?
> > 
> > The downside is that we cannot load legacy lib's above 48-bit address space,
> > but
> > currently ld-linux does not do that.  Should ld-linux do that in the future,
> > dlopen() fails.  Considering CRIU migration, we probably need to do this
> > anyway?
> 
> Again, I was thinking about JITs.  Please remember that not all code in
> the system is from files on the disk.  Please.  We need to be really,
> really sure that we don't addle this implementation by being narrow
> minded about this.
> 
> Please don't forget about JITs.
> 
> > > What are the reasons behind and implications of VM_DONTDUMP?
> > 
> > The bitmap is very big.
> 
> Really?  It's actually, what, 8*4096=32k, so 1/32,768th of the size of
> the libraries legacy libraries you load?  Do our crash dumps really not
> know how to represent or deal with sparse mappings?

Ok, even the core dump is not physically big, its size still looks odd, right?
Could this also affect how much time for GDB to load it.
We will only mmap the bitmap when the first time the bitmap prctl is called.

I have a related question:

Do we allow the application to read the bitmap, or any fault from the
application on bitmap pages?

We populate a page only when bits are set from a prctl.
Any other fault means either the application tries to find out an address
range's status or it executes legacy code that has not been marked in the
bitmap.

> 
> > In GDB, it should be easy to tell why a control-protection fault occurred
> > without the bitmap.
> 
> How about why one didn't happen?

We'll dump the bitmap if it is allocated.

Yu-cheng

