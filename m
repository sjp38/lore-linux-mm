Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7F33C31E4E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 871B62184C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 22:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Y2t0/2mr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 871B62184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 207326B0008; Fri, 14 Jun 2019 18:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B7F76B000C; Fri, 14 Jun 2019 18:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CDAC6B000D; Fri, 14 Jun 2019 18:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B55E76B0008
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 18:44:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so5527009edc.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=h2YsZJ/hpz/dktPd7lJ9/WdLKqP8cOEcDv4gWF/xH7M=;
        b=rsGg/mMGK2ZP8YHQ1KdQ7xxKtREVUlsy0a0ryzqhQM/qX57CRyduCwCmHOYr/76gQq
         wldYbJDSMcJLiFjnSvp5hNuuytq7X3Zyy8DJndvWRTtOEk/gKdNyiUNuSgTyyz+GR7si
         QXB4s24bR49FxcHCpdpkYIK04AxXPlzoLEMb4k67VP83wqvKQ5HRq7DVnrqcJnO/5UrP
         4goCd+qx5ZyRh2/HypJpEx5zf5Jwp37tFvkC5vWIKpJOcVM6zdY/SwqWyC9q1+6idVSb
         7gzYJf5NikmughFd0LxdmG+yOfxVV9ug41+rXKkwERYSxuZKIYiMrulU1l2VNbndd0Ya
         ZnEw==
X-Gm-Message-State: APjAAAU+HyYeMm7oRF7EOX4W9+/kY0Yp2oilmFm0DPKsd6uR90mAtVNw
	OuKt2+3I3QIIN0Lj4vgagjFb6jqWNkbRXjC3GYl9RRzer/X7SLoOugeQV9j56BWxMjlY2uNSGy4
	j8Utkx9vVSSRbglayDL+efLYQnLvP0M+lXHPVaUrYOa2X4q6GKNgw7coYa/NisFrh8w==
X-Received: by 2002:a17:906:614a:: with SMTP id p10mr34708551ejl.267.1560552284283;
        Fri, 14 Jun 2019 15:44:44 -0700 (PDT)
X-Received: by 2002:a17:906:614a:: with SMTP id p10mr34708518ejl.267.1560552283581;
        Fri, 14 Jun 2019 15:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560552283; cv=none;
        d=google.com; s=arc-20160816;
        b=Ye0CXqbC9+z8qYvvWclGHRTx6xixOeqzHfCY3rgRJZkjHOuJIMy0HkUb2opOKtqjh4
         5Pu7iFGqV9WIj9nLijtwfiL3kG6HPsEFSaYHi7Bnj7h6BqoMfQ9LPnYoEgcW4l8fRDHn
         v6xVRJWCMDiGzvSqaP4u2UkUYQgS+5D/3Jafffz0TRJWsOhSO3GO+INnQaU81nuu62ov
         AIB7H/EH2rKRExJjuNlI44qpkd87tbKfJt4ByoQ2+MLUTdZYdsEKVBJPWbB/pL6Mj70c
         AKULl1LsBTJJEK9iOcZNBTTfleUWu9cRTDH13XAN/7YXivx//8J1071R/Auht/AEEoQ+
         +Llg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=h2YsZJ/hpz/dktPd7lJ9/WdLKqP8cOEcDv4gWF/xH7M=;
        b=qIBEN2z/E709+h31ztbwaHM5ti+XA6XgTLbgOIvImPX99CDDugDdb0vXeJz9E+4sRe
         dOBP1LWI2AjWMXLF7ujf17qOdcPu4kIMyj3vEq5X0mCR0pNi6Eym+nqQ+jSMXAdVh5yN
         VwYF5aXhShfJB6RJKoxk8p5Ou1sGyK9WhLI6wbWJmZOyCkDooU7ArUOgmA3Nfd0mFwFq
         wsxDCptWyFLbQfsoXjMRJqQMbS3l5TjfOcj82eiLWXwVNwzda0lp/MBS/96CcvCIjJAE
         CqhYE4QEundC/5VHJquwZA8L5RGZesrXLi9Zm/Kx1f9aiNJQE87OPdGZS1jNH/Dt7f2k
         C6cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Y2t0/2mr";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20sor1352181ejr.35.2019.06.14.15.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 15:44:43 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Y2t0/2mr";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=h2YsZJ/hpz/dktPd7lJ9/WdLKqP8cOEcDv4gWF/xH7M=;
        b=Y2t0/2mr8aihOd4yjitVfbPHHMKDHwZD9B6ADKgMF/1yloLEFDKbVCRHfVvaojZBhW
         X9iJJUE6HuWUrExWayDRtjj+0OY9xfenQmbiD65VYnZPJOUFGdTbi3xuEA07tqg3ncbv
         ajDe+y4rUbN/CGxSwjohrEi6tZZ+rb0czHc523vfaeBuj/plC1g5QA1E/xwdWDUbC4Hd
         RklEBmoxmZUKNVrU/LEZqMvsSeLzhM9NmIDLrG2hAKwrIZM2QBMIxo1U2J3pm1Yk5ZQ5
         p0ydX7NAPzB8rkCRYyO5wZUKpOOL548iP7pggw258oF7RxeVGfPE4TrDcwadMkWMbA1a
         BUNQ==
X-Google-Smtp-Source: APXvYqzu11aNlHQ8Ctnz/nojH1rYOSaIZ8gUOC9DmalwLiJMfeuh07K661B4hMO+kTvku1uEQp/sMw==
X-Received: by 2002:a17:906:b2c6:: with SMTP id cf6mr66162140ejb.274.1560552283205;
        Fri, 14 Jun 2019 15:44:43 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j19sm1212825edr.69.2019.06.14.15.44.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 15:44:42 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 42D7D1032BB; Sat, 15 Jun 2019 01:44:43 +0300 (+03)
Date: Sat, 15 Jun 2019 01:44:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
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
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
Message-ID: <20190614224443.qmqolaigu5wnf75p@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
 <20190614111259.GA3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614111259.GA3436@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:12:59PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:40PM +0300, Kirill A. Shutemov wrote:
> > page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
> > going to use page_keyid() and since KVM can be built as a module
> > lookup_page_ext() has to be exported.
> 
> I _really_ hate having to export world+dog for KVM. This one might not
> be a real issue, but I itch every time I see an export for KVM these
> days.

Is there any better way? Do we need to invent EXPORT_SYMBOL_KVM()? :P

-- 
 Kirill A. Shutemov

