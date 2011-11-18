Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E3A346B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 18:53:05 -0500 (EST)
Received: by yenm10 with SMTP id m10so4023855yen.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 15:53:03 -0800 (PST)
Date: Fri, 18 Nov 2011 15:53:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 for-3.2-rc3] cpusets: stall when updating mems_allowed
 for mempolicy or disjoint nodemask
In-Reply-To: <20111117160019.c8bd45ba.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1111181549460.24487@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1111161307020.23629@chino.kir.corp.google.com> <20111117142213.2b34469d.akpm@linux-foundation.org> <alpine.DEB.2.00.1111171507340.9933@chino.kir.corp.google.com> <20111117160019.c8bd45ba.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Paul Menage <paul@paulmenage.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 Nov 2011, Andrew Morton wrote:

> Nothing in this changelog makes me understand why you think we need this
> change in 3.2.  What are the user-visible effects of this change?
> 

Kernels where MAX_NUMNODES > BITS_PER_LONG may temporarily see an empty 
nodemask in a tsk's mempolicy if its previous nodemask is remapped onto a 
new set of allowed cpuset nodes where the two nodemasks, as a result of 
the remap, are now disjoint.  This fix is a bandaid so that we never 
optimize the stores to tsk->mems_allowed because they intersect if tsk 
also has an existing mempolicy, so that prevents the possibility of seeing 
an empty nodemask during rebind.  For 3.3, I'd like to ensure that 
remapping any mempolicy's nodemask will never result in an empty nodemask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
