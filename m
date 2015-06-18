Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9986C6B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 10:50:19 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so9738889pdb.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 07:50:19 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ji4si11627701pbd.56.2015.06.18.07.50.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 18 Jun 2015 07:50:18 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NQ500M4CAJPZN50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 18 Jun 2015 15:50:13 +0100 (BST)
Message-id: <5582DAA3.8080204@samsung.com>
Date: Thu, 18 Jun 2015 16:50:11 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
 <5582A8C1.3000002@gmail.com>
In-reply-to: <5582A8C1.3000002@gmail.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Hi,

On 06/18/2015 01:17 PM, Kinglong Mee wrote:
> On 6/16/2015 9:09 PM, Beata Michalska wrote:
>> Introduce configurable generic interface for file
>> system-wide event notifications, to provide file
>> systems with a common way of reporting any potential
>> issues as they emerge.
> ... snip ...
>> +
>> +Sample request could look like the following:
>> +
>> + echo /sample/mount/point G T 710000 500000 > /sys/fs/events/config
>> +
>> +Multiple request might be specified provided they are separated with semicolon.
>> +
>> +The configuration itself might be modified at any time. One can add/remove
>> +particular event types for given fielsystem, modify the threshold levels,
>> +and remove single or all entries from the 'config' file.
>> +
>> + - Adding new event type:
>> +
>> + $ echo MOUNT EVENT_TYPE > /sys/fs/events/config
>> +
>> +(Note that is is enough to provide the event type to be enabled without
> 
> Should be "Note that it is ... " here ?

Right
> 
>> +the already set ones.)
>> +
>> + - Removing event type:
>> +
>> + $ echo '!MOUNT EVENT_TYPE' > /sys/fs/events/config
>> +
>> + - Updating threshold limits:
>> +
>> + $ echo MOUNT T L1 L2 > /sys/fs/events/config
>> +
>> + - Removing single entry:
>> +
>> + $ echo '!MOUNT' > /sys/fs/events/config
>> +
>> + - Removing all entries:
>> +
>> + $ echo > /sys/fs/events/config
>> +
>> +Reading the file will list all registered entries with their current set-up
>> +along with some additional info like the filesystem type and the backing device
>> +name if available.
>> +
>> +Final, though a very important note on the configuration: when and if the
>> +actual events are being triggered falls way beyond the scope of the generic
>> +filesystem events interface. It is up to a particular filesystem
>> +implementation which events are to be supported - if any at all. So if
>> +given filesystem does not support the event notifications, an attempt to
>> +enable those through 'config' file will fail.
>> +
>> +
>> +3. The generic netlink interface support:
>> +=========================================
>> +
>> +Whenever an event notification is triggered (by given filesystem) the current
>> +configuration is being validated to decide whether a userpsace notification
>> +should be launched. If there has been no request (in a mean of 'config' file
>> +entry) for given event, one will be silently disregarded. If, on the other
>> +hand, someone is 'watching' given filesystem for specific events, a generic
>> +netlink message will be sent. A dedicated multicast group has been provided
>> +solely for this purpose so in order to receive such notifications, one should
>> +subscribe to this new multicast group. As for now only the init network
>> +namespace is being supported.
>> +
>> +3.1 Message format
>> +
>> +The FS_NL_C_EVENT shall be stored within the generic netlink message header
>> +as the command field. The message payload will provide more detailed info:
>> +the backing device major and minor numbers, the event code and the id of
>> +the process which action led to the event occurrence. In case of threshold
>> +notifications, the current number of available blocks will be included
>> +in the payload as well.
>> +
>> +
>> +	 0                   1                   2                   3
>> +	 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>> +	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> +	|	            NETLINK MESSAGE HEADER			|
>> +	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> +	| 		GENERIC NETLINK MESSAGE HEADER   		|
>> +	| 	   (with FS_NL_C_EVENT as genlmsghdr cdm field)		|
> 
> cmd, not cdm.

ditto
> 
>> +	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> +	| 	      Optional user specific message header		|
>> +	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> +	|		   GENERIC MESSAGE PAYLOAD:			|
>> +	+---------------------------------------------------------------+
>> +	| 		  FS_NL_A_EVENT_ID  (NLA_U32)			|
>> +	+---------------------------------------------------------------+
>> +	|	  	  FS_NL_A_DEV_MAJOR (NLA_U32)			|
>> +	+---------------------------------------------------------------+
>> +	| 	  	  FS_NL_A_DEV_MINOR (NLA_U32) 			|
>> +	+---------------------------------------------------------------+
>> +	|  		  FS_NL_A_CAUSED_ID (NLA_U32)			|
> 
> Should be NLA_U64 ? The following uses as, 
> 
> +	if (nla_put_u64(skb, FS_NL_A_CAUSED_ID, pid_vnr(task_pid(current))))
> +		return -EINVAL;
> 

