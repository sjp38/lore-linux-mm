Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C7396B0292
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:16:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m4so630672ioe.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:16:14 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id a63si19784300ioe.65.2017.06.01.11.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:16:12 -0700 (PDT)
Date: Thu, 1 Jun 2017 13:16:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1706011002130.3014@eggly.anvils>
Message-ID: <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
 <alpine.LSU.2.11.1706011002130.3014@eggly.anvils>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu, 1 Jun 2017, Hugh Dickins wrote:

> CONFIG_SLUB_DEBUG_ON=y.  My SLAB|SLUB config options are
>
> CONFIG_SLUB_DEBUG=y
> # CONFIG_SLUB_MEMCG_SYSFS_ON is not set
> # CONFIG_SLAB is not set
> CONFIG_SLUB=y
> # CONFIG_SLAB_FREELIST_RANDOM is not set
> CONFIG_SLUB_CPU_PARTIAL=y
> CONFIG_SLABINFO=y
> # CONFIG_SLUB_DEBUG_ON is not set
> CONFIG_SLUB_STATS=y

Thats fine.

> But I think you are now surprised, when I say no slub_debug options
> were on.  Here's the output from /sys/kernel/slab/pgtable-2^12/*
> (before I tried the new kernel with Aneesh's fix patch)
> in case they tell you anything...
>
> pgtable-2^12/poison:0
> pgtable-2^12/red_zone:0
> pgtable-2^12/reserved:0
> pgtable-2^12/sanity_checks:0
> pgtable-2^12/store_user:0

Ok so debugging was off but the slab cache has a ctor callback which
mandates that the free pointer cannot use the free object space when
the object is not in use. Thus the size of the object must be increased to
accomodate the freepointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
