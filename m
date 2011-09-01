Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A58C36B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 18:08:17 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p81M86Ci028296
	for <linux-mm@kvack.org>; Thu, 1 Sep 2011 15:08:07 -0700
Received: from gwb1 (gwb1.prod.google.com [10.200.2.1])
	by hpaq11.eem.corp.google.com with ESMTP id p81M5qGb032397
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 1 Sep 2011 15:08:05 -0700
Received: by gwb1 with SMTP id 1so1419467gwb.36
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 15:08:02 -0700 (PDT)
Date: Thu, 1 Sep 2011 15:08:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <20110901145819.4031ef7c.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1109011501260.22550@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <20110901145819.4031ef7c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011, Andrew Morton wrote:

> > Add a userspace visible knob
> 
> argh.  Fear and hostility at new knobs which need to be maintained for
> ever, even if the underlying implementation changes.
> 

Do we really need to maintain tunables that lose their purpose either 
because the implementation changes or is patched to fix the issue that the 
tunable was intended to address without requiring it?

Are there really userspace tools written to not be able to handle -ENOENT 
when one of these gets removed?

> > It may also be useful to reduce the memory use of virtual
> > machines (temporarily?), in a way that does not cause memory
> > fragmentation like ballooning does.
> 
> Maybe.  You need to alter the setting, then somehow persuade all the
> targeted kswapd's to start running, then somehow determine that they've
> done their thing, then unalter the /proc setting.  Not the best API
> we've ever designed ;)
> 

And, unfortunately, this could have negative effects if using cpusets 
and/or mempolicies since this is global across all zones such that jobs 
that do not require such "extra" memory would be unfairly penalized with 
work incurred by additional reclaim they don't need.  And if the job is 
constrained to a memory cgroup, there's no guarantee it will reclaim back 
to these altered watermarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
