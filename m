From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908070804.BAA32970@google.engr.sgi.com>
Subject: [PATCH] rlim patch
Date: Sat, 7 Aug 1999 01:04:01 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: grg@ai.mit.edu
Cc: torvalds@transmeta.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Howdy --
> 
> Regarding http://reality.sgi.com/kanoj_engr/rlim.patch :
> 
> Thanks for the patch!
> I've also had to do similar things myself because I'm using over 2G virtual.

Linus/Alan, could you guys please look at the (2.2.10) patch at

	http://reality.sgi.com/kanoj_engr/rlim.patch

for inclusion into 2.2 and 2.3. It is absolutely essential for processes 
which want to fill up their 3Gb user space completely.

> 
> Do you know what the chance is of getting this patch into the kernel? 
> It's definitely useful and IMHO it should be considered a bugfix.
> (Was this posted to some list?)
> 
> 
> > This patch tries to fix some problems in the 2.2.10 kernel in regards
> > to limit checks on vm resources. Specifically, the RLIMIT_AS and
> > RLIMIT_MEMLOCK resource checking does not have a concept of "unlimited",
> > ie RLIM_INFINITY, this patch introduces that. Note that limits are
> > defined as "long" quantities, and none of the limit values can be
> > set to negative quantities via setrlimit. Hence, LONG_MAX is the
> > maximum value of any limit, and this is the same as RLIM_INFINITY.
> 
> An additional way of dealing with this problem is to make all those longs
> be unsigned, and make INFINITY be ~0UL.  This offers the advantage that you
> can also set resource limits to be between 2G and the maximum the kernel
> allows (e.g., 3G by default), instead of having all that be "infinity."  
> I realize only the very perverse would want to set some resource limit
> between 2G and 3G :), but this would seem to be The Right Thing anyway.

You will see that in a bunch of places, the kernel tries to cast the
"long" limits into "unsigned long" before doing the checks. Unfortunately,
setrlimit() does not let you set "long" -ve values, so this is of
limited use by itself. 


> To gain that advantage we'd need to have libc use and surface unsigned
> types too (which I've done on my system), which is actually claimed to
> be what the spec calls for in the first place.
>

Here in lies the dilemma of the concept of independent software modules. 
It would be a very nice thing to be able to isolate kernel changes and libc
(or command) changes, and not have them depend on each other. In cases like
this though, that poses problems, because you probably want old and new
kernels working properly on old and new libc's.

> 
> What do you think?
> 

Note that most limits are already set to LONG_MAX, which is also RLIM_INFINITY.
Couldn't we isolate the fix to just the kernel, and basically treat LONG_MAX
as RLIM_INFINITY, without wanting finer resolution?

Kanoj

> thx,
> grg
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
