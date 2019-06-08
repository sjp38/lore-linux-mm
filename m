Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE893C28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 20:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D5D5214C6
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 20:52:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D5D5214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ucw.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1447E6B0008; Sat,  8 Jun 2019 16:52:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11DAD6B000A; Sat,  8 Jun 2019 16:52:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 032546B000C; Sat,  8 Jun 2019 16:52:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEE3E6B0008
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 16:52:28 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 21so759200wmj.4
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 13:52:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RTjp2xeSAxDyXRORYBphlNukJB5yzn4j63QvdEaGPdk=;
        b=ngQubNTk5Q/tZhC/m5JZFHjqTajahCvuZhEBU1ZERJ1OEIycMvOJGAJW8MyDCY85pU
         3Dke6w5yK0aogd9LKyF4Dtoq8srPt1xzV1J1mXog3Sq6wMoO7z4zmllV8R+zRr9OBIQ6
         QcjaJatNyJ0Ma9CYdF8MXLOyJpUfTvRNdbAcVcbSO12IyqEJIRgLZZGLC4ikbZb/QLTf
         0CO8FkI3PQed/84Zqu0FFQc6mK09bFojP0hYR3t5Bgn5bOwmK3f4YeJ2++FuGmEocEbl
         Lke0GCPsXM2TCJLISgGCSZias4PrDb2MTkFkMqHEIAtlJSY2KuIrEK6wZwGbPN3BLJbV
         H2ZA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
X-Gm-Message-State: APjAAAX5qYgKYlfmOoQ+Edr43ZaItmTAQF/QHXbICrVp+oX7wNh5yi7b
	HhqP+wO4POU0K3KgnJs+zhMo2/kaUTRist02NBLzDwFDydPlnORfHMEH6Oi0kHaa4mAgj044O/X
	QEaQBIoDAFNSpMrJSu8GGPtrdxIaqIb3ycHuXhNWffT4octBntyQyhoOKrJ4msr8=
X-Received: by 2002:a05:6000:1241:: with SMTP id j1mr487459wrx.63.1560027148136;
        Sat, 08 Jun 2019 13:52:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymOwCcyUJbF+6LuSwQnpr9qU+Lb3BDQKgEGi89Zf1CGxp6F/39dviFHNTB3p26KFH66dBw
X-Received: by 2002:a05:6000:1241:: with SMTP id j1mr487406wrx.63.1560027146630;
        Sat, 08 Jun 2019 13:52:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560027146; cv=none;
        d=google.com; s=arc-20160816;
        b=0VDYQy0o7vtn6tS6xF6qS/n+eEiLCc6zP5BepERlZh84iVX4FKKAIvcnoawS1Gfxaz
         GQzwS5ZRCmEwuiW8pYQq0/FHwd9bwJbhDpQY9QXxnIz5ZNgxVWFByZb0/YhB7pCE0bMU
         SO14NfnvF82kYVz7n81rWNLPwgAY7mH12RvUFF5bT/dwFGhFEcE/xHXIwPRUbiqEWvyM
         2GoeyOAjFA0UZHPR90swGfpIlLJCXMrQ7YmWccbLGeuv2jsyXWLhItA6aXtIgns+H2SH
         q2uhbFtNM7EYqEGl5mP8kiZwV0qh9dk6Plo1Qiat47q3cdzB2wWyJqy8n/mLQLTdqeAV
         kTRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RTjp2xeSAxDyXRORYBphlNukJB5yzn4j63QvdEaGPdk=;
        b=dfsfLAXTyekbMT0FYBHJfzhAI7XDiH/gfEPzFQcO2bYK28ubNeBtFDCPF0VgYD0Qba
         kGt8/gP/mzzc395c1RoxgYMYoDcBQMQBJ7EnoNVMJEch/8CQuz5WI+oPZz5NydJFMd5w
         DbwmYFhZ+B8Gbeg6UjFBElAShU/hQAOn8+cpMw8XYqXdkcWN326u01nb53OJgd/BqD2G
         GivC6ZxlX295RdLMWPvbuXTzfo8I8JOXk+mVOamMSNcDtAdWkfzDZ1MTym58a91JmAoQ
         WUOFehgka0oWw3Adtw/jPitgqafTUPt7QQpTgWUFZybhUsJ1+0ueElk+uZ6KW8l/qky2
         W2/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id t9si4262396wri.375.2019.06.08.13.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jun 2019 13:52:26 -0700 (PDT)
Received-SPF: neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) client-ip=195.113.26.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 195.113.26.193 is neither permitted nor denied by best guess record for domain of pavel@ucw.cz) smtp.mailfrom=pavel@ucw.cz
Received: by atrey.karlin.mff.cuni.cz (Postfix, from userid 512)
	id BFAAC801E8; Sat,  8 Jun 2019 22:52:15 +0200 (CEST)
Date: Sat, 8 Jun 2019 22:52:18 +0200
From: Pavel Machek <pavel@ucw.cz>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
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
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
Message-ID: <20190608205218.GA2359@xo-6d-61-c0.localdomain>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> > I've no idea what the kernel should do; since you failed to answer the
> > question what happens when you point this to garbage.
> > 
> > Does it then fault or what?
> 
> Yeah, I think you'll fault with a rather mysterious CR2 value since
> you'll go look at the instruction that faulted and not see any
> references to the CR2 value.
> 
> I think this new MSR probably needs to get included in oops output when
> CET is enabled.
> 
> Why don't we require that a VMA be in place for the entire bitmap?
> Don't we need a "get" prctl function too in case something like a JIT is
> running and needs to find the location of this bitmap to set bits itself?
> 
> Or, do we just go whole-hog and have the kernel manage the bitmap
> itself. Our interface here could be:
> 
> 	prctl(PR_MARK_CODE_AS_LEGACY, start, size);
> 
> and then have the kernel allocate and set the bitmap for those code
> locations.

For the record, that sounds like a better interface than userspace knowing
about the bitmap formats...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

