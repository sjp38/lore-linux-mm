Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB64CC32756
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 12:34:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69BDD21743
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 12:34:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69BDD21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D96BB6B0005; Sat, 10 Aug 2019 08:34:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D46AE6B0006; Sat, 10 Aug 2019 08:34:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C10966B0007; Sat, 10 Aug 2019 08:34:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 752906B0005
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 08:34:09 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so61774907edx.10
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 05:34:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dQxLGgdX1gN7CDmeSmzhpSVESsW4Ramh6sEzCpgFrHM=;
        b=fxBtAWDYmoWJQzQoKs9fIVe2NY72omR9E3c+iq1PYMgBdm7/xXboXNzDB7ya27TNOW
         WMymwKGcQPrsl6MXdAS7MbTzOwuKrawiEBbCxArPr6Qml7fcqo5igMbC+9U5/OEnb68f
         Ve8R1mUd9RNGwL37d18D9QE4ocsSTKQzU/w/wLwFGwlVej1Pn/R1SqCplBAzs9CLSlLX
         9wiLzfUkhM5b3nHUBM5Fqg/mAuA2knd2Qw/GukhOAHI398l2sq+2mDqqq0xC9L4584tV
         0B5tzAKuS5A4BmixxHPBYy42+qy2EG67qkoarLMtKryFRk5Yx4fqEXV6nc6gNUIhRNsd
         FeeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAUB12sWN1UoZofdPi36MbbKOjEZr9Ex0T6eorBPTYKUD+QAJi9t
	A62Yd5LjvGfq7T1GYE20n0IsnoDQRqvejuRTEegJOooH6C4GhaGxoZNAt6gDuet2vztZawnJX6x
	FhrcDMbhxsA1fenjqjslGUUBo/67PpfatzGmXiS7HIu/S9kQWFflvNp2pStKXVcN4Cw==
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr22445642ejt.75.1565440448965;
        Sat, 10 Aug 2019 05:34:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLqp0MdrJq2XWzrc4T1y2uXApG5uTZb+HuTUJ3fsSADS8Yn7kPicCdyWsFuYqlEyytuIhF
X-Received: by 2002:a17:906:2111:: with SMTP id 17mr22445581ejt.75.1565440447880;
        Sat, 10 Aug 2019 05:34:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565440447; cv=none;
        d=google.com; s=arc-20160816;
        b=MMpqYZAMeauiJE3qbWmBCreVhdlxVDQBv1ISmgUq+zxwOie+oaQmVzPWKp94zrYUTR
         OnI3uLvoHD3i6rj91YRXg7sM6ytYHN6K4wZg1swVoJSsG+NDMArDhAoYBD5aBR3BangN
         xXBwYzyjOoF7HCTJvi83BQUt0DCAXLLtw5lETk8BYHgo51D+20uPMsZ3+k+ndTLOc6CZ
         0qwxAK/IdgkYikae8dVw0z7+zIYzC6qHWpl0ehArjQOih0Ycp4JHkWbtyQ68wT8FxTHC
         C9uqL3IxN3Vk8uNFLpzsnRPxUeoW2RuBhe2eKPa5tC8qjexECweEuBvP05h6/V5Kl95c
         5i8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dQxLGgdX1gN7CDmeSmzhpSVESsW4Ramh6sEzCpgFrHM=;
        b=yGaiSXOgF/asY+uDmni4vfxDtrcxh6j72b/kw0UiN2wNifZGk6VN+RMro80PaNnac0
         YqxV/R2t6vGLHu9LIXyNdcjNFQAl57+0bZPP8hmYeoDi9uec9NL3cD4AZf2FSXCdBqFy
         iM2WvzekgJyF0cX1PVYvjiF/Y+j710T07AZhVuebHB0ntIThhDknEgEyn4iOXnuTvwRw
         nzMTFyZ0YZ3Ht6oJEeGpHsBKQRw7Bi2ZdBWw0QGyqywSdhyjO+aBHCDOrnZGoPWD3T+M
         cnWBR0KbwYHUm3QU+PJmX8hK+HeZCKFRC2AZAxsyXbCTaJ1chNg1y9hjpskFI9DkJnSp
         3iCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id w26si793397eda.364.2019.08.10.05.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 05:34:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [192.168.1.66] (unknown [212.159.68.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id 063771C000AA;
	Sat, 10 Aug 2019 13:34:07 +0100 (BST)
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 Suren Baghdasaryan <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>,
 "Artem S. Tashkinov" <aros@gmx.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
References: <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
 <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
 <20190809085748.GN18351@dhcp22.suse.cz>
 <cdb392ee-e192-c136-41cb-48d9e4e4bf47@redhazel.co.uk>
 <20190809105016.GP18351@dhcp22.suse.cz>
From: ndrw <ndrw.xf@redhazel.co.uk>
Message-ID: <33407eca-3c05-5900-0353-761db62feeea@redhazel.co.uk>
Date: Sat, 10 Aug 2019 13:34:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809105016.GP18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/2019 11:50, Michal Hocko wrote:
> We try to protect low amount of cache. Have a look at get_scan_count
> function. But the exact amount of the cache to be protected is really
> hard to know wihtout a crystal ball or understanding of the workload.
> The kernel doesn't have neither of the two.

Thank you. I'm familiarizing myself with the code. Is there anyone I 
could discuss some details with? I don't want to create too much noise here.

For example, are file pages created by mmaping files and are anon page 
exclusively allocated on heap (RW data)? If so, where do "streaming IO" 
pages belong to?

> We have been thinking about this problem for a long time and couldn't
> come up with anything much better than we have now. PSI is the most recent
> improvement in that area. If you have better ideas then patches are
> always welcome.

In general, I found there are very few user accessible knobs for 
adjusting caching, especially in the pre-OOM phase. On the other hand, 
swapping, dirty page caching, have many options or can even be disabled 
completely.

For example, I would like to try disabling/limiting eviction of some/all 
file pages (for example exec pages) akin to disabling swapping, but 
there is no such mechanism. Yes, there would likely be problems with 
large RO mmapped files that would need to be addressed, but in many 
applications users would be interested in having such options.

Adjusting how aggressive/conservative the system should be with the OOM 
killer also falls into this category.

>> [OOM killer accuracy]
> That is a completely orthogonal problem, I am afraid. So far we have
> been discussing _when_ to trigger OOM killer. This is _who_ to kill. I
> haven't heard any recent examples that the victim selection would be way
> off and killing something obviously incorrect.

You are right. I've assumed earlyoom is more accurate because of OOM 
killer performing better on a system that isn't stalled yet (perhaps it 
does). But actually, earlyoom doesn't trigger OOM killer at all:

https://github.com/rfjakob/earlyoom#why-not-trigger-the-kernel-oom-killer

Apparently some applications (chrome and electron-based tools) set their 
oom_score_adj incorrectly - this matches my observations of OOM killer 
behavior:

https://bugs.chromium.org/p/chromium/issues/detail?id=333617

> Something that other people can play with to reproduce the issue would
> be more than welcome.

This is the script I used. It reliably reproduces the issue: 
https://github.com/ndrw6/import_postcodes/blob/master/import_postcodes.py 
but it has quite a few dependencies, needs some input data and, in 
general, does a lot more than just fill up the memory. I will try to 
come up with something simpler.

Best regards,

ndrw


