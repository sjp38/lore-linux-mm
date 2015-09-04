Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC576B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 16:29:04 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so34532365pac.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 13:29:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xi9si5864426pbc.214.2015.09.04.13.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 13:29:03 -0700 (PDT)
Date: Fri, 4 Sep 2015 13:29:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab:Fix the unexpected index mapping result of
 kmalloc_size(INDEX_NODE + 1)
Message-Id: <20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org>
In-Reply-To: <20150807015609.GB15802@js1304-P5Q-DELUXE>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
	<20150729152803.67f593847050419a8696fe28@linux-foundation.org>
	<20150731001827.GA15029@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
	<20150807015609.GB15802@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Fri, 7 Aug 2015 10:56:09 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Fri, Jul 31, 2015 at 08:57:35AM -0500, Christoph Lameter wrote:
> > On Fri, 31 Jul 2015, Joonsoo Kim wrote:
> > 
> > > I don't think that this fix is right.
> > > Just "kmalloc_size(INDEX_NODE) * 2" looks insane because it means 192 * 2
> > > = 384 on his platform. Why we need to check size is larger than 384?
> > 
> > Its an arbitrary boundary. Making it large ensures that the smaller caches
> > stay operational and do not fall back to page sized allocations.
> 
> If it is an arbitrary boundary, it would be better to use static value
> such as "256" rather than kmalloc_size(INDEX_NODE) * 2.
> Value of kmalloc_size(INDEX_NODE) * 2 can be different in some archs
> and it is difficult to manage such variation. It would cause this kinds of
> bug again. I recommand following change. How about it?
> 
> -       if (size >= kmalloc_size(INDEX_NODE + 1)
> +       if (!slab_early_init &&
> +               size >= kmalloc_size(INDEX_NODE) &&
> +               size >= 256
> 

Guys, can we please finish this off?  afaict Jianxuexin's original
patch is considered undesirable, but his machine is still going BUG.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
