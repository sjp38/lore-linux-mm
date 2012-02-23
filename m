Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D874B6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 18:09:38 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so2350709pbc.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:09:38 -0800 (PST)
Date: Thu, 23 Feb 2012 15:09:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
In-Reply-To: <20120223150238.GA15427@dhcp231-144.rdu.redhat.com>
Message-ID: <alpine.DEB.2.00.1202231505080.26362@chino.kir.corp.google.com>
References: <20120222115320.GA3107@x61.redhat.com> <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com> <20120223150238.GA15427@dhcp231-144.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@redhat.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Thu, 23 Feb 2012, Josef Bacik wrote:

> I requested this specifically because I was oom'ing the box so hard that I
> couldn't read /proc/slabinfo at the time of OOM and therefore had no idea what I
> was leaking.  Telling me how much slab was in use was no help, I needed to know
> which of the like 6 objects I was doing horrible things with was screwing me,
> and without this patch I would have no way of knowing.
> 

So an oom was creating a denial of service so that you had no way to do 
cat /proc/slabinfo?  I think we should talk about this first, because 
that's a serious situation that certainly shouldn't be happening.

The oom killer is designed to kill the most memory-hogging task available 
so that it doesn't have to kill multiple threads.  Why was the memory not 
being freed or why was the thread that was consistently being killed 
restarted time and time again so you couldn't even cat a file?

> Sure, if the OOM killer doesn't kill the poller, or kill NetworkManager since
> I'm remote logged into the box, or any of the other various important things
> that would be required for me to get this info.  Thanks,
> 

If you're polling for oom notifications sanely, you'd probably have set

	echo -1000 > /proc/pid/oom_score_adj

so it's unkillable as well as anything else you need to diagnose failures.  
NetworkManager itself isn't protected like this by default, but it 
shouldn't be killed unless it is leaking memory itself: we kill in the 
order of the most memory usage to the least.

So neither of these are reasons to not collect /proc/slabinfo, but I'm 
very interested in your follow-up to why you can't do so when "ooming the 
box so hard" where you're presumably able to cat to kernel log file but 
not cat /proc/slabinfo :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
