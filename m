Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4301C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:36:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79AAF21773
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 10:36:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79AAF21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15B546B000A; Fri, 24 May 2019 06:36:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10C416B000C; Fri, 24 May 2019 06:36:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3CCA6B000D; Fri, 24 May 2019 06:36:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 918686B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 06:36:21 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id r8so1458170ljg.6
        for <linux-mm@kvack.org>; Fri, 24 May 2019 03:36:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+dHsFaNc/9kBt77+Sy30DAJ4bmtuc84Uc22C67+SBDg=;
        b=HyZN3eGA1pk5MgwxmW3defrHvT+BIyR+mcWTEmaHjUA3NodQltTlCkGE4FSvHWoBrg
         +algD5bccBAjBSUKHMpYiJniX3c+RvZVYRBipt/A+7M+Mdaukuvg3kNui6ekFTgXkbup
         H1mAnGV2/pwR0y1sMBOcHx3IoNVBF2nmP0vN1DIH6uN6p5F07RmTrZ3WGSs4ej0SmNln
         HczkQ/fnxKQPnGcdn4MuQFZcG5htddvd0BcG/qEmVSb8zTaprZOKGmeCPUWQBJccFoi5
         oW/Bv6PEWyQ6NZCbxjLA01kwLH+EDDxVPAVAvk5yCH46n8GBVCCTQ7QDOLhzC0rqdfrt
         0gLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXMucvjuv/YRaFpNvhsPLuVm1vp0+syW6dQy1e5H43i/tmYyzBM
	rt6y41JvZJmVBB3dDt4ewzqs6y4IxlWSYP4EGEbcVzx+LEsDb0Mz6nD96t3v6feoiLYXoagQJ65
	MAIlu6HfpetCx124Hfcv3JUx6q8G0oP60qlNbcwjfQ6SxLvovZEf+oWqiTT1u+nT8Cw==
X-Received: by 2002:a19:740e:: with SMTP id v14mr44927089lfe.144.1558694180777;
        Fri, 24 May 2019 03:36:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmSXQv67kDQDQ3SaaxvWS0Iw9RumhdWr4eJ25GUlPflwCJmspNd1TWbP8sVsBMIcQKmX/5
X-Received: by 2002:a19:740e:: with SMTP id v14mr44927032lfe.144.1558694179683;
        Fri, 24 May 2019 03:36:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558694179; cv=none;
        d=google.com; s=arc-20160816;
        b=tZ8gIa3JzV4DW1d8I+7Y0y9GJ/G88zJj6uBZQE1vOqEhl9ZAGaABweSR/upKuu8zK4
         /NBwy+XTm+/KK09b0YDB/W3nDqKrCo3TejTBAI63ChhGh2ib8phVSR+5QXWZ1BhrpBah
         IY+RF8SMkyzk62kFpBf1BVQ/bGU6/1f2DJC9rwSnGj0LWSPUJLOna+2slySx7cjoXIjt
         XjwjfzFzRz1tAqecyT5Ut8/vf283sYRqdwoI6teJPQbGvwctumv9S8o1u+nnRA5I4aB0
         TOK3cyXFfGvEOapwj75PyKGhLV9279LcO7T7XRVBWoaD7wX78DbgIYHv9Ncx2luJwGp2
         fosg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+dHsFaNc/9kBt77+Sy30DAJ4bmtuc84Uc22C67+SBDg=;
        b=m48OQN0SHmObyggyn+bhLkrgJO0HbnkxpU1N/yfGOa+Jjn6WcjM0SBGhmCDY8eJ/5X
         0VkiucrGQbNbuRiF6bn1gVmC0vUSpkLHlo+qyC6E/KPI2fcz+NPqhiZJmOcQlyMZNs/A
         kgHM5FA5lWMetP0c6xw5wf5uz2JhVDeFX2ftNUZ5pgVQNiRd8e1BUg2XehmWcM4rKWmn
         +dk/KSOPtbgpr7Co+Ze0nBLL/kXG8tLonv3U/saUNyPJnxTdcByjT8ySlGecf1mVi5sv
         aFOt4u0WGvVG8aV3CdrKkYjIpKhPjqUeHrtybCDS72Dp1UzfRJciCHIsn/K2mLlKfRx+
         DeOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m13si1846683ljh.20.2019.05.24.03.36.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 03:36:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hU7YU-0005xE-Bo; Fri, 24 May 2019 13:36:06 +0300
Subject: Re: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
To: Andy Lutomirski <luto@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Keith Busch <keith.busch@intel.com>, alexander.h.duyck@linux.intel.com,
 Weiny Ira <ira.weiny@intel.com>, Andrey Konovalov <andreyknvl@google.com>,
 arunks@codeaurora.org, Vlastimil Babka <vbabka@suse.cz>,
 Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>,
 Kees Cook <keescook@chromium.org>, Johannes Weiner <hannes@cmpxchg.org>,
 Nicholas Piggin <npiggin@gmail.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
 Jerome Glisse <jglisse@redhat.com>, Mel Gorman
 <mgorman@techsingularity.net>, daniel.m.jordan@oracle.com,
 Jann Horn <jannh@google.com>, Adam Borowski <kilobyte@angband.pl>,
 Linux API <linux-api@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
 <CALCETrU221N6uPmdaj4bRDDsf+Oc5tEfPERuyV24wsYKHn+spA@mail.gmail.com>
 <9638a51c-4295-924f-1852-1783c7f3e82d@virtuozzo.com>
 <CALCETrUMDTGRtLFocw6vnN___7rkb6r82ULehs0=yQO5PZL8MA@mail.gmail.com>
 <67d1321e-ffd6-24a3-407f-cd26c82e46b8@virtuozzo.com>
 <CALCETrWzuH3=Uh91UeGwpCj28kjQ82Lj2OTuXm7_3d871PyZSA@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <58ad677d-677f-5e16-ecf9-565fcc3b7145@virtuozzo.com>
Date: Fri, 24 May 2019 13:36:05 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CALCETrWzuH3=Uh91UeGwpCj28kjQ82Lj2OTuXm7_3d871PyZSA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.05.2019 19:19, Andy Lutomirski wrote:
> On Tue, May 21, 2019 at 10:44 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> On 21.05.2019 19:43, Andy Lutomirski wrote:
>>> On Tue, May 21, 2019 at 8:52 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>>>
>>>> On 21.05.2019 17:43, Andy Lutomirski wrote:
> 
>>> Do you mean that the code you sent rejects this case?  If so, please
>>> document it.  In any case, I looked at the code, and it seems to be
>>> trying to handle MAP_SHARED and MAP_ANONYMOUS.  I don't see where it
>>> would reject copying a vDSO.
>>
>> I prohibit all the VMAs, which contain on of flags: VM_HUGETLB|VM_DONTEXPAND|VM_PFNMAP|VM_IO.
>> I'll check carefully, whether it's enough for vDSO.
> 
> I think you could make the new syscall a lot more comprehensible bg
> restricting it to just MAP_ANONYMOUS, by making it unmap the source,
> or possibly both.  If the new syscall unmaps the source (in order so
> that the source is gone before the newly mapped pages become
> accessible), then you avoid issues in which you need to define
> sensible semantics for what happens if both copies are accessed
> simultaneously.

In case of we unmap source, this does not introduce a new principal
behavior with the same page mapped twice in a single process like
Kirill pointed. This sounds as a good idea and this covers my
application area.

The only new principal thing is a child process will be able to inherit
a parent's VMA, which is not possible now. But it looks like we never
depend on processes relationship in the mapping code, and process
reparenting already gives many combinations, so the new change should
not affect much on this.

Kirill

