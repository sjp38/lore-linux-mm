Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C7C0C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCB112182B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 16:51:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCB112182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF076B000A; Wed, 17 Jul 2019 12:51:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B16F6B000C; Wed, 17 Jul 2019 12:51:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A0B38E0001; Wed, 17 Jul 2019 12:51:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB2686B000A
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 12:51:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o19so14986259pgl.14
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:51:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=TH3BLOrJdwb0K4fYTKufAE2/lEWu13MyzWYsnzji9pI=;
        b=k2BmH4vxURvuzD9PdXilNkIyd38EZZMe14fASbugGT7CBlmyHPma7YNF9cgnXg3mGk
         mq0eSGlRQOCALkx6gPA1cC/Ly5UEtxNK24HAtEkJKfX88qxnZ3+ffSreZw9GcU3JLR3E
         6CWufijcAxFoQg381U/riY/VGaAFuj8t9VvMZxqBq2ayjtR1ehx9ceYySTzJSRILJjtS
         JkxQiGFGxop7OfTipcW7KkwJbXGxhQrVheEq4Mz6ubJSH04qSEpkqvJ6B99wONhuXdFO
         4dHGhjvX4d4TozXjZOGJ1113X7Gv/Vg1o9ziEGI35Z4qPZVN765YqKQgvgBcJWQP77uu
         Uvpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWURIiiV9TmS2dA4RTtZT+Yji3I0fAk55S+KxckbMsQ43FgT2cp
	FFkdMGPMgQB4NZCUikHqk4qhrpkAV85ddL/VMNgk8f6a0pM96JofyLhZ+Ma6jlDbWYabzkOYEud
	f2R2dUK+MzYr+LGHdFgtN71ftBRcopMGVthYHmRCXqJGEW7IV81YXCL0q4HZ+OZ9jAA==
X-Received: by 2002:a63:4404:: with SMTP id r4mr41772320pga.245.1563382288452;
        Wed, 17 Jul 2019 09:51:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+RiXdp7o2jvXz2os2gjTfVCoh7t3QAAx+/uOpmMJAwQE8p72c6eOpCtj6UUDxwzHNy8P1
X-Received: by 2002:a63:4404:: with SMTP id r4mr41772186pga.245.1563382287299;
        Wed, 17 Jul 2019 09:51:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563382287; cv=none;
        d=google.com; s=arc-20160816;
        b=GLk4CwyzcuZGLf9OR5WJquBpSsri9ok+w48yIZQPEq4S2HrL1KJHEEuZiVMcCPwn2e
         NwoT9KCo3/l2ob4yyVbzVuQbBhXweks6rtt3vB4f4MfwaIzJNbhyEqWZ/H/qUBmNMvG2
         fk6qyLXBa2Tna0QPs640l1B8ujGkZHvluCmA1qibEyTVPqOtNaeTFoG7vH27xP04qRDe
         gxKoxpcO2UYWkHNpTjAjh4x/oYvIFjRFxv2TjzQe+4n3M8t8FugO7REj7X1MbZE/wcGh
         mkKQO/9PA/mwKALhx8uqwMaYocf7imShjl3+uLHyoyq7s3vebr1gz40UFX2NXtwyncJn
         192A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TH3BLOrJdwb0K4fYTKufAE2/lEWu13MyzWYsnzji9pI=;
        b=GMHr+YxXFn6YbRzu4rFcnHvmVgZOFDSheu97PJ11hdYe8gGjjNiSr+G4xoreex+Nsr
         F+tMK6iCwr9/eKbuwjes71FYqrWzMOokTBdk19S2Q35BKDAXyfZl+g4FiVdi9Cz50odu
         duEEOXAZDu5hz/+p4nbsiVdoG2Gaf6/4yrNQCR+42hdukw2OrI/Gca0wXOiYcOEQ+O/W
         ignokJIs36HKKnUstMnPp8OvME3LQjZM35OL8QLurSKNd0Pl06ZFc3jfNHKc76modc4I
         ffYFla41qswTCUEp9vrMYW6peTpPPmp3bML449+a14srFbhkc8EcNizGrRwXsQJrneJl
         iD2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id a25si24947602pfo.234.2019.07.17.09.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 09:51:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX8jliE_1563382282;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX8jliE_1563382282)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Jul 2019 00:51:24 +0800
