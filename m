Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DC4FC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:32:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 284D52063F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:32:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 284D52063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92606B000C; Fri, 14 Jun 2019 13:32:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A433D6B000D; Fri, 14 Jun 2019 13:32:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 931BF6B000E; Fri, 14 Jun 2019 13:32:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB7F6B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:32:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so1968464plq.21
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:32:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q5k5/JkverNJynE65mNuv0TQf6hmsM4Hqx1C4iCtCF4=;
        b=N7D3DBHDVAmGJ2ps0Wcxtlcj2rB1h1sj5JQRum7E2+BetjPAzQpqjiTxTcGGzvP5to
         y4PVwbQ6digSqSfTs+qCiX1mlDfVVySYpkxBnvlv6Soke5oPHeB78Pfzl7l7HJYu3Svu
         bec9gwHgYInxJ743zY+2T6w72XDPKTrgnBz85/o4kz3J2gA2zvTI5y2ZNhALfSbHmEdL
         XNvNhlFpmJN3o3qGIVLVWmg2+Z/dFHyzNMi3yNkv+20NKGEYTK6NuPeacDoOWCJg49A2
         0BeI30yEH6d7WLzSIpwEUj9auwtc+Dx9bQoplaWhJofeUYAbcOw6dQ/WG9sZ58jNiccb
         1m/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXb1071mQMPABfF3j0JCqWUfV/IV/+MclkVrwOC7rPAafW5kT8x
	Ta13kjC3OiNAm8K4sgqEE3ld/AYkcTm9LpC1X3KM3GAPhR3cH5Xhpg5O7X+VR6gcSTIUQ2T0JAg
	Fdm/4rMZlJ0vC7vT7adcQEivMhGlaub+BOBY5IOodbIMcSpJYlCuQ3nmX0WXMIFOjSg==
X-Received: by 2002:a17:90b:f0f:: with SMTP id br15mr5911970pjb.101.1560533555948;
        Fri, 14 Jun 2019 10:32:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVpDtUX7JlriZUKq9mvNQ+AMjVaWAf1X3md3TIJNCMkPn7QaIp9v+NWkzg4Gi08njNPf9V
X-Received: by 2002:a17:90b:f0f:: with SMTP id br15mr5911929pjb.101.1560533555321;
        Fri, 14 Jun 2019 10:32:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560533555; cv=none;
        d=google.com; s=arc-20160816;
        b=hHbhZmQF8xEumKEVFsO3jhzc6y6Vj6xVkWlCuDjU+veFY3kMDPs8ujXEkqRC4DNWHK
         Sh3JGESDVRg3MNu6Urwi38vDhnaeRgNGhk0RRZmcxEIqmU2QhiYMglq5ku6zNTdzg9TL
         adqMqVrfM79dOI5Hf45w8O5igTY6sIqAUKDXjEfyySI+Nqjcz7sCSe4HK4EaxPCTzZxl
         eB5Clr8Nwbd0Wt4mf4xhWg7Bj3XXzdKxk26eyl4Iy4dLM/nPPArVqWciGfyiJoIHc0Sq
         iO+uK5S5N8henK7xntf9kz5wK+ys+TNcoY/A7MoROXNdtPwoNHLGKe+QDQcZR5lI8+yi
         UZWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q5k5/JkverNJynE65mNuv0TQf6hmsM4Hqx1C4iCtCF4=;
        b=zuXNLX1SiXkl/Q3fGR8deEq7MZ2ALWX9q3LAeuZQ+3Z2OdpDv4UEUBMxVlKNFhck5Z
         4tP8xk+pc0434c9tmtughkZ3fWG7f09bRsUBTt0Hv+D/64WFX6jNdYL2JTdIr6TGTfrg
         3qizGdGcRhZfi08Jz0LXL2gOmxsS6E5p6pL2Ip73PLdBdcPrEqqvfz+UVgyLKfSTphcM
         9uWm7XPb8xOiRTpNNTCF/ZQxQDm7sbinZbUieVC5GFEvPA9BsIka8MXzCw6ngDza7CVK
         4PYFArG31UPV1KSy7Uc2Ovr9X3xf9778dUCLd8wm2DHqBZQ+k9LdjK9Syjgj2fVklfnW
         p85A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s24si3094455pga.515.2019.06.14.10.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:32:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:32:34 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:32:34 -0700
Date: Fri, 14 Jun 2019 10:35:41 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190614173541.GC5917@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <20190614114732.GE3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614114732.GE3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:47:32PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:05PM +0300, Kirill A. Shutemov wrote:
> > diff --git a/fs/exec.c b/fs/exec.c
> > index 2e0033348d8e..695c121b34b3 100644
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -755,8 +755,8 @@ int setup_arg_pages(struct linux_binprm *bprm,
> >  	vm_flags |= mm->def_flags;
> >  	vm_flags |= VM_STACK_INCOMPLETE_SETUP;
> >  
> > -	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end,
> > -			vm_flags);
> > +	ret = mprotect_fixup(vma, &prev, vma->vm_start, vma->vm_end, vm_flags,
> > +			     -1);
> 
> You added a nice NO_KEY helper a few patches back, maybe use it?

Sure, done.
(I hesitated to define NO_KEY in mm.h initially. Put it there now.
We'll see how that looks it next round.)

> 
> >  	if (ret)
> >  		goto out_unlock;
> >  	BUG_ON(prev != vma);

