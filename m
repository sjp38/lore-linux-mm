Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 341C06B0069
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 05:13:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b16so441222lfb.21
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 02:13:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si12948820wme.189.2017.10.05.02.13.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 02:13:48 -0700 (PDT)
Date: Thu, 5 Oct 2017 09:57:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
Message-ID: <20171005075757.ziyj7kyzyrx7ghd6@dhcp22.suse.cz>
References: <1507053977-116952-1-git-send-email-yang.s@alibaba-inc.com>
 <1507053977-116952-4-git-send-email-yang.s@alibaba-inc.com>
 <20171004142736.u4z7zdar6g7bqgrj@dhcp22.suse.cz>
 <4b668145-a81d-6f46-0569-b0adb76788d8@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b668145-a81d-6f46-0569-b0adb76788d8@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 02:08:48, Yang Shi wrote:
> 
> 
> On 10/4/17 7:27 AM, Michal Hocko wrote:
> > On Wed 04-10-17 02:06:17, Yang Shi wrote:
> > > +static bool is_dump_unreclaim_slabs(void)
> > > +{
> > > +	unsigned long nr_lru;
> > > +
> > > +	nr_lru = global_node_page_state(NR_ACTIVE_ANON) +
> > > +		 global_node_page_state(NR_INACTIVE_ANON) +
> > > +		 global_node_page_state(NR_ACTIVE_FILE) +
> > > +		 global_node_page_state(NR_INACTIVE_FILE) +
> > > +		 global_node_page_state(NR_ISOLATED_ANON) +
> > > +		 global_node_page_state(NR_ISOLATED_FILE) +
> > > +		 global_node_page_state(NR_UNEVICTABLE);
> > > +
> > > +	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
> > > +}
> > 
> > I am sorry I haven't pointed this earlier (I was following only half
> > way) but this should really be memcg aware. You are checking only global
> > counters. I do not think it is an absolute must to provide per-memcg
> > data but you should at least check !is_memcg_oom(oc).
> 
> BTW, I saw there is already such check in dump_header that looks like the
> below code:
> 
>         if (oc->memcg)
>                 mem_cgroup_print_oom_info(oc->memcg, p);
>         else
>                 show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
> 
> I'm supposed it'd better to replace "oc->memcg" to "is_memcg_oom(oc)" since
> they do the same check and "is_memcg_oom" interface sounds preferable.

Yes, is_memcg_oom is better

> Then I'm going to move unreclaimable slabs dump to the "else" block.

makes sense.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
