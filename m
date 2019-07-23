Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21C1BC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:08:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77F13218F0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="HNHBMNej"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77F13218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2665D8E0002; Tue, 23 Jul 2019 11:08:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F0B26B0010; Tue, 23 Jul 2019 11:08:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 091398E0002; Tue, 23 Jul 2019 11:08:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 913B36B000C
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:08:15 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id m2so9379229ljj.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:08:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FfrxMQ3/T40zfvxNCGGC0/I3Mfe2Uti/Lqf5PFT3euA=;
        b=fB9HOfFi9SZu5BJa8j+UmgeRDpbjef/6i6VXWLzH0/u5DnkI4kaPc5g+eSrnWiIm36
         /F1mwfs441me/qRxI+ZI4I/W7BWo4skJMmTFQv1mVrwRcajtYLY/l0QDoQyKndOQZ6la
         HRUD2lzHNCD6tGL+Hg7aurKiI2BlnttVGmm0rn0MlWnZ8b8SSP5YxyRS6zkxqWZjJulm
         uOEQ6GyrZtGh9fe156BzPu+sfWNBW49C/cJ4WeRRYIL9HYJ1Ud1MOwEHbhpLibT3KGc0
         7ycMNlJfAwmO0y+jznbO9+Cr6xsQt2XDkQkWi1vHc7R7D4igGUP96jCdf5YyWn7ilRxY
         iuXw==
X-Gm-Message-State: APjAAAXDAzD7kPixjgNu9wB+dNWKeZ4WcKtx1DB8ou0QDVOrl1MgdJLy
	BDobaZ+bOLSgvzfqYvaoNAQ5uuwK06iIYfkXUsZxITCaGyQIGGZXlHkso5ohp6gue3XjL0V8G1d
	HaVHo1IrgkcNu4j42MsB8wm1QYCSA6y2O5zzSQB2v9T9KxPUSDN/PwkTs1ozFFYED9Q==
X-Received: by 2002:a2e:9a13:: with SMTP id o19mr40943294lji.102.1563894494766;
        Tue, 23 Jul 2019 08:08:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwy2vLTGw51tG2Hti11zvG7XiSzOwc+xoTGyCog4flqNNpsEQ4OrXNNhXT/Jd2Nhkby2kt
X-Received: by 2002:a2e:9a13:: with SMTP id o19mr40943243lji.102.1563894493824;
        Tue, 23 Jul 2019 08:08:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563894493; cv=none;
        d=google.com; s=arc-20160816;
        b=FhBALA0Z/plbE6eSMriZq7S5IjfQp0sJVs1U0AnF911xyPTIOhByJvEfZOnlbiXJZR
         5Eor23oXg/NIdUIvLYHmrp9WLelzi/MaYA41+hC1RXguqCOln7CG/le5pE8OGyqsfxMr
         BQJNzNWZNnLRw5rgnHNkiut5bEZxQy3HjyokWpPGcRDN+9a0978PNhOynGO73q39SqYA
         W2cVGNANXTC+/RlM0dSP1HBvZJf+1f4ej1S0dQfVk5/Z+Eo5zAi6I36BhImG4rA+62IU
         MbfJJLa3H4BdfLqwwjIkKMYDFvEjcPd5Wa8dV5rK7hKnnLFfrSDgpDKm6lGTVeUQyBeF
         CbCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=FfrxMQ3/T40zfvxNCGGC0/I3Mfe2Uti/Lqf5PFT3euA=;
        b=OtfdmuAXcfweuEhApmuoZRWW12Xd0LDqk0plw2VFUP/Gggxi3BGiMouKUnhh0Z5vNX
         GKmrou8ktfFMmqU4ovf5ysYIsByDHOp6Uzxv9yIofncFpFgdv1Kzxxop2QRkIu+QKE+J
         aM31XR/iNU4jMv2C3prfDXv0poTTN9mFuPlnqqPOmHZ39tJmq2blL8Twwt0V5rbK7F0q
         n6elQD9FjaL2oB47BilHXyblrG/7eroAh1FPRVGa4wOx0fnkeBck5MLGiitNvHbCVQYd
         2wodVWJKGSqkAfMUXxOngpKQHYi+fTjvPSV71fHftIJ3CsRCvJS/6fgZ659f8TvEopWr
         bt5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=HNHBMNej;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id c18si32705809lfm.93.2019.07.23.08.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 08:08:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=HNHBMNej;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 7A6852E14C4;
	Tue, 23 Jul 2019 18:08:12 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id BcxYFxZnla-8C5OPgk9;
	Tue, 23 Jul 2019 18:08:12 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563894492; bh=FfrxMQ3/T40zfvxNCGGC0/I3Mfe2Uti/Lqf5PFT3euA=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=HNHBMNejDDlRT6ijLfCzFFUZUdrRW37pxt3V2UsNhzRWpGEUvNSKvDuUsqFkxyJaD
	 1dFNt/Rb8TfB7NU47v4Z2JD/H5+jB4W0iSAMt5lzmPHleP288f2mALmnfxFsqpBTap
	 w4I+vqMMq2yVVAJwf/2cw5QYy/cGqDssNSnrrK54=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id dHFoLqHukc-8BIauBFl;
	Tue, 23 Jul 2019 18:08:12 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/page_idle: simple idle page tracking for virtual
 memory
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>
References: <156388286599.2859.5353604441686895041.stgit@buzz>
 <20190723134647.GA104199@google.com>
 <53719394-2679-81ae-686e-c138522c0dfc@yandex-team.ru>
 <20190723142547.GD104199@google.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <056496c5-d87f-9ac0-a325-c0b0fb6a1f05@yandex-team.ru>
