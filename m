Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F90C6B0003
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 23:15:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so6007189plf.18
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 20:15:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u11-v6si9777021pgq.480.2018.06.29.20.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 20:15:49 -0700 (PDT)
Date: Fri, 29 Jun 2018 20:15:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
Message-Id: <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
In-Reply-To: <084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
	<1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
	<20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
	<084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Fri, 29 Jun 2018 19:28:15 -0700 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> 
> 
> > we're adding a bunch of code to 32-bit kernels which will never be
> > executed.
> >
> > I'm thinking it would be better to be much more explicit with "#ifdef
> > CONFIG_64BIT" in this code, rather than relying upon the above magic.
> >
> > But I tend to think that the fact that we haven't solved anything on
> > locked vmas or on uprobed mappings is a shostopper for the whole
> > approach :(
> 
> I agree it is not that perfect. But, it still could improve the most use 
> cases.

Well, those unaddressed usecases will need to be fixed at some point. 
What's our plan for that?

Would one of your earlier designs have addressed all usecases?  I
expect the dumb unmap-a-little-bit-at-a-time approach would have?

> For the locked vmas and hugetlb vmas, unmapping operations need modify 
> vm_flags. But, I'm wondering we might be able to separate unmap and 
> vm_flags update. Because we know they will be unmapped right away, the 
> vm_flags might be able to be updated in write mmap_sem critical section 
> before the actual unmap is called or after it. This is just off the top 
> of my head.
> 
> For uprobed mappings, I'm not sure how vital it is to this case.
> 
> Thanks,
> Yang
> 
> >
