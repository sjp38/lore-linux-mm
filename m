Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C22146B007E
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 10:10:30 -0500 (EST)
Date: Fri, 24 Feb 2012 10:10:26 -0500
From: Josef Bacik <josef@redhat.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
Message-ID: <20120224151025.GA1848@localhost.localdomain>
References: <20120222115320.GA3107@x61.redhat.com>
 <alpine.DEB.2.00.1202221640420.14213@chino.kir.corp.google.com>
 <20120223150238.GA15427@dhcp231-144.rdu.redhat.com>
 <alpine.DEB.2.00.1202231505080.26362@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202231505080.26362@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Josef Bacik <josef@redhat.com>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Thu, Feb 23, 2012 at 03:09:36PM -0800, David Rientjes wrote:
> On Thu, 23 Feb 2012, Josef Bacik wrote:
> 
> > I requested this specifically because I was oom'ing the box so hard that I
> > couldn't read /proc/slabinfo at the time of OOM and therefore had no idea what I
> > was leaking.  Telling me how much slab was in use was no help, I needed to know
> > which of the like 6 objects I was doing horrible things with was screwing me,
> > and without this patch I would have no way of knowing.
> > 
> 
> So an oom was creating a denial of service so that you had no way to do 
> cat /proc/slabinfo?  I think we should talk about this first, because 
> that's a serious situation that certainly shouldn't be happening.
>

Um well yeah, I'm rewriting a chunk of btrfs which was rapantly leaking memory
so the OOM just couldn't keep up with how much I was sucking down.  This is
strictly a developer is doing something stupid and needs help pointing out what
it is sort of moment, not a day to day OOM.
 
> The oom killer is designed to kill the most memory-hogging task available 
> so that it doesn't have to kill multiple threads.  Why was the memory not 
> being freed or why was the thread that was consistently being killed 
> restarted time and time again so you couldn't even cat a file?
> 

Memory was not being freed because it was all tied up in the metadata cache
stuff that I'm working on.

> > Sure, if the OOM killer doesn't kill the poller, or kill NetworkManager since
> > I'm remote logged into the box, or any of the other various important things
> > that would be required for me to get this info.  Thanks,
> > 
> 
> If you're polling for oom notifications sanely, you'd probably have set
> 
> 	echo -1000 > /proc/pid/oom_score_adj
> 
> so it's unkillable as well as anything else you need to diagnose failures.  
> NetworkManager itself isn't protected like this by default, but it 
> shouldn't be killed unless it is leaking memory itself: we kill in the 
> order of the most memory usage to the least.
> 
> So neither of these are reasons to not collect /proc/slabinfo, but I'm 
> very interested in your follow-up to why you can't do so when "ooming the 
> box so hard" where you're presumably able to cat to kernel log file but 
> not cat /proc/slabinfo :)

I'm not able to cat the kernel log file, I was using netconsole so I'd see the
OOM, and then nothing, couldn't do anything on the screen session I had and IIRC
netconsole just stopped, it required a hard reboot.

I think you are missing the point here.  This is likely not usefull in normal
OOM situations, this is for my very narrow need of doing something sooo
incredibly stupid that it makes the box unusable, but I still need to get some
sort of info out so I can know _which_ stupid thing I'm doing.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
