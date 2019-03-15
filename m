Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A8C6C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:03:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5149218FD
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 20:03:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mUxATW68"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5149218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2AA406B02C3; Fri, 15 Mar 2019 16:03:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 257CD6B02C4; Fri, 15 Mar 2019 16:03:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 108626B02C5; Fri, 15 Mar 2019 16:03:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C18EB6B02C3
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 16:03:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 73so11232365pga.18
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:03:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9AzJNPZrWzBDD4w+YR6o8R1NuHkXmo1ETr66/JW7xLw=;
        b=ZRrMgjgLMIn2NTrBnCXU6g1o8OLgU5FdT7Xf1m1qyujTLpGxvDxYKRqLlpyVGJ75Va
         umt0ZhTcXgUdkrSEDZgAyvVJ8o0QI4dqJekt8rQuVbFmE42gs0NuPgoiJiaxdDeFs0e9
         UvSNiFnJ7Y9iHrpizGtQNMKKKj9JRKOpgtVzeKyhr8OziNdoZBJ0c7ojl9yRjwyXFQ/M
         xJ3T2oEOyGQMFbxaAW/m2BuevHWW7PHpt3Q+ly5FB6vWajQpyCr1egzAIZoo7qX7HGpZ
         b7AqlwnJ46D2ufYIb8ns6Mgy18hbuzTSbfC+39JIw5cecDhcTWR/4s51Zt+TseRyNcWd
         L/wg==
X-Gm-Message-State: APjAAAXDmaEzPri8OeuYF97CUFJiFJG+TXVLhvKC01GsqR4nvWdFTxg5
	3S2iWGdsTA2mIya2QPEvN+l0SNVlygmDCH33SgV7Da/RWr10nmFodFGaq444oMURP8PP7E9xdy1
	dyWoiKybLYba6Doa62wFbxB8WuLDfbBpusaEoPn9r/Oq2IOgfLf4JhTKdBZqzvelqWA==
X-Received: by 2002:a17:902:9b96:: with SMTP id y22mr6194712plp.87.1552680215451;
        Fri, 15 Mar 2019 13:03:35 -0700 (PDT)
X-Received: by 2002:a17:902:9b96:: with SMTP id y22mr6194604plp.87.1552680214232;
        Fri, 15 Mar 2019 13:03:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552680214; cv=none;
        d=google.com; s=arc-20160816;
        b=rm1k3qcR6mDGzJCCFmjL6hMgF8H8UljvI9osM/o13G43RktLPX+Fe92ZdAx0hF+PXz
         d7RO+hfbjDe69XJVB1ODooTdsjlkkb4OP0XmFwhR6QuPf7r0SQmFxzJaM94agQ0gygoN
         01fIhUd5cH1CvL8/t+Ul9KFvwY9Y0nMHXbCO1bqohQkkdWb0/9crUcS1ob49+P7HCvAC
         5Ev9BU3+DZ7BES/ec4zsPTCBoYjgj09OlXma4dko5Tu2VKBPwaiYybG7w7PjHsbjzAO9
         gJJ2BWOOUW5pZ6ZqGg5U/htWa/wInT8NqPxywtlZuJYzYAJsQc3ooIJ5XKmb/lYrYNwE
         4GYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9AzJNPZrWzBDD4w+YR6o8R1NuHkXmo1ETr66/JW7xLw=;
        b=xUW0ZeiQsIiDkqkbwxK8Z8vaQVDe4IgIoMBVAWzn4008r17a4l9+ASQcgZybzd2GE3
         a6uGOBljAikrycDD6VCp/nxl3rNYzs5c0SCQbJCAa8y/rQeyt3DctVH8fW1q5zo0q0Lt
         dd7KjCj9FF6hoEW7xTSvN8OiYfyWlHL920Kd51rv0fGgDRuYDEGARDrmeRVgWz2+VvGg
         48wqHCj7lcJ+6wRWAFBAmPyGmWldjR6KygTBomQ5wSGrRppBt8w8T4MhuzF/4O//kGxt
         bdNVw55bjQTcpwAeppfOs3UESeYZOkfpEIqtqJ8aCobqUOCZrMXGxhJupOGVcPzzrh1b
         2Zmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mUxATW68;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b19sor2691855pgk.58.2019.03.15.13.03.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 13:03:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mUxATW68;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9AzJNPZrWzBDD4w+YR6o8R1NuHkXmo1ETr66/JW7xLw=;
        b=mUxATW68etjE5v8S6J9Jd+3aIJP3RDifB7SRhiyyAe3JOb88DPKvLOvqxA5fJjklUa
         0R51CHmyEhXiPvKBm8RTOmSqu9McUlBgo9ESFJeeOk3DFae8iSGVwwpnWkHL5T8LIehE
         H6aDiOVLZhFjZTl6Lyoxfp6D/MXHg0AlvvGtbOaILc1P4UMi+CnbvjCE9w2Bbb+mndVh
         HoRoU1W1TqYpdyrIt+3CSbdzFHrAwEv4kdI659SaRSqJ3zauITFYhoUxKS+o+Pa/IK6C
         O3HS9Q7uE1MPZhMMaTgS0hvmb0iSDSU6rlzoljfH1oI8gX1kjokIbEHdfL8Wq/7KSEZ6
         ejYA==
X-Google-Smtp-Source: APXvYqz6d+NKyVLh5z3E5aaETq9ca7nFOcUBQOKqRBUqKTHpgoiu//RDThDx4hpT4mlqDLJyMQbN0g==
X-Received: by 2002:a63:780e:: with SMTP id t14mr5285862pgc.276.1552680213678;
        Fri, 15 Mar 2019 13:03:33 -0700 (PDT)
Received: from ?IPv6:2620:15c:2c1:200:55c7:81e6:c7d8:94b? ([2620:15c:2c1:200:55c7:81e6:c7d8:94b])
        by smtp.gmail.com with ESMTPSA id p34sm4428128pgb.18.2019.03.15.13.03.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 13:03:32 -0700 (PDT)
Subject: Re: [PATCH v11 08/14] net, arm64: untag user pointers in
 tcp_zerocopy_receive
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org,
 bpf@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com>
Date: Fri, 15 Mar 2019 13:03:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/15/2019 12:51 PM, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> can only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/tcp.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 6baa6dc1b13b..89db3b4fc753 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1758,6 +1758,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
>  	int inq;
>  	int ret;
>  
> +	address = untagged_addr(address);
> +
>  	if (address & (PAGE_SIZE - 1) || address != zc->address)

The second test will fail, if the top bits are changed in address but not in zc->address

>  		return -EINVAL;
>  
> 

