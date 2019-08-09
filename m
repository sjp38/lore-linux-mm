Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB70BC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:09:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B48F720880
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:09:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B48F720880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4806C6B000A; Fri,  9 Aug 2019 06:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 409056B000C; Fri,  9 Aug 2019 06:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AB7D6B000D; Fri,  9 Aug 2019 06:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC8BB6B000A
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 06:09:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so59989963edx.12
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 03:09:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=zNdMlv6xZddHtB5qhGklwUJ7+PL6Br3G4ziSZtHhAdc=;
        b=A3pjy9J1iSWIgjn7dQoZAHnFTIsgXlmp5x0XoTeNnHn6E+VYyVWjx9hLEKJOcOCeGU
         BcVrigY+MAJPoyKW8wDLggy8YToGiY7LaRboHyc1QvKwnuzNKicWGbucnUGQqy9YeXsA
         YIm6po7YioSyuVV7qTQMDa9EZnAQhf0wFhLy1XMXwZXWKWCy3uFOTRLKNmq4pwqNecKD
         SLOXsVQncXZmt+lAQ8dWH08YQblJrxXbgHuKc6wgPppUKENU0quW/eJVZC/nTDc5GUYg
         yFNxEcsTgDx4tFV9McR5mFpDI9azd9HgfhI9IMkFuMmepCIarUUoIPkDDBWOwtk9OPhi
         LiZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAV6ehQGotgN9CYPdrxLwhb109Y0GzRuOUdHNESAYuHPP3Rzm+B3
	f2d+NLLS0lIZNl8ETmVuIv+YOFs8NSJHGhunHBIMHhr3uF5d2vsOXnRf89HasaMxpCNgG/J+5XI
	iBzpmRVlylJCLtV5nIYbjbephY2qCfZYdj4UXq6TYqvk/euHsSw6daParMaQrvraa1Q==
X-Received: by 2002:a17:906:5c4a:: with SMTP id c10mr17315363ejr.15.1565345375357;
        Fri, 09 Aug 2019 03:09:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBN0CzOXaemmoV5kjW0uEQxd9/8o4LZ4zZlp9OfOVM+APZAshBq1QqevG3EerpS8nFKNaN
