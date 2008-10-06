Message-ID: <48E9AA6E.3080608@suse.de>
Date: Mon, 06 Oct 2008 11:34:30 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
MIME-Version: 1.0
Subject: Re: [PATCH 00/32] Swap over NFS - v19
References: <20081002130504.927878499@chello.nl>
In-Reply-To: <20081002130504.927878499@chello.nl>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Patches are against: v2.6.27-rc5-mm1
> 
> This release features more comments and (hopefully) better Changelogs.
> Also the netns stuff got sorted and ipv6 will now build 

Except for this one I think ;-)

net/netfilter/core.c: In function a??nf_hook_slowa??:
net/netfilter/core.c:191: error: a??pskba?? undeclared (first use in this
function)

> and not oops on boot ;-)

The culprit is emergency-nf_queue.patch. The following change fixes the
build error for me.

Index: linux-2.6.26/net/netfilter/core.c
===================================================================
--- linux-2.6.26.orig/net/netfilter/core.c
+++ linux-2.6.26/net/netfilter/core.c
@@ -184,9 +184,12 @@ next_hook:
                ret = 1;
                goto unlock;
        } else if (verdict == NF_DROP) {
+drop:
                kfree_skb(skb);
                ret = -EPERM;
        } else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+               if (skb_emergency(skb))
+                       goto drop;
                if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
                              verdict >> NF_VERDICT_BITS))
                        goto next_hook;


Thanks,

-- 
Suresh Jayaraman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
