Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABA86B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 23:30:17 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so16249984pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 20:30:17 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id z9si14053654par.42.2016.01.27.20.30.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 20:30:16 -0800 (PST)
Date: Thu, 28 Jan 2016 13:25:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH/RFC 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
Message-ID: <20160128042510.GB14467@js1304-P5Q-DELUXE>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
 <1453799905-10941-4-git-send-email-borntraeger@de.ibm.com>
 <20160126181903.GB4671@osiris>
 <alpine.DEB.2.10.1601261525580.25141@chino.kir.corp.google.com>
 <20160127001918.GA7089@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1601261633520.6121@chino.kir.corp.google.com>
 <20160127005920.GB7089@js1304-P5Q-DELUXE>
 <56A8BB15.9070305@suse.cz>
 <56A8BC6D.9080101@de.ibm.com>
 <56A8C028.7050305@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A8C028.7050305@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, David Rientjes <rientjes@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org

On Wed, Jan 27, 2016 at 02:03:36PM +0100, Vlastimil Babka wrote:
> On 01/27/2016 01:47 PM, Christian Borntraeger wrote:
> > On 01/27/2016 01:41 PM, Vlastimil Babka wrote:
> >> On 01/27/2016 01:59 AM, Joonsoo Kim wrote:
> >> 
> >> I think it might be worth also to convert debug_pagealloc_enabled() to be based
> >> on static key, like I did for page_owner [1]. That should help make it possible
> >> to have virtually no overhead when compiling kernel with CONFIG_DEBUG_PAGEALLOC
> >> without enabling it boot-time. I assume it's one of the goals here?
> > 
> > We could do something like that but dump_stack and setup of the initial identity
> > mapping of the kernel as well as the initial page protection are not hot path
> > as far as I can tell. Any other places?
> 
> Well, mostly kernel_map_pages() which is used in page allocation hotpaths.

We cannot just convert it because setup_arch() is called before
jump_label_init(). We can do it by introducing _early variant but
I'm not sure it's worth doing. I think that just make it unlikely
works well. Recently, I tested a micro benchmark on slab alloc/free
on CONFIG_SLUB with applying static branch for debug option which
currently is using unlikely branch and can't find any noticeble
performance difference.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
