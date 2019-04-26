Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3118C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 976C12077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="ffuiVT02";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="c/LpaQH1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 976C12077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A1996B0006; Fri, 26 Apr 2019 10:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 251A46B0008; Fri, 26 Apr 2019 10:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 140FF6B000A; Fri, 26 Apr 2019 10:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id E531E6B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:44:58 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 133so2748549yby.15
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5UoLheAa6Our6G2kqP+bfcMeDCR52Ug8XMjSNEs+S2o=;
        b=XG12jSM/dO+TJ64JM5Q/9bfXSIRP6BenHmecYmrVCXq+HWBDuEr1bMTJxtYQUVTBjT
         53VRw9l2n3U1zbx8+NAMAyMsOvXTmKdkZqTPZWHEs+iWTynfSaPyp2HLfyjJSA+azamg
         9Kp18CYF5u3bz1emMGoei9K/wEF9RCF0WmVR7vZqZlR8m0s8qNN5fkR0giXHvZ+LYqJQ
         uvz5tYu6y6xLtnrDF89rfauoaata1X67vPvIBqA4AE1dw0GGhYnKaf1kXgoX+eWnQq3s
         TFBCHFjmZuy4l0utGAn7g5lbOJC0Ed5jPxFiy70Kv+ihTu7/LWpjXoxOoe9oMZVWKAnk
         MUXQ==
X-Gm-Message-State: APjAAAVxeF4DUafydZb86JaTSdzMarSY5yEfij2Qy54ZcvHygHFzRN0i
	7HrHJ6Yiy7RTFG1JLtmC1u8XeoiXUypRehzK8iYC9DBKTzsPFN4xNmKxFIMBfQJnIL6iqrtHql1
	L2/Jc+4/oONbuW2FICq2SqmP3DA/UULuwfMlZnMJV9RrCMcfxJ8BRE2/kIt5vHtov5w==
X-Received: by 2002:a25:2c13:: with SMTP id s19mr12862499ybs.254.1556289898469;
        Fri, 26 Apr 2019 07:44:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTBG4JdhKrNq4cPvyS0aph0Igc58yGG0B0MXbr0SQusPz/biGwUSACxJ7ahvfO3O5uYxbB
X-Received: by 2002:a25:2c13:: with SMTP id s19mr12862440ybs.254.1556289897727;
        Fri, 26 Apr 2019 07:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556289897; cv=none;
        d=google.com; s=arc-20160816;
        b=YnWNUVT1Sa4SmulGp/kzZctn1AaJmjQXccEJ9rQO/PYaEKpNFEil3gwPruVS5o7fwF
         gJZc846DpTIVrKriDZhrlWdWaIQyB7iPuE6Cujn8graW12q5TMmPp4UG0yToUKWI6xH7
         eoAGcsq5rKPoz8rSbcal1XVUC432rmHyBvoVl51JPqh8BZU69y0FdA2gGzy8iLfQVwi/
         Ovz+IRHvuK5/AkqWq+PjcveBX0jswZhnOUseDiLMlx8T6ZZEfHKwrB9YwHfxDWDqtqab
         WswbcV98YYjF8JbFjsbngXgIpA81+xNTSACTjpZQMCdG9mGZRd9yNSEaajgdvFwz9kIe
         6tLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=5UoLheAa6Our6G2kqP+bfcMeDCR52Ug8XMjSNEs+S2o=;
        b=Ss4Z4T7j2zKG0HfRyWVAfeoS4e6jF4m4bNTMfA+HhLpjV5bSPQAXlye5f77nv14hIN
         ybV8iS6pMQEeipQowbFxl4KuC6S8Yptf4PKD8OdPLS9dfdL3xuxcVSFeoQkCnhqnNIVH
         pXGKl8WaT0KZLWRug89Klxt1eSeN/adPY7I6Jm+NOLkWt+hIBlmKr4ibz6hA9zC7r8GX
         DK4/Tckm+RHUw48aNJP3mU4aH5KNTlzeDu9kERy0WEQqWDC4KLQgb5VyvSk3inlIB5Xk
         10xxFqx6Pn/t3G0injRm2PS4SASGzjUaQ8TvuX3eib1FLglQ1JFdGMhpfl0Xki9zeSR0
         UY5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ffuiVT02;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b="c/LpaQH1";
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id r4si18954958ybd.123.2019.04.26.07.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 07:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=ffuiVT02;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b="c/LpaQH1";
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 1D6498EE121;
	Fri, 26 Apr 2019 07:44:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556289893;
	bh=/lpGmp92SnREhL1+KYcT3K61/9XUBtMXsblw2FzasSA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=ffuiVT02EUH2eECy83dfcFNE0+vtHiuMqwZTddJQ9i72bUb2GmJPUQ/sm8EEkHcHo
	 7s5JCI+ReUKz3zqcqceM62WaH4FaV7mcJrzSJJ9K//vZ7ZHvMVxIc/EXN2dCLZlbR1
	 UdDCE3eFWZCumi1vdbW8myheF2JfXWaKFyW/2nhA=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yLJq8oWwvPYb; Fri, 26 Apr 2019 07:44:52 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id A49D78EE079;
	Fri, 26 Apr 2019 07:44:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556289892;
	bh=/lpGmp92SnREhL1+KYcT3K61/9XUBtMXsblw2FzasSA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=c/LpaQH11DqvDOWdFo9PDAdk54y15cDtOZWHQOh+8ho92pzdbvphMPwb8YYoD5uE+
	 OUqSRgNfGV5Vz7NXA3F9BgYgufxJH/U3FD64SkY5TtK0zGfILci6vulc5QFUPCVy3j
	 4dWDzvE/ru3CwOUs8x6QTjse54n1e6KVdzFT6PE4=
