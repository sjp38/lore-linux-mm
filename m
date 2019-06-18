Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9F99C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:05:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C29A20873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C29A20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D01E8E0006; Tue, 18 Jun 2019 12:05:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A7A18E0001; Tue, 18 Jun 2019 12:05:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED9CB8E0006; Tue, 18 Jun 2019 12:05:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D26258E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:05:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id i9so10135235qtc.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:05:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=R9lzACpyysqEMFTWath+L8VuA7EH+R6hsPpYBcFTTZc=;
        b=Aqjh7sXYhi3M8o0AdqkgyR0cH8l4ygBvldSqT6YgKz+hLToDQdxC0tupJYAwWhezuH
         oraHTv4+NOQQIODCOs7uKvepcRl1IB5nLZZpYUrqB3c06/AqNsVMJ4EOdEuheOaXDhj9
         yQa6iK3M03sTcmGi0qntYHgz4xzmTm0JhRm0pBlkZw24RLZH8eB0Fi+pll/HwXX6Cmj2
         PYwWMgFELjzAuL0IHrL4Q+vu3/ztZJQYRal1uGvJFGg1KqLU8k/PR24AaLbAMsCCiiB4
         BzMWa35K5L3myRU8awe9q7BhgqD9JUefADu2+pMaodo3WLWV3SalWWeCloukKk6dP+hD
         ZbLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVG5RRe/q2wI+3RwxvW9OnYOYoNWZWqWyng/RcMy2e69apaghIE
	KIEbkTsvhXFTJ2EjwAsRMJdHBWQ8s5xnd8uss1WVo2FHYB5Pn4aZLmfU50s4aejLAnaL1ZgIqaT
	aIZojmRINvpi4B6V5YCtQ3beA23TiDvXuIhcVGbbhgC9yvpwEdOllQw7UMz8RadeWWQ==
X-Received: by 2002:a37:a98c:: with SMTP id s134mr92360942qke.176.1560873950666;
        Tue, 18 Jun 2019 09:05:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5mn8xp33F7Y/J6TBi2n2PALmQjeB7Wy+yy+/HgQHi656bWNQ6XFQ7kMJ1q/HSStK6z0kw
X-Received: by 2002:a37:a98c:: with SMTP id s134mr92360898qke.176.1560873950139;
        Tue, 18 Jun 2019 09:05:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560873950; cv=none;
        d=google.com; s=arc-20160816;
        b=szFCcc1n4644alAkIOddAyCzLcUnoh+pM/E0nh9PdKsAtpMdRObyi+PNd6KGxEkbSt
         WjDLGlho5Q/17AbAeljkKOSvCrBBtHKrY7LxoVZluKKdoGz641/wwePExQhsHbeeWSod
         iptWN1i2bZuc08pcO57LK/NwUdRWS4vJwgBBAwdGHyS0Ri1zEfvsNCMuvbfsb1lUytg1
         nI9neoqo8S5RysIE0yoKROYGtDYC5r+9p1PYD2JaGd1Jx/C5UMqm9jMwyNxrLoJ6luM3
         b51zaJGPeWjZO+uOK2gNh8fc6Z/Wfh2Byj95JQxqM9s3GaWFFwJnKXJEWDq4Un+9FkoD
         0zzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=R9lzACpyysqEMFTWath+L8VuA7EH+R6hsPpYBcFTTZc=;
        b=W7rXN7WPgoSCyiFoeR4jaBy0gW2ZT/TRiUAVZZBK2B5NcwKGZfEnQUp5Mqxcc5v1dq
         7ciQI5xSiDaZ/8OMlr/nftIH5yl4Sne1iIrhQMmzVhJxyH5G0phFZTJXJ3D9YPGx2lnk
         Up8kf26WOyd6JPy7Hpa7plHeBU9XgdKC3o6x3j+lFi330J+tI8FRfRMbnoT7u30Ob2ef
         /Ge5wbVULCeXJPD4FYXY8/bkieYdQnSaicLbMXOkiOb7/PnPOAjs4xDotQPdNx9lV3ua
         5GNhyx3hZ2WH5FoYqZdifsPHwrwvfirdBUi9psS0Qbr0Pq4/ExtPwurtGGVntJeG9M+W
         XDNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i66si482422qtb.274.2019.06.18.09.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:05:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 06BA17FDF9;
	Tue, 18 Jun 2019 16:05:39 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-116-87.ams2.redhat.com [10.36.116.87])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 70CCD37DE;
	Tue, 18 Jun 2019 16:05:26 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Dave Martin <Dave.Martin@arm.com>,  Peter Zijlstra
 <peterz@infradead.org>,  Thomas Gleixner <tglx@linutronix.de>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Ingo Molnar
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
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an ELF file
References: <87lfy9cq04.fsf@oldenburg2.str.redhat.com>
	<20190611114109.GN28398@e103592.cambridge.arm.com>
	<031bc55d8dcdcf4f031e6ff27c33fd52c61d33a5.camel@intel.com>
	<20190612093238.GQ28398@e103592.cambridge.arm.com>
	<87imt4jwpt.fsf@oldenburg2.str.redhat.com>
	<alpine.DEB.2.21.1906171418220.1854@nanos.tec.linutronix.de>
	<20190618091248.GB2790@e103592.cambridge.arm.com>
	<20190618124122.GH3419@hirez.programming.kicks-ass.net>
	<87ef3r9i2j.fsf@oldenburg2.str.redhat.com>
	<20190618125512.GJ3419@hirez.programming.kicks-ass.net>
	<20190618133223.GD2790@e103592.cambridge.arm.com>
	<d54fe81be77b9edd8578a6d208c72cd7c0b8c1dd.camel@intel.com>
	<87pnna7v1d.fsf@oldenburg2.str.redhat.com>
	<1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
Date: Tue, 18 Jun 2019 18:05:24 +0200
In-Reply-To: <1ca57aaae8a2121731f2dcb1a137b92eed39a0d2.camel@intel.com>
	(Yu-cheng Yu's message of "Tue, 18 Jun 2019 08:53:29 -0700")
Message-ID: <87blyu7ubf.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 18 Jun 2019 16:05:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Yu-cheng Yu:

>> I assumed that it would also parse the main executable and make
>> adjustments based on that.
>
> Yes, Linux also looks at the main executable's header, but not its
> NT_GNU_PROPERTY_TYPE_0 if there is a loader.
>
>> 
>> ld.so can certainly provide whatever the kernel needs.  We need to tweak
>> the existing loader anyway.
>> 
>> No valid statically-linked binaries exist today, so this is not a
>> consideration at this point.
>
> So from kernel, we look at only PT_GNU_PROPERTY?

If you don't parse notes/segments in the executable for CET, then yes.
We can put PT_GNU_PROPERTY into the loader.

Thanks,
Florian

