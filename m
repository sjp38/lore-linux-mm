Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 159096B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 22:26:46 -0500 (EST)
Date: Sat, 5 Jan 2013 11:26:42 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
Message-ID: <20130105032642.GA8188@localhost>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
 <20121231113054.GC7564@quack.suse.cz>
 <20130102134334.GB30633@quack.suse.cz>
 <CAKYAXd8-sZo0XcdHuyOQ1qT_s3kJXyphXsjSS7e1-sJ1QaAOgg@mail.gmail.com>
 <1357261151.5105.2.camel@kernel.cn.ibm.com>
 <CAKYAXd-kcnxm6Do9VcbdyrCBvArrjz1iHOpxXHnyUyNcqP7Ofg@mail.gmail.com>
 <1357346803.5273.10.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1357346803.5273.10.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Dave Chinner <dchinner@redhat.com>

> > > Hi Namjae,
> > >
> > > Why use bdi_stat_error here? What's the meaning of its comment "maximal
> > > error of a stat counter"?
> > Hi Simon,
> > 
> > As you know bdi stats (BDI_RECLAIMABLE, BDI_WRITEBACK a?|) are kept in
> > percpu counters.
> > When these percpu counters are incremented/decremented simultaneously
> > on multiple CPUs by small amount (individual cpu counter less than
> > threshold BDI_STAT_BATCH),
> > it is possible that we get approximate value (not exact value) of
> > these percpu counters.
> > In order, to handle these percpu counter error we have used
> > bdi_stat_error. bdi_stat_error is the maximum error which can happen
> > in percpu bdi stats accounting.
> > 
> > bdi_stat(bdi, BDI_RECLAIMABLE);
> >  -> This will give approximate value of BDI_RECLAIMABLE by reading
> > previous value of percpu count.
> > 
> > bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> >  ->This will give exact value of BDI_RECLAIMABLE. It will take lock
> > and add current percpu count of individual CPUs.
> >    It is not recommended to use it frequently as it is expensive. We
> > can better use a??bdi_stata?? and work with approx value of bdi stats.
> > 
> 
> Hi Namjae, thanks for your clarify.
> 
> But why compare error stat count to bdi_bground_thresh? What's the

It's not comparing bdi_stat_error to bdi_bground_thresh, but rather,
in concept, comparing bdi_stat (with error bound adjustments) to
bdi_bground_thresh.

> relationship between them? I also see bdi_stat_error compare to
> bdi_thresh/bdi_dirty in function balance_dirty_pages. 

Here, it's trying to use bdi_stat_sum(), the accurate (however more
costly) version of bdi_stat(), if the error would possibly be large:

                if (bdi_thresh < 2 * bdi_stat_error(bdi)) {
                        bdi_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
                        //...
                } else {
                        bdi_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
                        //...
                }

Here the comment should have explained it well:

                 * In theory 1 page is enough to keep the comsumer-producer
                 * pipe going: the flusher cleans 1 page => the task dirties 1
                 * more page. However bdi_dirty has accounting errors.  So use
                 * the larger and more IO friendly bdi_stat_error.
                 */
                if (bdi_dirty <= bdi_stat_error(bdi))
                        break;


Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