Subject: Re: [v2 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-2-git-send-email-yang.shi@linux.alibaba.com>
 <fb74d657-90cd-6667-f253-162c951f1b05@suse.cz>
 <efe90132-6832-d61a-5d55-d2cc134c7087@linux.alibaba.com>
 <7806e608-ffcb-fd56-2e0f-a20bea127f40@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <88894b57-7005-5882-ab9f-fc64e42cf8ca@linux.alibaba.com>
Date: Wed, 17 Jul 2019 09:51:21 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <7806e608-ffcb-fd56-2e0f-a20bea127f40@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/17/19 3:55 AM, Vlastimil Babka wrote:
> On 7/16/19 7:18 PM, Yang Shi wrote:
>>> I think after your patch, you miss putback_movable_pages() in cases
>>> where some were queued, and later the walk returned -EIO. The previous
>>> code doesn't miss it, but it's also not obvious due to the multiple if
>>> (!err) checks. I would rewrite it some thing like this:
>>>
>>> if (ret < 0) {
>>>       putback_movable_pages(&pagelist);
>>>       err = ret;
>>>       goto mmap_out; // a new label above up_write()
>>> }
>> Yes, the old code had putback_movable_pages called when !err. But, I
>> think that is for error handling of mbind_range() if I understand it
>> correctly since if queue_pages_range() returns -EIO (only MPOL_MF_STRICT
>> was specified and there was misplaced page) that page list should be
>> empty . The old code should checked whether that list is empty or not.
> Hm I guess you're right, returning with EIO means nothing was queued.
>> So, in the new code I just removed that.
>>
>>> The rest can have reduced identation now.
>> Yes, the goto does eliminate the extra indentation.
>>
>>>> +	else {
>>>> +		err = mbind_range(mm, start, end, new);
>>>>    
>>>> -		if (nr_failed && (flags & MPOL_MF_STRICT))
>>>> -			err = -EIO;
>>>> -	} else
>>>> -		putback_movable_pages(&pagelist);
>>>> +		if (!err) {
>>>> +			int nr_failed = 0;
>>>> +
>>>> +			if (!list_empty(&pagelist)) {
>>>> +				WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>>>> +				nr_failed = migrate_pages(&pagelist, new_page,
>>>> +					NULL, start, MIGRATE_SYNC,
>>>> +					MR_MEMPOLICY_MBIND);
>>>> +				if (nr_failed)
>>>> +					putback_movable_pages(&pagelist);
>>>> +			}
>>>> +
>>>> +			if ((ret > 0) ||
>>>> +			    (nr_failed && (flags & MPOL_MF_STRICT)))
>>>> +				err = -EIO;
>>>> +		} else
>>>> +			putback_movable_pages(&pagelist);
>>> While at it, IIRC the kernel style says that when the 'if' part uses
>>> '{ }' then the 'else' part should as well, and it shouldn't be mixed.
>> Really? The old code doesn't have '{ }' for else, and checkpatch doesn't
>> report any error or warning.
> Checkpatch probably doesn't catch it, nor did the reviewers of the older
> code. But coding-style.rst says:
>
> Do not unnecessarily use braces where a single statement will do.
>
> ...
>
> This does not apply if only one branch of a conditional statement is a
> single
> statement; in the latter case use braces in both branches:
>
> .. code-block:: c
>
>          if (condition) {
>                  do_this();
>                  do_that();
>          } else {
>                  otherwise();
>          }

Thanks. Good to know this. Anyway, with the "goto" suggested above, we 
don't need that "else" anymore and we could save some change of lines.

>
>
> Thanks,
> Vlastimil

