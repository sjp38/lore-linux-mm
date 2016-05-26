Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A601D6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 09:59:39 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id yu3so127342835obb.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 06:59:39 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0113.outbound.protection.outlook.com. [157.56.112.113])
        by mx.google.com with ESMTPS id t131si9881886oig.155.2016.05.26.06.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 May 2016 06:59:38 -0700 (PDT)
Date: Thu, 26 May 2016 16:59:30 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Message-ID: <20160526135930.GA26059@esperanza>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
 <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160524161336.GA11150@esperanza>
 <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160525103011.GF11150@esperanza>
 <20160526070455.GF9661@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160526070455.GF9661@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, May 26, 2016 at 04:04:55PM +0900, Minchan Kim wrote:
> On Wed, May 25, 2016 at 01:30:11PM +0300, Vladimir Davydov wrote:
> > On Tue, May 24, 2016 at 01:04:33PM -0700, Eric Dumazet wrote:
> > > On Tue, 2016-05-24 at 19:13 +0300, Vladimir Davydov wrote:
> > > > On Tue, May 24, 2016 at 05:59:02AM -0700, Eric Dumazet wrote:
> > > > ...
> > > > > > +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> > > > > > +			       struct pipe_buffer *buf)
> > > > > > +{
> > > > > > +	struct page *page = buf->page;
> > > > > > +
> > > > > > +	if (page_count(page) == 1) {
> > > > > 
> > > > > This looks racy : some cpu could have temporarily elevated page count.
> > > > 
> > > > All pipe operations (pipe_buf_operations->get, ->release, ->steal) are
> > > > supposed to be called under pipe_lock. So, if we see a pipe_buffer->page
> > > > with refcount of 1 in ->steal, that means that we are the only its user
> > > > and it can't be spliced to another pipe.
> > > > 
> > > > In fact, I just copied the code from generic_pipe_buf_steal, adding
> > > > kmemcg related checks along the way, so it should be fine.
> > > 
> > > So you guarantee that no other cpu might have done
> > > get_page_unless_zero() right before this test ?
> > 
> > Each pipe_buffer holds a reference to its page. If we find page's
> > refcount to be 1 here, then it can be referenced only by our
> > pipe_buffer. And the refcount cannot be increased by a parallel thread,
> > because we hold pipe_lock, which rules out splice, and otherwise it's
> > impossible to reach the page as it is not on lru. That said, I think I
> > guarantee that this should be safe.
> 
> I don't know kmemcg internal and pipe stuff so my comment might be
> totally crap.
> 
> No one cannot guarantee any CPU cannot held a reference of a page.
> Look at get_page_unless_zero usecases.
> 
> 1. balloon_page_isolate
> 
> It can hold a reference in random page and then verify the page
> is balloon page. Otherwise, just put.
> 
> 2. page_idle_get_page
> 
> It has PageLRU check but it's racy so it can hold a reference
> of randome page and then verify within zone->lru_lock. If it's
> not LRU page, just put.

Well, I see your concern now - even if a page is not on lru and we
locked all structs pointing to it, it can always get accessed by pfn in
a completely unrelated thread, like in examples you gave above. That's a
fair point.

However, I still think that it's OK in case of pipe buffers. What can
happen if somebody takes a transient reference to a pipe buffer page? At
worst, we'll see page_count > 1 due to temporary ref and abort stealing,
falling back on copying instead. That's OK, because stealing is not
guaranteed. Can a function that takes a transient ref to page by pfn
mistakenly assume that this is a page it's interested in? I don't think
so, because this page has no marks on it except special _mapcount value,
which should only be set on kmemcg pages.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
