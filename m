Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC09C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:30:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72CAD217D7
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 15:30:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72CAD217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7DA88E0005; Mon, 18 Feb 2019 10:30:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E036E8E0002; Mon, 18 Feb 2019 10:30:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA45F8E0005; Mon, 18 Feb 2019 10:30:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E60B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:30:56 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id j5so3653716edt.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 07:30:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=t7ul6qFjAV6/5cm3WrDVGikFzQ/5NU91CimGKn19A2E=;
        b=hAnDUV45+zE//0EKMNy17QjmJ+FjpUGbxhGDkAzEmU31hDeyLSihc9pQlgq9+1go3n
         3KFPSsSJUg/HMistemWDYZYFKTTLSRxsHlJyGbQf9FqwpyKOep+sNZaRwe9gR56RWzo0
         zV63J/USwgcNVMnpfggyBpoFjtKJDehKxuDXMaPczr3CtbkNbHGDbGiokndjeYZ8z2EJ
         djGcQ6ARnV+am8+a7lF1uANSfPY+FctVqFDwA5I6Rle40/mXNR5Ie2f5JfVwhsTFTISc
         GFL0AKlPhVKCL/78XcgWHK3ej1B0mo3+BLyurHBz15Uo9J3/2VGxkSBtD00hkRQYz18T
         LoYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuaBZHDZGBtS1sj5SLwFz/H7Ns13bt0cjAJ3W/THdUyFWlpTbG+k
	QRKqtC+7TKoD9g7uvsUi/CqgtFzg3xaSdF6d+8AtNdA5Ef53x7AjIutxWpZZ53X45hFwykB58Zz
	LbF66vnIKbkuTlTh76Kp0zz3d1VHyLhKWQWnnJNpMDT2AsIbS6LmjdzgeDNnRBSLo1g==
X-Received: by 2002:a50:d4c3:: with SMTP id e3mr19229120edj.20.1550503856009;
        Mon, 18 Feb 2019 07:30:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZNx6A11pD6ElWLq1Np3DBwe9pdRrTaZFgJuDoavB3wdWXfQLQlvWC/hC1sos+yt98bFFMy
X-Received: by 2002:a50:d4c3:: with SMTP id e3mr19229055edj.20.1550503855107;
        Mon, 18 Feb 2019 07:30:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550503855; cv=none;
        d=google.com; s=arc-20160816;
        b=ah+JjWbzi6vQ+cea2JNh4Avwt9bbC+2OD0kUxtvlxJw/xrMQ/YkbmG0cqbo3LY0N/G
         iXStSnPp5ElFZEEHZzr2LxkcOZ9OutXOcqFOyXELRKHZk3jrP4t+KU2eM6XB6/q2XsWP
         jxk3ItPcnz+uJthakTlHHpONBgcVrsVZkWtlxBzATvH3CEY6zqRd4x54HBvTMaGNwkE+
         Unpoy0jYP63yOpIl/mIyr5eV37jsBcvmsZhVtW15R5aILalLAzsgHo0KMMclMHiR9wzV
         ZUtwTteoOsuVWOdb4PO4s7l8uD4+5vGZkfoUo0jz1kVXRjoWeEj4Bd5+SXCVLPWB0a4a
         ex4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=t7ul6qFjAV6/5cm3WrDVGikFzQ/5NU91CimGKn19A2E=;
        b=JRdXDh9Sr5YyIexQ3JuDui2+iB7Z4SsLymADGsrF+I37NrWwLYhPNgRXN+xsfgU1rV
         2fs9Y8ZnIL5MRFKcgSe8iZXhbUzbf9rjFR2VkOq5fVmqwKjtvKalN7MHlIW1nnuhcWnL
         jDf7JZb9eo4L23NpUzVzoJV7nXRDxm629/uP2DHa7/FuQ3uqz+nT4JXwrEwk+0f4qCWv
         hfjAZjASgsmeBVXno/Xk9MEWLo35cqQdecZU+tnflhPC5cyQ5PTrVlAolgJd3nCJ/qHt
         zStC2AUiIDzZV4/rFiO4Wlf7Kg1evekboqLyL88GksTVe595rlsDe5AyJBWSnGm23rlV
         1xfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a14si4311024edd.416.2019.02.18.07.30.54
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 07:30:55 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C95D2A78;
	Mon, 18 Feb 2019 07:30:52 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F256A3F675;
	Mon, 18 Feb 2019 07:30:39 -0800 (PST)
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
To: Peter Zijlstra <peterz@infradead.org>, Mark Rutland <mark.rutland@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
 <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
 <20190218142951.GA10145@lakrids.cambridge.arm.com>
 <20190218150657.GU32494@hirez.programming.kicks-ass.net>
From: Steven Price <steven.price@arm.com>
Message-ID: <eb7e0203-db08-743b-dbed-a7032b352ded@arm.com>
Date: Mon, 18 Feb 2019 15:30:38 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218150657.GU32494@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 15:06, Peter Zijlstra wrote:
> On Mon, Feb 18, 2019 at 02:29:52PM +0000, Mark Rutland wrote:
>> I think that Peter means p?d_huge(x) should imply p?d_large(x), e.g.
>>
>> #define pmd_large(x) \
>> 	(pmd_sect(x) || pmd_huge(x) || pmd_trans_huge(x))
>>
>> ... which should work regardless of CONFIG_HUGETLB_PAGE.
> 
> Yep, that.

I'm not aware of a situation where pmd_huge(x) is true but pmd_sect(x)
isn't. Equally for pmd_huge(x) and pmd_trans_huge(x).

What am I missing?

Steve

