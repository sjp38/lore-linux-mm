Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EB32C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:31:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F1C208E3
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 09:31:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RUBMKb3U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F1C208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 016588E0006; Mon, 17 Jun 2019 05:31:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09918E0001; Mon, 17 Jun 2019 05:31:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF8AB8E0006; Mon, 17 Jun 2019 05:31:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A400C8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:31:03 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id c4so7370292pgm.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:31:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=S6Eux1+C4YWs/QuUA6SdliFdoSV6T3YyLMZZE5kCxoc=;
        b=FPfK7zHzNqb0U0kZIOw/JO+UnrYu4PIEa0UOv/SGCdlxurfR4RoiSWAgBmhZk/b2AP
         jT08a/apaqWwaaz8alc82nv8fTgAwaTtKHNpOUPfGQQZO9+TmrdD1tkMDIt4r1EzgEbL
         vx1rrsOdKpOwtHz0un1lK4oQcZjNU536Ns3JRY4fQWJrROV7ciYlced1WuJ3PQB+iVdd
         0k351uO66FSWV/D+NvzmIvzWQZwFJAupEGCoRPR5IKQzpxUJgZrdt7AK8phAK1GJFPnf
         hW7mNo8a1w0o4pMO3EiGE47RY8ijNtio/+OzEe1H9czvDMfyrPQM/dTIEv4deaQ+EKCG
         uvlA==
X-Gm-Message-State: APjAAAVDJH1TKPPBmNTFt2rBp7Q2pb0EuAIim1oa2ty3tV072+99chOo
	TM+NRwtN7peM6nV7P975PoqyYjnGZq852E/QzZwo2WUj5ul4oah+dLsF4icFfHBrqTg0E/GLKBs
	4iRWLMfqUhcKayTw59c2IIyNgltm3eSreDQgZALPzhbVKfM+B40k6c7bkFWCXoWVt0w==
X-Received: by 2002:a63:6507:: with SMTP id z7mr13644217pgb.186.1560763863162;
        Mon, 17 Jun 2019 02:31:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrGUCL+an/D7IntAKEFVkS55FN+EYKYmnAsKIChyLJZTWunr47stfabZGrpDz8/8kOkuWb
X-Received: by 2002:a63:6507:: with SMTP id z7mr13644167pgb.186.1560763862567;
        Mon, 17 Jun 2019 02:31:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560763862; cv=none;
        d=google.com; s=arc-20160816;
        b=eNTQK4Jd8/lC36syzj1wknOF+Mxmc8NVMlO5AsrFb2ZC08Mz3zj2k994Uu7+NhXTgw
         TRg0nVSLs31cVKfqILGaZbF0y+4tbxU4rH3aZBCBkPlIIgFCOUEIwNjDveN/5zMf+12P
         NKHLhzsC+Z5A2koQU8DAoRev5LKEf+4CfCFCf8ytwcRqMqho219fxERYfPP4f2Mjfc7E
         DzotS1ov85bMIpstcpGqAvfVHyfTh99athxUk6QSJ47QiBdV5LhicPD+fohVZVvdGNpm
         xVs1FvNHCz0DFzoWJY4BoHy8s05Dq4Y9eBrDJnbdeTV0dDedVkEZft3N+whnj9JzpO4B
         pUjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=S6Eux1+C4YWs/QuUA6SdliFdoSV6T3YyLMZZE5kCxoc=;
        b=rlsqMnQtJRNEs0Fx7eSR5E8DDUHg4TNi93BCUvrSkDVKdCgjSyxdza7PPNSmEvPIO8
         RKIJ7B+X7D+1KjZSuSGaBv5JYX/gH0yydMkaMu+v5FLaN4j9h6EvLnVEIdVHSk+8nRSd
         a+u1xU7oqG9nAiWL33cE425DPgszzbROSFapp29yzM1qBoTpxVkebsXjYkC1yoscdQKv
         9NQ2Kklgq6Fnb/kOViZaT7l6E9GTMNf/OIqoUB0iz3VX4XNCn05ni8+Rsz7lR+oO/XbI
         mVffhxlsjZsovranwPMT/1NoqFLZ6VrANxd2tfm8AjkSiYqRVTSbnuL3LSxp1V7jy935
         PZ2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RUBMKb3U;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y4si11625602pgi.556.2019.06.17.02.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 02:31:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RUBMKb3U;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=S6Eux1+C4YWs/QuUA6SdliFdoSV6T3YyLMZZE5kCxoc=; b=RUBMKb3UfCdPutyLXQFsDEmKI
	Re6hCejTEV4R0QEWXbWr1K++kvxXqJmFehO8gKOWiiMoNlpMiQPU+ntcT1yCXHePZ+lHyf05s/0+t
	fKrO5mJAjcBO15sERkJaSnBM4UW4zaBb179cK8DbMSoNLkX2HexrlSQqGTuph4i1O5UO6U0qHoi9e
	vSrciALv3UC2tHwFxGamq+atN57Vg+H1QVVTmxGbEIo5TB4/1qBj5abfZsIVz58l6JsblHdBNTn0u
	Md3uulXM/xZzWdYAX50mjrdreT/YH0//O2BAS4Me5fkXCfird5wtoe2TiAmFC9N3ytSAqd+X7ce2n
	zPvKrDuzg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcnyZ-0005HC-RB; Mon, 17 Jun 2019 09:30:56 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 487DA20144539; Mon, 17 Jun 2019 11:30:54 +0200 (CEST)
Date: Mon, 17 Jun 2019 11:30:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
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
Message-ID: <20190617093054.GB3419@hirez.programming.kicks-ass.net>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
 <20190614111259.GA3436@hirez.programming.kicks-ass.net>
 <20190614224443.qmqolaigu5wnf75p@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614224443.qmqolaigu5wnf75p@box>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 01:44:43AM +0300, Kirill A. Shutemov wrote:
> On Fri, Jun 14, 2019 at 01:12:59PM +0200, Peter Zijlstra wrote:
> > On Wed, May 08, 2019 at 05:43:40PM +0300, Kirill A. Shutemov wrote:
> > > page_keyid() is inline funcation that uses lookup_page_ext(). KVM is
> > > going to use page_keyid() and since KVM can be built as a module
> > > lookup_page_ext() has to be exported.
> > 
> > I _really_ hate having to export world+dog for KVM. This one might not
> > be a real issue, but I itch every time I see an export for KVM these
> > days.
> 
> Is there any better way? Do we need to invent EXPORT_SYMBOL_KVM()? :P

Or disallow KVM (or parts thereof) from being a module anymore.

