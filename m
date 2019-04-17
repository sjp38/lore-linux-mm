Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5599C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:42:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50A0C20645
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 11:42:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50A0C20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD4AE6B0003; Wed, 17 Apr 2019 07:42:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D82C26B0006; Wed, 17 Apr 2019 07:42:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C243B6B0007; Wed, 17 Apr 2019 07:42:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2DD6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:42:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e22so10993132edd.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:42:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=TGNE0vrGRk5uFfhyxeJb4uSj+bv/zLUFbP10HHcpebA=;
        b=L5PEjZl8gv17GFD6+9eytV83Ar97TAb8tFaXzXDSJUv7fIeBGW3cWYwwYDBMpxCEdT
         f1oLzAHUM8JGdvGreMUSyJxH/LYy5jBGiC6P4nsTtlfjAyDQPjTjOiTup3KI/pOd6hWG
         8RgkzUVPftqCfm0dH/3vz9TiWYklNgvwVttwGHaRpd7cMvuNVytkpJimUKmwzTfLxJWY
         hDRGdou/QCw9G4QvLJbiCeKPdNptI6+jKol9mOnGp9rrNaDq+q3nQKUjjWQUhb6oPwrr
         Hcj8544kxMbUdkd+fOM/611T5wgATZi2fH9uiEHClbHCEpkcTcA71X32Ru2/5DCpNTyQ
         Rjgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVFF6zbLGwwf3OkwWmqmiN3UxWDkKnX5ROEfHei49oTG0r15UvO
	+InhdhcIUsu3s3irFE7X7HYp7XAtjW/T4YABWooIyx0UlPjaW0o6vb9i7iRIDBXsby6rpDoOXR0
	MrKcR4hpajJWqLT1bsNGVgMRWXuDei7SfSi+ATc4lGYu96XhF2BkRFdXcN1sS8NUTPA==
X-Received: by 2002:a17:906:9157:: with SMTP id y23mr47936467ejw.240.1555501366962;
        Wed, 17 Apr 2019 04:42:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwrMU4yJ8vFqoBhpRGukaBDKbeYVR2AQr9ElCz5gnVSFe4Bo3j9V8cUd8gAnWIuxYN+SL2
X-Received: by 2002:a17:906:9157:: with SMTP id y23mr47936424ejw.240.1555501365988;
        Wed, 17 Apr 2019 04:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555501365; cv=none;
        d=google.com; s=arc-20160816;
        b=ZX3IsWcbsfQUnaSbnqysp0iuTvzwwIlSQEtNWw6gsCH3kY9D/d36jDHgo6RZlcq/ed
         B1perF+0EeUWd35iZ03OLXTi28jSJpuSgR8sR1ALW5fyVzWYu7dCe2SQ9vGLunfVU8nC
         wZD2IdPNNoANGQx8Nle+emOhZWSo11NRgM4RMmMMLVw4fuwjhYRTW0zBpvz4QuE8A+u/
         4z+pRxyjgCIdXhAYaO90ASXPaODCfLrz4svMNccl2bPN9VGu57wiI0CWVmsMRdSr+x2M
         Ztanu7VusRoBZHb3JqQorT1LDSuHO0zT3MI0Y7UUO2ULPiSNJUCN+uB9MW+VyTmmsch0
         q8DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=TGNE0vrGRk5uFfhyxeJb4uSj+bv/zLUFbP10HHcpebA=;
        b=dL8NJbrD3DMD9Bcm5OanKUi290aRvvutlSQb5tBOIBCW0VsjDeCOhyuPYInQ/t7q8M
         BzupDF77Q/4CBSa49AUSCahxIqcK+/UCSIewiM42XxuZCj1JSgnk1bbWKUU0BW8GL4gT
         wz00t5mOsXlST8wERtJyX3lSTJ40qwND5qpkAHlBi4N62Fz7SokXjRFOJq1VRpH/jZFn
         pevST4DdispxXCceS3Gao6AFZYONUqPANl321H5+C1I4PWRDA/u/Wvi81bDyfCU/8RCp
         QVUESZ/gcI21j9bcCUjwJiUx07lyoNafONSX0EAa4OLf4AwpJRp/IYfJ09CxseJ2x22m
         m6mw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a25si3866231edr.41.2019.04.17.04.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 04:42:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5FF40AE5E;
	Wed, 17 Apr 2019 11:42:45 +0000 (UTC)
Subject: Re: vmscan.c: Reclaim unevictable pages.
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kernelnewbies@kernelnewbies.org, mhocko@kernel.org, minchan@kernel.org
References: <CACDBo57pEVRjOBf0yLMQ+KuGPeOuFcMufGVzjPJVnwfLFjzFSA@mail.gmail.com>
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
Message-ID: <9b1ace64-c4cc-b0b3-f864-c96124137853@suse.cz>
Date: Wed, 17 Apr 2019 13:39:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CACDBo57pEVRjOBf0yLMQ+KuGPeOuFcMufGVzjPJVnwfLFjzFSA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/6/19 7:59 AM, Pankaj Suryawanshi wrote:
> Hello ,
> 
> shrink_page_list() returns , number of pages reclaimed, when pages is
> unevictable it returns VM_BUG_ON_PAGE(PageLRU(page) ||
> PageUnevicatble(page),page);
> 
> We can add the unevictable pages in reclaim list in
> shrink_page_list(), return total number of reclaim pages including
> unevictable pages, let the caller handle unevictable pages.
> 
> I think the problem is shrink_page_list is awkard. If page is
> unevictable it goto activate_locked->keep_locked->keep lables, keep
> lable list_add the unevictable pages and throw the VM_BUG instead of
> passing it to caller while it relies on caller for
> non-reclaimed-non-unevictable  page's putback.
> I think we can make it consistent so that shrink_page_list could
> return non-reclaimed pages via page_list and caller can handle it. As
> an advance, it could try to migrate mlocked pages without retrial.
> 
> 
> Below is the issue i observed of CMA_ALLOC of large size buffer :
> (Kernel version - 4.14.65 With Android Pie.
> 
> [   24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) ||
> PageUnevictable(page))
> [   24.726949] page->mem_cgroup:bd008c00
> [   24.730693] ------------[ cut here ]------------
> [   24.735304] kernel BUG at mm/vmscan.c:1350!
> [   24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM

Please include full report including the full stacktrace, kernel version
etc etc.

> 
> 
> Below is the patch which solved this issue :
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index be56e2e..12ac353 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
>                 sc->nr_scanned++;
> 
>                 if (unlikely(!page_evictable(page)))
> -                       goto activate_locked;
> +                      goto cull_mlocked;
> 
>                 if (!sc->may_unmap && page_mapped(page))
>                         goto keep_locked;
> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
>                 } else
>                         list_add(&page->lru, &free_pages);
>                 continue;
> -
> +cull_mlocked:
> +                if (PageSwapCache(page))
> +                        try_to_free_swap(page);
> +                unlock_page(page);
> +                list_add(&page->lru, &ret_pages);
> +                continue;
>  activate_locked:
>                 /* Not a candidate for swapping, so reclaim swap space. */
>                 if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||
> 
> 
> 
> 
> It fixes the below issue.
> 
> 1. Large size buffer allocation using cma_alloc successful with
> unevictable pages.
> 
> cma_alloc of current kernel will fail due to unevictable page
> 
> Please let me know if anything i am missing.
> 
> Regards,
> Pankaj
> 

