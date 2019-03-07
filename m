Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34122C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 11:49:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A6A20643
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 11:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A6A20643
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64B6C8E0003; Thu,  7 Mar 2019 06:49:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D0868E0002; Thu,  7 Mar 2019 06:49:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44AB48E0003; Thu,  7 Mar 2019 06:49:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC8DF8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 06:49:18 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id n12so3249632wmc.2
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 03:49:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=qlRmZB9kaN/RX+irjUOJ1IYs/H7iKeXkrsnagD+20Fw=;
        b=QMHtm7c2LltwuBNO9iwtwHDHNY2VxNXdFzOFUYg3RMiVAMkKpdwjdelt9krDZlqr6N
         KHnDvMCsxy28vGOHUf1h1K57mzhZPtw33S+/jEcJ1kn09TGSdDSztwHDEUyT2ln5sT4l
         KQU2nLEqZ2ayYM/EIGBcN79wDA5MPptFoZeHEU5uxT9CKyxHZNQGYMki106H7khY6z+M
         /9BhQXiwsdKWwf/bukonC91kJSBPoCisBqMchwzNDu760qaq2hRERGEvyH2FJt0yNEnb
         c8W96dR1KKEozMhgN1PHjE61exWML4foUvy4CeNr1/VllU3ZzvOGiWRJE45+3UZoEBPu
         bgSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAWi3RXInxL7D1uRqeU5Lwg+UnqyDnaWrJp326nArbl/nG7pMF3Z
	yenFfANKFjYc41rpU/29gWCcYZJo+qudkEJD4Txvs6p8suqNTjaDeCvtdaV/2bL8KpQWScFijMz
	P4/A+bcyr9dFNHzh+2tU/KligCFjvW+svJX/QFW+doCLSfD1uCAClaY8KKNvvVGW8mQ==
X-Received: by 2002:adf:90af:: with SMTP id i44mr6472158wri.222.1551959358456;
        Thu, 07 Mar 2019 03:49:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqxzrPVGzNq3A5Ntjptz9Sl2No68TJSYALoc6+wtwgTTQs5wcC0/P109wZsh4VktUD+0EKdR
X-Received: by 2002:adf:90af:: with SMTP id i44mr6472102wri.222.1551959357235;
        Thu, 07 Mar 2019 03:49:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551959357; cv=none;
        d=google.com; s=arc-20160816;
        b=XK6/vqKc202pDt5nQLEOzEkgBnktyxr7GcNUjCKrJv2jPWJuPaRC2F1WmyoPZ/Jquv
         ObMg6bVcawXmDks7rUx0zdoFkTfCS0xoSl++c+5tuwCa6pTQa8pO7LrWyiutjacmyWIx
         eoG5Ho4AB7FhSkm67ZHqxcThQJ2IFPgaP5pCD+9G8LTKEf7Y0JeRtdUXPQxacPIEEwtQ
         liF7CHZakY+FYh+UDnr+O6uHVqn84rfBRV565rtEf/D5IvRPJF0hfIoC/KwG9dL9H+R/
         ANx5D3Y59X2wL6pw3nE6nVArUExZ4DWJjzwYYKmOuFbmV9QXFQ1cWhBneWpM0H4oe7jY
         sFgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=qlRmZB9kaN/RX+irjUOJ1IYs/H7iKeXkrsnagD+20Fw=;
        b=HJSNwE0+2poSOclxQ6xmSBilJib59U0Y0SYotebuFJdSob94sQzxJz4IsVGBdebm57
         hLOqDX+lKk7428cGh7M1yfj8Kmx9w9KiMq1JJcNFxwzaj61QD3lglEFmmBO+O2YWnIk4
         S42mfg4u50NTKQbue/wXHaR08NNqg3/vqqplPEZjIl8uiAsjvVywDH0lXrIjks3EFucW
         JLMykrSm3ATanP+3IEs1uUevA8KbDyXq0/Bp0w1zlm9bUV8zHKNJa4JmbyrNf7Xm3003
         MOsn8nCnV4WOJucU9jJd794sE/TuAatDxo63nOVF01HimZB429+LqFXaQyU8y9CSu9HF
         LlVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id r13si189332wrm.4.2019.03.07.03.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 03:49:17 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,451,1544482800"; 
   d="scan'208";a="298435532"
