Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFAE8C43612
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 20:58:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 608342183F
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 20:58:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="ISh828SP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 608342183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0098E8E0002; Fri, 11 Jan 2019 15:58:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA448E0001; Fri, 11 Jan 2019 15:58:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE9DF8E0002; Fri, 11 Jan 2019 15:58:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA418E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:58:37 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id u20so11245883pfa.1
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:58:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:newsgroups
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=LzUuvRIYUaY7dDi9dT5pV4RhzRHJzG9HkZDrLehUx8E=;
        b=Wxtsy0GwFAAFE9jao5yGdYrq8Ooy2MtDLX8EXJxy3regn8sv03iv5Yq/skeN16+pmr
         Entk5UtXZrsBeDFeijzjJTxqfjqbvz9aDSE9xDczVEotGWaXpsqz/3PXYWTFXK5IGtx1
         2MO8YZIfI6EYvrfWKTQXm7y6+FPHVSSSEJocX2YcVLIi7Z8Spn6bGbu1Yf76l219mUrl
         UnM9PN1OuIdHdi0Udf4EUehub8dCZgMyGRjw4yA/Vak5Jo6vMuVJZ414RgUAE4nAu6uW
         b5+PVy8Ca5qAmJm/tAegpAjtvuwOgrOBi0QuL6jJU6X4YjNGySq9+ijWGEa6ZGfMNfeB
         Z+1A==
X-Gm-Message-State: AJcUukcUvmZmkM6dPvY5o1XB5pAVMOfH3ScFs14lu1eFNdbAbj6ZfZh+
	UZUFDePucIfiRv07mQfnTJyUy/brCMryRfU+EheFVTTkraaXenh8prKomb3DOqjD1LeZMbW5z/3
	j11YvTJjS/t9H/PEye6NyarkfYiPK5LjLsOYOGkRsNpP+a+mNl9uD6qg428I8WL/e0A==
X-Received: by 2002:a62:b15:: with SMTP id t21mr16696520pfi.136.1547240317226;
        Fri, 11 Jan 2019 12:58:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5gCdMQ/2yZRJSA7bqj+1idQHpPRNZpA/FYPt5hid/HL8ZS+F0MBpuEEHQ9QgAM2uTo6BvC
X-Received: by 2002:a62:b15:: with SMTP id t21mr16696476pfi.136.1547240316322;
        Fri, 11 Jan 2019 12:58:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547240316; cv=none;
        d=google.com; s=arc-20160816;
        b=bjt0Jlt9qA2DFUNHPuGjUBrxeb7G6rnAcc5Pg9bgcBzxBh7QQ9rhl4aCDK+6o1FTzV
         mvQHmYugk7MrM+TW+EcgLQRzHyy+wlftNB9b/AXH9RYEkqHbu2amZ+utgE8rXuf1NWU+
         blgLcZVeziAQW9ihHuEBcJu+M1CQ0mq1+gy47gErSV2PDnkHYjFN1ow8aqgrZ/uM0XRh
         iDKr7SzumP5kOS8QZXoko/9+4tXD06Cl/JcXYQ8lh44kHWwxJbfRmZk8jRGruygDjwtm
         ZEpMxMAHcmKu1XHaHIk2VhiO55VLCI8Rot9wmH8xqj4Cz7Rgai3PB2McrHWPjVkRYe0c
         FwQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references
         :newsgroups:cc:to:subject:dkim-signature;
        bh=LzUuvRIYUaY7dDi9dT5pV4RhzRHJzG9HkZDrLehUx8E=;
        b=FG790yQrIAPnEk39oLn2n+k8LiIduQLkxVm+F3sNcHRUN/mI0K/EIFFS4+Wwzhv24C
         Fwg3V0KA1CkL2uz9PQsIDJ4zgEfWihONvkipXhTDlPrgSUItwzsCGrUU3C9GisSRfyhf
         9pAL+JgYEUXunOQMZ0SLnXELE8xMxxc6fyjoR5UbEFnJHWKLVIN6pFjsXZybMWXIOSEB
         1z7zO20GAdT3NDoSN9URBdoDDqd0I/csZtiXOoNubrLo0GvqkGx++aH7l0DXQdKNIUAa
         Axkpfb+DoWY0jwXdaeQBY/MHMHoJuneqLqWovTSxjfdXiFmoBlsh4AEr8EugSUk2m/j1
         /N+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=ISh828SP;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id l7si15083723pgk.169.2019.01.11.12.58.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 12:58:36 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=ISh828SP;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost3.synopsys.com [10.12.238.238])
	by smtprelay.synopsys.com (Postfix) with ESMTP id 34B0B24E1024;
	Fri, 11 Jan 2019 12:58:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1547240315; bh=KjM2U8zzXjSYEEa9IM0sDfxFpgxQOltZA+m4yd6wiqk=;
	h=Subject:To:CC:References:From:Date:In-Reply-To:From;
	b=ISh828SPar9UKMdDEjE8Wdb2T3qkAGlNdSoyJP8tsP3sOULHigyLbanTW2Js9zoh4
	 YLhE5ar4nzjkb3n5vMEtLzHhGxKUDdQsRzXaX1NxjHNnw6Ytliday5/GVT9m1iLOQf
	 E2HSA537Wxat4QRAYjs8IoYYM1YyTay7SSMwsKEY001A2I1NKpJO4KoUe9TkKJUzKq
	 EY79+X7VqSD9iLlWMrVdBwD/8DIrlRtf5e9WlVrwrtsAJd6U1J6RNBk0/RIQ/kTh/Y
	 QsmsbyiYYcWeCuoRD27/RyVyVKmZOfGOsihJPXap/ICvEi2ZQOPxTX5HNcRhX6D/r3
	 b31j2wSali7tw==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	by mailhost.synopsys.com (Postfix) with ESMTP id BDD2D37F9;
	Fri, 11 Jan 2019 12:58:34 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 12:58:34 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Sat, 12 Jan 2019 02:28:31 +0530
