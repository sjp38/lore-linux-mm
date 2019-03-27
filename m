Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E293C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB1572147C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 11:45:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB1572147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F9866B0003; Wed, 27 Mar 2019 07:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4806C6B0006; Wed, 27 Mar 2019 07:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34F346B0007; Wed, 27 Mar 2019 07:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D38A76B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 07:45:01 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19so6545568edr.12
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 04:45:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hwEueomhnu6chl+rjD2So7MMvkhqpBiXTJOuHp3YBSA=;
        b=j3AtsZUUEeeMmfuy0FEAgJ2o97s/qVGAup9CLZO/qLIMhbenAYwe81u8EPTdYcAC27
         gyVw9H8VbB8EO9r67uzq0NkqF34ib+m7F4HaSP3jfgYNBKTukYmNM7dnoW8RX3q379hZ
         GQg3U51Tf2AJydC6JlFdwQBOWX3j8hSmdCupPz6RwELJZotkhXU7fZ+Tw9j39MKHJYP/
         vYgIQsd9g9mLwCTDdMpQ+2ggdYPwoN6KudpwprXGbdPofaK1C69WLNMwnK848Jfu7xQJ
         pF6uebHvEqrYhFoYW8TIxL3OIqkkQVG8e0Yc9Btcei5jibmfjrdnpPgiSeDc/vccsrsc
         DZ+w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUsIeANnUp2aaa44cGIlhF6CNZ4ZZgc5e4bS3v5exRS24E2mlMQ
	hkt49vhMnm4/8VdXsq7ziqFoGV069+l4jVCZf56kIhsiDKATj7pxhvtVPjA7gvoR7Ey6hhQLel0
	LOaG3i9xTlZiL8jbid4PCJe50FO2XW8DXzz6N469nWnBzITjmGwQdFSPXAYlAyS4=
X-Received: by 2002:a50:b149:: with SMTP id l9mr23567786edd.254.1553687101281;
        Wed, 27 Mar 2019 04:45:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWBfh4QR2XnuN4urbJkwBocHH4UvqCGJlsb3yZNSqSP+nPJuS96Bn4oznRwaHuoAzv0fwg
X-Received: by 2002:a50:b149:: with SMTP id l9mr23567744edd.254.1553687100518;
        Wed, 27 Mar 2019 04:45:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553687100; cv=none;
        d=google.com; s=arc-20160816;
        b=QAmmxBl+1fiUTTFXjbrOVToNccjOulrj1gzZ6Uuwz/jE71OXvtv7n/lDMDqnDSZut+
         LWUwqbJIxc8IgzXgd1yBuM/2fSS4oe0GjorjN111bKezQBXO7vRAonscmheAuwD/xXHI
         9+32YsYwo7NxaI/C2wv849cYib1THLhbvb8pMPB/wA97xqcp0LIbxlY5N2tR9kVn9dj8
         TJ2wW+ABgkflONDzQBRIOD2eWg6HearbrNeIMXPtLVwYP1WChG8wfy8qLTHBA3HU49cS
         xRr7QKEkrOdCkEUkZuKMfVvfVtok1B84/6e09VJKGfSiW9p9mjKfaFSFICxzX98sli1A
         MLQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hwEueomhnu6chl+rjD2So7MMvkhqpBiXTJOuHp3YBSA=;
        b=0J0jN7/wCtlGfYhMKj2AfKgkmRtxy7DlHNQLVg3G4voYvC+/6UhnDzPme31EFFrVqV
         MBDpcP/L9Svh37BRAhrwnmCsPHfzyjrrGsCsJl269TBQ8A0sBluI2SQIlRltt2Y0d0XY
         M8XweTpzex9IwYB4COMv+JoPgJ2Sh1DTgh8e5RZjyHK3Ocn+H932kSXIFYs/AH7BBYyj
         vE6pKrz+cyq1j0sJ865Iz/T1wnHfZdZjB/jXgF+DAc5oHsUZQ6RAeisMOpubvMjIdJ95
         28QAwprkCwTHzlmR0lQKn+7ZLZyqcs+l0fFlWuNo65QNrTKPznA9S/sbptV537Bp1jS0
         GH8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si64285edc.177.2019.03.27.04.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 04:45:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9BD45AEF5;
	Wed, 27 Mar 2019 11:44:59 +0000 (UTC)
Date: Wed, 27 Mar 2019 12:44:58 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, cl@linux.com,
	willy@infradead.org, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190327114458.GF11927@dhcp22.suse.cz>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <651bd879-c8c0-b162-fee7-1e523904b14e@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <651bd879-c8c0-b162-fee7-1e523904b14e@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 07:34:32, Qian Cai wrote:
> On 3/27/19 4:44 AM, Michal Hocko wrote:
> >> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> >> index a2d894d3de07..7f4545ab1f84 100644
> >> --- a/mm/kmemleak.c
> >> +++ b/mm/kmemleak.c
> >> @@ -580,7 +580,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> >>  	struct rb_node **link, *rb_parent;
> >>  	unsigned long untagged_ptr;
> >>  
> >> -	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> >> +	/*
> >> +	 * The tracked memory was allocated successful, if the kmemleak object
> >> +	 * failed to allocate for some reasons, it ends up with the whole
> >> +	 * kmemleak disabled, so try it harder.
> >> +	 */
> >> +	gfp = (in_atomic() || irqs_disabled()) ?
> >> +	       gfp_kmemleak_mask(gfp) | GFP_ATOMIC :
> >> +	       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
> > 
> > 
> > The comment for in_atomic says:
> >  * Are we running in atomic context?  WARNING: this macro cannot
> >  * always detect atomic context; in particular, it cannot know about
> >  * held spinlocks in non-preemptible kernels.  Thus it should not be
> >  * used in the general case to determine whether sleeping is possible.
> >  * Do not use in_atomic() in driver code.
> 
> That is why it needs both in_atomic() and irqs_disabled(), so irqs_disabled()
> can detect kernel functions held spinlocks even in non-preemptible kernels.
> 
> According to [1],
> 
> "This [2] is useful if you know that the data in question is only ever
> manipulated from a "process context", ie no interrupts involved."
> 
> Since kmemleak only deal with kernel context, if a spinlock was held, it always
> has local interrupt disabled.

What? Normal spin lock implementation doesn't disable interrupts. So
either I misunderstand what you are saying or you seem to be confused.
the thing is that in_atomic relies on preempt_count to work properly and
if you have CONFIG_PREEMPT_COUNT=n then you simply never know whether
preemption is disabled so you do not know that a spin_lock is held.
irqs_disabled on the other hand checks whether arch specific flag for
IRQs handling is set (or cleared). So you would only catch irq safe spin
locks with the above check.

> ftrace is in the same boat where this commit was merged a while back that has
> the same check.
> 
> ef99b88b16be
> tracing: Handle ftrace_dump() atomic context in graph_trace_open()
> 
> [1] https://www.kernel.org/doc/Documentation/locking/spinlocks.txt
> [2]
> 	spin_lock(&lock);
> 	...
> 	spin_unlock(&lock);

-- 
Michal Hocko
SUSE Labs

