Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82144C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2A192147A
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:19:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="qj1+3eKY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2A192147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91BE96B0005; Tue,  6 Aug 2019 03:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CB5C6B0008; Tue,  6 Aug 2019 03:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED346B0005; Tue,  6 Aug 2019 03:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE236B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:19:55 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id w27so9756288lfk.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=N6mFKzcJuhbgMksEZaXjMK9Sa+aXVEkZHt/RWDgwRic=;
        b=Eq0hjsVmE7pWnFwCbnvIptyQOQte9a+gM9KG40twun854rSfqfhowNmByoOn512ExZ
         pzhpk7sbUFveAT/HcGd/W2d2V9NOq2n5VgEZnsu5q7L35OP4T2Ftc4UB7+YrQ0/BK1b6
         BApnvYJhhFpQGS5EvBR+Iz1JXH6zrMxK2JWiwPUeC6B+kp20ZG+B8jG5LLOOMbzndn1Y
         LJ7MIGZuuWWsWcN5pmK6GT3bllqcm7YmIAzHIDCLpjDm9mHK3phOyP5YV+Xu8qNY6CGe
         BvNtKYyWEYh2XssvMuVFa9zJmuGISbMTUkCNdy82sJK87yy2v4fB19pXSdaiLyStR5Fc
         P0dg==
X-Gm-Message-State: APjAAAV+03fjgxwAte0yl9qJSxfI/L/XObyGQy6VzjaurHjcGhHuk/xN
	877ZzA/In0o8eeK0opCzxczm+Aeoy5knSiD9R84cB02LYEB9YkbuED89gIP7NtPP7Qb4vn0OnCi
	Sd8dvUMIwseHLgRsh15qT804zSxcp3bulNdxOFkGeqip1VIzyPDMMERTAF+ph3hsnKA==
X-Received: by 2002:a2e:8802:: with SMTP id x2mr956883ljh.200.1565075994066;
        Tue, 06 Aug 2019 00:19:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxE4INA5uzdOuYy3H5FrLr14To/CXYR5HFTshl8DajRzshGRNVuhhy94HyDpW6+vfy4dUjE
X-Received: by 2002:a2e:8802:: with SMTP id x2mr956846ljh.200.1565075993115;
        Tue, 06 Aug 2019 00:19:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565075993; cv=none;
        d=google.com; s=arc-20160816;
        b=yHY8UPl3XHR/5MxxfALrWATP7M/qNfNd1DraeQl9oxoYe9YKK6mMDjMx8HYXCY8W3r
         Ey//ABTL/kuZ/AQKjnyQCfASZfkzGb9t8+bC3zR/OCNq5y6L3YbfyQnxaUnmpUcb8KmG
         r/Ocm7tmNgSLu/ln6D9PyNWd/XVe2I4Gi+plPkTd9ZIk3hQ4YzkBE9RfzRGA/3kxILkJ
         E50U/mEjBHw+0IZxArf5S0DoTnLjRPVoImCMS3i7gNCecOnY5iKB5E6Y7HkQZMjgEGww
         ECywn4TD/K4pWHobKF8cLBII7ABCtsdo2pgJxFlhs62T5zFD6PgTICY/rP6SLu3AwmoZ
         h9ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=N6mFKzcJuhbgMksEZaXjMK9Sa+aXVEkZHt/RWDgwRic=;
        b=nGWFNCbPm/Sth3LI10Sn0NapQMwwReJOM6gq0/MZVvO6PsWmXonwLeiSDJYLK4LdHI
         xGe3IA/zbliWkU1RNmZCoLsDAo/6dJk+TZRb/fGnf13riFB4K9weGudz5MINpiFeaULn
         ggIFhg0xj8nQ+npSU1oE9pFW+zU69LUy/IqLAdbfrVYENANFz5nNB2pk+gjwR5hc63vR
         BgvOnK5AygRyl3BW0BUEzzcl7DjmdFJYP1am4YOKRF2aiVs6U9spYE8DqaLwe2lHphdN
         XqawlgdWr2Jf6BA1cFNHvIwNLmJDf36Cb46oilEv87Q1V5MPO5vIS92a0jWnAULaqTOG
         f8Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=qj1+3eKY;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTPS id w204si65135515lff.112.2019.08.06.00.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:19:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=qj1+3eKY;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 5210B2E129D;
	Tue,  6 Aug 2019 10:19:52 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id kYXKZpPAQ1-JqZiG3nU;
	Tue, 06 Aug 2019 10:19:52 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1565075992; bh=N6mFKzcJuhbgMksEZaXjMK9Sa+aXVEkZHt/RWDgwRic=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=qj1+3eKYycJsRWYRyESXh/le9T+uXhFB29JZh8tHuGVXVY4TzJH31MfvV4dDd3p3D
	 5j+amf4w55mGNYaE/HxSlnsaBt7smrFwVUAi4JQnakvs/XAP5VyloJFo3MqiiLQ9zS
	 ItceemZk1AVrWepJltjbLkwA8naBgpG1rtuSRmSk=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:81f7:1ca8:6615:d682])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id J4Zd7BQsFS-JpkCvNW7;
	Tue, 06 Aug 2019 10:19:52 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729154952.GC21958@cmpxchg.org> <20190729185509.GI9330@dhcp22.suse.cz>
 <20190802094028.GG6461@dhcp22.suse.cz>
 <105a2f1f-de5c-7bac-3aa5-87bd1dbcaed9@yandex-team.ru>
 <20190802114438.GH6461@dhcp22.suse.cz>
 <20190806070728.GB11812@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <c6b2c864-985a-2565-95e7-3af9e3e015f8@yandex-team.ru>
Date: Tue, 6 Aug 2019 10:19:49 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806070728.GB11812@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 10:07 AM, Michal Hocko wrote:
> On Fri 02-08-19 13:44:38, Michal Hocko wrote:
> [...]
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index ba9138a4a1de..53a35c526e43 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -2429,8 +2429,12 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>>>>    				schedule_work(&memcg->high_work);
>>>>    				break;
>>>>    			}
>>>> -			current->memcg_nr_pages_over_high += batch;
>>>> -			set_notify_resume(current);
>>>> +			if (gfpflags_allow_blocking(gfp_mask)) {
>>>> +				reclaim_high(memcg, nr_pages, GFP_KERNEL);
>>
>> ups, this should be s@GFP_KERNEL@gfp_mask@
>>
>>>> +			} else {
>>>> +				current->memcg_nr_pages_over_high += batch;
>>>> +				set_notify_resume(current);
>>>> +			}
>>>>    			break;
>>>>    		}
>>>>    	} while ((memcg = parent_mem_cgroup(memcg)));
>>>>
> 
> Should I send an official patch for this?
> 

I prefer to keep it as is while we have no better solution.

