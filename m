Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id C32706B00EA
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 19:57:37 -0500 (EST)
Date: Tue, 6 Mar 2012 21:55:54 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
Message-ID: <20120307005553.GB2613@x61.redhat.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
 <20120306160833.0e9bf50a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120306160833.0e9bf50a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Mar 06, 2012 at 04:08:33PM -0800, Andrew Morton wrote:
> On Sun, 4 Mar 2012 13:43:32 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > BUG() is a no-op when CONFIG_BUG is disabled, so slab_node() needs a
> > dummy return value to avoid reaching the end of a non-void function.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/mempolicy.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1611,6 +1611,7 @@ unsigned slab_node(struct mempolicy *policy)
> >  
> >  	default:
> >  		BUG();
> > +		return numa_node_id();
> >  	}
> >  }
> 
> Wait.  If the above code generated a warning then surely we get a *lot*
> of warnings!  I'd expect that a lot of code assumes that BUG() never
> returns?
In a quick make (ARCH=um defconfig | CONFIG_BUG=n) the following four
warnings have popped out: 

kernel/sched/core.c:3144:1: warning: control reaches end of non-void function
[-Wreturn-type]
mm/bootmem.c:352:1: warning: control reaches end of non-void function
[-Wreturn-type]
fs/locks.c:1469:1: warning: control reaches end of non-void function
[-Wreturn-type]
block/cfq-iosched.c:2912:1: warning: control reaches end of non-void function
[-Wreturn-type]
net/core/ethtool.c:211:1: warning: control reaches end of non-void function
[-Wreturn-type]


So, yes... Unfortunately, we would see a lot more warnings for a (more) complete
kernel configuration.

> 
> Can we fix this within the BUG() definition?  I can't think of a way,
> unless gcc gives us a way of accessing the return type of the current
> function, and I don't think it does that.
> 
> 
> Also, does CONIG_BUG=n even make sense?  If we got here and we know
> that the kernel has malfunctioned, what point is there in pretending
> otherwise?  Odd.

I admit I was thinking about in follow David's example and start chasing
similar cases to propose a janitorial patch, however, I couldn't agree more with
your point here. It seems odd turning CONFIG_BUG off and neglect well known buggy
conditions within the code. Perhaps, then, the best way to cope with this oddity
would be just drop CONFIG_BUG config knob at all, making it permanently "on".

Any other thoughts?

  Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
