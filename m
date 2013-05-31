Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 623A56B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 03:55:24 -0400 (EDT)
Date: Fri, 31 May 2013 09:55:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: TLB and PTE coherency during munmap
Message-ID: <20130531075508.GE27176@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com>
 <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com>
 <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

On Fri, May 31, 2013 at 08:09:17AM +0400, Max Filippov wrote:
> Hi Peter,
> 
> On Wed, May 29, 2013 at 9:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > What about something like this?
> 
> With that patch I still get mtest05 firing my TLB/PTE incoherency check
> in the UP PREEMPT_VOLUNTARY configuration. This happens after
> zap_pte_range completion in the end of unmap_region because of
> rescheduling called in the following call chain:
> 
> unmap_region
>   free_pgtables
>     unlink_anon_vmas
>       lock_anon_vma_root
>         down_write
>           might_sleep
>             might_resched
>               _cond_resched
> 

Hurm, yeah. Catching all regular blocking primitives and making it
maintainable is going to be a problem :/

I suppose the easiest thing is simply killing fast_mode for now/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