Yes, or nla_put_u32 - either way my bad

> Also, I'd like FS_NL_A_CAUSED_PID than FS_NL_A_CAUSED_ID.

Alright
> 
>> +	+---------------------------------------------------------------+
>> +	|  		    FS_NL_A_DATA (NLA_U64)			|
>> +	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>> +
>> +
>> +The above figure is based on:
>> + http://www.linuxfoundation.org/collaborate/workgroups/networking/generic_netlink_howto#Message_Format
>> +
>> +
> ... snip... 
>> +	seq_putc(m, ' ');
>> +	if (sb->s_op->show_devname) {
>> +		sb->s_op->show_devname(m, en->mnt_path.mnt->mnt_root);
>> +	} else {
>> +		seq_escape(m, r_mnt->mnt_devname ? r_mnt->mnt_devname : "none",
>> +				" \t\n\\");
>> +	}
>> +	seq_puts(m, " (");
>> +
>> +	nmask = en->notify;
>> +	for (match = fs_etypes; match->pattern; ++match) {
>> +		if (match->token & nmask) {
>> +			seq_puts(m, match->pattern);
> 
> Print here is better.
> 
> if (match->pattern & FS_EVENT_THRESH)
> 	seq_printf(m, " %llu %llu", en->th.lrange, en->th.urange);
> 
>> +			nmask &= ~match->token;
>> +			if (nmask)
>> +				seq_putc(m, ',');
>> +		}
>> +	}
>> +	seq_printf(m, " %llu %llu", en->th.lrange, en->th.urange);
> 
> Don't print the lrange/urange (always be zero) when without FS_EVENT_THRESH.
> 

ditto

