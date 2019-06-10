Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A64EC4321A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:37:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C67B2086A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:37:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C67B2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C0526B026B; Mon, 10 Jun 2019 19:37:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 971676B026C; Mon, 10 Jun 2019 19:37:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EA736B026D; Mon, 10 Jun 2019 19:37:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46DBC6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 19:37:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d3so4954522pgc.9
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:37:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=H1S2pQ/cW7XaPQ2P/0+dlh79Tx9mxw0i8MrR+rRrwx0=;
        b=rfhOCgP/2BtuvOCKnU5UDnKc2INwlHmdUiLELPWNPHWmuubZ8uAbBjUw51gSkroUO2
         cJaC6c2MHDTB1JAwTZTiGJKWSFpttAvaMpWr/vF/52991HNen4FybRaSZNApxU/ALLz8
         uMzeJgRQ7iHGDczBBegrl2Pk747mfSHON7JyWutMyWPOUsb0ezZOY50jEwDyc8PeeVjT
         bESADaTt+mS4Q5wkDbjQpUtum1NfKTExEV+BYYJWvM4KP5jC7FR2YBTFxznXlJiTUeL+
         7D32ot6VmdgmizxF8ihEeC8O2WqmShO9RP2J5deM0d1AP9fB/Vv65vcEKt+Z2L675KE+
         yp4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVk9WrMy8rCeclG9Fb3FKBvvRbSH2GMJU5WOPGiwF+0cs8cirRm
	hRdur0YAtCoOvN296WtQ7AYOTkWm9Ebsov4w9rncNcK7PU7+lzrHj9jhK8cxdmMxDTmHDznOavN
	wrA8fi3HLGqFUxfme76MfHacm2j7nDXuJHnOIQLdZT+WHnAu2dNtrtrFt1SdfuP/CYA==
X-Received: by 2002:a63:ff23:: with SMTP id k35mr17570336pgi.139.1560209832829;
        Mon, 10 Jun 2019 16:37:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/DWRdsskalKJ1agCsy4axIjyYnMa3gY55es3NpXzitA/R4fPg2IPaAu1RpGzvK8uxXvDZ
X-Received: by 2002:a63:ff23:: with SMTP id k35mr17570297pgi.139.1560209831935;
        Mon, 10 Jun 2019 16:37:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560209831; cv=none;
        d=google.com; s=arc-20160816;
        b=Dzb6Adp9f8Y+JG1xzFWS/Iek4gOvqlJJH1L/Ss5z/9mpHx9Lka4094wA9DULxHZnWU
         KjlMJIK1wwCp8gCFUUTFxtQKtdI63Xso0DRxD15yLqXrpnyn7yrY7ikhGoe11iI3NSiX
         pVaw9jSD72ZkgQUuOspU+9jGIE3mAUx8cg5pCcBwHY37yMrqj8D5z+EI9B3KNHk+8iub
         C3a3EdwL5fRMGC7zXt8k6E4xIyU+WQJqd7cIKTVP/1zeg1nap+8rytzFe042kP7AVl8O
         T0zC0jfzf6ZoeNEhNFyb6DJFSSxeDKevJlkFIV5vY6/FOtKBUC49ioYVVtD0CV4QTLCJ
         Ju8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=H1S2pQ/cW7XaPQ2P/0+dlh79Tx9mxw0i8MrR+rRrwx0=;
        b=DzV8UKFrvaQ+bM1SMfd3Py2DflJ8CprGQ/5hY6hyFmSPuWCWZ1m6fls/og9Zjg33FJ
         Tn17zfHVEQlulq6k264ajh9/YLty08QsEugpTAPZE0Vp13xp+XXLQkn8SSdT5VnTcKg4
         fK1yyvcq8wPRVkuP/iCbiy/P9eFfRQugG7S+RpYIQUOnTNUzSLKJS+FeWynLyxMel3xn
         UGw8aUvOuK1puKjIpnouWwm5c1gyJYIsBZEEAsc9P9gMI1U/72b2uK9lHnpf4DyJIzAV
         6ckm7O65BNaGGvIm3vlbQ0cc+Cgo/ZaozNTw8w+8+sK/mvBRRqVBoWvpXTmDQKmOW7yy
         iWFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x1si732571pju.84.2019.06.10.16.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 16:37:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 16:37:11 -0700
X-ExtLoop1: 1
Received: from jkboswor-mobl1.amr.corp.intel.com (HELO [10.252.141.223]) ([10.252.141.223])
  by fmsmga008.fm.intel.com with ESMTP; 10 Jun 2019 16:37:09 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: "H.J. Lu" <hjl.tools@gmail.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski
 <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>,
 the arch/x86 maintainers <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org,
 Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>,
 Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
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
 <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com>
 <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
 <CAMe9rOqLxNxE-gGX9ozX=emW9iQ+gOeUiS3ec5W4jmF6wk6cng@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <46043aaf-7fd8-2aa1-2306-24de5bff64bf@intel.com>
Date: Mon, 10 Jun 2019 16:37:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAMe9rOqLxNxE-gGX9ozX=emW9iQ+gOeUiS3ec5W4jmF6wk6cng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 4:20 PM, H.J. Lu wrote:
>>> Perhaps we still let the app fill the bitmap?
>> I think I'd want to see some performance data on it first.
> Updating legacy bitmap in user space from kernel requires
> 
> long q;
> 
> get_user(q, ...);
> q |= mask;
> put_user(q, ...);
> 
> instead of
> 
> *p |= mask;
> 
> get_user + put_user was quite slow when we tried before.

Numbers, please.

There are *lots* of ways to speed something like that up if you have
actual issues with it.  For instance, you can skip the get_user() for
whole bytes.  You can write bits with 0's for unallocated address space.
 You can do user_access_begin/end() to avoid bunches of STAC/CLACs...

The list goes on and on. :)

