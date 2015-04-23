Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4A03C6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 23:21:53 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so6268146pdb.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 20:21:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id im3si10471056pbb.55.2015.04.22.20.21.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 20:21:52 -0700 (PDT)
Date: Wed, 22 Apr 2015 20:28:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/slab_common: Support the slub_debug boot option
 on specific object size
Message-Id: <20150422202842.47cb7940.akpm@linux-foundation.org>
In-Reply-To: <CA+eFSM38C+P5_2GRXxNR=LtGBHFo-gDyPMvembw75XV+0OkGCQ@mail.gmail.com>
References: <1429691618-13884-1-git-send-email-gavin.guo@canonical.com>
	<20150422140039.19812721dff3fec674dc5134@linux-foundation.org>
	<CA+eFSM38C+P5_2GRXxNR=LtGBHFo-gDyPMvembw75XV+0OkGCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <gavin.guo@canonical.com>
Cc: Christoph Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, 23 Apr 2015 11:10:40 +0800 Gavin Guo <gavin.guo@canonical.com> wrote:

> >>       for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
> >>               if (!kmalloc_caches[i]) {
> >> -                     kmalloc_caches[i] = create_kmalloc_cache(NULL,
> >> +                     kmalloc_caches[i] = create_kmalloc_cache(
> >> +                                                     kmalloc_names[i],
> >>                                                       1 << i, flags);
> >>               }
> >
> > You could do something like
> >
> >                 kmalloc_caches[i] = create_kmalloc_cache(
> >                                         kmalloc_names[i],
> >                                         kstrtoul(kmalloc_names[i] + 8),
> >                                         flags);
> >
> > here, and remove those weird "96" and "192" cases.
> 
> Thanks for your reply. I'm not sure if I am following your idea. Would you
> mean to simply replace the string like:
> 
>                 kmalloc_caches[1] = create_kmalloc_cache(
>                                         kmalloc_names[1], 96, flags);
> as follows:
> 
>                 kmalloc_caches[1] = create_kmalloc_cache(
>                                         kmalloc_names[1],
>                                         kstrtoul(kmalloc_names[i] + 8),
>                                         flags);
> 
> or if you like to merge the last 2 if conditions for 96 and 192 cases to
> the first if condition check:
> 
>                 if (!kmalloc_caches[i]) {
>                         kmalloc_caches[i] = create_kmalloc_cache(NULL,
>                                                         1 << i, flags);
>                 }

The latter - initialize all the caches in a single loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
