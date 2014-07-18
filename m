Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 563396B0037
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 14:19:51 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id hu12so7937747vcb.34
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:19:51 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id ce2si11737750qcb.7.2014.07.18.11.19.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 11:19:50 -0700 (PDT)
Received: by mail-qc0-f171.google.com with SMTP id i17so3721513qcy.30
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:19:50 -0700 (PDT)
Date: Fri, 18 Jul 2014 14:19:47 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-ID: <20140718181947.GE13012@htj.dyndns.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
 <20140718112039.GA8383@htj.dyndns.org>
 <CAOhV88PyBK3WxDjG1H0hUbRhRYzPOzV8eim5DuOcgObe-FtFYg@mail.gmail.com>
 <20140718180008.GC13012@htj.dyndns.org>
 <CAOhV88O03zCsv_3eadEKNv1D1RoBmjWRFNhPjEHawF9s71U0JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOhV88O03zCsv_3eadEKNv1D1RoBmjWRFNhPjEHawF9s71U0JA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

On Fri, Jul 18, 2014 at 11:12:01AM -0700, Nish Aravamudan wrote:
> why aren't these callers using kthread_create_on_cpu()? That API was

It is using that.  There just are other data structures too.

> already change to use cpu_to_mem() [so one change, rather than of all over
> the kernel source]. We could change it back to cpu_to_node and push down
> the knowledge about the fallback.

And once it's properly solved, please convert back kthread to use
cpu_to_node() too.  We really shouldn't be sprinkling the new subtly
different variant across the kernel.  It's wrong and confusing.

> Yes, this is a good point. But honestly, we're not really even to the point
> of talking about fallback here, at least in my testing, going off-node at
> all causes SLUB-configured slabs to deactivate, which then leads to an
> explosion in the unreclaimable slab.

I don't think moving the logic inside allocator proper is a huge
amount of work and this isn't the first spillage of this subtlety out
of allocator proper.  Fortunately, it hasn't spread too much yet.
Let's please stop it here.  I'm not saying you shouldn't or can't fix
the off-node allocation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
