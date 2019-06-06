Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD0FFC28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:41:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7637220684
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:41:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sCbqy9Il"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7637220684
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17D446B0277; Thu,  6 Jun 2019 10:41:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 154886B027A; Thu,  6 Jun 2019 10:41:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 041BD6B027B; Thu,  6 Jun 2019 10:41:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAC086B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:41:00 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id q20so121678itq.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:41:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qRHFQx4rk/WQV+W1bUpqDxQ0lUZEI/eFyBpWg1hk11Q=;
        b=P96/ABHlTq8a0Ig3kFkwp9GTVRq6Cs/5GC+7dTpLrud3bJcITK0tD+OqMRVmM+Ehpr
         gC4Ujuk3kng0MPHTWTanBUq77Db0TcJ22nJsH6Nj2Wm08eLMe18zoDj/Apc8+H2j/f+0
         uZvinU4xmDjPbSVSeoeV7YoG8u6cafBsS8RUCluyoRyGDIzAvcN1x/SNMlRrh7Vx7+2I
         8EjCnaaK+iO/sdaaYkbZ6cQAe3sQYk6GMLMhb2TP9zdeqwjZDoifQMNQZqY0g0dW9ZNe
         oNZw32ygmxvUoc6MMNm14RzyvdBdDgsnUysViN8xSdub+bDDbkS7YpTKaneuQjUVHhV1
         60tg==
X-Gm-Message-State: APjAAAXPS8JuOmPNe40IKb6px/hJ1yngjHZ167RQ141OTDCbGlhchcLO
	Dc1dR9uNxLYQbfhTnYDZ850ZhXXKwnY98WI8dwTCjUQ0NCF//tRSWR//WC3CKdPuXVfXvhHN2nG
	TfNHCtHxzzYyjE4AuLRZIBprULfNkBB0telAypi1FDSRRMt6qfDNPs4pJPWThAAm28A==
X-Received: by 2002:a24:3a11:: with SMTP id m17mr259859itm.177.1559832060651;
        Thu, 06 Jun 2019 07:41:00 -0700 (PDT)
X-Received: by 2002:a24:3a11:: with SMTP id m17mr259797itm.177.1559832059896;
        Thu, 06 Jun 2019 07:40:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832059; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOJOpno/DHbAC3eR12JLKPsYrfjC99Hzm/lDEK84nQf7aB/yxah+cDVva+3Z4Rlhex
         RqvQjnxUJHgEJq/o3aS3syYrWAgwzQOgHr+PJE9qO3J6cVeJ+by6O7JmhSqzqoMM7Mvr
         hKWZxfcFbGKFBEdtQEYkHUsmVsOZsBvDVfXs6pkidj/cl5YJwWuJObs2ZDz7wLFh4KrR
         LskqY/jxdfbhnIhLVc1OkjPNyysVLK7sRqx+x/96b9wG+XbjqoLINU+D/KFHLJpp6hcq
         R+XpO5bILIBfa1AfMReuIzRUd4W9Sc0InaQE6eHOo1eOUSyZXr7tTx6beaIzY9ocFSCh
         eJhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qRHFQx4rk/WQV+W1bUpqDxQ0lUZEI/eFyBpWg1hk11Q=;
        b=t+lCjsu2+rnmlyiJgr4/RrVF1iJlOXpPo629ksxBdDn+gdMY3nYlP0lYfCRf2blIDo
         hxFPVqcYXWr9UyuYVloU4HfNQPJ+LLaj1HczHkUpe9eEuLHulncQbpwEb5FtzB4EgJFW
         SOVB3Pd0ocKJ1znhPLxcYtK9pA0HisVf8tb9HXpgOaaC1YmsvR+A+bjedhNy/ZSO+cpF
         da9NTVMzpBrRZLFmIrFSYljiSB+Z/DM1UhH5KvwGF31/3cSR2HQxGm3NpggrnkhZnOv7
         FLgDW6nwUK8y6fPn8mMx5RExGJji+Iu/N+l821I3TU6qxAZRwCN4z9bw//M+q6KhNhXs
         VvIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sCbqy9Il;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h145sor1146693iof.56.2019.06.06.07.40.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:40:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sCbqy9Il;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qRHFQx4rk/WQV+W1bUpqDxQ0lUZEI/eFyBpWg1hk11Q=;
        b=sCbqy9Il3Out2uZPEuDkEDVkIvng7aW0ineP0yjFozNXPOloupyWTAbt2WypG90mH2
         RO8VsxvONEY6+lOd57nEUJshWUBcTFa4IkigR9dm1Tf3DkipfnQEDvxo9Opwgz/kXNUS
         DmfwsDfBQINnUWZ0Xoz1mLZvPk4JJIu5YNhrczzgp/VL2bPoWMOSqbNGpzr8ixIvUQ6M
         V9vloCuM2sAIC1VdTIvssvKJA6lBX9B+Tqrhtdc0OZYZB24Z7LzEBoEXD0s6IamPEOWM
         W5OA0EUvwGXsDqIoNEx40vD+nBZGfdTKV5o4U5ZsLduig2WAsLA4QAk+CITyXaYhUObi
         8iXw==
