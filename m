Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AAFC6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 21:59:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so41460646pfa.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 18:59:51 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id a5si2091739pgg.89.2017.01.18.18.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 18:59:50 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 75so2856861pgf.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 18:59:50 -0800 (PST)
Date: Thu, 19 Jan 2017 12:00:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Message-ID: <20170119030004.GA2046@jagdpanzerIV.localdomain>
References: <bug-192571-27@https.bugzilla.kernel.org/>
 <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain>
 <20170118131711.GA7021@dhcp22.suse.cz>
 <CALZtONC9Y67vL90_SXfQq7ZNqWgdFZESOwHJuQnWChNCQKcHHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONC9Y67vL90_SXfQq7ZNqWgdFZESOwHJuQnWChNCQKcHHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, sss123next@list.ru, Seth Jennings <sjenning@redhat.com>, Minchan Kim <minchan@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On (01/18/17 20:36), Dan Streetman wrote:
> On Wed, Jan 18, 2017 at 8:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 18-01-17 10:39:48, Sergey Senozhatsky wrote:
> >> Cc Dan
> >>
> >> On (01/17/17 12:22), Andrew Morton wrote:
> >> > > https://bugzilla.kernel.org/show_bug.cgi?id=192571
> >> > >
> >> > > --- Comment #1 from Gluzskiy Alexandr <sss123next@list.ru> ---
> >> > > [199961.576604] ------------[ cut here ]------------
> >> > > [199961.577830] kernel BUG at mm/zswap.c:1108!
> >>
> >> zswap didn't manage to decompress the page:
> >>
> >> static int zswap_frontswap_load(unsigned type, pgoff_t offset,
> >>                               struct page *page)
> >> {
> >> ...
> >>       dst = kmap_atomic(page);
> >>       tfm = *get_cpu_ptr(entry->pool->tfm);
> >>       ret = crypto_comp_decompress(tfm, src, entry->length, dst, &dlen);
> >>       put_cpu_ptr(entry->pool->tfm);
> >>       kunmap_atomic(dst);
> >>       zpool_unmap_handle(entry->pool->zpool, entry->handle);
> >>       BUG_ON(ret);
> >>       ^^^^^^^^^^^
> >
> > Ugh, why do we even do that? This is not the way how to handle error
> > situations. AFAIU propagating the error out wouldn't be a big deal
> > because we would just fallback to regular swap, right?
> 
> yeah this function definitely should never bug; it's just a callback
> from the zpool to try to write a page back to the swapcache so the
> zpool can free a page.  It's definitely ok for it to return an error.
> 

good. Dan, Seth, care to send the patch?
and one more thing... can you take a look at [1]?

[1] https://marc.info/?l=linux-mm&m=147031191906154&w=4

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
