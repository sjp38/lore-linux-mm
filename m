Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F890C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7F3820679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="LUvQwL/Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7F3820679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49B7D8E0005; Mon, 29 Jul 2019 05:40:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44B4F8E0002; Mon, 29 Jul 2019 05:40:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33AFF8E0005; Mon, 29 Jul 2019 05:40:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6CE58E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:40:33 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id o2so13233221lji.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:40:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7/tBJ4/qqqj7+TYSG8WJ1dkQnz6GbGSbSQMPTnlbeZw=;
        b=RlkQrbcQbNGD3gNFP9iKadr8hlg514/fmbYnWn+nj/P9i6fyYt+ZTfZPsaHTfQxnGx
         fKjvj/1gLnVoOGn+QgjMxM32QWF3hH4iUarXJUx7mP05SAMOJyyHOhbHEhHe/69x4ik1
         I5dmlQ62t9LhwSr+NTXI3jesLL1E4bjwSIYYvIKKGHeBrf2f8b7xKaiTQLA9JUX1Mc1p
         gyyZ9q5KdOcQlhND/8bmgDUx9UQfQnBx/lAI2HhNH+m6ICo45xFyIDNzxS6hsDuOjjDR
         Y6v1ZlWhrdXpGqPJYVBX9EGkWWdBWPawil2Ej+C0yAU0TntZNJ+uP9idhxlkIoedBOOB
         DUUQ==
X-Gm-Message-State: APjAAAWWC/wiSDY8w3BS8AKLim4lDzfbtYXmlcaVbl34QUn2HqrITP7Z
	137GOKKF6wItrDoFB+4sYa5KYtkPiNNs43ev7RqBeTumdoSTyO80VCfn6iadrLX75Mr/Rv1r1c2
	ukP0T8D9Qa11tmIk4JW0EO0HLwIIVjHHLz0/7hW4QTHa930i/wbt5rBOcMhXDSrVO3A==
X-Received: by 2002:a19:c711:: with SMTP id x17mr51197989lff.147.1564393232970;
        Mon, 29 Jul 2019 02:40:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7sQpCPdhOWsE7f6rSUImPAep4A4eYnO3fFXbe4VBQxDCr1N6uxVqb3deaC+00K27Ak4IT
X-Received: by 2002:a19:c711:: with SMTP id x17mr51197954lff.147.1564393232201;
        Mon, 29 Jul 2019 02:40:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564393232; cv=none;
        d=google.com; s=arc-20160816;
        b=e7Mv4nnjwr7qI3cyUwySmxUlNK/ghZWyhUqOpsNC53CVaDmga7Hjvu62PME0NuTZV6
         4nwoytlH/TLPRgxrfHERYmdyds+hL4XvUBvrfnLdR+TnIOVk9ILmeMcLaVrywBRuHkff
         0HEIWUqJRYWT15cQV9wiadLUoDmAv9jlhrOQAWHxEVjj3zvwE9wWLJZrNoSYXEPljx1q
         Vse4GQqKdYFs03EKWP/twwYB8pnn3Yqo2CSndhaXpb+wDGNjxwU1AKUUOJ3EMMcDA1Mo
         nOxX5czgeJxWuTd5c5RazQwbdCzSKat2b+EaSg/cNR8XDBxNwvv7XAFhwG9YsWC6ZyWV
         qgKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=7/tBJ4/qqqj7+TYSG8WJ1dkQnz6GbGSbSQMPTnlbeZw=;
        b=EqbkaTt2OZKsfJ6Iy1RsLMd1IEeZTCvtUDGwF+sClms51czm8UvrhkTra9+Jp7olui
         XpaUxfiIPS/UeQS+6sET6sneGBrBGZXqzpeq/gyW7FRnlMcJdYKlPFvKm9e0kY12hHRn
         b4YQdhkLJ3Bl2aK/52ShI5SR94Zyimlj3q0DAjtW7Un6MwGoGQL2WrkocDApVixfBGUt
         femT7RuO91zFx/Pe8/DXMYiqD2H3PW+x4pO7VgMKSCMCyU8/zSSkf+EeHVOvH6ZIK8wL
         SfF7BO+8b9Dg0sdAvmPEYKMJSkeUiqbafvWMfMizIpWX5jAWNtqroMs3Xza5e7RHfJQ3
         Eaeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="LUvQwL/Q";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id i125si47800436lfd.13.2019.07.29.02.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 02:40:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="LUvQwL/Q";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 8E7312E095E;
	Mon, 29 Jul 2019 12:40:31 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id U8DF8V3uZd-eVNCsmIB;
	Mon, 29 Jul 2019 12:40:31 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564393231; bh=7/tBJ4/qqqj7+TYSG8WJ1dkQnz6GbGSbSQMPTnlbeZw=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=LUvQwL/QlD6Pg9qp202MGi9db0D1vc9D2+yRRANkR7RNSkFzvu6mMu9rnOq3s/Z7g
	 9LobH066Mj6J048YjrUosIn/5LmhCs5N3ausLHyF+VaQpKLpjS4ngZ1UJ3lPHqZRbl
	 MkWJ2c9sBwf1N7xBB6VRESXglZ55Hw81Vcb+43Zo=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:6454:ac35:2758:ad6a])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 9QqUdtKSm2-eUAaJpRd;
	Mon, 29 Jul 2019 12:40:31 +0300
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
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
Date: Mon, 29 Jul 2019 12:40:29 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190729091738.GF9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.07.2019 12:17, Michal Hocko wrote:
> On Sun 28-07-19 15:29:38, Konstantin Khlebnikov wrote:
>> High memory limit in memory cgroup allows to batch memory reclaiming and
>> defer it until returning into userland. This moves it out of any locks.
>>
>> Fixed gap between high and max limit works pretty well (we are using
>> 64 * NR_CPUS pages) except cases when one syscall allocates tons of
>> memory. This affects all other tasks in cgroup because they might hit
>> max memory limit in unhandy places and\or under hot locks.
>>
>> For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
>> of pages and push memory cgroup usage far ahead high memory limit.
>>
>> This patch uses halfway between high and max limits as threshold and
>> in this case starts memory reclaiming if mem_cgroup_handle_over_high()
>> called with argument only_severe = true, otherwise reclaim is deferred
>> till returning into userland. If high limits isn't set nothing changes.
>>
>> Now long running get_user_pages will periodically reclaim cgroup memory.
>> Other possible targets are generic file read/write iter loops.
> 
> I do see how gup can lead to a large high limit excess, but could you be
> more specific why is that a problem? We should be reclaiming the similar
> number of pages cumulatively.
> 

Large gup might push usage close to limit and keep it here for a some time.
As a result concurrent allocations will enter direct reclaim right at
charging much more frequently.


Right now deferred recalaim after passing high limit works like distributed
memcg kswapd which reclaims memory in "background" and prevents completely
synchronous direct reclaim.

Maybe somebody have any plans for real kswapd for memcg?


I've put mem_cgroup_handle_over_high in gup next to cond_resched() and
later that gave me idea that this is good place for running any
deferred works, like bottom half for tasks. Right now this happens
only at switching into userspace.

