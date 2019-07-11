Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 816F7C74A42
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 06:18:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BE15208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 06:18:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BE15208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=chris-wilson.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9458E00A8; Thu, 11 Jul 2019 02:18:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 858498E0032; Thu, 11 Jul 2019 02:18:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 747C28E00A8; Thu, 11 Jul 2019 02:18:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20CC98E0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 02:18:04 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id p16so1183896wmi.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 23:18:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:to:from:in-reply-to:cc:references
         :message-id:user-agent:subject:date;
        bh=T03ObicY0kslgPIb/A3XEFd0lJa67dU3HkRTm4boNWY=;
        b=S1jJOvArC3Mhdrnx+h0yVaHMCZxSXWe1nUiAJG5/UAqoJo5GVgX0AWxSXLn/f8beQA
         Mh1SQ9gsMfBfsme2dqCxP1xKjnh92R0HAVM0BY1erb5i7ZP2zPbsrqpy68KFE9BFtk8l
         K9ztAXlKaqUGymYBGhXLn7V5ug2qvzf8FLYPsGmqRfZEdqaRrRYBT31qdVfzPnNxj3j6
         dEQlSgKcma/h4kFM1+TLiy2lqY7nS7t1D4CKi2ueYFSroOEiyuDfKpJiCfErCzUCvHea
         vQeXQk2iBRIcDrhfSEpjooNnZTsFUL2Z8aasSThsW96RlyIk2LKzz0KJfi+NgbGIexW6
         JVvg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Gm-Message-State: APjAAAWGqf75eyq4xu5QJrjilVBqVrp1r9lHUgZOerWhkJyT3LUy8Lkc
	4TLsYDd3GqJpQp8PQ70RJdAlWfTl8OwAqjxZ/WAUU5B1clyeCY7YDB2nXpS6AMpEvJj59twUthV
	gjv0uAoc6IDaXfjt0qj6OVaiBphxfw95JDWqrq4aGEUPgGKHhlypjSma8JOboCv0=
X-Received: by 2002:a05:600c:2385:: with SMTP id m5mr1881862wma.4.1562825883675;
        Wed, 10 Jul 2019 23:18:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBhbk/WiOhOVokrAspw43jKrkV+RMQ6/CahROlX8PkiPtRilQ0ePkVMXJO+RW9i3/4KTMi
X-Received: by 2002:a05:600c:2385:: with SMTP id m5mr1881713wma.4.1562825881999;
        Wed, 10 Jul 2019 23:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562825881; cv=none;
        d=google.com; s=arc-20160816;
        b=ftGYQpFa3rH1CzjoT/pH40hRsCnFvl0SVZHf0KHO05LPZcEi+uCYKZEikX5w4T17UO
         fTdPc6qU6bgxSdTLq6f8k6x/Fst7KD4YmwM9+BFCWBJugLHJitBdsKUkh5zkczlPbnYF
         W8PcxjJwnJIfCdW6Fs/jOe9xGe03/MLvQt1hcO+wSSkyGNEg6xI1fZhlBJKoY19pvZGm
         ntcJ2cw+kjpAlLIglIGH0mQ5P99OVCpSpLGRT+OJ1mCbatYCi9ON2bTNvkYZxd2vg/yz
         +r7emdN/LdT+7nvtUO6/dYQwYOVmp5mp+G6G5/NfoMxcCHt75hE2aolFdVxYt/PO5mMA
         g58A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:subject:user-agent:message-id:references:cc:in-reply-to:from
         :to:content-transfer-encoding:mime-version;
        bh=T03ObicY0kslgPIb/A3XEFd0lJa67dU3HkRTm4boNWY=;
        b=pG1wDMXz+5T4ZQ+F1wSAfsyl9uD7KUU29Kx5vH3BK/kl1l2BzfG3dF9XkRAJtNLq0V
         fiPcSVAw4MDPzUccFi+DhxBP51ll4/Lap5UsfQHyLeofANkC3MDF+ouL/2KjTRCHbt2f
         r4nMsyzDC/f6mWv11fanp6N0o8Wu5OoPXs3EUZ8AcSQ2RY+03vmHISmtHY6bEnzuC/rh
         reJCh+eLi4WCewomTP7haz9BP8F1SzeGwC899gGm1eXT/E9b+REd5IO51ZA1gBvi0Ona
         cId0qClfQrTxMYA+jzD1gRrVWryngLp9zNsbR+YQcwOShoCrUahVmMhOyGsLJStEzdBD
         T2Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id s185si3983823wme.25.2019.07.10.23.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 23:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) client-ip=109.228.58.192;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 109.228.58.192 is neither permitted nor denied by best guess record for domain of chris@chris-wilson.co.uk) smtp.mailfrom=chris@chris-wilson.co.uk
