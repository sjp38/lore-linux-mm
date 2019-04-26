Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CBBDC4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:19:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7F19206BF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 15:19:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="fM56JoE5";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="wMiizD1t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7F19206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60B756B000A; Fri, 26 Apr 2019 11:19:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E12B6B000C; Fri, 26 Apr 2019 11:19:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A97C6B000D; Fri, 26 Apr 2019 11:19:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2778A6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:19:28 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 83so2834372ybo.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 08:19:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J68SKZMWFlhNFlbbXuT/2rD7Xve6Pg3Zf1aIKWOtkLA=;
        b=Rf0FdiKxv4XOL+zIs6BvgziFcKa7ZbRSschXPRNS+XLY14Um8OXIQASYmZvba6Ad0O
         t+v84o3keqiuQWH7rcjHc5d5XPM37wCyYJiXLLf9lsqhwmyzoFII9j8a9PGtUrBcsrPY
         jZiiRO/VtW4dvO6MBXcH9c7Bm+g3oGe4sszl68Z7Y8Q27q8MC+dLixukfUUIqChJJXow
         T0LgltjNp1vqFCNmMp9avudTymIlhgPNZqAt5rpjQjo2uIrIxx9xHAEhQcVdgncfy3Ca
         T0z0EJ+4Qtmc0D09psgUiilbn84Tp6G77KFi5ykp6vTNhaLje5QpgVRggsv4VYupkQ2u
         6uqA==
X-Gm-Message-State: APjAAAU2l9prcdZnBz5CM0FPhbBqkWZn8aQObhrTbeSAYvoZgJ1yQiV0
	D5FnBSeOk6dA+q6VptfKrj1oRvCvsQQ9U0+9PTq/SHChRDpBdbCTbsbSAE8u8fNqkqykCihKw/S
	25cv/VibIoKfUC5Lu5pMLKqPvfGp3J+BuM6oAM1OxSdUyUgcoXUqJvPb23+pJbIfM4A==
X-Received: by 2002:a81:303:: with SMTP id 3mr7250429ywd.245.1556291967738;
        Fri, 26 Apr 2019 08:19:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwBArmhgDUdmjK5dgZ2/j7iiIe+Q/b1vnd991Eo7iaBMBb6ZwKwukcq7YQv3vYYBr+pyXK
X-Received: by 2002:a81:303:: with SMTP id 3mr7250365ywd.245.1556291967014;
        Fri, 26 Apr 2019 08:19:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556291967; cv=none;
        d=google.com; s=arc-20160816;
        b=eTTlwUsXV2XFxDeqaK9kKtAPRJWFxlpgKAXRdOFYVg0ZUGqbf4+0EXklYRFMqltZ+v
         SaSWfnFzzEFLr/JRP9aPz/RBl8hGi0O1T0e/i7ZwXaF1fm7eY+Pit1MuDVqhiP/EJ5yO
         LLQlvqq8fAnVUEl1c6oUfYD1wlM7crAog2amOZfQkJBK698tVKd1fSKYAWZ36WaSmDyW
         b+tUVq98fMG03oqOY6BfXyIu/nSHX2MzhWe3tf1P3S4Wp0emSzH6yiRXNd7qpnC2rwZG
         5DiMtRb3R42r2jPQP1njSgnnu6MP5Le9Y09oAqgvpW8Soo5EcAJmM5a/gTVzbo0DZ6NK
         /g2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=J68SKZMWFlhNFlbbXuT/2rD7Xve6Pg3Zf1aIKWOtkLA=;
        b=eVwsgTvOglESnsjb6PeaTlfLohAqFPa56tu1Ekgv4wwhFEsz2x8XCU4vTn/zw5ZW34
         gkT8ZIaSUhhEUBVwA43z7TQXHVTQT//qyZwLk56ktR+CnFC8oxkVb6PMlIHCkhCQaMoQ
         VTCHnT+oHqEdEuYQuv3wLXRY0/bJmAj44d3ioM/ux/VkH8vNZRA7CFBxIYBL3Lwldj4f
         rKLYQVdyoh+J+1BjZPLt00MFrreA9cqQld2H/6FzF/ynSXtdiiGCm/MNxpGTr7Fb/Q2u
         Uof7fF4uq30m4yVUqx7brTjNCh+SBoBg0jcrh39JN7eEenQlfX3CD36aUDDYNAP53gJa
         1I4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=fM56JoE5;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=wMiizD1t;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id e200si16510272ywe.180.2019.04.26.08.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 08:19:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=fM56JoE5;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=wMiizD1t;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id A33928EE121;
	Fri, 26 Apr 2019 08:19:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556291964;
	bh=hmFtcUTIxR6KLz/d5bw5os3KzZii0Jt5OxeEFe5h564=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=fM56JoE5ati7wZvsxw8+bqnORhHafkYAsczi3BkLGJzvv8CrEPOQfGMIJ8fmglnH4
	 I0fLsMTfpKdAg4K2Z7DkteyNgDqC7MeDmDzWPdf6nQxbpcpMeUKVKD/clCp1Sm+tvV
	 JwSTlLK+6ty1xy7o0l6+tAZxNDGrx5+NsMa0ddeI=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PlLHNPa9x-WD; Fri, 26 Apr 2019 08:19:23 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id B0F778EE079;
	Fri, 26 Apr 2019 08:19:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556291963;
	bh=hmFtcUTIxR6KLz/d5bw5os3KzZii0Jt5OxeEFe5h564=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=wMiizD1t9Gbvc78FIZ0oT7sBf+Bhdw8Zj9J4olOgVuOXb63DY2m6EkMzL5OwJ4cB9
	 V8drJSGDMUvV459JZLUANi6CJaA2wCrbuPrNf8EjfgRevipAGWvRPVtbIIm9Bgm0gJ
	 ETCRzhKn6Q+VjTyVslNyKpme4VCweotEJaLYK9hk=
