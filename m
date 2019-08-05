Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C17FEC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:13:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 834E420880
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 12:13:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 834E420880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B2DC6B0006; Mon,  5 Aug 2019 08:13:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 262B36B0007; Mon,  5 Aug 2019 08:13:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12C036B0008; Mon,  5 Aug 2019 08:13:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B62626B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 08:13:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n3so51384505edr.8
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 05:13:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=sHl3tOQZTYXcxjm8xMzEe069tHRGgY8F9rT4Ju1LnMQ=;
        b=oylZADE1CXbZ4zuaIJSParJWo5SBX/iIVXeu0vRvwWZKNx0rJyfQJKcvM+eqiPQfqp
         aph+Z4k0aTNKPaFw1mZRKc/VoOj70LzX0RuGbr2HNQZ95cIiOB+kxifc3L7gBBWLaxAd
         fldtmZuWP0dtFxV0g0Nislh16iUhAXYtjWUKSzN7WCefcNhjiqYFmYEKSqgR0w1eERT5
         Lyk58478ca6J6YnHjzXOXrB+f/WEg+YSRj6lztI0j6Gn0LFoOdO5pDDFelyOTIVrlbiQ
         vEgE3xoZjw2mLM+n26+WpEILXIG3cL/q/hYSJljgkwIb/jzJy3ez0OBdyZIGs7ascHQV
         +efw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXGakD3xgc0vbvkhbSRp6VSrJo8yvHXKViVH9r0swrjVxtH+oF4
	amEfrRUsfQsDtb3XwOPhFLooo2JQbSjs0bjg3j+jrnFzrdgMvY09soimRXtgTJk1Urs8wzSkNAA
	Qyg6b2kzHHG7V53u5xbvSQtjtftLhR2YixujE5emyXgpb33C37vfLHQPD6Fr4hJXaUQ==
X-Received: by 2002:a17:906:1d0b:: with SMTP id n11mr25453920ejh.27.1565007199297;
        Mon, 05 Aug 2019 05:13:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGS7E/UNheB1b0XwEVxxsYcxRTc9zzRQuwb4YYFxGt0emxHOc0300h9QAe0ahup6qXgX75
X-Received: by 2002:a17:906:1d0b:: with SMTP id n11mr25453852ejh.27.1565007198467;
        Mon, 05 Aug 2019 05:13:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565007198; cv=none;
        d=google.com; s=arc-20160816;
        b=aS7I1Igd8Mw1Gq2/Q7S7D8wZb/wyzUBu1+Y3VPDlEkybCsQdEwERVsXPpeGORzIp2k
         uyDy+tB5GdOQo2YCM6tJ4dzjKPL+oSsTnNzZJyNlSV5ifdFhZKx5zD3tjZvRYQreX/u6
         wBd2f8eHEFksxUUow5YK8QtZkfR3BS5j6Bbtizzv5X2ppEwngiXIx8F0djVijyBBUGa7
         BA8zrwnYaEshArwzDhESb3CiS1r9hQ4CI5t3C3myEM83S3QbzetsS7X28XEZXakKoMLz
         h3gZjCNkQ15ZQLY1nd1jbeMd68DItIiCndBMn18bdjB+mV+59TBHkyYiEZoe+HgLXTWz
         PSCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:cc:references:to
         :subject;
        bh=sHl3tOQZTYXcxjm8xMzEe069tHRGgY8F9rT4Ju1LnMQ=;
        b=JKbfPwSwcm/tNWA4GnMF60E4M9n/GqjJ4+/ADsVeWjS7Gy+sLY8UIT0nEuPR7ujBgt
         Nc00j0sE8DtCc7Hu8aasMMR9+FcItDR5agNOFU/RO8Nxib3tJiUjuUefyGadI+A7EAXz
         LNi0N0BTZcpggxFywzf13g4yvLzjdQazN33sC/UaM901P5SyAMRGyZLmPFS3xNIfm6E1
         FqNRRD3hGLAYTHuK5P+TkV/wH4Gb4dXDZBoYFcONtGxFHqV2PXo1ukPFYDGL5lstosk0
         rEGhOANsowZn8AgErOnYIB5h+GfB6ZrBNsmy8HTtZKwQDHrXa/JGvqIQ6679ORtmMNVo
         mTAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si28471301eds.64.2019.08.05.05.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 05:13:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8BD9EB644;
	Mon,  5 Aug 2019 12:13:17 +0000 (UTC)
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: "Artem S. Tashkinov" <aros@gmx.com>, linux-kernel@vger.kernel.org
References: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Suren Baghdasaryan <surenb@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <ce102f29-3adc-d0fd-41ee-e32c1bcd7e8d@suse.cz>
Date: Mon, 5 Aug 2019 14:13:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d9802b6a-949b-b327-c4a6-3dbca485ec20@gmx.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/4/19 11:23 AM, Artem S. Tashkinov wrote:
> Hello,
> 
> There's this bug which has been bugging many people for many years
> already and which is reproducible in less than a few minutes under the
> latest and greatest kernel, 5.2.6. All the kernel parameters are set to
> defaults.
> 
> Steps to reproduce:
> 
> 1) Boot with mem=4G
> 2) Disable swap to make everything faster (sudo swapoff -a)
> 3) Launch a web browser, e.g. Chrome/Chromium or/and Firefox
> 4) Start opening tabs in either of them and watch your free RAM decrease
> 
> Once you hit a situation when opening a new tab requires more RAM than
> is currently available, the system will stall hard. You will barely  be
> able to move the mouse pointer. Your disk LED will be flashing
> incessantly (I'm not entirely sure why). You will not be able to run new
> applications or close currently running ones.

> This little crisis may continue for minutes or even longer. I think
> that's not how the system should behave in this situation. I believe
> something must be done about that to avoid this stall.

Yeah that's a known problem, made worse SSD's in fact, as they are able
to keep refaulting the last remaining file pages fast enough, so there
is still apparent progress in reclaim and OOM doesn't kick in.

At this point, the likely solution will be probably based on pressure
stall monitoring (PSI). I don't know how far we are from a built-in
monitor with reasonable defaults for a desktop workload, so CCing
relevant folks.

> I'm almost sure some sysctl parameters could be changed to avoid this
> situation but something tells me this could be done for everyone and
> made default because some non tech-savvy users will just give up on
> Linux if they ever get in a situation like this and they won't be keen
> or even be able to Google for solutions.
> 
> 
> Best regards,
> Artem
> 

