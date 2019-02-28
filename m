Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64109C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:44:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C4C62183F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:44:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C4C62183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBD5F8E0003; Thu, 28 Feb 2019 05:44:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6A448E0001; Thu, 28 Feb 2019 05:44:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C32FD8E0003; Thu, 28 Feb 2019 05:44:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8C68E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:44:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u12so8336199edo.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:44:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=7j9CxLJkwuIeuSHQEQMK6LwLhyXnXvx8MyTjg0UJlm0=;
        b=ooJn4Gs20Rjyir+1B3Eb6ygECVtlZlQ5elPgMScdwq3Da6Zc/XTjSzoBNmg7ocL0Y5
         Vj2D8crpxudLLeOOuIo0UqV9w5PWcHaLJV4L3wFHkICVT4r4Zrd1PfDenSYZ+4MQiTng
         /sX6qzRBYm0mthImjo+JrtDVebqOiaQtY4BprGCLC+hm8YbZ2zU9oR+hYmZ727KkhOEI
         XgQlf2hETfLcA5pFoAaMJ19lFVNCL/9hBzhAd4iLle4Ao20+5gU4ap8AoXUHsE4ERmyD
         4JxyaI1ndBRkZzUK6izMzJP9O4G4b0ZGbXqSFRUXhyjNOOHDTOMGYoB+BZi/uj0S1BtP
         E1nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuZYAau6WPge+mM8lhslj45gzjBCtDWDDV3m4A/7ITTCipUqWVoF
	+qymLMsg+/epn2lPtZfrmXTs6YXx7kn+n7p5M5/KimAf75IyMi7hcGqRUU7rwd0OIeBMS9fGMBz
	XBub5Zy7JMbq750H9GVW6y+6KETDTWTnoBRaF7PuCqLuhlGIh8HiyoLWqtdc8tonVzg==
X-Received: by 2002:a17:906:24ca:: with SMTP id f10mr5001983ejb.240.1551350650992;
        Thu, 28 Feb 2019 02:44:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiHN9lYAVCL1kYcZB74l8hcihimrKgGduyJ5wE62FQZnIqdTLYBI5NoR3bhRrLhugwuHxH
X-Received: by 2002:a17:906:24ca:: with SMTP id f10mr5001939ejb.240.1551350650111;
        Thu, 28 Feb 2019 02:44:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551350650; cv=none;
        d=google.com; s=arc-20160816;
        b=mRgT+Z+H1xLpnBbH7G5QqqJV8x3RtNTyB0Hzy/ccxW9U3u8ugobraL+G3v3dvayH3L
         Vqg+BUpn2Mjd4fncyJZcYMPm/LEzHXrhKDOr0L2sdpe5DCPa/DO0cw+l9SmDaiZh3AT7
         SMWIt1ujyK1iuDSw+30WTCy1qrhve3dNSC9Z6fPAeBI1cOuwcmRgs9EUluGm1hn+s+6N
         C9aW8DUfcNulxevYNw6qL2Ia64UkDxMBRoQZouIMD/cfKrxWe+J/o6Fw3Sbnz8Lbwr+a
         B5bQDsRwZmxmIBBv8kPlVAOo0yuP0kOSCj6AWS4SQL+GSh6ABUQ5U9tPbbcm2aJAd7zb
         Xq4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=7j9CxLJkwuIeuSHQEQMK6LwLhyXnXvx8MyTjg0UJlm0=;
        b=z7vqINt8dz0krgCQt/1QNXNU8RLR07m50BmNMQbe5sWj1EZn3gxBBATsg8OQAJ8FZV
         /YRVeNT4iFNjxIlkR1MNNq1b+/zpOek0JUL5duiWSSokIM8pb5fTQiuNTaKeB79qv0tk
         iAijlSNQwO76KlA5qNi9WrTzoxiQkT3CF0vAKYM1/qVQAaSzJZGxicOPkOFS6IVKsLo1
         c/NSc3XIpZ+A/TAT/MwJaN2BX+HcwiD8ljxMoaP4DKad+7WLp3fhAGLgznJjheAbhFty
         XC+PW7/sRsS20lIhEWsIIKYqR86qpSui2MXAUpJIdJulpBGhu6rVVMcYtyPMBYyhyDQ6
         bRvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x58si84900edx.59.2019.02.28.02.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 02:44:10 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6DEE2ACA0;
	Thu, 28 Feb 2019 10:44:09 +0000 (UTC)
Subject: Re: [PATCH] mm: vmscan: add tracepoints for node reclaim
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, ktkhai@virtuozzo.com, broonie@kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>,
 shaoyafang@didiglobal.com
References: <1551341664-13912-1-git-send-email-laoar.shao@gmail.com>
 <2cf3574c-34f9-ada8-d27c-1ed822031305@suse.cz>
 <CALOAHbB8veCnu2EvTMhH6dJTOcWmozSE+3sKtX9jXheFtJjQUA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <b88ec9aa-4630-353a-955a-3e365d44b5d1@suse.cz>
Date: Thu, 28 Feb 2019 11:44:08 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CALOAHbB8veCnu2EvTMhH6dJTOcWmozSE+3sKtX9jXheFtJjQUA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 11:34 AM, Yafang Shao wrote:
> On Thu, Feb 28, 2019 at 6:21 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 2/28/19 9:14 AM, Yafang Shao wrote:
>>> In the page alloc fast path, it may do node reclaim, which may cause
>>> latency spike.
>>> We should add tracepoint for this event, and also mesure the latency
>>> it causes.
>>>
>>> So bellow two tracepoints are introduced,
>>>       mm_vmscan_node_reclaim_begin
>>>       mm_vmscan_node_reclaim_end
>>>
>>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
>>> ---
>>>  include/trace/events/vmscan.h | 48 +++++++++++++++++++++++++++++++++++++++++++
>>>  mm/vmscan.c                   | 13 +++++++++++-
>>>  2 files changed, 60 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
>>> index a1cb913..9310d5b 100644
>>> --- a/include/trace/events/vmscan.h
>>> +++ b/include/trace/events/vmscan.h
>>> @@ -465,6 +465,54 @@
>>>               __entry->ratio,
>>>               show_reclaim_flags(__entry->reclaim_flags))
>>>  );
>>> +
>>> +TRACE_EVENT(mm_vmscan_node_reclaim_begin,
>>> +
>>> +     TP_PROTO(int nid, int order, int may_writepage,
>>> +             gfp_t gfp_flags, int zid),
>>> +
>>> +     TP_ARGS(nid, order, may_writepage, gfp_flags, zid),
>>> +
>>> +     TP_STRUCT__entry(
>>> +             __field(int, nid)
>>> +             __field(int, order)
>>> +             __field(int, may_writepage)
>>
>> For node reclaim may_writepage is statically set in node_reclaim_mode,
>> so I'm not sure it's worth including it.
>>
>>> +             __field(gfp_t, gfp_flags)
>>> +             __field(int, zid)
>>
>> zid seems wasteful and misleading as it's simply derived by
>> gfp_zone(gfp_mask), so I would drop it.
>>
> 
> I agree with you that may_writepage and zid is wasteful, but I found
> they are in other tracepoints in this file,
> so I place them in this tracepoint as well.

I see zid only in kswapd waking tracepoints? That's different kind of
event.

> Seems we'd better drop them from other tracepoints as well ?

Hmm seems may_writepage in other tracepoints depends on laptop_mode
which is also a static setting. do_try_to_free_pages() can override it
due to priority, but that doesn't affect the tracepoints. If they are to
be dropped, it would be a separate patch though.

