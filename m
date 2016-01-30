Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id BE71A6B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 12:46:56 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id s5so36529960qkd.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 09:46:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si23250819qgy.13.2016.01.30.09.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 09:46:55 -0800 (PST)
Date: Sat, 30 Jan 2016 18:46:46 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [slab] a1fd55538c: WARNING: CPU: 0 PID: 0 at
 kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller()
Message-ID: <20160130184646.6ea9c5f8@redhat.com>
In-Reply-To: <21684.1454137770@turing-police.cc.vt.edu>
References: <56aa2b47.MwdlkrzZ08oDKqh8%fengguang.wu@intel.com>
	<20160128184749.7bdee246@redhat.com>
	<21684.1454137770@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com, brouer@redhat.com, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Sat, 30 Jan 2016 02:09:30 -0500
Valdis.Kletnieks@vt.edu wrote:

> On Thu, 28 Jan 2016 18:47:49 +0100, Jesper Dangaard Brouer said:
> > I cannot reproduce below problem... have enabled all kind of debugging
> > and also lockdep.
> >
> > Can I get a version of the .config file used?  
> 
> I'm not the 0day bot, but my laptop hits the same issue at boot.

Thank you! I'm now able to reproduce, and I've found the issue. It only
happens for SLAB, and with FAILSLAB disabled.

The problem were introduced in the patch before:
  http://ozlabs.org/~akpm/mmots/broken-out/mm-fault-inject-take-over-bootstrap-kmem_cache-check.patch
which moved the check function:

 static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
 {
       if (unlikely(cachep == kmem_cache))
               return false;

       return should_failslab(cachep->object_size, flags, cachep->flags);
 }

into the fault injection framework, call of should_failslab().

That change was wrong, as some very early boot code depend on SLAB
failing, when still allocating from the bootstrap kmem_cache. SLUB seem
to handle this better.


In this case the percpu system, have a workqueue function, calling
pcpu_extend_area_map() which sort-of probe the slab-allocator, and
depending on it fails, until it is fully ready.

I will fix up my patches, reverting this change... and let them go
through Andrews quilt process.

Let me know, if the linux-next tree need's an explicit fix?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