Date: Tue, 23 Jul 2019 18:08:11 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190723142547.GD104199@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.07.2019 17:25, Joel Fernandes wrote:
> On Tue, Jul 23, 2019 at 04:59:07PM +0300, Konstantin Khlebnikov wrote:
>>
>>
>> On 23.07.2019 16:46, Joel Fernandes wrote:
>>> On Tue, Jul 23, 2019 at 02:54:26PM +0300, Konstantin Khlebnikov wrote:
>>>> The page_idle tracking feature currently requires looking up the pagemap
>>>> for a process followed by interacting with /sys/kernel/mm/page_idle.
>>>> This is quite cumbersome and can be error-prone too. If between
>>>> accessing the per-PID pagemap and the global page_idle bitmap, if
>>>> something changes with the page then the information is not accurate.
>>>> More over looking up PFN from pagemap in Android devices is not
>>>> supported by unprivileged process and requires SYS_ADMIN and gives 0 for
>>>> the PFN.
>>>>
>>>> This patch adds simplified interface which works only with mapped pages:
>>>> Run: "echo 6 > /proc/pid/clear_refs" to mark all mapped pages as idle.
>>>> Pages that still idle are marked with bit 57 in /proc/pid/pagemap.
>>>> Total size of idle pages is shown in /proc/pid/smaps (_rollup).
>>>>
>>>> Piece of comment is stolen from Joel Fernandes <joel@joelfernandes.org>
>>>
>>> This will not work well for the problem at hand, the heap profiler
>>> (heapprofd) only wants to clear the idle flag for the heap memory area which
>>> is what it is profiling. There is no reason to do it for all mapped pages.
>>> Using the /proc/pid/page_idle in my patch, it can be done selectively for
>>> particular memory areas.
>>>
>>> I had previously thought of having an interface that accepts an address
>>> range to set the idle flag, however that is also more complexity.
>>
>> Profiler could look into particular area in /proc/pid/smaps
>> or count idle pages via /proc/pid/pagemap.
>>
>> Selective /proc/pid/clear_refs is not so hard to add.
>> Somthing like echo "6 561214d03000-561214d29000" > /proc/pid/clear_refs
>> might be useful for all other operations.
> 
> This seems really odd of an interface. Also I don't see how you can avoid
> looking up reverse maps to determine if a page is really idle.

This pretty straight forward format if you look into /proc/pid/maps and others.
Parsing is trivial - just one sscanf().

If we are looking for abandoned pages in particular proces it is enough to
mark page idle and look at access bit in this process.

If page is shared and got foreign access -- it is not abandoned.
And some information could be retrieved right from pagemap: file/anon and
exclusive-map bits.

> 
> What is also more odd is that traditionally clear_refs does interfere with
> reclaim due to clearing of accessed bit. Now you have one of the interfaces
> with clear_refs that does not interfere with reclaim. That is makes it very
> inconsistent. Also in this patch you have 2 interfaces to solve this, where
> as my patch added a single clean interface that is easy to use and does not
> need parsing of address ranges.

Your patch adds yet another per-task proc file which requires special tool.

My just extends existing interface and useful without any tools: just echo and cat.
And yet, special tool could get precise per-page information in binary form
along with other useful bits from /proc/pid/pagemap.

> 
> All in all, I don't see much the point of this honestly. But thanks for
> poking at it.
> 
> thanks,
> 
>   - Joel
> 

