Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A3CC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06A4020862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06A4020862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD4A76B026B; Mon, 10 Jun 2019 13:25:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E416B026C; Mon, 10 Jun 2019 13:25:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B0396B026D; Mon, 10 Jun 2019 13:25:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD226B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:25:23 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id u73so810337uau.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:25:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=1VV+xq086UX8c6jCatmwEDXtaJKBj6cnEMKuwv2eIek=;
        b=LsXYrb5oOh65q5FZXQRdPDOXqDn12WeK596opzYL86oXnyc5R0HFkwn+/BpBeBx7w3
         jy0g7Q5iO3WM3YYgg9tp6WJnjER4MMCy8ZILcFq6iPKejUY7hguHvR+eiZKcU1i7Gnc2
         8pKMk3ALOWzJh89vsAvMaI3ZdGy92O9LpVP4KH/+h5d8bv2tTNCOY+v2/KYAfzDWbb0u
         /CQR9a3bKVhHdzlmHOJ+quLynjHoOQP9ncCz/vPBd3vvxuQFqrswhjHPEgIV/r+wbFTC
         jiom46oBNc6ryd1oRNfffxLHbimFaFlf9F1hpy+8tDOrWdtkCuKw1ajjpOEYBu60coim
         upyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVK+KX7On1ebAgezjtoXXVmzT/+JqRQYGbwcJRVIhcq7mGv6Ql/
	4Kc3coxu7oXsSKAur98uo4sky6OZbdCjTZ2Rhj4/zMpiVYIJ4/aA3eRXH/OIt2/PkFw9f3AkUs6
	ZIVsk9wnrPs79pPptZuIY0l5UwR/MJ1wZ/2TMkaN6kM9jAdQPgB1iRBNprRD8gLVIGw==
X-Received: by 2002:a1f:24c4:: with SMTP id k187mr26541631vkk.26.1560187523157;
        Mon, 10 Jun 2019 10:25:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnAYNhoVVMRK5Q3rkCcX7PPdyfUyHn8QKpIBTLUsP/AJ9GJ05xoLS09ItxdVb+LPBPSnmZ
X-Received: by 2002:a1f:24c4:: with SMTP id k187mr26541556vkk.26.1560187522356;
        Mon, 10 Jun 2019 10:25:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560187522; cv=none;
        d=google.com; s=arc-20160816;
        b=O7klLt0r9oaBs9drgw5pErkpvXfSWQQoqI7cN30z+D9LiOF6YqE5KONxnsG6+pVERr
         12vspZHiMBTEd7jILKWTHdJkVEZWHgZv1Nbn0I+IYBdJqWTL2cw0WBwd41D/T4GmGZ2Y
         XFYjLtvPdyhTgY3FaPb/r71xjsByWXfVVrr+GGWsfkpDLwkyYCIPdKKJHu4e20kIs8CL
         zILb05r+6/3biQ9ElVy8Emsj95hyJxSk4VBUjSqbJpw33iI32Uwcvu+ERbQNaIrajR0/
         dnVYEAcElhRr9qBcB1ZxSavNaHKlZSlod4xTQpwjdqBTVY72oOp+wZg+RlnTVGaLj3hT
         eQVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=1VV+xq086UX8c6jCatmwEDXtaJKBj6cnEMKuwv2eIek=;
        b=0IrhkF+N6tLAAjWocj9qkXUQ+eBJvmWbUfokiWAA+nojxuq0bgZHDduanmOVZZzM4o
         enSwA5h15W3Zlv2vD4usM1P9L5OOZM7L55GWk5GOkFT2wXRhuCtKDkYn5gHSiBgnOARn
         tf31VSNA5UU9y1+916DOrwMclI7qv7IAfAAIO3oItw8uYD94Ec6tOhALIfpYgsw+lzWA
         8FWEQAzmO6hhQzfgtDd7zHEJD4aS6kPiXEiUJoWva2B93DMM/q/Vzl9PlqDCprnUWx2P
         0L9UnP4DdzlGsxhLVSxSjw4ArCDoQk9X9GgQStIMplkyKzkiSIoxgoG0O3b4ZTOMCQBq
         PV8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si143181vsp.16.2019.06.10.10.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:25:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 31DE23EDBF;
	Mon, 10 Jun 2019 17:25:01 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-117-27.ams2.redhat.com [10.36.117.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 7AE095B681;
	Mon, 10 Jun 2019 17:24:45 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Dave Martin <Dave.Martin@arm.com>,  x86@kernel.org,  "H. Peter Anvin"
 <hpa@zytor.com>,  Thomas Gleixner <tglx@linutronix.de>,  Ingo Molnar
 <mingo@redhat.com>,  linux-kernel@vger.kernel.org,
  linux-doc@vger.kernel.org,  linux-mm@kvack.org,
  linux-arch@vger.kernel.org,  linux-api@vger.kernel.org,  Arnd Bergmann
 <arnd@arndb.de>,  Andy Lutomirski <luto@amacapital.net>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Peter Zijlstra <peterz@infradead.org>,  Randy
 Dunlap <rdunlap@infradead.org>,  "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	<20190606200646.3951-23-yu-cheng.yu@intel.com>
	<20190607180115.GJ28398@e103592.cambridge.arm.com>
	<94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
Date: Mon, 10 Jun 2019 19:24:43 +0200
In-Reply-To: <94b9c55b3b874825fda485af40ab2a6bc3dad171.camel@intel.com>
	(Yu-cheng Yu's message of "Mon, 10 Jun 2019 09:29:04 -0700")
Message-ID: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 10 Jun 2019 17:25:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Yu-cheng Yu:

> To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
> logical choice.  And it breaks only a limited set of toolchains.
>
> I will simplify the parser and leave this patch as-is for anyone who wants to
> back-port.  Are there any objections or concerns?

Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
the largest collection of CET-enabled binaries that exists today.

My hope was that we would backport the upstream kernel patches for CET,
port the glibc dynamic loader to the new kernel interface, and be ready
to run with CET enabled in principle (except that porting userspace
libraries such as OpenSSL has not really started upstream, so many
processes where CET is particularly desirable will still run without
it).

I'm not sure if it is a good idea to port the legacy support if it's not
part of the mainline kernel because it comes awfully close to creating
our own private ABI.

Thanks,
Florian

