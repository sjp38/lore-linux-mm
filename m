Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B35DC6B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:11:59 -0400 (EDT)
Received: by qged69 with SMTP id d69so88694128qge.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:11:59 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id a74si5940687qgf.30.2015.07.23.07.11.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 07:11:58 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:11:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: rename and document alloc_pages_exact_node
In-Reply-To: <alpine.DEB.2.10.1507221445130.21468@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1507230855510.12258@east.gentwo.org>
References: <1437486951-19898-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507211428160.3833@chino.kir.corp.google.com> <55AF7F64.1040602@suse.cz> <alpine.DEB.2.10.1507221445130.21468@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Robin Holt <robinmholt@gmail.com>

On Wed, 22 Jul 2015, David Rientjes wrote:

> Eek, yeah, that does look bad.  I'm not even sure the
>
> 	if (nid < 0)
> 		nid = numa_node_id();
>
> is correct; I think this should be comparing to NUMA_NO_NODE rather than
> all negative numbers, otherwise we silently ignore overflow and nobody
> ever knows.

Comparing to NUMA_NO_NODE would be better. Also use numa_mem_id() instead
to support memoryless nodes better?

> The only possible downside would be existing users of
> alloc_pages_node() that are calling it with an offline node.  Since it's a
> VM_BUG_ON() that would catch that, I think it should be changed to a
> VM_WARN_ON() and eventually fixed up because it's nonsensical.
> VM_BUG_ON() here should be avoided.

The offline node thing could be addresses by using numa_mem_id()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
