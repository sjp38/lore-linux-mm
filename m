Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F2FCC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03D022186A
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:24:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TOs44IFx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03D022186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A62448E00CC; Wed,  6 Feb 2019 11:24:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3C88E00B1; Wed,  6 Feb 2019 11:24:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83B658E00CC; Wed,  6 Feb 2019 11:24:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD248E00B1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:24:04 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v12so5215797plp.16
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:24:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=z3kxfnmBJF9JEeLTh2Qv9UfiGWUm5fMi+IhLoPJOxnc=;
        b=olN4Mz7RJX+8C1xJlDAYDBqzQOqA9AOXUNamELTd2qSyiiwTl2597CrdTP9TuIPKxY
         QREvD/ATc9kY6lWz0M94D1zIhQaAYsKdlQ5tulGR6pOe9eBX1jKLDuC9iPpeE1SrwmEU
         ipcrxbFbyUnzdSNODp92nHF5T07SJT9S1ukiFm8HSi4VtaTqLqxVb8Bh8Y1kP+fkF/4h
         RRdGt9eJzzQVFfFDKSufKIMZaR6Q7ynxL+IITVhxxBErSSDdnBnBm7J9mwWCusaZNyl6
         Xte01xNzQU/gBQ6gxAO+o2ikcJBGITTfGujerJSHYP02houP1t+IDX5oyhhWj/fUcWQo
         Uk0w==
X-Gm-Message-State: AHQUAuZfsSuPrzZGgXflyqz2FxVH/ccaZSLB+FTqaNFEqRX1OI5PZEWI
	naO1OLS9oH6Sc8PkwyMYNV1eQq+BwR62c6DMMNy8oqNjCvLZmIpGw/o9SMoW/9K4Kn66+WcR09y
	+UE4CqIW7NfBAkKGld+jlZsYPUnCz5oVySarLlO0fezL5VaeMqxkBLbi2Ol0IjgiTh/CcvHRHvQ
	zTnrz11AVgRJel+2OlPIZ8tr52tQ+AaE5QJyJPM/zYcEz8502XcvRIwpZz3LfxJ8Urfur6jR0vO
	82vJfN5u7sbKqgwwFKXfr+N9e08uZIrWUmDzGJofxdaG9EQBmBYuWq+8Jp1Mc00dz5sbt0vNEx2
	DWXbRfErT1H3EcgaJI1eSObH3PrnXWygvdLiW64QmFsbB4QFLvO9VZSVmWij/7NbGo4arWW2WA=
	=
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr11745595plr.178.1549470243856;
        Wed, 06 Feb 2019 08:24:03 -0800 (PST)
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr11745526plr.178.1549470243025;
        Wed, 06 Feb 2019 08:24:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549470243; cv=none;
        d=google.com; s=arc-20160816;
        b=Co+FDDq4CvkVz6ANpb2nmkgWHMmR0nphdZwrPnFi0I92H+ILzR8HdCKCJJqCNrSTa2
         iDDRNi+SxofPqPh8nxS5ItzASoIyJjLeHqFUXLHGr4tqfp/AvleozY9fVtX3kNM1zser
         BkNlyqY4cE8rTty544Whlr2oSIBccozpA0liMLSzjpQifsSC6KrhYA4e3M50nFLiIndh
         XFTo7hyj0PBEHcV28c8aIN4D58Z1vmJqoX+beHSt7S9iNDqcT90JPU8wFQ9VvuEQI/bU
         OsUjWixLCj9Le3kVF8S0Vgk7FYRNFqhTrLHPNr9fU3ZhKXFFhJL4NijBdI8V7I0OapO0
         8mvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=z3kxfnmBJF9JEeLTh2Qv9UfiGWUm5fMi+IhLoPJOxnc=;
        b=gqNh4VzwvLsIV3XySdiwH0SzPmjdbKODNnjhzBYA06YmDmWWoGxDgHlLfHlyN79/Kg
         2w6qxvjwQhZVcwy0x68LkqyDTNmDljtX6KQsYoPTDIhz4iFM2X7pw6CMOQrzAP1nGpbO
         6JCIG03ygbVcz3NYDJbD/GnrBzMOX36IgTriPd9efAuEJYDHzi5tVsCzeb3Iz6MZqbDa
         1ejbPionRKpOodao/v5jy4lol65CqtkAr4nbFvHCKi+81fXAc4m8PSgpBCnUSzO3QQh/
         nj5W1stjcTaPPGl7I/9+Z1u6HYiObNxmih6DnXlVsUkjgutbeXZ4p7TdIcypGXzd8hhr
         7g+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TOs44IFx;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u10sor9927205pgr.25.2019.02.06.08.24.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 08:24:02 -0800 (PST)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TOs44IFx;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z3kxfnmBJF9JEeLTh2Qv9UfiGWUm5fMi+IhLoPJOxnc=;
        b=TOs44IFxpDo8l3wywTdA3/xWWnWhN6UatDpaS2Q6+Ctt6VczwdlhJvcDxfNfoU4Qe+
         fPN7h4BtM3N/nwFPwhtz7RX+vJjiarfjv3srCVD1ioPk54nTxrIviR2d0WYwZ2UbZzns
         8RHkSe3jVDJuf5jKDl5EVK/cSt+c2onn65qGVwYnHUVWjTOVeIh/gmzSRw/8asjhx+qh
         Wtm9DcqopbqECAQKKjz2FMkQQcabxRugpgJvZsQuSjyoQ5RchXF+0XjrNqLB54qFu5TW
         FQAoQHT3WngGSERXsY5Xl2xUGuhnQPXOS/bs7r7dZzI382rEoCwlE/cpHOcINQKxSVXS
         frlg==
