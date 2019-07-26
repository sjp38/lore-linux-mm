Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D914C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FAEC21871
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:53:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FAEC21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0A126B0005; Fri, 26 Jul 2019 08:53:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE0E28E0003; Fri, 26 Jul 2019 08:53:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCFF88E0002; Fri, 26 Jul 2019 08:53:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D85C6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:53:35 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e39so47223451qte.8
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:53:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=DHcuayelp8myF8MmoINiMSJ6lAdY92SYzASiTn+SS7A=;
        b=QnzOqWaEe4n4mEdSDcqt5Fr9ZkRqfWcY6hA/piNj4c2PgqMlUVE79zVkBBC8JI/gjf
         Xar1ZpQy8NuJIh43S64Gly/gZdYQkTodAjkg7pAvSRWHB+ofq4t5lEVDi60czNaqpZQt
         HxWyNmxdt1Yj/1JSEn4kTm/GbmLCjJaSMzOqDfFBddG7VLejWh/l1aO1ifed0uE3mQz7
         YxF3itpkpGTPgBdOrf8kEMML1ycP5oKDgkQ1lkyNRQerG1Fe9BmazcOsosvTp7nDS+Jq
         1omG2UWCqVSz6LPu8RP0Bx/9asztjBcqPI70yYU0qLRc4fVMXXuq/ouWQS9fItl5gO6y
         HxPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUuu4E0a7VstLw+4jZ6e/8pUQlj4aRiUZk1N4BUzcJVDWW+IiPv
	AZ464AUjxETZpVUM4x3/6VjlOfmyMOweJ/LtxVovsLfZwK7tmg83HkdLOklttAAKxuQKU4oQOsr
	SWKQTnOhFJu5hTNKnf/PCkUEezhUQiP3guivepxXTOTtgnU8k1Bkyxah1C1dq9ttkew==
X-Received: by 2002:a05:6214:1441:: with SMTP id b1mr66209326qvy.218.1564145615416;
        Fri, 26 Jul 2019 05:53:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9rNVsuKpGj+MCqKdRhNGQ2HR1rCSco5KQ8YcGSH6h6+Td94HDCIB5gQNX+c51qSCm5vd4
X-Received: by 2002:a05:6214:1441:: with SMTP id b1mr66209301qvy.218.1564145614864;
        Fri, 26 Jul 2019 05:53:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564145614; cv=none;
        d=google.com; s=arc-20160816;
        b=oHjhtr0sX4aywr8X9IcD/GyzvgO+qSUZeHVmAAaur5IE6hri/n34s52zO+j0ixCQ7/
         yOpPZIPrBPNCawxWr6PfJuWAQo30b+BqFYKyvw06woyGDnAZU0Wt+Fy+N9239lkcszWh
         tNJcJ6fvelaNuwUz8IKJQYslCMmemkqLI032LqVuUT8giTNpPOdmpimrl0hT/BRxtwvm
         I6QvA06sCTPY0Qyjmnw8Ucm0R1ssHdYqaTkhKsYen2hTZUQ8njeHM/p49Dww2X3dlxZp
         8IhQR+CnTyjpn07vHRpEGadmcrWZNcMkWBbXOkzhh4VPafwRrrlP326q8tqoyu0jfsvg
         4Dgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DHcuayelp8myF8MmoINiMSJ6lAdY92SYzASiTn+SS7A=;
        b=qbbgbtv01sN7FYoa3Omr8pLuTMtZY/hZm8OHMeO/wEct74G/b5UicCcAqo0Mrt6qZ7
         yxJEuuXZ/xe8qm8MgIlXFch7XjYLuqHsq3AARV4byC8XrwWY4neSk03eHxC0wTXICrtZ
         0dNOwVL8e4iclF9QbCihW+uUYQtIW29u54vnjqwyLtMAA5ZcAH5RxU1EA84BSUa2p0c3
         +k9SBy4cP3QoAhcE93hKaAIH9S+yvh3x+234QdAWnK92yU/PFDpg25en843iCyQG6i60
         xl5w9G1NgBlkva/sTjL6VAKpg6fhwN+1fXUQ91kunAZ0TPX2wF/X6iJxvrBZnno/i+UZ
         3Otw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si20447817qvo.107.2019.07.26.05.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 05:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AE5F6300D1CA;
	Fri, 26 Jul 2019 12:53:33 +0000 (UTC)
