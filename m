Date: Tue, 30 Oct 2007 18:16:35 -0400
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071030221635.GA643@dmt>
References: <20071030191827.GB31038@dmt> <47279A9D.70504@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47279A9D.70504@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, Gautham shenoy <ego@in.ibm.com>, roland@redhat.com
List-ID: <linux-mm.kvack.org>

Hi Balbir, 

Last message was lacking details and clarity, sorry.

And yes, the OOM acronym is confusing since it usually refers to OOM
killer.. mem_notify sounds way better.

On Wed, Oct 31, 2007 at 02:27:01AM +0530, Balbir Singh wrote:

> > +void oom_check_fn(unsigned long unused)
> > +{
> > +	bool wake = 0;
> > +	unsigned int swapped_pages;
> > +
> > +	swapped_pages = sum_vm_event(PSWPOUT);
> > +	if (swapped_pages > prev_swapped_pages)
> > +		wake = 1;
> > +	prev_swapped_pages = swapped_pages;
> > +
> 
> Two comments
> 
> 1. So this is a rate growth function and continues to wake
>    up tasks as long as the rate of swapout keeps growing?"

Correct.

> 2. How will this function work in the absence of swap? Does
>   this feature work in the absence of swap?

In the absence of swap PSWPOUT does not increase, therefore the function
won't wake-up tasks.

> > +	oom_notify_status = wake;
> > +
> > +	if (wake)
> > +		wake_up_all(&oom_wait);
> > +
> > +	return;
> > +}
> > +
> > +static int oom_notify_open(struct inode *inode, struct file *file)
> > +{
> 
> Should we check current->oomkilladj before allowing open to proceed?
> 
> > +	spin_lock(&oom_notify_lock);
> > +	if (!oom_notify_users) {
> > +		oom_notify_status = 0;
> > +		oom_check_timer.expires = jiffies + msecs_to_jiffies(1000);
> 
> A more meaningful name for 1000, here please?

Fixed.

> > +		mod_timer(&oom_check_timer, oom_check_timer.expires);
> > +	}
> > +	oom_notify_users++;
> > +	spin_unlock(&oom_notify_lock);
> > +
> > +	return 0;
> > +}
> > +
> > +static int oom_notify_release(struct inode *inode, struct file *file)
> > +{
> > +	spin_lock(&oom_notify_lock);
> > +	oom_notify_users--;
> > +	if (!oom_notify_users) {
> > +		del_timer(&oom_check_timer);
> > +		oom_notify_status = 0;
> > +	}
> > +	spin_unlock(&oom_notify_lock);
> > +	return 0;
> > +}
> > +
> > +static unsigned int oom_notify_poll(struct file *file, poll_table *wait)
> > +{
> > +	unsigned int val = 0;
> > +	struct zone *zone;
> > +	int cz_idx = zone_idx(NODE_DATA(nid)->node_zonelists->zones[0]);
> > +
> > +	poll_wait(file, &oom_wait, wait);
> > +
> > +	if (oom_notify_status)
> > +		val = POLLIN;
> > +
> > +	for_each_zone(zone) {
> > +		if (!populated_zone(zone))
> > +			continue;	
> > +		if (!zone_watermark_ok(zone, 0, zone->pages_low, cz_idx, 0)) {
> > +			val = POLLIN;
> > +			break;
> > +		}
> > +	}
> > +
> > +	return val;
> > +}
> > +
> > +struct file_operations oom_notify_fops = {
> > +	.open = oom_notify_open,
> > +	.release = oom_notify_release,
> > +	.poll = oom_notify_poll,
> > +};
> 
> Can we also implement a oom_notify_read() function, so that a read on
> /dev/oom_notify will give the reason for returning on select on
> /dev/oom_notify.

There are two different notifications:

1) normal memory shortage, allowing userspace to intelligently free
data.

2) critical memory shortage, allowing userspace to take an action before
the OOM killer kicks in.

1 is a fast path AND the large majority of applications only care
about it anyway... which means that I see little value on reporting
both events via the same descriptor.

However, that might be bullshit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
