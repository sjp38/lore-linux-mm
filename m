Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7A46B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:37:14 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so66042644wic.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:37:13 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id ly8si10938587wic.103.2015.10.21.02.37.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 02:37:13 -0700 (PDT)
Received: by wikq8 with SMTP id q8so84517073wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:37:12 -0700 (PDT)
Date: Wed, 21 Oct 2015 11:37:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4.3-rc6] proc: fix oom_adj value read from
 /proc/<pid>/oom_adj
Message-ID: <20151021093710.GA8799@dhcp22.suse.cz>
References: <65a10261038346b1a778443fd15f0980@SHMBX01.spreadtrum.com>
 <87zizdfo0x.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87zizdfo0x.fsf@x220.int.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hongjie Fang =?utf-8?B?KOaWuea0quadsCk=?= <Hongjie.Fang@spreadtrum.com>, "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

[CC David as well]

The original patch has been posted here:
http://lkml.kernel.org/r/65a10261038346b1a778443fd15f0980%40SHMBX01.spreadtrum.com

On Tue 20-10-15 12:27:58, Eric W. Biederman wrote:
> "Hongjie Fang (ae?1ae'aae??)" <Hongjie.Fang@spreadtrum.com> writes:
> 
> > The oom_adj's value reading through /proc/<pid>/oom_adj is different 
> > with the value written into /proc/<pid>/oom_adj.
> > Fix this by adding a adjustment factor.
> 
> *Scratches my head*
> 
> Won't changing the interpretation of what is written break existing
> userspace applications that write this value?

No, because they will see the same value they wrote. The current state
is broken because you get a different value than you wrote.

I am just wondering, how have you found this problem? Code review or
have you encountered a real failure because of this?

> Added a few more likely memory management suspects that might understand
> what is going on here.
> 
> Eric
> 
> >
> > Signed-off-by: Hongjie Fang <hongjie.fang@spreadtrum.com>
> > ---
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index b25eee4..1ea0589 100644
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1043,6 +1043,7 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
> >  	int oom_adj;
> >  	unsigned long flags;
> >  	int err;
> > +	int adjust;

This doesn't need the function visibility.

> >  
> >  	memset(buffer, 0, sizeof(buffer));
> >  	if (count > sizeof(buffer) - 1)
> > @@ -1084,8 +1085,10 @@ static ssize_t oom_adj_write(struct file *file, const char __user *buf,
> >  	 */
> >  	if (oom_adj == OOM_ADJUST_MAX)
> >  		oom_adj = OOM_SCORE_ADJ_MAX;
> > -	else
> > -		oom_adj = (oom_adj * OOM_SCORE_ADJ_MAX) / -OOM_DISABLE;
> > +	else{

space after else and checkpatch will probably complain about missing { }
for if...

Other than that the patch looks good to me. The changelog coul be
slightly improved as well.

> > +		adjust = oom_adj > 0 ? (-OOM_DISABLE-1) : -(-OOM_DISABLE-1);
> > +		oom_adj = (oom_adj * OOM_SCORE_ADJ_MAX + adjust) / -OOM_DISABLE;
> > +	}
> >  
> >  	if (oom_adj < task->signal->oom_score_adj &&
> >  	    !capable(CAP_SYS_RESOURCE)) {
> >
> > --
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
