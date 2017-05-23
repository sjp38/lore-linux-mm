Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C24A96B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 12:56:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so171352250pff.13
        for <linux-mm@kvack.org>; Tue, 23 May 2017 09:56:11 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id 84si19417988pfx.319.2017.05.23.09.56.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 09:56:11 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id e193so120313410pfh.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 09:56:10 -0700 (PDT)
Date: Tue, 23 May 2017 09:56:08 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
Message-ID: <20170523165608.GN141096@google.com>
References: <20170519210036.146880-1-mka@chromium.org>
 <20170519210036.146880-2-mka@chromium.org>
 <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
 <20170522205621.GL141096@google.com>
 <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
 <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>

Hi David,

El Mon, May 22, 2017 at 06:35:23PM -0700 David Rientjes ha dit:

> On Mon, 22 May 2017, Andrew Morton wrote:
> 
> > > > Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't 
> > > > think this should ever warn on gcc.
> > > 
> > > clang warns about unused static inline functions outside of header
> > > files, in difference to gcc.
> > 
> > I wish it wouldn't.  These patches just add clutter.
> > 
> 
> Matthias, what breaks if you do this?
> 
> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> index de179993e039..e1895ce6fa1b 100644
> --- a/include/linux/compiler-clang.h
> +++ b/include/linux/compiler-clang.h
> @@ -15,3 +15,8 @@
>   * with any version that can compile the kernel
>   */
>  #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
> +
> +#ifdef inline
> +#undef inline
> +#define inline __attribute__((unused))
> +#endif

Thanks for the suggestion!

Nothing breaks and the warnings are silenced. It seems we could use
this if there is a stong opposition against having warnings on unused
static inline functions in .c files.

Still I am not convinced that gcc's behavior is preferable in this
case. True, it saves us from adding a bunch of __maybe_unused or
#ifdefs, on the other hand the warning is a useful tool to spot truly
unused code. So far about 50% of the warnings I looked into fall into
this category.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
