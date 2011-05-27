Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8630F6B0012
	for <linux-mm@kvack.org>; Fri, 27 May 2011 19:31:03 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p4RNUpO9017393
	for <linux-mm@kvack.org>; Fri, 27 May 2011 16:30:51 -0700
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by hpaq7.eem.corp.google.com with ESMTP id p4RNUURb014673
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 16:30:37 -0700
Received: by pwi15 with SMTP id 15so1235115pwi.5
        for <linux-mm@kvack.org>; Fri, 27 May 2011 16:30:36 -0700 (PDT)
Date: Fri, 27 May 2011 16:30:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] cpusets: randomize node rotor used in
 cpuset_mem_spread_node()
In-Reply-To: <20110527231700.GA3214@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1105271628430.9445@chino.kir.corp.google.com>
References: <20110414065146.GA19685@tiehlicka.suse.cz> <20110414160145.0830.A69D9226@jp.fujitsu.com> <20110415161831.12F8.A69D9226@jp.fujitsu.com> <20110415082051.GB8828@tiehlicka.suse.cz> <20110526153319.b7e8c0b6.akpm@linux-foundation.org>
 <20110527124705.GB4067@tiehlicka.suse.cz> <20110527142051.d7ec3784.akpm@linux-foundation.org> <20110527231700.GA3214@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Jack Steiner <steiner@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Sat, 28 May 2011, Michal Hocko wrote:

> > --- a/include/linux/nodemask.h~cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node-fix-2
> > +++ a/include/linux/nodemask.h
> > @@ -433,8 +433,6 @@ static inline void node_set_offline(int 
> >  	nr_online_nodes = num_node_state(N_ONLINE);
> >  }
> >  
> > -extern int node_random(const nodemask_t *maskp);
> > -
> >  #else
> >  
> >  static inline int node_state(int node, enum node_states state)
> > @@ -466,7 +464,15 @@ static inline int num_node_state(enum no
> >  #define node_set_online(node)	   node_set_state((node), N_ONLINE)
> >  #define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
> >  
> > -static inline int node_random(const nodemask_t *mask) { return 0; }
> > +#endif
> > +
> > +#if defined(CONFIG_NUMA) && (MAX_NUMNODES > 1)
> > +extern int node_random(const nodemask_t *maskp);
> > +#else
> > +static inline int node_random(const nodemask_t *mask)
> > +{
> > +	return 0;
> > +}
> >  #endif
> 
> I have to admit that I quite don't understand concept of several nodes
> with UMA archs but do we really want to provide the sane node all the
> time?
> 

They aren't nodes on UMA machines, they are memory regions for 
DISCONTIGMEM which are separated by large holes in the address space.  
These archs will never sanely use node_random(), so it doesn't really 
matter except for CONFIG_NUMA where MAX_NUMNODES > 1, since they won't be 
selecting random memory regions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
