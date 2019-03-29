Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C34F0C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:38:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76002218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:37:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76002218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 964FE6B000D; Fri, 29 Mar 2019 11:37:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 912D66B000E; Fri, 29 Mar 2019 11:37:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DC086B0010; Fri, 29 Mar 2019 11:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7B36B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:37:59 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v18so2614698qtk.5
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:37:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=mbN1IRHLsjTQaFhVYmsOxlkSLPvhKlDSQFtzKoFSiCs=;
        b=jgSOCzyWlJ5F6HMtSkjZjfWpXmpYV+iX0O2pWch11Q4AK27M6o3Z74MwLB2KtGs9Yr
         mefhLevMZz3VnEMU8gZCHGNOtQo5FNNbbjl24KGgKBQFc3KPsuHtfSPWsbY3kWToB5Lg
         GYt8zlUlku2tGrSp1WPuUjFXhH3WudMlA37gkNs7+Xey2UH6+LcZhqsdCtPyEDl/Sjyn
         7BwejZ9B2DLdTdvQXLH+T29crX1XcFisByCJMJ1760Zb4KtnlZJB23MD9oNWoGjh7Ac8
         gH+kKfOfw6N+RXGbb+KHXTFGvV3eFf9yF4jdP2T0RsdJePkDH5nOxjsFFlJfj4fl5QBl
         69fQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXC4jcgFSs3k77IWfPQBOVmzC1+UZlFtohtG3ByEK4BPCz6wzif
	N+QQCjbRx3oZJP9kXbqTg2nawnkj9xzQNlBaM5nbWmf2dQ60mr7rGa1yGACiqAr1O2fC/kpai8x
	LLBK3sE+Ajyurlwu2QzM7dKWPLYcXm65hvYSuXzJU+qhoZ5CQ1K6vh+Je219wpdu8pQ==
X-Received: by 2002:a37:624e:: with SMTP id w75mr37768311qkb.11.1553873879097;
        Fri, 29 Mar 2019 08:37:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySkJZcoOSUt4m63aX+DyYHd8cDJeqY4Rlgfr3WEjj6kiSNZgp7Wy46cfaSdIDebRFCh6wP
X-Received: by 2002:a37:624e:: with SMTP id w75mr37768240qkb.11.1553873878072;
        Fri, 29 Mar 2019 08:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553873878; cv=none;
        d=google.com; s=arc-20160816;
        b=gG0BxqIhy+BG4I4XCYtyD+1OaS7BdrK3kCvF31kHvEJFa8cAU4wjjAl43cCvPK0r0j
         kwOJzhQELyrsY8VbK7IaBcmXv/24YeVPvnTw+vsaMRcdAgOM4yK9KHfz61lIgRUnUebI
         dqeBL7oC9Q9JuYNvleRA6mx6vLbXvshxyL/ltxRdF7IytkFhhQ+kPyeDbt1ylWQddbfM
         4kPEV2jcx3tsPdHrE6DmDhTMFwsOKQ2hK3OxHougLpcNL8d2JCp8Xhq18KnFYcBn0L3o
         kW/oibcJ21pgKyGM0pBS2hb7TzGP6p9AyX4jyVwvCbh9tWLhk47D6XvH9HljH6JC/DWq
         ruTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=mbN1IRHLsjTQaFhVYmsOxlkSLPvhKlDSQFtzKoFSiCs=;
        b=aevEu6q5+eZEM750TWkTGcSA/EmNjpe/qJg7B6qXzaCftnmDk5DAkEJUXmlzXGIezx
         rgDkJFfuVIz8q2zsrUNHtOdeokwpKmEo+4dgawursuLzqLSiwFSvOn75a8qJ37kdLbvY
         jjHccvthjBNTHYfJCkvPqgXuVyU6SZgCA5fwspvyEkYHZ3rPy4INDvwty1071bejG5XN
         unHBRFepElE9iPyO/1ruzbPkYsTXlNOuitd6HTjFOFnLBaNkhkZW8Ce9Ss+hOFfqiAkV
         fr2kx2NbKOgFe1eM9kY9zMtLirRCbu8ueHawzscpzhYCtlX9yt2hxxig2AmeDOwQq8O1
         sl7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t37si1459127qte.86.2019.03.29.08.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:37:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2577F81F01;
	Fri, 29 Mar 2019 15:37:57 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9FBD683E82;
	Fri, 29 Mar 2019 15:37:47 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
