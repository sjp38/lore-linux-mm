Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 1925B6B0070
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 19:46:44 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id jt11so9450450pbb.40
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 16:46:43 -0800 (PST)
Message-ID: <1357346803.5273.10.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
From: Simon Jeons <simon.jeons@gmail.com>
Date: Fri, 04 Jan 2013 18:46:43 -0600
In-Reply-To: <CAKYAXd-kcnxm6Do9VcbdyrCBvArrjz1iHOpxXHnyUyNcqP7Ofg@mail.gmail.com>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
	 <20121231113054.GC7564@quack.suse.cz>
	 <20130102134334.GB30633@quack.suse.cz>
	 <CAKYAXd8-sZo0XcdHuyOQ1qT_s3kJXyphXsjSS7e1-sJ1QaAOgg@mail.gmail.com>
	 <1357261151.5105.2.camel@kernel.cn.ibm.com>
	 <CAKYAXd-kcnxm6Do9VcbdyrCBvArrjz1iHOpxXHnyUyNcqP7Ofg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, fengguang.wu@intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Dave Chinner <dchinner@redhat.com>

On Fri, 2013-01-04 at 16:41 +0900, Namjae Jeon wrote:
> 2013/1/4, Simon Jeons <simon.jeons@gmail.com>:
> > On Thu, 2013-01-03 at 13:35 +0900, Namjae Jeon wrote:
> >> 2013/1/2, Jan Kara <jack@suse.cz>:
> >> > On Tue 01-01-13 08:51:04, Wanpeng Li wrote:
> >> >> On Mon, Dec 31, 2012 at 12:30:54PM +0100, Jan Kara wrote:
> >> >> >On Sun 30-12-12 14:59:50, Namjae Jeon wrote:
> >> >> >> From: Namjae Jeon <namjae.jeon@samsung.com>
> >> >> >>
> >> >> >> Consider Process A: huge I/O on sda
> >> >> >>         doing heavy write operation - dirty memory becomes more
> >> >> >>         than dirty_background_ratio
> >> >> >>         on HDD - flusher thread flush-8:0
> >> >> >>
> >> >> >> Consider Process B: small I/O on sdb
> >> >> >>         doing while [1]; read 1024K + rewrite 1024K + sleep 2sec
> >> >> >>         on Flash device - flusher thread flush-8:16
> >> >> >>
> >> >> >> As Process A is a heavy dirtier, dirty memory becomes more
> >> >> >> than dirty_background_thresh. Due to this, below check becomes
> >> >> >> true(checking global_page_state in over_bground_thresh)
> >> >> >> for all bdi devices(even for very small dirtied bdi - sdb):
> >> >> >>
> >> >> >> In this case, even small cached data on 'sdb' is forced to flush
> >> >> >> and writeback cache thrashing happens.
> >> >> >>
> >> >> >> When we added debug prints inside above 'if' condition and ran
> >> >> >> above Process A(heavy dirtier on bdi with flush-8:0) and
> >> >> >> Process B(1024K frequent read/rewrite on bdi with flush-8:16)
> >> >> >> we got below prints:
> >> >> >>
> >> >> >> [Test setup: ARM dual core CPU, 512 MB RAM]
> >> >> >>
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56064
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56704
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 84720
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 94720
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   384
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   960
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92160
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   256
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   768
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   256
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   320
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92032
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 91968
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =  1024
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   576
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 84352
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   512
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92608
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92544
> >> >> >> KB
> >> >> >>
> >> >> >> As mentioned in above log, when global dirty memory > global
> >> >> >> background_thresh
> >> >> >> small cached data is also forced to flush by flush-8:16.
> >> >> >>
> >> >> >> If removing global background_thresh checking code, we can reduce
> >> >> >> cache
> >> >> >> thrashing of frequently used small data.
> >> >> >  It's not completely clear to me:
> >> >> >  Why is this a problem? Wearing of the flash? Power consumption? I'd
> >> >> > like
> >> >> >to understand this before changing the code...
> >> Hi Jan.
> >> Yes, it can reduce wearing and fragmentation of flash. And also from
> >> one scenario - we
> >> think it might reduce power consumption also.
> >>
> >> >> >
> >> >> >> And It will be great if we can reserve a portion of writeback cache
> >> >> >> using
> >> >> >> min_ratio.
> >> >> >>
> >> >> >> After applying patch:
> >> >> >> $ echo 5 > /sys/block/sdb/bdi/min_ratio
> >> >> >> $ cat /sys/block/sdb/bdi/min_ratio
> >> >> >> 5
> >> >> >>
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56064
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56704
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  84160
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  96960
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  94080
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93120
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93120
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  91520
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  89600
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93696
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93696
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  72960
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90624
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90624
> >> >> >> KB
> >> >> >> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90688
> >> >> >> KB
> >> >> >>
> >> >> >> As mentioned in the above logs, once cache is reserved for Process
> >> >> >> B,
> >> >> >> and patch is applied there is less writeback cache thrashing on sdb
> >> >> >> by frequent forced writeback by flush-8:16 in over_bground_thresh.
> >> >> >>
> >> >> >> After all, small cached data will be flushed by periodic writeback
> >> >> >> once every dirty_writeback_interval.
> >> >> >  OK, in principle something like this makes sence to me. But if
> >> >> > there
> >> >> > are
> >> >> >more BDIs which are roughly equally used, it could happen none of
> >> >> > them
> >> >> > are
> >> >> >over threshold due to percpu counter & rounding errors. So I'd rather
> >> >> >change the conditions to something like:
> >> >> >	reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> >> >> >	bdi_bground_thresh = bdi_dirty_limit(bdi, background_thresh);
> >> >> >
> >> >> >  	if (reclaimable > bdi_bground_thresh)
> >> >> >		return true;
> >> >> >	/*
> >> >> >	 * If global background limit is exceeded, kick the writeback on
> >> >> >	 * BDI if there's a reasonable amount of data to write (at least
> >> >> >	 * 1/2 of BDI's background dirty limit).
> >> >> >	 */
> >> >> >	if (global_page_state(NR_FILE_DIRTY) +
> >> >> >	    global_page_state(NR_UNSTABLE_NFS) > background_thresh &&
> >> >> >	    reclaimable * 2 > bdi_bground_thresh)
> >> >> >		return true;
> >> >> >
> >> >>
> >> >> Hi Jan,
> >> >>
> >> >> If there are enough BDIs and percpu counter of each bdi roughly
> >> >> equally
> >> >> used less than 1/2 of BDI's background dirty limit, still nothing will
> >> >> be flushed even if over global background_thresh.
> >> >   Yes, although then the percpu counter error would have to be quite
> >> > big.
> >> > Anyway, we can change the last condition to:
> >> >      if (global_page_state(NR_FILE_DIRTY) +
> >> >          global_page_state(NR_UNSTABLE_NFS) > background_thresh &&
> >> >          reclaimable * 2 + bdi_stat_error(bdi) * 2 >
> >> > bdi_bground_thresh)
> >> >
> >> >   That should be safe and for machines with resonable number of CPUs it
> >> > should save the wakeup as well.
> >> I agree and will send v2 patch as your suggestion.
> >
> > Hi Namjae,
> >
> > Why use bdi_stat_error here? What's the meaning of its comment "maximal
> > error of a stat counter"?
> Hi Simon,
> 
> As you know bdi stats (BDI_RECLAIMABLE, BDI_WRITEBACK a?|) are kept in
> percpu counters.
> When these percpu counters are incremented/decremented simultaneously
> on multiple CPUs by small amount (individual cpu counter less than
> threshold BDI_STAT_BATCH),
> it is possible that we get approximate value (not exact value) of
> these percpu counters.
> In order, to handle these percpu counter error we have used
> bdi_stat_error. bdi_stat_error is the maximum error which can happen
> in percpu bdi stats accounting.
> 
> bdi_stat(bdi, BDI_RECLAIMABLE);
>  -> This will give approximate value of BDI_RECLAIMABLE by reading
> previous value of percpu count.
> 
> bdi_stat_sum(bdi, BDI_RECLAIMABLE);
>  ->This will give exact value of BDI_RECLAIMABLE. It will take lock
> and add current percpu count of individual CPUs.
>    It is not recommended to use it frequently as it is expensive. We
> can better use a??bdi_stata?? and work with approx value of bdi stats.
> 

