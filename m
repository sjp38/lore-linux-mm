Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEF69C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 07:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DBE8207E0
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 07:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DBE8207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24F466B0007; Wed,  5 Jun 2019 03:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 200186B000A; Wed,  5 Jun 2019 03:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C8276B000C; Wed,  5 Jun 2019 03:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B57606B0007
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 03:58:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so4483116edl.10
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 00:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=dtFnyfKgG8IxI5rNacvqEjOgQALJK0nXzvx8n0nLIcQ=;
        b=f/CaMiEigfuWgxhJGeSVumrj88Ginvmwd/GnYMp3Pv3vXXYMLnT93M0LOGs1X8p+3B
         piRuXYV6j1duEy5hoKRVVaJcWbkran03G9Yn1y8jwI/t5TDR4VBU3NIBaIKPU9DQLLQ4
         jNWy18qA9Z9da/LUMlTSc54dELSYl3hmREytWsTPpI8vW5xy2JfJMlzF8JuXfhdw/Cpi
         xFVPoteQG3svq0tyNj2nG91OFsNhe2JAu1yru20N0Hn9qGqsC3n49aIyzcp/jBlxrNQZ
         +P+r/xJp/M8rkqhymbtrtmdqzECzmuCEoKhwUqIAZoKzut+a97DemH0yQRq9ye2mIEPj
         CrRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXm8pjbLs3ktJ2dXXBcduJRNiJFgEP5Pb6XWVfRdxAO+shpd5X/
	9UV2kdIVwj0/dUvAb+gqJZ2GSFNNby6hgeonxeT6kfWNZY1iatc8LaTblxscb1w9qK4JPqY8+8C
	636N8dk1CqHeNGDARHp6VL4r7WvBFkPZmgYQ9qFL9mvCSiaj4OJm6gEuCAPXpvVGkWg==
X-Received: by 2002:a50:cb04:: with SMTP id g4mr30149739edi.181.1559721531276;
        Wed, 05 Jun 2019 00:58:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzczumIUnLdw9WcOjCwZH5V0d9NVdHxFDRgAOkolxzWBSOGl0zsTHu1fQzjRta2PEOSCQ9b
X-Received: by 2002:a50:cb04:: with SMTP id g4mr30149666edi.181.1559721530441;
        Wed, 05 Jun 2019 00:58:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559721530; cv=none;
        d=google.com; s=arc-20160816;
        b=kDmUcIuf6diiYlC4zVLgL049mJhfxnrcyZI+5ItJf2OIVt8dvXJ9kB/VEJJnVes/rT
         vL4xMaNG3HPbopHyMZbkuk43qgb1d7Ur8HFUe7EeYhlEAIYDFAmbBjWD3R9BQ5ZeuCCU
         b/dv+9lurRcK0XvuWrJgoEdfgjxVkq/4b8JGiTJPUxfpYOo4iVEt3h/6yNt68AZUibTu
         4K2JPxXr/YYGnIyJ8BFVJ2ppCVbghzwqP4mz1T8ZFbri9IPiEkTPfqC6pkACVY8xbhxd
         7ezNtXUkoFMXBc2sbz/9rV8Qyh1NYLuUGaZMw0pHRyFQGiyTJSlbLRzt/uYLtlhyU+ZX
         Vaug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=dtFnyfKgG8IxI5rNacvqEjOgQALJK0nXzvx8n0nLIcQ=;
        b=k1DJAm5tUaZTJUGCjLPzgCET2mk5pn4dtTBxyz+9+EnHPo3r/npucxrBKX69H7vVyh
         aL1ZwX7lwIUbQpKjfBA88MyulvlMYq0w3Vu/u9sc6/azoQgQ3L/Mbd7YhyF9YnE2ZXKi
         qLf2DnJmlHnuBsq7KqF4WGv1qC1lUcC9DzHbavniYfVD9qrv7F7yEHFmvECN+QS5wpOe
         ERog7ChcTBXJ3wLOSnM5OQlqrU+mxuHHJvUi6ClA6FYs/5dcQPHjOKQLGnDQcOqVJbpd
         QYRIeVaDmPqJB8+E3ZZHuCixdzwat4/dzapSu6D/ivOwzuVF6Uvnd1R/dkeDB3H4/A6T
         nMQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35si9399305edd.5.2019.06.05.00.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 00:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BDEFFAF2D;
	Wed,  5 Jun 2019 07:58:49 +0000 (UTC)
Subject: Re: question: should_compact_retry limit
To: Mike Kravetz <mike.kravetz@oracle.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
References: <6377c199-2b9e-e30d-a068-c304d8a3f706@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <908c1454-6ae5-87ca-c6a5-e542fbafa866@suse.cz>
Date: Wed, 5 Jun 2019 09:58:49 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6377c199-2b9e-e30d-a068-c304d8a3f706@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/5/19 1:30 AM, Mike Kravetz wrote:
> While looking at some really long hugetlb page allocation times, I noticed
> instances where should_compact_retry() was returning true more often that
> I expected.  In one allocation attempt, it returned true 765668 times in a
> row.  To me, this was unexpected because of the following:
> 
> #define MAX_COMPACT_RETRIES 16
> int max_retries = MAX_COMPACT_RETRIES;
> 
> However, if should_compact_retry() returns true via the following path we
> do not increase the retry count.
> 
> 	/*
> 	 * make sure the compaction wasn't deferred or didn't bail out early
> 	 * due to locks contention before we declare that we should give up.
> 	 * But do not retry if the given zonelist is not suitable for
> 	 * compaction.
> 	 */
> 	if (compaction_withdrawn(compact_result)) {
> 		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
> 		goto out;
> 	}
> 
> Just curious, is this intentional?

Hmm I guess we didn't expect compaction_withdrawn() to be so
consistently returned. Do you know what value of compact_result is there
in your test?

