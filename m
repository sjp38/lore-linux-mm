Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D86BC7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:24:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 868ED214AE
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 11:24:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="nByOcS25"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 868ED214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2248E0003; Mon, 29 Jul 2019 07:24:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C63058E0002; Mon, 29 Jul 2019 07:24:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B52F58E0003; Mon, 29 Jul 2019 07:24:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9658E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:24:38 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c18so13299937lji.19
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:24:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0rOY1hf/vJwvLzCfaIpmU6fmgpWmli7XV2Wh26/reCw=;
        b=eZ7jEfhrpG4NG/HEABr/mJ86LAb+HuAaOF0A2NEXJzjfpbvtlvdyWp6PkjrLj7ZnbO
         53RSPD7gF0L0ABIcVf2d3mYv8E3dQzUHLv7nrzZgynb+Ry8nJcvPh7aT/6MQCCtaDn0/
         84J5wnNz7X6TyUxnqJx07EWJUDmg2AOO0wg+1pbQwAy3XstF8YnS2gs/YD3XibQcVm2C
         6ChxMTPQ9HfK4t7aOWPXD7SdkwrppTTjbBMdme0TUFDY9ZRcHOeV6eH8vYOTOoVVrJ3c
         lccPI1+yK/SF83hVpkNIODoDn/87ENHWJHRiaz7lgFb/+X3JD1GOogXmgmXgy73amxsa
         Jp5g==
X-Gm-Message-State: APjAAAW5Pcoxka0xyL2X9EomBZxTMfHdunQ0GROq0oWGaGeXY9puAhww
	yITMURffig8Kq8r3CLtpNOKsPf/AfsCOq9c1CiYDE65712UT8vndjQXqbxT23ugGOKnAy9pccOq
	owpOPXzNGm5GNCfMtqiWXhz+0Cdxg2S9y8L9BhN3I6j3w7Tx1r45BINV3Qs+GBveSdw==
X-Received: by 2002:a2e:9758:: with SMTP id f24mr57971275ljj.58.1564399477502;
        Mon, 29 Jul 2019 04:24:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCZKs6esVYtJaFoNpH5ox1u0cQiK09MFu2oQkCAKbg/DCI//TBmlM9PvAmSTCnKLGVqPll
X-Received: by 2002:a2e:9758:: with SMTP id f24mr57971225ljj.58.1564399476649;
        Mon, 29 Jul 2019 04:24:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564399476; cv=none;
        d=google.com; s=arc-20160816;
        b=Dyl8ivT0lBe8fulhJC7SUrpDHAjf3rYyT2n+x1JaMUtmfY0NyyPGFLjfsxkba1Nqwf
         2h1xFgh4HgE+li5og3rx9y5yuiaeBNvrgKdduVvlNCyp38HJ8ldSW1gko7DhaJQ480LC
         hGLQdteFIGcro6W/X7ObmptM3Ggp+FBbrWP9IknVNSZPWVGn34MG6BsoshGQ/A/EfMBC
         NTOPIgu4NYjg5LnmPPB0fLYjgXLUEFQ5UpBsza4Vkg2KV3zJ/w92xHsQWuXqtT7FuvhF
         yzOdDiFb7dlhiqD+O7ddm+mHS89YmichWHsj4xF4M45bvllmWUzw71ArUU1teng9oP1w
         ovyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0rOY1hf/vJwvLzCfaIpmU6fmgpWmli7XV2Wh26/reCw=;
        b=YKuQlo4/Gu8SbQv2M0pzKhZfi0aVBJHF4ODJO92DsAqf+tWoKe5LfbTrqd6C8zEsz+
         lEvgqb/d9gPw6qJlN4fSWcRXafDP9H3f+vpYLxooqznDO/N51Bcv7N9Pn5HQY35e+EY9
         Sl4sDlcLry0tQU/JfCtw6MG9DsSGzt887IdW00V9v27LeorTLm9p00d175PVhdYBJLIr
         KbjxK7q1BTeTIt+VzDkO16NgCXR1x6U3kL1KU7/QI44WIIKLQqwTAnL6+0kNf4nRRih5
         vpF9nkbCgZFyJ19cgt/nRkFxb+ETzpRKznTIkHFK4lB7PzFhboueJ0iSQl8/jzDo/yx5
         UpnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nByOcS25;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTPS id m10si45549792lfd.120.2019.07.29.04.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 04:24:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=nByOcS25;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 058D02E12DD;
	Mon, 29 Jul 2019 14:24:36 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id TcQGodNMlR-OZNmerOf;
	Mon, 29 Jul 2019 14:24:35 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564399475; bh=0rOY1hf/vJwvLzCfaIpmU6fmgpWmli7XV2Wh26/reCw=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=nByOcS2558rwwbSDAEFX2ECRH9cbBKFJaqHwq5HMsvxsD7/jzng5DQod4BtWEnb02
	 nZJtRjZ8Zv2vy73Awdgp0hBWRsof8qOxZYo+VXuBmFOCl89Fox23CMoLSgOX4cRU6Z
	 yHZqAu8Cmmg5ZnLDYFt0xwqNaLD3D6ptE3l9l5p4=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:6454:ac35:2758:ad6a])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id QfhZn5Pecb-OZAml5J4;
	Mon, 29 Jul 2019 14:24:35 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz>
 <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <5002e67b-b87f-d753-0f9c-6e732b8e7a80@yandex-team.ru>
