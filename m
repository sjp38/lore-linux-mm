Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4021D6B026B
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 11:33:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so3434361wra.3
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 08:33:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g61si15551edd.365.2017.09.20.08.33.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Sep 2017 08:33:29 -0700 (PDT)
Date: Wed, 20 Sep 2017 17:33:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] mm: introduce validity check on vm dirtiness settings
Message-ID: <20170920153326.GH11106@quack2.suse.cz>
References: <1505775180-12014-1-git-send-email-laoar.shao@gmail.com>
 <20170919083554.GC3216@quack2.suse.cz>
 <CALOAHbAhnno94Jo1uLe3QzYhbAsc=wuHVXTvurCoVhe6YFnPyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAhnno94Jo1uLe3QzYhbAsc=wuHVXTvurCoVhe6YFnPyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, mhocko@suse.com, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 19-09-17 19:48:00, Yafang Shao wrote:
> 2017-09-19 16:35 GMT+08:00 Jan Kara <jack@suse.cz>:
> > On Tue 19-09-17 06:53:00, Yafang Shao wrote:
> >> +     if (vm_dirty_bytes == 0 && vm_dirty_ratio == 0 &&
> >> +             (dirty_background_bytes != 0 || dirty_background_ratio != 0))
> >> +             ret = false;
> >
> > Hum, why not just:
> >         if ((vm_dirty_bytes == 0 && vm_dirty_ratio == 0) ||
> >             (dirty_background_bytes == 0 && dirty_background_ratio == 0))
> >                 ret = false;
> >
> > IMHO setting either tunable to 0 is just wrong and actively dangerous...
> >
> 
> Because these four variables all could be set to 0 before, and I'm not
> sure if this
> is needed under some certain conditions, although I think this is
> dangerous but I have
> to keep it as before.
> 
> If you think that is wrong, then I will modified it as you suggested.

OK, I see but see below.

> >>  int dirty_background_ratio_handler(struct ctl_table *table, int write,
> >>               void __user *buffer, size_t *lenp,
> >>               loff_t *ppos)
> >>  {
> >>       int ret;
> >> +     int old_ratio = dirty_background_ratio;
> >>
> >>       ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
> >> -     if (ret == 0 && write)
> >> -             dirty_background_bytes = 0;
> >> +     if (ret == 0 && write) {
> >> +             if (dirty_background_ratio != old_ratio &&
> >> +                     !vm_dirty_settings_valid()) {
> >
> > Why do you check whether new ratio is different here? If it is really
> > needed, it would deserve a comment.
> >
> 
> There're two reseaons,
> 1.  if you set a value same with the old value, it's needn't to do this check.
> 2. there's another behavior that I'm not sure whether it is reaonable.  i.e.
>      if the old value is,
>             vm.dirty_background_bytes = 0;
>             vm.dirty_background_ratio=10;
>       then I execute the bellow command,
>             sysctl -w vm.dirty_background_bytes=0
>      at the end these two values will be,
>             vm.dirty_background_bytes = 0;
>             vm.dirty_background_ratio=0;
> I'm not sure if this is needed under some certain conditons, So I have
> to keep it as before.

OK, this is somewhat the problem of the switching logic between _bytes and
_ratio bytes and also the fact that '0' has a special meaning in these
files. I think the cleanest would be to just refuse writing of '0' into any
of these files which would deal with the problem as well.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
