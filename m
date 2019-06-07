Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53B91C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08585208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 07:58:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="c34v2gJu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08585208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FC266B0266; Fri,  7 Jun 2019 03:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D4676B0269; Fri,  7 Jun 2019 03:58:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C1596B026B; Fri,  7 Jun 2019 03:58:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8E16B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 03:58:36 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id n4so1097493ioc.0
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 00:58:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z6UrZZzp3n14Ze8Py53PCQO3uqTMikRd3FqfmNFJBQ4=;
        b=t3aowVUq/ifhYFcS7Zo3IaFV+vI8Uid34t/WNIexQafskTX47USOJFve2ysN6iKQsH
         Y1ZF7buJ2bc7+leflCvmCTg3/pq/v+uXhAc7QabE6kc3UYtoE+w2oKPnHg1LkiztWUnX
         witBjmSZuC+ZGfXj+cETY3wLdpqdUCRvjT/oiRVruLxM/DdsYZzVFr9Uwf+LsoPU3LOf
         KfOSPTP92zF9Mt+T0HH0uc9g8HdfyBrW03BEz4IwWhuZ6surIgRMy+4Sy7RCpr8q+Wlw
         A94JU1fc91LuoW4xzJYDHEhnSHIFoRyXgHhdFjniuy/CJ59Nzs6QUy6BJ358eZK872Lu
         iUww==
X-Gm-Message-State: APjAAAV3J+JVttIEt4VHP4UtMcQX2dA7tBHxpoF00B2xY/TCkrDGXAXx
	wXIRdY4MeSf70lX/mPD4p35OkwCWta6MWOkkcjPHlX1aahJgkDntpw/Bt+8B37wnpGvGR0MLskl
	kEXD4L1mmhGW0chmXP6IMz0SjR7kNB4sBW1N0BU09rCvQVbanFTuJqMLuMYzFhrNJrg==
X-Received: by 2002:a24:7f14:: with SMTP id r20mr3104150itc.8.1559894316013;
        Fri, 07 Jun 2019 00:58:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwss+J4UaQYc5kP7nHZh52+bnk9SqgPP8TzeENbg4hEA+vMyUOXlONTIiyGmGYz38LDgiz1
X-Received: by 2002:a24:7f14:: with SMTP id r20mr3104128itc.8.1559894315377;
        Fri, 07 Jun 2019 00:58:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559894315; cv=none;
        d=google.com; s=arc-20160816;
        b=CSLLfLX0fkN++jspHpTnOX+iHHzcx0tHCQG67Ia+dB24CzVm9bU+MtNDnHuNj4RLxh
         wFVoFZAx4CfRMZYKmyaDHIVNI/MabpFXYcrTI4z9iFNnyZXyDxcWTHR1BeA9RuSUJ1iP
         3vNdBTXhdk9r+wNue9F1dDq9pnKM5xbDpjmYhJ0KUP2S8lTyo9ePmtXKnt86Ci1zXvju
         5tkEbSWpYtU3H/khF2WbJr827JmIpxr+sEPtQcMJbKoTV0qcqLiBOwlhkvhAW9jjkxwC
         J6/xCsj3e+t4No8UmuRZbstBulTfQlvMDBiAbJfDtoXe7e4Rrpbtg0gGp94dfHDRydhs
         //gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z6UrZZzp3n14Ze8Py53PCQO3uqTMikRd3FqfmNFJBQ4=;
        b=TMmXtcNiZiFGqZm0kKs4KKLK0yRpU8qyTsHU1t+xM0HD8gKJrdZ4J+ffs/cZs/p0vh
         3extD1sV/aF6tRz7rr16bDwCFCbJnMz2cXUFLbqB9dkDN5qyGYrpBZMmCsDagdDtHrNx
         SmMsbfaE5FazVUnBDTQFxMLJ72nVH0xLRouG+e1554hNffE7P5f6zBwGP3pKEodMwtd3
         zS1MNA59On65qOsSofovXRWMjhav5IanzqTpUhUs+DAUYDM8qqtQxlZ+NKgmERV1/I1E
         KUq04syN/Bp+kPoZ9uYzwf76q4pzCS2YPYhtsb8dn+gxLx+4nWJdbEheZlkIvyIfc6iw
         Vvuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=c34v2gJu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u5si1100646jam.36.2019.06.07.00.58.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 00:58:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=c34v2gJu;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z6UrZZzp3n14Ze8Py53PCQO3uqTMikRd3FqfmNFJBQ4=; b=c34v2gJu6/rQ2aR6lzQzkJp4R
	z4dwER8rHQHa20F2xwJqlwIMnaDfbzgY0t9dtmC00if5JmBXgbJwuagYcVraKs/LOpN57iEZWAQ4Z
	7t7YudJFD6qIS39i+NzbtHeGLIClaVI94mba6elh0sLE+c8QjeqhvQneZ+6vITyvsC/YlzzZf7KLg
	os1cVnpLF3vYqwamMx9h2vPERuVOJzJBX3XIOH+7iw7eyNZ7+DeblVjqaHE45hP7O5GsCdgg/mZ2T
	wAwFffH77sM5O+pS21lWtrBJwviK0lHJlsAHzQKUXtTSOrZRbG9TXAL3qKQUt76wjH7Dfc5J7d7Vc
	8UlJaR+SQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ9lX-0006Ov-Fa; Fri, 07 Jun 2019 07:58:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 3C301202CD6B2; Fri,  7 Jun 2019 09:58:22 +0200 (CEST)
Date: Fri, 7 Jun 2019 09:58:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
Message-ID: <20190607075822.GR3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-23-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200646.3951-23-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:06:41PM -0700, Yu-cheng Yu wrote:
> An ELF file's .note.gnu.property indicates features the executable file
> can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> 
> With this patch, if an arch needs to setup features from ELF properties,
> it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> arch_setup_property().
> 
> For example, for X86_64:
> 
> int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> {
> 	int r;
> 	uint32_t property;
> 
> 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> 			     &property);
> 	...
> }
> 
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>

Did HJ write this patch as suggested by that SoB chain? If so, you lost
a From: line on top, if not, the SoB thing is invalid.