X-Google-Smtp-Source: APXvYqzKErRjMjB/Lu1mV96B+n+Cf6+/oCq0PF53kEaSxsxhJvuN0Qd+FEtZW9TaI4V1DZGCc+oSBw0knpFzAe36NbU=
X-Received: by 2002:a6b:e711:: with SMTP id b17mr28649615ioh.3.1559832059117;
 Thu, 06 Jun 2019 07:40:59 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000005a4b99058a97f42e@google.com> <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
 <20190606131334.GA24822@fieldses.org> <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
In-Reply-To: <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Jun 2019 16:40:46 +0200
Message-ID: <CACT4Y+aJQ6J5WdviD+cOmDoHt2Dj=Q4uZ4vHbCfHe+_TCEY6-Q@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, 
	syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, bfields@redhat.com, chris@chrisdown.name, 
	Daniel Jordan <daniel.m.jordan@oracle.com>, guro@fb.com, 
	Johannes Weiner <hannes@cmpxchg.org>, Jeff Layton <jlayton@kernel.org>, laoar.shao@gmail.com, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-nfs@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yang.shi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 3:43 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 06.06.2019 16:13, J. Bruce Fields wrote:
> > On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
> >> This may be connected with that shrinker unregistering is forgotten on error path.
> >
> > I was wondering about that too.  Seems like it would be hard to hit
> > reproduceably though: one of the later allocations would have to fail,
> > then later you'd have to create another namespace and this time have a
> > later module's init fail.
>
> Yes, it's had to bump into this in real life.
>
> AFAIU, syzbot triggers such the problem by using fault-injections
> on allocation places should_failslab()->should_fail(). It's possible
> to configure a specific slab, so the allocations will fail with
> requested probability.

No fault injection was involved in triggering of this bug.
Fault injection is clearly visible in console log as "INJECTING
FAILURE at this stack track" splats and also for bugs with repros it
would be noted in the syzkaller repro as "fault_call": N. So somehow
this bug was triggered as is.

But overall syzkaller can do better then the old probabilistic
injection. The probabilistic injection tend to both under-test what we
want to test and also crash some system services. syzkaller uses the
new "systematic fault injection" that allows to test specifically each
failure site separately in each syscall separately.
All kernel testing systems should use it. Also in couple with KASAN,
KMEMLEAK, LOCKDEP. It's indispensable in finding kernel bugs.



> > This is the patch I have, which also fixes a (probably less important)
> > failure to free the slab cache.
> >
> > --b.
> >
> > commit 17c869b35dc9
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Wed Jun 5 18:03:52 2019 -0400
> >
> >     nfsd: fix cleanup of nfsd_reply_cache_init on failure
> >
> >     Make sure everything is cleaned up on failure.
> >
> >     Especially important for the shrinker, which will otherwise eventually
> >     be freed while still referred to by global data structures.
> >
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >
> > diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> > index ea39497205f0..3dcac164e010 100644
> > --- a/fs/nfsd/nfscache.c
> > +++ b/fs/nfsd/nfscache.c
> > @@ -157,12 +157,12 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
> >       nn->nfsd_reply_cache_shrinker.seeks = 1;
> >       status = register_shrinker(&nn->nfsd_reply_cache_shrinker);
> >       if (status)
> > -             return status;
> > +             goto out_nomem;
> >
> >       nn->drc_slab = kmem_cache_create("nfsd_drc",
> >                               sizeof(struct svc_cacherep), 0, 0, NULL);
> >       if (!nn->drc_slab)
> > -             goto out_nomem;
> > +             goto out_shrinker;
> >
> >       nn->drc_hashtbl = kcalloc(hashsize,
> >                               sizeof(*nn->drc_hashtbl), GFP_KERNEL);
> > @@ -170,7 +170,7 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
> >               nn->drc_hashtbl = vzalloc(array_size(hashsize,
> >                                                sizeof(*nn->drc_hashtbl)));
> >               if (!nn->drc_hashtbl)
> > -                     goto out_nomem;
> > +                     goto out_slab;
> >       }
> >
> >       for (i = 0; i < hashsize; i++) {
> > @@ -180,6 +180,10 @@ int nfsd_reply_cache_init(struct nfsd_net *nn)
> >       nn->drc_hashsize = hashsize;
> >
> >       return 0;
> > +out_slab:
> > +     kmem_cache_destroy(nn->drc_slab);
> > +out_shrinker:
> > +     unregister_shrinker(&nn->nfsd_reply_cache_shrinker);
> >  out_nomem:
> >       printk(KERN_ERR "nfsd: failed to allocate reply cache\n");
> >       return -ENOMEM;
>
> Looks OK for me. Feel free to add my reviewed-by if you want.
>
> Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/275f77ad-1962-6a60-e60b-6b8845f12c34%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.

