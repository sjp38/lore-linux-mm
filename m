Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2F776B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 23:17:18 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id he1so64817632pac.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 20:17:18 -0700 (PDT)
Received: from out4133-18.mail.aliyun.com (out4133-18.mail.aliyun.com. [42.120.133.18])
        by mx.google.com with ESMTP id t6si43974726pfb.72.2016.06.21.20.17.17
        for <linux-mm@kvack.org>;
        Tue, 21 Jun 2016 20:17:17 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <06be01d1cb9c$8f235850$ad6a08f0$@alibaba-inc.com> <06bf01d1cb9f$32a49320$97edb960$@alibaba-inc.com> <20160621111716.GD30848@dhcp22.suse.cz>
In-Reply-To: <20160621111716.GD30848@dhcp22.suse.cz>
Subject: Re: [PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into a helper
Date: Wed, 22 Jun 2016 11:17:12 +0800
Message-ID: <06e801d1cc34$920d5cd0$b6281670$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: 'Oleg Nesterov' <oleg@redhat.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> > > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > > index 968d5ea06e62..a6a8fbdd5a1b 100644
> > > --- a/fs/proc/base.c
> > > +++ b/fs/proc/base.c
> > > @@ -1037,7 +1037,47 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
> > >  	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> > >  }
> > >
> > > -static DEFINE_MUTEX(oom_adj_mutex);
> > > +static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> > > +{
> > > +	static DEFINE_MUTEX(oom_adj_mutex);
> >
> > Writers are not excluded for readers!
> > Is this a hot path?
> 
> I am not sure I follow you question. This is a write path... Who would
> be the reader?
> 
Currently oom_adj_read() and oom_adj_write() are serialized with 
task->sighand->siglock, and in this work oom_adj_mutex is introduced to
only keep writers in hose.

Plus, oom_adj_write() and oom_badness() are currently serialized 
with task->alloc_lock, and they may be handled in subsequent patches.

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
