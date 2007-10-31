Date: Wed, 31 Oct 2007 12:15:57 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071031121557.7b7468c7@bree.surriel.com>
In-Reply-To: <1193850073.17412.40.camel@dyn9047017100.beaverton.ibm.com>
References: <20071030191827.GB31038@dmt>
	<1193781568.8904.33.camel@dyn9047017100.beaverton.ibm.com>
	<20071030171209.0caae1d5@cuia.boston.redhat.com>
	<472801DC.6050802@us.ibm.com>
	<20071031003119.05dc064e@bree.surriel.com>
	<1193850073.17412.40.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm <linux-mm@kvack.org>, drepper@redhat.com, Andrew Morton <akpm@linux-foundation.org>, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007 09:01:13 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> > Well, if the scheme is implemented "right", then what you
> > describe will never happen because programs will have freed
> > their excess memory already before any swapping happens.
> 
> Hmm.. Most cases, application doesn't care about swapping
> activity of the kernel - unless its something to do with
> one of its own processes/threads. So having notifications
> per-process/app/cgroup is what they are looking for.

That seems awfully short sighted to me.  Additional IO has
the potential to slow any application down, simply by keeping
the disk busy.

Also, if you only send out a notification by the time it is
too late, it will be too late.  You cannot avoid IO if you
do not send out the notification until you've done IO.

If you send out the notification before IO has been done, you
don't know for sure who would have been swapped out.

> But again, how they would react to the notification is 
> an interesting thing. If they really act nice and free
> up stuff they don't need or read more crap and cause
> more swapping :(

The easiest thing an app can do when getting the notification
is to madvise(MADV_DONTNEED) any pages that are on internal
free lists, eg. free(3)d memory, memory on a garbage collector
free list, etc...

Other things that could be done is to reduce the size of a
cache, or to kick off a garbage collector run.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
