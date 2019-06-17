Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59972C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:01:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0568F208E4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:01:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0568F208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FF468E0004; Mon, 17 Jun 2019 07:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688C38E0001; Mon, 17 Jun 2019 07:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 550BD8E0004; Mon, 17 Jun 2019 07:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B9D58E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:01:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t2so5799508plo.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Qaf+B9Yr7ALXcLt671oylbmPh3oUBy5ZfluH2fNwOPs=;
        b=kPEcL3VfSk9NboXxC1PFR+RipFmzmJYOnut26R9aHHJABt9ZuzVZ+b5yrTw5M8XU/n
         08lFWmxhi1GUeaybGZcfEtFU6ORE0YpkV0jEVDO6YcJtwHmITWdCi4A44K3ctNtU62Tw
         s1kmTG7Q6/oG5e29htblYI2SeZq5+N5RRPFwFaguqyjy7aQTyHV9jVJ9lwuarpCkxv5w
         9NJUqd8MV75O7ZW+KeBN9TRs2TWtJc7NxoOfHv9Q1JcSemz/5jF7hv84ORdfYBOG8w6H
         K2p/ZDTtHCGjD+xqHct5Pq2O9vp2h3o3oGuZWi/RnFv9G6sY6RKRUNs4fSw9B8lv87z7
         O0Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXX6/tJiSFrQ3+8DHjNnwa3b1o8O5emMGTPmJHMNv6l76G3+Apf
	Yugt2+G08aTLLB0/HCpvHqnDGmD4GBBk6ecs9T4TO9DMSKJU0cNkCIWYzRR3HY6PuocXTcDiZ5r
	eTVHvppTEU/ohrEiEl236NvlkoP1o7eJVoj1Kef9W9gEneQIYwk8qeXDfaO+s6KwI7w==
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr107918542pla.235.1560769304705;
        Mon, 17 Jun 2019 04:01:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2kguIAL6mZwPwsweC3SsjpOuuzgJrgWjURU55+SBjNoxlIuY07rvYAtrrST3tKyBK/b2b
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr107918481pla.235.1560769303876;
        Mon, 17 Jun 2019 04:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560769303; cv=none;
        d=google.com; s=arc-20160816;
        b=ta/+62qjCcE6HdNRz2b7RAyxwkN45WF5NtAw+c5H5Oi7kFi8WNSE2i++KbQKxG5gP1
         0h1eU/v2BFMb9T1u3ud6UHI+AP/8hah+lFWXTpNqHksuIwqFIh313KxMDDnOXRXgRCQD
         eBWuRJ1u9doTjusJzO3itWgEgTDsLpAZPCuiGrDnlqI2lgjMxMSf2SZvSReChsImyhub
         nRjM2MA4gQJ+5hxkYM4NCPS7D4cfLpbVw8J8gS/fH3pC3IEXZ5QDRS9q4fI4WHgrci92
         ApVnGVTs7GpiWlgyxxndzi6r5+9iLNDjcNWaUEkKQEKcSlBE416FOJRsKNcbHDrWSHZr
         kJoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=Qaf+B9Yr7ALXcLt671oylbmPh3oUBy5ZfluH2fNwOPs=;
        b=hkUbhTuUbddOZDyPp1WkqU92pSUOub1BKt9x1yJnpsHz++eR8ov7yXq/40jy+gbw5y
         0ghByJHH1Wrwne/gugSSRJFsYSJK30LXLwS9uTKtapz+ywidAWrvyW4HhLOdFKuI3/kC
         BTT6zUCcr+M7l2+bWr0cyGM80Afw5WcHXIq6XvyQxez6iD6T/AtPGqBiydap6FrPZ3Dd
         c/fdM/KhzuB2BojMeF4XazkfR5kruOi6Vz8URq155absxaN84nrf6gQcu5Yp514J1dnK
         zSJbXLuh8xhdIVh4jivI7i+Y6MhxdHWPHUKCa9WELYMpqvH9cIeWRtDUVdm9kypYyKVy
         WmGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id z8si9602367pjn.51.2019.06.17.04.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 04:01:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 04:01:43 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga006.fm.intel.com with ESMTP; 17 Jun 2019 04:01:39 -0700
Message-ID: <1560769298.5187.16.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
From: Kai Huang <kai.huang@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov"
	 <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner
 <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski
 <luto@amacapital.net>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>,  Dave Hansen <dave.hansen@intel.com>, Jacob Pan
 <jacob.jun.pan@linux.intel.com>, Alison Schofield
 <alison.schofield@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org, 
 keyrings@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 17 Jun 2019 23:01:38 +1200
In-Reply-To: <20190617093054.GB3419@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
	 <20190614111259.GA3436@hirez.programming.kicks-ass.net>
	 <20190614224443.qmqolaigu5wnf75p@box>
	 <20190617093054.GB3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 11:30 +0200, Peter Zijlstra wrote:
> On Sat, Jun 15, 2019 at 01:44:43AM +0300, Kirill A. Shutemov wrote:
> > On Fri, Jun 14, 2019 at 01:12:59PM +0200, Peter Zijlstra wrote:
> > > On Wed, May 08, 2019 at 05:43:40PM +0300, Kirill A. Shutemov wrote:
> > > > page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
> > > > going to use page_keyid() and since KVM can be built as a module
> > > > lookup_page_ext() has to be exported.
> > > 
> > > I _really_ hate having to export world+dog for KVM. This one might not
> > > be a real issue, but I itch every time I see an export for KVM these
> > > days.
> > 
> > Is there any better way? Do we need to invent EXPORT_SYMBOL_KVM()? :P
> 
> Or disallow KVM (or parts thereof) from being a module anymore.

For this particular symbol expose, I don't think its fair to blame KVM since the fundamental reason
is because page_keyid() (which calls lookup_page_ext()) being implemented as static inline function
in header file, so essentially having any other module who calls page_keyid() will trigger this
problem -- in fact IOMMU driver calls page_keyid() too so even w/o KVM lookup_page_ext() needs to be
exposed.

Thanks,
-Kai

