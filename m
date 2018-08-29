Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78F046B4C2C
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 10:35:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k16-v6so2375642ede.6
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:35:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r52-v6si1587184edd.119.2018.08.29.07.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 07:35:47 -0700 (PDT)
Date: Wed, 29 Aug 2018 16:35:45 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180829143545.GY10223@dhcp22.suse.cz>
References: <20180820032204.9591-3-aarcange@redhat.com>
 <20180821115057.GY29735@dhcp22.suse.cz>
 <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829142816.GX10223@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed 29-08-18 16:28:16, Michal Hocko wrote:
> On Wed 29-08-18 09:28:21, Zi Yan wrote:
> [...]
> > This patch triggers WARN_ON_ONCE() in policy_node() when MPOL_BIND is used and THP is on.
> > Should this WARN_ON_ONCE be removed?
> > 
> > 
> > /*
> > * __GFP_THISNODE shouldn't even be used with the bind policy
> > * because we might easily break the expectation to stay on the
> > * requested node and not break the policy.
> > */
> > WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> 
> This is really interesting. It seems to be me who added this warning but
> I cannot simply make any sense of it. Let me try to dig some more.

OK, I get it now. The warning seems to be incomplete. It is right to
complain when __GFP_THISNODE disagrees with MPOL_BIND policy but that is
not what we check here. Does this heal the warning?
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index da858f794eb6..7bb9354b1e4c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1728,7 +1728,10 @@ static int policy_node(gfp_t gfp, struct mempolicy *policy,
 		 * because we might easily break the expectation to stay on the
 		 * requested node and not break the policy.
 		 */
-		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
+		if (policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE)) {
+			nodemask_t *nmask = policy_nodemask(gfp, policy);
+			WARN_ON_ONCE(!node_isset(nd, *nmask));
+		}
 	}
 
 	return nd;
-- 
Michal Hocko
SUSE Labs