Message-ID: <1556289889.2833.17.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system
 call isolation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Ingo Molnar <mingo@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, Alexandre Chartre
 <alexandre.chartre@oracle.com>, Andy Lutomirski <luto@kernel.org>, Borislav
 Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter
 Anvin" <hpa@zytor.com>,  Ingo Molnar <mingo@redhat.com>, Jonathan Adams
 <jwadams@google.com>, Kees Cook <keescook@chromium.org>,  Paul Turner
 <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner
 <tglx@linutronix.de>,  linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org,  Linus Torvalds
 <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>,
 Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 26 Apr 2019 07:44:49 -0700
In-Reply-To: <20190426083144.GA126896@gmail.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
	 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
	 <20190426083144.GA126896@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-04-26 at 10:31 +0200, Ingo Molnar wrote:
> * Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> > When enabled, the system call isolation (SCI) would allow execution
> > of the system calls with reduced page tables. These page tables are
> > almost identical to the user page tables in PTI. The only addition
> > is the code page containing system call entry function that will
> > continue exectution after the context switch.
> > 
> > Unlike PTI page tables, there is no sharing at higher levels and
> > all the hierarchy for SCI page tables is cloned.
> > 
> > The SCI page tables are created when a system call that requires 
> > isolation is executed for the first time.
> > 
> > Whenever a system call should be executed in the isolated
> > environment, the context is switched to the SCI page tables. Any
> > further access to the kernel memory will generate a page fault. The
> > page fault handler can verify that the access is safe and grant it
> > or kill the task otherwise.
> > 
> > The initial SCI implementation allows access to any kernel data,
> > but it limits access to the code in the following way:
> > * calls and jumps to known code symbols without offset are allowed
> > * calls and jumps into a known symbol with offset are allowed only
> > if that symbol was already accessed and the offset is in the next
> > page 
> > * all other code access are blocked
> > 
> > After the isolated system call finishes, the mappings created
> > during its execution are cleared.
> > 
> > The entire SCI page table is lazily freed at task exit() time.
> 
> So this basically uses a similar mechanism to the horrendous PTI CR3 
> switching overhead whenever a syscall seeks "protection", which
> overhead is only somewhat mitigated by PCID.
> 
> This might work on PTI-encumbered CPUs.
> 
> While AMD CPUs don't need PTI, nor do they have PCID.
> 
> So this feature is hurting the CPU maker who didn't mess up, and is 
> hurting future CPUs that don't need PTI ..
> 
> I really don't like it where this is going. In a couple of years I
> really  want to be able to think of PTI as a bad dream that is mostly
> over  fortunately.

Perhaps ROP gadgets were a bad first example.  The research object of
the current patch set is really to investigate eliminating sandboxing
for containers.  As you know, current sandboxes like gVisor and Nabla
try to reduce the exposure to horizontal exploits (ability of an
untrusted tenant to exploit the shared kernel to attack another tenant)
by running significant chunks of kernel emulation code in userspace to
reduce exposure of the tenant to code in the shared kernel.  The price
paid for this is pretty horrendous in performance terms, but the
benefit is multi-tenant safety.

The question we were looking into is if we used per-tenant in-kernel
address space isolation to improve the security of kernel system calls
such that either the exploit becomes detectable or its consequences
bounce back only on the tenant trying the exploit, we could eliminate
the emulation for that system call and instead pass it through to the
kernel, thus thinning out the sandbox layer without losing the security
benefits.

We are looking at other aspects as well, like can we simply run chunks
of the kernel in the user's address space as the sanbox emulation
currently does, or can we hide a tenant's data objects such that
they're not easily accessible from an exploited kernel.

James

