Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B2D476B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:08:32 -0400 (EDT)
Received: by mail-da0-f49.google.com with SMTP id t11so388642daj.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:08:31 -0700 (PDT)
Date: Wed, 10 Apr 2013 15:08:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 2/3] resource: Add release_mem_region_adjustable()
In-Reply-To: <1365630585.32127.110.camel@misato.fc.hp.com>
Message-ID: <alpine.DEB.2.02.1304101505250.1526@chino.kir.corp.google.com>
References: <1365614221-685-1-git-send-email-toshi.kani@hp.com> <1365614221-685-3-git-send-email-toshi.kani@hp.com> <20130410144412.395bf9f2fb8192920175e30a@linux-foundation.org> <1365630585.32127.110.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxram@us.ibm.com, guz.fnst@cn.fujitsu.com, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, 10 Apr 2013, Toshi Kani wrote:

> > I'll switch it to GFP_ATOMIC.  Which is horridly lame but the
> > allocation is small and alternatives are unobvious.
> 
> Great!  Again, thanks for the update!

release_mem_region_adjustable() allocates at most one struct resource, so 
why not do kmalloc(sizeof(struct resource), GFP_KERNEL) before taking 
resource_lock and then testing whether it's NULL or not when splitting?  
It unnecessarily allocates memory when there's no split, but 
__remove_pages() shouldn't be a hotpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
