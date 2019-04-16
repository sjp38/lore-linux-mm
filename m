Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A15AC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:19:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2CF220656
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:19:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2CF220656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DC1D6B02B6; Tue, 16 Apr 2019 11:19:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 863FD6B02B8; Tue, 16 Apr 2019 11:19:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 704686B02B9; Tue, 16 Apr 2019 11:19:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 199996B02B6
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:19:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f7so11157659edi.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:19:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=jSvblVTgD9PZC+8zXsx7UqN9RF1fxq6fFo6XUrEpZjg=;
        b=A1lwGn6m6/Bss2wUH3lL+Yy5KPKTfM6Z7UzXM5dkWT6SHfnevAaOCi/jlPK3JqYKCf
         m25K6DzTCvTI+FZLr+ENNOijtLwqp1viIgJj8azPJi6ZU7nNMrIBr5zZ5ThKNOua+o85
         4Ub5wIGnqnLYi0NsiZzUo6BR8PiRJtcX4J9bcecd5t+IhCUWnEZEoQlXxWTipF5gGwyA
         YPGeLekNDpvAwGZ/lQ5UOOtYwSjLVUG20zSWJU1lg/kLZlexuSDtHSRr+OwNOatQZ3/u
         DftOqS0W7FuKC8HYWQo8Mj+8XqAcwQlcRnfKqintgkGhmeeV1IS3EabpREfQ4DIGUHX9
         AkcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAV6+qVGNCbCrj34SlrhY5VSaaqH4Z2yaByb2rkC4VdVeUhS7eKg
	K8qD5uSNzROP53irjT+cx1Jn8k4cEfRi6eHgIdGWXcuUuXaGyRqzuLaASzdEU3KsUmiOqfq943B
	sCPUJgnHowTfyQEGrQOmap+Fsi/tvijoE8x/KC569uSDqeR+1NN6XoZSlp4A0D3Syzw==
X-Received: by 2002:a50:a3b1:: with SMTP id s46mr49441993edb.99.1555427974583;
        Tue, 16 Apr 2019 08:19:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBljArd//BvoP0cBGMw2y2vq5fY/5hC23Db76/lxeceBFWybH77YdW5m2KxepJMhptWItD
X-Received: by 2002:a50:a3b1:: with SMTP id s46mr49441950edb.99.1555427973685;
        Tue, 16 Apr 2019 08:19:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555427973; cv=none;
        d=google.com; s=arc-20160816;
        b=a0l62AqP8eyqU3G/CczOyJRF4NNn9q5l3lORCwCV0L1F9PyGI3VXtIl1z7pRRZzwyX
         a8Mlc4QCviV0/TwKaY+gT2usn8sy2dbikGbkJpmZ6kXI2ankPmNMQyoxHNbWLqGNKR6H
         ouq+jvyb3rWisUaVedrD9P8XTigM+xwA9zfvZu9hESSgF8HYZSqMrckeCUvexbtLaZhX
         6gSdRi3vHmQfk8zgq2c2UchAZoj52MJxVd7uTkc19CC6hFpkvaLhizDb9SXZp6TYlseU
         X3lbctm3effLbDjXdByZC7IqyNnzuLxDdgcMu7L92u9HJrjrxvvK/awl9BeKh9gpSxRP
         Qa4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jSvblVTgD9PZC+8zXsx7UqN9RF1fxq6fFo6XUrEpZjg=;
        b=knsnmMhRBW+DoZe4mK57279wQNKDiuY1s+xZ0c2qHPH+taUXdRzbbiGPGBz1mbSuK9
         lZ7Hlt7NY2h59O243iuiWevmj2Ng1EQI+tq6A179+TQg8taJiBM0mUirfSrdeGXoG0Wr
         FOYDEr7tbfv/P6sUahIpHp6CiJh8JXNhIjKLwHryIo2Ub5j+Zxv3lIIDPQKISucWZY2u
         LmYfcj4lFUkQh6FPvs4UdfsbLn62WNAMJ4ceNYJWmezlxXZ5Ln125CyQAJfU2wff/1WI
         gX3JBMj+3FyvsjezedX4qndtRfVirnpb8cUe/XZy5ndGRBNwVld61rxBPejC+Rwwx9un
         1BMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si784952ejr.43.2019.04.16.08.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:19:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 92646AE5D;
	Tue, 16 Apr 2019 15:19:32 +0000 (UTC)
Subject: Re: [patch V5 01/32] mm/slab: Remove broken stack trace storage
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>,
 Sean Christopherson <sean.j.christopherson@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>,
 David Rientjes <rientjes@google.com>
References: <20190414155936.679808307@linutronix.de>
 <20190414160143.591255977@linutronix.de>
 <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com>
 <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de>
 <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble>
 <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de>
 <20190415161657.2zwboghblj5ducux@treble>
 <CALCETrXLa9ec8Lcz2WPML8qQiStpTtDSAGkW=Rv9bMSiunNNMw@mail.gmail.com>
 <alpine.DEB.2.21.1904152320540.1806@nanos.tec.linutronix.de>
 <612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz>
 <alpine.DEB.2.21.1904161608570.1685@nanos.tec.linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <20effcc8-6d4d-bdd8-379e-8eed5624542c@suse.cz>
Date: Tue, 16 Apr 2019 17:16:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1904161608570.1685@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 4:10 PM, Thomas Gleixner wrote:
> kstack_end() is broken on interrupt stacks as they are not guaranteed to be
> sized THREAD_SIZE and THREAD_SIZE aligned.
> 
> As SLAB seems not to be used much with debugging enabled and might just go
> away completely according to:
> 
>   https://lkml.kernel.org/r/612f9b99-a75b-6aeb-cf92-7dc5421cd950@suse.cz
> 
> just remove the bogus code instead of trying to fix it.
> 
> Fixes: 98eb235b7feb ("[PATCH] page unmapping debug") - History tree
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: linux-mm@kvack.org

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

> ---
> V5: Remove the cruft.
> V4: Make it actually work
> V2: Made the code simpler to understand (Andy)
> ---
>  mm/slab.c |   22 +++-------------------
>  1 file changed, 3 insertions(+), 19 deletions(-)
> 
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1470,33 +1470,17 @@ static bool is_debug_pagealloc_cache(str
>  static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
>  			    unsigned long caller)
>  {
> -	int size = cachep->object_size;
> +	int size = cachep->object_size / sizeof(unsigned long);
>  
>  	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
>  
> -	if (size < 5 * sizeof(unsigned long))
> +	if (size < 4)
>  		return;
>  
>  	*addr++ = 0x12345678;
>  	*addr++ = caller;
>  	*addr++ = smp_processor_id();
> -	size -= 3 * sizeof(unsigned long);
> -	{
> -		unsigned long *sptr = &caller;
> -		unsigned long svalue;
> -
> -		while (!kstack_end(sptr)) {
> -			svalue = *sptr++;
> -			if (kernel_text_address(svalue)) {
> -				*addr++ = svalue;
> -				size -= sizeof(unsigned long);
> -				if (size <= sizeof(unsigned long))
> -					break;
> -			}
> -		}
> -
> -	}
> -	*addr++ = 0x87654321;
> +	*addr = 0x87654321;
>  }
>  
>  static void slab_kernel_map(struct kmem_cache *cachep, void *objp,
> 

