Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C42F6B0011
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:27:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j3so11741574wrb.18
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:27:34 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id o7si7810761wrg.396.2018.02.26.11.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 11:27:33 -0800 (PST)
Subject: Re: [PATCH 2/7] genalloc: selftest
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-3-igor.stoppa@huawei.com>
 <76b3d858-b14e-b66d-d8ae-dbd0b307308a@gmail.com>
 <a7b47f45-5929-ae07-1a10-46a02f6db078@huawei.com>
 <45087800-218a-7ff5-22c0-d0a5bfea5001@gmail.com>
 <20249e10-4a13-8084-bcf2-0f98497a755f@huawei.com>
 <20180226191235.GA24087@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <aa491cf5-ace4-1e2c-2f49-60f96b1e6da9@huawei.com>
Date: Mon, 26 Feb 2018 21:26:58 +0200
MIME-Version: 1.0
In-Reply-To: <20180226191235.GA24087@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: J Freyensee <why2jjj.linux@gmail.com>, david@fromorbit.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 26/02/18 21:12, Matthew Wilcox wrote:
[...]

> panic() halts the kernel
> BUG_ON() kills the thread
> WARN_ON() just prints messages
> 
> Now, if we're at boot time and we're still executing code from the init
> thread, killing init is equivalent to halting the kernel.
> 
> The question is, what is appropriate for test modules?  I would say
> WARN_ON is not appropriate because people ignore warnings.  BUG_ON is
> reasonable for development.  panic() is probably not.

Ok, so I can leave WARN_ON() in the libraries, and keep the more
restrictive BUG_ON() for the self test, which is optional for both
genalloc and pmalloc.

> Also, calling BUG_ON while holding a lock is not a good idea; if anything
> needs to acquire that lock to shut down in a reasonable fashion, it's
> going to hang.
> 
> And there's no need to do something like BUG_ON(!foo); foo->wibble = 1;
> Dereferencing a NULL pointer already produces a nice informative splat.
> In general, we assume other parts of the kernel are sane and if they pass
> us a NULL pool, it's no good returning -EINVAL, we may as well just oops
> and let somebody else debug it.

Great, that makes the code even simpler.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