Message-ID: <1556291961.2833.42.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system
 call isolation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Mike Rapoport <rppt@linux.ibm.com>,
  linux-kernel@vger.kernel.org, Alexandre Chartre
 <alexandre.chartre@oracle.com>,  Andy Lutomirski <luto@kernel.org>,
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Jonathan
 Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>, Paul Turner
 <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner
 <tglx@linutronix.de>,  linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org
Date: Fri, 26 Apr 2019 08:19:21 -0700
In-Reply-To: <54090243-E4C7-4C66-8025-AFE0DF5DF337@amacapital.net>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
	 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
	 <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com>
	 <1556290658.2833.28.camel@HansenPartnership.com>
	 <54090243-E4C7-4C66-8025-AFE0DF5DF337@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-04-26 at 08:07 -0700, Andy Lutomirski wrote:
> > On Apr 26, 2019, at 7:57 AM, James Bottomley <James.Bottomley@hanse
> > npartnership.com> wrote:
> > 
> > > On Fri, 2019-04-26 at 07:46 -0700, Dave Hansen wrote:
> > > > On 4/25/19 2:45 PM, Mike Rapoport wrote:
> > > > After the isolated system call finishes, the mappings created
> > > > during its execution are cleared.
> > > 
> > > Yikes.  I guess that stops someone from calling write() a bunch
> > > of times on every filesystem using every block device driver and
> > > all the DM code to get a lot of code/data faulted in.  But, it
> > > also means not even long-running processes will ever have a
> > > chance of behaving anything close to normally.
> > > 
> > > Is this something you think can be rectified or is there
> > > something fundamental that would keep SCI page tables from being
> > > cached across different invocations of the same syscall?
> > 
> > There is some work being done to look at pre-populating the
> > isolated address space with the expected execution footprint of the
> > system call, yes.  It lessens the ROP gadget protection slightly
> > because you might find a gadget in the pre-populated code, but it
> > solves a lot of the overhead problem.
> > 
> 
> I’m not even remotely a ROP expert, but: what stops a ROP payload
> from using all the “fault-in” gadgets that exist — any function that
> can return on an error without doing to much will fault in the whole
> page containing the function.

The address space pre-population is still per syscall, so you don't get
access to the code footprint of a different syscall.  So the isolated
address space is created anew for every system call, it's just pre-
populated with that system call's expected footprint.

> To improve this, we would want some thing that would try to check
> whether the caller is actually supposed to call the callee, which is
> more or less the hard part of CFI.  So can’t we just do CFI and call
> it a day?

By CFI you mean control flow integrity?  In theory I believe so, yes,
but in practice doesn't it require a lot of semantic object information
which is easy to get from higher level languages like java but a bit
more difficult for plain C.

> On top of that, a robust, maintainable implementation of this thing
> seems very complicated — for example, what happens if vfree() gets
> called?

Address space Local vs global object tracking is another thing on our
list.  What we'd probably do is verify the global object was allowed to
be freed and then hand it off safely to the main kernel address space.

James

