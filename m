Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE98C31E51
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 00:04:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B60F2184B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 00:04:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B60F2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B90416B0006; Fri, 14 Jun 2019 20:04:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B40686B0007; Fri, 14 Jun 2019 20:04:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2EBE8E0001; Fri, 14 Jun 2019 20:04:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF196B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 20:04:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y187so3019393pgd.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 17:04:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5mT9tJ2INLNtwB+it3Tg4tF2fNd8znWytbxNERoLzm0=;
        b=FMcyWlr/nSe9bofV0ujAj4/0Zm5acKjwtjLyJ5enW5xxHvrWsBUFwkR9t8qr3XGW/O
         TQVfxUCAji9GmGo+eEXRrPMzvSDv1mS0sUhPyJ15XoV2nxsBvA+TQWZ3t9Rui/Xt87UM
         RQeYzhh/F7ByibeVV/MYrpEnmd5q3P0J+SF2ROuVWlDJDsGu7CI+GlpI+a/4L6hs39sZ
         4B8UwsrGz8YFlLURWQMXZaMYzSSbSs6I273wuMaEayIEstErF2w3mMQmABoZVkH2LHta
         3ENy1QnRyF2QlWpAmwuAUSWuJxof2jFZw/hkqxwC8ESvMS6IADcAMrsZGJ/Q8wgGObp0
         0l7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUrigioDKqRVHw3WIjd+xcS+qbYhbfD+REHym7DbUI/VZiLQDRg
	11IH2AGIWGxe3Wqu8OuE9MnVkbGmOcbgb4F9K/3BwXhGq/nAMdb5o1baU4bh+dUPMG8sIUB91xy
	7YCp/9oMjiC5u3sW+tllc7bBuJIqqjlXmJWo6Y11DIoHwWVUFcKnhfEZ4eKUibiwBjw==
X-Received: by 2002:a63:5207:: with SMTP id g7mr36953702pgb.356.1560557041005;
        Fri, 14 Jun 2019 17:04:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaZWVZEKLMGMlIgXBxMjEmwvg8zpDHd/sDTA5RI/iGROs+IeA6SMXE8sEapX12RJTnNclJ
X-Received: by 2002:a63:5207:: with SMTP id g7mr36953642pgb.356.1560557039960;
        Fri, 14 Jun 2019 17:03:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560557039; cv=none;
        d=google.com; s=arc-20160816;
        b=GUPwobgtb8cOhzoASs9LsoVkLBpNSVWqAA+C6DCm4pmUv/k8ZJ+Cd1hVsROMGS1tZ/
         0XlGKdZ5kOnbogui2LtcT90+3DVJwS53U6vO0YlY51o2wdrQh5yGO0IP+Vv2LxiF0KC9
         8RRfw7ATpygcZxhK3Uoo6lbA7DTtfkeoRICBvm1btXKb0vaIE7b7IVaQyOkCq6jiYa4h
         1d5uYdD7dZePL2i242SMyOoO6qh4QCoBd+85e8KYiwfeGBn4eqqaio8vWQpVN4RPl0rr
         fb1KlonP2uQgBKhPCUVohaiaK+h6So/YeC5PzFbLbKuR/WcAZhVZQ3y8oKd+SXa0/jhS
         iq6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5mT9tJ2INLNtwB+it3Tg4tF2fNd8znWytbxNERoLzm0=;
        b=HYcoedkHutgcGsqspZGHrNc+PuqnKmxizhqldwfzCGxyXkbNp+cmCkRd3XdgXKjNU0
         0NfVif1qzIA5t1oGl4JnLRAl1ARLx/UN+CdsDQunSXKQxqdcP+hBL4/fcPz4X54LUFlA
         M1R49xgcBTYdDlsT02FeT3V5s0uJYbkPTte09mWr0ZKWzIrNyHv3CySwmAaiqKnrUUFh
         818BrPUeH8LpY1jAFr0D+eg+AQw9Sf9rOzGtx77U5g0rP4UzVGISeWEjagpOxGXVszEg
         9s8B2nWiJHz2R2ZeXp8pZABtq1ioxD4CYmpC/kmX5RNHyajIeUOl6x8T4/ZZ43vZBnK1
         Ur/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d2si3745021pgc.75.2019.06.14.17.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 17:03:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 17:03:59 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 17:03:58 -0700
Date: Fri, 14 Jun 2019 17:07:05 -0700
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
Subject: Re: [PATCH, RFC 47/62] mm: Restrict MKTME memory encryption to
 anonymous VMAs
Message-ID: <20190615000705.GA14860@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-48-kirill.shutemov@linux.intel.com>
 <20190614115520.GH3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614115520.GH3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:55:20PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:07PM +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > Memory encryption is only supported for mappings that are ANONYMOUS.
> > Test the VMA's in an encrypt_mprotect() request to make sure they all
> > meet that requirement before encrypting any.
> > 
> > The encrypt_mprotect syscall will return -EINVAL and will not encrypt
> > any VMA's if this check fails.
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> This should be folded back into the initial implemention, methinks.

It is part of the initial implementation. I looked for
places to split the implementation into smaller,
reviewable patches, hence this split. None of it gets
built until the CONFIG_X86_INTEL_MKTME is introduced
in a later patch.

The encrypt_mprotect() patchset is ordered like this:
1) generalize mprotect to support the mktme extension
2) wire up encrypt_mprotect()
3) implement encrypt_mprotect()
4) keep reference counts on encryption keys (was VMAs)
5) (this patch) restrict to anonymous VMAs.
  
I thought Patch 5) was a small, but meaningful split. It 
accentuates the fact that MKTME is restricted to anonymous
memory.

Alas, I want to make it logical to review, so I'll move it.


