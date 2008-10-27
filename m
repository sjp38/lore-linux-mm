Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9RLKRKE031693
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 15:20:27 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RLKcqE136552
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 15:20:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RLK8S6005666
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 15:20:08 -0600
Date: Mon, 27 Oct 2008 16:20:36 -0500
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint
	restart
Message-ID: <20081027212036.GA32162@us.ibm.com>
References: <20081021124130.a002e838.akpm@linux-foundation.org> <20081021202410.GA10423@us.ibm.com> <48FE82DF.6030005@cs.columbia.edu> <20081022152804.GA23821@us.ibm.com> <48FF4EB2.5060206@cs.columbia.edu> <87tzayh27r.wl%peter@chubb.wattle.id.au> <49059FED.4030202@cs.columbia.edu> <1225125752.12673.79.camel@nimitz> <4905F648.4030402@cs.columbia.edu> <1225140705.5115.40.camel@enoch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1225140705.5115.40.camel@enoch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Peter Chubb <peterc@gelato.unsw.edu.au>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, hpa@zytor.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Quoting Matt Helsley (matthltc@us.ibm.com):
> On Mon, 2008-10-27 at 13:11 -0400, Oren Laadan wrote:
> > Dave Hansen wrote:
> > > On Mon, 2008-10-27 at 07:03 -0400, Oren Laadan wrote:
> > >>> In our implementation, we simply refused to checkpoint setid
> > >> programs.
> > >>
> > >> True. And this works very well for HPC applications.
> > >>
> > >> However, it doesn't work so well for server applications, for
> > >> instance.
> > >>
> > >> Also, you could use file system snapshotting to ensure that the file
> > >> system view does not change, and still face the same issue.
> > >>
> > >> So I'm perfectly ok with deferring this discussion to a later time :)
> > > 
> > > Oren, is this a good place to stick a process_deny_checkpoint()?  Both
> > > so we refuse to checkpoint, and document this as something that has to
> > > be addressed later?
> > 
> > why refuse to checkpoint ?
> 
> 	If most setuid programs hold privileged resources for extended periods
> of time after dropping privileges then it seems like a good idea to
> refuse to checkpoint. Restart of those programs would be quite
> unreliable unless/until we find a nice solution.

I agree with Dave and Matt.  Let's assume that we have a setuid root
program which creates some resources then drops to username kooky.  If
you now checkpoint and restart that program, then a stupid restart will
either

	1. be done as user kooky and not be able to recreate the
	resources, fail.
	2. be done as user root and not drop uid back to kooky, unsafe.

For the earliest prototypes of c/r, I think saying that setuid an the
life of a container makes checkpoint impossible is the right thing to
do.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
