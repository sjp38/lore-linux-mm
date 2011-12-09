Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3A45C6B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 09:38:15 -0500 (EST)
Message-ID: <4EE21D23.4000309@parallels.com>
Date: Fri, 9 Dec 2011 12:37:23 -0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
References: <1323120903-2831-1-git-send-email-glommer@parallels.com> <1323120903-2831-2-git-send-email-glommer@parallels.com> <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, Paul Menage <paul@paulmenage.org>

On 12/08/2011 11:21 PM, KAMEZAWA Hiroyuki wrote:
> Hm, why you check val != parent->kmem_independent_accounting ?
>
> 	if (parent&&  parent->use_hierarchy)
> 		return -EINVAL;
> ?
>
> BTW, you didn't check this cgroup has children or not.
> I think
>
> 	if (this_cgroup->use_hierarchy&&
>               !list_empty(this_cgroup->childlen))
> 		return -EINVAL;

How about this?

         val = !!val;

         /*
          * This follows the same hierarchy restrictions than
          * mem_cgroup_hierarchy_write()
          */
         if (!parent || !parent->use_hierarchy) {
                 if (list_empty(&cgroup->children))
                         memcg->kmem_independent_accounting = val;
                 else
                         return -EBUSY;
         }
         else
                 return -EINVAL;

         return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