Date: Mon, 29 Jul 2019 14:24:35 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729103307.GG9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.07.2019 13:33, Michal Hocko wrote:
> On Mon 29-07-19 12:40:29, Konstantin Khlebnikov wrote:
>> On 29.07.2019 12:17, Michal Hocko wrote:
>>> On Sun 28-07-19 15:29:38, Konstantin Khlebnikov wrote:
>>>> High memory limit in memory cgroup allows to batch memory reclaiming and
>>>> defer it until returning into userland. This moves it out of any locks.
>>>>
>>>> Fixed gap between high and max limit works pretty well (we are using
>>>> 64 * NR_CPUS pages) except cases when one syscall allocates tons of
>>>> memory. This affects all other tasks in cgroup because they might hit
>>>> max memory limit in unhandy places and\or under hot locks.
>>>>
>>>> For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
>>>> of pages and push memory cgroup usage far ahead high memory limit.
>>>>
>>>> This patch uses halfway between high and max limits as threshold and
>>>> in this case starts memory reclaiming if mem_cgroup_handle_over_high()
>>>> called with argument only_severe = true, otherwise reclaim is deferred
>>>> till returning into userland. If high limits isn't set nothing changes.
>>>>
>>>> Now long running get_user_pages will periodically reclaim cgroup memory.
>>>> Other possible targets are generic file read/write iter loops.
>>>
>>> I do see how gup can lead to a large high limit excess, but could you be
>>> more specific why is that a problem? We should be reclaiming the similar
>>> number of pages cumulatively.
>>>
>>
>> Large gup might push usage close to limit and keep it here for a some time.
>> As a result concurrent allocations will enter direct reclaim right at
>> charging much more frequently.
> 
> Yes, this is indeed prossible. On the other hand even the reclaim from
> the charge path doesn't really prevent from that happening because the
> context might get preempted or blocked on locks. So I guess we need a
> more detailed information of an actual world visible problem here.
>   
>> Right now deferred recalaim after passing high limit works like distributed
>> memcg kswapd which reclaims memory in "background" and prevents completely
>> synchronous direct reclaim.
>>
>> Maybe somebody have any plans for real kswapd for memcg?
> 
> I am not aware of that. The primary problem back then was that we simply
> cannot have a kernel thread per each memcg because that doesn't scale.
> Using kthreads and a dynamic pool of threads tends to be quite tricky -
> e.g. a proper accounting, scaling again.

Yep, for containers proper accounting is important, especially cpu usage.

We're using manual kwapd-style reclaim in userspace by MADV_STOCKPILE
within container where memory allocation latency is critical.

This patch is about less extreme cases which would be nice to handle
automatically, without custom tuning.

>   
>> I've put mem_cgroup_handle_over_high in gup next to cond_resched() and
>> later that gave me idea that this is good place for running any
>> deferred works, like bottom half for tasks. Right now this happens
>> only at switching into userspace.
> 
> I am not against pushing high memory reclaim into the charge path in
> principle. I just want to hear how big of a problem this really is in
> practice. If this is mostly a theoretical problem that might hit then I
> would rather stick with the existing code though.
> 

Besides latency which might be not so important for everybody I see these:

First problem is a fairness within cgroup - task that generates allocation
flow isn't throttled after passing high limits as documentation states.
It will feel memory pressure only after hitting max limit while other
tasks with smaller allocations will go into direct reclaim right away.

Second is an accumulating too much deferred reclaim - after large gup task
might call direct reclaim with target amount much larger than gap between
high and max limits, or even larger than max limit itself.