X-Default-Received-SPF: pass (skip=forwardok (res=PASS)) x-ip-name=78.156.65.138;
Received: from localhost (unverified [78.156.65.138]) 
	by fireflyinternet.com (Firefly Internet (M1)) with ESMTP (TLS) id 17214061-1500050 
	for multiple; Thu, 11 Jul 2019 07:17:55 +0100
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
To: Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20190710225720.58246f8e@oasis.local.home>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190614093914.58f41d8f@gandalf.local.home>
 <156052491337.7796.17642747687124632554@skylake-alporthouse-com>
 <20190614153837.GE538958@devbig004.ftw2.facebook.com>
 <20190710225720.58246f8e@oasis.local.home>
Message-ID: <156282587317.12280.11217721447100506162@skylake-alporthouse-com>
User-Agent: alot/0.6
Subject: Re: [BUG] lockdep splat with kernfs lockdep annotations and slab mutex from
 drm patch??
Date: Thu, 11 Jul 2019 07:17:53 +0100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Quoting Steven Rostedt (2019-07-11 03:57:20)
> On Fri, 14 Jun 2019 08:38:37 -0700
> Tejun Heo <tj@kernel.org> wrote:
> =

> > Hello,
> > =

> > On Fri, Jun 14, 2019 at 04:08:33PM +0100, Chris Wilson wrote:
> > > #ifdef CONFIG_MEMCG
> > >         if (slab_state >=3D FULL && err >=3D 0 && is_root_cache(s)) {
> > >                 struct kmem_cache *c;
> > > =

> > >                 mutex_lock(&slab_mutex);
> > > =

> > > so it happens to hit the error + FULL case with the additional slabca=
ches?
> > > =

> > > Anyway, according to lockdep, it is dangerous to use the slab_mutex i=
nside
> > > slab_attr_store().  =

> > =

> > Didn't really look into the code but it looks like slab_mutex is held
> > while trying to remove sysfs files.  sysfs file removal flushes
> > on-going accesses, so if a file operation then tries to grab a mutex
> > which is held during removal, it leads to a deadlock.
> > =

> =

> Looks like this never got fixed and now this bug is in 5.2.

git blame gives

commit 107dab5c92d5f9c3afe962036e47c207363255c7
Author: Glauber Costa <glommer@parallels.com>
Date:   Tue Dec 18 14:23:05 2012 -0800

    slub: slub-specific propagation changes

for adding the mutex underneath sysfs read, and I think

commit d50d82faa0c964e31f7a946ba8aba7c715ca7ab0
Author: Mikulas Patocka <mpatocka@redhat.com>
Date:   Wed Jun 27 23:26:09 2018 -0700

    slub: fix failure when we delete and create a slab cache

added the sysfs removal underneath the slab_mutex.

> Just got this:
> =

>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
>  WARNING: possible circular locking dependency detected
>  5.2.0-test #15 Not tainted
>  ------------------------------------------------------
>  slub_cpu_partia/899 is trying to acquire lock:
>  000000000f6f2dd7 (slab_mutex){+.+.}, at: slab_attr_store+0x6d/0xe0
>  =

>  but task is already holding lock:
>  00000000b23ffe3d (kn->count#160){++++}, at: kernfs_fop_write+0x125/0x230
>  =

>  which lock already depends on the new lock.
>  =

>  =

>  the existing dependency chain (in reverse order) is:
>  =

>  -> #1 (kn->count#160){++++}:
>         __kernfs_remove+0x413/0x4a0
>         kernfs_remove_by_name_ns+0x40/0x80
>         sysfs_slab_add+0x1b5/0x2f0
>         __kmem_cache_create+0x511/0x560
>         create_cache+0xcd/0x1f0
>         kmem_cache_create_usercopy+0x18a/0x240
>         kmem_cache_create+0x12/0x20
>         is_active_nid+0xdb/0x230 [snd_hda_codec_generic]
>         snd_hda_get_path_idx+0x55/0x80 [snd_hda_codec_generic]
>         get_nid_path+0xc/0x170 [snd_hda_codec_generic]
>         do_one_initcall+0xa2/0x394
>         do_init_module+0xfd/0x370
>         load_module+0x38c6/0x3bd0
>         __do_sys_finit_module+0x11a/0x1b0
>         do_syscall_64+0x68/0x250
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
>  =

>  -> #0 (slab_mutex){+.+.}:
>         lock_acquire+0xbd/0x1d0
>         __mutex_lock+0xfc/0xb70
>         slab_attr_store+0x6d/0xe0
>         kernfs_fop_write+0x170/0x230
>         vfs_write+0xe1/0x240
>         ksys_write+0xba/0x150
>         do_syscall_64+0x68/0x250
>         entry_SYSCALL_64_after_hwframe+0x49/0xbe
>  =

>  other info that might help us debug this:
>  =

>   Possible unsafe locking scenario:
>  =

>         CPU0                    CPU1
>         ----                    ----
>    lock(kn->count#160);
>                                 lock(slab_mutex);
>                                 lock(kn->count#160);
>    lock(slab_mutex);
>  =

>   *** DEADLOCK ***
>  =

> =

> =

> Attached is a config and the full dmesg.
> =

> -- Steve
>=20

