Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76903C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A9E27B84
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:53:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A9E27B84
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C33C86B026B; Mon,  3 Jun 2019 00:53:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEC5E6B026C; Mon,  3 Jun 2019 00:53:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAB996B026D; Mon,  3 Jun 2019 00:53:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57B246B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:53:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so23868269ede.8
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:53:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bPIWbE2q76g+esVcv8gpMOKvYwWEx38JKPKguY5Y3MQ=;
        b=rfCL2pZKf8NRu+VGM5NpFZOWodV6Bur7kvVsBPSEsERPD0LKUw0ynEvK/42nRqpVbg
         VtwwJn9bMtZrVEWLYr/3b9MQT6UN11aEl2DHUnOcjzTEhH0UXnw316JmvXT57/DUaCAi
         aevQLC+CUeSgMr+8/x9LJ6UGMmgBgy2F6x3eZg1FVCINrgPToFqSEJosh11Iu803soA7
         aobTA3dG20dtdGrF4BoyTmZ1Hak1fxNgu1NHqRXFDJ7T9IBUC9PReh+ZlDehhw01y0ey
         eL1s5+/ISI3PFSA7R9K97gYDxwhh5AWuQW4T//RIQvG8s5eCwCoNu76gMeDPT6Z2ganj
         la3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVWWcwT7IS/no0V5BqflgyrEP+VEOlTIPqu5qZPBa0tn+KARkr+
	Aeah419i9s1QbvRGgPTMQr3jcRIF6paViWVK3YoPNKUs61/A9zVCYLYydFkporqwlJsoIJcFspI
	+uVJxiSBICyM6ANQ78tEv9gC0nLMemeyIy/AxYT7EpVLuOreYUNbX15IAPUGr/JPwwQ==
X-Received: by 2002:a17:906:4482:: with SMTP id y2mr21501298ejo.201.1559537600908;
        Sun, 02 Jun 2019 21:53:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8Qo0MTH1Wmy/txoNXaVwAaRaBLH8nXAZaTZ3dcu+048jAPyScangDsLeIctUD3uC+MSDA
X-Received: by 2002:a17:906:4482:: with SMTP id y2mr21501252ejo.201.1559537600024;
        Sun, 02 Jun 2019 21:53:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559537600; cv=none;
        d=google.com; s=arc-20160816;
        b=oYDGHpzfabjbJNYjity2JMEJsgCk/B43XXLAAxg4801JZkGQhBknn65RaziR/78wvp
         lpbynvC+mZb4H8Cp1Kf1x2GSPjR/dgS+v3yPpZmDafnP5vqDEkWm0b70KIqubWzyD4Au
         ffsTKR+In95dEyniU+nplg/VDiTviT9FtNMW1usV3lnbC/xBt7kHPCJeBDol+aOVJbtt
         gmDnhbFjLQEUaq4kMXZEBiSBSCb7YSNSB6kwOxOG4LmoD9eOjmn7XzBr8P21kldEDqpM
         qRWEqQwPS63+u1eaOuTifUiIDdMuTSY842euq8EyMKg2vw6bh2Z9ZWO6hJqTEucUS0lD
         5uIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=bPIWbE2q76g+esVcv8gpMOKvYwWEx38JKPKguY5Y3MQ=;
        b=hOvWrjSuEAYPH879bx1jCTSRRMNpRwPYSzXuf45uUB4SUqPOfJD0iYsdqijbRvsgWZ
         0ZFszbT+hqYlXirV7Hf61jr6EaYdTYHYutswW4FPFlFHJ3dofysQi8DFmmGajCB0bwPU
         E4AELir9qeGJPZrv2RhriU4G6QKUKho8jTYfEHAQl3bUscl+48RTRDLen/OE9U5Kpdo/
         NA3qfcFBCqjk2Rt245CQiV/fOIYmQpF16RdNryz7A221vMVSVW8vE3AGkG+IC8MrzCmH
         nUvCDJeyy6TQEaL7NROJV0T5TmzF7aPi2M/w3ubLWm7hOUbDtNCRPiQcJzM09Ru0oeSV
         RNrw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ec18si252386ejb.374.2019.06.02.21.53.19
        for <linux-mm@kvack.org>;
        Sun, 02 Jun 2019 21:53:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A87D1341;
	Sun,  2 Jun 2019 21:53:18 -0700 (PDT)
Received: from [10.162.40.144] (p8cg001049571a15.blr.arm.com [10.162.40.144])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CC0BB3F5AF;
	Sun,  2 Jun 2019 21:53:11 -0700 (PDT)
Subject: Re: [RFC] mm: Generalize notify_page_fault()
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
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
 "David S. Miller" <davem@davemloft.net>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
 <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
 <20190530133954.GA2024@bombadil.infradead.org>
 <f1995445-d5ab-f292-d26c-809581002184@arm.com>
 <20190531174854.GA31852@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6338fef8-e097-a76e-5c07-455d0d9b6e24@arm.com>
Date: Mon, 3 Jun 2019 10:23:26 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190531174854.GA31852@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/31/2019 11:18 PM, Matthew Wilcox wrote:
> On Fri, May 31, 2019 at 02:17:43PM +0530, Anshuman Khandual wrote:
>> On 05/30/2019 07:09 PM, Matthew Wilcox wrote:
>>> On Thu, May 30, 2019 at 05:31:15PM +0530, Anshuman Khandual wrote:
>>>> On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
>>>>> The two handle preemption differently.  Why is x86 wrong and this one
>>>>> correct?
>>>>
>>>> Here it expects context to be already non-preemptible where as the proposed
>>>> generic function makes it non-preemptible with a preempt_[disable|enable]()
>>>> pair for the required code section, irrespective of it's present state. Is
>>>> not this better ?
>>>
>>> git log -p arch/x86/mm/fault.c
>>>
>>> search for 'kprobes'.
>>>
>>> tell me what you think.
>>
>> Are you referring to these following commits
>>
>> a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
>> b506a9d08bae ("x86: code clarification patch to Kprobes arch code")
>>
>> In particular the later one (b506a9d08bae). It explains how the invoking context
>> in itself should be non-preemptible for the kprobes processing context irrespective
>> of whether kprobe_running() or perhaps smp_processor_id() is safe or not. Hence it
>> does not make much sense to continue when original invoking context is preemptible.
>> Instead just bail out earlier. This seems to be making more sense than preempt
>> disable-enable pair. If there are no concerns about this change from other platforms,
>> I will change the preemption behavior in proposed generic function next time around.
> 
> Exactly.
> 
> So, any of the arch maintainers know of a reason they behave differently
> from x86 in this regard?  Or can Anshuman use the x86 implementation
> for all the architectures supporting kprobes?

So the generic notify_page_fault() will be like this.

int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
{
        int ret = 0;

        /*
         * To be potentially processing a kprobe fault and to be allowed
         * to call kprobe_running(), we have to be non-preemptible.
         */
        if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
                if (kprobe_running() && kprobe_fault_handler(regs, trap))
                        ret = 1;
        }
        return ret;
}

