Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id AAFB26B0044
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 18:07:04 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so9896989pbb.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 15:07:04 -0700 (PDT)
Date: Thu, 18 Oct 2012 15:06:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
In-Reply-To: <507FC8E3.8020006@parallels.com>
Message-ID: <alpine.DEB.2.00.1210181502270.30894@chino.kir.corp.google.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com> <20121017151214.e3d2aa3b.akpm@linux-foundation.org> <507FC8E3.8020006@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 18 Oct 2012, Glauber Costa wrote:

> > Do we actually need to test PF_KTHREAD when current->mm == NULL? 
> > Perhaps because of aio threads whcih temporarily adopt a userspace mm?
> 
> I believe so. I remember I discussed this in the past with David
> Rientjes and he advised me to test for both.
> 

PF_KTHREAD can do use_mm() to assume an ->mm but hopefully they aren't 
allocating slab while doing so.  Have you considered actually charging 
current->mm->owner for that memory, though, since the kthread will have 
freed the memory before unuse_mm() or otherwise have charged it on behalf 
of a user process, i.e. only exempting PF_KTHREAD?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
