Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AFD646B01DD
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 17:19:30 -0400 (EDT)
Date: Tue, 8 Jun 2010 23:17:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 09/18] oom: select task from tasklist for mempolicy ooms
Message-ID: <20100608211748.GA13542@redhat.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061525000.32225@chino.kir.corp.google.com> <20100608140818.b413c335.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100608140818.b413c335.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06/08, Andrew Morton wrote:
>
> On Sun, 6 Jun 2010 15:34:31 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
>
> > +			if (cpuset_mems_allowed_intersects(current, tsk))
> > +				return true;
> > +		}
> > +		tsk = next_thread(tsk);
>
> hm, next_thread() uses list_entry_rcu().  What are the locking rules
> here?  It's one of both of rcu_read_lock() and read_lock(&tasklist_lock),
> I think?

Yes, next_thread() is safe under tasklist/rcu/siglock.

> > +	} while (tsk != start);
> > +	return false;
> >  }
>
> This is all bloat and overhead for non-NUMA builds.  I doubt if gcc is
> able to eliminate the task_struct walk (although I didn't check).

I'd also suggest while_each_thread() instead if next_thread() +
"tsk != start", but this is really minor nit.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
