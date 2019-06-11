Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EB84C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBAAF2173E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:58:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="BVKkouMq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBAAF2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7ACF06B000D; Mon, 10 Jun 2019 20:58:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75DD26B0266; Mon, 10 Jun 2019 20:58:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64E676B026C; Mon, 10 Jun 2019 20:58:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 317166B000D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:58:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 140so8365784pfa.23
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:content-transfer-encoding:from
         :mime-version:subject:date:message-id:references:cc:in-reply-to:to;
        bh=Qm0kPO1uAJ3z1V1j+us2fMRdl6WcfjHPQXtYwKhWHOw=;
        b=AFZI6z4fEetbvdOutnWA/MIkK0DQEpltZu1AY2marABuPDo07oOwE4y0JDRrO5VIdX
         RJ5MoxZcmW4joxvKFQ8yzuvzVGkRerLrncQOutXfvtu1zwJnsILejYM10lMIlLTWfvU0
         ngri8YtDvnp1rMqCY0AonvG0sBmYGaGISQsILzgyja6xY60aLUmZk4Q1ghxHwcg4t86w
         ipiIUrTEIBvmu5cpVaAQy0r6PiySpqN1zbMTTj5XT/fnFRyvnZGf/UHMV0ZSScAzV+aP
         7M1uAUUAwTkiAQRs345Dl8OKWh4VHw61yHtB68zCRBNqf1umFk83IcnpdZcw65/TtcPZ
         tD+Q==
X-Gm-Message-State: APjAAAU86f4x17OuapNuvnpxCSDVCGFR6cjYHlIEVSVn7gHlPmdX5H/P
	WbIl0Dby2k7QUMoVCkd+2irs/YxaiXepncLFDZ9pmSlEPN1EvusT3gIgUccQsN0e3r9VaPzDuVw
	X01HPgGCJQMCcj7xOXINaoW0o3wmfKlCqFmaa/uKRmSPat6XpeZ+qT79PvFKVfD/rDQ==
X-Received: by 2002:a65:484d:: with SMTP id i13mr17601845pgs.27.1560214730679;
        Mon, 10 Jun 2019 17:58:50 -0700 (PDT)
X-Received: by 2002:a65:484d:: with SMTP id i13mr17601812pgs.27.1560214729891;
        Mon, 10 Jun 2019 17:58:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560214729; cv=none;
        d=google.com; s=arc-20160816;
        b=xq0gsbxJhnWdPNWzBRUPDMIui8K3ndJp5hVn7ET/ajqQF7UnXlccoN+Cs20VhEG2M8
         wn/SW5JJX2JuiTCcj1droFDTTUArfWj8Iedvk1JmG1mgwxtkvWcHf5DRgQttsVK8vFyy
         ChXMEx75iYiBivpdqAi/odMIGVkcqij1wEiIbOlP+gqfaaaFw3F1jKme50KjXKdo9Jxh
         mzi2naKnifFn/I3H3MPKqM33Hdp2qRvTF6tHaAscfvEq+AP8cwENkjF7uEihNlwx6KJD
         LicBdbptJ9JQ6ZlRrxMZQTxgNnsqsHIt2Kg3Pn1HAXOUfcZuvAbGK04bqEVj3M87Z9mC
         Om/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:in-reply-to:cc:references:message-id:date:subject:mime-version
         :from:content-transfer-encoding:dkim-signature;
        bh=Qm0kPO1uAJ3z1V1j+us2fMRdl6WcfjHPQXtYwKhWHOw=;
        b=JIRASgc3tg4gbpIIjibmKNvAHX9DZN+6l9xzB7r77p2EBTK5r/lbA8lJXCqrMoCs1h
         tveILr6bjikFokgOw6kT5oilCsvj3xBh3FGpq5VMIuQ+DS2dShXxyrJTbZ4kZ8u/wEFx
         9zuiXgfV7nD+/FJNVhQjzZAt9qMriTrCFt8JauDkh6toQGk4VFctbAi4isBB8+Q2mvqF
         /Ie+gnPVmXd7ZnzZEUU2IclRcyAyDOZ2fbowN7dAHkbdh9gsDxqF+4mZZ05akFdCM70X
         Q3WJpSW2Pqu/H48KMx7tuliWazmj/ouuD/4XOexT5fP/aOfnJGcIgvhikFP5r7PO1U2U
         bZXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=BVKkouMq;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u19sor13516959plq.53.2019.06.10.17.58.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 17:58:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=BVKkouMq;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=content-transfer-encoding:from:mime-version:subject:date:message-id
         :references:cc:in-reply-to:to;
        bh=Qm0kPO1uAJ3z1V1j+us2fMRdl6WcfjHPQXtYwKhWHOw=;
        b=BVKkouMqizWMIp86sUnwYUIJSyRkM2G6Pe8zlryowrNTb9LFpBf1If0yNMMHqWfp0F
         aqvarMEwPlbihNns5+AGPXDpt1we54kMWHty1e5OgyiGDIetI6BtOAAyQFCAS3LvpXtt
         uzvSXO7fOA1xexLVdCqI1QOPZpKtT4lZVG077v5++zFnzHYcC3ZBSAwwFeHo9MexBqAQ
         2Hhjnsrz/HjTu2HPnoa50Wg160y84xDJPkQyFDks7AOcPsvsPIeb4DvMn/Muc/w88IXq
         lpM8C4dM7VF7To/MMIkC6rQztkpMZWTvQCV7twCTJ1I4ecG5LMDnzxqJ26KNPiGwgDTp
         +SDA==
