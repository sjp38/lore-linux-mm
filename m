Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1F32C6B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 04:04:09 -0400 (EDT)
Date: Fri, 17 Aug 2012 10:04:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 08/11] memcg: disable kmem code when not in use.
Message-ID: <20120817080404.GB18600@dhcp22.suse.cz>
References: <1344517279-30646-1-git-send-email-glommer@parallels.com>
 <1344517279-30646-9-git-send-email-glommer@parallels.com>
 <20120817070241.GA18600@dhcp22.suse.cz>
 <502DEC32.6070807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502DEC32.6070807@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri 17-08-12 11:01:06, Glauber Costa wrote:
> On 08/17/2012 11:02 AM, Michal Hocko wrote:
> > On Thu 09-08-12 17:01:16, Glauber Costa wrote:
> >> We can use jump labels to patch the code in or out when not used.
> >>
> >> Because the assignment: memcg->kmem_accounted = true is done after the
> >> jump labels increment, we guarantee that the root memcg will always be
> >> selected until all call sites are patched (see memcg_kmem_enabled).
> > 
> > Not that it would be really important because kmem_accounted goes away

And just found out it doesn't go away completely, it just transforms
from bool to unsigned log (with flags). The rest still holds...

> > in a subsequent patch but I think the wording is a bit misleading here.
> > First of all there is no guanratee that kmem_accounted=true is seen
> > before atomic_inc(&key->enabled) because there is no memory barrier and
> > the lock serves just a leave barrier. But I do not think this is
> > important at all because key->enabled is what matters here. Even if
> > memcg_kmem_enabled is true we do not consider it if the key is disabled,
> > right?
> > 
> 
> Right.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