X-Received: by 2002:a17:906:5c4a:: with SMTP id c10mr17315303ejr.15.1565345374371;
        Fri, 09 Aug 2019 03:09:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565345374; cv=none;
        d=google.com; s=arc-20160816;
        b=cITPz3j4PlceMQ2/KQZg9AC7DuWrVz6qtZ/napBgGybsW90tYWB5//YdMKJbb7hukv
         VB5+x6TY2ex7KshR5zqBSVBZknycuXJqEqE6eJz1C86DwfEFA5RamG7bYhN78TUrOVsz
         UGbVYpO1u9cRSxds8L0LMfk1QsOKor8lj2UqdXpB3v5EicdHGxrytdNAIfMyORWxyhcU
         wK4YJ5O6qH+iC5Z/eiA6dFTa9I86AiHOYP2HoKo+5R2bJcBjbZdx1i8CAkqcGWXR3krt
         OlMS8z2uTXIaXcKulEMXLLKf9qvt0npVgH/3JmGryCJw2dir9HpY1H/iMPiC7y0s34fi
         sQZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zNdMlv6xZddHtB5qhGklwUJ7+PL6Br3G4ziSZtHhAdc=;
        b=eh7SpO5DWK14N7l66yzBxjH8WvyRkbjDk1PqrCEJ03hlL3sQDndx/t+LBiNNgf7Wdd
         D0EKV7hTE1u3bt9MnwsPs59AmV7y633EOX3GsrZTy1bfedr/p4X2t9PkolFt2132Y0Ze
         KFrjWCw9f+r5pQ4rszChXMMX9zTUpPWzq5icllFoR0K6eLnuIey1qYZO7vBf+p1SeR32
         ESovfR51fU6jDzv43HzOFD3CjAf5UX/QudX2ky1yJKij7Nm+knYxQLC+YA7gtdpNgkfF
         KgarXQZk4HQVKarYXSGSrbPpY+0Fhdu9bj79/cmKN6p+6yaT9DM3XDgKZi8Gn0p5Vrro
         8JCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id c15si33591898ejr.343.2019.08.09.03.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 03:09:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [192.168.1.66] (unknown [212.159.68.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id 997771C021CC;
	Fri,  9 Aug 2019 11:09:33 +0100 (BST)
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 Suren Baghdasaryan <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>,
 "Artem S. Tashkinov" <aros@gmx.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
References: <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
 <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
 <20190809085748.GN18351@dhcp22.suse.cz>
From: ndrw <ndrw.xf@redhazel.co.uk>
Message-ID: <cdb392ee-e192-c136-41cb-48d9e4e4bf47@redhazel.co.uk>
Date: Fri, 9 Aug 2019 11:09:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809085748.GN18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/2019 09:57, Michal Hocko wrote:
> We already do have a reserve (min_free_kbytes). That gives kswapd some
> room to perform reclaim in the background without obvious latencies to
> allocating tasks (well CPU still be used so there is still some effect).

I tried this option in the past. Unfortunately, I didn't prevent 
freezes. My understanding is this option reserves some amount of memory 
to not be swapped out but does not prevent the kernel from evicting all 
pages from cache when more memory is needed.

> Kswapd tries to keep a balance and free memory low but still with some
> room to satisfy an immediate memory demand. Once kswapd doesn't catch up
> with the memory demand we dive into the direct reclaim and that is where
> people usually see latencies coming from.

Reclaiming memory is fine, of course, but not all the way to 0 caches. 
No caches means all executable pages, ro pages (e.g. fonts) are evicted 
from memory and have to be constantly reloaded on every user action. All 
this while competing with tasks that are using up all memory. This 
happens with of without swap, although swap does spread this issue in 
time a bit.

> The main problem here is that it is hard to tell from a single
> allocation latency that we have a bigger problem. As already said, the
> usual trashing scenario doesn't show problem during the reclaim because
> pages can be freed up very efficiently. The problem is that they are
> refaulted very quickly so we are effectively rotating working set like
> crazy. Compare that to a normal used-once streaming IO workload which is
> generating a lot of page cache that can be recycled in a similar pace
> but a working set doesn't get freed. Free memory figures will look very
> similar in both cases.

Thank you for the explanation. It is indeed a difficult problem - some 
cached pages (streaming IO) will likely not be needed again and should 
be discarded asap, other (like mmapped executable/ro pages of UI 
utilities) will cause thrashing when evicted under high memory pressure. 
Another aspect is that PSI is probably not the best measure of detecting 
imminent thrashing. However, if it can at least detect a freeze that has 
already occurred and force the OOM killer that is still a lot better 
than a dead system, which is the current user experience.

> Good that earlyoom works for you.

I am giving it as an example of a heuristic that seems to work very well 
for me. Something to look into. And yes, I wouldn't mind having such 
mechanism built into the kernel.

>   All I am saying is that this is not
> generally applicable heuristic because we do care about a larger variety
> of workloads. I should probably emphasise that the OOM killer is there
> as a _last resort_ hand break when something goes terribly wrong. It
> operates at times when any user intervention would be really hard
> because there is a lack of resources to be actionable.

It is indeed a last resort solution - without it the system is unusable. 
Still, accuracy matters because killing a wrong task does not fix the 
problem (a task hogging memory is still running) and may break the 
system anyway if something important is killed instead.

[...]

> This is a useful feedback! What was your workload? Which kernel version?

I tested it by running a python script that processes a large amount of 
data in memory (needs around 15GB of RAM). I normally run 2 instances of 
that script in parallel but for testing I started 4 of them. I sometimes 
experience the same issue when using multiple regular memory intensive 
desktop applications in a manner described in the first post but that's 
harder to reproduce because of the user input needed.

[    0.000000] Linux version 5.0.0-21-generic (buildd@lgw01-amd64-036) 
(gcc version 8.3.0 (Ubuntu 8.3.0-6ubuntu1)) #22-Ubuntu SMP Tue Jul 2 
13:27:33 UTC 2019 (Ubuntu 5.0.0-21.22-generic 5.0.15)
AMD CPU with 4 cores, 8 threads. AMDGPU graphics stack.

Best regards,

ndrw


