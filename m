Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B59C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD21E20663
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:30:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD21E20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31BB58E000F; Mon, 25 Feb 2019 10:30:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CB9F8E000D; Mon, 25 Feb 2019 10:30:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 146F98E000F; Mon, 25 Feb 2019 10:30:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB5318E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:30:42 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e2so7504340pln.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:30:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=X/LuRqo38XO/9DXO+3PBIaONx82ZyIqQnDokOIB9Pb0=;
        b=qvuSio8AA/cvSNqK6WvOMwjTDydO6bGkNDBK8AfONJ0gZW2ouuON/FWeoT3dSARY2M
         S1PygFNuRhByuP1K5BGIQVdZULs9d4faM0smfWjSsemhtw07KTuRyacYzZUR5L8Rmd+k
         aYnc8iRRgM53p8dWj9f9OD7oyPHvhxqtoKAVDUQl1/rZmpcMSdeu/GE0Yihd/DPx+S4e
         O8xi2SjTjwesFP2LRWDAhjBgAhJqISNlYQSqkxOMVDuvFAqq5Dv3wEHVJIfri4niNlmx
         3or2rRoSmXcd6C8hCyrAc092YoDsury+KVjRHUJ7H9lhqjzbvvS0cWXUFEcHBA5eqHSH
         pQ1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaCIIprNEks+cKk2Mfj57rZ7qih5HpWSSeWp33r+4VXSnd14td6
	Wy2FfEJlrv4HR6zJ0rwjhxhAaQqqwbe3GhotrYf09/Lhm+3n2+8QUU/g2VHwUi6YUDqi8gJiOou
	RYvN/rn+Y84Qw2+fBmm8zHCH6mgQ/9dJ18Ld5ySppcaj2Vpfve8J2JclJ2BEPUsOTQA==
X-Received: by 2002:a17:902:87:: with SMTP id a7mr11133937pla.295.1551108642353;
        Mon, 25 Feb 2019 07:30:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbfFYKjeqpZlJOZPtxG6KqkELp4oxxn7Xqv84TZND9tg6c1LL8pRqo1UdyeObwtYLGntA/e
X-Received: by 2002:a17:902:87:: with SMTP id a7mr11133864pla.295.1551108641432;
        Mon, 25 Feb 2019 07:30:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551108641; cv=none;
        d=google.com; s=arc-20160816;
        b=jT/5smmHeyE/+vnRnTOegwq0CYMNKxwNY5rzP5OojLQ9lZsfdZ8mlM8BRanSvTaL+6
         WSo0jOnh/Mt85tSoZXKc5U0jX0Vtp2p28a8n7C4jyjnoWqGvIIt3BGtKqn+6qSfU2DD+
         PTT/edwOk84xy0yL0tpUrn2mQwcgkydOxWavk7kBORxy123q5/9WP9s8pL01BmcmNM5n
         4eAMlJX3SwgkGoQvX5Kcg1HJc62ud5bgTjzmjW1W592eHx/51y7VzeSBzAlzoDuyia0N
         kFw+M7qsN8rzdH3Lx/qSH1i+9Wxg4mq/uTgrjHF4yheEkSgP6FK8ibR5H2ehuvaVlUR6
         9S5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=X/LuRqo38XO/9DXO+3PBIaONx82ZyIqQnDokOIB9Pb0=;
        b=nz3x01O0n8UxYn2r+qaapEER0Yk7cSTyr2XLS9gNh4Oa6kmu3+YEjmVoWg/lj+2hlX
         oDHQw4unvqoCfx4+gCyCQ7Zdb3omyYtD83dGzR4UCqdKCirkM+T4UStn9plSIwABAG2N
         smnx3/lNu/mFE4+kOTW6Mz7Yerw4uPFh9MlqI40yQu6ad56Cpz0mbMxMiN+3aBeSwrfE
         V/+78Y/G04HgnFXQ9L2LrMu/Cyj1is3ruHpOYis9qbupi+09aM6qppEe1slNDIsACi0k
         hejQ7KweMNUtj3tbyTPBJ+w7zoy+TeenkuCotvrOxPpk1ode4tt9n0s8NSITKC3/3Csc
         oQDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id cs11si10501843plb.248.2019.02.25.07.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:30:41 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 07:30:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,411,1544515200"; 
   d="scan'208";a="137037030"
Received: from mmshuai-mobl.amr.corp.intel.com (HELO [10.254.87.252]) ([10.254.87.252])
  by orsmga002.jf.intel.com with ESMTP; 25 Feb 2019 07:30:39 -0800
Subject: Re: [PATCH 5/6] x86/numa: push forward the setup of node to cpumask
 map
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
 <1551011649-30103-6-git-send-email-kernelfans@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <0c76e937-7cca-12a5-0655-ea8c4a427c54@intel.com>
Date: Mon, 25 Feb 2019 07:30:40 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1551011649-30103-6-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/24/19 4:34 AM, Pingfan Liu wrote:
> At present the node to cpumask map is set up until the secondary
> cpu boot up. But it is too late for the purpose of building node fall back
> list at early boot stage. Considering that init_cpu_to_node() already owns
> cpu to node map, it is a good place to set up node to cpumask map too. So
> do it by calling numa_add_cpu(cpu) in init_cpu_to_node().

It sounds like you have carefully considered the ordering and
dependencies here.  However, none of that consideration has made it into
the code.

Could you please add some comments to the new call-sites to explain why
the *must* be where they are?

