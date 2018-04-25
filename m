Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 301E86B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 09:42:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z22so11430633pfi.7
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 06:42:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e1-v6sor6274352pld.99.2018.04.25.06.42.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 06:42:47 -0700 (PDT)
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <111ba92b-ea48-93a8-a86c-0c7ca54eabaa@gmail.com>
Date: Wed, 25 Apr 2018 06:42:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180425052722.73022-2-edumazet@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <eric.dumazet@gmail.com>



On 04/24/2018 10:27 PM, Eric Dumazet wrote:
> When adding tcp mmap() implementation, I forgot that socket lock
> had to be taken before current->mm->mmap_sem. syzbot eventually caught
> the bug.
> +

...

  

> +	down_read(&current->mm->mmap_sem);
> +
> +	ret = -EINVAL;
> +	vma = find_vma(current->mm, address);
> +	if (!vma || vma->vm_start > address || vma->vm_ops != &tcp_vm_ops)
>  		goto out;
> -	}
> +	zc->length = min_t(unsigned long, zc->length, vma->vm_end - address);
> +
>  	tp = tcp_sk(sk);
>  	seq = tp->copied_seq;
> -	/* Abort if urgent data is in the area */
> -	if (unlikely(tp->urg_data)) {
> -		u32 urg_offset = tp->urg_seq - seq;
> +	zc->length = min_t(u32, zc->length, tcp_inq(sk));
>  
>

I might have to make sure zc->length is page aligned before calling zap_page_range() ?

zc->length &= ~(PAGE_SIZE - 1);

 +	zap_page_range(vma, address, zc->length);