Received: from nat-inria-bordeaux-52-gw-01-bso.bordeaux.inria.fr (HELO [10.204.4.73]) ([194.199.1.52])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 07 Mar 2019 12:49:15 +0100
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <8fb27d2c-2165-7029-6ea1-94fc379b3be7@inria.fr>
Date: Thu, 7 Mar 2019 12:49:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190214171017.9362-8-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 14/02/2019 à 18:10, Keith Busch a écrit :
> If the HMAT Subsystem Address Range provides a valid processor proximity
> domain for a memory domain, or a processor domain matches the performance
> access of the valid processor proximity domain, register the memory
> target with that initiator so this relationship will be visible under
> the node's sysfs directory.
>
> By registering only the best performing relationships, this provides the
> most useful information applications may want to know when considering
> which CPU they should run on for a given memory node, or which memory
> node they should allocate memory from for a given CPU.
>
> Since HMAT requires valid address ranges have an equivalent SRAT entry,
> verify each memory target satisfies this requirement.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

[...]

> +static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	list_for_each_entry(intitator, &initiators, node)
> +		if (intitator->processor_pxm == cpu_pxm)
> +			return intitator;
> +	return NULL;
> +}

Typo intitator -> initiator

> +static __init void alloc_memory_initiator(unsigned int cpu_pxm)
> +{
> +	struct memory_initiator *intitator;
> +
> +	if (pxm_to_node(cpu_pxm) == NUMA_NO_NODE)
> +		return;
> +
> +	intitator = find_mem_initiator(cpu_pxm);
> +	if (intitator)
> +		return;
> +
> +	intitator = kzalloc(sizeof(*intitator), GFP_KERNEL);
> +	if (!intitator)
> +		return;
> +
> +	intitator->processor_pxm = cpu_pxm;
> +	list_add_tail(&intitator->node, &initiators);
> +}

Same typo


> +static __init void hmat_register_target_initiators(struct memory_target *target)
> +{
> +	static DECLARE_BITMAP(p_nodes, MAX_NUMNODES);
> +	struct memory_initiator *initiator;
> +	unsigned int mem_nid, cpu_nid;
> +	struct memory_locality *loc = NULL;
> +	u32 best = 0;
> +	int i;
> +
> +	if (target->processor_pxm == PXM_INVAL)
> +		return;


This test above looks wrong to me. First, it means that either you
return from here, or from the next branch below, hence the loop that
looks for best performance is dead code. Secondly, it means that memory
targets without a PXM never get an initiator.

I verified that removing this test makes things look better on my HMAT
tests.


> +	mem_nid = pxm_to_node(target->memory_pxm);
> +
> +	/*
> +	 * If the Address Range Structure provides a local processor pxm, link
> +	 * only that one. Otherwise, find the best performance attribtes and
> +	 * register all initiators that match.
> +	 */
> +	if (target->processor_pxm != PXM_INVAL) {
> +		cpu_nid = pxm_to_node(target->processor_pxm);
> +		register_memory_node_under_compute_node(mem_nid, cpu_nid, 0);
> +		return;
> +	}


This seems to contradict your first paragraph in the header where you say

"or a processor domain matches the performance access of the valid processor proximity domain".

By returning here, you're only keeping the the local PXM and ignoring
other initiators that may have the same performance.

I am testing a HMAT where one memory target has same performance to two
processor proxdomains. If no processor proxdomain is set in the HMAT for
this target, I get two initiators as expected. If proxdomain is
explicitly set in the HMAT, I get only that one as initiator.

Brice


