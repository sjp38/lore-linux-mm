Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1743C41514
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:01:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C6492087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 10:01:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="moNr7gZ0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C6492087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EE306B0005; Fri,  2 Aug 2019 06:01:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9782E6B0006; Fri,  2 Aug 2019 06:01:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F0C86B0008; Fri,  2 Aug 2019 06:01:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12A5E6B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 06:01:13 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id y24so425449lfh.5
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 03:01:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7bbzX4NqS7tPlZl7gqOBotqgWDukNiS3yB34/LQpZj4=;
        b=q0tt4vOu7n60xT7QGlBrQKCiiVm9S2TEsih+JEN0B3qns+3rSFReFjUhJVxSXjphCp
         HuWRqC7gmZt0vktduJfXQfyYwgV2BPhDx5OMMqY7oaeYMXdI+BlFsRHtVV8jZ0mukNHY
         YY6P1k8noFFzmQMxhiXsptPFTwAmdkMnJE5FHGrQjSyLElB0uOJFRJJtuTw+bnFsCxA7
         tw3JfFr9V1YmoXZPrY/lMKylx7Tgaoe4gGf5jr4BmCxIEMZAYmZKhVBy+VxVXckhm/ou
         le91OlsstEmYLe4cBLi0m39+jiP5bA3aQCbeQX4MrmB1D5K1KJQQyDVA4dIbQfBoiiSs
         AGSQ==
X-Gm-Message-State: APjAAAXk6zKqksnBMPeNdhtWkd64mDlxYKeDBzM60RoH4jJq4o0K2B2t
	VoqRZLPqgQPPAw5tFsqdt7VD2n3ZZPfH4ieAOc3ll9B2WXpBJsx/1SG2PpbxHNFRKTvyXIPVGVL
	fEp/XnxnT28bceJVxut/oHO9lIjP7c6hpKI18gAUyfPFtLTag2C42jap7yPffud/naA==
X-Received: by 2002:a2e:5dc6:: with SMTP id v67mr71126547lje.240.1564740072296;
        Fri, 02 Aug 2019 03:01:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY19BkJ9IMKXjgs+/+Bp7GIdkVevktsa/rXV6mXbZH6TsYFt/3SLgZFhgXiMqhl8xL0sZ0
X-Received: by 2002:a2e:5dc6:: with SMTP id v67mr71126516lje.240.1564740071395;
        Fri, 02 Aug 2019 03:01:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564740071; cv=none;
        d=google.com; s=arc-20160816;
        b=yWwIpQ4fUST3g+xBjAJeGJWHUMG0Z0/UW9yMxmzOTw3oIs+n5x8PPlwZJR7Sb2ltb/
         ELabwqHo69U6E72dcFA2g4xKQ2AgRDka1QMIAml3d9xZpHfXJs6w0GQNsvJeVT5Elwc5
         1rT6WDS856mNFkg/hKbJGv+YLrz/ZelDZOJIefeURGsPvxZNKsPoJSaJO6qH88aueCje
         0vWCoG7AC7W1jE2pk+0BtYFN3kx9fd8raqpc3WN4pWea/lIQ90rvXs0zv09o5ruS9cWf
         xmmtASVaDs2L9A+12o7agqGVSo0HEB1S1bk9QGjL2WKHq2r8olfkq5t3i7/dy22LwwVD
         acOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=7bbzX4NqS7tPlZl7gqOBotqgWDukNiS3yB34/LQpZj4=;
        b=ILsF8gDR8QNveiUn47Si0d7DzOZgAtzGtLUAQ3Gvky/+SzbE6BR2DhEsULk6On07hu
         a1FDu0WrK1Uh6d6ddfwV1sIvzBR4oGsI09G+Mq6GzZTvMC4FUSnAh93yUdLFcISluSpf
         1UBD4dOVZCxDb3x6RQyrUGgL2YnQeSIK7kbz6TNV64CdiuTMCxnGY2boQicGoBmM4oMO
         qMKobDAURNt+aGiCn5i7PvSVsLQwMpRqoDfwftD+gzMRqSGx9//XYk+4TDNgiZGdbNH0
         OkbIpibicowv4uYc9JeP1GQIRqzkJtOfrr62JiVI9NJ3+YTPcUVSZpuqoOZVsP2AOi75
         ZRMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=moNr7gZ0;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id x144si58149263lfa.3.2019.08.02.03.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 03:01:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=moNr7gZ0;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id B6E762E1531;
	Fri,  2 Aug 2019 13:01:08 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id HOPkayq66P-18ZKcidf;
	Fri, 02 Aug 2019 13:01:08 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1564740068; bh=7bbzX4NqS7tPlZl7gqOBotqgWDukNiS3yB34/LQpZj4=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=moNr7gZ0cw46pUWpD6Kc7KZit/7vWlq/+bm9aSLLfyTHajQxFIF6NO0eZbtRnQnlt
	 8/3f6xX2AE9lAZha1WwiDSi+7GkhRjLEfbfSQzeoRWg2vKQ12/g+secRmysS7PnKgh
	 txBLBlys7Azw5kyL63Cc1ZWr+j7i4olh1Dv57I8A=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:6454:ac35:2758:ad6a])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id tiugwYi2cZ-18Q82FIR;
	Fri, 02 Aug 2019 13:01:08 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org> <20190729185509.GI9330@dhcp22.suse.cz>
 <20190802094028.GG6461@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
