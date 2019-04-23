Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8AFC282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:34:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40BDA20674
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:34:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40BDA20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C03676B0003; Tue, 23 Apr 2019 02:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8A2C6B0006; Tue, 23 Apr 2019 02:34:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A03A46B0007; Tue, 23 Apr 2019 02:34:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4528E6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:34:00 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j9so3051434eds.17
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 23:34:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=BwXTUc1q5CtW2peENvu8Y7l7bAFHeldqtmOljmzYOB8=;
        b=RV764Ak8r7VZYP6BLBmEQnm2Mvy8NfEfTsbsOb1TOKXmT8iaxiFFWeWbzI+yDUR6QA
         Eq3S/GCUhLpK1kvjbUalXFOnpPAvKB7x69IlxP2IxbCuz8ZGDDSeYSRHxnVDmLUc8VFN
         QSL741eoDkaaVNhU6Sg7rC3bXoj4Qk7JWxpfLzMEIbhZ6tXhHIPjaZOFZd1Cv1NgF144
         SLm+RpZYwjzPBZbrUlkOs0QR7WB4WrVlHQjYdeTIxjh0XD2vefjaP1GKpa5H/Fvx4jav
         ePY50SNtSEf8CGPljjHGRR+iT8TWc0qpwC6VJvHgPCvM0j0OlQwBGiIKXhlmQIcWX+dI
         Q5FA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUOIEzMfR+uTyGeYXYMQ+ZG9R355kE4hQSmBoi5pz5fmfRw68Ul
	bjd5CoNVxvwHkLGRlioi9AHQH3LvqRO9LodPZ/YZX/6aUch9Uik1cNm5NuqYd+EVFYMA8MQ05uH
	DUZB7yf7ngUoFjNJIlURN1S5bGnKA46h7gx0+zFVxxy2xpmEuWLPwLPeAv+7EYUBYdQ==
X-Received: by 2002:a17:906:f03:: with SMTP id z3mr11704317eji.280.1556001239802;
        Mon, 22 Apr 2019 23:33:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPEzv3+JqKxgd2tF7PuZZf/NObYNPG01BtPCeFbRp4EI2OLnYZFNki0IggATRwHhBsDl9m
X-Received: by 2002:a17:906:f03:: with SMTP id z3mr11704277eji.280.1556001238843;
        Mon, 22 Apr 2019 23:33:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556001238; cv=none;
        d=google.com; s=arc-20160816;
        b=DTUo3rxeCP81ew1Z47pipQxZ/z4MqEn6QZyMGwP330EyC5w1MIAU9CbKX59PwSgeQ/
         u8i3wNmV9i6hDc4XN/1zD2T+htZbbj1319Xv1FTzx2CAR92Dhjy3uc+kBiJaUbAjqwY5
         psm7/VfQdrwjoinunsPolqgkTjd6qunkxApcNlWIpBq45zHFDiwzWz8BbZPcOJLnErle
         Yb899seVrskTwWaYWSSZwEvGkpmSF7QLq4oCWPzINOo2U2xyp5Ff5oysJ86o6SnWgLEQ
         y9FyqbbsgN96GAilbb+RYtRrsYRZj5D9EiYJgQyX4tZvXiAvuyTSCi+7SLgEHkdyqJ+Q
         tjdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=BwXTUc1q5CtW2peENvu8Y7l7bAFHeldqtmOljmzYOB8=;
        b=otogm0oT2sqZJBZbwV3C+lSMy8Hw0RUQmUJVGm2YELc0Bh9eahCIDzhMs9NvNvT4Jb
         T6rdWYHgGm/SnTWeYF+Ve56EfgCe2UJd4+qzJ/ZeexmnJeM2b78rtEr63QaHTBg0hNX+
         6xTQtRCP44PSz3wjykJLcfeX5NLKqx8edJztvjIDahiNX2nYDkgSWhdgepcoFfr96KxE
         kljPhjjjXfv/VPMqkpJWlJWJuvGAGPrw1KoVir91WsJ2QiQuYvhrEZA7DR8JKFZOVEmk
         qh6fkeROxEADsHOkv5Pyv5qE5T2uijI3XU+CQPASYw8xZWZNio6VB30jpcFSsi2vpQE0
         I20g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h14si342505edk.382.2019.04.22.23.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 23:33:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED2F8AD72;
	Tue, 23 Apr 2019 06:33:57 +0000 (UTC)