X-Google-Smtp-Source: AHgI3IYhw9WZpm+mywwAL0qVkE0TRXuKGYMLgGTiDU4KbP9bWqvXaHtCSLxeFym4VOZ2w2twoVYlCg==
X-Received: by 2002:a63:1766:: with SMTP id 38mr5413529pgx.299.1549470242559;
        Wed, 06 Feb 2019 08:24:02 -0800 (PST)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id y9sm9374626pfi.74.2019.02.06.08.24.00
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:24:01 -0800 (PST)
Date: Wed, 6 Feb 2019 08:23:59 -0800
From: Guenter Roeck <linux@roeck-us.net>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Chris Metcalf <chris.d.metcalf@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
Message-ID: <20190206162359.GA30699@roeck-us.net>
References: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
 <87munc306z.fsf@rustcorp.com.au>
 <201902060631.x166V9J8014750@www262.sakura.ne.jp>
 <20190206143625.GA25998@roeck-us.net>
 <e4dd7464-a787-c54f-24f9-9caaeb759cfc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e4dd7464-a787-c54f-24f9-9caaeb759cfc@i-love.sakura.ne.jp>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 11:57:45PM +0900, Tetsuo Handa wrote:
> On 2019/02/06 23:36, Guenter Roeck wrote:
> > On Wed, Feb 06, 2019 at 03:31:09PM +0900, Tetsuo Handa wrote:
> >> (Adding linux-arch ML.)
> >>
> >> Rusty Russell wrote:
> >>> Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> writes:
> >>>> (Adding Chris Metcalf and Rusty Russell.)
> >>>>
> >>>> If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
> >>>> evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
> >>>> previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
> >>>> commits listed below.
> >>>>
> >>>>   Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
> >>>>   expects that has_work is evaluated by for_each_cpu().
> >>>>
> >>>>   Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
> >>>>   assumes that for_each_cpu() does not need to evaluate has_work.
> >>>>
> >>>>   Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
> >>>>   expects that has_work is evaluated by for_each_cpu().
> >>>>
> >>>> What should we do? Do we explicitly evaluate has_work if NR_CPUS == 1 ?
> >>>
> >>> No, fix the API to be least-surprise.  Fix 2d3854a37e8b767a too.
> >>>
> >>> Doing anything else would be horrible, IMHO.
> >>>
> >>
> >> Fixing 2d3854a37e8b767a might involve subtle changes. If we do
> >>
> > 
> > Why not fix the macros ?
> > 
> > #define for_each_cpu(cpu, mask)                 \
> >         for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
> > 
> > does not really make sense since it does not evaluate mask.
> > 
> > #define for_each_cpu(cpu, mask)                 \
> >         for ((cpu) = 0; (cpu) < 1 && cpumask_test_cpu((cpu), (mask)); (cpu)++)
> > 
> > or something similar might do it.
> 
> Fixing macros is fine, The problem is that "mask" becomes evaluated
> which might be currently undefined or unassigned if CONFIG_SMP=n.
> Evaluating "mask" generates expected behavior for lru_add_drain_all()
> case. But there might be cases where evaluating "mask" generate
> unexpected behavior/results.

Interesting notion. I would have assumed that passing a parameter
to a function or macro implies that this parameter may be used.

This makes me wonder - what is the point of ", (mask)" in the current
macros ? It doesn't make sense to me.

Anyway, I agree that fixing the macro might result in some failures.
However, I would argue that those failures would actually be bugs,
hidden by the buggy macros. But of course that it just my opinion.

Guenter

