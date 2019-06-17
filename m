Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0FF8C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:10:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59EA22080C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:10:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="F60cT2pW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59EA22080C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7DA38E0004; Mon, 17 Jun 2019 05:10:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2E078E0001; Mon, 17 Jun 2019 05:10:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1DAA8E0004; Mon, 17 Jun 2019 05:10:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B38B48E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:10:47 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w17so11489519iom.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:10:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=lSBxG3pslaMoZ4q5LfNT8Zk++zn3HV9csalZ1zH5zZQ=;
        b=rEUGYEFhPf8Q3YmVLscv9iry5EZMhOb+PtlkayXoKvpwLUZuyQIE76K3aOiCypPrzG
         dHz5MM5THNtCDyIz8kcPo6MlIOeUN8XJHoFzVeOKw8LRR5SQxYc1KDQc4epeK+WBcTLZ
         RtE7WpC7OGoiTIlkS8lr2Yuf+pcR6141FwxY3aQW+2ltyaPU9eqUSOxeyVqj8Tn6+L81
         GWpRtiEZTuwG4U1JFT/k0FVHEbiFQcb1klydSZ71qyhAJw6S9D8gRC7qCpRk9ulMXUQm
         qm0aEcH20np5LKD6RSJU+jNe2xBbapMrihJqHi1GY0W+DYHVwdrOWppMnCs4cUvk7EJb
         fjqQ==
X-Gm-Message-State: APjAAAVZeWV/MQaDlkXB6+/Qkhk0pkxwN/wuRWHKYDqy0f3vPsH7f4cX
	N355jxhSvS39xT+uQFeWt/dDS9pMAnepvaHjG2BECTGkIXEnjiAH+rrSsHr8kEz15svgam0pNaU
	5n4rFXB9/W+P/HTgrdUSx2nKQgyRAVamE06B2IxOdo/kCydcYDbN/HV6Bo0KPYj6STg==
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr61307982iou.69.1560762647451;
        Mon, 17 Jun 2019 02:10:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNfdrpS7aEo6IulWbST1voRoTvdww4N6XVNFq2zLRxtAgr5RF+7BfpbZ6pO32xodsTaXt8
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr61307934iou.69.1560762646674;
        Mon, 17 Jun 2019 02:10:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560762646; cv=none;
        d=google.com; s=arc-20160816;
        b=cOGqzBriDCEGfKS0oOdM4CNIHpb0VcIbOAGyQX/jnRnLOK+2B7pfovA7Rvbc5DNFY3
         7F3WN3LScB6F/ZrZUeTdwPZWYSW8lkUjp3wcRY7F9f4fXV0S5FXglz0/VodHMN+QTfaY
         nKOgREcQM+kLDpHBWIxMHdk1uXTK2oHOvHUXU4IA3V2j36z2VU91VmI7032b0xJCbc/H
         4Cqnm9Vz8V/DRmvkG1E45XTOLuGFUp+6fReVAY2/c5jDnXfM4Q51goLtjdgk0ipvjYjJ
         LAft6Ad/siAlBWU9ost3PjCm1dLbbAX2e1uhefVLUkgbUpt5XN+cX85cGEGFlfKVXbJO
         p4hw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=lSBxG3pslaMoZ4q5LfNT8Zk++zn3HV9csalZ1zH5zZQ=;
        b=rX+muvy+P5iTWXxcG9bieeA2jS1E1vrGxkYv2CzaPhWzcLWtZicQgPz3//PCPmJ6Fb
         fQz4Tscdn3EG4lC2n5qQaSFAuAnSlxkcSaL2G8geCfaDTx0nuTukNE6MPiPDD6RR9os6
         SOFbfh8MjbfAermLBk1vfGs/iob7WFvxri4MsMcp835iBbNd/4OPhQsfZMNNxh5chwEF
         elnQ3uyzOJY0OVlldJ0DKYwXBY+lbI1WRtSyyATEfFk/togq4RDoagdPfsQ+E3otaUmJ
         aOKXb2BCnYOFUy2ZxqYi8y8OkdruQcpjnU2tOMwVGUzIxOXOf5Cj0GRXg3l8nzNG6UuO
         qpGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=F60cT2pW;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a62si15033773jaa.115.2019.06.17.02.10.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 02:10:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=F60cT2pW;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=lSBxG3pslaMoZ4q5LfNT8Zk++zn3HV9csalZ1zH5zZQ=; b=F60cT2pWFaw+0bzwXk+QRPjac
	SQSBB/T3pjj2vvFitGT/VQMox0OWHFlY644jDhByelCvdv36dXHlHs3LZfXBNZLOcSyAel99wBGkY
	dFsCansXAOcFaLXJODF/MXDuQ8yJInHw7J7paI8oo77fjHJJkvvsAKzyfXfCipuAVRZfyrQpHtdD/
	QM8OcVqmrDNHs8qOYqIJsH4Lf8t+jhkz5jV/yXzAdo16KalPAs6LpG1ubmATO7b7shkE064qeSkQM
	bPPwCnc+sKzykEJ6dtXc1BDAiu59261Ly0WOF5HSco5f1OwG4zfFkrhkepGAG9wwbbdLQXTYyNU1T
	uXZZrXUnQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcnf0-0005x4-8P; Mon, 17 Jun 2019 09:10:42 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 0782E2025A803; Mon, 17 Jun 2019 11:10:41 +0200 (CEST)
