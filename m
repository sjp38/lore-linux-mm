Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074EEC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:43:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6502208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 17:43:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uUV0Qg4R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6502208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45D196B0005; Fri,  7 Jun 2019 13:43:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40E5F6B0006; Fri,  7 Jun 2019 13:43:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FD226B0007; Fri,  7 Jun 2019 13:43:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB86D6B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 13:43:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g38so1862195pgl.22
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 10:43:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ib5xcjylzZJYs4tQEX10bx6Iy6PiZBk7Yfn6HEJa6+k=;
        b=JuV0aIPt3F6WgCyvZdp5FXG7BPj60XoPxhIpdKGjYoLRI/j9ZDkMPPDA/tx6mvydbW
         hXx95Asim5jESJOtn4RwtPmSNqyCAFZpIhG1kfiHHp9OveUC9ZVJhbON2CqrcuQxTAo5
         SPLReL+M01fFkILUC8GtNiBMmPnXm13f9mMaBXZzyHoMhj7LXL1M1ZIKfVuZL2KqqYeC
         8aheYPLoPiBvXAiMOdpK8/CyDDzyk3frTOveOcbRmlFcxYfK6cqVmszpsSIFvtEDgkPs
         wP9O/6n53MGNR6fJfyAuY5tqqwoPUU0VzL29vBHWetFmGhhzncJDSOdGOQ1JXc4vvASX
         epkQ==
X-Gm-Message-State: APjAAAUwJnsjHfUu2Hz+wFZVGoJgHO4kBIFsQGzV+ALDX3ixv27mF+Tg
	od1TGRVA264vAel/M5xnZA6ANskPwI2dolqT5btKmtPsoIZ6Ak4l4OGr2DoRAbK0PMY8zpcQc20
	OMrYlykqhsVNXNahSUgUL2yHIojr0RSLCmHJ9E7EspzqxigTNsMgTgu/beNDLF5wIqg==
X-Received: by 2002:a63:7e43:: with SMTP id o3mr4147079pgn.450.1559929428323;
        Fri, 07 Jun 2019 10:43:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqEPy2h2h0BXxzj2SL79nzoTGSMQn5Z6jUYPH8sZTw/cPA8wbrm4JXtZdqWX4kZIgYzzy9
X-Received: by 2002:a63:7e43:: with SMTP id o3mr4146939pgn.450.1559929426807;
        Fri, 07 Jun 2019 10:43:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559929426; cv=none;
        d=google.com; s=arc-20160816;
        b=sovBQtFyXZfe559YU+tprsnRa+d39lsK/RUjXxadT/8s6WnTy+4nacyE6inOdZ/X1l
         J8Uk5Z+wH3BL7gNfDF/j6yWF6Y4f7kd3Vkaf0hfR4r286BJH+le7dkgA4e7lCrMCBSvN
         pvvbiUlVriaC5ubd4Ho2AYWQAEONwqnV1HcgVStDN7b0OCV9eINgIaYjaER4MFIUsZbj
         oxnRMcl8eeyNZVXW4Zg1xL53jV91TPJDzkfVHY9cXVVCITbLoCykYf3IMxvRDFciEeS2
         UwkTMW7AdnnQTsNE9o8TfFBiUjJdrO2hBk3XjzrOiTax78MB/AcI5lnrHoF/F6aa8mqO
         7Fhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ib5xcjylzZJYs4tQEX10bx6Iy6PiZBk7Yfn6HEJa6+k=;
        b=pOqCUy3dSanhzY3gWwMynHrBUnWj6RSJ6CMGsCvZlGqHSt3nNsFtHXSmVTlgfVFvCB
         bKXj3U93gAUJAKYDDiiOtgPU7B75gCf4pXGkPhR8aXL5u7SQ/P8yy/mY1bykkTLlNjum
         Z0G+aih/irTdzvJUtgxNoEeuNJsMec3zl9Sp7b/N2Jxf6VPZtnsi8Gm5TGi8w4btI+rK
         OM0DwbwohyQX6z8ptTcN+JYNVQRbOUPCEWE2u8THAeJeoThVr2R0LETprXrS8lM5vbov
         +mc56DWFiSOIcL8cln3TBi3wxvjHoVVTkfN8kxfN4cQRbTtogA6Gufa9wJaYVP/3bwij
         SRrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uUV0Qg4R;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e12si2572391pfd.4.2019.06.07.10.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 10:43:46 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uUV0Qg4R;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ib5xcjylzZJYs4tQEX10bx6Iy6PiZBk7Yfn6HEJa6+k=; b=uUV0Qg4RLvuFztCksJatP1vun
	caXXdhBCXJ1/Zff5BaFrpqzvOtmY792iqKlflcEH7L4Ds+nzOZdE00i9/+A2QdpjUZaw8FTm5C0Di
	6a0ESgkewptbth56+PriX5BaJhJVXnuImAz3+GhDF6apj0C5KkbXzhVOPvgP9z/JpZvioXldA2ZyH
	zuy1FnNgL5zmKuiuFAWNNtxXbReWZY/rsPt+VJwglRFELnGzRDXjgtIXTDTsSXd0TqgtRtMjweOwZ
	c+Gb5zmZMbrHo49WAIM2sc6JhZRZ7FubJesd/SG9HdwisS9G3VLMjnBNop6B3+O0rZ9//FQS4z8+R
	sYPvGd5CA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZItt-0006lL-Ul; Fri, 07 Jun 2019 17:43:38 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6C02B20216A2F; Fri,  7 Jun 2019 19:43:36 +0200 (CEST)
Date: Fri, 7 Jun 2019 19:43:36 +0200
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
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
Message-ID: <20190607174336.GM3436@hirez.programming.kicks-ass.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 09:23:43AM -0700, Yu-cheng Yu wrote:
> On Fri, 2019-06-07 at 10:08 +0200, Peter Zijlstra wrote:
> > On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
> > > Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
> > > that allows execution of legacy, non-IBT compatible library by an
> > > IBT-enabled application.  When set, each bit in the bitmap indicates
> > > one page of legacy code.
> > > 
> > > The bitmap is allocated and setup from the application.
> > > +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
> > > +{
> > > +	u64 r;
> > > +
> > > +	if (!current->thread.cet.ibt_enabled)
> > > +		return -EINVAL;
> > > +
> > > +	if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
> > > +		return -EINVAL;
> > > +
> > > +	current->thread.cet.ibt_bitmap_addr = bitmap;
> > > +	current->thread.cet.ibt_bitmap_size = size;
> > > +
> > > +	/*
> > > +	 * Turn on IBT legacy bitmap.
> > > +	 */
> > > +	modify_fpu_regs_begin();
> > > +	rdmsrl(MSR_IA32_U_CET, r);
> > > +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> > > +	wrmsrl(MSR_IA32_U_CET, r);
> > > +	modify_fpu_regs_end();
> > > +
> > > +	return 0;
> > > +}
> > 
> > So you just program a random user supplied address into the hardware.
> > What happens if there's not actually anything at that address or the
> > user munmap()s the data after doing this?
> 
> This function checks the bitmap's alignment and size, and anything else is the
> app's responsibility.  What else do you think the kernel should check?

I've no idea what the kernel should do; since you failed to answer the
question what happens when you point this to garbage.

Does it then fault or what?

