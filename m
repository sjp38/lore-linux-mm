Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 716A52802FE
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 02:34:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so28976006wry.4
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 23:34:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p43si3226572wrc.129.2017.06.28.23.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 23:34:21 -0700 (PDT)
Date: Thu, 29 Jun 2017 08:33:20 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] futex: avoid undefined behaviour when shift exponent is
 negative
In-Reply-To: <59545DD6.3030508@huawei.com>
Message-ID: <alpine.DEB.2.20.1706290832140.1861@nanos>
References: <1498045437-7675-1-git-send-email-zhongjiang@huawei.com> <20170621164036.4findvvz7jj4cvqo@gmail.com> <595331FE.3090700@huawei.com> <alpine.DEB.2.20.1706282353190.1890@nanos> <59545DD6.3030508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Ingo Molnar <mingo@kernel.org>, akpm@linux-foundation.org, mingo@redhat.com, minchan@kernel.org, mhocko@suse.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 29 Jun 2017, zhong jiang wrote:
> On 2017/6/29 6:13, Thomas Gleixner wrote:
> > That's simply wrong. If oparg is negative and the SHIFT bit is set then the
> > result is undefined today and there is no way that this can be used at
> > all.
> >
> > On x86:
> >
> >    1 << -1	= 0x80000000
> >    1 << -2048	= 0x00000001
> >    1 << -2047	= 0x00000002
>   but I test the cases in x86_64 all is zero.   I wonder whether it is related to gcc or not
> 
>   zj.c:15:8: warning: left shift count is negative [-Wshift-count-negative]
>   j = 1 << -2048;
>         ^
> [root@localhost zhongjiang]# ./zj
> j = 0

Which is not a surprise because the compiler can detect it as the shift is
a constant. oparg is not so constant ...

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
