Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBF2DC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F224217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 15:08:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="fONq6q23"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F224217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBB7E8E0001; Thu, 18 Jul 2019 11:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D462D6B0008; Thu, 18 Jul 2019 11:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0CCB8E0001; Thu, 18 Jul 2019 11:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB076B0006
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 11:08:08 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id r5so6241344ljn.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:08:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=r+b1A4l2F9g/q3ITgDkPw72qBmDym1kZ98ZmcHn0K5o=;
        b=mQpSsfaSX8hbiwTL7EhBnr1MMPNWu5QgrTa3Xlup9lxqbNReCOMXlLvbLvLCT7XfOS
         3mfbzjTt6TyMicW1Cq73miavXQxotetRM/dQK5o+Vlp6HX4YIVmPLR+lto3n+KKPao8t
         sckEhB09Pewj+TWjxNiK5kX0mQBT9LNo2wB9GD5sUrC68QSuRABzf/Z/gz2FSwSYwUi2
         yhIm5wP68FFr5/feeIQ1GPGaXbhAzKdy2KHWBPeZrXzKYyeAG6Q9tXb/JkGaQIoDyWAj
         V+z7tTm+zWqv6brDyR4dJ59ehMIhtuajj5Z09aKYt8sCFcFKFMIWxkBJ4PG4pyAvuSkA
         UXWw==
X-Gm-Message-State: APjAAAUIKzU7yXbuPkOeYmYhlPlbfbeFC3nDuzoue5e2LtPLxMp78un0
	f25iUIL5npfdcbcePclN0p+MGUHBaHeNNNHIDDLyTGowE7coqrK7aeeVxF94tKu+FIE66fz73D5
	pXhvAD/ROnOWw2P1L38a2bffHk0GeplfKOC7fCu9RfBV4LyoXFXuQF2h6jnG3HKXZpA==
X-Received: by 2002:a2e:98c9:: with SMTP id s9mr5463410ljj.176.1563462487851;
        Thu, 18 Jul 2019 08:08:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhzxe+uY4VpnnmETyF0anYycdjt+ynXivaaoiz9jaZkbZALeTyKqJE7oXpHPuxPeiMpZT9
X-Received: by 2002:a2e:98c9:: with SMTP id s9mr5463354ljj.176.1563462486718;
        Thu, 18 Jul 2019 08:08:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563462486; cv=none;
        d=google.com; s=arc-20160816;
        b=EpuJq9KgeJwi18vpYHxjFxI2zsPfYvZeXmNIDLHeDahD01NhDHyTugLlCrJbc1k07l
         oegqQ7IxdT2oT2uX0RiUCelTIdmUxNNXDjuus9R9LFvUJo1He1OKiqDgr+Ns+IGbkfii
         Mr5eDkEkwAQM6CdTbryxyEkcMKKgisIOYUrttE6WLy39fQjBwe32av/Ak3NK0QkKD0Au
         tugDWM8O2wPnE0QSbk5js5r6Ct09DTuIDAUJ70Yk/ec0BbIXhY4qKLYBv161Ozl4LQNs
         mDF1XxVzD8NpbVfMJWiytAAvwU7+NLY8d2M4wtvhjSJ9FzS7DT6JUulnrYWASzdFxUXg
         JRqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=r+b1A4l2F9g/q3ITgDkPw72qBmDym1kZ98ZmcHn0K5o=;
        b=qyDqs+8Qof4ZMrDtn5kzvtLA2fStknayi/VAOaz2P8/IENabAKdf+rYb0M5W5pcAsU
         ovtpisQVMl/QawA3zEpHwGSNYkFl/hFMX6v0PBvILc+pWcO51DxXG/Z2z64q+yWXtLcn
         A9a9tfkPujPhBC+cATWNm3LnknsmTxLrWcVfhj04WTxZGtlWRLcGJjmEJP+OsvPV3aeZ
         hZSHB4lB/JgllQeZvaCzsUkLLzN3RXAF/oxe+Q0j9mD9QE9LBWmiP5Ra3DilWau8GTOX
         YgDBTQcZD9w8QbBrlFUfTrydtkknHrDwY+RF27KnQ2y8XmFhAagRT1zo5i7Pmxhokfrs
         amyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fONq6q23;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id h1si26042098ljj.107.2019.07.18.08.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 08:08:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=fONq6q23;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 4DA4B2E14E5;
	Thu, 18 Jul 2019 18:08:05 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id eXvUEDwHGP-84N4WWpg;
	Thu, 18 Jul 2019 18:08:05 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563462485; bh=r+b1A4l2F9g/q3ITgDkPw72qBmDym1kZ98ZmcHn0K5o=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=fONq6q23F+TbpfJUloG+4AFtEiPFAzYalIZRoJbbZtzbwYfw3hOzrUGevBCgpBLt3
	 1xSMeWyElu/EiB0c1Y+1qjl6d0f01J5sGN8KzRd1VKZmnVt2ItWA0zRZR1M8fp7vAM
	 uWPWO5qTXUNSaNYmvs/LfFEkPVA88TEFptog/Nzc=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38d2:81d0:9f31:221f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id QzWFJEUVAn-84ISGi64;
	Thu, 18 Jul 2019 18:08:04 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH 2/2] mm/memcontrol: split local and nested atomic
 vmstats/vmevents counters
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>
References: <156336655741.2828.4721531901883313745.stgit@buzz>
 <156336655979.2828.15196553724473875230.stgit@buzz>
 <20190717175319.GB25882@cmpxchg.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <e768596e-f012-b8f0-ee3c-773abb7a3692@yandex-team.ru>
Date: Thu, 18 Jul 2019 18:08:04 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717175319.GB25882@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.07.2019 20:53, Johannes Weiner wrote:
> On Wed, Jul 17, 2019 at 03:29:19PM +0300, Konstantin Khlebnikov wrote:
>> This is alternative solution for problem addressed in commit 815744d75152
>> ("mm: memcontrol: don't batch updates of local VM stats and events").
>>
>> Instead of adding second set of percpu counters which wastes memory and
>> slows down showing statistics in cgroup-v1 this patch use two arrays of
>> atomic counters: local and nested statistics.
>>
>> Then update has the same amount of atomic operations: local update and
>> one nested for each parent cgroup. Readers of hierarchical statistics
>> have to sum two atomics which isn't a big deal.
>>
>> All updates are still batched using one set of percpu counters.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Yeah that looks better. Note that it was never about the atomics,
> though, but rather the number of cachelines dirtied. Your patch should
> solve this problem as well, but it might be a good idea to run
> will-it-scale on it to make sure the struct layout is still fine.
> 

Looks like this patch shows 2% regression for 24 core 2 numa node
machine I have. Compete remove of these counters gives 2% boost.
Also I cannot reproduce regression fixed by commit 815744d75152 - revert
have no effect.

So, feel free to ignore second patch. I'll play with this a little more.

Maybe atomic per-numa counters could give nice balance between scalability add overhead.
Ideally this memory could be mapped in per-cpu manner to give atomic access via fs/gs.

