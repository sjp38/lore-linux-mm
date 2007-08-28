Date: Mon, 27 Aug 2007 17:01:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC]  Add node 'states' sysfs class attribute - V2
Message-Id: <20070827170159.0a79529d.akpm@linux-foundation.org>
In-Reply-To: <1188248528.5952.95.camel@localhost>
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	<1188248528.5952.95.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, clameter@sgi.com, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007 17:02:08 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Here's a cleaned up version that addresses Christoph's comments.
> 
> Lee
> ===============
> PATCH Add node 'states' sysfs class attribute v2
> 
> Against:  2.6.23-rc3-mm1
> 
> V1 -> V2:
> + style cleanup
> + drop 'len' variable in print_node_states();  compute from
>   final size.
> + use nodelist_scnprintf() for state masks.
> 
> Add a sysfs class attribute file to /sys/devices/system/node
> to display node state masks.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

So I spent half a minute or so working out "wtf does this do" then decided
that it isn't efficient for everyone who reads this patch to have to do the
same thing.

Perhaps including sample output would help to explain wtf this does. 
afaict it will spit out a bitmap like:

possible: 11110000
on-line: 11010000
normal memory: 01110000
etc

or something like that, dunno.  Please document this interface for us?

> Index: Linux/drivers/base/node.c
> ===================================================================
> --- Linux.orig/drivers/base/node.c	2007-08-27 12:31:32.000000000 -0400
> +++ Linux/drivers/base/node.c	2007-08-27 16:30:18.000000000 -0400
> @@ -12,6 +12,7 @@
>  #include <linux/topology.h>
>  #include <linux/nodemask.h>
>  #include <linux/cpu.h>
> +#include <linux/device.h>
>  
>  static struct sysdev_class node_class = {
>  	set_kset_name("node"),
> @@ -232,8 +233,76 @@ void unregister_one_node(int nid)
>  	unregister_node(&node_devices[nid]);
>  }
>  
> +/*
> + * [node] states attribute
> + */
> +static char * node_state_names[] = {

s/* /*/

> +	"possible:",
> +	"on-line:",

It would be more typical to use "online" here.

> +	"normal memory:",
> +#ifdef CONFIG_HIGHMEM
> +	"high memory:",

Do we really want a space in here?  It makes parsing somewhat
harder.  Do the other files in /sys/devices/system/node take care to avoid
doing this?

And what happened to the one-value-per-sysfs file rule?  Did we already
break it so much in /sys/devices/system/node that we've just given up?

> +#endif
> +	"cpu:",
> +};
> +
> +static ssize_t
> +print_node_states(struct class *class, char *buf)

static ssize_t print_node_states(struct class *class, char *buf)

fits in 80-cols, hece is preferred here.

> +{
> +	int i;
> +	int n;
> +	ssize_t  size = PAGE_SIZE;
> +
> +	for (i = 0; i < NR_NODE_STATES; i++) {
> +		n = snprintf(buf, size, "%14s  ", node_state_names[i]);
> +		if (n <= 0)
> +			break;
> +		buf += n;
> +		size -= n;
> +		if (size <= 0)
> +			break;
> +
> +		n = nodelist_scnprintf(buf, size, node_states[i]);
> +		if (n <= 0)
> +			break;
> +		buf += n;
> +		size -=n;
> +		if (size <= 0)
> +			break;
> +
> +		n = snprintf(buf, size, "\n");
> +		if (n <= 0)
> +			break;
> +		buf += n;
> +		size -= n;
> +		if (size <= 0)
> +			break;
> +	}
> +
> +	if (n > 0) {
> +		n = PAGE_SIZE;
> +		if (size > 0)
> +			n -= size;
> +	}
> +	return n;
> +}

Can't use seq_file interface here?

The fiddling with PAGE_SIZE is unfortunate.

> +static CLASS_ATTR(states, 0444, print_node_states, NULL);
> +
> +static int node_states_init(void)
> +{
> +	return sysfs_create_file(&node_class.kset.kobj,
> +				&class_attr_states.attr);
> +}
> +
>  static int __init register_node_type(void)
>  {
> -	return sysdev_class_register(&node_class);
> +	int ret;
> +
> +	ret = sysdev_class_register(&node_class);
> +	if (!ret)
> +		ret = node_states_init();
> +
> +	return ret;
>  }
>  postcore_initcall(register_node_type);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
