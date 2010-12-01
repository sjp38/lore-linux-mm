Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 550686B009D
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:13:50 -0500 (EST)
Date: Wed, 1 Dec 2010 12:13:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [thisops uV3 08/18] Taskstats: Use this_cpu_ops
In-Reply-To: <1291226786.2898.22.camel@holzheu-laptop>
Message-ID: <alpine.DEB.2.00.1012011212490.3774@router.home>
References: <20101130190707.457099608@linux.com>  <20101130190845.819605614@linux.com> <1291226786.2898.22.camel@holzheu-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010, Michael Holzheu wrote:

> >  		return -ENOMEM;
> >
> >  	if (!info) {
> > -		int seq = get_cpu_var(taskstats_seqnum)++;
> > -		put_cpu_var(taskstats_seqnum);
> > +		int seq = this_cpu_inc_return(taskstats_seqnum);
>
> Hmmm, wouldn't seq now always be one more than before?
>
> I think that "seq = get_cpu_var(taskstats_seqnum)++" first assigns
> taskstats_seqnum to seq and then increases the value in contrast to
> this_cpu_inc_return() that returns the already increased value, correct?

Correct. We need to subtract one from that (which will eliminate the minus
-1 that the inline this_cpu_inc_return creates).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
