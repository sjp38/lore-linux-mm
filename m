Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 685716B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 05:20:30 -0400 (EDT)
Message-ID: <5033521A.9050704@parallels.com>
Date: Tue, 21 Aug 2012 13:17:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-10-git-send-email-glommer@parallels.com> <20120817090005.GC18600@dhcp22.suse.cz> <502E0BC3.8090204@parallels.com> <20120817093504.GE18600@dhcp22.suse.cz> <502E17C4.7060204@parallels.com> <20120817103550.GF18600@dhcp22.suse.cz> <502E1E90.1080805@parallels.com> <20120821075430.GA19797@dhcp22.suse.cz> <20120821083501.GC19797@dhcp22.suse.cz>
In-Reply-To: <20120821083501.GC19797@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 08/21/2012 12:35 PM, Michal Hocko wrote:
> On Tue 21-08-12 09:54:30, Michal Hocko wrote:
>> E.g. how do you handle charges you left behind? Say you charged some
>> pages for stack?
> 
> I got to the last patch and see how you do it. You are relying on
> free_accounted_pages directly which doesn't check kmem_accounted and
> uses PageUsed bit instead. So this is correct. I guess you are relying
> on the life cycle of the object in general so other types of objects
> should be safe as well and there shouldn't be any leaks. It is just that
> the memcg life time is not bounded now. Will think about that.
> 
Unless you have a better way, I believe any kind of transversal in the
free page path is performance detrimental. So the best way is to be
explicit and mark a specific callsite as a memcg free.

As for the unbounded time, you are correct. However, I believe it is
possible to move a lot of the work we do for free (such as freeing the
percpu counters and the css_id itself) to an earlier time.

Also, if it ever becomes a problem, it is theoretically possible to
avoid this, by tracking the kmem pages in a per-memcg list. We would
then transverse such list as we do for user pages, and reparent them.
The problem is that this is also a bit space inefficient, since we can't
reuse any more fields in page_struct for the list_head, so we'd need an
external structure. There is a list_head + a pointer per tracked page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
