Date: Tue, 12 Feb 2008 12:05:17 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to allowed nodes V3
In-Reply-To: <alpine.DEB.1.00.0802111757470.19213@chino.kir.corp.google.com>
References: <20080212103944.29A9.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802111757470.19213@chino.kir.corp.google.com>
Message-Id: <20080212115952.29B2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> I'm talking about the disclaimer that I quoted above in the changelog of 
> this patch.  Lee was stating that he deferred my suggestion to move the 
> logic into mpol_new(), which I did in my patchset, but I don't think that 
> needs to be included in this patch's changelog.
> 
> I'm all for the merging of this patch (once my concern below is addressed) 
> but the section of the changelog that is quoted above is unnecessary.

OK. I obey you.

> So my question is why we consider this invalid:
> 
> 	nodemask_t nodes;
> 
> 	nodes_clear(&nodes);
> 	node_set(1, &nodes);
> 	set_mempolicy(MPOL_DEFAULT, nodes, 1 << CONFIG_NODES_SHIFT);
> 
> The nodemask doesn't matter at all with a MPOL_DEFAULT policy.

Hmmmmmm
sorry, I don't understand yet.

My test result was

RHEL5(initrd-2.6.18 + rhel patch)	EINVAL
2.6.24					EINVAL
2.6.24 + lee-patch			EINVAL


I don't know current behavior good or wrong.
but I think it is not regression.


-------------------------------------------------------
#include <numaif.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <numa.h>

main(){
        int err;
        nodemask_t nodes;

        nodemask_zero(&nodes);
        nodemask_set(&nodes, 1);
        err = set_mempolicy(MPOL_DEFAULT, &nodes.n[0], 2048);
        if (err < 0) {
                perror("set_mempolicy");
        }

        return 0;
}


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
