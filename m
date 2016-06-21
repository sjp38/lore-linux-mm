Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8226B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:17:20 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id c1so11083426lbw.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:17:20 -0700 (PDT)
Received: from mail-lb0-f196.google.com (mail-lb0-f196.google.com. [209.85.217.196])
        by mx.google.com with ESMTPS id i127si29656753lfd.61.2016.06.21.04.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 04:17:19 -0700 (PDT)
Received: by mail-lb0-f196.google.com with SMTP id td3so1490665lbb.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 04:17:19 -0700 (PDT)
Date: Tue, 21 Jun 2016 13:17:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into
 a helper
Message-ID: <20160621111716.GD30848@dhcp22.suse.cz>
References: <06be01d1cb9c$8f235850$ad6a08f0$@alibaba-inc.com>
 <06bf01d1cb9f$32a49320$97edb960$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06bf01d1cb9f$32a49320$97edb960$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Oleg Nesterov' <oleg@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 21-06-16 17:27:57, Hillf Danton wrote:
> > 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Currently we have two proc interfaces to set oom_score_adj. The legacy
> > /proc/<pid>/oom_adj and /proc/<pid>/oom_score_adj which both have their
> > specific handlers. Big part of the logic is duplicated so extract the
> > common code into __set_oom_adj helper. Legacy knob still expects some
> > details slightly different so make sure those are handled same way - e.g.
> > the legacy mode ignores oom_score_adj_min and it warns about the usage.
> > 
> > This patch shouldn't introduce any functional changes.
> > 
> > Acked-by: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  fs/proc/base.c | 94 +++++++++++++++++++++++++++-------------------------------
> >  1 file changed, 43 insertions(+), 51 deletions(-)
> > 
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index 968d5ea06e62..a6a8fbdd5a1b 100644
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1037,7 +1037,47 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
> >  	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> >  }
> > 
> > -static DEFINE_MUTEX(oom_adj_mutex);
> > +static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> > +{
> > +	static DEFINE_MUTEX(oom_adj_mutex);
> 
> Writers are not excluded for readers!
> Is this a hot path?

I am not sure I follow you question. This is a write path... Who would
be the reader?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
