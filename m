Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BB30C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:45:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C122217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C122217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3B8C6B0005; Fri, 24 May 2019 06:45:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4466B0007; Fri, 24 May 2019 06:45:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8C7E6B000A; Fri, 24 May 2019 06:45:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53D366B0005
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:45:56 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id b29so1593214lfo.17
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EHzBNm7jpoAZqEAdIPtmn9MMNs37cXWjlC4ginYqACk=;
        b=npNZjOFjeBpy6QtgChgEV5vDPDCjlyXmARElKsCowcblHJ2+PEDnEfNAUqGj5ay7gn
         2A1oI1uODGmn7fAIvVbENV3TW/69t5/3EpQYNttYL85HBwFIj6NYyfXpGu7GMgurmrB7
         pwVGp+bxEIBLp4yipSFqBbvyqXmfDCTPxIQ7DvqAqJOTGp721MfYN5FKBYXleb2cpQma
         kK4conGf/LqTBLwlm/g31vWtbAzve4pL6rFQp861MjXfgMY697xJbM6Y6HIXwZC7kAFO
         OGQ3ktlVuJlfnLxwKoMkVDSbnG8FISxcVM/FdseXReOrj5Z26cq6xpfeazUb5WfxJKVR
         EW+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUNUeE+mLYskEEN3M8WhRfgS8gjynPSxxx0WY7lhCDyeN00cC5U
	uxZBemKnW/r+VHxunH1St0tUHlNVqVTCdon+Sj0cmhcuGndGUA1FFUbx1LZ/y23k3LdIzvLJdAK
	l3sD8Yv9Va+xksE355Ak1bVMyz5OsQNZQpHM1h1C/I4oLm1c3IgFUrAmCAVZWa9gQXg==
X-Received: by 2002:a2e:8143:: with SMTP id t3mr27797863ljg.131.1558694755792;
        Fri, 24 May 2019 03:45:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYCXZfBUH0O9W96n4N2e56p7LymZtEyHxtGvLZjRsqQPm94K++UZVSwTiafZ5KzE0w08VR
X-Received: by 2002:a2e:8143:: with SMTP id t3mr27797797ljg.131.1558694754465;
        Fri, 24 May 2019 03:45:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558694754; cv=none;
        d=google.com; s=arc-20160816;
        b=tY5RBDewbavFXVe/TG3c49roouT0lAR21YueJZUi8WFoSWslu6SlndRCxzmaQtx7Tz
         F3Rzqe02hCilhKu5Mx/rrepWlMjZg6HrrN/Dg6iGh2xoDhFS+xRBwKu4OLgFIydtRqgZ
         PXtsvUTdlEWR+LSh+LOH4pcYX6LT/9SV6C0WeSpliCY9kG1Z40U1oFoTZjvDPdtaeGkW
         rCFx1eusTZIxovnnD2YxBEfz49Gw57qw0JjsPZRUk+Uzfv+2G8NkVkw9B+bFtppi3tob
         tLOSJOq6qNrXZV8fHy6scxkkM/BCUyPEJsQEVKA8cmvR1PoIt7V1nHx123WYg7BJoohU
         aJ0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EHzBNm7jpoAZqEAdIPtmn9MMNs37cXWjlC4ginYqACk=;
        b=zvitNolggHnWNMV8mGUu+4ugzcNr9lIHl5KVUJScJBcbWS+LiMKXK7GKQHuH2KSTFe
         /wHCBMEy0s1Z5ddVmXI94i03VPhJ7ndKrKOr3VGfi1nh0p5BcH6GYw+aB7OpS4YkVWiw
         wVERLiOTwWSgUUiAEYKndrXhjgyjEB9nNmliDv7me3hUriAIE0b2Iua8pfe1GogDlWSi
         ym91XUkxtod4iXQbfrgomgEiIm+pChE+wG3ZrkOfXUYwnFiQtKG0Qqxx4kHd0jMkyxKz
         CjR/AfwJ6jzL2sMBYrF8RZrsNrxnJDVFMZyYc/p22fKmYgdLxcvV9/Imiyz6tP0He/xp
         2x1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e3si2258991ljg.124.2019.05.24.03.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 03:45:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hU7hv-00060o-CJ; Fri, 24 May 2019 13:45:51 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com,
 andreyknvl@google.com, arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com,
 riel@surriel.com, keescook@chromium.org, hannes@cmpxchg.org,
 npiggin@gmail.com, mathieu.desnoyers@efficios.com, shakeelb@google.com,
 guro@fb.com, aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <20190522152254.5cyxhjizuwuojlix@box>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <358bb95e-0dca-6a82-db39-83c0cf09a06c@virtuozzo.com>
Date: Fri, 24 May 2019 13:45:50 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190522152254.5cyxhjizuwuojlix@box>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.05.2019 18:22, Kirill A. Shutemov wrote:
> On Mon, May 20, 2019 at 05:00:01PM +0300, Kirill Tkhai wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a VMA from a process to current process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
> 
> Kirill, could you explain how the change affects rmap and how it is safe.
> 
> My concern is that the patchset allows to map the same page multiple times
> within one process or even map page allocated by child to the parrent.
> 
> It was not allowed before.
> 
> In the best case it makes reasoning about rmap substantially more difficult.
> 
> But I'm worry it will introduce hard-to-debug bugs, like described in
> https://lwn.net/Articles/383162/.

Andy suggested to unmap PTEs from source page table, and this make the single
page never be mapped in the same process twice. This is OK for my use case,
and here we will just do a small step "allow to inherit VMA by a child process",
which we didn't have before this. If someone still needs to continue the work
to allow the same page be mapped twice in a single process in the future, this
person will have a supported basis we do in this small step. I believe, someone
like debugger may want to have this to make a fast snapshot of a process private
memory (when the task is stopped for a small time to get its memory). But for
me remapping is enough at the moment.

What do you think about this?

[...]

Kirill