Date: Fri, 29 Mar 2019 16:37:46 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190329104311-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 29 Mar 2019 15:37:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 16:08, Michael S. Tsirkin wrote:
> On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
>>
>> We had a very simple idea in mind: As long as a hinting request is
>> pending, don't actually trigger any OOM activity, but wait for it to be
>> processed. Can be done using simple atomic variable.
>>
>> This is a scenario that will only pop up when already pretty low on
>> memory. And the main difference to ballooning is that we *know* we will
>> get more memory soon.
> 
> No we don't.  If we keep polling we are quite possibly keeping the CPU
> busy so delaying the hint request processing.  Again the issue it's a

You can always yield. But that's a different topic.

> tradeoff. One performance for the other. Very hard to know which path do
> you hit in advance, and in the real world no one has the time to profile
> and tune things. By comparison trading memory for performance is well
> understood.
> 
> 
>> "appended to guest memory", "global list of memory", malicious guests
>> always using that memory like what about NUMA?
> 
> This can be up to the guest. A good approach would be to take
> a chunk out of each node and add to the hints buffer.

This might lead to you not using the buffer efficiently. But also,
different topic.

> 
>> What about different page
>> granularity?
> 
> Seems like an orthogonal issue to me.

It is similar, yes. But if you support multiple granularities (e.g.
MAX_ORDER - 1, MAX_ORDER - 2 ...) you might have to implement some sort
of buddy for the buffer. This is different than just a list for each node.

> 
>> What about malicious guests?
> 
> That's an interesting question.  Host can actually enforce that # of
> hinted free pages at least matches the hint buffer size.

Well, you will have to assume that the hinting buffer might be
completely used by any guest. Just like ballooning, there are no
guarantees. If the buffer memory is part of initial boot memory, any
guest without proper modifications will simply make use of it. See more
on that below. At first, my impression was that you would actually
somehow want to expose new memory ("buffer") to the guest, which is why
I shivered.

> 
> 
>> What about more hitning
>> requests than the buffer is capable to handle?
> 
> The idea is that we don't send more hints than in the buffer.
> In this way host can actually control the overhead which
> is probably a good thing - host knows how much benefit
> can be derived from hinting. Guest doesn't.

So the buffer will require a global lock, just so we are on the same
page. "this way host can actually control the overhead" - you can
implement that easier by specifying a desired limit via virtio and
tracking it in the guest. Which is what your buffer would implicitly do.

> 
>> Honestly, requiring page hinting to make use of actual ballooning or
>> additional memory makes me shiver. I hope I don't get nightmares ;) In
>> the long term we might want to get rid of the inflation/deflation side
>> of virtio-balloon, not require it.
>>
>> Please don't over-engineer an issue we haven't even see yet.
> 
> All hinting patches are very lightly tested as it is. OOM especially is
> very hard to test properly.  So *I* will sleep better at night if we
> don't have corner cases.  Balloon is already involved in MM for
> isolation and somehow we live with that.  So wait until you see actual
> code before worrying about nightmares.

Yes, but I want to see attempts with simple solutions first.

> 
>> Especially
>> not using a mechanism that sounds more involved than actual hinting.
> 
> That would depend on the implementation.
> It's just moving a page between two lists.

Except NUMA and different granularities.

> 
> 
>>
>> As always, I might be very wrong, but this sounds way too complicated to
>> me, both on the guest and the hypervisor side.
> 
> On the hypervisor side it can be literally nothing if we don't
> want to enforce buffer size.


Just so we understand each other. What you mean with "appended to guest
memory" is "append to the guest memory size", not actually "append
memory via virtio-balloon", like adding memory regions and stuff.

Instead of "-m 4G" you would do "-m 5G -device virtio-balloon,hint_size=1G".


So to summarize my opinion, this looks like a *possible* improvement for
the future *if* we realize that a simple approach does not work. If we
simply add more memory for the hinting buffer to the VM memory size, we
will have to assume it will be used by guests, even if they are not
malicious (e.g. guest without virtio-balloon driver or without the
enhancement). NUMA and different page granularities in the guest are
tricky parts.

-- 

Thanks,

David / dhildenb

