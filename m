Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABDA6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 02:34:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so29799189lfa.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 23:34:44 -0700 (PDT)
Received: from mail-lb0-f194.google.com (mail-lb0-f194.google.com. [209.85.217.194])
        by mx.google.com with ESMTPS id 20si23995121ljj.0.2016.06.21.23.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 23:34:43 -0700 (PDT)
Received: by mail-lb0-f194.google.com with SMTP id td3so3236334lbb.2
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 23:34:43 -0700 (PDT)
Date: Wed, 22 Jun 2016 08:34:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into
 a helper
Message-ID: <20160622063441.GA7520@dhcp22.suse.cz>
References: <06be01d1cb9c$8f235850$ad6a08f0$@alibaba-inc.com>
 <06bf01d1cb9f$32a49320$97edb960$@alibaba-inc.com>
 <20160621111716.GD30848@dhcp22.suse.cz>
 <06e801d1cc34$920d5cd0$b6281670$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06e801d1cc34$920d5cd0$b6281670$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Oleg Nesterov' <oleg@redhat.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 22-06-16 11:17:12, Hillf Danton wrote:
> 
> > > > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > > > index 968d5ea06e62..a6a8fbdd5a1b 100644
> > > > --- a/fs/proc/base.c
> > > > +++ b/fs/proc/base.c
> > > > @@ -1037,7 +1037,47 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
> > > >  	return simple_read_from_buffer(buf, count, ppos, buffer, len);
> > > >  }
> > > >
> > > > -static DEFINE_MUTEX(oom_adj_mutex);
> > > > +static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> > > > +{
> > > > +	static DEFINE_MUTEX(oom_adj_mutex);
> > >
> > > Writers are not excluded for readers!
> > > Is this a hot path?
> > 
> > I am not sure I follow you question. This is a write path... Who would
> > be the reader?
> > 
> Currently oom_adj_read() and oom_adj_write() are serialized with 
> task->sighand->siglock, and in this work oom_adj_mutex is introduced to
> only keep writers in hose.

OK, I see your point now. I didn't bother with the serialization with
readers because I believe it doesn't matter so much. Readers would
have to synchronize with writers to make sure they are seeing the most
current value otherwise you could see an outdated value anyway. It's
not like you would see a "corrupted" value without lock.

The primary point of the lock is to make sure that parallel updaters
cannot allow non-priviledged user to escape the restrictions.

If you see any specific scenario which would suffer from the lack of
serialization I can add the lock to readers as well.
 
> Plus, oom_adj_write() and oom_badness() are currently serialized 
> with task->alloc_lock, and they may be handled in subsequent patches.

alloc_lock is there just to make sure we see the proper mm.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
