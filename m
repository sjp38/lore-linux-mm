Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D447E6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 16:32:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y138so38804888wme.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:32:21 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id u2si18210969wjy.214.2016.10.24.13.32.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 13:32:20 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c78so545693wme.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 13:32:20 -0700 (PDT)
Date: Mon, 24 Oct 2016 22:32:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid maybe-uninitialized warning
Message-ID: <20161024203218.GF13148@dhcp22.suse.cz>
References: <20161024152511.2597880-1-arnd@arndb.de>
 <20161024162243.GA13148@dhcp22.suse.cz>
 <4142781.4gMiS9Brv9@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4142781.4gMiS9Brv9@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Gruenbacher <agruenba@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 24-10-16 21:42:36, Arnd Bergmann wrote:
> On Monday, October 24, 2016 6:22:44 PM CEST Michal Hocko wrote:
> > On Mon 24-10-16 17:25:03, Arnd Bergmann wrote:
> > > After enabling -Wmaybe-uninitialized warnings, we get a false-postive
> > > warning for shmem:
> > > 
> > > mm/shmem.c: In function a??shmem_getpage_gfpa??:
> > > include/linux/spinlock.h:332:21: error: a??infoa?? may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > 
> > Is this really a false positive? If we goto clear and then 
> >         if (sgp <= SGP_CACHE &&
> >             ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
> >                 if (alloced) {
> > 
> > we could really take a spinlock on an unitialized variable. But maybe
> > there is something that prevents from that...
> 
> I did the patch a few weeks ago (I sent the more important
> ones out first) and I think I concluded then that 'alloced'
> would be false in that case.

OK, I guess you are right and alloced is set only after info has been
already initialized. So this really looks like a false positive.

> 
> > Anyway the whole shmem_getpage_gfp is really hard to follow due to gotos
> > and labels proliferation.
> 
> Exactly. Maybe we should mark the patch for -stable backports after all
> just to be sure.

I am not really sure a stable backport is really necessary but a cleanup
in this area would be more than welcome. At least from me ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
