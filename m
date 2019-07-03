Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8B75C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:35:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8655D21880
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 05:35:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8655D21880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF0C06B0003; Wed,  3 Jul 2019 01:35:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA1B78E0003; Wed,  3 Jul 2019 01:35:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDDED8E0001; Wed,  3 Jul 2019 01:35:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 952E16B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 01:35:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b21so814699edt.18
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 22:35:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=J92O1NIqH/vYDRZjQiW92fLeK0leVQa4byZBl7CHyL4=;
        b=rKka53EG1mR8cWIYnBu58kpuqQvh60DltANKYyeoYVth3YDb6bWNNLWyysuvKwSKN+
         09lEQIFKrXRqn+sz5qz+1VN308DCV6XjWtVEpZ+YmaWI5AU8/8vkVQjwDuT/giVYmA9c
         s57cM5ZMaWsVBlYTNvzxm2F//7X+NyJT77r/qeN2zdrMy9qTuMvGMYB8+UiO1tDLRAa7
         z9cA2dJFaYjzLy2jbxfzH3LKgJXv2n/VwpcyBvm1YBY8kd6c8RWDiwQrVw9lg6JM9mB4
         WJlWRWjJdBZiIh+ByGxhnl4vS3MJsVB8CBL6/EWjklZfltuSde1ajKFbxbtbjc1zY/F/
         iTjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVx6KIvNIl1H5DIYsN8HveXORY8MHFNtQj893njrGrUNLezOpo5
	pK6jUetWv+BmH+mMvcXzrl5JR2ns/VSCxWLazzlidskbf3l5XHfipintWUobtzQQg/MELsOenb8
	bJLFv4sInkhiTuG29ecJ17j0j/Dv3p4SmXfMlXjIc9QfI54nrSlwn72rJNDTWcCNWZQ==
X-Received: by 2002:a50:f091:: with SMTP id v17mr39942473edl.254.1562132103043;
        Tue, 02 Jul 2019 22:35:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZb/Tv4hE5CPsDP2n074GWS4AJ4ckGfnKh7xthvxVnvBlxkVncCgI6B9DPM62LGCGug9Qc
X-Received: by 2002:a50:f091:: with SMTP id v17mr39942424edl.254.1562132102228;
        Tue, 02 Jul 2019 22:35:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562132102; cv=none;
        d=google.com; s=arc-20160816;
        b=vWP/H5WYjpkqn5ZOR1sTp4D15RM8IInwJilLnyGO/FltYvH3bjISMlJRTN4fZloL2t
         bt/w6CRj4Yf+fOZp3JKQdPPBrZ+L5J0ghjwPJIkqHwtlnOx65seaom7LRPyLUPktdsdi
         tcPODWp0k19cBkmknFZrt4BBejKY4kgr3/b97m15lXGhtPPiQCZsTh7SDn66bnXxScX1
         kMb5UVCRiGIY/97hcYCJ6f5TOJlfzUuOfVv8AS53rxZvmEfUiyFBkU9JlzzWTtth8cRd
         0Jj5TsmCcdVygQDSWy7sfLBPof1FXgyjinDV1zJoklVqMDAoxbsd+o8GDN60eSdsuV8N
         h2mw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=J92O1NIqH/vYDRZjQiW92fLeK0leVQa4byZBl7CHyL4=;
        b=gWjbTOleW+xqI9vMUcCCZuLQmSYDJ0c89+Xz5FbrZZT2EhtMCPqfMLxiSrpNayfdW4
         7Tce2JmBSKMKn9Qmgw5U7/QZWtWwawzTEQMU7wWYNF4RZbsI73PhMA18S7izeAEn57b+
         GIhzKHpvzjiULc1iegJ9cJD8H+v4IpxI4vAaVD6H99f/XbHiTsnFoqkr4DFpir56dRoY
         dRONokuXY+61XnQXBJopzxl9Q464SuLOvqCcfYerFSK9dSPRJSiqr6wH9IIz/MjS5PfH
         IMPMm0Nd/kvZ6XoZuYz6/VyzEygQQwFj4NegzGS9r4J1wPyfnTS7x+1C7azLy4QAFPHP
         mX7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w54si1084154edd.427.2019.07.02.22.35.01
        for <linux-mm@kvack.org>;
        Tue, 02 Jul 2019 22:35:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 36FF42B;
	Tue,  2 Jul 2019 22:35:01 -0700 (PDT)
Received: from [10.162.42.95] (p8cg001049571a15.blr.arm.com [10.162.42.95])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 14A2D3F718;
	Tue,  2 Jul 2019 22:36:52 -0700 (PDT)
Subject: Re: [DRAFT] mm/kprobes: Add generic kprobe_fault_handler() fallback
 definition
To: Guenter Roeck <linux@roeck-us.net>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org
References: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
 <1561973757-5445-1-git-send-email-anshuman.khandual@arm.com>
 <8c6b9525-5dc5-7d17-cee1-b75d5a5121d6@roeck-us.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <fc68afaa-32e1-a265-aae2-e4a9440f4c95@arm.com>
Date: Wed, 3 Jul 2019 11:05:27 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <8c6b9525-5dc5-7d17-cee1-b75d5a5121d6@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/01/2019 06:58 PM, Guenter Roeck wrote:
> On 7/1/19 2:35 AM, Anshuman Khandual wrote:
>> Architectures like parisc enable CONFIG_KROBES without having a definition
>> for kprobe_fault_handler() which results in a build failure. Arch needs to
>> provide kprobe_fault_handler() as it is platform specific and cannot have
>> a generic working alternative. But in the event when platform lacks such a
>> definition there needs to be a fallback.
>>
>> This adds a stub kprobe_fault_handler() definition which not only prevents
>> a build failure but also makes sure that kprobe_page_fault() if called will
>> always return negative in absence of a sane platform specific alternative.
>>
>> While here wrap kprobe_page_fault() in CONFIG_KPROBES. This enables stud
>> definitions for generic kporbe_fault_handler() and kprobes_built_in() can
>> just be dropped. Only on x86 it needs to be added back locally as it gets
>> used in a !CONFIG_KPROBES function do_general_protection().
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> I am planning to go with approach unless we just want to implement a stub
>> definition for parisc to get around the build problem for now.
>>
>> Hello Guenter,
>>
>> Could you please test this in your parisc setup. Thank you.
>>
> 
> With this patch applied on top of next-20190628, parisc:allmodconfig builds
> correctly. I scheduled a full build for tonight for all architectures.

How did that come along ? Did this pass all build tests ?

