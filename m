Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12669C468BD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 02:39:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C700E207E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 02:39:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C700E207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CE1D6B0008; Sun,  9 Jun 2019 22:39:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57DAB6B0010; Sun,  9 Jun 2019 22:39:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446346B0266; Sun,  9 Jun 2019 22:39:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E86976B0008
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 22:39:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so8100906edv.16
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 19:39:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RyFA1VGTrvnjjqSTKnvEHdEkEZsATntB0kbsInD7AOQ=;
        b=aExD6cImkMxwmCRCN2yS44Dif/kNstxCOOgU+9B/KtoqcZNmYvRIrIko3Jo93PY37C
         qqnf593/2UkV2MUsx3bKNnXuChM9k29p8oh2VZ8zdygeGE13Oa9YevPlUY3esUkhiHCU
         xyJJETG8bbwmdWrVGMdO4jYHInQLB0jsZ3ZOZiHu9DJe/M4ezZll2S2tze3ImiBmCZn5
         1ODtFbwC7op4Pty9JZl2QLWpWnvGzljC2YCx+z5ED3hSTbUi80+7i4mGl3U+BJ7rO4YV
         9o3j3YVphtuHHiS8U2CqJseH1Ff6VLjGfVTLvMeBZcLhrsm1jg5Ldbh/SYtotw5Cjil3
         TjkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU3hZ0GU8/etijJzeOyPW5/SZDwpEJgHDNUPLIhZwlekgSCJUsg
	QXiU3xcMHiWCkd06eEohjR00xTQMqLza8hagUs+RX+mQKpijhkiuB2Iw8BOSY8aBj4NyF8FdeTl
	mCqpDnJT8sdfltyJYcFr7sK4sfchyZs+C7NIhHH4a3wYFg7EoFTx2rLqU2IFCn1TQVA==
X-Received: by 2002:a17:906:604e:: with SMTP id p14mr12616759ejj.192.1560134343476;
        Sun, 09 Jun 2019 19:39:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7KsMfcPjBNHWLBbGnlCTm4rHYg1gYSM8FbGl8CW77w0c8uLjsBdCe1e4g37Ed9uBqzBf/
X-Received: by 2002:a17:906:604e:: with SMTP id p14mr12616709ejj.192.1560134342616;
        Sun, 09 Jun 2019 19:39:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560134342; cv=none;
        d=google.com; s=arc-20160816;
        b=iNI9jhn0lGuTcgVwroImS2gbJMiXEuc0p1fDoTzsC0NGk5gupG3PfPzOOPQHWzBWyz
         zG87R3LCtqCD7owK5o+kbW7OInZ9gVnUROEkv60SuJM6puX7zcFcwj5MBUjhPKnuRUd2
         m3+98zSwmQfYXE8H3s7NemUzapSqHwYZicqgOF5o8UbDhZJDZqNIJoZceRt4Xe/QxRZ4
         d0Mmel37asFaW2tB6rrnTEsL2xjFyEUBOW4vVaxuNnbXKVu64ggFgFgmO2NGum+ZHsQD
         7qYYri2jYhh7AsuNLagSsQe440tHkia2ZeC3yR3JHfT/w/IwYD+ZgJfePFuga1Dlajlv
         xSfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RyFA1VGTrvnjjqSTKnvEHdEkEZsATntB0kbsInD7AOQ=;
        b=iHkG/MFee4gZOLt8vwH/fiyo40XoggaNZqo3DQFz31yQgA1Y3gnSun37fzBJ8Qrck5
         norJoqVbAkSSSflOIdoKqDvRUW34PPZLfeRwFg2R/nOU0yo9JXF5jhn3kBior8LpCK3G
         VY42QJPw/w9ysXqHdLp46QGuHShPHbLL2n5pUFXCRMeIn0/ns/BVUGJ28loAkSKuGDiN
         Q6ZkOkFhA0cu2adNgJ1Yew0fRgblB0XdpUykNnNP8I4tOBHYYVzxOTinYovQluYrTSwt
         myjQFYMrR/5TArLvc3Kqv+rqzQDBiKh+APPtaokriq8N6llA+H6j1ERyNcY4Rt9CqZrC
         hpow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z48si718584edc.301.2019.06.09.19.39.02
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 19:39:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 95990337;
	Sun,  9 Jun 2019 19:39:01 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4353A3F557;
	Sun,  9 Jun 2019 19:38:53 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Christophe Leroy <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
