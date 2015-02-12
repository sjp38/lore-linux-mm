Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id BE99B6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 19:16:59 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id f51so5541050qge.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:16:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l4si3012209qci.30.2015.02.11.16.16.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 16:16:58 -0800 (PST)
Date: Thu, 12 Feb 2015 13:16:49 +1300
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
Message-ID: <20150212131649.59b70f71@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1502111604510.15061@gentwo.org>
References: <20150210194804.288708936@linux.com>
	<20150210194811.902155759@linux.com>
	<20150211174817.44cc5562@redhat.com>
	<alpine.DEB.2.11.1502111305520.7547@gentwo.org>
	<20150212104316.2d5c32ea@redhat.com>
	<alpine.DEB.2.11.1502111604510.15061@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com

On Wed, 11 Feb 2015 16:06:50 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Thu, 12 Feb 2015, Jesper Dangaard Brouer wrote:
> 
> > > > This is quite an expensive lock with irqsave.
[...]
> > > We can require that interrupt are off when the functions are called. Then
> > > we can avoid the "save" part?
> >
> > Yes, we could also do so with an "_irqoff" variant of the func call,
> > but given we are defining the API we can just require this from the
> > start.
> 
> Allright. Lets do that then.

Okay. Some measurements to guide this choice.

Measured on my laptop CPU i7-2620M CPU @ 2.70GHz:

 * 12.775 ns - "clean" spin_lock_unlock
 * 21.099 ns - irqsave variant spinlock
 * 22.808 ns - "manual" irqsave before spin_lock
 * 14.618 ns - "manual" local_irq_disable + spin_lock

Reproducible via my github repo:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c

The clean spin_lock_unlock is 8.324 ns faster than irqsave variant.
The irqsave variant is actually faster than expected, as the measurement
of an isolated local_irq_save_restore were 13.256 ns. 

The difference to the "manual" irqsave is only 1.709 ns, which is approx
the cost of an extra function call.

If one can use the non-flags-save version of local_irq_disable, then one
can save 6.481 ns (on this specific CPU and kernel config 3.17.8-200.fc20.x86_64).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

https://github.com/netoptimizer/prototype-kernel/commit/1471ac60

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
