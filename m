Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46D42C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 09:18:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 012EC208C3
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 09:18:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 012EC208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9215F6B0007; Sat, 10 Aug 2019 05:18:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1E36B0008; Sat, 10 Aug 2019 05:18:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BF476B000A; Sat, 10 Aug 2019 05:18:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD166B0007
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 05:18:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 41so85448473qtm.4
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 02:18:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=bO4ajwIZruW6CDQX8+FqDn+nhqT46y/306bNpC8fqeI=;
        b=bUThI6L+SAwu/Q8U1xPJ9BaWCu/nlChs6It4wNs691FMVjMTvJUOTV5jj6AYYdn3Wp
         7/BTc/dEOoWHjE1NRlWpIIpmvMVMFZRwd9R79g4LsJsFzqM5WJ3CnuZE4wlbz1nAjuyq
         disqHCZ+Jo5CWGDhIGVHwXO/6gwlnC3WCCGRecWmqPJbsPTi8Px8ja2V0mA0cAEZ0ymH
         zVdJUWx9OzlHLrXnfebUkxDrGs+LlRDiXNr3YdXxGB1FEKmpIIRu+pwHsVPproWX0dPk
         qaHi/iss7ewz2dXjOdIZ9ORUVBUmmg2dSUZnmfBJP/7DXMdxbl/+liVCr4z2aoSwx3Q1
         jhMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWGSHTf1DNkjGKykYL5eN9RQZVAKE820Aqd/a5GdwoYf2xu67ix
	VeBeobUP4q9eL1IfFFjn4pHEEQmnN0P1iRwOVZ3efPqcJk3X54tUFpmIVhHLOVNle02t2x+JMkG
	KJP56KfBJ2wandZZv7TnN6nILS+M8mUy/mLbfISyY5IlDfyGLqitJwsLxSqSOJ/K+1w==
X-Received: by 2002:aed:3091:: with SMTP id 17mr18078129qtf.290.1565428727125;
        Sat, 10 Aug 2019 02:18:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdn2e5I1CfRy3SOItOl8a9bKxWqnlMu7nzWrpZ5Ag21FgsAMjIWMCtO737kVFrArzMin+O
X-Received: by 2002:aed:3091:: with SMTP id 17mr18078106qtf.290.1565428726486;
        Sat, 10 Aug 2019 02:18:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565428726; cv=none;
        d=google.com; s=arc-20160816;
        b=y1G/5uEdKynJg1lt4Wy7aAfELokUXUKLdY53qdh6DGDtJmY7Q2pP/Hry5SgVAGtWtS
         qm8whUhnUCZNh7m4Ty6HAbcDo3buHGGrMLVj9Qlik2PZ/qepQq+AKstO/aiyxWowK8cK
         Sc4JFv9i3CwoBVRFzX1on5xhBEqcTC+pdnPrD97gS45Jnr5qYhqYwU3PZIFYj364R4B+
         LegWBvnotcpW1jeJ98hZHMdwCoCwevZ9/lMJLtZVuTrtistjwhMQETVXrDbBuldWjiD/
         574apYH0S4NE3++EOMz2yUT82F9LdQHjjwZ8nPb9XArUPXmIcdd6Y4MuJE9aB6Qg1s3y
         CWJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=bO4ajwIZruW6CDQX8+FqDn+nhqT46y/306bNpC8fqeI=;
        b=kbsLxHjP5AC2Znu6xW/JPQ+MggHTLwLo5VbQiN/rxvCxNXZ3ZaTA5AY9Wrln+wHql7
         5qf1SmwVjXYeKol9c2vB83+SLyrGK3ymyM/Hr7zG+2bUJjmqbSVy7csYTBZRr5DIKJwP
         WTU7UtTL8gE45j/Ifvf3RcFIuI9/C6y2Sgtbj6S6VYFWO0Sp8GRklGrbPvmHGSiGuLqr
         SysDW6FRC4uZIww5u8Wb1autSgyhsGBciJ3zDXMVDpnX9TrMSF5CAMeUEsmzELX9/kFX
         qyhZYqdyIBzj+jrYBSrziVL9LX/B8zZ04+1YVq8HUZLOlt/1gr/DFGTZvbtdLp9gLR4x
         IqeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v51si11861219qtk.217.2019.08.10.02.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 02:18:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8AA85300C72E;
	Sat, 10 Aug 2019 09:18:45 +0000 (UTC)
Received: from [10.36.116.22] (ovpn-116-22.ams2.redhat.com [10.36.116.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2E2485D9E2;
	Sat, 10 Aug 2019 09:18:42 +0000 (UTC)
Subject: Re: [PATCH v1 2/4] mm/memory_hotplug: Handle unaligned start and
 nr_pages in online_pages_blocks()
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Arun KS <arunks@codeaurora.org>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>, Sasha Levin <sashal@kernel.org>
References: <20190809125701.3316-1-david@redhat.com>
 <20190809125701.3316-3-david@redhat.com>
 <20190809144602.eddc3827a373f17ddda7d069@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <710da2da-6ad5-33f1-ff6e-88ed7c91607b@redhat.com>
Date: Sat, 10 Aug 2019 11:18:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190809144602.eddc3827a373f17ddda7d069@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Sat, 10 Aug 2019 09:18:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.08.19 23:46, Andrew Morton wrote:
> On Fri,  9 Aug 2019 14:56:59 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>> Take care of nr_pages not being a power of two and start not being
>> properly aligned. Essentially, what walk_system_ram_range() could provide
>> to us. get_order() will round-up in case it's not a power of two.
>>
>> This should only apply to memory blocks that contain strange memory
>> resources (especially with holes), not to ordinary DIMMs.
> 
> I'm assuming this doesn't fix any known runtime problem and that a
> -stable backport isn't needed.

Yeah, my understanding is that this would only apply when offlining and
re-onlining boot memory that contains such weird memory holes. I don't
think this is stable material.

Thanks!

> 
>> Fixes: a9cd410a3d29 ("mm/page_alloc.c: memory hotplug: free pages as higher order")
> 
> To that end, I replaced this with my new "Fixes-no-stable" in order to
> discourage -stable maintainers from overriding our decision.
> 
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Dan Williams <dan.j.williams@intel.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>


-- 

Thanks,

David / dhildenb

