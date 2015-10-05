Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6227382FAD
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 19:53:42 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so194391963pac.2
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 16:53:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id id10si44011398pbc.42.2015.10.05.16.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 16:53:41 -0700 (PDT)
Date: Tue, 6 Oct 2015 01:53:37 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151006015337.0fab1547@redhat.com>
In-Reply-To: <20151005212639.35932b6c@redhat.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
	<20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
	<20151005212639.35932b6c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, brouer@redhat.com

On Mon, 5 Oct 2015 21:26:39 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> My only problem left, is I want a perf measurement that pinpoint these
> kind of spots.  The difference in L1-icache-load-misses were significant
> (1,278,276 vs 2,719,158).  I tried to somehow perf record this with
> different perf events without being able to pinpoint the location (even
> though I know the spot now).  Even tried Andi's ocperf.py... maybe he
> will know what event I should try?

Using: 'ocperf.py -e icache_misses' and looking closer at the perf
annotate and considering "skid" I think I can see the icache misses
happening in the end of the function, due to the UD2 inst.

Annotation of kmem_cache_free_bulk (last/end of func):

       =E2=94=8217b:   test   %r12,%r12
       =E2=94=82     =E2=86=91 jne    2e
       =E2=94=82184:   pop    %rbx
       =E2=94=82       pop    %r12
       =E2=94=82       pop    %r13
       =E2=94=82       pop    %r14
       =E2=94=82       pop    %r15
       =E2=94=82       pop    %rbp
       =E2=94=82     =E2=86=90 retq
  8.57 =E2=94=8218f:   mov    0x30(%rdx),%rdx
  5.71 =E2=94=82     =E2=86=91 jmp    116
       =E2=94=82195:   ud2
  2.86 =E2=94=82197:   mov    %rdi,%rsi
       =E2=94=82       mov    %r11d,%r8d
       =E2=94=82       mov    %r10,%rcx
       =E2=94=82       mov    %rbx,%rdx
       =E2=94=82       mov    %r15,%rdi
       =E2=94=82     =E2=86=92 callq  __slab_free
       =E2=94=82     =E2=86=91 jmp    17b
  2.86 =E2=94=821ad:   mov    0x30(%rdi),%rdi
       =E2=94=82     =E2=86=91 jmpq   99

--=20
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
