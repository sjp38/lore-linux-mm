Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 17F536B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:18:40 -0500 (EST)
Date: Mon, 26 Nov 2012 14:18:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -mm] memcg: do not trigger OOM from add_to_page_cache_locked
Message-ID: <20121126131837.GC17860@dhcp22.suse.cz>
References: <20121122190526.390C7A28@pobox.sk>
 <20121122214249.GA20319@dhcp22.suse.cz>
 <20121122233434.3D5E35E6@pobox.sk>
 <20121123074023.GA24698@dhcp22.suse.cz>
 <20121123102137.10D6D653@pobox.sk>
 <20121123100438.GF24698@dhcp22.suse.cz>
 <20121125011047.7477BB5E@pobox.sk>
 <20121125120524.GB10623@dhcp22.suse.cz>
 <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126013855.AF118F5E@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

[CCing also Johannes - the thread started here:
https://lkml.org/lkml/2012/11/21/497]

On Mon 26-11-12 01:38:55, azurIt wrote:
> >This is hackish but it should help you in this case. Kamezawa, what do
> >you think about that? Should we generalize this and prepare something
> >like mem_cgroup_cache_charge_locked which would add __GFP_NORETRY
> >automatically and use the function whenever we are in a locked context?
> >To be honest I do not like this very much but nothing more sensible
> >(without touching non-memcg paths) comes to my mind.
> 
> 
> I installed kernel with this patch, will report back if problem occurs
> again OR in few weeks if everything will be ok. Thank you!

Now that I am looking at the patch closer it will not work because it
depends on other patch which is not merged yet and even that one would
help on its own because __GFP_NORETRY doesn't break the charge loop.
Sorry I have missed that...

The patch bellow should help though. (it is based on top of the current
-mm tree but I will send a backport to 3.2 in the reply as well)
---
