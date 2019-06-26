Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A05DC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:38:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3808921670
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:38:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3808921670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43706B0003; Wed, 26 Jun 2019 13:38:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF4B58E0003; Wed, 26 Jun 2019 13:38:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE45E8E0002; Wed, 26 Jun 2019 13:38:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1576B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:38:48 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so2194244pfb.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:38:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AqyIU3rWQpzA90sPDOX6SRMhi4r1FKCPLmdXup5eYHs=;
        b=RLuzqaLGEaHe91rIr7w8qkNzAvI077y5Sz6lcM18vZEPu7fdhw1LOFnI39tssqAONq
         VfO9gxLfAe40cHAlWpU8EON6bSqesIl6Zu9qqUXEbku6IWWZUMOoL/YcafUAqaWIIB4T
         a0GHZ0Dw2RgfDT4Gn+fw3HPqdSS20Ok4zZYsiWx+9R/7cqyempb7py7jfahzKw14XEOd
         GqTFVvZGzaHwghQFdAPaIKcyYan1BDJLpklte3Pqh1vcz34TJedscbt47qPgJs/DFPHi
         8Z1y/oc2Mim4UvVcUkTTZ8AZbXJaYxwAsI9JdvN0p79sS/2sMIMQiDW4sDMiW4awT3pq
         ooaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWtn1NTFYIlxxceUGTEmOlBBv2wWDXH24G3fAg5GiLeVIKBoXWZ
	vUEvuEcdrOigE58daCIOcdhqEr5Jds/aARbh7xacf/s7TvMCiLDEik3HwybND/c35vTQNu+s7g+
	ilgfbJSj5RcaVEhn0xjCMmg/jJTq94Ti0WwIRl4fWSkNVNlPNxBsqpWE57RhrqJjHLg==
X-Received: by 2002:a17:902:9898:: with SMTP id s24mr6651092plp.226.1561570728135;
        Wed, 26 Jun 2019 10:38:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5sqwny9gkJfJmNGucDlw78kP4Nrhrp8cZhuBlN9XNEtJXUbR4VQ804HZwLPiJm1bjdvbI
X-Received: by 2002:a17:902:9898:: with SMTP id s24mr6651017plp.226.1561570727315;
        Wed, 26 Jun 2019 10:38:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561570727; cv=none;
        d=google.com; s=arc-20160816;
        b=yQX+08+CRZYXH23Bb/EhiXfDCrxRKegoDKmLT5KwHDrNUxAmlM5J9Z3lDTi7zIh4R+
         xFrm/wBHZihlo/EqbsvlrLPt0FKolS/EGT3iX51CggXR1kCi01t8atCe4R21ETGGKCnq
         exiX1FyH/41kZC2Ncuh29ixCrv4JAynHMRjNZxdJIjp2WLD9NRajByV1xK/ggSji4Qdg
         FgRolits1pNW+7XZVIu/NKZjqdPsXDF/DTnkCKswLJ7hNBybndELvCyhslUQ/N5/Knnk
         49l35G8zPNQBN5HlpM6hNwPXwlAoSRmJvglJTDDE6z3X/ArqOJ78nZIifWBkqWugt+5W
         xhbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=AqyIU3rWQpzA90sPDOX6SRMhi4r1FKCPLmdXup5eYHs=;
        b=flJw9N1o9uQvWEu7n6aPqTOxViqlYLq7raH/s8NgdyrSH089cYhaC+xShdtHQFoSmT
         2YlsKxi3CgWqeLl+p6IlncrATKGX0kv4/vToOAG9zoqCbmnbTq2ufGTioM2TZgSsS/17
         k+usNyAwE16xNS43NdscqCx5xickrAtoTtRSZUQSS05s+jOpl8/9lX/moTp730ChRpkH
         A3irONlRuoJnD1DiY6/2qPKSkR6BNtuU4WO+5QcOnbqtEOyvBXAz5edWJik4RUZ6T46v
         6gaxQcNbdEWb2jIvoxj6s0unMkcgea8sO3PxSviIGXk5etVPdwYIhgvsLX3cmSEb1KyY
         GJKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i41si2494581pje.45.2019.06.26.10.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 10:38:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 10:38:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="183217012"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga001.fm.intel.com with ESMTP; 26 Jun 2019 10:38:46 -0700
Message-ID: <9f7787e255ef859a39ea87e70132a50572f4db65.camel@intel.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Andy Lutomirski <luto@kernel.org>, Dave Martin <Dave.Martin@arm.com>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION"
 <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch
 <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd
 Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill
 Gorcunov <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer
 <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn
 <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit
 <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Szabolcs Nagy
 <szabolcs.nagy@arm.com>, libc-alpha <libc-alpha@sourceware.org>
Date: Wed, 26 Jun 2019 10:30:24 -0700
In-Reply-To: <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	 <20190502111003.GO3567@e103592.cambridge.arm.com>
	 <CALCETrVZCzh+KFCF6ijuf4QEPn=R2gJ8FHLpyFd=n+pNOMMMjA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 10:14 -0700, Andy Lutomirski wrote:
> On Thu, May 2, 2019 at 4:10 AM Dave Martin <Dave.Martin@arm.com> wrote:
> > 
> > On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > > An ELF file's .note.gnu.property indicates features the executable file
> > > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > > 
[...]
> 
> Where did PT_GNU_PROPERTY come from?  Are there actual docs for it?
> Can someone here tell us what the actual semantics of this new ELF
> thingy are?  From some searching, it seems like it's kind of an ELF
> note but kind of not.  An actual description would be fantastic.
> 
> Also, I don't think there's any actual requirement that the upstream
> kernel recognize existing CET-enabled RHEL 8 binaries as being
> CET-enabled.  I tend to think that RHEL 8 jumped the gun here.  While
> the upstream kernel should make some reasonble effort to make sure
> that RHEL 8 binaries will continue to run, I don't see why we need to
> go out of our way to keep the full set of mitigations available for
> binaries that were developed against a non-upstream kernel.
> 
> In fact, if we handle the legacy bitmap differently from RHEL 8, we
> may *have* to make sure that we don't recognize existing RHEL 8
> binaries as CET-enabled.

We have worked out the issue.  Linux will look at only PT_GNU_PROPERTY, which is
a shortcut pointing directly to .note.gnu.property.  I have an updated patch,
and will send it out (although it is not yet perfect).

The Linux gABI extension draft is here: https://github.com/hjl-tools/linux-abi/w
iki/linux-abi-draft.pdf.

Yu-cheng

