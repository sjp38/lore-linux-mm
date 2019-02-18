Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BC63C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 953F6218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:20:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 953F6218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C6E18E0003; Mon, 18 Feb 2019 03:20:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 277688E0001; Mon, 18 Feb 2019 03:20:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B4298E0003; Mon, 18 Feb 2019 03:20:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3B5E8E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:20:35 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id g75so3889564ljg.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:20:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5SgWj0WCOUsnb+Z8O35WayYrI11lKZYvefwHPXVlQMg=;
        b=uUCcmjk6bFfvYcsAiEV44pct+rr2DCyrAOlPDexK8iLgZOV1Y5Paidd5IcRxwMbj1D
         OxSDlrnj+Tstj1POVHQ6t9JShCoGZT6g+5T2TY4lSKpBMo+vM8VdMJuEE+cegnFGKSIV
         4E1s/YFIDBC2h7Lf1mP8A+bqx1rU1ywYfXm08OjilkVx29LOYyU6bs74QG7NcpZ4m33V
         TpgWJZJS8mwC57BjH1VTiLfnYJzM9sD4vbcLvqAX1Cd9RMbS4/iDjI4bZXP+8HCgPqXM
         0WKW79BgxQTBnNMmK4GPzezml6LxbEYb7n2N7qj5MPCAE72r3Ouim5XR+2Ks3CGQ3lRy
         8BHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubRvWgbEL4bQPfZu1acgaNwPXVepmQnIW5XIE2oiWrUTgupeWxU
	xUBwrJN17i07uPsHws0134sr3BjpsEhdpZ2Uye8pIO33sTsgfbQ173MOaxVVO2LrDgbH73WGvH+
	EZhcsd8OI+uNJ2+lY23YJiD0hGC1Oc6J+J1T3xrAJFokFHZlG9gCCcWKswBGI76ScTQ==
X-Received: by 2002:a19:6458:: with SMTP id b24mr14055337lfj.116.1550478034862;
        Mon, 18 Feb 2019 00:20:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZK+dTMmtRx4CHb4hRQsb1v4wLJ4E29wcEW6htsgvy8UgkxFamloTRk1K/IQgZT+PXwoLIH
X-Received: by 2002:a19:6458:: with SMTP id b24mr14055273lfj.116.1550478033707;
        Mon, 18 Feb 2019 00:20:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478033; cv=none;
        d=google.com; s=arc-20160816;
        b=M5TcA1rtTnOrwACf7xADUMM4uvDKOX/q8uq3wz1CL9IcLGJTGK5pep0glsp04RAkPr
         TyvZpffLpRlnnPXd9WAwpdLzVuhj44t5MSsFWC7KAnx3b04B/MKxUqNE4niGdjeACSDs
         U5zCfEAF5qioH83YaK42BPvvqHiKWFLhJKdSzwTil+DO7qUf1JJ4chPF6TCyQfaDNsDA
         sxSp0zBzDbEnIcfM5w4Ms/PEQbAqqRZhOPfvHpOIDqpU7oHvfcMjE7OzRe5NwFZ0sWFi
         zkOcKjz823Bw5cVhiCmPBYgOKvLPNg1aiPmY14UQZaAHVyai0n755LuZUYrgBpxAd79i
         nsjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5SgWj0WCOUsnb+Z8O35WayYrI11lKZYvefwHPXVlQMg=;
        b=MrRjSBaAlqA8vrBb8n0Inw1tWz2Qtucm3BOuUesxaUf+zl50rRp3/HaMd+BTAL+3OU
         oCaB4qkuLBdgi0y94NC66swFVCg9g9rXJ2hTRGRSNPyFIsDob/nlOrnHYQA+9tSyeD6Q
         nBhsdiUBj4+r3O8Ggq4drO9JZkOcFvs3WrfW1vPVTOxl2St0kga2dmyUzHKd77+2vr/z
         Ht/KCyEkTw4guFjHd6tt2tSkActvot21tiE3yZftyA3Q17N625kAe17Fe2UaSMimqUcH
         OFSybZ/pm4O/QA4dxJxZHzY5R6tKRRC5R3fbTorcTEIOFexcmJSRGFSWrtkLmhGM00fs
         F3+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f20si1585038lja.25.2019.02.18.00.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 00:20:33 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1gveA0-0007p3-1w; Mon, 18 Feb 2019 11:20:20 +0300
Subject: Re: [PATCH v2 4/4] mm: Generalize putback scan functions
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <155014039859.28944.1726860521114076369.stgit@localhost.localdomain>
 <155014053725.28944.7960592286711533914.stgit@localhost.localdomain>
 <20190215203926.ldpfniqwpn7rtqif@ca-dmjordan1.us.oracle.com>
 <b2fcd214-52a5-6284-81b9-8a09de27fbea@virtuozzo.com>
 <20190215221335.32zqxhwtcr2kmgku@ca-dmjordan1.us.oracle.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <3e408cad-38f3-e15d-f2b8-d0c136707c9a@virtuozzo.com>
Date: Mon, 18 Feb 2019 11:20:13 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190215221335.32zqxhwtcr2kmgku@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 16.02.2019 01:13, Daniel Jordan wrote:
> On Fri, Feb 15, 2019 at 10:01:05PM +0000, Kirill Tkhai wrote:
>> On 15.02.2019 23:39, Daniel Jordan wrote:
>>> On Thu, Feb 14, 2019 at 01:35:37PM +0300, Kirill Tkhai wrote:
>>>> +static unsigned noinline_for_stack move_pages_to_lru(struct lruvec *lruvec,
>>>> +						     struct list_head *list)
>>>>  {
>>>>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>>>> +	int nr_pages, nr_moved = 0;
>>>>  	LIST_HEAD(pages_to_free);
>>>> +	struct page *page;
>>>> +	enum lru_list lru;
>>>>  
>>>> -	/*
>>>> -	 * Put back any unfreeable pages.
>>>> -	 */
>>>> -	while (!list_empty(page_list)) {
>>>> -		struct page *page = lru_to_page(page_list);
>>>> -		int lru;
>>>> -
>>>> +	while (!list_empty(list)) {
>>>> +		page = lru_to_page(list);
>>>>  		VM_BUG_ON_PAGE(PageLRU(page), page);
>>>> -		list_del(&page->lru);
>>>>  		if (unlikely(!page_evictable(page))) {
>>>> +			list_del_init(&page->lru);
>>>
>>> Why change to list_del_init?  It's more special than list_del but doesn't seem
>>> needed since the page is list_add()ed later.
>>
>> Not something special is here, I'll remove this _init.
>>  
>>> That postprocess script from patch 1 seems kinda broken before this series, and
>>> still is.  Not that it should block this change.  Out of curiosity did you get
>>> it to run?
>>
>> I fixed all new warnings, which come with my changes, so the patch does not make
>> the script worse.
>>
>> If you change all already existing warnings by renaming variables in appropriate
>> places, the script will work in some way. But I'm not sure this is enough to get
>> results correct, and I have no a big wish to dive into perl to fix warnings
>> introduced by another people, so I don't plan to do with this script something else.
> 
> Ok, was asking in case I was doing something wrong.
> 
> With the above change, for the series, you can add
> 
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

Ok, thanks.

