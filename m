Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2C7286B0139
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 14:10:06 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro2so383173pbb.18
        for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:10:05 -0700 (PDT)
Message-ID: <1367345403.11020.1.camel@edumazet-glaptop>
Subject: Re: [PATCH 1/2] Make the batch size of the percpu_counter
 configurable
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Apr 2013 11:10:03 -0700
In-Reply-To: <1367339009.27102.174.camel@schen9-DESK>
References: 
	<c1f9c476a8bd1f5e7049b8ac79af48be61afd8f3.1367254913.git.tim.c.chen@linux.intel.com>
	 <0000013e5b24d2c5-9b899862-e2fd-4413-8094-4f1e5a0c0f62-000000@email.amazonses.com>
	 <1367339009.27102.174.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2013-04-30 at 09:23 -0700, Tim Chen wrote:
> On Tue, 2013-04-30 at 13:32 +0000, Christoph Lameter wrote:
> > On Mon, 29 Apr 2013, Tim Chen wrote:
> > 
> > > diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
> > > index d5dd465..5ca7df5 100644
> > > --- a/include/linux/percpu_counter.h
> > > +++ b/include/linux/percpu_counter.h
> > > @@ -22,6 +22,7 @@ struct percpu_counter {
> > >  	struct list_head list;	/* All percpu_counters are on a list */
> > >  #endif
> > >  	s32 __percpu *counters;
> > > +	int *batch ____cacheline_aligned_in_smp;
> > >  };
> > 
> > What is this for and why does it have that alignmend?
> 
> I was assuming that if batch is frequently referenced, it probably
> should not share a cache line with the counters field.

But 'counters' field has the same requirement. Its supposed to be read
only field. 

So please remove this '____cacheline_aligned_in_smp', as it makes the
whole struct percpu_counter at least two cache lines wide, for no
obvious reason.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
