Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABF32802E6
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 03:19:53 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so7503003wic.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 00:19:52 -0700 (PDT)
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id qg11si1936269wic.73.2015.07.16.00.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 00:19:51 -0700 (PDT)
Received: by wgkl9 with SMTP id l9so50776772wgk.1
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 00:19:51 -0700 (PDT)
Date: Thu, 16 Jul 2015 09:19:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/5] memcg: export struct mem_cgroup
Message-ID: <20150716071948.GC3077@dhcp22.suse.cz>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
 <1436958885-18754-2-git-send-email-mhocko@kernel.org>
 <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150715135711.1778a8c08f2ea9560a7c1f6f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 15-07-15 13:57:11, Andrew Morton wrote:
> On Wed, 15 Jul 2015 13:14:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > mem_cgroup structure is defined in mm/memcontrol.c currently which
> > means that the code outside of this file has to use external API even
> > for trivial access stuff.
> > 
> > This patch exports mm_struct with its dependencies and makes some of the
> > exported functions inlines. This even helps to reduce the code size a bit
> > (make defconfig + CONFIG_MEMCG=y)
> > 
> > text		data    bss     dec     	 hex 	filename
> > 12355346        1823792 1089536 15268674         e8fb42 vmlinux.before
> > 12354970        1823792 1089536 15268298         e8f9ca vmlinux.after
> > 
> > This is not much (370B) but better than nothing. We also save a function
> > call in some hot paths like callers of mem_cgroup_count_vm_event which is
> > used for accounting.
> > 
> > The patch doesn't introduce any functional changes.
> > 
> > ...
> >
> >  include/linux/memcontrol.h | 369 +++++++++++++++++++++++++++++++++++++++++----
> 
> Boy, that's a ton of new stuff into the header file.  Do we actually
> *need* to expose all this?

I am exporting struct mem_cgroup with its dependencies + some small
functions which allow to inline some really trivial code and helps to
generate a better code.

> Is some other patch dependent on it? 

Without mem_cgroup visible outside of memcontrol.c we couldn't inline
and now we can also use some fields from mem_cgroup directly and get rid
of some really trivial access functions.

> If
> not then perhaps we shouldn't do this - if the code was already this
> way, I'd be attracted to a patch which was the reverse of this one!

I agree with Johannes who originally suggested to expose mem_cgroup that
it will allow for a better code later.
 
> There's some risk of build breakage here - just from a quick scan,
> memcontrol.h is going to need eventfd.h for eventfd_ctx.  But what else
> is needed?

I have tested this with all{mod,yes,no}config + my battery of configs
which I am using for mm git tree testing + some randconfig without
issues. Sure there might be some config combo I haven't tested but I
guess it should be quite unlikely.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
