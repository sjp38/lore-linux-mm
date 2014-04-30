Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0736D6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 18:49:34 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e51so1801228eek.16
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:49:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id z42si32322545eel.92.2014.04.30.15.49.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 15:49:33 -0700 (PDT)
Date: Wed, 30 Apr 2014 18:49:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140430224914.GC26041@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140430145238.4215f914f7ad025da4db5470@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430145238.4215f914f7ad025da4db5470@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Apr 30, 2014 at 02:52:38PM -0700, Andrew Morton wrote:
> On Mon, 28 Apr 2014 14:26:41 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi,
> > previous discussions have shown that soft limits cannot be reformed
> > (http://lwn.net/Articles/555249/). This series introduces an alternative
> > approach for protecting memory allocated to processes executing within
> > a memory cgroup controller. It is based on a new tunable that was
> > discussed with Johannes and Tejun held during the kernel summit 2013 and
> > at LSF 2014.
> > 
> > This patchset introduces such low limit that is functionally similar
> > to a minimum guarantee. Memcgs which are under their lowlimit are not
> > considered eligible for the reclaim (both global and hardlimit) unless
> > all groups under the reclaimed hierarchy are below the low limit when
> > all of them are considered eligible.
> 
> Permitting containers to avoid global reclaim sounds rather worrisome.
> 
> Fairness: won't it permit processes to completely protect their memory
> while everything else in the system is getting utterly pounded?  We
> need to consider global-vs-memcg fairness as well as memcg-vs-memgc.

Yes.

> Security: can this feature be used to DoS the machine?  Set up enough
> hierarchies which are below their low limit and we risk memory
> exhaustion and swap-thrashing and oom-killings for other processes.

And yes.

However, setting the low limit is a priviliged operation, so I don't
see how you could do worse with it than with mlock, disabling swap
etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
