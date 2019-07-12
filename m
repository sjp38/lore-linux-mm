Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2838C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B68F5208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:51:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B68F5208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58CB28E014E; Fri, 12 Jul 2019 09:51:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53CA58E00DB; Fri, 12 Jul 2019 09:51:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C2F8E014E; Fri, 12 Jul 2019 09:51:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEF98E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:51:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id c31so4821467pgb.20
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:51:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=yXZDGH7UFPztNuivEXwKOh8AtHddMWSG8TndzGrNhQI=;
        b=m/U0pKx8Hg8VKxgareiN/ra87bFUVCsT4aIjaCbRniK9FJ1mASyi3ePNPaZDdQlj5n
         6OP3k7qcHrQWPcYrSziqSeHsTsXieJfBkBYf71MtDqD8brwCPJQuUHG40hQnhH4Hsqc8
         uHedf+em2wo8MdrjZ17nCofkaclXuKhnuQdMpxMTDaggjomAwph2OVH6QMo2j4eFT2k3
         m2UkLonMeNbhbIyBt7/KihhQViGu5HHFRUxQ1Ya4NYIJp9Z+sFwW8bq4uF65P3lTSVbD
         IBJ544wAvzeTIwgpr7AkmzpjvBeSzpzDj0eKCXxcJQku1hFgEoq7MrgoRHy9HyzIMcPg
         2nRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWBxDa2MduerD5o4nJOfNLQtN1hJdUytmfrsSO7Uj+xzWDZ7Ljp
	1WEO27p8ymSN3KO1JkXTYYk2ChvUvKk/FZmLanAiIkDsWWat7/hxale0b+bdsWR2qUSOCuGQJfe
	AeY8//y+pf9NSCkgEP6woQQppHiZIHgaZ7zpmWqShnMdF+heTyt5S2MCw7yVjy0ZvfQ==
X-Received: by 2002:a63:4006:: with SMTP id n6mr10385771pga.403.1562939465676;
        Fri, 12 Jul 2019 06:51:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0/upGpQmw8PCTb12qNTX6BPwAogXh+0ABJN9QT2NKZUA4guVWrchS79CoRwIKoTGsmhsg
X-Received: by 2002:a63:4006:: with SMTP id n6mr10385629pga.403.1562939464163;
        Fri, 12 Jul 2019 06:51:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939464; cv=none;
        d=google.com; s=arc-20160816;
        b=n64u76zYKt97YrcigX5fJEUK0qjMsBNuozNVH4uY7ETTldMbgCxQr4vn+gE1K1PLpv
         HvuzSagCL6T+jeLiBb2ASM8Onw9jCEzQLqkD6tmmwhTOakeyzVoztFCGB/dZkGm1AhyV
         CxYDfQLkJrUR2aPueo1zDsYbnQFk6ycVLdSzsl9wte6Q4QtgXumOnmLrEXiePNuzBX6l
         cCGjiPYCTqbnoCphhkjsUAZuRpNwTk7BDwcwXUTJJMUfa2deM6ViSSd69UxAY5wsGVj+
         T68pN4ZhTmB/ZmwoCjNAmOWclAHrKFwYzGnVzi/9DMPglkcU37LcnNrjobCz20sRHpAN
         I3wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=yXZDGH7UFPztNuivEXwKOh8AtHddMWSG8TndzGrNhQI=;
        b=ln4FZsekx5gTejfXZjxTwcVL02EmrDhBCB4rib24UVe6n4AnraaVad7hSP0+woFIqP
         3pf/4ZODfOGzBFtJ7rn8TOWYNBoN4oIIRNNr6ct7OL5zjjStQ8hladSWO6EeTnWKGVRi
         KUjsz1M+SFPB/fLQrnwAJN6/pQbTlLXLQCY7tqowm+o+2nk1ew1nok4qLSUuuoGuG6Ef
         RGbA2Aufa+OpQAnP1AU1T7vgJUYcxsto5t8wxcR4vHTM3Kv2L3IYXMv77h9igSQrBUkc
         PRvErS4hdKvQ6Pe4E25hYi/T6YxRa9Htw+IhsiSqhFteCT5mRlHH6ZQVvxkHsL1OWtVl
         B84w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d15si8547173pgv.90.2019.07.12.06.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:51:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jul 2019 06:51:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,482,1557212400"; 
   d="scan'208";a="166683426"
Received: from smatond1-mobl1.amr.corp.intel.com (HELO [10.252.143.186]) ([10.252.143.186])
  by fmsmga008.fm.intel.com with ESMTP; 12 Jul 2019 06:51:02 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
 rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
 hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
 peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
 liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
 rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <2791712a-9f7b-18bc-e686-653181461428@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <dbbf6b05-14b6-d184-76f2-8d4da80cec75@intel.com>
Date: Fri, 12 Jul 2019 06:51:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <2791712a-9f7b-18bc-e686-653181461428@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/12/19 1:09 AM, Alexandre Chartre wrote:
> On 7/12/19 12:38 AM, Dave Hansen wrote:
>> I don't see the per-cpu areas in here.  But, the ASI macros in
>> entry_64.S (and asi_start_abort()) use per-cpu data.
> 
> We don't map all per-cpu areas, but only the per-cpu variables we need. ASI
> code uses the per-cpu cpu_asi_session variable which is mapped when an ASI
> is created (see patch 15/26):

No fair!  I had per-cpu variables just for PTI at some point and had to
give them up! ;)

> +    /*
> +     * Map the percpu ASI sessions. This is used by interrupt handlers
> +     * to figure out if we have entered isolation and switch back to
> +     * the kernel address space.
> +     */
> +    err = ASI_MAP_CPUVAR(asi, cpu_asi_session);
> +    if (err)
> +        return err;
> 
> 
>> Also, this stuff seems to do naughty stuff (calling C code, touching
>> per-cpu data) before the PTI CR3 writes have been done.  But, I don't
>> see anything excluding PTI and this code from coexisting.
> 
> My understanding is that PTI CR3 writes only happens when switching to/from
> userland. While ASI enter/exit/abort happens while we are already in the
> kernel,
> so asi_start_abort() is not called when coming from userland and so not
> interacting with PTI.

OK, that makes sense.  You only need to call C code when interrupted
from something in the kernel (deeper than the entry code), and those
were already running kernel C code anyway.

If this continues to live in the entry code, I think you have a good
clue where to start commenting.

BTW, the PTI CR3 writes are not *strictly* about the interrupt coming
from user vs. kernel.  It's tricky because there's a window both in the
entry and exit code where you are in the kernel but have a userspace CR3
value.  You end up needing a CR3 write when you have a userspace CR3
value when the interrupt occurred, not only when you interrupt userspace
itself.

