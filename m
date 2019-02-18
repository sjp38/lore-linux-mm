Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84024C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 00:49:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24F042184E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 00:49:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24F042184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773598E0002; Sun, 17 Feb 2019 19:49:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7220F8E0001; Sun, 17 Feb 2019 19:49:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4D88E0002; Sun, 17 Feb 2019 19:49:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1538E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 19:49:27 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y1so10874490pgo.0
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 16:49:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=t/Tw3mg2eScR+/eDukcxRR+xCCMQN0tMQ+7ePdAhFec=;
        b=bQMrVfUovWeN7B/MeJbJvgvwRODXKbgoi89eaA5moxw/4Q6bAqbfwPAvzC1EJx1WqL
         lfe5tSpNq2iKagPopLyFx9TQxNQFjz82lXU5V2YOqFcowJ3SOqgdHIqkxJ8GKZRoWE/X
         5yOA4JKUat5aHHeYsMGnwmqpT4s7MTGELOJSiYJGkkm7Yt+AUX4Tc3WkiszSC6VJBCfg
         5eHP8M140bk+0PzEnBuQg0RVPsbelMgzz4SwlPFb5oOVJUkHrAYWdHXtBPDktPwR0fIs
         31RANd2UIbzanejCBTkQ3VZY7Rc7wGGVNmHt2NrS0MIIfTfMo7m8fZUn3N0U89szb1me
         XjkQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuZzFgreiEtSWMeyZjWlKr1suIb2AuRTJp8EV9Y4j3PMsESBNxCf
	p3jv0SUXaanq7/GsX2rm73HmikAU4OqWdGX67oaq7Kc1tvUbYw5tyjed4wLcPi5srA6FykPhKvE
	jw4rtgJTediRd447gYQrTy8WEpkw6gNO+XfK+XDrulxfBwsjf/Q/S+xU9VCa2g0E=
X-Received: by 2002:a62:3047:: with SMTP id w68mr8171281pfw.17.1550450966759;
        Sun, 17 Feb 2019 16:49:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4+0ZS6kwrbPraFWrMEzve7qqH0JecNfFm72vGCtJ2rjgCXZI8BpQTPtFKXjswJdWRCepc
X-Received: by 2002:a62:3047:: with SMTP id w68mr8171241pfw.17.1550450965894;
        Sun, 17 Feb 2019 16:49:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550450965; cv=none;
        d=google.com; s=arc-20160816;
        b=BFFF6SHcSbTvl4XTmQT3ULMAt1GLQYIivF/fajqrclYJ9BNZKdIR8eYbNB9BVF3Ica
         RJeuHTuwWSZdH2tNgqH2rrVV3NAZfuIHtjEOreU57U5HYu3EuWmtE4T/H/oiRqkaUu9M
         JzK47z0zxhacjTLCKaXA8/n6sdPGBsRRxKkO3SUN4xvyDGbmZw0CYJTb/YbRT6UIz9/l
         Wep7D6OCLRzh2J6gvfi4NhLW1KqzDKU8ZnvgTgZOwerllCIAsAQmfMebZFxoGxFlrCPt
         9QGJWl6YmVzDksbVeahtFhvPkUDFEklbv0rp1wjQTqPKIMjq5rw4xbyOhGaJAnSVBHY1
         DRFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=t/Tw3mg2eScR+/eDukcxRR+xCCMQN0tMQ+7ePdAhFec=;
        b=jrwtdG4/aomZ0UxIRia5FhaqLzO2qFn7jWoBNTsme8dEoKMlNMG8pH1phAHvXctAYX
         Stnb1dX1SeiV4neG8OsI0I1zygq1K9VXVvP4IWSSbwS/QqR8ASF/y2E56prTRWP6vSlz
         33v+DeafCDXXuM/8hwU6GnT3jETtZ8YnrA4IPvNtM4cieFt89eyzzNPEhgKVCbze59p4
         ihyfdnOPHoSF1SpRDcAsgRJaUGJPD9ZwPB1K5TuP0cbnrfQ/3qvGXGv9cf3Wzhvq6+wC
         74JSFVZvevHlwlODFsIijmlURkbKE7N1hri3uwsyOZqiixpEafHvOcI6ObAjAqNiH88y
         Jk9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id s14si4759690plq.284.2019.02.17.16.49.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 16:49:25 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 442lcd2whwz9s7h;
	Mon, 18 Feb 2019 11:49:21 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Segher Boessenkool <segher@kernel.crashing.org>, erhard_f@mailbox.org, jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
In-Reply-To: <20190217215556.GH31125@350D>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org> <20190217062333.GC31125@350D> <87ef86dd9v.fsf@concordia.ellerman.id.au> <20190217215556.GH31125@350D>
Date: Mon, 18 Feb 2019 11:49:18 +1100
Message-ID: <87imxhrkdt.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh <bsingharora@gmail.com> writes:
> On Sun, Feb 17, 2019 at 07:34:20PM +1100, Michael Ellerman wrote:
>> Balbir Singh <bsingharora@gmail.com> writes:
>> > On Sat, Feb 16, 2019 at 08:22:12AM -0600, Segher Boessenkool wrote:
>> >> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
>> >> > On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
>> >> > > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
>> >> > > rather than just checking that the value is non-zero, e.g.:
>> >> > > 
>> >> > >   static inline int pgd_present(pgd_t pgd)
>> >> > >   {
>> >> > >  -       return !pgd_none(pgd);
>> >> > >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>> >> > >   }
>> >> > > 
>> >> > > Unfortunately this is broken on big endian, as the result of the
>> >> > > bitwise && is truncated to int, which is always zero because
>> >> 
>> >> (Bitwise "&" of course).
>> >> 
>> >> > Not sure why that should happen, why is the result an int? What
>> >> > causes the casting of pgd_t & be64 to be truncated to an int.
>> >> 
>> >> Yes, it's not obvious as written...  It's simply that the return type of
>> >> pgd_present is int.  So it is truncated _after_ the bitwise and.
>> >>
>> >
>> > Thanks, I am surprised the compiler does not complain about the truncation
>> > of bits. I wonder if we are missing -Wconversion
>> 
>> Good luck with that :)
>> 
>> What I should start doing is building with it enabled and then comparing
>> the output before and after commits to make sure we're not introducing
>> new cases.
>
> Fair enough, my point was that the compiler can help out. I'll see what
> -Wconversion finds on my local build :)

I get about 43MB of warnings here :)

cheers

