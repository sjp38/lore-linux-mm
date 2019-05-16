Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DDAEC04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:22:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDA6D205ED
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:22:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDA6D205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 437A86B0006; Thu, 16 May 2019 10:22:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E8C06B0007; Thu, 16 May 2019 10:22:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D7FB6B0008; Thu, 16 May 2019 10:22:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE63B6B0006
	for <linux-mm@kvack.org>; Thu, 16 May 2019 10:22:32 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g8so536000lja.12
        for <linux-mm@kvack.org>; Thu, 16 May 2019 07:22:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=luxCrZEStgJBs7CpALfKRLP6982TIh6OfHD/4DCx+GU=;
        b=EOO4I7WI62KlccU1BfaIaIxSgvXAK34EzsspOsZFfxemGD0tbOSXCMIoDApHZtFeeI
         fE0ffDFZ1KAJ00f0eyh1IEeMrolpkGAO1Ax6Dzh6M7R9lG2I1qm7IWhD45Lo8CRmSm2M
         G4NWeO3tiAGW2xMfTT8ymTlzbGez1EGKA7jiZkP0IU5v4yFRf/eaQTcQEU1dWf+6D3lG
         5EUmiK3CKk/W8YA97QfV1zttdzJ5YvkxHCwLWj+PZJGojv9VIXYk6NFyBkkDebfx1z7Y
         0sT7IYh2JwYHwwfxg49aCw/3TM/45As0v/5GyjsZfuALhDVTgA25tiRlHPanQRQd6kWF
         Z+UQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWH3lrvJb631SiKzXBrp9fkzMlVHFGcpiz55PY61TYa+B5r9d4+
	uXWilPpbWC6QqJPJt2MoWBWJvmZmdW1buFSWPYsOZR9A/FEmcrEXJKzHyqtvWDcAFj//Cti3F84
	JwcfMJMy1MPg08EV+zYoEKQnbmt53Rjsna5hr+g2uT2oZCxFgG1+B2Dt5PHfhB855XA==
X-Received: by 2002:a2e:5301:: with SMTP id h1mr17247299ljb.196.1558016552125;
        Thu, 16 May 2019 07:22:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvLEp+YVS/aWLxZzcj87NUl5WRwlNxuzrRY/SWDdLV/FLt7E3m/ySKowRlVAemcyfoL6FB
X-Received: by 2002:a2e:5301:: with SMTP id h1mr17247239ljb.196.1558016551207;
        Thu, 16 May 2019 07:22:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558016551; cv=none;
        d=google.com; s=arc-20160816;
        b=KoFh0etcksT13p6izgsOSZYWJjiEw7tLlEMAaOIDDioDY2smN6u1Q/EXZi8bdRLxiG
         2rB28Hl9GECzJGAg1BNw7iqanC6sJxsDL0u3JGuAR5ZSwvyFDejDbwVDXbMKznMXVrGS
         ZNSlb5nFVnqFxtoKEPQoB9oIJGWiXS5A1/3SCzDOHT2XKyY35RUbY1hfUv24a4QtHhIN
         aUNbG6Bjm1mnVk6nmAJ3hCrogMFaJ7smyY6DLf972vvi1y+XLMeTr3YfluM7ZI5JsWi5
         SgU1GbA/mN2QfGeCNMa62bvo7XX0t1QRp3e5mBns9vSt9zIjSnTC3+wOPt5kXLPEa9O7
         rSyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=luxCrZEStgJBs7CpALfKRLP6982TIh6OfHD/4DCx+GU=;
        b=GsUCVw2ETHZEqaxeW8ZdAmtuvX8iZbtgh3WVuuPtG6tDCbsSi0BitNe6expZPWSbT5
         XyYklht9fxv5IJZVL/2TS7hwF68upfaTxLQnnVX/V4SP6RrCmkXLUplR7dKqRwovN4UF
         XT8A3NIRG2AUneZC9aaAHbmapFwU7vDzZenospXm6XtRkFYRy3zrWhyt1xWbHqKVGLM7
         uoc4J15zQe7da5mo3YZitDVRTlRIT2P+ZigMvOfvWauCjRPiN8zFj/bPVICAfMBAV6we
         cU/yJKUUGv3gITW1yYBKJUlEt/nM+zJnTm9OfoLeC9l8XeBDtgLRBXsVItNgbFaSNRJp
         Je5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a22si4477181lji.206.2019.05.16.07.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 07:22:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hRHH5-0007GL-T0; Thu, 16 May 2019 17:22:24 +0300
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <20190516133034.GT16651@dhcp22.suse.cz>
 <20190516135259.GU16651@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <85562807-2a13-9aa2-e67d-15513c766eae@virtuozzo.com>
Date: Thu, 16 May 2019 17:22:23 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190516135259.GU16651@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.05.2019 16:52, Michal Hocko wrote:
> On Thu 16-05-19 15:30:34, Michal Hocko wrote:
>> [You are defining a new user visible API, please always add linux-api
>>  mailing list - now done]
>>
>> On Wed 15-05-19 18:11:15, Kirill Tkhai wrote:
> [...]
>>> The proposed syscall aims to introduce an interface, which
>>> supplements currently existing process_vm_writev() and
>>> process_vm_readv(), and allows to solve the problem with
>>> anonymous memory transfer. The above example may be rewritten as:
>>>
>>> 	void *buf;
>>>
>>> 	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>>> 		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
>>> 	recv(sock, buf, n * PAGE_SIZE, 0);
>>>
>>> 	/* Sign of @pid is direction: "from @pid task to current" or vice versa. */
>>> 	process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
>>> 	munmap(buf, n * PAGE_SIZE);
> 
> AFAIU this means that you actually want to do an mmap of an anonymous
> memory with a COW semantic to the remote process right?

Yes.

> How does the remote process find out where and what has been mmaped?

Any way. Isn't this a trivial task? :) You may use socket or any
of appropriate linux features to communicate between them.

>What if the range collides? This sounds quite scary to me TBH.

In case of range collides, the part of old VMA becomes unmapped.
The same way we behave on ordinary mmap. You may intersect a range,
which another thread mapped, so you need a synchronization between
them. There is no a principle difference.

Also I'm going to add a flag to prevent unmapping like Kees suggested.
Please, see his message.

> Why cannot you simply use shared memory for that?

Because of remote task may want specific type of VMA. It may want not to
share a VMA with its children.

Speaking about online migration, a task wants its anonymous private VMAs
remain the same after the migration. Otherwise, imagine the situation,
when task's stack becomes a shared VMA after the migration.
Also, task wants anonymous mapping remains anonymous.

In general, in case of shared memory is enough for everything, we would
have never had process_vm_writev() and process_vm_readv() syscalls.

Kirill