>> +	seq_puts(m, ")\n");
>> +	return 0;
>> +}
>> +
>> +static const struct seq_operations fs_trace_seq_ops = {
>> +	.start	= fs_trace_seq_start,
>> +	.next	= fs_trace_seq_next,
>> +	.stop	= fs_trace_seq_stop,
>> +	.show	= fs_trace_seq_show,
>> +};
>> +
>> +static int fs_trace_open(struct inode *inode, struct file *file)
>> +{
>> +	return seq_open(file, &fs_trace_seq_ops);
>> +}
>> +
>> +static const struct file_operations fs_trace_fops = {
>> +	.owner		= THIS_MODULE,
>> +	.open		= fs_trace_open,
>> +	.write		= fs_trace_write,
>> +	.read		= seq_read,
>> +	.llseek		= seq_lseek,
>> +	.release	= seq_release,
>> +};
>> +
>> +static int fs_trace_init(void)
>> +{
>> +	fs_trace_cachep = KMEM_CACHE(fs_trace_entry, 0);
>> +	if (!fs_trace_cachep)
>> +		return -EINVAL;
>> +	init_waitqueue_head(&trace_wq);
>> +	return 0;
>> +}
>> +
>> +/* VFS support */
>> +static int fs_trace_fill_super(struct super_block *sb, void *data, int silen)
>> +{
>> +	int ret;
>> +	static struct tree_descr desc[] = {
>> +		[2] = {
>> +			.name	= "config",
>> +			.ops	= &fs_trace_fops,
>> +			.mode	= S_IWUSR | S_IRUGO,
>> +		},
>> +		{""},
>> +	};
>> +
>> +	ret = simple_fill_super(sb, 0x7246332, desc);
>> +	return !ret ? fs_trace_init() : ret;
>> +}
>> +
>> +static struct dentry *fs_trace_do_mount(struct file_system_type *fs_type,
>> +		 int ntype, const char *dev_name, void *data)
>> +{
>> +	return mount_single(fs_type, ntype, data, fs_trace_fill_super);
>> +}
>> +
>> +static void fs_trace_kill_super(struct super_block *sb)
>> +{
>> +	/*
>> +	 * The rcu_barrier here will/should make sure all call_rcu
>> +	 * callbacks are completed - still there might be some active
>> +	 * trace objects in use which can make calling the
>> +	 * kmem_cache_destroy unsafe. So we wait until all traces
>> +	 * are finally released.
>> +	 */
>> +	fs_remove_all_traces();
>> +	rcu_barrier();
>> +	wait_event(trace_wq, !atomic_read(&stray_traces));
>> +
>> +	kmem_cache_destroy(fs_trace_cachep);
>> +	kill_litter_super(sb);
>> +}
>> +
>> +static struct kset	*fs_trace_kset;
>> +
>> +static struct file_system_type fs_trace_fstype = {
>> +	.name		= "fstrace",
>> +	.mount		= fs_trace_do_mount,
>> +	.kill_sb	= fs_trace_kill_super,
>> +};
>> +
>> +static void __init fs_trace_vfs_init(void)
>> +{
>> +	fs_trace_kset = kset_create_and_add("events", NULL, fs_kobj);
>> +
>> +	if (!fs_trace_kset)
>> +		return;
>> +
>> +	if (!register_filesystem(&fs_trace_fstype)) {
>> +		if (!fs_event_netlink_register())
>> +			return;
>> +		unregister_filesystem(&fs_trace_fstype);
>> +	}
>> +	kset_unregister(fs_trace_kset);
>> +}
>> +
>> +static int __init fs_trace_evens_init(void)
>> +{
>> +	fs_trace_vfs_init();
>> +	return 0;
>> +};
>> +module_init(fs_trace_evens_init);
>> +
>> diff --git a/fs/events/fs_event.h b/fs/events/fs_event.h
>> new file mode 100644
>> index 0000000..23f24c8
>> --- /dev/null
>> +++ b/fs/events/fs_event.h
>> @@ -0,0 +1,22 @@
>> +/*
>> + * Copyright(c) 2015 Samsung Electronics. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms of the GNU General Public License version 2.
>> + *
>> + * The full GNU General Public License is included in this distribution in the
>> + * file called COPYING.
>> + *
>> + * This program is distributed in the hope that it will be useful, but WITHOUT
>> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>> + * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
>> + * more details.
>> + */
>> +
>> +#ifndef __GENERIC_FS_EVENTS_H
>> +#define __GENERIC_FS_EVENTS_H
>> +
>> +int  fs_event_netlink_register(void);
>> +void fs_event_netlink_unregister(void);
>> +
>> +#endif /* __GENERIC_FS_EVENTS_H */
>> diff --git a/fs/events/fs_event_netlink.c b/fs/events/fs_event_netlink.c
>> new file mode 100644
>> index 0000000..0c97eb7
>> --- /dev/null
>> +++ b/fs/events/fs_event_netlink.c
>> @@ -0,0 +1,104 @@
>> +/*
>> + * Copyright(c) 2015 Samsung Electronics. All rights reserved.
>> + *
>> + * This program is free software; you can redistribute it and/or modify it
>> + * under the terms of the GNU General Public License version 2.
>> + *
>> + * The full GNU General Public License is included in this distribution in the
>> + * file called COPYING.
>> + *
>> + * This program is distributed in the hope that it will be useful, but WITHOUT
>> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>> + * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
>> + * more details.
>> + */
>> +#include <linux/fs.h>
>> +#include <linux/init.h>
>> +#include <linux/kernel.h>
>> +#include <linux/sched.h>
>> +#include <linux/slab.h>
>> +#include <net/netlink.h>
>> +#include <net/genetlink.h>
>> +#include "fs_event.h"
>> +
>> +static const struct genl_multicast_group fs_event_mcgroups[] = {
>> +	{ .name = FS_EVENTS_MCAST_GRP_NAME, },
>> +};
>> +
>> +static struct genl_family fs_event_family = {
>> +	.id		= GENL_ID_GENERATE,
>> +	.name		= FS_EVENTS_FAMILY_NAME,
>> +	.version	= 1,
>> +	.maxattr	= FS_NL_A_MAX,
>> +	.mcgrps		= fs_event_mcgroups,
>> +	.n_mcgrps	= ARRAY_SIZE(fs_event_mcgroups),
>> +};
>> +
>> +int fs_netlink_send_event(size_t size, unsigned int event_id,
>> +			  int (*compose_msg)(struct sk_buff *skb,  void *data),
>> +			  void *cbdata)
>> +{
>> +	static atomic_t seq;
>> +	struct sk_buff *skb;
>> +	void *msg_head;
>> +	int ret = 0;
>> +
>> +	if (!size || !compose_msg)
>> +		return -EINVAL;
>> +
>> +	/* Skip if there are no listeners */
>> +	if (!genl_has_listeners(&fs_event_family, &init_net, 0))
>> +		return 0;
>> +
>> +	if (event_id != FS_EVENT_NONE)
>> +		size += nla_total_size(sizeof(u32));
>> +	size += nla_total_size(sizeof(u64));
> 
> What is this for ?
> 
This should actually get removed :)

> thanks
> Kinglong Mee
> 

Thank You,

Best Regards
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
