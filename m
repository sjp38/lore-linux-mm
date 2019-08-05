Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A73B6C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BC722067D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 09:14:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BC722067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D73FC6B0003; Mon,  5 Aug 2019 05:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D22C06B0005; Mon,  5 Aug 2019 05:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEADC6B0006; Mon,  5 Aug 2019 05:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAC56B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 05:14:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so51104814edx.10
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 02:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=jDYIaHtZ2SuL/9bWZSctelrOwC63t2IkfcNeCcIYSIU=;
        b=Qy/JEqV5l4+ZLRo6Y53iwrlSRXIysSDicxLowfV9LSpmdIkgX5CGNClq9P+ujuZGde
         u7xmqi8hLf0i9Zb2nK5VlAvRCaUilFfYyln/ua22ODTMXafFaK4fLVk+0ZeJGZjqbN/K
         /pXNTlMiBtbkdW3CyiN/IIwVtMUkBKwl6itTGnzje3D3k8GOzk04CzKE01wIXwOCtQ1R
         dqv45ntPx0k9ZIWI/4vKusxXlz7V44cI0pJ9wtUwR+VN++PKVRERAm0PHt18N9eCphlh
         OGNG/UjTUPH8gRdrM0i6yOHa7vnqikQ0oharOY6NyL5Gz/KTluL3nPYrbW3UvBYC5tcu
         iEuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUxlCwDWeQf6K0zCzxC3NKIiJwVTC/INXWlASCavvKWHv/vprBa
	Rx7Ja3V0XI7l/wcrZ4ZSUy5D7Gh3k4pVhuDZ/Xd9Woj23Cv67/YsvvmD6nIb/AzJuXAUxXu0nB+
	jTHFtcDl93vfWg4bMEfoV+YeS4aQBMlnhxq5KcAQNTXMjIoZe1VKH1Ua0W20bjdGATA==
X-Received: by 2002:a05:6402:6d0:: with SMTP id n16mr49983894edy.168.1564996485028;
        Mon, 05 Aug 2019 02:14:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzD/4wD1+QyswuhgHp8ErAHsJm6A6GZ9bFzqPuN3zCOPgaU5lc96AHdrLmZJclXgnk3U8Zd
X-Received: by 2002:a05:6402:6d0:: with SMTP id n16mr49983847edy.168.1564996484297;
        Mon, 05 Aug 2019 02:14:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564996484; cv=none;
        d=google.com; s=arc-20160816;
        b=KDh8Ve02rlupj3MVTHniZVBeDpydsCm9AEsKfU2IvTrnVLSyiN06Apq6g/VAeqpnR1
         88ZVdCPymr/la8Bw+KT0ehXrUYsNgjlgO4VqLT+P99XYJLMKQvwdTM+m57m+kQRZCA86
         k+bEy6HA+jnJL+RIG5DfG2WmT8zIpLMbouhhUtuF28LLe7O9nFBamsznj6V9+8y6ZebA
         2ugxxejSkoLczuz5P12B6UeNuT834PBWSlRqZokZoK2W5kHKgasCdD4XcCgJxb/Vs0Bd
         U6BaG7x51LXZdqeOhLR863W1wC6/I4dvctuwS/3p0mUb9Qj95HxnfhGcLHKdx6W+tmFF
         ppBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jDYIaHtZ2SuL/9bWZSctelrOwC63t2IkfcNeCcIYSIU=;
        b=ShqQv3n9DFIrVhTDRW8pdnJCm7Jt/hPqRF3CKyNuQFqMHggiTzsKYomg0AtU8rRM1m
         P+JGW+qK5x7mOJh+OT/BJifwjkR/ko2cYMarsP5fRrFKu3LX894ywzfOwa21v4t+FQfM
         ApA6to2hhcUrbeVC0eLDvd/6okCUwBepLiDor+kHRNHIf0/0Bx9trJUXi+9lis4Og5/s
         maye/2u/Q9Vn38pyVgFMd9dwIdZ7XN81NWsTK3UOX6pFncMA2oJZ0qb0a65bMKnU06M3
         weVocgKdWZDwPZPpNRv/EQhv1cMJEPPGSc2H0gq4gQ3gnMsJj6o08iIFdb03PbEn3tKo
         DF6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10si26596720ejx.110.2019.08.05.02.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 02:14:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5E290AE56;
	Mon,  5 Aug 2019 09:14:43 +0000 (UTC)
