Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E4A6A6B2A6E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:51:56 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q12-v6so2938079pgp.6
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:51:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si4410509plw.99.2018.08.23.06.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 06:51:55 -0700 (PDT)
Date: Thu, 23 Aug 2018 15:51:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] xen/gntdev: fix up blockable calls to mn_invl_range_start
Message-ID: <20180823135151.GM29735@dhcp22.suse.cz>
References: <20180823120707.10998-1-mhocko@kernel.org>
 <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07c7ead4-334d-9b25-f588-25e9b46bbea0@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, LKML <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>

On Thu 23-08-18 22:44:07, Tetsuo Handa wrote:
> On 2018/08/23 21:07, Michal Hocko wrote:
> > diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> > index 57390c7666e5..e7d8bb1bee2a 100644
> > --- a/drivers/xen/gntdev.c
> > +++ b/drivers/xen/gntdev.c
> > @@ -519,21 +519,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
> >  	struct gntdev_grant_map *map;
> >  	int ret = 0;
> >  
> > -	/* TODO do we really need a mutex here? */
> >  	if (blockable)
> >  		mutex_lock(&priv->lock);
> >  	else if (!mutex_trylock(&priv->lock))
> >  		return -EAGAIN;
> >  
> >  	list_for_each_entry(map, &priv->maps, next) {
> > -		if (in_range(map, start, end)) {
> > +		if (!blockable && in_range(map, start, end)) {
> 
> This still looks strange. Prior to 93065ac753e4, in_range() test was
> inside unmap_if_in_range(). But this patch removes in_range() test
> if blockable == true. That is, unmap_if_in_range() will unconditionally
> unmap if blockable == true, which seems to be an unexpected change.

You are right. I completely forgot I've removed in_range there. Does
this look any better?

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index e7d8bb1bee2a..30f81004ea63 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -525,14 +525,20 @@ static int mn_invl_range_start(struct mmu_notifier *mn,
 		return -EAGAIN;
 
 	list_for_each_entry(map, &priv->maps, next) {
-		if (!blockable && in_range(map, start, end)) {
+		if (in_range(map, start, end)) {
+			if (blockable)
+				continue;
+
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
 		unmap_if_in_range(map, start, end);
 	}
 	list_for_each_entry(map, &priv->freeable_maps, next) {
-		if (!blockable && in_range(map, start, end)) {
+		if (in_range(map, start, end)) {
+			if (blockable)
+				continue;
+			
 			ret = -EAGAIN;
 			goto out_unlock;
 		}
-- 
Michal Hocko
SUSE Labs
