Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC8C1C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABA9A20673
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:42:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABA9A20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 490D36B0271; Fri, 14 Jun 2019 14:42:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4411F6B0272; Fri, 14 Jun 2019 14:42:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 308206B0273; Fri, 14 Jun 2019 14:42:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEF726B0271
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:42:56 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w14so2089192plp.4
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:42:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9hN01HWSvmoIeNpCYPODXZOQLf1HGABYtKlgksj9bLc=;
        b=WbGTRExjtzHfohr3OTI5s1JjS/ZFV1nR0zqZjBv7R1Rl/KJKUR16CUz8lZcqfRAgTT
         N5zddGq8RnYKdrdL/S3DsG8xGdnLCiDxjU/CxTuJIi0xJYnaCwBH95dis18VwzjegLTJ
         IqGf2X6CjlDUw07CbkgW6aJjFNMWB0st8/Gug+wqm0s1msoH1P/wkGc33JvGVEF15aNi
         glwu5aAUOMZ+m4HnI/x9sHLEzDslm89k4JCXkCab0/7IeRlhv6Y1aTqW/SeodPBmFbWU
         qmsR2rE+WYxq2vz5xo2khD6pmvnHFrlXUJ+w5Ip88qU5dw4C0RATvu3iWZZL/WADGjM+
         iKRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV6G6IsKaPEl+Yg2AIf3ceE9PYGcmLk2AcP9hk4hNvBYif0i9UY
	KD2ndNjvOUAUJNkUac2BQSZUmzW9HjrGPD3LsfqfESSMljnd/RJpMig0clNm+bhS5CZBi5o2HCS
	De7iFzFNQ3my7HJpRRqlCGJz8Z4BscX3QNTuITwGe37lRf2gyLfbTCS78q4O95cLYuw==
X-Received: by 2002:a17:902:b202:: with SMTP id t2mr92074892plr.69.1560537776619;
        Fri, 14 Jun 2019 11:42:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz61O09RbYqoPJDXmzsKmCkdfgd+aIH2iN9fiat74fKRAVpQwfjOeiFL6ZkcjgcMUSeEJPL
X-Received: by 2002:a17:902:b202:: with SMTP id t2mr92074854plr.69.1560537775983;
        Fri, 14 Jun 2019 11:42:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560537775; cv=none;
        d=google.com; s=arc-20160816;
        b=ygHzk09k/eM33FibbYHt5DX6neAhScuMJNqo0XVKfn6GhHIZdV43QpbbZfE93imbCB
         Yj19AcofjP9UexCn+4eXCccLDNzX//3vM1yY/M124jMxNUdAWhyrcWYgRGVhfB4tOSV9
         nIikCsBZAEL0zMIBjqItdb5J2kAbdRNgIOZDNxITRhE0q25TBDfNgdbwug2czHrMsBH8
         xn0oO8Sn/VOREqcvaPp2559BaqqZFYN1AGTqKHA69mXEstalmhZDOTD+2VNPi/t9q2vm
         PY14oAf0/PJkVphc9XW05GlGr3xeciJo6qPP7jSzAIYFo/zPfJ1KyE8MlcE2fRxHnh1N
         gupw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9hN01HWSvmoIeNpCYPODXZOQLf1HGABYtKlgksj9bLc=;
        b=K8ZpvTyvS0aVjHRmLv4NZkUI2Lb/mlBGKURj2uO1cKuqPTOXH+wq7HdQuiZWMYn+Au
         4p9VW/413gvhZg5uwgECCsnOf6fytf1UtZ5tpkQcbwkmHeAQIyOd6iqiC9siL9J59zXp
         dYfq02H5yN5//O/br+OxIwVjHvfKOzQGIWfkrs0LE/ZEIN60V+tECpETGsreTa9rZabS
         CD17dm3ACGzuqnb8krePhIlxbCdWme4Zo5oRc6oPwkhA4/6BGbOTYbtmdkZPvkINnyvP
         6D42mM94J1I+mg4TIuUYqWEVK2bmpytc3EqQ03jlw/0XfGmXGCoE/aLehNjWZP2Izvq4
         PAbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w8si3173335pgr.258.2019.06.14.11.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:42:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 11:42:54 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 11:42:55 -0700
Date: Fri, 14 Jun 2019 11:46:02 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
Message-ID: <20190614184602.GB7252@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
 <20190614114408.GD3436@hirez.programming.kicks-ass.net>
 <20190614173345.GB5917@alison-desk.jf.intel.com>
 <e0884a6b-78bc-209d-bc9a-90f69839189e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0884a6b-78bc-209d-bc9a-90f69839189e@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:26:10AM -0700, Dave Hansen wrote:
> On 6/14/19 10:33 AM, Alison Schofield wrote:
> > Preserving the data across encryption key changes has not
> > been a requirement. I'm not clear if it was ever considered
> > and rejected. I believe that copying in order to preserve
> > the data was never considered.
> 
> We could preserve the data pretty easily.  It's just annoying, though.
> Right now, our only KeyID conversions happen in the page allocator.  If
> we were to convert in-place, we'd need something along the lines of:
> 
> 	1. Allocate a scratch page
> 	2. Unmap target page, or at least make it entirely read-only
> 	3. Copy plaintext into scratch page
> 	4. Do cache KeyID conversion of page being converted:
> 	   Flush caches, change page_ext metadata
> 	5. Copy plaintext back into target page from scratch area
> 	6. Re-establish PTEs with new KeyID

Seems like the 'Copy plaintext' steps might disappoint the user, as
much as the 'we don't preserve your data' design. Would users be happy
w the plain text steps ?
Alison

> 
> #2 is *really* hard.  It's similar to the problems that the poor
> filesystem guys are having with RDMA these days when RDMA is doing writes.
> 
> What we have here (destroying existing data) is certainly the _simplest_
> semantic.  We can certainly give it a different name, or even non-PROT_*
> semantics where it shares none of mprotect()'s functionality.
> 
> Doesn't really matter to me at all.

