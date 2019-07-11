Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E5BAC742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 21:22:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C950208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 21:22:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="C9PwpYMa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C950208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89A0D8E00FB; Thu, 11 Jul 2019 17:22:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 870A28E00DB; Thu, 11 Jul 2019 17:22:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 786348E00FB; Thu, 11 Jul 2019 17:22:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 409998E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 17:22:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x10so4165877pfa.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 14:22:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ll8NrHguXOqSbOpxMM5XmQWOR4BFFXXFhQrd5rYx/Xk=;
        b=tSH886m25NSI6hqSigPuzV1GmTZmBJKNSbl/RDi/hni0hq9ae9BXME27crlrcTa7n9
         so+Uw2MDPwujdQRUf0JV5hqmNd1c18hi94YeD02DR9LyUGR/iAVtpmm2yB4n9v8azCMg
         Pk198otKR5MVWordWK0sONf9OviGhMeaYfE3PqgY+z4cL4q6j3cpN/C/ETjhSM9VeWJU
         yE3JgvaltvBuEgTJB0mDQTO/vmP7PpWEIMC1QIxiJ1iwDaQgHwYe7DfDS7jJ+nLLnMtf
         mFhjXtpFEuuSDcGkAcyG94CWKBfipf76G4nPVsDzwsKea+DjDmNCTR+b0QuxPy3NYpRe
         +KSQ==
X-Gm-Message-State: APjAAAVddigeJiI1YSLe7UpyQksh7wUjVeVnoOeKtHQw/cx3CfX2jBv0
	7vr7jX8khuJvgPtXdq4cagsXvxVPlttY5pBo2L+UuIjDz4kE+iIhz2LIsmYu9UcmZ+vkdhKN3aK
	8MC8oYO+k9iJCI87qGsSDD/6cRqvxYLo+eH5bGB7ooQKTGcHAi1RmvQ+KJ/DbvEaCjA==
X-Received: by 2002:a63:e5a:: with SMTP id 26mr6377798pgo.3.1562880140756;
        Thu, 11 Jul 2019 14:22:20 -0700 (PDT)
X-Received: by 2002:a63:e5a:: with SMTP id 26mr6377736pgo.3.1562880139818;
        Thu, 11 Jul 2019 14:22:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562880139; cv=none;
        d=google.com; s=arc-20160816;
        b=vZ6uNZ6YNTd2SAeCTNvEHkJyBS2dogDFlLEMiHlFdOUqtFPyfAS73YnWZeC5hx/EkC
         5py3Qdk5jsirPWCIayGboAeM+fzrP5ut5QwiL8T//ji+JbSK8TIQBpYom/ZxPAsiXgRE
         6B94Is6DOwEr41S4ZgYi8n4hpSMl/wwE+5EOth2xrkezxd0xF7rU8t8Hewos65Dvknjl
         gQGipP5Xh5nr5us+Vi+6i+/qqt7Nk+O1THyZNLRNzHVDtKexEMrbI22aKu/T3rrB3MOw
         237iqtNNL0P89DuSZS+yzyNSjlWDPf0p9Prn8jrBDgd0StLUGSF8YTCuXwSUTn9ZHdIa
         4ELw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ll8NrHguXOqSbOpxMM5XmQWOR4BFFXXFhQrd5rYx/Xk=;
        b=UzOc2X73E8i4LufCDwh8uKBuR1Z2oLmAqzl3qw1VYgrl3pNnbubbkgYcRy6L0Snex4
         WpbCg5JNYkbd9yRWhgNer7IgM+rkwv8Dji43FiG3kzm+pgyV1QogrlqXR6yUjXneO532
         xYkVZctxjlpiKHAYHCnNR125tAqAyhnGisAvbj1RUfFr36HZruXYWZML9493nUCfz1w5
         aHWjN2RYKPkzSaVkvFAdoVWYQ4uAZ2YJY5ZBOMBjQ6zuXREd1/k/K7BKDJV6/fVIXDfq
         SZXqmJbY3iPgXUFDP1X/j7PBa7YzYuRBXIPhYo6Pz6gc1xdcXZCkyNdOr7mo9IfDzRGG
         8V5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=C9PwpYMa;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor8389831pji.23.2019.07.11.14.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 14:22:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=C9PwpYMa;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ll8NrHguXOqSbOpxMM5XmQWOR4BFFXXFhQrd5rYx/Xk=;
        b=C9PwpYMaU9nVnH3nEjptn59gQLUrcOKCxfNMsY8XTuu9ttCZx7aRAOEHY7h1SQW4s2
         tw4XozBpC/BRtjZAQltp+ICrnkKdPNBW9ZSZeKJczjFxavyxAimNnFXa0fqSw4s//rBe
         vjca8wK1Fs0iUswUWyHaSEcy5ZKljnQclicZ3JsLPA+Md9+CJqzqF8XncAHitOiUll/Z
         nGi/M8F4Bs3N0oJ82RN5dcn52F4Unh59YdWtHx83yUCqryESf5zS+sK+DIKNUt1RNl4B
         c5E+mqlcxYon91Rn/QKsJSNP+vTIYnRc9D+A43HI9quZrC7JXAuSiNAxuEIl3Kw6L3Zm
         xoWw==
