Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id AB6826B0133
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:48:36 -0400 (EDT)
Subject: Re: [PATCH 1/2] Make the batch size of the percpu_counter
 configurable
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <0000013e5bfd1548-a6ef7962-7b00-495b-8e83-d7a08413e165-000000@email.amazonses.com>
References: 
	 <c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
	 <0000013e5b24d2c5-9b899862-e2fd-4413-8094-4f1e5a0c0f62-000000@email.amazonses.com>
	 <1367339009.27102.174.camel@schen9-DESK>
	 <0000013e5bfd1548-a6ef7962-7b00-495b-8e83-d7a08413e165-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Apr 2013 10:48:14 -0700
Message-ID: <1367344094.27102.182.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2013-04-30 at 17:28 +0000, Christoph Lameter wrote:
> On Tue, 30 Apr 2013, Tim Chen wrote:
> 
> > On Tue, 2013-04-30 at 13:32 +0000, Christoph Lameter wrote:
> > > On Mon, 29 Apr 2013, Tim Chen wrote:
> > >
> > > > diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> > > > index d5dd465..5ca7df5 100644
> > > > --- a/include/linux/percpu_counter.h
> > > > +++ b/include/linux/percpu_counter.h
> > > > @@ -22,6 +22,7 @@ struct percpu_counter {
> > > >  	struct list_head list;	/* All percpu_counters are on a list */
> > > >  #endif
> > > >  	s32 __percpu *counters;
> > > > +	int *batch ____cacheline_aligned_in_smp;
> > > >  };
> > >
> > > What is this for and why does it have that alignmend?
> >
> > I was assuming that if batch is frequently referenced, it probably
> > should not share a cache line with the counters field.
> 
> And why is it a pointer?

A pointer because the default percpu_counter_batch value could change
later when cpus come online after we initialize per cpu counter and
percpu_counter_batch will get computed again in percpu_counter_startup.
Making it a pointer will make it unnecessary to come back and change the
batch sizes if we use static batch value and default batch size.

> 
> And the pointer is so frequently changed that it needs it own cache line?
> 

On second thought, your're right. It is unnecessary for *batch to have
its own cache line as the counters pointer and head_list above it will
not change frequently.  I'll remove the cache alignment.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
