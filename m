Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFCE6B0031
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 08:40:12 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so5163770pad.40
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 05:40:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id iy4si11804749pbb.0.2013.11.19.05.40.09
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 05:40:10 -0800 (PST)
Date: Tue, 19 Nov 2013 14:40:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131119134007.GD20655@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131119131400.GC20655@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 19-11-13 14:14:00, Michal Hocko wrote:
[...]
> We have basically ended up with 3 options AFAIR:
> 	1) allow memcg approach (memcg.oom_control) on the root level
>            for both OOM notification and blocking OOM killer and handle
>            the situation from the userspace same as we can for other
> 	   memcgs.

This looks like a straightforward approach as the similar thing is done
on the local (memcg) level. There are several problems though.
Running userspace from within OOM context is terribly hard to do
right. This is true even in the memcg case and we strongly discurage
users from doing that. The global case has nothing like outside of OOM
context though. So any hang would blocking the whole machine. Even
if the oom killer is careful and locks in all the resources it would
have hard time to query the current system state (existing processes
and their states) without any allocation.  There are certain ways to
workaround these issues - e.g. give the killer access to memory reserves
- but this all looks scary and fragile.

> 	2) allow modules to hook into OOM killer path and take the
> 	   appropriate action.

This already exists actually. There is oom_notify_list callchain and
{un}register_oom_notifier that allow modules to hook into oom and
skip the global OOM if some memory is freed. There are currently only
s390 and powerpc which seem to abuse it for something that looks like a
shrinker except it is done in OOM path...

I think the interface should be changed if something like this would be
used in practice. There is a lot of information lost on the way. I would
basically expect to get everything that out_of_memory gets.

> 	3) create a generic filtering mechanism which could be
> 	   controlled from the userspace by a set of rules (e.g.
> 	   something analogous to packet filtering).

This looks generic enough but I have no idea about the complexity.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