Date: Mon, 17 Jun 2019 11:10:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alison Schofield <alison.schofield@intel.com>,
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
Message-ID: <20190617091040.GZ3436@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
 <20190614114408.GD3436@hirez.programming.kicks-ass.net>
 <20190614173345.GB5917@alison-desk.jf.intel.com>
 <e0884a6b-78bc-209d-bc9a-90f69839189e@intel.com>
 <20190614184602.GB7252@alison-desk.jf.intel.com>
 <ca62a921-e60c-6532-32c3-f02e15ba69aa@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ca62a921-e60c-6532-32c3-f02e15ba69aa@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 12:11:23PM -0700, Dave Hansen wrote:
> On 6/14/19 11:46 AM, Alison Schofield wrote:
> > On Fri, Jun 14, 2019 at 11:26:10AM -0700, Dave Hansen wrote:
> >> On 6/14/19 10:33 AM, Alison Schofield wrote:
> >>> Preserving the data across encryption key changes has not
> >>> been a requirement. I'm not clear if it was ever considered
> >>> and rejected. I believe that copying in order to preserve
> >>> the data was never considered.
> >>
> >> We could preserve the data pretty easily.  It's just annoying, though.
> >> Right now, our only KeyID conversions happen in the page allocator.  If
> >> we were to convert in-place, we'd need something along the lines of:
> >>
> >> 	1. Allocate a scratch page
> >> 	2. Unmap target page, or at least make it entirely read-only
> >> 	3. Copy plaintext into scratch page
> >> 	4. Do cache KeyID conversion of page being converted:
> >> 	   Flush caches, change page_ext metadata
> >> 	5. Copy plaintext back into target page from scratch area
> >> 	6. Re-establish PTEs with new KeyID
> > 
> > Seems like the 'Copy plaintext' steps might disappoint the user, as
> > much as the 'we don't preserve your data' design. Would users be happy
> > w the plain text steps ?
> 
> Well, it got to be plaintext because they wrote it to memory in
> plaintext in the first place, so it's kinda hard to disappoint them. :)
> 
> IMNHO, the *vast* majority of cases, folks will allocate memory and then
> put a secret in it.  They aren't going to *get* a secret in some
> mysterious fashion and then later decide they want to protect it.  In
> other words, the inability to convert it is pretty academic and not
> worth the complexity.

I'm not saying it is (required to preserve); but I do think it is
somewhat surprising to have an mprotect() call destroy content. It's
traditionally specified to not do that.

