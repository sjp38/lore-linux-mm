Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27AC86B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:12:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l132so1073927wmf.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:12:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si28005529wjt.239.2016.09.20.08.12.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 08:12:22 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for local
 NUMA mode
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <65cb95b8-4521-cc4c-a30c-e6c23731479c@suse.cz>
Date: Tue, 20 Sep 2016 17:12:16 +0200
MIME-Version: 1.0
In-Reply-To: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

[CC += linux-api@vger.kernel.org]

     Since this is a kernel-user-space API change, please CC linux-api@. The 
kernel source file Documentation/SubmitChecklist notes that all Linux kernel 
patches that change userspace interfaces should be CCed to 
linux-api@vger.kernel.org, so that the various parties who are interested in API 
changes are informed. For further information, see 
https://www.kernel.org/doc/man-pages/linux-api-ml.html

I think man page should document the change? Also I noticed that MPOL_NUMA 
itself is missing in the man page...

On 09/18/2016 01:29 PM, Piotr Kwapulinski wrote:
> The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> Return the "invalid argument" from set_mempolicy whenever
> any of these flags is passed along with MPOL_LOCAL.
> It is consistent with MPOL_PREFERRED passed with empty nodemask.
> It also slightly shortens the execution time in paths where these flags
> are used e.g. when trying to rebind the NUMA nodes for changes in
> cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> the mempolicy structure (/proc/PID/numa_maps).

Hmm not sure I understand. How does change in mpol_new() affect 
mpol_rebind_preferred()?

Vlastimil

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
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
