Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D3AC66B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 15:46:13 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t15so73891wmh.3
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 12:46:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10si10443984wrh.426.2017.12.18.12.46.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 12:46:12 -0800 (PST)
Date: Mon, 18 Dec 2017 21:46:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: make unregister_shrinker() safer
Message-ID: <20171218204610.GS16951@dhcp22.suse.cz>
References: <20171216192937.13549-1-akaraliou.dev@gmail.com>
 <20171218084948.GK16951@dhcp22.suse.cz>
 <04b38213-5330-bf47-8865-eee7e18b8612@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04b38213-5330-bf47-8865-eee7e18b8612@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak <akaraliou.dev@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Mon 18-12-17 21:34:20, ak wrote:
> On 12/18/2017 11:49 AM, Michal Hocko wrote:
> 
> > On Sat 16-12-17 22:29:37, Aliaksei Karaliou wrote:
> > > unregister_shrinker() does not have any sanitizing inside so
> > > calling it twice will oops because of double free attempt or so.
> > > This patch makes unregister_shrinker() safer and allows calling
> > > it on resource freeing path without explicit knowledge of whether
> > > shrinker was successfully registered or not.
> > Tetsuo has made it half way to this already [1]. So maybe we should
> > fold shrinker->nr_deferred = NULL to his patch and finally merge it.
> > 
> > [1] http://lkml.kernel.org/r/1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
>
> Yeah, no problem from my side.
> I'm sorry, it seems that I haven't done enough research to realize
> that someone is already looking at that place.

Absolutely no reason to be worried. This happens all the time ;)
 
> The only my concern/question is whether we should also add some
> paranoid stuff in that extra branch (check that list is empty for
> example) or not.

I wouldn't bother. There are two reasons to actually care here: a) to
make registration code easier (so that they can call unregister_shrinker
even on path with failed register_shrinker - e.g. sget_userns would
become more complex if we had to special case the failure) and b) to not
blow up on the double unregister which is an alternative of a).

We really do not need this to be super clever, it is an internal
function.

> > > Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
> > > ---
> > >   mm/vmscan.c | 4 ++++
> > >   1 file changed, 4 insertions(+)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 65c4fa26abfa..7cb56db5e9ca 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -281,10 +281,14 @@ EXPORT_SYMBOL(register_shrinker);
> > >    */
> > >   void unregister_shrinker(struct shrinker *shrinker)
> > >   {
> > > +	if (!shrinker->nr_deferred)
> > > +		return;
> > > +
> > >   	down_write(&shrinker_rwsem);
> > >   	list_del(&shrinker->list);
> > >   	up_write(&shrinker_rwsem);
> > >   	kfree(shrinker->nr_deferred);
> > > +	shrinker->nr_deferred = NULL;
> > >   }
> > >   EXPORT_SYMBOL(unregister_shrinker);
> > > -- 
> > > 2.11.0
> > > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
