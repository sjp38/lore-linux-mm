Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA12C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:23:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC7A2184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:23:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC7A2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C6CA6B0003; Wed, 20 Mar 2019 10:23:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54DBD6B0006; Wed, 20 Mar 2019 10:23:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EE946B0007; Wed, 20 Mar 2019 10:23:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D91236B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:23:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o27so975107edc.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:23:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=PwK3ue9mJR16Ki992gulZ1vVHMsqKCJ9bZ1jmT287ao=;
        b=tL31ZmvpMY2i8NBkM3X9pUqlPxbloGKhWdSh/cDg5i9C2G+daug5mnlOdqHBFqolqC
         sEwjd+AHrBrlczpQNxZKZ9tP0RwsAIri+hxtmg79TecIHXhtNuBKWIm6nIDdfrSTL6I8
         dGWyosgQi1oiHeW4p6BWQCK7K8B+Xmnuaxx4/C0PE4ygdHgRplHWPw8OhXfI5/hf9XQb
         ShzgEaNn+q2LwivvZSva+tNnq8ES05S4jRf994LbPzM/v26GcQEbflpgYGDSMiRFz8cg
         DY5YzvRm0IXildLlPDABElq91OyFo/1ej7vYbNE7aPQc4jflwxdA4C53qMtznMotG3OF
         i3+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV6iO/3KWvjSN77Im5UyUh0Ljjzz8TxOk4h6omKunMg1W9MTiXr
	I3oPsGaJ1pNmH561aUhs304qddUIcevcYBJDhAFFCOwZpP2UCpWN7ycb2VmnxsxeDn8yiTNVhkd
	Mu5cpFUm2xsC7FHXJFNlDfr6fYIRo2hdkXONmSMwspxPTSml6ieGDq002iraWXSYkWA==
X-Received: by 2002:a17:906:d51:: with SMTP id r17mr2414562ejh.109.1553091812445;
        Wed, 20 Mar 2019 07:23:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMw1JEZkLpENSDXf32REJxf7N0pTgoJZ8cRX3e7AKqfnOvUaFxkjMSAvzYxlY+bc0Fn27+
X-Received: by 2002:a17:906:d51:: with SMTP id r17mr2414513ejh.109.1553091811398;
        Wed, 20 Mar 2019 07:23:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553091811; cv=none;
        d=google.com; s=arc-20160816;
        b=bAISgaX+dow0oBQSS4C7i5giZ5Lm3In+eIYCmJyrW/ezUr+xVCk/T28EdxtjLDGNqu
         QTUA1XWF0oaF9B1zA32gNTN2RHjLCavEWHcWSrbR8sQmn40+CRS26LQu03QDDtPHsk7t
         VLQd/DlxCMhWHw/wJBeB8FqqLFAWqiu3AQkaeq+uSiG88QBTPhcIS//6b8Vx8ZCec1sZ
         lrNfjp2+WzkHI3JMYXBIRhAXRscs8R2RTXid9w1evU3Ald/oGMSacwlc7A631PjeFGS4
         EaUZsTia+I7AD/m9qZC+q8McdJiJhB+ZjuvdkBuo/eKI7hWAgLswKprHJaWO3hJxXL37
         eZ0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=PwK3ue9mJR16Ki992gulZ1vVHMsqKCJ9bZ1jmT287ao=;
        b=yuxlxBCXTJB8p7ri7n2anDlv0xS2DHoREn1GS5CsTdia78MLhSA8mLJ+mIf3c9YOgG
         y0AkkOqfYMUFsQ+PL/L01cke2XqGlF6TiZghUH9waKV2r2BpJCM3Z7zPRPdlV6aPRo1m
         VAeOl9OL5nI7d56qMyvQl47UbXh8mkh0vpHYIYvNAuMGu45CGxUB3cqkx5lRDrRZqDxp
         O7e0kXwpyDQQUw9JVoh3LzmjY+V+JSuN3jx1uRDRQvyoPA62+gj3IeJxY3OKT64OzVgU
         dsQjWEMKrwDgwFfJ8dN8myRiJQrW6v1YZzImHWJQ5DO7YLhuR9otfMzBog9LyRc/2Jkg
         N5Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i8si838994eda.408.2019.03.20.07.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 07:23:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 59176ADFB;
	Wed, 20 Mar 2019 14:23:30 +0000 (UTC)
Subject: Re: [PATCH] driver : staging : ion: optimization for decreasing
 memory fragmentaion
To: Zhaoyang Huang <huangzhaoyang@gmail.com>,
 Chintan Pandya <cpandya@codeaurora.org>, David Rientjes
 <rientjes@google.com>, Joe Perches <joe@perches.com>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>,
 devel@driverdev.osuosl.org,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
References: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
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
Message-ID: <ca8bb8d0-3252-f9a7-3bf7-98d5a97e40cf@suse.cz>
Date: Wed, 20 Mar 2019 15:23:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

You should have CC'd the ION maintainers/lists per
./scripts/get_maintainer.pl - CCing now.

On 3/14/19 12:06 PM, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> Two action for this patch:
> 1. set a batch size for system heap's shrinker, which can have it buffer
> reasonable page blocks in pool for future allocation.
> 2. reverse the order sequence when free page blocks, the purpose is also
> to have system heap keep as more big blocks as it can.
> 
> By testing on an android system with 2G RAM, the changes with setting
> batch = 48MB can help reduce the fragmentation obviously and improve
> big block allocation speed for 15%.
> 
> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> ---
>  drivers/staging/android/ion/ion_heap.c        | 12 +++++++++++-
>  drivers/staging/android/ion/ion_system_heap.c |  2 +-
>  2 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
> index 31db510..9e9caf2 100644
> --- a/drivers/staging/android/ion/ion_heap.c
> +++ b/drivers/staging/android/ion/ion_heap.c
> @@ -16,6 +16,8 @@
>  #include <linux/vmalloc.h>
>  #include "ion.h"
>  
> +unsigned long ion_heap_batch = 0;
> +
>  void *ion_heap_map_kernel(struct ion_heap *heap,
>  			  struct ion_buffer *buffer)
>  {
> @@ -303,7 +305,15 @@ int ion_heap_init_shrinker(struct ion_heap *heap)
>  	heap->shrinker.count_objects = ion_heap_shrink_count;
>  	heap->shrinker.scan_objects = ion_heap_shrink_scan;
>  	heap->shrinker.seeks = DEFAULT_SEEKS;
> -	heap->shrinker.batch = 0;
> +	heap->shrinker.batch = ion_heap_batch;
>  
>  	return register_shrinker(&heap->shrinker);
>  }
> +
> +static int __init ion_system_heap_batch_init(char *arg)
> +{
> +	 ion_heap_batch = memparse(arg, NULL);
> +
> +	return 0;
> +}
> +early_param("ion_batch", ion_system_heap_batch_init);
> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> index 701eb9f..d249f8d 100644
> --- a/drivers/staging/android/ion/ion_system_heap.c
> +++ b/drivers/staging/android/ion/ion_system_heap.c
> @@ -182,7 +182,7 @@ static int ion_system_heap_shrink(struct ion_heap *heap, gfp_t gfp_mask,
>  	if (!nr_to_scan)
>  		only_scan = 1;
>  
> -	for (i = 0; i < NUM_ORDERS; i++) {
> +	for (i = NUM_ORDERS - 1; i >= 0; i--) {
>  		pool = sys_heap->pools[i];
>  
>  		if (only_scan) {
> 

