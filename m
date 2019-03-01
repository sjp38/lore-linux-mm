Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ACA8C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E42882084F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:04:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E42882084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65A638E0003; Fri,  1 Mar 2019 08:04:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 609598E0001; Fri,  1 Mar 2019 08:04:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D1118E0003; Fri,  1 Mar 2019 08:04:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EAA468E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 08:04:40 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so9873058eds.12
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 05:04:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=rhCRJG5VeZdbbL7GpBA127G1YSKF8NzZMlTkUyVLjm8=;
        b=TmR3JeR7wjspw8xYY4vitctcMX3Q0DFBgemDyHArdVygegFNIFq9IYrX1kAVxNqkdA
         R+p1YcHkEZsZuxKOw0IlhVHcIIqeeEapWVvEQiJqiv8YVFYDlZsA8YOL8UOsAnWUb9Ck
         ybD9G0H8gMF8zNyHE2nBHy17yBa1r713ndlLLziMGTGagt6+cMIVZOrzMPXk/nfF5L3b
         xs12e05I3sE4f+Hv0U2PAyHRKY4yRFioCr7NSMwPOsxuy4D3I/NeAJjE23/nzNbd9Lgd
         GX5zuADu7QnfyMXFlsvd/otO5ErQ9U8PnRgd8YjYquE/Qa7QFmDiIafiBXfyEQef1JqG
         BOcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVx1YgcvlalSgd9E73Oz5hsy3tE4vKbxLAcWuuq08ekU75Llub4
	UUo3tTusMnR8vQ9GnXIcoak8HXvFazxJ+JXTL+w2mLPe1shtxZpIfCILZe7JWcYW9FdCNSeseg0
	ePuk6Fr/JK5Ge1j/11QN9qfuXUQMeEc9L3M6bS0CWLEqGvYcAtzMG+I2iOuDDV7h9Vw==
X-Received: by 2002:a50:b4f7:: with SMTP id x52mr4297950edd.81.1551445480526;
        Fri, 01 Mar 2019 05:04:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqwhdy1MxE7ygRwftSMVgMOKhLd52a1uknR9IG2FGhToydwQuxPBfKnS7fz8fUsv2vEYVPfE
X-Received: by 2002:a50:b4f7:: with SMTP id x52mr4297901edd.81.1551445479636;
        Fri, 01 Mar 2019 05:04:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551445479; cv=none;
        d=google.com; s=arc-20160816;
        b=0f0LUH5qF9XUfmebA/oUv6qefjqpNDLLglDfamuctd6Gfw6mwVLIWJfZmT3I+BU93W
         mEgH6PiXsv9RgxVC1j5I7OyBb8g2DbL1n/L8DfSNXl8mhDw0uTM/YdCLWCiROuZ0w1ba
         L7eI3bxVvYWQDWZeuOt7TZKpsNfevFA0bv37BUK1H794TZuXH9bzCWvwQF0yF9IuUNrm
         TE1+ycI0btC8licaP9ibkuQoF9EiYoFBRZiMTeTsdn3WUv8VDpylr4Kc+dhFvh/SVI8M
         eUhT9w/5D61OluOGubavU283OQGSG2ZApD+irjI2K1RFHOL1wuIhwE26I8qkhTlxS77h
         zSlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=rhCRJG5VeZdbbL7GpBA127G1YSKF8NzZMlTkUyVLjm8=;
        b=FM3L+pNWwgJlKXYXfPQF/hNG33YBjAdCmk+S4QPswOg9gNJFpwjNL9rulSaXhZnee3
         Q4kttzNJPEqlp9AZxjwNP7Aj8Bc+rCl1LxtvWWatJ9Tt8/EMg247veC2n94LvbZHJdW/
         7KPK67BXqaQuj/2gi/Mcaoi/79AyrBuNxKC+BKKQBUqDroSgCM8aukGkewzubOXUE81u
         8KjLxE+HsDwzGadOnqUJD7CzqhQJLUC7FLUAXg2Prv4ATRyyLdkSl3YWHMLL2C3VSr+L
         eE57/QBjZq3EVum3cK8laRdj1neU0z96o9GFxmHS7Y5uVhwNyJughaE7U8tNWP8m4Ne0
         6SEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2si1880824ejx.304.2019.03.01.05.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 05:04:39 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8509AA71;
	Fri,  1 Mar 2019 13:04:38 +0000 (UTC)
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
To: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 Hugh Dickins <hughd@google.com>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@suse.com>
References: <20190301035550.1124-1-aarcange@redhat.com>
 <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
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
Message-ID: <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
Date: Fri, 1 Mar 2019 14:04:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/1/19 10:37 AM, Kirill A. Shutemov wrote:
> On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
>> Hello,
>>
>> This was a well known issue for more than a decade, but until a few
>> months ago we relied on the compiler to stick to atomic accesses and
>> updates while walking and updating pagetables.
>>
>> However now the 64bit native_set_pte finally uses WRITE_ONCE and
>> gup_pmd_range uses READ_ONCE as well.
>>
>> This convert more racy VM places to avoid depending on the expected
>> compiler behavior to achieve kernel runtime correctness.
>>
>> It mostly guarantees gcc to do atomic updates at 64bit granularity
>> (practically not needed) and it also prevents gcc to emit code that
>> risks getting confused if the memory unexpectedly changes under it
>> (unlikely to ever be needed).
>>
>> The list of vm_start/end/pgoff to update isn't complete, I covered the
>> most obvious places, but before wasting too much time at doing a full
>> audit I thought it was safer to post it and get some comment. More
>> updates can be posted incrementally anyway.
> 
> The intention is described well to my eyes.
> 
> Do I understand correctly, that it's attempt to get away with modifying
> vma's fields under down_read(mmap_sem)?

If that's the intention, then IMHO it's not that well described. It
talks about "racy VM places" but e.g. the __mm_populate() changes are
for code protected by down_read(). So what's going on here?

> I'm not fan of this.
> 
> It can help with producing stable value for the one field, but it doesn't
> help if more than one thing changed under you. Like if both vm_start and
> vm_end modifed under you, it can lead to inconsistency. Like vm_end <
> vm_start.
> 

