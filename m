Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A77BC28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:54:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C23A32083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:54:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C23A32083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A1E26B027B; Thu,  6 Jun 2019 10:54:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 652946B027C; Thu,  6 Jun 2019 10:54:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 542676B027D; Thu,  6 Jun 2019 10:54:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E275F6B027B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:54:41 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so600479ljj.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:54:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dD702thkJa4xRC9FL35mAEmbp02pQamPCZ6/vuPpoAQ=;
        b=bR3mUEuenEoa4PrfkSaMS0NkIjFa3i4M1xaR4+GE0wVgMwqom+9LRvNFAuH9jkZvwM
         50bYIHViAjYRokVtFvLPvOPSB4pYouTO+1VP3h2lKianHMZqhJYvakjeECDykm7aYeX3
         WGz5XBeWD+xoDwrEDJgSIIrs3OOS/xCmpmyxDNl2AjTkLEZU/c4Jrhc2S5S64Awsowa3
         SxcyvmyH4BRef23h9Wk+a2VqOxgWk2immJOCcnLHIOGCHXEqXFABPJWm5rvFCeztRgjK
         deFZLZ1dqi3kZbv254YVR88u1BuchfsIy39hRL7oeuscLzXgo/cyQovryK83bm8+Soz2
         ENkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVR/rKKt3diMj0CJSO1WjU8szS6i4Dwo7N2qnxeO9lhrMvXdyM9
	oerFyl0YU9P1I4X6qd7ry5Dgo0j5vnmFjxmuZ/li4tUjNoa5L7VNpJLlCvzuHU5liYYnBQ+xGl2
	PNcAFzFOI1TSUsnNCN/459Jc0AKsXSkDHqXhYQnXgCF8J1YJMBuwxtmkWbZoIdgypxQ==
X-Received: by 2002:a2e:9a9a:: with SMTP id p26mr11373172lji.64.1559832881238;
        Thu, 06 Jun 2019 07:54:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTiA56XA5sdLlo49cLz/7wkVLi55Gbv+gc8OQJOPwEwt6EQ+/xsbesBpllhSN841UqQ4qQ
X-Received: by 2002:a2e:9a9a:: with SMTP id p26mr11373142lji.64.1559832880426;
        Thu, 06 Jun 2019 07:54:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832880; cv=none;
        d=google.com; s=arc-20160816;
        b=FJ7pCFMcLDuLCd3DFTBgQixTGHUlFoPgHNfhDUQX5g/k6eseDdRCjNWC76koyrbAco
         7skV9JhQeeCkyV6dkMevevUmu7QfTtx1CsOOUSEhekR9n6xU1FqvOr/w56U37M0c11/V
         jzfd2ufiq+kVUJil0waAP62y3pfSQVML0hfVVKkiZbZ8L6OrYC2XBrRJvceMnj3Ylk3H
         eWhutsgxUkzx6vJb9p55OL8//IYUDnqAA5mi7aw1JAFGE99WW1tlfHrzp/IItMPq+0co
         UJuHWkivJOMg/Kqr0VNdL47L4B/cySWLPZLAVkZ8L1x9rv2o3BnjzIF8kR74dru6DY2s
         Knfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=dD702thkJa4xRC9FL35mAEmbp02pQamPCZ6/vuPpoAQ=;
        b=oT39dtic+gz8LI6vyQjHP4kCtgAPcNj4n3DhniGdYmAmXxgQwTdYws0T4NsI4myeIO
         nVxTKYsCzpp0F3B5PDArPE8JPbuUmMF3MRVEaTmq+9tfRDz/DTBHbnpLW95sOTzR4rf/
         2kp01jXhHd2qJXVv0R8T0p7pdwqJZjRbppapCdkKE/YuFhG04pCloo6+EJ0XfsBXY6Nh
         5IRzBXfilZuqmM7TxtfhSJYmvO7pG2FDuYnbSMXxnZwpVWR9xuemY7Hwwa6QbLWxh7nj
         0/IIoOPaGh3t6eRlqRGFTvad46JmjaHOjHyHmlEf7gTwCkxLoGcg9EzlWmH+JBlifHut
         wkFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s7si2223877ljg.50.2019.06.06.07.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 07:54:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hYtmX-0000ch-5P; Thu, 06 Jun 2019 17:54:21 +0300
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
 syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, bfields@redhat.com,
 chris@chrisdown.name, Daniel Jordan <daniel.m.jordan@oracle.com>,
 guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>,
 Jeff Layton <jlayton@kernel.org>, laoar.shao@gmail.com,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 linux-nfs@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>,
 Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yang.shi@linux.alibaba.com
References: <0000000000005a4b99058a97f42e@google.com>
 <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
 <20190606131334.GA24822@fieldses.org>
 <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
 <CACT4Y+aJQ6J5WdviD+cOmDoHt2Dj=Q4uZ4vHbCfHe+_TCEY6-Q@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <00ec828a-0dcb-ca70-e938-ca26a6a8b675@virtuozzo.com>
Date: Thu, 6 Jun 2019 17:54:19 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aJQ6J5WdviD+cOmDoHt2Dj=Q4uZ4vHbCfHe+_TCEY6-Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.06.2019 17:40, Dmitry Vyukov wrote:
> On Thu, Jun 6, 2019 at 3:43 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>>
>> On 06.06.2019 16:13, J. Bruce Fields wrote:
>>> On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
>>>> This may be connected with that shrinker unregistering is forgotten on error path.
>>>
>>> I was wondering about that too.  Seems like it would be hard to hit
>>> reproduceably though: one of the later allocations would have to fail,
>>> then later you'd have to create another namespace and this time have a
>>> later module's init fail.
>>
>> Yes, it's had to bump into this in real life.
>>
>> AFAIU, syzbot triggers such the problem by using fault-injections
>> on allocation places should_failslab()->should_fail(). It's possible
>> to configure a specific slab, so the allocations will fail with
>> requested probability.
> 
> No fault injection was involved in triggering of this bug.
> Fault injection is clearly visible in console log as "INJECTING
> FAILURE at this stack track" splats and also for bugs with repros it
> would be noted in the syzkaller repro as "fault_call": N. So somehow
> this bug was triggered as is.
> 
> But overall syzkaller can do better then the old probabilistic
> injection. The probabilistic injection tend to both under-test what we
> want to test and also crash some system services. syzkaller uses the
> new "systematic fault injection" that allows to test specifically each
> failure site separately in each syscall separately.

Oho! Interesting.

> All kernel testing systems should use it. Also in couple with KASAN,
> KMEMLEAK, LOCKDEP. It's indispensable in finding kernel bugs.

