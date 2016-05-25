Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB42B6B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 06:30:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r64so68012176oie.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 03:30:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0115.outbound.protection.outlook.com. [104.47.2.115])
        by mx.google.com with ESMTPS id b6si4708362otc.116.2016.05.25.03.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 May 2016 03:30:23 -0700 (PDT)
Date: Wed, 25 May 2016 13:30:11 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Message-ID: <20160525103011.GF11150@esperanza>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
 <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160524161336.GA11150@esperanza>
 <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2016 at 01:04:33PM -0700, Eric Dumazet wrote:
> On Tue, 2016-05-24 at 19:13 +0300, Vladimir Davydov wrote:
> > On Tue, May 24, 2016 at 05:59:02AM -0700, Eric Dumazet wrote:
> > ...
> > > > +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> > > > +			       struct pipe_buffer *buf)
> > > > +{
> > > > +	struct page *page = buf->page;
> > > > +
> > > > +	if (page_count(page) == 1) {
> > > 
> > > This looks racy : some cpu could have temporarily elevated page count.
> > 
> > All pipe operations (pipe_buf_operations->get, ->release, ->steal) are
> > supposed to be called under pipe_lock. So, if we see a pipe_buffer->page
> > with refcount of 1 in ->steal, that means that we are the only its user
> > and it can't be spliced to another pipe.
> > 
> > In fact, I just copied the code from generic_pipe_buf_steal, adding
> > kmemcg related checks along the way, so it should be fine.
> 
> So you guarantee that no other cpu might have done
> get_page_unless_zero() right before this test ?

Each pipe_buffer holds a reference to its page. If we find page's
refcount to be 1 here, then it can be referenced only by our
pipe_buffer. And the refcount cannot be increased by a parallel thread,
because we hold pipe_lock, which rules out splice, and otherwise it's
impossible to reach the page as it is not on lru. That said, I think I
guarantee that this should be safe.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
