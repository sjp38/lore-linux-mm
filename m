Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 749F76B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 03:17:03 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id n15so465593lbi.19
        for <linux-mm@kvack.org>; Thu, 15 May 2014 00:17:02 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id js5si2616494lab.83.2014.05.15.00.17.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 May 2014 00:17:01 -0700 (PDT)
Date: Thu, 15 May 2014 11:16:52 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140515071650.GB32113@esperanza>
References: <cover.1399982635.git.vdavydov@parallels.com>
 <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 14, 2014 at 11:20:51AM -0500, Christoph Lameter wrote:
> On Tue, 13 May 2014, Vladimir Davydov wrote:
> 
> > Since the "slow" and the "normal" free's can't coexist at the same time,
> > we must assure all conventional free's have finished before switching
> > all further free's to the "slow" mode and starting reparenting. To
> > achieve that, a percpu refcounter is used. It is taken and held during
> > each "normal" free. The refcounter is killed on memcg offline, and the
> > cache's pages migration is initiated from the refcounter's release
> > function. If we fail to take a ref on kfree, it means all "normal"
> > free's have been completed and the cache is being reparented right now,
> > so we should free the object using the "slow" mode.
> 
> Argh adding more code to the free path touching more cachelines in the
> process.

Actually, there is not that much active code added, IMO. In fact, it's
only percpu ref get/put for per memcg caches plus a couple of
conditionals. The "slow" mode code is meant to be executed very rarely,
so we can move it to a separate function under unlikely optimization.

I admit that's far not perfect, because kfree is really a hot path,
where every byte of code matters, but unfortunately I don't see how we
can avoid this in case we want slab re-parenting.

Again, I'd like to hear from you if there is any point in moving in this
direction, or I should give up and concentrate on some other approach,
because you'll never accept it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
