Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C658DC606BF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:50:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9108B20665
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:50:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9108B20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26A598E0019; Mon,  8 Jul 2019 10:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21A448E0002; Mon,  8 Jul 2019 10:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1312A8E0019; Mon,  8 Jul 2019 10:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id E89FF8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 10:50:05 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id b139so15433303qkc.21
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 07:50:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=m4lJKeNqPF6PUhJfVn2/MLy0a1U7ORLGNDoWGGROjW8=;
        b=TfuNp5ABFR6fuwHZVSSmRSE4V+PbQCebtmpreZDkQbMEkPdZoqcty6ieBIUritrpkK
         fLunCuqn6t+fsbbNGYVGzxkAvnpNkDqJZmp2UrK7XukODsx+3SzWoCyRHQQFJWZoA9+e
         HIaa5gJSkOF44K+t3V0ZRn8+zEP80DY3wmlQsXA2CHMoKmISnoqqrH5B+h7pfmChzhoQ
         ff+d2UYAS3mq4OHs+/b6YklAFHc6NtG4TJ3aTFhbyzITCTeLwViIgvyhzucDcGXbi7MF
         7c1tBd2yes2gFSYpFKmkxk3+qd5fdnj976ccAt9i77kSg+ZPh+XOqZ3b/FBFuZLH5w5F
         vfvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX5o/HOSrsRlszyeCRJb/qmrJ8ABz0ExNuppZhDHuog/i4r0v/V
	tyPrtUlljnnaMaU1gNjQuo8+BDmH8Mg4Se1YUrcDfzcvfvRCK4Wbo2neFPKrbQbYGzdYEGNhiF+
	iQ9clIHO+lcKjizZwf2n+qMNP/EoNzaPv+qC5LvR0i9Q+/hRDO4f5GKcu7ibnx8I=
X-Received: by 2002:a37:a14e:: with SMTP id k75mr12939261qke.65.1562597405737;
        Mon, 08 Jul 2019 07:50:05 -0700 (PDT)
X-Received: by 2002:a37:a14e:: with SMTP id k75mr12939205qke.65.1562597405109;
        Mon, 08 Jul 2019 07:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562597405; cv=none;
        d=google.com; s=arc-20160816;
        b=gzQM8phd+45rpfiMhAeTtChqbtsA6RZuutYrZiTQTAwmvcqqLUB8hhTbeyk7TD/bdq
         L53lJatlBo/FpfYTOExGN35JJrmIOhnBaiSZFhyg1qGADLWXTl497quLoiJRDfHkgYSR
         1k27dYOJiqG4tIoJaVgqwoEaxru905BRkSxgZRDVEqU7I42rQpRTFxkGpL+SAXgdK+ED
         Vrrf1KkAVrCtxu3rMy2q2p4I7qLkAFx1ROj2Tg7BJVB7WoW6dSHfw5hQUpNou2PZZyL9
         vKMk7T+854Oa7nAetzCcbWkHv0DK8SykwR7Fj42DtAfDrj1pA0XTyQwlJRS4yAjZlzIq
         9tzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=m4lJKeNqPF6PUhJfVn2/MLy0a1U7ORLGNDoWGGROjW8=;
        b=d28FWP2Wy0mfKm+I5Y0ZsrPAgGneJg4lKRGsfw+YDjXdnEjVEoWTRQLB6+2hRigUii
         GdX+Y/mA/jhmWj/rNjjBlk0HGxf7yyXBh/YGWm+3yhBgRNqQONdF6bkhLMXHcq5lyAWa
         2cJRX6YwX1diLJzqAKLnipJ0WbfAtIHNb1eiarVeVMqDsIlrxAXjNgBDinFv8U+/NOKs
         1c1kBuGjNvvYGVbqmxxdtxv1FmamNLjTpuBHLLSyXaJVMb8smZrxuYlcYwjMW86FnmRx
         yioz4iiiVp6yWtWdYBaf/CUSZ3NqhkU0sim69tC/DzjCCiu3CIEI9zHw3vaHGATFayrH
         l4Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e1sor10123416qkg.200.2019.07.08.07.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 07:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzcydk75TJwyLHh1v1P7pYsUDMdBgKhP7Ny0LseHJK3GqpASJIMfeiWla1A76rTrchhM+b/iw==
X-Received: by 2002:a37:2c46:: with SMTP id s67mr15092125qkh.396.1562597404820;
        Mon, 08 Jul 2019 07:50:04 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::3:8b5a])
        by smtp.gmail.com with ESMTPSA id a6sm6872044qkn.59.2019.07.08.07.50.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 07:50:03 -0700 (PDT)
Date: Mon, 8 Jul 2019 10:50:02 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Kefeng Wang <wangkefeng.wang@huawei.com>,
	Peng Fan <peng.fan@nxp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Dennis Zhou (Facebook)" <dennisszhou@gmail.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] percpu: fix pcpu_page_first_chunk return code handling
Message-ID: <20190708145002.GA17098@dennisz-mbp>
References: <20190708125217.3757973-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190708125217.3757973-1-arnd@arndb.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2019 at 02:52:09PM +0200, Arnd Bergmann wrote:
> gcc complains that pcpu_page_first_chunk() might return an uninitialized
> error code when the loop is never entered:
> 
> mm/percpu.c: In function 'pcpu_page_first_chunk':
> mm/percpu.c:2929:9: error: 'rc' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> Make it return zero like before the cleanup.
> 
> Fixes: a13e0ad81216 ("percpu: Make pcpu_setup_first_chunk() void function")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/percpu.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 5a918a4b1da0..5b65f753c575 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2917,6 +2917,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
>  		ai->reserved_size, ai->dyn_size);
>  
>  	pcpu_setup_first_chunk(ai, vm.addr);
> +	rc = 0;
>  	goto out_free_ar;
>  
>  enomem:
> -- 
> 2.20.0
> 

Hi Arnd,

I got the report for the kbuild bot. I have the fix in my tree already.

Thanks,
Dennis

