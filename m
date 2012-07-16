Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E31726B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 19:48:28 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so13043040pbb.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 16:48:28 -0700 (PDT)
Date: Mon, 16 Jul 2012 16:48:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <alpine.DEB.2.00.1207161506390.32319@router.home>
Message-ID: <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2> <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1207160915470.28952@router.home> <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com> <alpine.DEB.2.00.1207161506390.32319@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shuah Khan <shuah.khan@hp.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 16 Jul 2012, Christoph Lameter wrote:

> > Sounds like a response from someone who is very familiar with slab
> > allocators.  The reality, though, is that very few people are going to be
> > doing development with CONFIG_DEBUG_VM enabled unless they notice problems
> > beforehand.
> 
> Kernels are certainly run with CONFIG_DEBUG_VM before merges to mainstream
> occur. If the developer does not do it then someone else will.
> 

So let's say a developer wants to pass a dynamically allocated string to 
kmem_cache_create() for the cache name and it happens to be NULL because 
of a failed allocation but this never happened in testing (or it does 
happen but CONFIG_DEBUG_VM=n) and they are using CONFIG_SLAB.

What would the failure be in linux-next?  It looks like it would just 
result in a corrupted slabinfo.  Bad result, we used to catch this problem 
before the extraction of common functionality and now we've allowed a 
corrupted slabinfo for nothing: optimizing kmem_cache_create() is 
pointless.

> The kernel cannot check everything and will blow up in unexpected ways if
> someone codes something stupid. There are numerous debugging options that
> need to be switched on to get better debugging information to investigate
> deper. Adding special code to replicate these checks is bad.
> 

Disagree, CONFIG_SLAB does not blow up for a NULL name string and just 
corrupts userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
