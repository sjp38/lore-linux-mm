Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F1B8C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:09:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E12612084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:09:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E12612084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BBB58E0004; Mon, 17 Jun 2019 07:09:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76D238E0001; Mon, 17 Jun 2019 07:09:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 659A68E0004; Mon, 17 Jun 2019 07:09:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4626F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:09:04 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so8955337qtr.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:09:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=vwHKFwOFdew7kWVH8l7pV0qVg+iIeaoKVnkIvAlLtdc=;
        b=Onr/F7S6zlDpgFWfy8TLBNMd9bC2GjcP/cWmyQtaN5MQCxsMr6hAHMVmH7bWZKzPpo
         cvZfeJ2pDEEpNcARgnbwTv5s8NELTD+BrU8TlX+zWxmpwyFdwYiZ0lQiT9J1HBnjB+iL
         wuGRprPP2ta9pk6tckZs2EmYh4qojjzlXAD2M4c68g0a9XHJrmFW5PDUmgJ6JQBSNh6w
         ZkhlDACxbAQrrQLVjN3taAWMgEJi3ZJ9tBAYPiYgX/0VEY5sUNYQwkdhWrya6VjAg4zt
         ZjGOTZccmYxVP4TFL8eHnrFAUCnCpYG1UopM4TwlLl1kfkcg9yMAEKL9iwiQjTsbrk9x
         SFiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWNWtFbJLkFe8lQMjQ9vEiGILoVY0qcq7pi5/7wPQ9DNbXQVOa1
	J2iQw3oBIxlLQx9a2+XNXmYxc7laPB+3qAaIvxatArhF4WuN9g+QL55THoQVpH/7suR5ENnoiW6
	qvnEz71itEygzP4o3i5+esWlYgZo1O2FE1kLlaLA40uKz7tUOMWFgjwJLirCgPzrYhg==
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr88982230qkj.49.1560769744027;
        Mon, 17 Jun 2019 04:09:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9wlxfFDZINK43A5RPZsEA2HUh6brjDPm0FmP9aIXM3fiIiQMalW+iLHBac4lRkluAcrIy
X-Received: by 2002:a05:620a:1497:: with SMTP id w23mr88982189qkj.49.1560769743440;
        Mon, 17 Jun 2019 04:09:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560769743; cv=none;
        d=google.com; s=arc-20160816;
        b=S7D0xqVIngx0CTBVy20JfVdvz+9uw9x9h4MULL8IsQ6mv/JT0QwXGheD+uM56WCRev
         PJ9D9nhdSNUA8xAxAb0cOfRXGjtZkAsINuKms7UweocK/HLyuPoUn12erLle4Ak3/HUO
         3FlyWUHvKhIlUnvnyE6coKch0Qr8hcw9E3+Rhw5pg5OmVZxD9njhy5DOS038QisLd7zR
         zf7/nATV74IDgn9VqcWNtiMgLJ4mqssNBEClLXaZmEf2eJ2jHmtLQmKrXhx5jXaN9qcm
         aMYeKPg8VQVRXOsLW//WvaPz+aY6rjCTrzQzED2AyAKgw7cTJzlLCa8sx1L/ysb43et+
         wtSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=vwHKFwOFdew7kWVH8l7pV0qVg+iIeaoKVnkIvAlLtdc=;
        b=ZL8W9xiRedoXLHptbYmCRneE43cTlwh23hOk2uq26DkT5IeBEn5yK7K/iAg6egRdpM
         ZzxKF8YZN5K5VZefFmuZSw4CCnJzipuzyagpAifI1HJx94klbKkif0GknG+NZ6b+QdrC
         +wZ/yd9c2znLjJWgkX5RD1/YARJ3FYpgXHhsDx5avCNJcPNX8Qw0npORohXhYeEkRzmm
         v+8nkbjnHRq7DQcDUdDFvJzxr/MS9zyLS5gniUguszzU9UtnWvBZ+EKquYklnVH5LPmB
         f9yl55MV/AMoVabQKZ22cl5pBMdsEyGAjCSC7Jm9YJKt/kpPlF2MjYjzBMWvlVxJ9eCb
         EMtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a8si7104851qkn.248.2019.06.17.04.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 04:09:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 206F4356E7;
	Mon, 17 Jun 2019 11:08:32 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (dhcp-192-180.str.redhat.com [10.33.192.180])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5EAC57BE78;
	Mon, 17 Jun 2019 11:08:16 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>,  x86@kernel.org,  "H. Peter Anvin"
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
	<87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	<20190611114109.GN28398@e103592.cambridge.arm.com>
	<031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	<20190612093238.GQ28398@e103592.cambridge.arm.com>
Date: Mon, 17 Jun 2019 13:08:14 +0200
In-Reply-To: <20190612093238.GQ28398@e103592.cambridge.arm.com> (Dave Martin's
	message of "Wed, 12 Jun 2019 10:32:38 +0100")
Message-ID: <87imt4jwpt.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 17 Jun 2019 11:08:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Dave Martin:

> On Tue, Jun 11, 2019 at 12:31:34PM -0700, Yu-cheng Yu wrote:
>> On Tue, 2019-06-11 at 12:41 +0100, Dave Martin wrote:
>> > On Mon, Jun 10, 2019 at 07:24:43PM +0200, Florian Weimer wrote:
>> > > * Yu-cheng Yu:
>> > > 
>> > > > To me, looking at PT_GNU_PROPERTY and not trying to support anything is a
>> > > > logical choice.  And it breaks only a limited set of toolchains.
>> > > > 
>> > > > I will simplify the parser and leave this patch as-is for anyone who wants
>> > > > to
>> > > > back-port.  Are there any objections or concerns?
>> > > 
>> > > Red Hat Enterprise Linux 8 does not use PT_GNU_PROPERTY and is probably
>> > > the largest collection of CET-enabled binaries that exists today.
>> > 
>> > For clarity, RHEL is actively parsing these properties today?
>> > 
>> > > My hope was that we would backport the upstream kernel patches for CET,
>> > > port the glibc dynamic loader to the new kernel interface, and be ready
>> > > to run with CET enabled in principle (except that porting userspace
>> > > libraries such as OpenSSL has not really started upstream, so many
>> > > processes where CET is particularly desirable will still run without
>> > > it).
>> > > 
>> > > I'm not sure if it is a good idea to port the legacy support if it's not
>> > > part of the mainline kernel because it comes awfully close to creating
>> > > our own private ABI.
>> > 
>> > I guess we can aim to factor things so that PT_NOTE scanning is
>> > available as a fallback on arches for which the absence of
>> > PT_GNU_PROPERTY is not authoritative.
>> 
>> We can probably check PT_GNU_PROPERTY first, and fallback (based on ld-linux
>> version?) to PT_NOTE scanning?
>
> For arm64, we can check for PT_GNU_PROPERTY and then give up
> unconditionally.
>
> For x86, we would fall back to PT_NOTE scanning, but this will add a bit
> of cost to binaries that don't have NT_GNU_PROPERTY_TYPE_0.  The ld.so
> version doesn't tell you what ELF ABI a given executable conforms to.
>
> Since this sounds like it's largely a distro-specific issue, maybe there
> could be a Kconfig option to turn the fallback PT_NOTE scanning on?

I'm worried that this causes interop issues similarly to what we see
with VSYSCALL today.  If we need both and a way to disable it, it should
be something like a personality flag which can be configured for each
process tree separately.  Ideally, we'd settle on one correct approach
(i.e., either always process both, or only process PT_GNU_PROPERTY) and
enforce that.

Thanks,
Florian

