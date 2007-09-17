Date: Mon, 17 Sep 2007 12:00:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] cpuset dirty limits
In-Reply-To: <20070914161540.5b192348.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709171153010.27542@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
 <46E743F8.9050206@google.com> <20070914161540.5b192348.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, pj@sgi.com, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007, Andrew Morton wrote:

> > +	mutex_lock(&callback_mutex);
> > +	*cs_int = val;
> > +	mutex_unlock(&callback_mutex);
> 
> I don't think this locking does anything?

Locking is wrong here. The lock needs to be taken before the cs pointer 
is dereferenced from the caller.

> > +	return 0;
> > +}
> > +
> >  /*
> >   * Frequency meter - How fast is some event occurring?
> >   *
> > ...
> > +void cpuset_get_current_ratios(int *background_ratio, int *throttle_ratio)
> > +{
> > +	int background = -1;
> > +	int throttle = -1;
> > +	struct task_struct *tsk = current;
> > +
> > +	task_lock(tsk);
> > +	background = task_cs(tsk)->background_dirty_ratio;
> > +	throttle = task_cs(tsk)->throttle_dirty_ratio;
> > +	task_unlock(tsk);
> 
> ditto?

It is required to take the task lock while dereferencing the tasks cpuset 
pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