Subject: Re: [PATCH 2/3] mm, compaction: raise compaction priority after it
 withdrawns
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
 Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
 Andrea Arcangeli <aarcange@redhat.com>, David Rientjes
 <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
 <20190802223930.30971-3-mike.kravetz@oracle.com>
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
Message-ID: <8cdb8901-b1fa-86d4-15a8-379b24d8ed60@suse.cz>
Date: Mon, 5 Aug 2019 11:14:42 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190802223930.30971-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/3/19 12:39 AM, Mike Kravetz wrote:
> From: Vlastimil Babka <vbabka@suse.cz>
> 
> Mike Kravetz reports that "hugetlb allocations could stall for minutes or hours
> when should_compact_retry() would return true more often then it should.
> Specifically, this was in the case where compact_result was COMPACT_DEFERRED
> and COMPACT_PARTIAL_SKIPPED and no progress was being made."
> 
> The problem is that the compaction_withdrawn() test in should_compact_retry()
> includes compaction outcomes that are only possible on low compaction priority,
> and results in a retry without increasing the priority. This may result in
> furter reclaim, and more incomplete compaction attempts.
> 
> With this patch, compaction priority is raised when possible, or
> should_compact_retry() returns false.
> 
> The COMPACT_SKIPPED result doesn't really fit together with the other outcomes
> in compaction_withdrawn(), as that's a result caused by insufficient order-0
> pages, not due to low compaction priority. With this patch, it is moved to
> a new compaction_needs_reclaim() function, and for that outcome we keep the
> current logic of retrying if it looks like reclaim will be able to help.
> 
> Reported-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

There should be also your SOB, IIUC.

> ---
>  include/linux/compaction.h | 22 +++++++++++++++++-----
>  mm/page_alloc.c            | 16 ++++++++++++----
>  2 files changed, 29 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 9569e7c786d3..4b898cdbdf05 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -129,11 +129,8 @@ static inline bool compaction_failed(enum compact_result result)
>  	return false;
>  }
>  
> -/*
> - * Compaction  has backed off for some reason. It might be throttling or
> - * lock contention. Retrying is still worthwhile.
> - */
> -static inline bool compaction_withdrawn(enum compact_result result)
> +/* Compaction needs reclaim to be performed first, so it can continue. */
> +static inline bool compaction_needs_reclaim(enum compact_result result)
>  {
>  	/*
>  	 * Compaction backed off due to watermark checks for order-0
> @@ -142,6 +139,16 @@ static inline bool compaction_withdrawn(enum compact_result result)
>  	if (result == COMPACT_SKIPPED)
>  		return true;
>  
> +	return false;
> +}
> +
> +/*
> + * Compaction has backed off for some reason after doing some work or none
> + * at all. It might be throttling or lock contention. Retrying might be still
> + * worthwhile, but with a higher priority if allowed.
> + */
> +static inline bool compaction_withdrawn(enum compact_result result)
> +{
>  	/*
>  	 * If compaction is deferred for high-order allocations, it is
>  	 * because sync compaction recently failed. If this is the case
> @@ -207,6 +214,11 @@ static inline bool compaction_failed(enum compact_result result)
>  	return false;
>  }
>  
> +static inline bool compaction_needs_reclaim(enum compact_result result)
> +{
> +	return false;
> +}
> +
>  static inline bool compaction_withdrawn(enum compact_result result)
>  {
>  	return true;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d3bb601c461b..af29c05e23aa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3965,15 +3965,23 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	if (compaction_failed(compact_result))
>  		goto check_priority;
>  
> +	/*
> +	 * compaction was skipped because there are not enough order-0 pages
> +	 * to work with, so we retry only if it looks like reclaim can help.
> +	 */
> +	if (compaction_needs_reclaim(compact_result)) {
> +		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
> +		goto out;
> +	}
> +
>  	/*
>  	 * make sure the compaction wasn't deferred or didn't bail out early
>  	 * due to locks contention before we declare that we should give up.
> -	 * But do not retry if the given zonelist is not suitable for
> -	 * compaction.
> +	 * But the next retry should use a higher priority if allowed, so
> +	 * we don't just keep bailing out endlessly.
>  	 */
>  	if (compaction_withdrawn(compact_result)) {
> -		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
> -		goto out;
> +		goto check_priority;
>  	}
>  
>  	/*
> 