Hi Namjae, thanks for your clarify.

But why compare error stat count to bdi_bground_thresh? What's the
relationship between them? I also see bdi_stat_error compare to
bdi_thresh/bdi_dirty in function balance_dirty_pages. 


> Thanks.
> >
> >>
> >> Thanks Jan.
> >> >
> >> > 								Honza
> >> >
> >> >> >> Suggested-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >> >> >> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> >> >> >> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> >> >> >> Cc: Fengguang Wu <fengguang.wu@intel.com>
> >> >> >> Cc: Jan Kara <jack@suse.cz>
> >> >> >> Cc: Dave Chinner <dchinner@redhat.com>
> >> >> >> ---
> >> >> >>  fs/fs-writeback.c |    4 ----
> >> >> >>  1 file changed, 4 deletions(-)
> >> >> >>
> >> >> >> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> >> >> >> index 310972b..070b773 100644
> >> >> >> --- a/fs/fs-writeback.c
> >> >> >> +++ b/fs/fs-writeback.c
> >> >> >> @@ -756,10 +756,6 @@ static bool over_bground_thresh(struct
> >> >> >> backing_dev_info *bdi)
> >> >> >>
> >> >> >>  	global_dirty_limits(&background_thresh, &dirty_thresh);
> >> >> >>
> >> >> >> -	if (global_page_state(NR_FILE_DIRTY) +
> >> >> >> -	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
> >> >> >> -		return true;
> >> >> >> -
> >> >> >>  	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
> >> >> >>  				bdi_dirty_limit(bdi, background_thresh))
> >> >> >>  		return true;
> >> >> >> --
> >> >> >> 1.7.9.5
> >> >> >>
> >> >> >--
> >> >> >Jan Kara <jack@suse.cz>
> >> >> >SUSE Labs, CR
> >> >> >
> >> >> >--
> >> >> >To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> >> >the body to majordomo@kvack.org.  For more info on Linux MM,
> >> >> >see: http://www.linux-mm.org/ .
> >> >> >Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >> >>
> >> > --
> >> > Jan Kara <jack@suse.cz>
> >> > SUSE Labs, CR
> >> >
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> >
> >


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