X-Google-Smtp-Source: APXvYqypuSeNyb69Dk1JO7kRPzoyRnBwWoCoeZNmZn0wdvSjTCngSTAW9y6Wh2k0x/7KmWf40re8Ww==
X-Received: by 2002:a17:90a:d998:: with SMTP id d24mr7113307pjv.89.1562880139069;
        Thu, 11 Jul 2019 14:22:19 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id i3sm7186454pfo.138.2019.07.11.14.22.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Jul 2019 14:22:18 -0700 (PDT)
Date: Thu, 11 Jul 2019 14:22:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Chris Wilson <chris@chris-wilson.co.uk>
cc: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, 
    Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [BUG] lockdep splat with kernfs lockdep annotations and slab
 mutex from drm patch??
In-Reply-To: <156282587317.12280.11217721447100506162@skylake-alporthouse-com>
Message-ID: <alpine.DEB.2.21.1907111419120.157247@chino.kir.corp.google.com>
References: <20190614093914.58f41d8f@gandalf.local.home> <156052491337.7796.17642747687124632554@skylake-alporthouse-com> <20190614153837.GE538958@devbig004.ftw2.facebook.com> <20190710225720.58246f8e@oasis.local.home>
 <156282587317.12280.11217721447100506162@skylake-alporthouse-com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019, Chris Wilson wrote:

> Quoting Steven Rostedt (2019-07-11 03:57:20)
> > On Fri, 14 Jun 2019 08:38:37 -0700
> > Tejun Heo <tj@kernel.org> wrote:
> > 
> > > Hello,
> > > 
> > > On Fri, Jun 14, 2019 at 04:08:33PM +0100, Chris Wilson wrote:
> > > > #ifdef CONFIG_MEMCG
> > > >         if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
> > > >                 struct kmem_cache *c;
> > > > 
> > > >                 mutex_lock(&slab_mutex);
> > > > 
> > > > so it happens to hit the error + FULL case with the additional slabcaches?
> > > > 
> > > > Anyway, according to lockdep, it is dangerous to use the slab_mutex inside
> > > > slab_attr_store().  
> > > 
> > > Didn't really look into the code but it looks like slab_mutex is held
> > > while trying to remove sysfs files.  sysfs file removal flushes
> > > on-going accesses, so if a file operation then tries to grab a mutex
> > > which is held during removal, it leads to a deadlock.
> > > 
> > 
> > Looks like this never got fixed and now this bug is in 5.2.
> 
> git blame gives
> 
> commit 107dab5c92d5f9c3afe962036e47c207363255c7
> Author: Glauber Costa <glommer@parallels.com>
> Date:   Tue Dec 18 14:23:05 2012 -0800
> 
>     slub: slub-specific propagation changes
> 
> for adding the mutex underneath sysfs read, and I think
> 
> commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
> Author: Mikulas Patocka <mpatocka@redhat.com>
> Date:   Wed Jun 27 23:26:09 2018 -0700
> 
>     slub: fix failure when we delete and create a slab cache
> 
> added the sysfs removal underneath the slab_mutex.
> 
> > Just got this:
> > 
> >  ======================================================
> >  WARNING: possible circular locking dependency detected
> >  5.2.0-test #15 Not tainted
> >  ------------------------------------------------------
> >  slub_cpu_partia/899 is trying to acquire lock:
> >  000000000f6f2dd7 (slab_mutex){+.+.}, at: slab_attr_store+0x6d/0xe0
> >  
> >  but task is already holding lock:
> >  00000000b23ffe3d (kn->count#160){++++}, at: kernfs_fop_write+0x125/0x230
> >  
> >  which lock already depends on the new lock.
> >  
> >  
> >  the existing dependency chain (in reverse order) is:
> >  
> >  -> #1 (kn->count#160){++++}:
> >         __kernfs_remove+0x413/0x4a0
> >         kernfs_remove_by_name_ns+0x40/0x80
> >         sysfs_slab_add+0x1b5/0x2f0
> >         __kmem_cache_create+0x511/0x560
> >         create_cache+0xcd/0x1f0
> >         kmem_cache_create_usercopy+0x18a/0x240
> >         kmem_cache_create+0x12/0x20
> >         is_active_nid+0xdb/0x230 [snd_hda_codec_generic]
> >         snd_hda_get_path_idx+0x55/0x80 [snd_hda_codec_generic]
> >         get_nid_path+0xc/0x170 [snd_hda_codec_generic]
> >         do_one_initcall+0xa2/0x394
> >         do_init_module+0xfd/0x370
> >         load_module+0x38c6/0x3bd0
> >         __do_sys_finit_module+0x11a/0x1b0
> >         do_syscall_64+0x68/0x250
> >         entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >  

Which slab cache is getting created here?  I assume that sysfs_slab_add() 
is only trying to do kernfs_remove_by_name_ns() becasue its unmergeable 
with other slab caches.

> >  -> #0 (slab_mutex){+.+.}:
> >         lock_acquire+0xbd/0x1d0
> >         __mutex_lock+0xfc/0xb70
> >         slab_attr_store+0x6d/0xe0
> >         kernfs_fop_write+0x170/0x230
> >         vfs_write+0xe1/0x240
> >         ksys_write+0xba/0x150
> >         do_syscall_64+0x68/0x250
> >         entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >  
> >  other info that might help us debug this:
> >  
> >   Possible unsafe locking scenario:
> >  
> >         CPU0                    CPU1
> >         ----                    ----
> >    lock(kn->count#160);
> >                                 lock(slab_mutex);
> >                                 lock(kn->count#160);
> >    lock(slab_mutex);
> >  
> >   *** DEADLOCK ***
> >  

