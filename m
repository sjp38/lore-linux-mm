Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 332D16B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 05:25:32 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so3215483lbj.14
        for <linux-mm@kvack.org>; Fri, 18 May 2012 02:25:30 -0700 (PDT)
Date: Fri, 18 May 2012 12:25:26 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH RESEND] slub: fix a memory leak in get_partial_node()
In-Reply-To: <1337181182-23054-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1205181223460.3899@tux.localdomain>
References: <alpine.LFD.2.02.1205160935340.1763@tux.localdomain> <1337181182-23054-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org

On Thu, 17 May 2012, Joonsoo Kim wrote:
> In the case which is below,
> 
> 1. acquire slab for cpu partial list
> 2. free object to it by remote cpu
> 3. page->freelist = t
> 
> then memory leak is occurred.
> 
> Change acquire_slab() not to zap freelist when it works for cpu partial list.
> I think it is a sufficient solution for fixing a memory leak.
> 
> Below is output of 'slabinfo -r kmalloc-256'
> when './perf stat -r 30 hackbench 50 process 4000 > /dev/null' is done.
> 
> ***Vanilla***
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     256  Total  :     468   Sanity Checks : Off  Total: 3833856
> SlabObj:     256  Full   :     111   Redzoning     : Off  Used : 2004992
> SlabSiz:    8192  Partial:     302   Poisoning     : Off  Loss : 1828864
> Loss   :       0  CpuSlab:      55   Tracking      : Off  Lalig:       0
> Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0
> 
> ***Patched***
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     256  Total  :     300   Sanity Checks : Off  Total: 2457600
> SlabObj:     256  Full   :     204   Redzoning     : Off  Used : 2348800
> SlabSiz:    8192  Partial:      33   Poisoning     : Off  Loss :  108800
> Loss   :       0  CpuSlab:      63   Tracking      : Off  Lalig:       0
> Align  :       8  Objects:      32   Tracing       : Off  Lpadd:       0
> 
> Total and loss number is the impact of this patch.
> 
> Cc: <stable@vger.kernel.org>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
