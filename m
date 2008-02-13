Subject: Re: [PATCH 2.6.24-mm1]  Mempolicy:  silently restrict nodemask to
	allowed nodes V3
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0802121100211.9649@chino.kir.corp.google.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org>
	 <1202748459.5014.50.camel@localhost>
	 <20080212091910.29A0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <alpine.DEB.1.00.0802111649330.6119@chino.kir.corp.google.com>
	 <1202828903.4974.8.camel@localhost>
	 <alpine.DEB.1.00.0802121100211.9649@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Tue, 12 Feb 2008 17:07:20 -0700
Message-Id: <1202861240.4974.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-12 at 11:06 -0800, David Rientjes wrote:
> On Tue, 12 Feb 2008, Lee Schermerhorn wrote:
> 
> > Firstly, because this was the original API. 
> > 
> > Secondly, I consider this key to extensible API design.  Perhaps,
> > someday, we might want to assign some semantic to certain non-empty
> > nodemasks to MPOL_DEFAULT.  If we're allowing applications to pass
> > arbitrary nodemask now, and just ignoring them, that becomes difficult.
> > Just like dis-allowing unassigned flag values.
> > 
> 
> I allow it with my patchset because there's simply no reason not to.

I'm interpreting this as "because I [David] simply see no reason not
to."   

> 
> MPOL_DEFAULT is the default system-wide policy that does not require a 
> nodemask as a parameter.  Both the man page (set_mempolicy(2)) and the 
> documentation (Documentation/vm/numa_memory_policy.txt) state that.
> 
> It makes no sense in the future to assign a meaning to a nodemask passed 
> along with MPOL_DEFAULT.  None at all.  

Again, you're stating an opinion, to which you're entitled, or
expressing a limitation to your clairvoyance, for which I can't fault
you.  Indeed, I tend to agree with you on this particular point--my own
opinion and/or lack of vision.  However, I've been burned in the past by
just this scenario--wanting to assign meaning to something that was
ignored--because it could break existing applications.  So, on general
principle, I like to be fairly strict with argument checking [despite my
natural libertarian tendencies].

> The policy is simply the 
> equivalent of default_policy and, as the system default, a nodemask 
> parameter to the system default policy is wrong be definition.  
> 
> So, logically, we can either allow all nodemasks to be passed with a 
> MPOL_DEFAULT policy or none at all (it must be NULL).  Empty nodemasks 
> don't have any logical relationship with MPOL_DEFAULT.

Ah, maybe this explains our disconnect.  Internally, a NULL nodemask
pointer specified by the application is equivalent to an empty nodemask
is equivalent to maxnode == 0.  See get_nodes().  By the time
mpol_check_policy() or mpol_new() get called, all they have is a pointer
to the cleared nodemask in the stack frame of sys_set_mempolicy() or
sys_mbind().  So, the existing code's error checking doesn't require one
to specify a non-NULL, but empty nodemask.  It just requires that one
does not specify any nodes with MPOL_DEFAULT.  

Does this help clarify things?

Lee

P.S.,

I've had time to review the patches and have comments queued up.  I'll
send along comments shortly [wherein I do mention my preference for the
error checking].


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
