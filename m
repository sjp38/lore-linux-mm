Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5A1EC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:06:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9ADDB2089E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:06:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9ADDB2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C7B46B026C; Mon, 10 Jun 2019 17:06:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3513C6B026D; Mon, 10 Jun 2019 17:06:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 218B96B026E; Mon, 10 Jun 2019 17:06:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF4906B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:06:11 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x18so8008250pfj.4
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:06:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0g11nzS+c3R6mgDXma2Z3wFsZfJv5siuRUS81jrQFQ0=;
        b=NmYaLSPzzuZgdgQzBUxz4LeAAZPH7TejxBEt32vEENTdTkoaHhilmXCcn6pALpMyyD
         4nD13I0bwWOPx99fIXPNq3V1XIPzDgngd0a/xlbI502O7V7kNA5oxgw/bcU49XV2gUEv
         vhg/YXlkB7pIejVaJkQs1lLayeeTF8mWD+tLgVApEv6x2+Ggq1cTl4ljf1EZvt/Dv6kO
         kwzHvmMu003lWV+Y+QWI6liMHfEmJQSfouAxcfdhHnaBwjMoujNerLt2i0Wvma2/oU22
         dIcLPvP+Dk0s+rydhLFmuIEhxxBdF6aa0CZt2gx1yAL/aLPF+af5MierF0EBkabWpT+U
         aWww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVEfm4QFTJRQNfu/SfmtUmBL6VZ/ALzfx1AWwhn6PQo1VJ0D0dZ
	wxn5FcYKcj2BLFbE6c8iZ8nCWNTCokhwxp1oEbRd6UrIvOlPqoOYnzdXwUmwNFEtpg39w+mSjgM
	iGjotUBdZWbN7Qo+PodS+aaXTcWIPM3uAkr+Wsrfwqu7OqaEJZToQ0CR/BCvlOKwKMA==
X-Received: by 2002:a63:fc61:: with SMTP id r33mr17348197pgk.294.1560200771439;
        Mon, 10 Jun 2019 14:06:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypOhHEuu4ONYN2zlWgEYut7J8MGioXFeG+w15lFYFmZeK4mU1JI7VCt0pO7EnFyj0sqb4T
X-Received: by 2002:a63:fc61:: with SMTP id r33mr17348147pgk.294.1560200770491;
        Mon, 10 Jun 2019 14:06:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560200770; cv=none;
        d=google.com; s=arc-20160816;
        b=vTfLyiawea/lBbmNKxvk9sVl7O6IaiiDYpK0NAxa87VRwFSiwd4rlHRIfyySjo6Mpd
         0TQsX3eu21ftclbCCuiUglDXH6zetiaQSIIewL5pZbTxCL+KOJVFkTtAb6hEzBQijf8m
         MCVRyhcgAnwQTP0NPbrx1GXyqvIowuzrXBy1sUHk3XhUiN9Gsnh3+ZXK4onHW7cEk1fl
         3gSi4h/PqJYS5p16f9TVmDhQ8UIj5wcPGOKQA5kAPgr9RBdblcl1zy7oT6O0ElmSlq9y
         mtnn6yqqEKPbKTwgQWS+PQU5kMp9c0UiL3QpR/p5jWrYb7G+q15oQUeK+ELLfPdkg/lx
         Se6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=0g11nzS+c3R6mgDXma2Z3wFsZfJv5siuRUS81jrQFQ0=;
        b=a0KUy6s/not+x6y3CiZsp1kH6ouSscQt7eEiIbWwgqnniLEo2PcQllH2yZcZGUXSZI
         /a3mjD638PbJAghw8dIwxKvlxfJbRNLr/oY0CHVJJ9CrEEr6JUTa5NEOCXZx2QJ3ZZMk
         l7UrR0TOnAYfzHG7AiZNr+UybsqCO2iBYyumSiAT1629xzpmti3Zo2H1q91/wEjjyaf7
         YWDtrdQtKiDhwT3ay0vIwQPZdLAZP+D8DWK6qy/ky1QUjzNF7PQY32+HTkoZsC5lgPAO
         S3tDeXIuRjmHAZx5KrGFw9kU6X4B6pYoloQ9Gt02I8dYbtAVH74ABDTw/+to0yawoECV
         EpAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id bh2si10791104plb.430.2019.06.10.14.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 14:06:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 14:06:10 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 10 Jun 2019 14:06:08 -0700
Message-ID: <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
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
Date: Mon, 10 Jun 2019 13:58:01 -0700
In-Reply-To: <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
	 <20190606200926.4029-4-yu-cheng.yu@intel.com>
	 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
	 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
	 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
	 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
	 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
	 <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
	 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net>
	 <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
	 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com>
	 <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
	 <0665416d-9999-b394-df17-f2a5e1408130@intel.com>
	 <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
	 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-10 at 13:43 -0700, Dave Hansen wrote:
> On 6/10/19 1:27 PM, Yu-cheng Yu wrote:
> > > > If the loader cannot allocate a big bitmap to cover all 5-level
> > > > address space (the bitmap will be large), it can put all legacy lib's
> > > > at lower address.  We cannot do these easily in the kernel.
> > > 
> > > This is actually an argument to do it in the kernel.  The kernel can
> > > always allocate the virtual space however it wants, no matter how large.
> > >  If we hide the bitmap behind a kernel API then we can put it at high
> > > 5-level user addresses because we also don't have to worry about the
> > > high bits confusing userspace.
> > 
> > We actually tried this.  The kernel needs to reserve the bitmap space in the
> > beginning for every CET-enabled app, regardless of actual needs. 
> 
> I don't think this is a problem.  In fact, I think reserving the space
> is actually the only sane behavior.  If you don't reserve it, you
> fundamentally limit where future legacy instructions can go.
> 
> One idea is that we always size the bitmap for the 48-bit addressing
> systems.  Legacy code probably doesn't _need_ to go in the new address
> space, and if we do this we don't have to worry about the gigantic
> 57-bit address space bitmap.
> 
> > On each memory request, the kernel then must consider a percentage of
> > allocated space in its calculation, and on systems with less memory
> > this quickly becomes a problem.
> 
> I'm not sure what you're referring to here?  Are you referring to our
> overcommit limits?

Yes.

