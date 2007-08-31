Date: Fri, 31 Aug 2007 13:02:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH]  Memory controller improve user interface (v2)
Message-Id: <20070831130216.226db806.akpm@linux-foundation.org>
In-Reply-To: <20070830185246.3170.74806.sendpatchset@balbir-laptop>
References: <20070830185246.3170.74806.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 31 Aug 2007 00:22:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +/*
> + * Strategy routines for formating read/write data
> + */
> +int mem_container_read_strategy(unsigned long long val, char *buf)
> +{
> +	return sprintf(buf, "%llu Bytes\n", val);
> +}

It's a bit cheesy to be printing the units like this.  It's better to just
print the raw number.

If you really want to remind the user what units that number is in (not a
bad idea) then it can be encoded in the filename, like
/proc/sys/vm/min_free_kbytes, /proc/sys/vm/dirty_expire_centisecs, etc.


> +int mem_container_write_strategy(char *buf, unsigned long long *tmp)
> +{
> +	*tmp = memparse(buf, &buf);
> +	if (*buf != '\0')
> +		return -EINVAL;
> +
> +	printk("tmp is %llu\n", *tmp);

don't think we want that.

> +	/*
> +	 * Round up the value to the closest page size
> +	 */
> +	*tmp = ((*tmp + PAGE_SIZE - 1) >> PAGE_SHIFT) << PAGE_SHIFT;
> +	return 0;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