Date: Mon, 10 Jun 2019 08:09:11 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/07/2019 09:01 PM, Christophe Leroy wrote:
> 
> 
> Le 07/06/2019 à 12:34, Anshuman Khandual a écrit :
>> Very similar definitions for notify_page_fault() are being used by multiple
>> architectures duplicating much of the same code. This attempts to unify all
>> of them into a generic implementation, rename it as kprobe_page_fault() and
>> then move it to a common header.
>>
>> kprobes_built_in() can detect CONFIG_KPROBES, hence new kprobe_page_fault()
>> need not be wrapped again within CONFIG_KPROBES. Trap number argument can
>> now contain upto an 'unsigned int' accommodating all possible platforms.
>>
>> kprobe_page_fault() goes the x86 way while dealing with preemption context.
>> As explained in these following commits the invoking context in itself must
>> be non-preemptible for kprobes processing context irrespective of whether
>> kprobe_running() or perhaps smp_processor_id() is safe or not. It does not
>> make much sense to continue when original context is preemptible. Instead
>> just bail out earlier.
>>
>> commit a980c0ef9f6d
>> ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
>>
>> commit b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
>>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-ia64@vger.kernel.org
>> Cc: linuxppc-dev@lists.ozlabs.org
>> Cc: linux-s390@vger.kernel.org
>> Cc: linux-sh@vger.kernel.org
>> Cc: sparclinux@vger.kernel.org
>> Cc: x86@kernel.org
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
>> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
>> Cc: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Russell King <linux@armlinux.org.uk>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: Fenghua Yu <fenghua.yu@intel.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Thomas Gleixner <tglx@linutronix.de>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Ingo Molnar <mingo@redhat.com>
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>> Testing:
>>
>> - Build and boot tested on arm64 and x86
>> - Build tested on some other archs (arm, sparc64, alpha, powerpc etc)
>>
>> Changes in RFC V3:
>>
>> - Updated the commit message with an explaination for new preemption behaviour
>> - Moved notify_page_fault() to kprobes.h with 'static nokprobe_inline' per Matthew
>> - Changed notify_page_fault() return type from int to bool per Michael Ellerman
>> - Renamed notify_page_fault() as kprobe_page_fault() per Peterz
>>
>> Changes in RFC V2: (https://patchwork.kernel.org/patch/10974221/)
>>
>> - Changed generic notify_page_fault() per Mathew Wilcox
>> - Changed x86 to use new generic notify_page_fault()
>> - s/must not/need not/ in commit message per Matthew Wilcox
>>
>> Changes in RFC V1: (https://patchwork.kernel.org/patch/10968273/)
>>
>>   arch/arm/mm/fault.c      | 24 +-----------------------
>>   arch/arm64/mm/fault.c    | 24 +-----------------------
>>   arch/ia64/mm/fault.c     | 24 +-----------------------
>>   arch/powerpc/mm/fault.c  | 23 ++---------------------
>>   arch/s390/mm/fault.c     | 16 +---------------
>>   arch/sh/mm/fault.c       | 18 ++----------------
>>   arch/sparc/mm/fault_64.c | 16 +---------------
>>   arch/x86/mm/fault.c      | 21 ++-------------------
>>   include/linux/kprobes.h  | 16 ++++++++++++++++
>>   9 files changed, 27 insertions(+), 155 deletions(-)
>>
> 
> [...]
> 
>> diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
>> index 443d980..064dd15 100644
>> --- a/include/linux/kprobes.h
>> +++ b/include/linux/kprobes.h
>> @@ -458,4 +458,20 @@ static inline bool is_kprobe_optinsn_slot(unsigned long addr)
>>   }
>>   #endif
>>   +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>> +                          unsigned int trap)
>> +{
>> +    int ret = 0;
> 
> ret is pointless.
> 
>> +
>> +    /*
>> +     * To be potentially processing a kprobe fault and to be allowed
>> +     * to call kprobe_running(), we have to be non-preemptible.
>> +     */
>> +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
> 
> don't need an 'if A if B', can do 'if A && B'

Which will make it a very lengthy condition check.

> 
>> +            ret = 1;
> 
> can do 'return true;' directly here
> 
>> +    }
>> +    return ret;
> 
> And 'return false' here.

Makes sense, will drop ret.