Date: Fri, 2 Aug 2019 13:01:07 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190802094028.GG6461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02.08.2019 12:40, Michal Hocko wrote:
> On Mon 29-07-19 20:55:09, Michal Hocko wrote:
>> On Mon 29-07-19 11:49:52, Johannes Weiner wrote:
>>> On Sun, Jul 28, 2019 at 03:29:38PM +0300, Konstantin Khlebnikov wrote:
>>>> --- a/mm/gup.c
>>>> +++ b/mm/gup.c
>>>> @@ -847,8 +847,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>>>>   			ret = -ERESTARTSYS;
>>>>   			goto out;
>>>>   		}
>>>> -		cond_resched();
>>>>   
>>>> +		/* Reclaim memory over high limit before stocking too much */
>>>> +		mem_cgroup_handle_over_high(true);
>>>
>>> I'd rather this remained part of the try_charge() call. The code
>>> comment in try_charge says this:
>>>
>>> 	 * We can perform reclaim here if __GFP_RECLAIM but let's
>>> 	 * always punt for simplicity and so that GFP_KERNEL can
>>> 	 * consistently be used during reclaim.
>>>
>>> The simplicity argument doesn't hold true anymore once we have to add
>>> manual calls into allocation sites. We should instead fix try_charge()
>>> to do synchronous reclaim for __GFP_RECLAIM and only punt to userspace
>>> return when actually needed.
>>
>> Agreed. If we want to do direct reclaim on the high limit breach then it
>> should go into try_charge same way we do hard limit reclaim there. I am
>> not yet sure about how/whether to scale the excess. The only reason to
>> move reclaim to return-to-userspace path was GFP_NOWAIT charges. As you
>> say, maybe we should start by always performing the reclaim for
>> sleepable contexts first and only defer for non-sleeping requests.
> 
> In other words. Something like patch below (completely untested). Could
> you give it a try Konstantin?

This should work but also eliminate all benefits from deferred reclaim:
bigger batching and running without of any locks.

After that gap between high and max will work just as reserve for atomic allocations.

> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba9138a4a1de..53a35c526e43 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   				schedule_work(&memcg->high_work);
>   				break;
>   			}
> -			current->memcg_nr_pages_over_high += batch;
> -			set_notify_resume(current);
> +			if (gfpflags_allow_blocking(gfp_mask)) {
> +				reclaim_high(memcg, nr_pages, GFP_KERNEL);
> +			} else {
> +				current->memcg_nr_pages_over_high += batch;
> +				set_notify_resume(current);
> +			}
>   			break;
>   		}
>   	} while ((memcg = parent_mem_cgroup(memcg)));
> 