Subject: Re: [PATCH] mm: Do not boost watermarks to avoid fragmentation for
 the DISCONTIG memory model
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 linux-parisc@vger.kernel.org, linux-mm@kvack.org,
 LKML <linux-kernel@vger.kernel.org>
References: <20190419094335.GJ18914@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <f3c49c8d-6723-3d97-bcdb-ff7ffa84998a@suse.cz>
Date: Tue, 23 Apr 2019 08:33:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190419094335.GJ18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/19/19 11:43 AM, Mel Gorman wrote:
> Mikulas Patocka reported that 1c30844d2dfe ("mm: reclaim small amounts
> of memory when an external fragmentation event occurs") "broke" memory
> management on parisc. The machine is not NUMA but the DISCONTIG model
> creates three pgdats even though it's a UMA machine for the following
> ranges
> 
>         0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
>         1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
>         2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
> 
> From his own report
> 
> 	With the patch 1c30844d2, the kernel will incorrectly reclaim the
> 	first zone when it fills up, ignoring the fact that there are two
> 	completely free zones. Basiscally, it limits cache size to 1GiB.
> 
> 	For example, if I run:
> 	# dd if=/dev/sda of=/dev/null bs=1M count=2048
> 
> 	- with the proper kernel, there should be "Buffers - 2GiB"
> 	when this command finishes. With the patch 1c30844d2, buffers
> 	will consume just 1GiB or slightly more, because the kernel was
> 	incorrectly reclaiming them.
> 
> The page allocator and reclaim makes assumptions that pgdats really
> represent NUMA nodes and zones represent ranges and makes decisions
> on that basis. Watermark boosting for small pgdats leads to unexpected
> results even though this would have behaved reasonably on SPARSEMEM.
> 
> DISCONTIG is essentially deprecated and even parisc plans to move to
> SPARSEMEM so there is no need to be fancy, this patch simply disables
> watermark boosting by default on DISCONTIGMEM.
> 
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Tested-by: Mikulas Patocka <mpatocka@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  Documentation/sysctl/vm.txt | 16 ++++++++--------
>  mm/page_alloc.c             | 13 +++++++++++++
>  2 files changed, 21 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 6af24cdb25cc..3f13d8599337 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -866,14 +866,14 @@ The intent is that compaction has less work to do in the future and to
>  increase the success rate of future high-order allocations such as SLUB
>  allocations, THP and hugetlbfs pages.
>  
> -To make it sensible with respect to the watermark_scale_factor parameter,
> -the unit is in fractions of 10,000. The default value of 15,000 means
> -that up to 150% of the high watermark will be reclaimed in the event of
> -a pageblock being mixed due to fragmentation. The level of reclaim is
> -determined by the number of fragmentation events that occurred in the
> -recent past. If this value is smaller than a pageblock then a pageblocks
> -worth of pages will be reclaimed (e.g.  2MB on 64-bit x86). A boost factor
> -of 0 will disable the feature.
> +To make it sensible with respect to the watermark_scale_factor
> +parameter, the unit is in fractions of 10,000. The default value of
> +15,000 on !DISCONTIGMEM configurations means that up to 150% of the high
> +watermark will be reclaimed in the event of a pageblock being mixed due
> +to fragmentation. The level of reclaim is determined by the number of
> +fragmentation events that occurred in the recent past. If this value is
> +smaller than a pageblock then a pageblocks worth of pages will be reclaimed
> +(e.g.  2MB on 64-bit x86). A boost factor of 0 will disable the feature.
>  
>  =============================================================
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cfaba3889fa2..86c3806f1070 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -266,7 +266,20 @@ compound_page_dtor * const compound_page_dtors[] = {
>  
>  int min_free_kbytes = 1024;
>  int user_min_free_kbytes = -1;
> +#ifdef CONFIG_DISCONTIGMEM
> +/*
> + * DiscontigMem defines memory ranges as separate pg_data_t even if the ranges
> + * are not on separate NUMA nodes. Functionally this works but with
> + * watermark_boost_factor, it can reclaim prematurely as the ranges can be
> + * quite small. By default, do not boost watermarks on discontigmem as in
> + * many cases very high-order allocations like THP are likely to be
> + * unsupported and the premature reclaim offsets the advantage of long-term
> + * fragmentation avoidance.
> + */
> +int watermark_boost_factor __read_mostly;
> +#else
>  int watermark_boost_factor __read_mostly = 15000;
> +#endif
>  int watermark_scale_factor = 10;
>  
>  static unsigned long nr_kernel_pages __initdata;
> 

