Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF2D6C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:19:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF94E20815
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:19:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF94E20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2C56B027D; Mon, 27 May 2019 09:19:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4644B6B027E; Mon, 27 May 2019 09:19:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32D936B027F; Mon, 27 May 2019 09:19:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D1F616B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 09:19:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so28020250edr.18
        for <linux-mm@kvack.org>; Mon, 27 May 2019 06:19:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=FJoZQHbqHN75qPqhOBllpf0gYDzOBGlgBEBqHdQIhwg=;
        b=Gg2AJFQSMix/6NFJ1HRYtgsYh1BjTmIuOng9ZD6cRnzP57OAt4MAYle7rqjA4NCARJ
         jceSWPOPUZQW5mpAfpcEPtj2pglgAJD8lyJac8syeYecEfQtQ21m+6AA7wXBf93dinFk
         1+47ATbHdF24ztLnn+0NXNcAOMyeU6qHJVLDEOwFTHTbz5sLJfsLhEOpvYTnxIyyMztc
         nwng00wZdILBmnj+UqAFUyMC03T2CkXJ1YKACXZ/7BqBk6Qqam9MEEgeWqb3J/3KViDX
         3azVfdaojlxZ1MiPOZ23XVqUNt6EAbf52EY5n/dZLrQIG8X0BAYDzrVErwIlSaBhZ7Ib
         t9pQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWID2IQaLyYKIFyL0B0ftZjBv97yHYYFC/xasv4Fr4q3gmN/Gdh
	6kNwX/HrK3xivoiCtQy0VxsklJnZV+k2Db2hvNdxJvC56dT5PsvGU48nIx52oUlUIAzmkCysMdL
	oHei3hHYaqica4n03ykQK2MMo7ODXy6WApj/3Mv92wc74gR+vQ21y7zgpBqRh/MBFLw==
X-Received: by 2002:a17:906:2922:: with SMTP id v2mr44670910ejd.115.1558963186395;
        Mon, 27 May 2019 06:19:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9LxLqE/8/bwhT8dtztJVd7FgsYklU4sxJ1yHYlGKJjbnf/VUErMYy41yVt9KQnS2HsNGt
X-Received: by 2002:a17:906:2922:: with SMTP id v2mr44670841ejd.115.1558963185585;
        Mon, 27 May 2019 06:19:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558963185; cv=none;
        d=google.com; s=arc-20160816;
        b=gUNxhoxXaASbi6cAsDFEkw80aI/VKmfMTdRp9xwNmb0yLfLB16G6JNUJ+eZP0ijDT3
         415vJIXnBAlLFAsxmb6LOc0ZeViBYbhCFE7Zsogy4r5vVySCoTGrzy2vU9LpzRyqQSoC
         +k0b9FAURI7x/T1laWyCsRNrgHbbKAxlJvAkhh6qCb0RUgG8DsHIwK+Yzls2LiA3vF7j
         7fzNW9eugOuJdKp+r5s44pmo53hiazBKCQdrIc7qnES7kt4UJiEMgaCr6stn69NN7N4b
         cBdbwh/QMrytmhjZN+699VYEYuCd8emqlkr94q+QD1iAMa41n1qzpnfpAC+5gBqh90BD
         FcpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=FJoZQHbqHN75qPqhOBllpf0gYDzOBGlgBEBqHdQIhwg=;
        b=iACV/Xj9mRBIl+IPG4xMVDIpgKAGJYiZTI8scaOoPgKwY9PHvQNdErIyPRzwrHB6vZ
         G5uNmZ0nlnvaViuClhA/0l8BNiJ+KQKJgxiJIZkEmlbGy5OhjtTtR+s4NPWKlCpbzFXr
         Kdhw75ivZ2OUum2y6IIzLHisS+NSxqpybyAQjNI93hAQaA/AkUjuCWbjXrhEJwotmiSW
         iK+/Trpn8wJERbb8tdH8a8gvYjaZaOrdgqYkFpogJvk4ip6Jmhyjq/idoVm3YA3nY9U6
         Lei3F0xndifuSWhhulrS/ZrwVW2C4lzrBiwuGYjXdf+gLP/M80LQq4nqg1KdGklg/A2O
         YFfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u4si7020035eju.130.2019.05.27.06.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 06:19:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1952DAE78;
	Mon, 27 May 2019 13:19:45 +0000 (UTC)
Subject: Re: [PATCH v2] mm: mlockall error for flag MCL_ONFAULT
To: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>,
 Michal Hocko <mhocko@kernel.org>, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "Jordan, Tobias" <Tobias.Jordan@elektrobit.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
 "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
References: <20190527070415.GA1658@dhcp22.suse.cz>
 <20190527075333.GA6339@er01809n.ebgroup.elektrobit.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <7d5b948d-0253-e73e-980f-f6db5f92b461@suse.cz>
Date: Mon, 27 May 2019 15:19:44 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190527075333.GA6339@er01809n.ebgroup.elektrobit.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/27/19 9:53 AM, Potyra, Stefan wrote:
> If mlockall() is called with only MCL_ONFAULT as flag,
> it removes any previously applied lockings and does
> nothing else.
> 
> This behavior is counter-intuitive and doesn't match the
> Linux man page.
> 
>   For mlockall():
> 
>   EINVAL Unknown  flags were specified or MCL_ONFAULT was specified with‐
>          out either MCL_FUTURE or MCL_CURRENT.
> 
> Consequently, return the error EINVAL, if only MCL_ONFAULT
> is passed. That way, applications will at least detect that
> they are calling mlockall() incorrectly.
> 
> Fixes: b0f205c2a308 ("mm: mlock: add mlock flags to enable VM_LOCKONFAULT usage")
> Signed-off-by: Stefan Potyra <Stefan.Potyra@elektrobit.com>
> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks, shame we didn't catch it during review. Hope nobody will report
a regression.

> ---
>  mm/mlock.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index e492a155c51a..03f39cbdd4c4 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -797,7 +797,8 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	unsigned long lock_limit;
>  	int ret;
>  
> -	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)))
> +	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT)) ||
> +	    flags == MCL_ONFAULT)
>  		return -EINVAL;
>  
>  	if (!can_do_mlock())
> 

