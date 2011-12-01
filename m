Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 555136B006E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 08:04:36 -0500 (EST)
Date: Thu, 1 Dec 2011 14:04:31 +0100
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: KSM: numa awareness sysfs knob
Message-ID: <20111201130430.GA3361@dhcp-27-244.brq.redhat.com>
References: <1322649446-11437-1-git-send-email-pholasek@redhat.com>
 <20111130154719.57154fdd.akpm@linux-foundation.org>
 <20111201101640.GA2156@dhcp-27-244.brq.redhat.com>
 <201112011940.19022.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201112011940.19022.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Thu, 01 Dec 2011, Nai Xia wrote:

> Date: Thu, 1 Dec 2011 19:40:18 +0800
> From: Nai Xia <nai.xia@gmail.com>
> To: Petr Holasek <pholasek@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins
>  <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>,
>  linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov
>  <anton@redhat.com>
> Subject: Re: KSM: numa awareness sysfs knob
> Reply-To: nai.xia@gmail.com
> 
> On Thursday 01 December 2011 18:16:40 Petr Holasek wrote:
> > On Wed, 30 Nov 2011, Andrew Morton wrote:
> > 
> > > Date: Wed, 30 Nov 2011 15:47:19 -0800
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > To: Petr Holasek <pholasek@redhat.com>
> > > Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli
> > >  <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
> > >  Anton Arapov <anton@redhat.com>
> > > Subject: Re: [PATCH] [RFC] KSM: numa awareness sysfs knob
> > > 
> > > On Wed, 30 Nov 2011 11:37:26 +0100
> > > Petr Holasek <pholasek@redhat.com> wrote:
> > > 
> > > > Introduce a new sysfs knob /sys/kernel/mm/ksm/max_node_dist, whose
> > > > value will be used as the limitation for node distance of merged pages.
> > > > 
> > > 
> > > The changelog doesn't really describe why you think Linux needs this
> > > feature?  What's the reasoning?  Use cases?  What value does it provide?
> > 
> > Typical use-case could be a lot of KVM guests on NUMA machine and cpus from
> > more distant nodes would have significant increase of access latency to the
> > merged ksm page. I chose sysfs knob for higher scalability.
> 
> Seems this consideration for NUMA is sound. 
> 
> > 
> > > 
> > > > index b392e49..b882140 100644
> > > > --- a/Documentation/vm/ksm.txt
> > > > +++ b/Documentation/vm/ksm.txt
> > > > @@ -58,6 +58,10 @@ sleep_millisecs  - how many milliseconds ksmd should sleep before next scan
> > > >                     e.g. "echo 20 > /sys/kernel/mm/ksm/sleep_millisecs"
> > > >                     Default: 20 (chosen for demonstration purposes)
> > > >  
> > > > +max_node_dist    - maximum node distance between two pages which could be
> > > > +                   merged.
> > > > +                   Default: 255 (without any limitations)
> > > 
> > > And this doesn't explain to our users why they might want to alter it,
> > > and what effects they would see from doing so.  Maybe that's obvious to
> > > them...
> > 
> > Now I can't figure out more extensive description of this feature, but we
> > could explain it deeply, of course.
> 
> However, if we don't know what the number fed into this knob really means, 
> seems nobody would think of using this knob...
> 
> Then why not make this NUMA feature automatically adjusted by some algorithm
> instread of dropping it to userland?
> 
> BTW, the algrothim you already include in this patch seems unstable itself:
> 
> Suppose we have three duplicated pages in order: Page_a, Page_b, Page_c with 
> distance(Page_a, Page_b) == distance(Page_b, Page_c) == 3, 
> but distance(Page_a, Page_c) == 6 and if max_node_dist == 3, 
> a stable algorithm should result in Page_a and Page_c being merged to Page_b,
> independent of the order these pages get scanned. 
> 
> But with your patch, if ksmd goes Page_b --> Page_c --> Page_a, will it 
> result in Page_b being merged to Page_c but Page_a not merged since its 
> distance to Page_c is 6?

Yes, you're right. With this patch, merge order depends only on the order of
scanning. Use of some algorithm (maybe from graph-theory field?) is a really 
good point. Although the complexity of code will rise a lot, it maybe the
best solution for most of usecases when this algorithm would be able to do 
some heuristics and determine max_distance for merging on its own without 
any userspace inputs.

> 
> It may easy to further deduce that maybe a worst case(or even many cases?) 
> for your patch will get many many could-be-merged pages not merged simply 
> because of the sequence they are scanned.
> 
> The problem you plan to solve maybe worthwhile, but it may also be much more
> complex than you expected ;-)

That's the reason why it is only RFC, I mainly wanted to gather your opinions:)

>   
> 
> BR,
> 
> Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
