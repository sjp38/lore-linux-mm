Date: Mon, 20 Aug 2007 12:20:54 +0400
From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: Re: [Devel] [-mm PATCH 1/9] Memory controller resource counters (v6)
Message-ID: <20070820082054.GA6926@localhost.sw.ru>
References: <20070817084228.26003.12568.sendpatchset@balbir-laptop> <20070817084238.26003.7733.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070817084238.26003.7733.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 17, 2007 at 02:12:38PM +0530, Balbir Singh wrote:
> --- /dev/null
> +++ linux-2.6.23-rc2-mm2-balbir/kernel/res_counter.c
> +void res_counter_init(struct res_counter *counter)
> +{
> +	spin_lock_init(&counter->lock);
> +	counter->limit = (unsigned long)LONG_MAX;

why cast?

> +int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> +{
> +	if (counter->usage > (counter->limit - val)) {

() aren't needed.

> +		counter->failcnt++;
> +		return -ENOMEM;
> +	}
> +
> +	counter->usage += val;
> +	return 0;
> +}
> +
> +int res_counter_charge(struct res_counter *counter, unsigned long val)
> +{
> +	int ret;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&counter->lock, flags);
> +	ret = res_counter_charge_locked(counter, val);
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +	return ret;
> +}
> +
> +void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> +{
> +	if (WARN_ON(counter->usage < val))
> +		val = counter->usage;

explicit if and WARN_ON(1) is clearer. I should send a patch banning such
type of usage soon.

> +
> +	counter->usage -= val;
> +}
> +
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&counter->lock, flags);
> +	res_counter_uncharge_locked(counter, val);
> +	spin_unlock_irqrestore(&counter->lock, flags);
> +}

> +ssize_t res_counter_write(struct res_counter *counter, int member,
> +		const char __user *userbuf, size_t nbytes, loff_t *pos)
> +{
> +	int ret;
> +	char *buf, *end;
> +	unsigned long tmp, *val;
> +
> +	buf = kmalloc(nbytes + 1, GFP_KERNEL);

please, switch to fixed buffer, allocating memory depending on size
told by userspace will beat later. Ditto for other proc writing
functions.

> +	ret = -ENOMEM;
> +	if (buf == NULL)
> +		goto out;
> +
> +	buf[nbytes] = '\0';
> +	ret = -EFAULT;
> +	if (copy_from_user(buf, userbuf, nbytes))
> +		goto out_free;
> +
> +	ret = -EINVAL;
> +	tmp = simple_strtoul(buf, &end, 10);
> +	if (*end != '\0')
> +		goto out_free;
> +
> +	val = res_counter_member(counter, member);
> +	*val = tmp;
> +	ret = nbytes;
> +out_free:
> +	kfree(buf);
> +out:
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
