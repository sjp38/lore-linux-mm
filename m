Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA2F6C04AB4
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 07:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E483208C3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 07:05:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E483208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA11C6B0003; Thu,  9 May 2019 03:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2A986B0006; Thu,  9 May 2019 03:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A2BF6B0007; Thu,  9 May 2019 03:05:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 679986B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 03:05:30 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id f25so1164792qkk.22
        for <linux-mm@kvack.org>; Thu, 09 May 2019 00:05:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=kAOBwpN4b2vLeVPMMWuYF1W3cQlMXLND/pYoQLZriXY=;
        b=BScC3kPk26MNpyrhXD0ZjYukA3sbXrupOxnUgJswi6vw9UC0FjucTVrnYJ8UKFOPGY
         7IgrWbVpw7RjjoytbKFP1p7gT2xor7FxrxOQ4LIn7XCocXiEB2VKfuZIGDLuV6VImJer
         jF4U/CZMa10ljzUOcV7sxuYW5/lrLQQBXvdozgilUGjO5hexO3oLwK6/ObH0VRiqgJ1J
         zihmyjwYU5i/SUsOPjkXXkTxOVcozyHwP857eFlDFoCU95mBE3FS0N04waebaapxG2Zv
         JeOf1lfHpuATe89kuy5sYtUfBieppQJQBcUebj/ANosueZXLo46iASOBxhajN6qpbF5V
         AbYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWlnFvXPiQZlXeMDkdnUjLeMTeKwAe2jko/T/R663hKJ3aL+c/g
	EEnADaCft+QwPX3FsIKf7TNBEiANXlUkwwc7IF6Lmrs4u0SrJF3+V7jt0trmTak/I5cR/JsqLWn
	eM+WhFd86RyONRgRwmAmEEsWI1Azxs+Cvccxb2dpf1riYETrh4txaJQahzlYWw+/dJg==
X-Received: by 2002:a0c:c110:: with SMTP id f16mr2161400qvh.190.1557385530177;
        Thu, 09 May 2019 00:05:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzErtWqafSsASxKCBbsQKs1uhIFZZaf6sPZeF68T0IZjVFvtqYyGSNL97JlhD6uOjZgtKna
X-Received: by 2002:a0c:c110:: with SMTP id f16mr2161372qvh.190.1557385529607;
        Thu, 09 May 2019 00:05:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557385529; cv=none;
        d=google.com; s=arc-20160816;
        b=xDrVZRalmOOYAiEwvaKywawEv5k4vjJ7s8IK868fS/CepJropFEcgGgr+Gu0DeWoFk
         GhcrpamOAzS7envlDypH/8AVlQvc4yKqr38sqaKjhsCXJXeItuApWctXAxkXBOMCv3eT
         W4hWvJqq80v8j6H9XGxNoW2YvVwxjmLCcHc6ywh58Ex1RRX+1zsUUNq/55qCRi6fPFMf
         a3PJBG2NLblKtAY0NkbX4q8es2tzxwwGNUOJacTd3YvrXmnEhqrxLeqijF00btyHbJRq
         RBf34y2H8MfaKrmES4a82e1m2HjpqVwWM6QL9MKzo6PpAF71ak8sj0unej5OkbOJZBXw
         ys5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=kAOBwpN4b2vLeVPMMWuYF1W3cQlMXLND/pYoQLZriXY=;
        b=mdwuxXPJ72xijEY6Tjow1RWseh8R3uNRNpPH5lCytSRgMERsJelw6HoTEXuKl0ShlF
         Z9Fwtp3dupW0DxH0s2wQvXi8YEKLlUJkhkl3t8oTp0ob6cb6PKG0Nc7uOcW5xX6Ylluq
         Mgi/PfB/x/BeE3dENJ0PY4nj5pCAzehM8rOxKsuhRdDUaC8SFtYobcU4PclvvKK6pLxu
         TDzlkrK9zxcjc8hR+XKSJtDUkpBrKxj8zGEke7dpcxir5uIBObyW5g0aNkI3Vxmt5Duj
         1denwfvRA1aag4pQhLI6R++3S9VZnTxUSQuZh28i2IQj4s9L7tUht3SBYYMWCjL5GgGm
         uJYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o10si956930qtm.37.2019.05.09.00.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 00:05:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F07A03082E5A;
	Thu,  9 May 2019 07:05:27 +0000 (UTC)
Received: from [10.36.117.56] (ovpn-117-56.ams2.redhat.com [10.36.117.56])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EB9AB8916;
	Thu,  9 May 2019 07:05:23 +0000 (UTC)
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
To: osalvador <osalvador@suse.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-6-david@redhat.com>
 <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
 <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
 <CAPcyv4iRQteuT9yESvbUyhp3KVVgTXDiGAo+TwPCM_4f0CzBgg@mail.gmail.com>
 <edd762a1-c012-fe05-a72e-2505cd98188a@redhat.com>
 <1557356938.3028.35.camel@suse.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f7fac4cc-468e-0787-a364-760e68f6b1c2@redhat.com>
Date: Thu, 9 May 2019 09:05:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1557356938.3028.35.camel@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 09 May 2019 07:05:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.05.19 01:08, osalvador wrote:
> On Wed, 2019-05-08 at 09:39 +0200, David Hildenbrand wrote:
>> However I haven't really thought it through yet, smalles like that
>> could
>> as well just be handled by the caller of
>> arch_add_memory()/arch_remove_memory() eventually, passing it via
>> something like the altmap parameter.
>>
>> Let's leave it in place for now, we can talk about that once we have
>> new
>> patches from Oscar.
> Hi David,
> 
> I plan to send a new patchset once this is and Dan's are merged,
> otherwise I will have a mayhem with the conflicts.
> 
> I also plan/want to review this patchset, but time is tight this week.
> 

Sure, take your time. I'll resend this patch set most probably tomorrow
or early next week. Cheers!

-- 

Thanks,

David / dhildenb

