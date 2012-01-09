Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5FD4A6B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 15:55:11 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2114859ghr.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 12:55:10 -0800 (PST)
Date: Mon, 9 Jan 2012 12:55:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com>
Message-ID: <alpine.DEB.2.00.1201091251300.10232@chino.kir.corp.google.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com> <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com> <20120104195521.GA19181@suse.de> <84FF21A720B0874AA94B46D76DB9826904554AFD@008-AM1MPN1-003.mgdnok.nokia.com>
 <alpine.DEB.2.00.1201090203470.8480@chino.kir.corp.google.com> <84FF21A720B0874AA94B46D76DB9826904554B81@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: gregkh@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

On Mon, 9 Jan 2012, leonid.moiseichuk@nokia.com wrote:

> > I'm not sure why you need to detect low memory thresholds if you're not
> > interested in using the memory controller, why not just use the oom killer
> > delay that I suggested earlier and allow userspace to respond to conditions
> > when you are known to failed reclaim and require that something be killed?
> 
> As I understand that is required to turn on memcg and memcg is a thing 
> I try to avoid.
> 

Maybe there's some confusion: the proposed oom killer delay that I'm 
referring to here is not upstream and has never been written for global 
oom conditions.  My reference to it earlier was as an internal patch that 
we carry on top of memory controller, but what I'm proposing here is for 
it to be implemented globally.

So if the page allocator can make no progress in freeing memory, we would 
introduce a delay in out_of_memory() if it were configured via a sysctl 
from userspace.  When this delay is started, applications waiting on this 
event can be notified with eventfd(2) that the delay has started and they 
have however many milliseconds to address the situation.  When they 
rewrite the sysctl, the delay is cleared.  If they don't rewrite the 
sysctl and the delay expires, the oom killer proceeds with killing.

What's missing for your usecase with this proposal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
