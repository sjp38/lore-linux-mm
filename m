Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59622C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:10:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 172F8218A2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:10:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 172F8218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE3406B0003; Fri, 22 Mar 2019 12:10:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB9416B0006; Fri, 22 Mar 2019 12:10:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5B886B0007; Fri, 22 Mar 2019 12:10:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93F776B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:10:35 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q21so2748307qtf.10
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:10:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=DYZRW1HbMw0mjSRErQnXpeaeAikC5qL3028WMKtAUaQ=;
        b=A59TmUAlzduTqvQgcHsxqTGLYYugBH3xPkoxs1BgYCxceBfKYC9kJoj0JMQtVz3PoE
         ZozoIFWeuz1ApSrD7dvJryvbjF8s3GaA+FGuI6OW4nDnn05z0AN+fhnqpPULiJ0ZZozD
         8KUQCjKEmdyqR7maBv7vvRkp0RS4/INFLQ1GcIhcIc+ZBuafHeH1k7fDap6UJ0r6BZa8
         QrTz/R/HVOgjPVwbK+qzjj1a76TZFzILJccY9mqp8eMXlOeWIN7HhBEWyZ2C7HdQvGSf
         XSBVwLdrIxRXqTGbsD3+sgrOWplLfbwF13/EIzO+n1QDMRNaJS7DC3T3O3rrLwbhHu7h
         yXkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWnVH4dOYuXUfWZU2CpKiYLH3O6s8x4n9znEoj7QhsYcOrd9MuG
	LCB7av0L48BfuJLbbwDG4ut8QZc1jUVvxSQN8yo6+0r+fvE5HNwUM+KQoQPxrkvMbg2tsZ83R49
	1f9ITNyUDcoujELluf0LUNkDcNCJXMy9gPagRsacqi1tZuUfPrh+xU/ALKDxczUGQJQ==
X-Received: by 2002:ac8:27a6:: with SMTP id w35mr8691078qtw.157.1553271035305;
        Fri, 22 Mar 2019 09:10:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySHloNa1oS+Lr3U/k3rAMzCoosS5D2uEGymiZ9al5Hj4kgrWbf9d2lSrOIu1zbeLjG7LYR
X-Received: by 2002:ac8:27a6:: with SMTP id w35mr8691002qtw.157.1553271034506;
        Fri, 22 Mar 2019 09:10:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553271034; cv=none;
        d=google.com; s=arc-20160816;
        b=X0dvmsxWzEcd7G8WdjSXdh0h6DMsummJ1cFegmJeN5Z0rTlHMSe4Yre5ekfuEUzean
         VK2D9tvRrEqIC4poeEustJ+/PETxG8xY5XflCo2HTTtxec1SLtLwcjYqCl8RMsfwVViv
         ZPrE88EKUVxWwdfzdXQNND2j/KwnP5kYEhowSxZxSyZ6/XX5aiPVGtewY8VmSN0XQbhL
         Hrb8sgmZb8CigM/5C+D4v962upAvil3Aqo50AO/yDz/DAKheR14LW4foZYRc7tbbzNoy
         08kjFy8sLNy4EmVvn8FqiBr7F0HubtUu24WHvQBaMFHCPES1Ve+uADrbNC9ewW/UjO2x
         /1Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=DYZRW1HbMw0mjSRErQnXpeaeAikC5qL3028WMKtAUaQ=;
        b=ZnLVq6RnebxLZHGtAuu89/XkoAt4OSZQwzXauAvoeRpZfy5iNqT40ldim+7Phdz9GQ
         o3IFd3V+i2/GsRk3t0Z68M32cITUKUJZU87679BpxF3QHWzmI7ZaEseA4kdDicRBmdx0
         xKAVw7eIMvS10ljEqbiDXZus8TI4ax4gxp9AihmTgFuKcO2m3UECKxJaPe5KtB0eyao/
         4RLO1aQ3GqKHS5+XnjOAWHuKaTuLwSjfYIbRVFsPeZuKM9o6AhKa7CWdCaTFElFoq5pR
         aVDWfUXsjaKJvMfr4pFv99PIpg0GwZwA27jAKp68PRfUB+NIot5DBWRwH9+yb/UusbdK
         m0Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u17si1983252qvm.77.2019.03.22.09.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 09:10:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E82F38666D;
	Fri, 22 Mar 2019 16:10:32 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 472915C579;
	Fri, 22 Mar 2019 16:10:28 +0000 (UTC)
Subject: Re: [PATCH 2/4] signal: Make flush_sigqueue() use free_q to release
 memory
To: Oleg Nesterov <oleg@redhat.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@vger.kernel.org,
 Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
 Eric Paris <eparis@parisplace.org>,
 "Peter Zijlstra (Intel)" <peterz@infradead.org>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-3-longman@redhat.com>
 <20190322015208.GD19508@bombadil.infradead.org>
 <20190322111642.GA28876@redhat.com>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <d9e02cc4-3162-57b0-7924-9642aecb8f49@redhat.com>
Date: Fri, 22 Mar 2019 12:10:27 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190322111642.GA28876@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 22 Mar 2019 16:10:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/22/2019 07:16 AM, Oleg Nesterov wrote:
> On 03/21, Matthew Wilcox wrote:
>> On Thu, Mar 21, 2019 at 05:45:10PM -0400, Waiman Long wrote:
>>
>>> To avoid this dire condition and reduce lock hold time of tasklist_lo=
ck,
>>> flush_sigqueue() is modified to pass in a freeing queue pointer so th=
at
>>> the actual freeing of memory objects can be deferred until after the
>>> tasklist_lock is released and irq re-enabled.
>> I think this is a really bad solution.  It looks kind of generic,
>> but isn't.  It's terribly inefficient, and all it's really doing is
>> deferring the debugging code until we've re-enabled interrupts.
> Agreed.

Thanks for looking into that. As I am not knowledgeable enough about the
signal handling code path, I choose the lowest risk approach of not
trying to change the code flow while deferring memory deallocation after
releasing the tasklist_lock.

>> We'd be much better off just having a list_head in the caller
>> and list_splice() the queue->list onto that caller.  Then call
>> __sigqueue_free() for each signal on the queue.
> This won't work, note the comment which explains the race with sigqueue=
_free().
>
> Let me think about it... at least we can do something like
>
> 	close_the_race_with_sigqueue_free(struct sigpending *queue)
> 	{
> 		struct sigqueue *q, *t;
>
> 		list_for_each_entry_safe(q, t, ...) {
> 			if (q->flags & SIGQUEUE_PREALLOC)
> 				list_del_init(&q->list);
> 	}
>
> called with ->siglock held, tasklist_lock is not needed.
>
> After that flush_sigqueue() can be called lockless in release_task() re=
lease_task.
>
> I'll try to make the patch tomorrow.
>
> Oleg.
>
I am looking forward to it.

Thanks,
Longman


