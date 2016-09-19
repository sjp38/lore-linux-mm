Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC736B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 07:52:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n4so119453460lfb.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 04:52:08 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ud2si21926891wjc.0.2016.09.19.04.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 04:52:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b184so14540392wma.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 04:52:06 -0700 (PDT)
Date: Mon, 19 Sep 2016 13:52:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
Message-ID: <20160919115204.GL10785@dhcp22.suse.cz>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 18-09-16 13:29:43, Piotr Kwapulinski wrote:
> The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> Return the "invalid argument" from set_mempolicy whenever
> any of these flags is passed along with MPOL_LOCAL.

man 2 set_mempolicy doesn't list this as invalid option. Maybe this is a
documentation bug but is it possible that somebody will see this as an
unexpected error?

> It is consistent with MPOL_PREFERRED passed with empty nodemask.
> It also slightly shortens the execution time in paths where these flags
> are used e.g. when trying to rebind the NUMA nodes for changes in
> cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> the mempolicy structure (/proc/PID/numa_maps).

I am not sure I understand this argument. What does this patch actually
fix? If this is about the execution time then why not just bail out
early when MPOL_LOCAL && (MPOL_F_STATIC_NODES || MPOL_F_RELATIVE_NODES)

> Isolated tests done.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
> ---
>  mm/mempolicy.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 2da72a5..27b07d1 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -276,7 +276,9 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
>  				return ERR_PTR(-EINVAL);
>  		}
>  	} else if (mode == MPOL_LOCAL) {
> -		if (!nodes_empty(*nodes))
> +		if (!nodes_empty(*nodes) ||
> +		    (flags & MPOL_F_STATIC_NODES) ||
> +		    (flags & MPOL_F_RELATIVE_NODES))
>  			return ERR_PTR(-EINVAL);
>  		mode = MPOL_PREFERRED;
>  	} else if (nodes_empty(*nodes))
> -- 
> 2.9.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
