Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEC406B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 03:04:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 190so124608575iow.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 00:04:36 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 16si2934486itm.77.2016.05.26.00.04.34
        for <linux-mm@kvack.org>;
        Thu, 26 May 2016 00:04:35 -0700 (PDT)
Date: Thu, 26 May 2016 16:04:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Message-ID: <20160526070455.GF9661@bbox>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
 <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160524161336.GA11150@esperanza>
 <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160525103011.GF11150@esperanza>
MIME-Version: 1.0
In-Reply-To: <20160525103011.GF11150@esperanza>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Wed, May 25, 2016 at 01:30:11PM +0300, Vladimir Davydov wrote:
> On Tue, May 24, 2016 at 01:04:33PM -0700, Eric Dumazet wrote:
> > On Tue, 2016-05-24 at 19:13 +0300, Vladimir Davydov wrote:
> > > On Tue, May 24, 2016 at 05:59:02AM -0700, Eric Dumazet wrote:
> > > ...
> > > > > +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> > > > > +			       struct pipe_buffer *buf)
> > > > > +{
> > > > > +	struct page *page = buf->page;
> > > > > +
> > > > > +	if (page_count(page) == 1) {
> > > > 
> > > > This looks racy : some cpu could have temporarily elevated page count.
> > > 
> > > All pipe operations (pipe_buf_operations->get, ->release, ->steal) are
> > > supposed to be called under pipe_lock. So, if we see a pipe_buffer->page
> > > with refcount of 1 in ->steal, that means that we are the only its user
> > > and it can't be spliced to another pipe.
> > > 
> > > In fact, I just copied the code from generic_pipe_buf_steal, adding
> > > kmemcg related checks along the way, so it should be fine.
> > 
> > So you guarantee that no other cpu might have done
> > get_page_unless_zero() right before this test ?
> 
> Each pipe_buffer holds a reference to its page. If we find page's
> refcount to be 1 here, then it can be referenced only by our
> pipe_buffer. And the refcount cannot be increased by a parallel thread,
> because we hold pipe_lock, which rules out splice, and otherwise it's
> impossible to reach the page as it is not on lru. That said, I think I
> guarantee that this should be safe.

I don't know kmemcg internal and pipe stuff so my comment might be
totally crap.

No one cannot guarantee any CPU cannot held a reference of a page.
Look at get_page_unless_zero usecases.

1. balloon_page_isolate

It can hold a reference in random page and then verify the page
is balloon page. Otherwise, just put.

2. page_idle_get_page

It has PageLRU check but it's racy so it can hold a reference
of randome page and then verify within zone->lru_lock. If it's
not LRU page, just put.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
