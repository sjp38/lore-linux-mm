Date: Thu, 21 Aug 2008 19:59:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [discuss] memrlimit - potential applications that can use
Message-Id: <20080821195915.f1ecd012.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48AD42E1.40204@linux.vnet.ibm.com>
References: <48AA73B5.7010302@linux.vnet.ibm.com>
	<1219161525.23641.125.camel@nimitz>
	<48AAF8C0.1010806@linux.vnet.ibm.com>
	<1219167669.23641.156.camel@nimitz>
	<48ABD545.8010209@linux.vnet.ibm.com>
	<1219249757.8960.22.camel@nimitz>
	<48ACE040.2030807@linux.vnet.ibm.com>
	<20080821164339.679212b2.kamezawa.hiroyu@jp.fujitsu.com>
	<48AD42E1.40204@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Aug 2008 15:56:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Aug 2008 08:55:52 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >>>>> So, before we expand the use of those features to control groups by
> >>>>> adding a bunch of new code, let's make sure that there will be users
> >>>> for
> >>>>> it and that those users have no better way of doing it.
> >>>> I am all ears to better ways of doing it. Are you suggesting that overcommit was
> >>>> added even though we don't actually need it?
> >>> It serves a purpose, certainly.  We have have better ways of doing it
> >>> now, though.  "i>>?So, before we expand the use of those features to
> >>> control groups by adding a bunch of new code, let's make sure that there
> >>> will be users for it and that those users have no better way of doing
> >>> it."
> >>>
> >>> The one concrete user that's been offered so far is postgres.  I've
> >> No, you've been offered several, including php and apache that use memory limits.
> >>
> >>> suggested something that I hope will be more effective than enforcing
> >>> overcommit.  
> > 
> > I'm sorry I miss the point. My concern on memrlimit (for overcommiting) is that
> > it's not fair because an application which get -ENOMEM at mmap() is just someone
> > unlucky.
> 
> It can happen today with overcommit turned on. Why is it unlucky?
> 
Today's overcommit is also unlucky ;) 

For example) process A and B is under a memrlimit.
 process A no memory leak, it often calls malloc() and free().
 process B does memory leak, 100MB per night.

process A cannot do anything when it notices malloc() returns NULL.
It controls his memory usage perfectly. He is unlucky and will die.
process B can use up VSZ which is freed by process A.

(OOM-killer, is disliked by everyone, have some kind of fairness.
 It checks usage.)

>  I think it's better to trigger some notifier to application or daemon
> > rather than return -ENOMEM at mmap(). Notification like "Oh, it seems the VSZ
> > of total application exceeds the limit you set. Although you can continue your
> > operation, it's recommended that you should fix up the  situation".
> > will be good.
> > 
> 
> So you are suggesting that when we are running out of memory (as defined by our
> current resource constraints), we don't return -ENOMEM, but instead we now
> handle a new event that states that we are running out of memory?
> 
Not "running out of memory" Just "VSZ is over the limit you set/expected".

My point is an application witch can handle NULL returned by malloc() is
not very popular, I think.

Sorry for noise.

Thanks,
-Kame

> NOTE: I am not opposed to the event, it can be useful for container
> administrators to know how to size their containers, not to application
> developers who want to auto-tune their applications (see my comment on autonomic
> computing in an earlier thread) or to applications that want to make sure they
> don't OOM without the system administrator having to do oom_adj for every
> important application.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
