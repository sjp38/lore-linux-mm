Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 643BD6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 11:13:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so128605396wmg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 08:13:01 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id b9si5038825wje.129.2016.10.04.08.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 08:13:00 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id b201so14997772wmb.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 08:12:59 -0700 (PDT)
Date: Tue, 4 Oct 2016 17:12:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: print nodemask in the oom report
Message-ID: <20161004151258.GD32214@dhcp22.suse.cz>
References: <20160930214146.28600-1-mhocko@kernel.org>
 <65c637df-a9a3-777d-f6d3-322033980f86@suse.cz>
 <20161004141607.GC32214@dhcp22.suse.cz>
 <6fc2bb5f-a91c-f4e8-8d3c-029e2bdb3526@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6fc2bb5f-a91c-f4e8-8d3c-029e2bdb3526@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Sellami Abdelkader <abdelkader.sellami@sap.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 04-10-16 17:02:42, Vlastimil Babka wrote:
> On 10/04/2016 04:16 PM, Michal Hocko wrote:
> > On Tue 04-10-16 15:24:53, Vlastimil Babka wrote:
> > > On 09/30/2016 11:41 PM, Michal Hocko wrote:
> > [...]
> > > > Fix this by always priting the nodemask. It is either mempolicy mask
> > > > (and non-null) or the one defined by the cpusets.
> > > 
> > > I wonder if it's helpful to print the cpuset one when that's printed
> > > separately, and seeing both pieces of information (nodemask and cpuset)
> > > unmodified might tell us more. Is it to make it easier to deal with NULL
> > > nodemask? Or to make sure the info gets through pr_warn() and not pr_info()?
> > 
> > I am not sure I understand the question. I wanted to print the nodemask
> > separatelly in the same line with all other allocation request
> > parameters like order and gfp mask because that is what the page
> > allocator got (via policy_nodemask). cpusets builds on top - aka applies
> > __cpuset_zone_allowed on top of the nodemask. So imho it makes sense to
> > look at the cpuset as an allocation domain while the mempolicy as a
> > restriction within this domain.
> > 
> > Does that answer your question?
> 
> Ah, I wasn't clear. What I questioned is the fallback to cpusets for NULL
> nodemask:
> 
> nodemask_t *nm = (oc->nodemask) ? oc->nodemask :
> &cpuset_current_mems_allowed;

Well no nodemask means there is no mempolicy so either all nodes can be
used or they are restricted by the cpuset. cpuset_current_mems_allowed is
node_states[N_MEMORY] if there is no cpuset so I believe we are printing
the correct information. An alternative would be either not print
anything if there is no nodemask or print node_states[N_MEMORY]
regardless the cpusets. The first one is quite ugly while the later
might be confusing I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