Received: from [10.10.161.70] (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Sat, 12 Jan 2019 02:28:31 +0530
Subject: Re: [PATCH 3/3] bitops.h: set_mask_bits() to return old value
To: Peter Zijlstra <peterz@infradead.org>
CC: Mark Rutland <mark.rutland@arm.com>, Miklos Szeredi <mszeredi@redhat.com>,
	Jani Nikula <jani.nikula@intel.com>, Will Deacon <will.deacon@arm.com>,
	<linux-kernel@vger.kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>,
	<linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-snps-arc@lists.infradead.org>, Ingo Molnar <mingo@kernel.org>
Newsgroups: gmane.linux.kernel.arc,gmane.linux.kernel,gmane.linux.kernel.mm
References: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
 <1547166387-19785-4-git-send-email-vgupta@synopsys.com>
 <20190111092408.GM30894@hirez.programming.kicks-ass.net>
From: Vineet Gupta <vineet.gupta1@synopsys.com>
Openpgp: preference=signencrypt
Autocrypt: addr=vgupta@synopsys.com; keydata=
 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
 hhqBJlyU6MVUa6vZNv8E
Message-ID: <d36b8582-184a-37d2-699f-04837745b70a@synopsys.com>
Date: Fri, 11 Jan 2019 12:58:22 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190111092408.GM30894@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111205822.4-KS2-v8Zke1jCU4y2iftgr7vivlRj19Y9sCWnq9GOg@z>

On 1/11/19 1:24 AM, Peter Zijlstra wrote:
> diff --git a/include/linux/bitops.h b/include/linux/bitops.h
> index 705f7c442691..2060d26a35f5 100644
> --- a/include/linux/bitops.h
> +++ b/include/linux/bitops.h
> @@ -241,10 +241,10 @@ static __always_inline void __assign_bit(long nr, volatile unsigned long *addr,
>  	const typeof(*(ptr)) mask__ = (mask), bits__ = (bits);	\
>  	typeof(*(ptr)) old__, new__;				\
>  								\
> +	old__ = READ_ONCE(*(ptr));				\
>  	do {							\
> -		old__ = READ_ONCE(*(ptr));			\
>  		new__ = (old__ & ~mask__) | bits__;		\
> -	} while (cmpxchg(ptr, old__, new__) != old__);		\
> +	} while (!try_cmpxchg(ptr, &old__, new__));		\
>  								\
>  	new__;							\
>  })
> 
> 
> While there you probably want something like the above... 

As a separate change perhaps so that a revert (unlikely as it might be) could be
done with less pain.

> although,
> looking at it now, we seem to have 'forgotten' to add try_cmpxchg to the
> generic code :/

So it _has_ to be a separate change ;-)

But can we even provide a sane generic try_cmpxchg. The asm-generic cmpxchg relies
on local irq save etc so it is clearly only to prevent a new arch from failing to
compile. atomic*_cmpxchg() is different story since atomics have to be provided by
arch.

Anyhow what is more interesting is the try_cmpxchg API itself. So commit
a9ebf306f52c756 introduced/use of try_cmpxchg(), which indeed makes the looping
"nicer" to read and obvious code gen improvements.

So,
        for (;;) {
                new = val $op $imm;
                old = cmpxchg(ptr, val, new);
                if (old == val)
                        break;
                val = old;
        }

becomes

        do {
        } while (!try_cmpxchg(ptr, &val, val $op $imm));


But on pure LL/SC retry based arches, we still end up with generated code having 2
loops. We discussed something similar a while back: see [1]

First loop is inside inline asm to retry LL/SC and the outer one due to code
above. Explicit return of try_cmpxchg() means setting up a register with a boolean
status of cmpxchg (AFAIKR ARMv7 already does that but ARC e.g. uses a CPU flag
thus requires an additional insn or two). We could arguably remove the inline asm
loop and retry LL/SC from the outer loop, but it seems cleaner to keep the retry
where it belongs.

Also under the hood, try_cmpxchg() would end up re-reading it for the issue fixed
by commit 44fe84459faf1a.

Heck, it would all be simpler if we could express this w/o use of cmpxchg.

	try_some_op(ptr, &val, val $op $imm);

P.S. the horrible API name is for indicative purposes only

This would remove the outer loop completely, also avoid any re-reads due to the
semantics of cmpxchg etc.

[1] https://www.spinics.net/lists/kernel/msg2029217.html

