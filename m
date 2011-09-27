Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D35C49000C4
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 14:30:21 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p8RIUI5C012021
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:30:18 -0700
Received: from gyb11 (gyb11.prod.google.com [10.243.49.75])
	by wpaz13.hot.corp.google.com with ESMTP id p8RIQEKN005423
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:30:16 -0700
Received: by gyb11 with SMTP id 11so9709559gyb.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 11:30:16 -0700 (PDT)
Date: Tue, 27 Sep 2011 11:30:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] oom: do not live lock on frozen tasks
In-Reply-To: <20110927075245.GA25807@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1109271128110.17876@chino.kir.corp.google.com>
References: <20110825151818.GA4003@redhat.com> <alpine.DEB.2.00.1109260154510.1389@chino.kir.corp.google.com> <20110926091440.GE10156@tiehlicka.suse.cz> <201109261751.40688.rjw@sisk.pl> <alpine.DEB.2.00.1109261801150.8510@chino.kir.corp.google.com>
 <20110927075245.GA25807@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Tue, 27 Sep 2011, Michal Hocko wrote:

> I guess you mean a situation when select_bad_process picks up a process
> which is not marked as frozen yet but we send SIGKILL right before
> schedule is called in refrigerator. 
> In that case either schedule should catch it by signal_pending_state
> check or we will pick it up next OOM round when we pick up the same
> process (if nothing else is eligible). Or am I missing something?
>  

That doesn't close the race, the oom killer will see the presence of an 
eligible TIF_MEMDIE thread in select_bad_process() and simply return to 
the page allocator.  You'd need to thaw it there as well and hope that 
nothing now or in the future will get into an endless thaw-freeze-thaw 
loop in the exit path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
