Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0176B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:09:30 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id l61so5745982wev.13
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:09:30 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id ew10si33909926wic.34.2015.02.11.12.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 12:09:29 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id r20so20074628wiv.2
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:09:28 -0800 (PST)
Date: Wed, 11 Feb 2015 12:09:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slub: kmem_cache_shrink: init discard list after
 freeing slabs
In-Reply-To: <20150211154128.GA26049@esperanza>
Message-ID: <alpine.DEB.2.10.1502111206150.16711@chino.kir.corp.google.com>
References: <1423627463.5968.99.camel@intel.com> <1423642582-23553-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.11.1502110851180.32065@gentwo.org> <alpine.DEB.2.11.1502110857410.948@gentwo.org> <20150211154128.GA26049@esperanza>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, 11 Feb 2015, Vladimir Davydov wrote:

> Currently, the discard list is only initialized at the beginning of the
> function. As a result, if there are > 1 nodes, we can get use-after-free
> while processing the second or higher node:
> 
>     WARNING: CPU: 60 PID: 1 at lib/list_debug.c:29 __list_add+0x3c/0xa9()
>     list_add corruption. next->prev should be prev (ffff881ff0a6bb98), but was ffffea007ff57020. (next=ffffea007fbf7320).
>     Modules linked in:
>     CPU: 60 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc7-next-20150203-gb50cadf #2178
>     Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BIVTSDP1.86B.0038.R02.1307231126 07/23/2013
>      0000000000000009 ffff881ff0a6ba88 ffffffff81c2e096 ffffffff810e2d03
>      ffff881ff0a6bad8 ffff881ff0a6bac8 ffffffff8108b320 ffff881ff0a6bb18
>      ffffffff8154bbc7 ffff881ff0a6bb98 ffffea007fbf7320 ffffea00ffc3c220
>     Call Trace:
>      [<ffffffff81c2e096>] dump_stack+0x4c/0x65
>      [<ffffffff810e2d03>] ? console_unlock+0x398/0x3c7
>      [<ffffffff8108b320>] warn_slowpath_common+0xa1/0xbb
>      [<ffffffff8154bbc7>] ? __list_add+0x3c/0xa9
>      [<ffffffff8108b380>] warn_slowpath_fmt+0x46/0x48
>      [<ffffffff8154bbc7>] __list_add+0x3c/0xa9
>      [<ffffffff811bf5aa>] __kmem_cache_shrink+0x12b/0x24c
>      [<ffffffff81190ca9>] kmem_cache_shrink+0x26/0x38
>      [<ffffffff815848b4>] acpi_os_purge_cache+0xe/0x12
>      [<ffffffff815c6424>] acpi_purge_cached_objects+0x32/0x7a
>      [<ffffffff825f70f1>] acpi_initialize_objects+0x17e/0x1ae
>      [<ffffffff825f5177>] ? acpi_sleep_proc_init+0x2a/0x2a
>      [<ffffffff825f5209>] acpi_init+0x92/0x25e
>      [<ffffffff810002bd>] ? do_one_initcall+0x90/0x17f
>      [<ffffffff811bdfcd>] ? kfree+0x1fc/0x2d5
>      [<ffffffff825f5177>] ? acpi_sleep_proc_init+0x2a/0x2a
>      [<ffffffff8100031a>] do_one_initcall+0xed/0x17f
>      [<ffffffff825ae0e2>] kernel_init_freeable+0x1f0/0x278
>      [<ffffffff81c1f31a>] ? rest_init+0x13e/0x13e
>      [<ffffffff81c1f328>] kernel_init+0xe/0xda
>      [<ffffffff81c3ca7c>] ret_from_fork+0x7c/0xb0
>      [<ffffffff81c1f31a>] ? rest_init+0x13e/0x13e
> 
> Fix this by initializing the discard list at each iteration of the
> for_each_kmem_cache_node loop. Also, move promote lists initialization
> to the beginning of the loop to conform.
> 
> fixes: slub-never-fail-to-shrink-cache

8f44a586ac86 ("slub: never fail to shrink cache")

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Reported-by: Huang Ying <ying.huang@intel.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
