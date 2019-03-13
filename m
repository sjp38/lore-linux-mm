Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3381FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:48:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED97D2147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:48:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED97D2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C388E0006; Wed, 13 Mar 2019 12:48:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B9AD8E0001; Wed, 13 Mar 2019 12:48:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A94C8E0006; Wed, 13 Mar 2019 12:48:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 047538E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:48:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o9so1195744edh.10
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:48:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=lghDKZgyrm86hfNmt3u3cOOP9IXBV2jyjrtyVBPLQx8=;
        b=X6SYgNt5cZywb/VLtuq1XAJ24ROz+9QHEMgLgYbGcOhGLGm4nbGCuV/2QaD5pruxqa
         YgJFf68HKyhb5CRLHQ1bG6ffTXwFAnO0gF74aVAfyYGUSGxaEzW0hmtw7v/IW8h499yg
         rEBC35xtxLedRoumIXTOCAlVG/cDlq3E1lr1Kny10fPWtxKbYZ49cl66GOyeCWo5YZZB
         yLztFQvNdsALMXzuZxt0Alwo4a8gmhOtkfSiqPUPEl6BlA92qseJ+6fdlWV3YYQuAiML
         YjOCYSMgDP521YxI8KSP1sNmYoXlBzPg5WKkvl8thX9DmDLFrrsyAql4YZ2gtK2jD6RJ
         Tvhg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVLou0AoFh227/JScEpO1OTX20WcAKih2Jnv3dF6BbGj4h9u31v
	ikED5fr0qvjgsYhS48ExNOjDze7UDPJREf4UHIIG1oTRfxkziKmWwxRT37gemZINWf7cMb7ltxG
	4iAFY7O4XF3CVjYhEvG5QiRCKyiDI0KenpdnjppI4NQZsu+4HASSL/WXAxSJsuko=
X-Received: by 2002:a50:c212:: with SMTP id n18mr8125275edf.23.1552495709603;
        Wed, 13 Mar 2019 09:48:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDf0ZAfX4htFGVXjmAL45jLMwz4aXXF6err7qfMqCG0eWxqIchJJfGmgYWtk/GyIDkZP6v
X-Received: by 2002:a50:c212:: with SMTP id n18mr8125216edf.23.1552495708345;
        Wed, 13 Mar 2019 09:48:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552495708; cv=none;
        d=google.com; s=arc-20160816;
        b=k1kDzfoE629ZSZ1tnnVEn+FXSJujox/KtIK1MrL9WA3pC+JWFkfPh9VvLzL2zoMSIC
         fXlOr/MPStPimztGniEns4zaUEK0sziAmrgoW7WoZlDA7g1KjE3IeBqK44sVGlr5pkyT
         ZPj6eIA1ChibgadQIZgPKRg7e+pnlXe5lkm2k7p/9InMZYRaZZqV06vSv3/0bmXAffAG
         8WVajscVMfx3+iSweNFE8MAWFK0j/leOlKeF9qg9NLkDd2uU+f3tXaIzbgl+ZyAX7u4e
         31WRxRzCq6EayuYjjkL9MKw68/vyrLLIsWeuaGL2NF5Hkso3mH4hFTUk/FbL432QtK0s
         VcKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=lghDKZgyrm86hfNmt3u3cOOP9IXBV2jyjrtyVBPLQx8=;
        b=zYx8ZD+5CtTwXaqW02tfL6l+zfRZK3MLaZ8LTsac67euUepV2OJlAKg7bKPRcbLkLk
         s23o9JmpUHydEvMUq/4UpVII+DWWxaWtJD8GkHCCRXLFY+DkiakdM5VcJD7kk4f2aDjn
         mBeNZh/CIc43rIRCb9kj9wk9Z7bwf2NFEM8rkIps1cuxMLy9dAiRuceKGV5jYXcGFtFY
         WEsMx7J0flibyVrboQEB3W1avpjkC43SBLS79Uhps5K6vQxvzjH/n2+nj8BrGNPzoaGD
         7ECVwIG3N36rST8Y5F35G/zjl04e4H1u7PXMsauNzNnBnWK3VQ5q3CCAhPDgPrLcf6Q9
         1ZdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id g26si267011ejd.14.2019.03.13.09.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:48:28 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 2A6EDFF822;
	Wed, 13 Mar 2019 16:48:21 +0000 (UTC)
Subject: Re: [PATCH v6 0/4] Fix free/allocation of runtime gigantic pages
To: Dave Hansen <dave.hansen@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190307132015.26970-1-alex@ghiti.fr>
 <875e6287-9528-45ec-788c-9c785e548942@intel.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <de40e6f1-c520-bcae-2009-19c0abbcd5d5@ghiti.fr>
Date: Wed, 13 Mar 2019 17:48:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <875e6287-9528-45ec-788c-9c785e548942@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/13/2019 05:41 PM, Dave Hansen wrote:
> On 3/7/19 5:20 AM, Alexandre Ghiti wrote:
>> This series fixes sh and sparc that did not advertise their gigantic page
>> support and then were not able to allocate and free those pages at runtime.
>> It renames MEMORY_ISOLATION && COMPACTION || CMA condition into the more
>> accurate CONTIG_ALLOC, since it allows the definition of alloc_contig_range
>> function.
>> Finally, it then fixes the wrong definition of ARCH_HAS_GIGANTIC_PAGE config
>> that, without MEMORY_ISOLATION && COMPACTION || CMA defined, did not allow
>> architectures to free boottime allocated gigantic pages although unrelated.
> Looks good, thanks for all the changes.  For everything generic in the
> set, plus the x86 bits:
>
> Acked-by: Dave Hansen <dave.hansen@intel.com>

Thanks Dave,

Alex

