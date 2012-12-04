Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C5B566B0072
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 15:35:43 -0500 (EST)
Date: Wed, 5 Dec 2012 07:35:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch,v2] bdi: add a user-tunable cpu_list for the bdi flusher
 threads
Message-ID: <20121204203539.GA16353@dastard>
References: <x49lidfnf0s.fsf@segfault.boston.devel.redhat.com>
 <20121204023405.GE32450@dastard>
 <x49liddq3o0.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49liddq3o0.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zach Brown <zab@redhat.com>

On Tue, Dec 04, 2012 at 09:42:55AM -0500, Jeff Moyer wrote:
> Dave Chinner <david@fromorbit.com> writes:
> 
> > On Mon, Dec 03, 2012 at 01:53:39PM -0500, Jeff Moyer wrote:
> >> +static ssize_t cpu_list_store(struct device *dev,
> >> +		struct device_attribute *attr, const char *buf, size_t count)
> >> +{
> >> +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> >> +	struct bdi_writeback *wb = &bdi->wb;
> >> +	cpumask_var_t newmask;
> >> +	ssize_t ret;
> >> +	struct task_struct *task;
> >> +
> >> +	if (!alloc_cpumask_var(&newmask, GFP_KERNEL))
> >> +		return -ENOMEM;
> >> +
> >> +	ret = cpulist_parse(buf, newmask);
> >> +	if (!ret) {
> >> +		spin_lock(&bdi->wb_lock);
> >> +		task = wb->task;
> >> +		if (task)
> >> +			get_task_struct(task);
> >> +		spin_unlock(&bdi->wb_lock);
> >> +		if (task) {
> >> +			ret = set_cpus_allowed_ptr(task, newmask);
> >> +			put_task_struct(task);
> >> +		}
> >
> > Why is this set here outside the bdi->flusher_cpumask_mutex?
> 
> The cpumask mutex protects updates to bdi->flusher_cpumask, it has
> nothing to do with the call to set_cpus_allowed.  We are protected from
> concurrent calls to cpu_list_store by the sysfs mutex that is taken on
> entry.  I understand that this is non-obvious, and it wouldn't be wrong
> to hold the mutex here.  If you'd like me to do that for clarity, that
> would be ok with me.

At minimum it needs a comment like this otherwise someone is going
to come along and ask "why is that safe?" like I just did. I'd
prefer the code to be obviously consistent to avoid the need for
commenting about the special case, especially when the obviously
correct code is simpler ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
