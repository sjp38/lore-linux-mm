Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC2F5C28CC3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8068B24036
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:09:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8068B24036
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D13D6B026A; Wed, 29 May 2019 14:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 181826B026B; Wed, 29 May 2019 14:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070806B026D; Wed, 29 May 2019 14:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C4AB26B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:09:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h7so2444327pfq.22
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:09:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fvFAcNgrd4Z1P/nlDc3TlqmFbHwnelK+ZPWrvWQOFbo=;
        b=l/0lRfMWPIxkjN/Ww4Dyc7l580vxBcZyvoYpRic6P84akkgI9E+pxtlyICRUT6BQad
         mPLIhyn8YuculXTnV6GjVJQov4cBp37umKBaxuQZ2ae7sxQ39ngIB5A71Wwg/Rp3/Mc5
         Sx/VJYu8nK840gFcuAOC/WTSumAuf4PrAI3B/5+y4d8g2ZmOPAYIwwCiuLbek12W2hfd
         qBHgSNlFF7ow0VJjB8QY5QfKLTLHBNSBjh52husuSYMJci7FUQfKJoPoWfuda6da1jDV
         uTuZBrHtFAOAFiqQTB99tqYEhqtNdqvLWOMiiJsW+4OF5Ol6zxDHri8rmvtY3fGWfXf+
         zAQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW8IP7fPEeOjX1+tcVj86l+lcuZtmRUkp18ooPF39p0vI1Mjw4Y
	UnHUwfBLSi2crtbwFpEVmy4eTtkiREZzQqetwvaKpTZdAu/ZTaTm/ao52fN2E6QRsTAizrIQTBQ
	3axo4m8HyXqQRfvxBg9xPHKyuLu2xNSfA3rtrjKlqDezj+85HiYusLlioyO/V8k9BZw==
X-Received: by 2002:a62:cfc4:: with SMTP id b187mr4111005pfg.134.1559153353473;
        Wed, 29 May 2019 11:09:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGKHud9KKtr9lsGbEVNrO9PqA+J+RvumcZ9Gn70p3Zq1bee/z0SNfKpIWkF5mopKMMaeUU
X-Received: by 2002:a62:cfc4:: with SMTP id b187mr4110943pfg.134.1559153352818;
        Wed, 29 May 2019 11:09:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559153352; cv=none;
        d=google.com; s=arc-20160816;
        b=xtTZRkO9ru2buwCdTbKWcfmHjZ2TNgXjzte89vEXb36tBMrc+a9Y/nKI2Sgx90YH0f
         NXqZzMUYxelm9K8eoi/DxvLhAnLGtP9q/yllmxM1aLrjwMDqFQHe7QBRHzb4h2r976GI
         jUDjxAyQgZMCiiECUZebbrHxba17hdx8c/uKE/AmQwmz5Y3R0++2CX50m0gZz2I60B1L
         HLC+ZbkeokY2NjpqEX+1Bc9/w12iR9gMCpdTo8BYDarcp8psr4Q8YcZ/1mjIDfOLOFyy
         woc/iKgwO5wFDE8BPmhltBDMj035J3JknJ9qb5I5ql74op8xQmcIwlthMKeb6aerU//4
         6hsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fvFAcNgrd4Z1P/nlDc3TlqmFbHwnelK+ZPWrvWQOFbo=;
        b=hwln45zfPA8a1+U9yBEU6lkurkTxMy03sdnzKHkFPz7mBNl+dE/+yEz7qbdwTP96Lg
         aNE3kMKR8On3DqCGxYO0iYYGuQDdDZ/bywzXz8kXCkqKcey6GvtndelPlsTfqa6sLEfe
         f96S0XE8NoST+6reph1MMiaYxgq04OqV87avGoWCB3ik4FRer4w5CGoAMY8XWoI8whmH
         /IkFceK/SLDOK1rIHqVzdqI5MhH+bMtcMsVzF9zEeQEOq3PBuMZ9RMHDROzwdySz1BE/
         aM6no8ht9ltDpeIrrNKQH1TsfTUWmRmHYaywmFZOu3Ei/VIgigxopmfzld7nSmX1GunE
         7dAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e127si416777pgc.214.2019.05.29.11.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:09:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 11:09:12 -0700
X-ExtLoop1: 1
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga005.fm.intel.com with ESMTP; 29 May 2019 11:09:11 -0700
Date: Wed, 29 May 2019 11:13:02 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 57/62] x86/mktme: Overview of Multi-Key Total Memory
 Encryption
Message-ID: <20190529181302.GB32533@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-58-kirill.shutemov@linux.intel.com>
 <20190529072148.GE3656@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529072148.GE3656@rapoport-lnx>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 10:21:48AM +0300, Mike Rapoport wrote:
> On Wed, May 08, 2019 at 05:44:17PM +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > Provide an overview of MKTME on Intel Platforms.
> > 
> > Signed-off-by: Alison Schofield <alison.schofield@intel.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  Documentation/x86/mktme/index.rst          |  8 +++
> >  Documentation/x86/mktme/mktme_overview.rst | 57 ++++++++++++++++++++++
> 
> I'd expect addition of mktme docs to Documentation/x86/index.rst

Got it. Thanks.
Alison