Received: from [10.72.12.238] (ovpn-12-238.pek2.redhat.com [10.72.12.238])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3F4645DE6F;
	Fri, 26 Jul 2019 12:53:19 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
Date: Fri, 26 Jul 2019 20:53:18 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726082837-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 26 Jul 2019 12:53:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
> On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
>> On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
>>> On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
>>>> On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
>>>>>> Exactly, and that's the reason actually I use synchronize_rcu() there.
>>>>>>
>>>>>> So the concern is still the possible synchronize_expedited()?
>>>>> I think synchronize_srcu_expedited.
>>>>>
>>>>> synchronize_expedited sends lots of IPI and is bad for realtime VMs.
>>>>>
>>>>>> Can I do this
>>>>>> on through another series on top of the incoming V2?
>>>>>>
>>>>>> Thanks
>>>>>>
>>>>> The question is this: is this still a gain if we switch to the
>>>>> more expensive srcu? If yes then we can keep the feature on,
>>>> I think we only care about the cost on srcu_read_lock() which looks pretty
>>>> tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
>>>>
>>>> Of course I can benchmark to see the difference.
>>>>
>>>>
>>>>> if not we'll put it off until next release and think
>>>>> of better solutions. rcu->srcu is just a find and replace,
>>>>> don't see why we need to defer that. can be a separate patch
>>>>> for sure, but we need to know how well it works.
>>>> I think I get here, let me try to do that in V2 and let's see the numbers.
>>>>
>>>> Thanks
>>
>> It looks to me for tree rcu, its srcu_read_lock() have a mb() which is too
>> expensive for us.
> I will try to ponder using vq lock in some way.
> Maybe with trylock somehow ...


Ok, let me retry if necessary (but I do remember I end up with deadlocks 
last try).


>
>
>> If we just worry about the IPI,
> With synchronize_rcu what I would worry about is that guest is stalled


Can this synchronize_rcu() be triggered by guest? If yes, there are 
several other MMU notifiers that can block. Is vhost something special here?


> because system is busy because of other guests.
> With expedited it's the IPIs...
>

The current synchronize_rcu()  can force a expedited grace period:

void synchronize_rcu(void)
{
         ...
         if (rcu_blocking_is_gp())
return;
         if (rcu_gp_is_expedited())
synchronize_rcu_expedited();
else
wait_rcu_gp(call_rcu);
}
EXPORT_SYMBOL_GPL(synchronize_rcu);


>> can we do something like in
>> vhost_invalidate_vq_start()?
>>
>>          if (map) {
>>                  /* In order to avoid possible IPIs with
>>                   * synchronize_rcu_expedited() we use call_rcu() +
>>                   * completion.
>> */
>> init_completion(&c.completion);
>>                  call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
>> wait_for_completion(&c.completion);
>>                  vhost_set_map_dirty(vq, map, index);
>> vhost_map_unprefetch(map);
>>          }
>>
>> ?
> Why would that be faster than synchronize_rcu?


No faster but no IPI.


>
>
>>> There's one other thing that bothers me, and that is that
>>> for large rings which are not physically contiguous
>>> we don't implement the optimization.
>>>
>>> For sure, that can wait, but I think eventually we should
>>> vmap large rings.
>>
>> Yes, worth to try. But using direct map has its own advantage: it can use
>> hugepage that vmap can't
>>
>> Thanks
> Sure, so we can do that for small rings.


Yes, that's possible but should be done on top.

Thanks

