Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7E56B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 13:58:10 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so29467615qge.3
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 10:58:10 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id q33si2234000qkq.14.2015.07.30.10.58.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 10:58:09 -0700 (PDT)
Date: Thu, 30 Jul 2015 12:58:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node
In-Reply-To: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org>
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On Thu, 30 Jul 2015, Vlastimil Babka wrote:

> --- a/mm/slob.c
> +++ b/mm/slob.c
>  	void *page;
>
> -#ifdef CONFIG_NUMA
> -	if (node != NUMA_NO_NODE)
> -		page = alloc_pages_exact_node(node, gfp, order);
> -	else
> -#endif
> -		page = alloc_pages(gfp, order);
> +	page = alloc_pages_node(node, gfp, order);

NAK. This is changing slob behavior. With no node specified it must use
alloc_pages because that obeys NUMA memory policies etc etc. It should not
force allocation from the current node like what is happening here after
the patch. See the code in slub.c that is similar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