X-Google-Smtp-Source: APXvYqxSKP4PBZdAqAyV8bIxzJS6jMTPwYPb+xhoAjdP1xT8Us29SP9WDn8Ct0Ow9eVbUjBD+yr4Ew==
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr70909928pld.271.1560214729538;
        Mon, 10 Jun 2019 17:58:49 -0700 (PDT)
Received: from [10.228.61.2] (151.sub-97-41-129.myvzw.com. [97.41.129.151])
        by smtp.gmail.com with ESMTPSA id h19sm11894263pfn.79.2019.06.10.17.58.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 17:58:46 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
From: Andy Lutomirski <luto@amacapital.net>
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
Date: Mon, 10 Jun 2019 17:36:03 -0700
Message-Id: <7E931FED-B39D-4C05-8B78-D8CF2F0EF9FC@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net> <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com> <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com> <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com> <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com> <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com> <BBBF82D3-EE21-49E1-92A4-713C7729E6AD@amacapital.net>
 <a329c4fa-adb0-09a4-7a8c-465f82e0e6c7@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
In-Reply-To: <a329c4fa-adb0-09a4-7a8c-465f82e0e6c7@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Mailer: iPhone Mail (16F203)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 10, 2019, at 5:08 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 6/10/19 4:54 PM, Andy Lutomirski wrote:
>> Another benefit of kernel management: we could plausibly auto-clear
>> the bits corresponding to munmapped regions. Is this worth it?
>=20
> I did it for MPX.  I think I even went to the trouble of zapping the
> whole pages that got unused.
>=20
> But, MPX tables took 80% of the address space, worst-case.  This takes
> 0.003% :)  The only case it would really matter would be a task was
> long-running, used legacy executables/JITs, and was mapping/unmapping
> text all over the address space.  That seems rather unlikely.

Every wasted page still costs 4K plus page table overhead.  The worst case i=
s a JIT that doesn=E2=80=99t clean up and leaks legacy bitmap memory all ove=
r. We can blame the JIT, but the actual attribution could be complicated.

It also matters when you unmap one thing, map something else, and are sad wh=
en the legacy bits are still set.

Admittedly, it=E2=80=99s a bit hard to imagine the exploit that takes advant=
age of this.=

