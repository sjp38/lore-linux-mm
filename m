Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72DD2C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:01:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32B3C218DA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:01:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32B3C218DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA9A66B0003; Fri, 26 Jul 2019 08:01:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5AC56B0005; Fri, 26 Jul 2019 08:01:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A70DC8E0002; Fri, 26 Jul 2019 08:01:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86E1D6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:01:19 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x1so47342263qts.9
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:01:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=w3wuoFfbMt9qdirrl+bhnjG3ZFuqAGhEyYyG9y4KPa8=;
        b=iYfQ0aHapM/4QhjWn4x7NSWzSOta0xv8KK2UmRkAvTdjOOitOlMhzLyL+FC2cjaud9
         cSPPIBcirzdBuxXpB9jTSMcmvV1SqjVtLrczbUenLpra4Nzm4Lv3M/foGA6GW0xjExuQ
         F3OjIKIod+PEp1tTOTMye0lDv723bCoTh2vNhSiUh8muLbVeE2E5d6G0XfAy7SuSMo7g
         fzpXg8jHpsc1akrjjrdtJEozPkXQdb8D4y9pa/vQfwNEmZssm/UUK+kEF0jmjm4olpIk
         Bwds4N6ev7EYu/Id4DBIbO9Ma/xULrxN1Yyb0ylQBn9KcMV+nR6xn9SE9Y6FAIExmn8Q
         upCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWrsarwelc3PmAK8V2v6pEyzz1yJqPzyHamtOMYyrKfnZ0WSfZQ
	JoQAVPApBmpuXY1mU9iZiKZkjRGBgkiV2S2d806W0Na6RwScGy9iySyLJxmmWderQZbqugo4f0w
	yaVpMoSyV8Fi4apMjUlRCIV1QzSm8u1wscOfoC0hgzOxLW3bzkfXfYYd6ti43EpQY6g==
X-Received: by 2002:a0c:9932:: with SMTP id h47mr67061726qvd.147.1564142479204;
        Fri, 26 Jul 2019 05:01:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxo7nWCBKN2/bud0eO4LLcRLf07/NmBP9kkKdJhDfUz6ldemcpgRUewbLPtH54bDw+DVDq4
X-Received: by 2002:a0c:9932:: with SMTP id h47mr67061143qvd.147.1564142470088;
        Fri, 26 Jul 2019 05:01:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564142470; cv=none;
        d=google.com; s=arc-20160816;
        b=Ni5VzACwWByXwnGPQZd0TGZvptj1UWuTgdyP5RqQ1wfOjGjldGJ5j50Wix8F71tgkA
         OoDU4Ji+PIEyPp5NkhCToVO9MIUHap5i2XRazFk2mNGlQqpP41ii/mHrd10Cqmtjvn2B
         cOs1x1NrvfJZLuYAiYuJSgxCYQFVi+FLmXLII7YgvP8fwGVuKduHKRO975uAYt9kvqIG
         8ijZSYrE0N3eKshIeVeYEuho5I2QIHhKD7TjVk19G+qA4jNcvG1ird0dwLqO1LIYG9Hn
         PG/9LWOxfsjJ97ckUvtn7OZVZrizfdoHiESW3IW9N6kLM6BNoLCHqtQMaNysperJ1bEx
         aCXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=w3wuoFfbMt9qdirrl+bhnjG3ZFuqAGhEyYyG9y4KPa8=;
        b=SugUosrecNFNOmcmJh5eXTRryiD5iZ+V3z/7dyghEtzQrxNU9wOvhr+r1jArCzE8Cp
         NtdHeb1qEUiP7WQ7IeJ8t1ZjRqSmSzIjWSZVGkah5tTqSjT/MUaVsniCkkjXLNU2uydv
         oponwV7v7uUeLm0x/IKU3jxlPyOeDw1E38VuxF/E3j8TNx+Uw7NuUP66iVtdVr70I9FK
         rsLmrvDAcivIKnp74aVRhYCRG+sqcSsBs+mbqoIkfrqtGWzYxF/dToQYTLt6LMEnzMc7
         J97+SVNzFt0l8RuM5IlHH+FkwWYdytUUEwH8IXXB8cwiUnYPLKljhCgKxDadtCujHp6k
         353g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a193si10290042qkc.324.2019.07.26.05.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 05:01:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0724830C0A3B;
	Fri, 26 Jul 2019 12:01:08 +0000 (UTC)
Received: from [10.72.12.238] (ovpn-12-238.pek2.redhat.com [10.72.12.238])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0BBB55DE6F;
	Fri, 26 Jul 2019 12:00:59 +0000 (UTC)
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
References: <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
Date: Fri, 26 Jul 2019 20:00:58 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190726074644-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 26 Jul 2019 12:01:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
> On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
>> On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
>>>> Exactly, and that's the reason actually I use synchronize_rcu() there.
>>>>
>>>> So the concern is still the possible synchronize_expedited()?
>>> I think synchronize_srcu_expedited.
>>>
>>> synchronize_expedited sends lots of IPI and is bad for realtime VMs.
>>>
>>>> Can I do this
>>>> on through another series on top of the incoming V2?
>>>>
>>>> Thanks
>>>>
>>> The question is this: is this still a gain if we switch to the
>>> more expensive srcu? If yes then we can keep the feature on,
>>
>> I think we only care about the cost on srcu_read_lock() which looks pretty
>> tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
>>
>> Of course I can benchmark to see the difference.
>>
>>
>>> if not we'll put it off until next release and think
>>> of better solutions. rcu->srcu is just a find and replace,
>>> don't see why we need to defer that. can be a separate patch
>>> for sure, but we need to know how well it works.
>>
>> I think I get here, let me try to do that in V2 and let's see the numbers.
>>
>> Thanks


It looks to me for tree rcu, its srcu_read_lock() have a mb() which is 
too expensive for us.

If we just worry about the IPI, can we do something like in 
vhost_invalidate_vq_start()?

         if (map) {
                 /* In order to avoid possible IPIs with
                  * synchronize_rcu_expedited() we use call_rcu() +
                  * completion.
*/
init_completion(&c.completion);
                 call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
wait_for_completion(&c.completion);
                 vhost_set_map_dirty(vq, map, index);
vhost_map_unprefetch(map);
         }

?


> There's one other thing that bothers me, and that is that
> for large rings which are not physically contiguous
> we don't implement the optimization.
>
> For sure, that can wait, but I think eventually we should
> vmap large rings.


Yes, worth to try. But using direct map has its own advantage: it can 
use hugepage that vmap can't

Thanks

