Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF956B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 17:16:32 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f66so34323836ioe.12
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 14:16:32 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id e42si19322638ioj.166.2017.04.12.14.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 14:16:31 -0700 (PDT)
Date: Wed, 12 Apr 2017 16:16:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 2/6] mm, mempolicy: stop adjusting current->il_next in
 mpol_rebind_nodemask()
In-Reply-To: <97045760-77eb-c892-9bcb-daad10a1d91d@suse.cz>
Message-ID: <alpine.DEB.2.20.1704121607520.28335@east.gentwo.org>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-3-vbabka@suse.cz> <alpine.DEB.2.20.1704111227080.25069@east.gentwo.org> <9665a022-197a-4b02-8813-66aca252f0f9@suse.cz> <97045760-77eb-c892-9bcb-daad10a1d91d@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, 12 Apr 2017, Vlastimil Babka wrote:

> >> Well, interleave_nodes() will then potentially return a node outside of
> >> the allowed memory policy when its called for the first time after
> >> mpol_rebind_.. . But thenn it will find the next node within the
> >> nodemask and work correctly for the next invocations.
> >
> > Hmm, you're right. But that could be easily fixed if il_next became il_prev, so
> > we would return the result of next_node_in(il_prev) and also store it as the new
> > il_prev, right? I somehow assumed it already worked that way.

Yup that makes sense and I thought about that when I saw the problem too.

> @@ -863,6 +856,18 @@ static int lookup_node(unsigned long addr)
>  	return err;
>  }
>
> +/* Do dynamic interleaving for a process */
> +static unsigned interleave_nodes(struct mempolicy *policy, bool update_prev)

Why do you need an additional flag? Would it not be better to always
update and switch the update_prev=false case to simply use
next_node_in()?

> +{
> +	unsigned next;
> +	struct task_struct *me = current;
> +
> +	next = next_node_in(me->il_prev, policy->v.nodes);
> +	if (next < MAX_NUMNODES && update_prev)
> +		me->il_prev = next;
> +	return next;
> +}
> +
>  /* Retrieve NUMA policy */
>  static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  			     unsigned long addr, unsigned long flags)
> @@ -916,7 +921,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  			*policy = err;
>  		} else if (pol == current->mempolicy &&
>  				pol->mode == MPOL_INTERLEAVE) {
> -			*policy = current->il_next;
> +			*policy = interleave_nodes(current->mempolicy, false);

Here

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
