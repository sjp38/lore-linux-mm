Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC6C6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 19:15:51 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so108144914pab.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 16:15:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 73si18473206pfq.164.2016.03.28.16.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 16:15:50 -0700 (PDT)
Date: Mon, 28 Mar 2016 16:15:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/vmap: Add a notifier for when we run out of vmap
 address space
Message-Id: <20160328161549.c77046847a8ae791cb436aff@linux-foundation.org>
In-Reply-To: <20160317134156.GX14143@nuc-i3427.alporthouse.com>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
	<1458221699-13734-1-git-send-email-chris@chris-wilson.co.uk>
	<20160317134156.GX14143@nuc-i3427.alporthouse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, David Rientjes <rientjes@google.com>, Roman Peniaev <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 17 Mar 2016 13:41:56 +0000 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> On Thu, Mar 17, 2016 at 01:34:59PM +0000, Chris Wilson wrote:
> > vmaps are temporary kernel mappings that may be of long duration.
> > Reusing a vmap on an object is preferrable for a driver as the cost of
> > setting up the vmap can otherwise dominate the operation on the object.
> > However, the vmap address space is rather limited on 32bit systems and
> > so we add a notification for vmap pressure in order for the driver to
> > release any cached vmappings.
> > 
> > The interface is styled after the oom-notifier where the callees are
> > passed a pointer to an unsigned long counter for them to indicate if they
> > have freed any space.
> > 
> > v2: Guard the blocking notifier call with gfpflags_allow_blocking()
> > 
> > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Roman Peniaev <r.peniaev@gmail.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  include/linux/vmalloc.h |  4 ++++
> >  mm/vmalloc.c            | 27 +++++++++++++++++++++++++++
> >  2 files changed, 31 insertions(+)
> > 
> > diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> > index d1f1d338af20..edd676b8e112 100644
> > --- a/include/linux/vmalloc.h
> > +++ b/include/linux/vmalloc.h
> > @@ -187,4 +187,8 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
> >  #define VMALLOC_TOTAL 0UL
> >  #endif
> >  
> > +struct notitifer_block;
> Omg. /o\

Hah.

Please move the forward declaration to top-of-file.  This prevents
people from later adding the same thing at line 100 - this has happened
before.

Apart from that, all looks OK to me - please merge it via the DRM tree
if that is more convenient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
