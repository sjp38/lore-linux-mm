Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62CA5C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B8CF23FFE
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 17:49:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B8CF23FFE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AC336B026B; Wed, 29 May 2019 13:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75CA76B026D; Wed, 29 May 2019 13:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64BB76B026E; Wed, 29 May 2019 13:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9736B026B
	for <linux-mm@kvack.org>; Wed, 29 May 2019 13:49:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f15so2706640ede.8
        for <linux-mm@kvack.org>; Wed, 29 May 2019 10:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P7ysRMZt6AAuCtlwAp6M6h3nYp7ECC73QBcM+lIyMIY=;
        b=KKAOT8JCZ4sXrfnli7ENL7pe3OSWWaCDmXyV5CB1iOyReoGs/IbjzbUq711J+SO6nE
         Ej63Qq7LkwL1zguW5K/YKY4a/arB7MP53bqXluLlSsSfqTUjeFFSnLX4U8+LoY0iWrH/
         xteW4F8eAsD0H0/qzIrAl4aYjpNkVdxF+bmFkh7n2Q67XSC15BNQbtdm7oH8CVqSWFIs
         cviKheu2+M8UKVpDw16A6Tv2Eroz+87EkYgztQo6k73+jnOts17rGItCwgtzBbymYaO4
         pPAhNGL3bsbAHy3d1mBFIIEyQCqyXpD1xLt8ZFmC1hkp9QVKkoT0XJAG9xQwW6pQS8Gj
         Jxsg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWTYwqZotoqdMMralq1d5gf3eKL6/v36JODhD72Cxw7s8xpERfS
	cH89Z73U492PmPItens9ueK7X1KT4Gaqz9ojAqd0QWzdlfArUn4mSFZQO5YLSkj+i/Z/5VCRQYu
	lcenBLJMLJSc9tuDggDZAEpPX5/9u1eD5SgNEk97zLSc422NANzTGPFN0Yw1uSlc=
X-Received: by 2002:a50:8a46:: with SMTP id i64mr136878848edi.177.1559152175768;
        Wed, 29 May 2019 10:49:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOnvXpPuLpRlXUZtsa6E8DdIEU8qe5tYoxLhc5vvm6yL1VtKNWw1cwR9gm8yP6+WLi+EEM
X-Received: by 2002:a50:8a46:: with SMTP id i64mr136878755edi.177.1559152174835;
        Wed, 29 May 2019 10:49:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559152174; cv=none;
        d=google.com; s=arc-20160816;
        b=0PZaFgzm7iEXzWD7WcpRRLXVwnN5svLHlrRVPvfwcZ0G6bVWX5+S557vDbfYtDVdPU
         ZoF1g+FGZhQEC9DTOVB7AMyBLrsn2PkF4Fp7o6FFU5VYMrosldXkazBKjS4FdrTu/NGA
         zeZLPPHE6Bo8LfXtZ62G7eGo3H9pEbCmDhekWTV3v6H7dDlGVD1hmJN+oP0FSisgLxVj
         z0Oru6euNeDnF6ZzwcR5dS8h+0VgBEWLgVoKT20TXgcEM7OIdCLvLecMgZB6n9fVoJpT
         3cKrF9l0sL3/w9vPg0a6SeC6G36qzTqsqaTcMQx78+zc1IcMBMKB9uU1cdTZ74DiCa9U
         bzOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P7ysRMZt6AAuCtlwAp6M6h3nYp7ECC73QBcM+lIyMIY=;
        b=mq1objEiRCR45mstpFBwEQv3C3UQtaFaNmCjmMuWCdLcoH4UWBl6uhU08FNsG4yOdH
         N+yBQJiYUL50SArvcEJOf5h71em+koCZc9CfRR1XbBoxCNjjKNMn7yed/XlZdClxyW2n
         9oMtiXkAaBXp22gfCLe4XF6zJSeqchCXYHr2Q4LGEbzVb8UQrko7Q56mWIH7OmoE+dLI
         HfcL6rW4Px1bobNZxuSKAXR8mwexvVYc3TTsK1E4QkiSOIIQxsf6PJunkJPAIQxNhbHY
         c6QAcCdQ8m0my4ORtrP195IInAmiAEqDeAybIOF5ITiRdWgATT5+rvpIE9fK/M2UsYnr
         qZfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si196946ejj.111.2019.05.29.10.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 10:49:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C68D6ACD8;
	Wed, 29 May 2019 17:49:33 +0000 (UTC)
Date: Wed, 29 May 2019 19:49:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Dianzhang Chen <dianzhangchen0@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in
 kmalloc_slab()
Message-ID: <20190529174931.GH18589@dhcp22.suse.cz>
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com>
 <20190529162532.GG18589@dhcp22.suse.cz>
 <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 30-05-19 00:39:53, Dianzhang Chen wrote:
> It's come from `192+1`.
> 
> 
> The more code fragment is:
> 
> 
> if (size <= 192) {
> 
>     if (!size)
> 
>         return ZERO_SIZE_PTR;
> 
>     size = array_index_nospec(size, 193);
> 
>     index = size_index[size_index_elem(size)];
> 
> }

OK I see, I could have looked into the code, my bad. But I am still not
sure what is the potential exploit scenario and why this particular path
a needs special treatment while other size branches are ok. Could you be
more specific please?
-- 
Michal Hocko
SUSE Labs

