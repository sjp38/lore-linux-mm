Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FEB0C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F34A2173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:59:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F34A2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 061946B0007; Thu,  8 Aug 2019 17:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 011416B0008; Thu,  8 Aug 2019 17:59:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1BE66B000A; Thu,  8 Aug 2019 17:59:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93BDC6B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:59:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w25so58978062edu.11
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:59:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=l1IxYBfv33MNiS25HgXGEbDjrrNAu9O12K2pnMeMX4Y=;
        b=dBO5M96Q/gdm3sjC0rwwK1NM5R9NTEkYanLEGLg4Fb/EkqRi7pDHnrVYFwcsRjriZI
         idhGhb1BLPTFgsAc1nqMYFzt4crtq3NqQdo+P+mWnOFbHMbTu9cT7HW6b03LJHoTqaZb
         3MLcaBOpKPN6Ba+pf6GUhz8RynKXggyhna+tIXRJzx0JJZ5/N3C4haL0JEkP8F2LOVls
         iVZdq0QGEZ9nEbfQNkOC9zTm17IKxOpdZEUdjllL9lrp5IwxikhTJwHX25SPqekJALLJ
         3+8AyeQhZmzLfDd9G7hex/N7+v65DwyyeubhCuu45dKuk4DZZeYB1054/BUFNpzhHEfW
         xMPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAWcq+v1vcsotCOuxzZ4eXWgxU9g0x8xNgNH0l5vl36A9RSWloQM
	ywcwb/LyXwpNCNk3D0XpEz8SvqxgOM0l6Z7XgeXdFl7pzOMU5O2fbi0vQJ3reYiIQoEofTcKfKV
	ej1beaIKbI7IJq9Bh/DRSx5dxrEtPQaU/CJbeST3bxK15LPN/lWAflFyq6ZKmb/rmjA==
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr15587503ejh.218.1565301574147;
        Thu, 08 Aug 2019 14:59:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygRkixKtJ5WZSFiicgtNYSvyr4ajeLPGNSLHp24ag1MUWSQQEqdEYLMD0jNYR9NIAxcFDt
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr15587458ejh.218.1565301573228;
        Thu, 08 Aug 2019 14:59:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565301573; cv=none;
        d=google.com; s=arc-20160816;
        b=sur8xp7OD5JnG8Xv56ZFKXFhWCl5Ptuou0vOhcixORld6HQihPrmyKpD1qydzvguHG
         +oY2Oz0LdpywOmAPd+JxbzOHUdAjuYv2nV3/+G9QEHTR167CnC3Vl65bEXz4gXU82G4T
         o4jDiHo5Tmh4jg7CCvXWC8loSTH7fgBQVuEm9liOQL92Af1yzvUC6sZHud4zI7ZhcO9H
         xuIrYo8Ai3LcpQwONF2FHj4FXzkozH9Raf3g5BZiKuukuglpCyTX7EINQp1TOEG+jfBS
         9h2boqi3bdSatF6K4K8KwULOyz0adGDlgJA2S4HiuzOQHJuIP9kUZgrujTLfStXGdFor
         Yn8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=l1IxYBfv33MNiS25HgXGEbDjrrNAu9O12K2pnMeMX4Y=;
        b=P/PgE+WVmI/nw41fjJK7Ek2/KllPteis4m4fVLFA8NEGax8vtyw9BFUei3ruAuXVXj
         330Dqa4IfaOEwM/NF56hSOt5Z4JGo1u5VGwmbgByLEZ/MrS49Bd1hdKg7lhcBXFWN0xG
         FFnpllD6cBZHWdsNdGKOApAdRnavhFXqGomtUJ6qkT88J/77c/AEICePgcQcrIfCjIx0
         z/J3Jd3KIbIhQvwWwIezrh2kkKYrTK+HAquhdjRMSP6EZt8BSeI5jCCwqXPowsUktCxX
         IANT2H5iO+qMa3svkn4WY0KDM1iSBgpYQf/Z27QNWlIv5VpHb9BaKdkcm3MuAC7YyTwL
         EU9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id z43si273218edz.3.2019.08.08.14.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:59:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [192.168.1.66] (unknown [212.159.68.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id A2A331C0219A;
	Thu,  8 Aug 2019 22:59:32 +0100 (BST)
From: ndrw <ndrw.xf@redhazel.co.uk>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 Suren Baghdasaryan <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>,
 "Artem S. Tashkinov" <aros@gmx.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
References: <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
Message-ID: <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
Date: Thu, 8 Aug 2019 22:59:32 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808185925.GH18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/08/2019 19:59, Michal Hocko wrote:
> Well, I am afraid that implementing anything like that in the kernel
> will lead to many regressions and bug reports. People tend to have very
> different opinions on when it is suitable to kill a potentially
> important part of a workload just because memory gets low.

Are you proposing having a zero memory reserve or not having such option 
at all? I'm fine with the current default (zero reserve/margin).

I strongly prefer forcing OOM killer when the system is still running 
normally. Not just for preventing stalls: in my limited testing I found 
the OOM killer on a stalled system rather inaccurate, occasionally 
killing system services etc. I had much better experience with earlyoom.

> LRU aspect doesn't help much, really. If we are reclaiming the same set
> of pages becuase they are needed for the workload to operate then we are
> effectivelly treshing no matter what kind of replacement policy you are
> going to use.

In my case it would work fine (my system already works well with 
earlyoom, and without it it remains responsive until last couple hundred 
MB of RAM).


>>> PSI is giving you a matric that tells you how much time you
>>> spend on the memory reclaim. So you can start watching the system from
>>> lower utilization already.

I've tested it on a system with 45GB of RAM, SSD, swap disabled (my 
intention was to approximate a worst-case scenario) and it didn't really 
detect stall before it happened. I can see some activity after reaching 
~42GB, the system remains fully responsive until it suddenly freezes and 
requires sysrq-f. PSI appears to increase a bit when the system is about 
to run out of memory but the change is so small it would be difficult to 
set a reliable threshold. I expect the PSI numbers to increase 
significantly after the stall (I wasn't able to capture them) but, as 
mentioned above, I was hoping for a solution that would work before the 
stall.

$ while true; do sleep 1; cat /proc/pressure/memory ; done
[starting a test script and waiting for several minutes to fill up memory]
some avg10=0.00 avg60=0.00 avg300=0.00 total=0
full avg10=0.00 avg60=0.00 avg300=0.00 total=0
some avg10=0.00 avg60=0.00 avg300=0.00 total=10389
full avg10=0.00 avg60=0.00 avg300=0.00 total=6442
some avg10=0.00 avg60=0.00 avg300=0.00 total=18950
full avg10=0.00 avg60=0.00 avg300=0.00 total=11576
some avg10=0.00 avg60=0.00 avg300=0.00 total=25655
full avg10=0.00 avg60=0.00 avg300=0.00 total=16159
some avg10=0.00 avg60=0.00 avg300=0.00 total=31438
full avg10=0.00 avg60=0.00 avg300=0.00 total=19552
some avg10=0.00 avg60=0.00 avg300=0.00 total=44549
full avg10=0.00 avg60=0.00 avg300=0.00 total=27772
some avg10=0.00 avg60=0.00 avg300=0.00 total=52520
full avg10=0.00 avg60=0.00 avg300=0.00 total=32580
some avg10=0.00 avg60=0.00 avg300=0.00 total=60451
full avg10=0.00 avg60=0.00 avg300=0.00 total=37704
some avg10=0.00 avg60=0.00 avg300=0.00 total=68986
full avg10=0.00 avg60=0.00 avg300=0.00 total=42859
some avg10=0.00 avg60=0.00 avg300=0.00 total=76598
full avg10=0.00 avg60=0.00 avg300=0.00 total=48370
some avg10=0.00 avg60=0.00 avg300=0.00 total=83080
full avg10=0.00 avg60=0.00 avg300=0.00 total=52930
some avg10=0.00 avg60=0.00 avg300=0.00 total=89384
full avg10=0.00 avg60=0.00 avg300=0.00 total=56350
some avg10=0.00 avg60=0.00 avg300=0.00 total=95293
full avg10=0.00 avg60=0.00 avg300=0.00 total=60260
some avg10=0.00 avg60=0.00 avg300=0.00 total=101566
full avg10=0.00 avg60=0.00 avg300=0.00 total=64408
some avg10=0.00 avg60=0.00 avg300=0.00 total=108131
full avg10=0.00 avg60=0.00 avg300=0.00 total=68412
some avg10=0.00 avg60=0.00 avg300=0.00 total=121932
full avg10=0.00 avg60=0.00 avg300=0.00 total=77413
some avg10=0.00 avg60=0.00 avg300=0.00 total=140807
full avg10=0.00 avg60=0.00 avg300=0.00 total=91269
some avg10=0.00 avg60=0.00 avg300=0.00 total=170494
full avg10=0.00 avg60=0.00 avg300=0.00 total=110611
[stall, sysrq-f]

Best regards,

ndrw


