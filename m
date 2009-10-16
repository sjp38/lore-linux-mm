Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A35C76B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 02:34:20 -0400 (EDT)
Date: Fri, 16 Oct 2009 08:34:05 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 0/2] x86, UV: fixups for configurations with a large
	number of nodes.
Message-ID: <20091016063405.GB20388@elte.hu>
References: <20091015223959.783988000@alcatraz.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091015223959.783988000@alcatraz.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>


* Robin Holt <holt@sgi.com> wrote:

> We need the __uv_hub_info structure to contain the correct values for 
> n_val, gpa_mask, and lowmem_remap_*.  The first patch in the series 
> accomplishes this.  Could this be included in the stable tree as well. 
> Without this patch, booting a large configuration hits a problem where 
> the upper bits of the gnode affect the pnode and the bau will not 
> operate.

i've applied this one.

> The second patch cleans up the broadcast assist unit code a small bit.

Seems to be more than just a 'cleanup'. It changes:

  uv_nshift = uv_hub_info->m_val;

to (in essence):

              uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1)

which is not the same. Furthermore, the new inline is:

+       return gpa >> uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1);

note that >> has higher priority than bitwise & - is that intended? I 
think the intention was:

+       return gpa >> (uv_hub_info->m_val & ((1UL << uv_hub_info->n_val) - 1));

in any case please do that cleaner by adding a separate mask variable.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
