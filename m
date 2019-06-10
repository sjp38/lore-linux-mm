Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F0CAC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:59:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB85D207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:59:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB85D207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EA036B026A; Mon, 10 Jun 2019 13:59:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CC2A6B026B; Mon, 10 Jun 2019 13:59:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 589D16B026C; Mon, 10 Jun 2019 13:59:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 239A46B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:59:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 145so7677487pfv.18
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:59:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=sKBl7bnkIQX3qEm3oDzk59hrL0yJy6172AFHnaiL5hs=;
        b=Yl3/du6wCOFG/1ez+g3R8tfhZ3LAHz3fhsGJ5pPUAJOE4/bsuyR2HxW2Oduzkur/uE
         2U4MI655MXl6wwmq4+hIdH9oDEMyLjtQmEDKGN9qgVAwwYDY4pq4j7lX0k1PjQ+Pm91v
         vWUJg1lUNZwYgS2HSDu+jZK1AOVOixg9FkEQFEAfOjlyriOdKeWFRm7vVvfNIGbXgrjz
         kQDD85q0weehZCP7jbOizFhQ5xpG2jtX1lCrMZ/AulS0Fl9KXAB8hIiMeKozjEi9ZUgr
         43sLoDAWOQLOB77TlsMvrLcDPrejvUdxbQwPpeZVqwWRR2EAwNVW6U8sg714FLPnj4SD
         nx1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXs3Kgq1zmcGgd1dhSDlNedaed51u07IPiuNKOlexJe7nhnNsn4
	kuflUoIuIoy+6DhLkACCo2qTbzHy7AFhvgLmhnBmpDxzMmLmbfOqYZ6xPXs4Ve/Yjznhl7g/QCv
	zjqKppU8Yg988osJNHK4/+nblyvU2EruyYfhf52DPOz/OhHmSLO8v/8rAEKoQ91kDRw==
X-Received: by 2002:a17:902:b947:: with SMTP id h7mr28641365pls.267.1560189590807;
        Mon, 10 Jun 2019 10:59:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWW0HkMQ6Vr0c0MaoVtlvX6NpNW+rfa7u5DeSZEy8yCf61xq500X3xsch2DV41P3+qayOn
X-Received: by 2002:a17:902:b947:: with SMTP id h7mr28641316pls.267.1560189589940;
        Mon, 10 Jun 2019 10:59:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560189589; cv=none;
        d=google.com; s=arc-20160816;
        b=W7z9OT5bGpdYjnvsbcOlG2/1nEEDuuV8iUZSvSdhca3xXLuZyU3tyguUnaM7IyESkC
         WY/pQ8CkFA9b3U0DfXnzJBLEg/hJraQwA92yIwBlpk0UsblGi3776lKjyB7LzwB0znM0
         gB6rJAIh/nqVKlWyzfXIHZseXYIs2pMijjSR4inkWsq5Bo+DvXW6TzxfCNhT3AgbcHik
         kaGfgRFOB0yUNJq4RXjpqQZFToJwFfI9gcJqReXZASh92KvHNl5dCInAMftso5LVbpIO
         8QaGiDjznKGR4NHVQHAzUs/i1eoxOUupHmlkMdHlq9YOm7msAOIKOaL77mhu6aesWg/U
         m3Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=sKBl7bnkIQX3qEm3oDzk59hrL0yJy6172AFHnaiL5hs=;
        b=vX3SfSOyWB1TDHKSuYhKLU/woi1ok7wqLmmCi3iB4dwDJHmnylDIzR38+8iOLwcqgb
         38YDyO8eUcZnGc0Wx9wxVKBLsvhMIH6zJEV3mDDAOa3Dk6jG7x8gwr3pua+lmY03Ezx4
         euey711H2DX5KrjrG3aLCy0l8zqAldEISVExHNO+i1APEZZYNSOoxuQ+jMJ22jTwfWfG
         qPbZfgXTyRC6dQL5+r7j9+hP0/TuDuRJUDmfk8CrbRwKFey5mX1IQNj7bfGUcasnB1il
         2+R60AfXQ22qIZJl/iO3JmTBlxZBxn7Wr64qB1IGBv86kUk3PNQULno8ZnSWOrI8Z0bH
         4mWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l9si9850272pgq.534.2019.06.10.10.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:59:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 10:59:49 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga002.jf.intel.com with ESMTP; 10 Jun 2019 10:59:48 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>,
 Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
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
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <0e07f346-89c7-ccf1-9d38-854a8e7d25a1@intel.com>
Date: Mon, 10 Jun 2019 10:59:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <5dc357f5858f8036cad5847cfe214401bb9138bf.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 9:05 AM, Yu-cheng Yu wrote:
> On Fri, 2019-06-07 at 14:09 -0700, Dave Hansen wrote:
>> On 6/7/19 1:06 PM, Yu-cheng Yu wrote:
>>>> Huh, how does glibc know about all possible past and future legacy code
>>>> in the application?
>>> When dlopen() gets a legacy binary and the policy allows that, it will
>>> manage
>>> the bitmap:
>>>
>>>   If a bitmap has not been created, create one.
>>>   Set bits for the legacy code being loaded.
>> I was thinking about code that doesn't go through GLIBC like JITs.
> If JIT manages the bitmap, it knows where it is.
> It can always read the bitmap again, right?

Let's just be clear:

The design proposed here is that all code mappers (anybody wanting to
get legacy non-CET code into the address space):

1. Know about CET
2. Know where the bitmap is, and identify the part that needs to be
   changed
3. Be able to mprotect() the bitmap to be writable (undoing glibc's
   PROT_READ)
4. Set the bits in the bitmap for the legacy code
5. mprotect() the bitmap back to PROT_READ

Do the non-glibc code mappers have glibc interfaces for this?
Otherwise, how could a bunch of JITs in a big multi-threaded application
possibly coordinate the mprotect()s?  Won't they race with each other?

