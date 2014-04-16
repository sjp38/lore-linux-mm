Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3D65A6B0031
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:13:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so10282836pdj.36
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:13:49 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id hb10si8143301pbc.441.2014.04.15.22.13.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 22:13:48 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so10460460pad.21
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:13:48 -0700 (PDT)
Message-ID: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Apr 2014 22:13:46 -0700
In-Reply-To: <20140416040336.10604.96000.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	 <20140416040336.10604.96000.stgit@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org

On Wed, 2014-04-16 at 14:03 +1000, NeilBrown wrote:
> sk_lock can be taken while reclaiming memory (in nfsd for loop-back
> NFS mounts, and presumably in nfs), and memory can be allocated while
> holding sk_lock, at least via:
> 
>  inet_listen -> inet_csk_listen_start ->reqsk_queue_alloc
> 
> So to avoid deadlocks, always set PF_FSTRANS while holding sk_lock.
> 
> This deadlock was found by lockdep.

Wow, this is adding expensive stuff in fast path, only for nfsd :(

BTW, why should the current->flags should be saved on a socket field,
and not a current->save_flags. This really looks a thread property, not
a socket one.

Why nfsd could not have PF_FSTRANS in its current->flags ?

For applications handling millions of sockets, this makes a difference.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
