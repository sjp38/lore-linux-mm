Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4996B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so2433730wjd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p198si20033729wmb.10.2017.01.18.05.17.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 05:17:15 -0800 (PST)
Date: Wed, 18 Jan 2017 14:17:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Message-ID: <20170118131711.GA7021@dhcp22.suse.cz>
References: <bug-192571-27@https.bugzilla.kernel.org/>
 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118013948.GA580@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: sss123next@list.ru, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 18-01-17 10:39:48, Sergey Senozhatsky wrote:
> Cc Dan
> 
> On (01/17/17 12:22), Andrew Morton wrote:
> > > https://bugzilla.kernel.org/show_bug.cgi?id=192571
> > > 
> > > --- Comment #1 from Gluzskiy Alexandr <sss123next@list.ru> ---
> > > [199961.576604] ------------[ cut here ]------------
> > > [199961.577830] kernel BUG at mm/zswap.c:1108!
> 
> zswap didn't manage to decompress the page:
> 
> static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> 				struct page *page)
> {
> ...
> 	dst = kmap_atomic(page);
> 	tfm = *get_cpu_ptr(entry->pool->tfm);
> 	ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
> 	put_cpu_ptr(entry->pool->tfm);
> 	kunmap_atomic(dst);
> 	zpool_unmap_handle(entry->pool->zpool, entry->handle);
> 	BUG_ON(ret);
> 	^^^^^^^^^^^

Ugh, why do we even do that? This is not the way how to handle error
situations. AFAIU propagating the error out wouldn't be a big deal
because we would just fallback to regular swap, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
