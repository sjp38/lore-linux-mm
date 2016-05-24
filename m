Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id B44796B0253
	for <linux-mm@kvack.org>; Tue, 24 May 2016 12:36:15 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id u5so41274177igk.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 09:36:15 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0105.outbound.protection.outlook.com. [157.56.112.105])
        by mx.google.com with ESMTPS id x7si2587138oia.49.2016.05.24.09.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 09:36:14 -0700 (PDT)
Date: Tue, 24 May 2016 19:36:06 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RESEND 8/8] af_unix: charge buffers to kmemcg
Message-ID: <20160524163606.GB11150@esperanza>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
 <1464094926.5939.48.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1464094926.5939.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 06:02:06AM -0700, Eric Dumazet wrote:
> On Tue, 2016-05-24 at 11:49 +0300, Vladimir Davydov wrote:
> > Unix sockets can consume a significant amount of system memory, hence
> > they should be accounted to kmemcg.
> > 
> > Since unix socket buffers are always allocated from process context,
> > all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
> > sock->sk_allocation mask.
> 
> I have two questions : 
> 
> 1) What happens when a buffer, allocated from socket <A> lands in a
> different socket <B>, maybe owned by another user/process.
> 
> Who owns it now, in term of kmemcg accounting ?

We never move memcg charges. E.g. if two processes from different
cgroups are sharing a memory region, each page will be charged to the
process which touched it first. Or if two processes are working with the
same directory tree, inodes and dentries will be charged to the first
user. The same is fair for unix socket buffers - they will be charged to
the sender.

> 
> 2) Has performance impact been evaluated ?

I ran netperf STREAM_STREAM with default options in a kmemcg on
a 4 core x 2 HT box. The results are below:

 # clients            bandwidth (10^6bits/sec)
                    base              patched
         1      67643 +-  725      64874 +-  353    - 4.0 %
         4     193585 +- 2516     186715 +- 1460    - 3.5 %
         8     194820 +-  377     187443 +- 1229    - 3.7 %

So the accounting doesn't come for free - it takes ~4% of performance.
I believe we could optimize it by using per cpu batching not only on
charge, but also on uncharge in memcg core, but that's beyond the scope
of this patch set - I'll take a look at this later.

Anyway, if performance impact is found to be unacceptable, it is always
possible to disable kmem accounting at boot time (cgroup.memory=nokmem)
or not use memory cgroups at runtime at all (thanks to jump labels
there'll be no overhead even if they are compiled in).

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
