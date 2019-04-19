Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95892C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 12:58:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DAE321929
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 12:58:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DAE321929
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7D736B0003; Fri, 19 Apr 2019 08:58:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C060D6B0006; Fri, 19 Apr 2019 08:58:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA7A26B0007; Fri, 19 Apr 2019 08:58:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 535996B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 08:58:16 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so2834707edb.2
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 05:58:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=dumOHHMrWUpgmBfZCxe8bhTY9FgccqbLv62i9JGRHN4=;
        b=lFk15FA0GcklHiOOBayIk3DgGA5bKNkZCD/jXFR9sA8IvNgHnf1rTi/qyrcux8NEH/
         GuXwXvc6ebOoi9r36j6czMrKI5m5YW1bDhcJvvK/LTIQt6a9sqfb2lVr/FC57pRRDRcP
         LwPZNe2Y0dJYtKY72c+riLGl3IWBXp+HqUyff+Z1SF+g4GOF6doT4HjlPrAB5MzOlkR8
         T1BO5pAxIE1l9WjcvgSO1+kGK6wyDmfKfIURztk5n1GchJ2oLzGjvfOPRm1A2mmQNOU1
         1BpBEV+KmvqUeMh2HK5wOiCw31iVFvtw0YgICBYu2+JXz3PJ8Bdz7OOi6M+0/bm4p4yq
         4a9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWwKHq6v/ak/LW26W9Ak7NSHZXBeTxCClx5ejccXbE6OTgpub0u
	S+5nx1FW+oO8ykYv6dX/ulckzE/wVTbPHBwcnGPelNKrGCGWQD53uAWK1gSaVxWYVjOP5EE8Nlw
	SjgXECY2FVAxeVrhN6m8UzyWyG85zF+hQFWGALP6pHZUVAAgIXp7exoyJXwnFVN6bGA==
X-Received: by 2002:a50:cb0a:: with SMTP id g10mr2381529edi.41.1555678695913;
        Fri, 19 Apr 2019 05:58:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDFcEiZrGC0F9rHSG3WyHAj+ePnIrjhpW+PIK0BRb2pjeCRkMSJu3Vgr8k1OD6GQFJDZQX
X-Received: by 2002:a50:cb0a:: with SMTP id g10mr2381498edi.41.1555678695125;
        Fri, 19 Apr 2019 05:58:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555678695; cv=none;
        d=google.com; s=arc-20160816;
        b=Daag9d9c0/DfIZ9cXhIMAXgPTYbSPbLpyRwzAfXg6jeMffHfbKIZ9731afzT4SQbI+
         5leI5StE0R44h/OYZIuf9ywIvOlezRqvfVUV4J6X2bWhDExeFw7QzmqnXBmTeqNPiBVa
         DkFD9AlixSJhLA/VM9Jpie+Hm80iTEFiF90I8Oyxm8A+Hwi8IW2z2QvdRue1qQmtbbFh
         N8EaIvOYLNopTcTp076uH8Zjl5TyLdszTweB9nV3z+3T7x4sZ3XWLWXZcoJsNNAP79nY
         ivL7ZLreVTUneEVdCvyZGTGSwjFy6lg1myEQ5kDe/cpbzu5WOONVr6AwsmoZYDnXHXhJ
         Ey5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=dumOHHMrWUpgmBfZCxe8bhTY9FgccqbLv62i9JGRHN4=;
        b=TMuiXd+lP5nKZRVSbiH1xwFOSNj2ucq9dH7VqTRQXJHPxKbuLPO3tZHBT7ilv1CxsI
         DWxzvUiavejaMc1t/rJSM3M3PnuGemSyTWfDb0lfs6R/CJWmlSSfHzYjvSTKB4lcyDst
         6YaIKW0CIlxIYvnGlyqHXM5duwjAgMR8OxRa8Ab54fH9Zwkif1g9BouSaZVx+sdsVfRw
         8w06oN3vdqr1kS6nxj6YmGEYGnCC1arwWIBB7me2lT60EPk8fdX0JANoby/XHfEfQcqj
         SRbIcCUp8/ibaH7DDtkPe6UMmjMr1hq4lI47GKfDtAxdHqo4wmGeZnfuVzPFNWOaj1Sv
         hhIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si2139904ejr.336.2019.04.19.05.58.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 05:58:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3D28ADD4;
	Fri, 19 Apr 2019 12:58:13 +0000 (UTC)
Subject: Re: [PATCH] mm, page_alloc: Always use a captured page regardless of
 compaction result
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Li Wang <liwang@redhat.com>, linux-mm <linux-mm@kvack.org>,
 linux-kernel@vger.kernel.org
References: <20190419085133.GH18914@techsingularity.net>
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
Message-ID: <e99a54aa-bc21-d3f3-54a5-5da0039216a9@suse.cz>
Date: Fri, 19 Apr 2019 14:54:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190419085133.GH18914@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/19/19 10:51 AM, Mel Gorman wrote:
> During the development of commit 5e1f0f098b46 ("mm, compaction: capture
> a page under direct compaction"), a paranoid check was added to ensure
> that if a captured page was available after compaction that it was
> consistent with the final state of compaction. The intent was to catch
> serious programming bugs such as using a stale page pointer and causing
> corruption problems.
> 
> However, it is possible to get a captured page even if compaction was
> unsuccessful if an interrupt triggered and happened to free pages in
> interrupt context that got merged into a suitable high-order page. It's
> highly unlikely but Li Wang did report the following warning on s390
> occuring when testing OOM handling. Note that the warning is slightly
> edited for clarity.
> 
> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_direct_compact+0x182/0x190
> [ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
>  nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
>  des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
>  libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
>  ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
> [ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1
> 
> This patch simply removes the check entirely instead of trying to be
> clever about pages freed from interrupt context. If a serious programming
> error was introduced, it is highly likely to be caught by prep_new_page()
> instead.
> 
> Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct compaction")
> Reported-by: Li Wang <liwang@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Ah, noticed the new formal resend only after replying to the first one,
so here goes again:


Yup, no need for a Cc: stable on a very rare WARN_ON_ONCE. So the AI
will pick it anyway...

Acked-by: Vlastimil Babka <vbabka@suse.cz>


> ---
>  mm/page_alloc.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..cfaba3889fa2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  	memalloc_noreclaim_restore(noreclaim_flag);
>  	psi_memstall_leave(&pflags);
>  
> -	if (*compact_result <= COMPACT_INACTIVE) {
> -		WARN_ON_ONCE(page);
> -		return NULL;
> -	}
> -
>  	/*
>  	 * At least in one zone compaction wasn't deferred or skipped, so let's
>  	 * count a compaction stall
> 

