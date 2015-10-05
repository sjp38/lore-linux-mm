Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id D1C9082F66
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 19:07:08 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so193389661pac.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 16:07:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w14si43708970pbt.201.2015.10.05.16.07.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 16:07:07 -0700 (PDT)
Date: Tue, 6 Oct 2015 01:07:03 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151006010703.09e2f0ff@redhat.com>
In-Reply-To: <20151005212045.GG26924@tassilo.jf.intel.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
	<20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
	<20151005212639.35932b6c@redhat.com>
	<20151005212045.GG26924@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, brouer@redhat.com

(trimmed Cc list a little)

On Mon, 5 Oct 2015 14:20:45 -0700 Andi Kleen <ak@linux.intel.com> wrote:

> > My only problem left, is I want a perf measurement that pinpoint these
> > kind of spots.  The difference in L1-icache-load-misses were significant
> > (1,278,276 vs 2,719,158).  I tried to somehow perf record this with
> > different perf events without being able to pinpoint the location (even
> > though I know the spot now).  Even tried Andi's ocperf.py... maybe he
> > will know what event I should try?
> 
> Run pmu-tools toplev.py -l3 with --show-sample. It tells you what the
> bottle neck is and what to sample for if there is a suitable event and
> even prints the command line.
> 
> https://github.com/andikleen/pmu-tools/wiki/toplev-manual#sampling-with-toplev
> 

My result from (IP-forward flow hitting CPU 0):
 $ sudo ./toplev.py -I 1000 -l3 -a --show-sample --core C0

So, what does this tell me?:

 C0    BAD     Bad_Speculation:                                 0.00 % [  5.50%]
 C0    BE      Backend_Bound:                                 100.00 % [  5.50%]
 C0    BE/Mem  Backend_Bound.Memory_Bound:                     53.06 % [  5.50%]
 C0    BE/Core Backend_Bound.Core_Bound:                       46.94 % [  5.50%]
 C0-T0 FE      Frontend_Bound.Frontend_Latency.Branch_Resteers: 5.42 % [  5.50%]
 C0-T0 BE/Mem  Backend_Bound.Memory_Bound.L1_Bound:            54.51 % [  5.50%]
 C0-T0 BE/Core Backend_Bound.Core_Bound.Ports_Utilization:     20.99 % [  5.60%]
 C0-T0         CPU utilization: 1.00 CPUs   	[100.00%]
 C0-T1 FE      Frontend_Bound.Frontend_Latency.Branch_Resteers: 6.04 % [  5.50%]
 C0-T1         CPU utilization: 1.00 CPUs   	[100.00%]

Unfortunately the perf command it gives me fails with:
 "invalid or unsupported event".

Perf command:

 perf record -g -e cpu/event=0xc5,umask=0x0,name=Branch_Resteers_BR_MISP_RETIRED_ALL_BRANCHES:pp,period=400009/pp,cpu/event=0xd,umask=0x3,cmask=1,name=Bad_Speculation_INT_MISC_RECOVERY_CYCLES,period=2000003/,cpu/event=0xd1,umask=0x1,name=L1_Bound_MEM_LOAD_UOPS_RETIRED_L1_HIT:pp,period=2000003/pp,cpu/event=0xd1,umask=0x40,name=L1_Bound_MEM_LOAD_UOPS_RETIRED_HIT_LFB:pp,period=100003/pp -C 0,4 -a


> However frontend issues are difficult to sample, as they happen very far
> away from instruction retirement where the sampling happens. So you may
> have large skid and the sampling points may be far away. Skylake has new
> special FRONTEND_* PEBS events for this, but before it was often difficult. 

This testlab CPU is i7-4790K @ 4.00GHz.  Maybe I should get a Skylake...


p.s. thanks for your pmu-tools[1], even-though I don't know how to use
most of them ;-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://github.com/andikleen/pmu-tools

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
