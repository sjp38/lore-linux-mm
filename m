Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90076C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A7FF20663
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:34:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A7FF20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E63C28E0010; Mon, 25 Feb 2019 10:34:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E13338E000D; Mon, 25 Feb 2019 10:34:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDBC58E0010; Mon, 25 Feb 2019 10:34:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7438E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:34:04 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id w16so8042412pfn.3
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:34:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vkgH9+6AH4vkTAGEO3gO1nUMRgBUguP9BwVrAM4Qy1o=;
        b=iCiuL2//xL8Sif0EgdxAh/I2wu6R7zbQpWQB5CK7rZjovzueWweqdDzVyxfGgSHU0X
         UB+bDu+ce1S77ekIW4+dwyhqEaKaXntLMdPm40N254tDABTLzSe+eAFUe741DtH2GW/D
         w6k73RfuYBBkMMU4ACXnmROP3vHtd9kiY+ZN6/kv2f/eV87L4Vtk9CKwFWtxD0/xke+c
         uCITy58D4aKeS43ocw/yyHYHCEnpA6SdcGjI3b0vPIbQcz78p5/xeWX/I/rGhwgtTaj1
         5hkI+E4XCKCidtkVNaVgY1gxVR+XZliWHh1PgLRA7OYxOrMPmBkgIo45w59yzm1D3lXt
         IrXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYpUKqAV4i/kNgJZ3juOEUaJLAZfqPlISFCKFH1rCunSdFQgD51
	+qDZp0LTK7DVikBxJ32cQFX5DrSL9XpO1jL/mh+g6+6UqbaBtKJkTgNw2i3HOBRvzit1Yj59XQq
	4TR7QOxehXDe9q3YNEbUp9dJDkaLKmOTAtsU5vqouDD31XVWXDsG7PSJ2C/6TpTAujg==
X-Received: by 2002:a63:4247:: with SMTP id p68mr10802261pga.30.1551108844170;
        Mon, 25 Feb 2019 07:34:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbmaCl+SgFr1pGf7zWJ91rSIZ5T1STQMNhQo2fFazkd25mynNpIfy4HwHQftxHfZILqjQe4
X-Received: by 2002:a63:4247:: with SMTP id p68mr10802199pga.30.1551108843270;
        Mon, 25 Feb 2019 07:34:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551108843; cv=none;
        d=google.com; s=arc-20160816;
        b=niqMpzXE20yShncIyPup2vGY/Obt5xJ1QG8mUepJOjV+OOULOPoW4KAFbymsMwEM2K
         n83aSXznzNjSmmRT7EZmub3TDSCQDx72mz81uD7Ob/cl6p+uMS2bvV52Dnre+tE0XF13
         LfONAAFBQN07EJPZ4JGnLb2davyfyKErD2YeDwtKOj0UJDBA8G3vULURrtYBWzo2Ag58
         7EjU1F0JOOATFK0frTv4QV+Ah9sYpXehYOYjFe2oFvlIz+ahtQMJpxeQtlWuIOBAUsGQ
         0tIYcH8zDh0yffqOxkCIePd7mgQrJ+njVSBWfpgnCDnyO+YXtFqqHnCP98I7v0vfpXgc
         AQjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=vkgH9+6AH4vkTAGEO3gO1nUMRgBUguP9BwVrAM4Qy1o=;
        b=PNFzQwYMxumY1pv3LTQrZMn6Fpt5Oi41CFvsGVA60v5DXKqRf1XGAjz7+MdrSOacE2
         ydfayTuMXJICuoT45gNXftN/rr/+9iSJM6qsXxS184NuzY1dpEkoqO5KL36baGvqJkL9
         8mS6T9TS1DRRQBceQ6WVKECJyIqA9vbzUvqTLYa3d+yvwPkCFoomhEvboj5+auR+MYvY
         4SUk+O8QL/TTjVyQLaBaNBTi+xtM07nY0brdOYcEFzjcsscOAzKsMz/aeaE75tWm8T5i
         6S5JzNO01hlBnZf2+TfAe62nitbPFMs5tEwZH5/QpqO3xEBXVK7oIUxIxl4iwXqmEgow
         oxvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y9si9271203pgv.134.2019.02.25.07.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:34:03 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 07:34:02 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,411,1544515200"; 
   d="scan'208";a="137037992"
Received: from mmshuai-mobl.amr.corp.intel.com (HELO [10.254.87.252]) ([10.254.87.252])
  by orsmga002.jf.intel.com with ESMTP; 25 Feb 2019 07:34:02 -0800
Subject: Re: [PATCH 2/6] mm/memblock: make full utilization of numa info
To: Pingfan Liu <kernelfans@gmail.com>, x86@kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andy Lutomirski <luto@kernel.org>,
 Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Jonathan Corbet <corbet@lwn.net>, Nicholas Piggin <npiggin@gmail.com>,
 Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <0371b80b-3b4c-2377-307f-2001153edd19@intel.com>
Date: Mon, 25 Feb 2019 07:34:03 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1551011649-30103-3-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/24/19 4:34 AM, Pingfan Liu wrote:
> +/*
> + * build_node_order() relies on cpumask_of_node(), hence arch should 
> + * set up cpumask before calling this func.
> + */

Whenever I see comments like this, I wonder what happens if the arch
doesn't do this?  Do we just crash in early boot in wonderful new ways?
 Or do we get a nice message telling us?

> +void __init memblock_build_node_order(void)
> +{
> +	int nid, i;
> +	nodemask_t used_mask;
> +
> +	node_fallback = memblock_alloc(MAX_NUMNODES * sizeof(int *),
> +		sizeof(int *));
> +	for_each_online_node(nid) {
> +		node_fallback[nid] = memblock_alloc(
> +			num_online_nodes() * sizeof(int), sizeof(int));
> +		for (i = 0; i < num_online_nodes(); i++)
> +			node_fallback[nid][i] = NUMA_NO_NODE;
> +	}
> +
> +	for_each_online_node(nid) {
> +		nodes_clear(used_mask);
> +		node_set(nid, used_mask);
> +		build_node_order(node_fallback[nid], num_online_nodes(),
> +			nid, &used_mask);
> +	}
> +}

This doesn't get used until patch 6 as far as I can tell.  Was there a
reason to define it here?

