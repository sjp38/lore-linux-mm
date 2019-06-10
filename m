Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DCD5C31E43
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:28:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E7D2920820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:28:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D2920820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9721E6B026A; Mon, 10 Jun 2019 13:28:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FC1A6B026B; Mon, 10 Jun 2019 13:28:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C30C6B026C; Mon, 10 Jun 2019 13:28:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 549C86B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:28:55 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id j77so3285354vsd.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:28:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=edI7w/jdzY4VGdpt/zuxxeKV3jnPqOV6ruJzrmpXcBM=;
        b=Bg61DmLj/dwZsySR3VV/UVfmrrzdKxAxXPCh9hL+VIKmdYt6CxqGyAMZ/2s02wCoIm
         NfFkR4UJFEkKaVsfVnfzHPOl7PdPbcLubcg10ojvva2qV89QKlKWux3jFUEAeV8tx/WJ
         52e6YgU9BsUS6PYuJOsohCwi0WToMhYM2Z5syNoq93vgcUbhAiJ1xBIbdFZRm0ogulvd
         acw1wO+f8qP8L5/Si0YW1aPbr97pjAefhZfAf5I4deHp/UEOOTsKdDDC+n5zBI+j7i2d
         3yxrgfz8aX+o52DH0v9HXv1+UgY4PMyPTlzUbLln76P5nHtWpda/2sNtohop9EiXrC08
         Um/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVYffe8kT58PnqdgxWdairbp525m6xo+WYLxGsFbRPEzcVZWOLU
	DVocyfmAHhC+PErN8fG2t7C5mZ+3CmQEGfCj7vAiaSM8tFdqujXAINFWi0D+7oLU//D35NwyMWr
	QG7nJy40u2x6cOuIQPrfKU71/jp7fDadOjmJ8S9Jkxe3bVakfWEk2rXG/uW8tU0jqhw==
X-Received: by 2002:a67:f882:: with SMTP id h2mr14330150vso.78.1560187735077;
        Mon, 10 Jun 2019 10:28:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTnv2RvDggAkN4bF/QTUnCVDUdJ8AAnW+x4u3YAkHcmR5C6+aZWJ1gOI0rOyrM3lVKabvK
X-Received: by 2002:a67:f882:: with SMTP id h2mr14330040vso.78.1560187733991;
        Mon, 10 Jun 2019 10:28:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560187733; cv=none;
        d=google.com; s=arc-20160816;
        b=TC0jcoiVMSU1nYol5h11lRUdFpmIOSV5olrJ1VTG17dxsr39qH0GdK10pGhdLKJOkR
         +LSYl9H7uxdD2h/YMOjnR27cY4erj43YwB7y1HcRwdKMzhGLnm6XLlfQ3hqmqZxZHIdO
         8FxnDQ3LiFmjUhjm30ZIcq8Y9dz9fVeHGEWU5+1Zl7Gb6ZOg7e6VR+jtYs7WBkWtKape
         sNUH25PQuITMqb2vNOR5K63NJEEp27ZGPny1KacDSpltb+sfKRLREkV+GtcTUJmlq+Lh
         Q8ToOrSkSRQuOfKve515ipWUCMk6A6/byDBxjVYPF4NakZJVsKkjZPIldMoOuFs+UhTw
         uz0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=edI7w/jdzY4VGdpt/zuxxeKV3jnPqOV6ruJzrmpXcBM=;
        b=0COpAMinV/hJfdZiacLM0YA1kuU55LypScDlbq+yxN9ooVJCSn4KQoDqXTPXCxMp09
         oOi0jmeB8M8jpG6dBwxIKpkwv0X6mrPuGCvqqVxmyMw5BTzKILebhGCDsqF/GURgrZ9O
         qm4GFQGKcrv3ur63VBy3Bcia7p1gZoxu21XN53s7OLXRBVrHa3AU5fZ2+aoibZCpuluD
         lJZHalOHbbvcew6qRSecBwJOUYz7bqm2VCByxZUvXKnVugz1bLKlx96FmY+e+JJ63/fS
         yw2Vh6nJyacTE9ByJynt91Ebwx9be75w2POuPJIUDUkNBedT0Im6aRT78HXDDAfelKpJ
         6bJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s205si1601318vkd.5.2019.06.10.10.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:28:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fweimer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=fweimer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BA733C057E37;
	Mon, 10 Jun 2019 17:28:49 +0000 (UTC)
Received: from oldenburg2.str.redhat.com (ovpn-117-27.ams2.redhat.com [10.36.117.27])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5D8DC5DD63;
	Mon, 10 Jun 2019 17:28:37 +0000 (UTC)
From: Florian Weimer <fweimer@redhat.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,  Andy Lutomirski
 <luto@amacapital.net>,  Peter Zijlstra <peterz@infradead.org>,
  x86@kernel.org,  "H. Peter Anvin" <hpa@zytor.com>,  Thomas Gleixner
 <tglx@linutronix.de>,  Ingo Molnar <mingo@redhat.com>,
  linux-kernel@vger.kernel.org,  linux-doc@vger.kernel.org,
  linux-mm@kvack.org,  linux-arch@vger.kernel.org,
  linux-api@vger.kernel.org,  Arnd Bergmann <arnd@arndb.de>,  Balbir Singh
 <bsingharora@gmail.com>,  Borislav Petkov <bp@alien8.de>,  Cyrill Gorcunov
 <gorcunov@gmail.com>,  Dave Hansen <dave.hansen@linux.intel.com>,  Eugene
 Syromiatnikov <esyr@redhat.com>,  "H.J. Lu" <hjl.tools@gmail.com>,  Jann
 Horn <jannh@google.com>,  Jonathan Corbet <corbet@lwn.net>,  Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>,  Oleg Nesterov <oleg@redhat.com>,  Pavel
 Machek <pavel@ucw.cz>,  Randy Dunlap <rdunlap@infradead.org>,  "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>,  Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
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
	<5dc357f5858f8036cad5847cfe214401bb9138bf.camel@intel.com>
Date: Mon, 10 Jun 2019 19:28:36 +0200
In-Reply-To: <5dc357f5858f8036cad5847cfe214401bb9138bf.camel@intel.com>
	(Yu-cheng Yu's message of "Mon, 10 Jun 2019 09:05:13 -0700")
Message-ID: <87h88xcptn.fsf@oldenburg2.str.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 10 Jun 2019 17:28:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Yu-cheng Yu:

> On Fri, 2019-06-07 at 14:09 -0700, Dave Hansen wrote:
>> On 6/7/19 1:06 PM, Yu-cheng Yu wrote:
>> > > Huh, how does glibc know about all possible past and future legacy code
>> > > in the application?
>> > 
>> > When dlopen() gets a legacy binary and the policy allows that, it will
>> > manage
>> > the bitmap:
>> > 
>> >   If a bitmap has not been created, create one.
>> >   Set bits for the legacy code being loaded.
>> 
>> I was thinking about code that doesn't go through GLIBC like JITs.
>
> If JIT manages the bitmap, it knows where it is.
> It can always read the bitmap again, right?

The problem are JIT libraries without assembler code which can be marked
non-CET, such as liborc.  Our builds (e.g., orc-0.4.29-2.fc30.x86_64)
currently carries the IBT and SHSTK flag, although the entry points into
the generated code do not start with ENDBR, so that a jump to them will
fault with the CET enabled.

Thanks,
Florian

