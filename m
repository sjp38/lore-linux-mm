Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8672C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:42:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DADC222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:42:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DADC222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE96D8E0002; Thu, 14 Feb 2019 12:42:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70E28E0001; Thu, 14 Feb 2019 12:42:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EA238E0002; Thu, 14 Feb 2019 12:42:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 597628E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:42:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id m3so5325023pfj.14
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:42:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=u1F8cssiCEWbey4phsGbRHnO6z5hrr4yYt4G2B4UbAk=;
        b=AtHNnSY63R3qGBGuwY4sT5tEapKJsJfEzT8BTKsHk1BqH+tepsV9DdXK+iZVs1EtTH
         MH09Rya0MWP4Sa1hUNob+ncp7Dr+SYTGuP1/YamedRicWxd9+NNG2VM2W25zCRL6Wo7D
         GDBWdyPYxG6At6tUYHGMMgyJYw8c81xqftpgUyjJfvNdFRTYtCZdIefiEb9Fq3XY6Hgf
         VDa2YJ/RMtlAeLkqhHs3cNPI5eK+gtgGU/skncj+Sa/tsrZJMIk1rgdFeKX8M8aJ/1ps
         MvR29bcBGmOQ6YR2XnEfNUTcyT0Iynsa1+9kap9GfNU8caxf162mGqVAjo1yMwKuLwsx
         KKIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ972Apqm33Zo2W/1j4y+UK/19XkBheuHYjGXzD8/y0TlWZnnq2
	MqEhi9NaoKZPjBv8o7ud7JaDxJ/zPm5qOMMoQ0SPlTF+2YTgPYdIbOVoQ/tYP+sBpKsc5Za0euk
	UJYkO/Z58nV8k1YnXZC0CxutRy/17AVc3odhEk8F2HweW/oHkK1QBbo/o0tLQw66d/g==
X-Received: by 2002:a62:f598:: with SMTP id b24mr5254893pfm.72.1550166146553;
        Thu, 14 Feb 2019 09:42:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqbyheartzgU7iS61Rx3jU4QFpHcmdhOVZnjaGVRG6tzcViVuUhvJ/ugnnGxqWJfoLu8M8
X-Received: by 2002:a62:f598:: with SMTP id b24mr5254841pfm.72.1550166145788;
        Thu, 14 Feb 2019 09:42:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550166145; cv=none;
        d=google.com; s=arc-20160816;
        b=Wf30h7yeydtJt028M+WYRxoGLaKigtgFE+SpAEogNCORStDc0S7JiEYh1i9OSvq4Eg
         2Fty0xZFpxgeSTJsVYxEIZFXrjTFijHttl1kPUxChviP+XQbb4iSCgG4fhvG7wXRaflW
         rmAO1Q4sN4qE1OvkeiV370b3dXuA3qAA0qihPglEW4TtQLY0YVNvvIDkrb89x4/eZ9TA
         3cQaR8pP00kGaZ3/m7Ysz32T0x8FmFWGhxztmHmAK7qeGpreSyEiS9jQygi6faW5vsYA
         AAuuLqL549RMTtEg821n1DzmToKF0Nc0Hz4jSvQL2bZB+dQN5jZxquFmJGh96SdiSqhc
         EqvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=u1F8cssiCEWbey4phsGbRHnO6z5hrr4yYt4G2B4UbAk=;
        b=Ti94Jr07X7L9x2HskhEUC0aHd7ktJ/M5R1BQC+3Fqmt4nR9FJVqQuuvU2h0mysNPbe
         thY8q5fDaOa/VZCZ3Rew8jrMWKoyRizqeyYO/zTyWEDvuLvDnkjiCkl+wYFFqNIul0UZ
         sb9MrpQ9b3ZZlbabcmreQYeCjW9J71UlJnr4vEbZ8Zotu13a2n5XGuA78IgszRP0yIda
         +K2DPa0T49tL0NVuW0Xm7KzMxtlRTy92PcYujGOzxKJrpBpFRwnJgX9HOn8E//DkLWKA
         2BeTAAg78pGZKHWRdFxXk1WppAa6i7kbTtVbfymdCgAnveoNbOx2U0eecEh5V9SK92/P
         lhYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h8si2953890pgc.397.2019.02.14.09.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:42:25 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:42:25 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="138657185"
Received: from pmmonter-mobl.amr.corp.intel.com (HELO [10.254.87.236]) ([10.254.87.236])
  by orsmga001.jf.intel.com with ESMTP; 14 Feb 2019 09:42:24 -0800
Subject: Re: [RFC PATCH v8 13/14] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws,
 jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org,
 liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
 mhocko@suse.com, catalin.marinas@arm.com, will.deacon@arm.com,
 jmorris@namei.org, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
 tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
 jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
 oao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com,
 john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com,
 hch@lst.de, steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
 peterz@infradead.org, kernel-hardening@lists.openwall.com,
 linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <98134cb73e911b2f0b59ffb76243a7777963d218.1550088114.git.khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <a6510fa8-e96d-677b-78df-da9a19c4089b@intel.com>
Date: Thu, 14 Feb 2019 09:42:27 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <98134cb73e911b2f0b59ffb76243a7777963d218.1550088114.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>  #endif
> +
> +	/* If there is a pending TLB flush for this CPU due to XPFO
> +	 * flush, do it now.
> +	 */

Don't forget CodingStyle in all this, please.

> +	if (cpumask_test_and_clear_cpu(cpu, &pending_xpfo_flush)) {
> +		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
> +		__flush_tlb_all();
> +	}

This seems to exist in parallel with all of the cpu_tlbstate
infrastructure.  Shouldn't it go in there?

Also, if we're doing full flushes like this, it seems a bit wasteful to
then go and do later things like invalidate_user_asid() when we *know*
that the asid would have been flushed by this operation.  I'm pretty
sure this isn't the only __flush_tlb_all() callsite that does this, so
it's not really criticism of this patch specifically.  It's more of a
structural issue.


> +void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
> +{

This is a bit lightly commented.  Please give this some good
descriptions about the logic behind the implementation and the tradeoffs
that are in play.

This is doing a local flush, but deferring the flushes on all other
processors, right?  Can you explain the logic behind that in a comment
here, please?  This also has to be called with preemption disabled, right?

> +	struct cpumask tmp_mask;
> +
> +	/* Balance as user space task's flush, a bit conservative */
> +	if (end == TLB_FLUSH_ALL ||
> +	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
> +		do_flush_tlb_all(NULL);
> +	} else {
> +		struct flush_tlb_info info;
> +
> +		info.start = start;
> +		info.end = end;
> +		do_kernel_range_flush(&info);
> +	}
> +	cpumask_setall(&tmp_mask);
> +	cpumask_clear_cpu(smp_processor_id(), &tmp_mask);
> +	cpumask_or(&pending_xpfo_flush, &pending_xpfo_flush, &tmp_mask);
> +}

Fun.  cpumask_setall() is non-atomic while cpumask_clear_cpu() and
cpumask_or() *are* atomic.  The cpumask_clear_cpu() is operating on
thread-local storage and doesn't need to be atomic.  Please make it
__cpumask_clear_cpu().

