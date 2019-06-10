Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 397CDC31E43
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AEC6206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:13:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AEC6206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90E976B026B; Mon, 10 Jun 2019 12:13:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BF236B026D; Mon, 10 Jun 2019 12:13:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787F16B026E; Mon, 10 Jun 2019 12:13:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 419A56B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:13:22 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i3so5996983plb.8
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:13:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aHgdO29UtzVvri0V50TQMtM7S2F55KHF4sKCxD7/B9c=;
        b=PRzJgG+Puj794VJWp7GIv66VIKQ96hKshV6v3gQUF7wey/35lVcpHdG3FTDG6I5+fr
         VXajrb7d0mLaILps7ChRcJPGL37Gk6LSYBfSlhoTpuI7s5mPm1Yn9jPPRYcpNpaFl0ix
         zF678zBy0945KSSW/8eD33vrOuR9SLNjzkhmBU8tGNbH2eBU2wFpEhOmybgcuUCQtDOa
         WMIzGRhKu3VHrmWV7LdjFOXAu9r/x8/DenvPYv2w/bTQDg/pHFmMM11UyI3oZeVhV0Vn
         LSLdlCySelTNeb72O/NNiv8B3guf8zMAHrGwX4KtvaO2G0Zl/kalua8R1th9FLmydQcd
         E1lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVXNK8Ld32RDiW7lw6rO2LLW+utrj46tY2RE7y6O1c6zGdpW7aG
	n/eRUA8zl2GTK3B/Bw/SmHa2ptzYg3IfEWVLcoTRrpyzFY6hqt/BeFpuBeg61nGbZwRyFahyFRr
	QbmKBjWRWMJJVW+jnuJWIetd9yV2js1A1DYwRhK4Hg15TA7/MYF0pp4gpoV3/Me3HzA==
X-Received: by 2002:a65:5889:: with SMTP id d9mr1082017pgu.39.1560183201859;
        Mon, 10 Jun 2019 09:13:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/BXTFIaCCJL8OJcEM8+ONwhnMhB7RmU+pa/i1RvL2UexfFVHxstSFNCkFWiLKZwmNGYV2
X-Received: by 2002:a65:5889:: with SMTP id d9mr1081932pgu.39.1560183200575;
        Mon, 10 Jun 2019 09:13:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560183200; cv=none;
        d=google.com; s=arc-20160816;
        b=yF2Ahf9xdXxqCOgvl/8nm3gD5dOO4ynMVj0YT8U+N+sgULaWDx7V7c47iULhJzqfRS
         h8okB5Ws6LnbewRQMl76VsAGYDQaUTz6JFUAeXSyCWVx+FWbKGuvTMqAfd5uPQrjHRLr
         enbBjXCXeUWIRorlTQw7WLMmxvTgl392j2qXVNEheEGRlRLEHcvgi5umgEG6yy4QlFcW
         P0oAfWI4Va60ofoepYdsAI8FMJUsiSl3awnkO6m6mEVC/wSBTWsoCbM+uHbiVEwwhlCB
         sU700WlR4Ar0cWPurMNVcIAe3JsKic375ZGIQWgGWOaOWC7f+E29i6Jb8h/X33x1nR+Q
         lGjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=aHgdO29UtzVvri0V50TQMtM7S2F55KHF4sKCxD7/B9c=;
        b=Ubr3/GEFdjhwoVZrjTcOT0l7z0DicGovRmIJRPlZlAVb0I30qrJhLX9qzLykKvny1j
         m22eiBT6OpOAh/6rTdpQjxdbw74Rs5ChGI4IImnMAYzl0gxj6f4BTzGyfJ1ok0xralFC
         jSxw+UWvURGBMA9yFS28StrfZK5yHKwgAGk4Hng9XMtMfE531+Hv+r1+gPaxrwXgwxWJ
         ltcIRp4BEqJc5JM/0UK1tCryGOhPmu8Z0LmZM2mDxAkfcmlbEqEBhcwcpJtfOeLbyECz
         oJN9leN6XYQfzcJS63RZ2qzAJQ3RosxpDiJlVX0ZrKpIMHZZXAXKeeNwcw8nl+kG159I
         ae+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id y138si9930237pfb.3.2019.06.10.09.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:13:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 09:13:20 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by FMSMGA003.fm.intel.com with ESMTP; 10 Jun 2019 09:13:19 -0700
Message-ID: <5dc357f5858f8036cad5847cfe214401bb9138bf.camel@intel.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski
 <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
 <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene
 Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J.
 Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov
 <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Mon, 10 Jun 2019 09:05:13 -0700
In-Reply-To: <f6de9073-9939-a20d-2196-25fa223cf3fc@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <4b448cde-ee4e-1c95-0f7f-4fe694be7db6@intel.com>
	 <0e505563f7dae3849b57fb327f578f41b760b6f7.camel@intel.com>
	 <f6de9073-9939-a20d-2196-25fa223cf3fc@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 14:09 -0700, Dave Hansen wrote:
> On 6/7/19 1:06 PM, Yu-cheng Yu wrote:
> > > Huh, how does glibc know about all possible past and future legacy code
> > > in the application?
> > 
> > When dlopen() gets a legacy binary and the policy allows that, it will
> > manage
> > the bitmap:
> > 
> >   If a bitmap has not been created, create one.
> >   Set bits for the legacy code being loaded.
> 
> I was thinking about code that doesn't go through GLIBC like JITs.

If JIT manages the bitmap, it knows where it is.
It can always read the bitmap again, right?

Yu-cheng

