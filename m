Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 36AFF6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:20:55 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so3237496qcy.31
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:20:55 -0700 (PDT)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id e7si1092319qai.203.2014.05.14.09.20.54
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 09:20:54 -0700 (PDT)
Date: Wed, 14 May 2014 11:20:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
In-Reply-To: <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
References: <cover.1399982635.git.vdavydov@parallels.com> <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 13 May 2014, Vladimir Davydov wrote:

> Since the "slow" and the "normal" free's can't coexist at the same time,
> we must assure all conventional free's have finished before switching
> all further free's to the "slow" mode and starting reparenting. To
> achieve that, a percpu refcounter is used. It is taken and held during
> each "normal" free. The refcounter is killed on memcg offline, and the
> cache's pages migration is initiated from the refcounter's release
> function. If we fail to take a ref on kfree, it means all "normal"
> free's have been completed and the cache is being reparented right now,
> so we should free the object using the "slow" mode.

Argh adding more code to the free path touching more cachelines in the
process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
