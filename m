Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD137C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:27:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0DB0218A3
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:27:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0DB0218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 338576B0003; Tue,  2 Jul 2019 17:27:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C28D8E0003; Tue,  2 Jul 2019 17:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13C538E0001; Tue,  2 Jul 2019 17:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEB976B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 17:27:10 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d3so183078pgc.9
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 14:27:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=3A2JKYyF6Wow+uyBjAseYYHmwKeOnuwwqwzbEFG4G9s=;
        b=KpIkfmUlpkoIxmuULtGtwcsjUC8VWKXyMkfZCosqEZqFtXcJDAylDE55dwDE6HffL7
         05AgEhwCVNaMS0qD6ERygDNOfCvsJOTOsSTY7en7fk8CrjkCi84VAW4Aijg/a1zmE9A3
         hM/fss6GhU0rbLaceJ3F6YxtD1UQS5/MGe2gEcua7nQbb/vN7KoqcZKuG52WHYcnD2On
         Kq6OZYIluddFsKVemDVLJ1y4VfRWpkJ9faNxndfnQqMvHgf879KQ0f0j30cbZ1O0x8sp
         stihSaS8QDK0rQa2s/BaLonpOWnLWVo34yLDbBCo4lr0eQL+Dw+84sLeG+/Gq02BShO7
         T2sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV1zoAT76oYy/o1OvXUsKNiH85U8GOA//PZeBV+MrTidbb0DsN1
	AhqmHO3JPPjwVKEYoi5GhWIfJkZszEk3ckxB6v1RAQfOVhH9BLooc6f4JJUbRs49A2saJEv0Lej
	i4NogVUGp9tT02M8/AMZDJxMyK0E9tXZGyHNdvhQnBEylxYAFl2qra8pSESee9e3skQ==
X-Received: by 2002:a17:902:8b82:: with SMTP id ay2mr35151693plb.164.1562102830406;
        Tue, 02 Jul 2019 14:27:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuP+utd0cm3A4N3hpvL0YPzOZ8VD+OF56xRxzmfdz5ykM/6+HGhYUnUHyL4NdwNV9l4wUF
X-Received: by 2002:a17:902:8b82:: with SMTP id ay2mr35151655plb.164.1562102829796;
        Tue, 02 Jul 2019 14:27:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562102829; cv=none;
        d=google.com; s=arc-20160816;
        b=p7QQYKrWz/ulaaXvqFyXB+/zX/OIOrgM6ojfKivGXqV3HHyWU9jo2YPpHqDsfwOT9K
         rPW+O1dXiFs3m6kff1fmnD44QUiCYhyT/SEe+d+k2GaDPjZwqoZpWqoRB5zjjzI3N+qF
         Nx7c18nkQhSt7mz4cv6yhJ/iFcUWRqvwXHDTiDsu04hIIMVU+WFzST5TZk0X0YDrQEC6
         O8P3HVoIFrmcvVt9fBisFwYCkELUda56fcllBtEJLi5vvIsOlmbLpVzspguFWQ3nGtXG
         /luRWyw9yT16KyYwTYh6bzZRQ4VWb/JFD+c8Hf87PCQZ3gSdiUAvnzKWLuHm0y2HEwYf
         yGFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3A2JKYyF6Wow+uyBjAseYYHmwKeOnuwwqwzbEFG4G9s=;
        b=0BhcYMBW4yqSH0zw4U2CfDVCQ2/6tpkdn3Mozth+AOHhnqe9yYysOvndD1aqc+dlwa
         idw+YzUJ1m1CDqNlNMTnOg972qOauRYPWClYzBPDpQ+gunFvvXcGkS4GbpZ1aqp1Vp5O
         LqRQFJSGDwJXIyOXEfxnhtSvipTktwBfW7JGxhPV8J994vD8wCN1aV/tVhkA7C582+sR
         ZT1QJjTL9UfAFw1GzAHr+kUtUPe214z3fhM/svc7daPP3QFXQR9sD2AxFM8+NedF2be0
         rco4I7drFusOZq0Ir4GNVl2I88H1q0rU1boxg+A880ynx+tcVIvHr6qQVDwq072PidyQ
         y6Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w9si37587plp.118.2019.07.02.14.27.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 14:27:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav302.sakura.ne.jp (fsav302.sakura.ne.jp [153.120.85.133])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x62LR2VM045843;
	Wed, 3 Jul 2019 06:27:02 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav302.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav302.sakura.ne.jp);
 Wed, 03 Jul 2019 06:27:02 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav302.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x62LQvFp045817
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 3 Jul 2019 06:27:02 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
 <20190701140434.GA6376@dhcp22.suse.cz> <20190701141647.GB6376@dhcp22.suse.cz>
 <0d81f46e-0b5f-0792-637f-fa88468f33cf@i-love.sakura.ne.jp>
 <20190702135148.GF978@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0c26d2d5-19b1-7915-e47e-60d86a946d09@i-love.sakura.ne.jp>
Date: Wed, 3 Jul 2019 06:26:55 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190702135148.GF978@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/02 22:51, Michal Hocko wrote:
>>> I do not see any strong reason to keep the current ordering. OOM victim
>>> check is trivial so it shouldn't add a visible overhead for few
>>> unkillable tasks that we might encounter.
>>>
>>
>> Yes if we can tolerate that there can be only one OOM victim for !memcg OOM events
>> (because an OOM victim in a different OOM context will hit "goto abort;" path).
> 
> You are right. Considering that we now have a guarantee of a forward
> progress then this should be tolerateable (a victim in a disjoint
> numaset will go away and other one can go ahead and trigger its own
> OOM).

But it might take very long period before MMF_OOM_SKIP is set by the OOM reaper
or exit_mmap(). Until MMF_OOM_SKIP is set, OOM events from disjoint numaset can't
make forward progress.

