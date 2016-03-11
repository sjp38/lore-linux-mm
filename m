Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 282576B007E
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 11:10:38 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id av4so15393292igc.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 08:10:38 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0225.hostedemail.com. [216.40.44.225])
        by mx.google.com with ESMTPS id b17si3996537ign.51.2016.03.11.08.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 08:10:37 -0800 (PST)
Date: Fri, 11 Mar 2016 11:10:34 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
Message-ID: <20160311111034.2255e3b3@gandalf.local.home>
In-Reply-To: <56E2AF71.2050800@gmail.com>
References: <cover.1456504662.git.glider@google.com>
	<00e9fa7d4adeac2d37a42cf613837e74850d929a.1456504662.git.glider@google.com>
	<56D471F5.3010202@gmail.com>
	<CACT4Y+YPFEyuFdnM3_=2p1qANC7A1CKB0o1ySx2zexgE4kgVVw@mail.gmail.com>
	<56D58398.2010708@gmail.com>
	<CAG_fn=Xby+PJtMQtZ68gPkSPCyxbF=RsOCVavYew7ZVDx25yow@mail.gmail.com>
	<CAPAsAGzmFWCMEHhw=+15B1RO_7r3vUOMG0cZEPzQ=YcM5YP5MQ@mail.gmail.com>
	<CAG_fn=UhykNnE7L1dHA3LFbLb9tp-x0nZ4Z7joUk_-vvHDtX5g@mail.gmail.com>
	<56E2AF71.2050800@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 11 Mar 2016 14:43:45 +0300
Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:


> >> This is not about size, this about fragmentation. vmalloc allows to
> >> utilize available low-order pages,
> >> hence reduce the fragmentation.  
> > I've attempted to add __vmalloc(STACK_ALLOC_SIZE, alloc_flags,
> > PAGE_KERNEL) (also tried vmalloc(STACK_ALLOC_SIZE)) instead of
> > page_alloc() and am now getting a crash in
> > kmem_cache_alloc_node_trace() in mm/slab.c, because it doesn't allow
> > the kmem_cache pointer to be NULL (it's dereferenced when calling
> > trace_kmalloc_node()).
> > 
> > Steven, do you know if this because of my code violating some contract
> > (e.g. I'm calling vmalloc() too early, when kmalloc_caches[] haven't
> > been initialized),   
> 
> Probably. kmem_cache_init() goes before vmalloc_init().

Agreed, that function can not be called with cachep NULL, nor can it be
called before kmem_cache is set up to point to kmem_cache_boot.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
