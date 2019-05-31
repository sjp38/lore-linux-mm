Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6F6BC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 931F026D5E
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 17:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EAUDatB5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 931F026D5E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E6D46B0010; Fri, 31 May 2019 13:49:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BEA06B026F; Fri, 31 May 2019 13:49:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 110D06B0272; Fri, 31 May 2019 13:49:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D01386B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 13:48:59 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b69so6798049plb.9
        for <linux-mm@kvack.org>; Fri, 31 May 2019 10:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ox5SYttOkOuRXfS7cs3JsHQ+R0GLTw4N6BHjQRoaW9E=;
        b=ht39l/tCs93dWK1LaILe6RcM/VNZUJ5mJcvd2CvZRvHX2SXBJuGLUDZMYUXN6A/2Xf
         if+pjsNlRQ/0SgXo9J8KEBctCAYfEdGXK66KmDLKslzQCOiJSjMuRD58GvogqSipz7xX
         WJRvBkSd+gBPxAkbBrh+0BqWFsxb7XFg7wrULCureqZ+MZgHbDgqYt9VQIKLNS4fcH5H
         tFtd7kLIVy4nRAWl1PDLM3c2wZWgqnFR3Y3l164DP96ivwK7FYRqQwuqCtFP+okl2q3r
         ymcCqh5bT1Ot+6cEi2ER5FgJvSxywP6hUCW6/coNDB3dvEnrGk/OMrBVWAR58wE3hxwd
         HKVw==
X-Gm-Message-State: APjAAAUNKNTCo2+yJoBlNOzYArZI8gJn9jG94xyH1fpsbjkGx97I4O0W
	XvG1v/qwtvRAH5wwybiUcfGumBa6Q61y3JSH5ywrKc/4rUEKplc+Wi4TF9xVs2+Htxqg48KsvKB
	ZjsgCNPT3/fUSB36M/Mq1HMh38aKWGM/LcT+bffmuGPz0HQPShi9pdd3a5LlvF60wiQ==
X-Received: by 2002:a63:fb02:: with SMTP id o2mr10666418pgh.357.1559324939323;
        Fri, 31 May 2019 10:48:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuv8FCPyR02gI1e/dfNSu2pZ3/fyVk43KqFs0v5cpIJx+3iimjwG0yW3AKClSzBggdVW5G
X-Received: by 2002:a63:fb02:: with SMTP id o2mr10666368pgh.357.1559324938569;
        Fri, 31 May 2019 10:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559324938; cv=none;
        d=google.com; s=arc-20160816;
        b=l68ri08jqPrQtgq2qCaGa7Q55YJ3GPsAmHaksTt/BKaNBYypVxwP1M0njDGqOJWi7S
         5dY11C05qksWizfCVLYQeTyJV8SGIpQiXtstg2xuosF23nYwLFZqT794rCOSlQdcAjYh
         LTci9JyLCV+x3oH2a0vExmo+OHPidpq0Jp9YBcLOnhafptNtTx+lyhAKG3TNcZ1UOILS
         yTofW0+laMOKUqEJuRiolVq3CXS3bO+hvNnbJQ6HPQMNV/EDepebeewrJ6Nutr+Lp/Wl
         heRSf4Z9wIgEap7oqG9Igl68k068Qjovu23igtQ23sQ2MkIXzajTxYuxLJXiiMm4+CzL
         U7UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ox5SYttOkOuRXfS7cs3JsHQ+R0GLTw4N6BHjQRoaW9E=;
        b=lLs2T76ygHYQAt9M3+NcZZ7xYYIQFt9K1J8KUHRJs6LqoTVMstksti7X+zSibLqIAb
         I8HuPcJRY26lKPBPfee+PLe903V6YJxVvr1IHccmCXvXPuSPXviLkYBzzzH2419qAfUg
         a/3HwIUL+YWnUdmdkQuJmmFwRNjl5BSvp/I67UXAI3+q6kBofKowiQXR7hhkaLHKO/6o
         /Prv1VUavZVf2zz8qIc5h9Qmzv+x1rHn+1qN0VNW+y28mYqr6kcqDm5CBovm+PA0T5vd
         D7lZkX+ZavSB+w84SkSInIDBGrC4kRifp5LASZ4YEf1fW6iVC+QoMFt3+qeyJUNisKw5
         zxTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EAUDatB5;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y22si6824581pgj.402.2019.05.31.10.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 May 2019 10:48:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EAUDatB5;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ox5SYttOkOuRXfS7cs3JsHQ+R0GLTw4N6BHjQRoaW9E=; b=EAUDatB5hW46G9M1Ux5rKjKdO
	2gatVjjYZRPlz/Y8yieBJl+NTOqpgatgBKBU0KD4TsTPRHuOAOdASb97lecou22eiM2OapeLCzPgp
	B0i0qPk66SspAy6OJFa1NIO4ol3ItewiiFaxYuuw7LLCg6ihQcITsomL18HAh28KsH655hSpvEaXK
	xELWZ9GoG8dKe0FlwT+BYKfNw7vVZDolyKXu+JXuRall/zajJ1hcm3jvaxeoZ0nnxHMg7OjxSwtOg
	5Emd9DEvLQB4DtO5nEcmw84mXxgWLl2OJrNXW+ggkep9wq+uTLg1JfxZNt1MTnoW7sdnu4+jS5Uxt
	sHxXOWYlg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWleA-0002Ni-V0; Fri, 31 May 2019 17:48:54 +0000
Date: Fri, 31 May 2019 10:48:54 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] mm: Generalize notify_page_fault()
Message-ID: <20190531174854.GA31852@bombadil.infradead.org>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
 <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
 <20190530133954.GA2024@bombadil.infradead.org>
 <f1995445-d5ab-f292-d26c-809581002184@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f1995445-d5ab-f292-d26c-809581002184@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 02:17:43PM +0530, Anshuman Khandual wrote:
> On 05/30/2019 07:09 PM, Matthew Wilcox wrote:
> > On Thu, May 30, 2019 at 05:31:15PM +0530, Anshuman Khandual wrote:
> >> On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
> >>> The two handle preemption differently.  Why is x86 wrong and this one
> >>> correct?
> >>
> >> Here it expects context to be already non-preemptible where as the proposed
> >> generic function makes it non-preemptible with a preempt_[disable|enable]()
> >> pair for the required code section, irrespective of it's present state. Is
> >> not this better ?
> > 
> > git log -p arch/x86/mm/fault.c
> > 
> > search for 'kprobes'.
> > 
> > tell me what you think.
> 
> Are you referring to these following commits
> 
> a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
> b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
> 
> In particular the later one (b506a9d08bae). It explains how the invoking context
> in itself should be non-preemptible for the kprobes processing context irrespective
> of whether kprobe_running() or perhaps smp_processor_id() is safe or not. Hence it
> does not make much sense to continue when original invoking context is preemptible.
> Instead just bail out earlier. This seems to be making more sense than preempt
> disable-enable pair. If there are no concerns about this change from other platforms,
> I will change the preemption behavior in proposed generic function next time around.

Exactly.

So, any of the arch maintainers know of a reason they behave differently
from x86 in this regard?  Or can Anshuman use the x86 implementation
for all the architectures supporting kprobes?

