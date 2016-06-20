Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7E566B0260
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:35:08 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id nq2so24763348lbc.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:35:08 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n66si14858189wmg.5.2016.06.20.02.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 02:35:07 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r201so12538748wme.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:35:07 -0700 (PDT)
Date: Mon, 20 Jun 2016 11:35:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160620093505.GA4601@dhcp22.suse.cz>
References: <1466154017-2222-1-git-send-email-mhocko@kernel.org>
 <20160618025904-mutt-send-email-mst@redhat.com>
 <20160619213543.GA32752@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160619213543.GA32752@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>

On Sun 19-06-16 23:35:43, Michal Hocko wrote:
> On Sat 18-06-16 03:09:02, Michael S. Tsirkin wrote:
> > On Fri, Jun 17, 2016 at 11:00:17AM +0200, Michal Hocko wrote:
[...]
> > > diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> > > index 349557825428..b1f314fca3c8 100644
> > > --- a/include/linux/uaccess.h
> > > +++ b/include/linux/uaccess.h
> > > @@ -76,6 +76,28 @@ static inline unsigned long __copy_from_user_nocache(void *to,
> > >  #endif		/* ARCH_HAS_NOCACHE_UACCESS */
> > >  
> > >  /*
> > > + * A safe variant of __get_user for for use_mm() users to have a
> > > + * gurantee that the address space wasn't reaped in the background
> > > + */
> > > +#define __get_user_mm(mm, x, ptr)				\
> > > +({								\
> > > +	int ___gu_err = __get_user(x, ptr);			\
> > > +	if (!___gu_err && test_bit(MMF_UNSTABLE, &mm->flags))	\
> > 
> > test_bit is somewhat expensive. See my old mail
> > 	x86/bitops: implement __test_bit
> 
> Do you have a msg_id?
> 
> > I dropped it as virtio just switched to simple &/| for features,
> > but we might need something like this now.
> 
> Is this such a hot path that something like this would make a visible
> difference? 

OK, so I've tried to apply your patch [1] and updated both __get_user_mm
and __copy_from_user_mm and the result is a code size reduction:
   text    data     bss     dec     hex filename
  12835       2      32   12869    3245 drivers/vhost/vhost.o
  12882       2      32   12916    3274 drivers/vhost/vhost.o.before

This is really tiny and I cannot tell anything about the performance. Should
I resurrect your patch and push it together with this change or this can happen
later?

[1] http://lkml.kernel.org/r/1440776707-22016-1-git-send-email-mst@redhat.com
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
