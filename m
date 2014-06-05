Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DB5EE6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 12:02:06 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id k14so441863wgh.6
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 09:02:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fo7si15869060wib.72.2014.06.05.09.01.36
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 09:01:36 -0700 (PDT)
Date: Thu, 5 Jun 2014 18:00:29 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
	has listeners
Message-ID: <20140605160029.GA28812@redhat.com>
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at> <20140605141841.GA23796@redhat.com> <539090F1.7090408@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539090F1.7090408@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On 06/05, Richard Weinberger wrote:
>
> Am 05.06.2014 16:18, schrieb Oleg Nesterov:
> > On 06/05, Richard Weinberger wrote:
> >>
> >> +int mem_cgroup_has_listeners(struct mem_cgroup *memcg)
> >> +{
> >> +	int ret = 0;
> >> +
> >> +	if (!memcg)
> >> +		goto out;
> >> +
> >> +	spin_lock(&memcg_oom_lock);
> >> +	ret = !list_empty(&memcg->oom_notify);
> >> +	spin_unlock(&memcg_oom_lock);
> >> +
> >> +out:
> >> +	return ret;
> >> +}
> >
> > Do we really need memcg_oom_lock to check list_empty() ? With or without
> > this lock we can race with list_add/del anyway, and I guess we do not care.
>
> Hmm, in mm/memcontrol.c all list_dev/add are under memcg_oom_lock.

And? How this lock can help to check list_empty() ?

list_add/del can come right after mem_cgroup_has_listeners() and change
the value of list_empty() anyway.

> What do I miss?

Or me...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
