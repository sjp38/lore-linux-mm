Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E7C476B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:21:48 -0400 (EDT)
Received: by pdea3 with SMTP id a3so53709517pde.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:21:48 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id da1si2475277pad.9.2015.04.30.01.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:21:47 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NNM009LT1W6XX70@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 30 Apr 2015 09:21:43 +0100 (BST)
Message-id: <5541E60E.9040103@samsung.com>
Date: Thu, 30 Apr 2015 10:21:34 +0200
From: Beata Michalska <b.michalska@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC v2 1/4] fs: Add generic file system event notifications
References: <20150428135653.GD9955@quack.suse.cz>
 <20150428140936.GA13406@kroah.com> <553F9D56.6030301@samsung.com>
 <20150428173900.GA16708@kroah.com> <5540822C.10000@samsung.com>
 <20150429074259.GA31089@quack.suse.cz> <20150429091303.GA4090@kroah.com>
 <5540BC2A.8010504@samsung.com> <20150429134505.GB15398@kroah.com>
 <5540FD3E.9050801@samsung.com> <20150429155522.GA14723@kroah.com>
In-reply-to: <20150429155522.GA14723@kroah.com>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

Hi,

On 04/29/2015 05:55 PM, Greg KH wrote:
> On Wed, Apr 29, 2015 at 05:48:14PM +0200, Beata Michalska wrote:
>> On 04/29/2015 03:45 PM, Greg KH wrote:
>>> On Wed, Apr 29, 2015 at 01:10:34PM +0200, Beata Michalska wrote:
>>>>>>> It needs to be done internally by the app but is doable.
>>>>>>> The app knows what it is watching, so it can maintain the mappings.
>>>>>>> So prior to activating the notifications it can call 'stat' on the mount point.
>>>>>>> Stat struct gives the 'st_dev' which is the device id. Same will be reported
>>>>>>> within the message payload (through major:minor numbers). So having this,
>>>>>>> the app is able to get any other information it needs. 
>>>>>>> Note that the events refer to the file system as a whole and they may not
>>>>>>> necessarily have anything to do with the actual block device. 
>>>>>
>>>>> How are you going to show an event for a filesystem that is made up of
>>>>> multiple block devices?
>>>>
>>>> AFAIK, for such filesystems there will be similar case with the anonymous
>>>> major:minor numbers - at least the btrfs is doing so. Not sure we can
>>>> differentiate here the actual block device. So in this case such events
>>>> serves merely as a hint for the userspace.
>>>
>>> "hint" seems like this isn't really going to work well.
>>>
>>> Do you have userspace code that can properly map this back to the "real"
>>> device that is causing problems?  Without that, this doesn't seem all
>>> that useful as no one would be able to use those events.
>>
>> I'm not sure we are on the same page here.
>> This is about watching the file system rather than the 'real' device.
>> Like the threshold notifications: you would like to know when you
>> will be approaching certain level of available space for the tmpfs
>> mounted on /tmp.  You do know you are watching the /tmp
>> and you know that the dev numbers for this are 0:20 (or so). 
>> (either through calling stat on /tmp or through reading the /proc/$$/mountinfo)
>> With this interface you can setup threshold levels
>> for /tmp. Then, once the limit is reached the event will be
>> sent with those anonymous major:minor numbers.
>>
>> I can provide a sample code which will demonstrate how this
>> can be achieved.
> 
> Yes, example code would be helpful to understand this, thanks.
> 
> greg k-h
> 

Below is an absolutely *simplified* sample application. 
Hope this will be helpful.

---------------
#include <netlink/cli/utils.h>
#include <fs_event.h>
#include <string.h>
#include <regex.h>

#define ARRAY_SIZE(x) (sizeof(x)/sizeof((x)[0]))
#define LOG(args...) fprintf(stderr, args)

#define BUFF_SIZE 256

struct list_node {
	struct list_node *next;
	struct list_node *prev;
};

#define MBITS	20
#define MAKE_DEV(major, minor) \
	((major) << MBITS | ((minor) & ((1U << MBITS) -1)))

struct mount_data {
	struct list_node link;
	dev_t dev;
	char *dname;
};

static struct list_node mount_list = {&mount_list, &mount_list};

static void list_add(struct list_node *new_node, struct list_node *head)
{
	struct list_node *node;

	node = head->next;
	head->next = new_node;
	new_node->prev =  head;
	new_node->next = node;
	node->prev = new_node;
}

static struct mount_data *find_mount(struct list_node *mlist, dev_t dev)
{
	struct list_node *node;
	struct mount_data *mdata;

	for (node = mlist->prev; node != mlist; node = node->prev) {
		mdata = (char*)node - ((size_t) &((struct mount_data*)0)->link);
		if (mdata->dev == dev)
			return mdata;
	}
	return NULL;
}

static void create_mount_base(struct list_node *mlist)
{
	FILE *f;
	char entry[BUFF_SIZE];
	regex_t  re;

	if (!(f = fopen("/proc/self/mountinfo", "r")))
		return;

	if (regcomp(&re, "[0-9]*:[0-9]*", REG_EXTENDED))
		goto leave;

	while (fgets(entry, BUFF_SIZE, f)) {
		regmatch_t pmatch;
		int dev_major, dev_minor;
		char *s;

		if (regexec(&re, entry, 1, &pmatch, 0))
			continue;

		if (pmatch.rm_so == -1)
			continue;

		sscanf(entry + pmatch.rm_so, "%d:%d",
				&dev_major, &dev_minor);

		s = entry + pmatch.rm_eo;
		s = strtok(++s, " ");
		if (!s)
			continue;
		if (s = strtok(NULL, " ")) {
			struct mount_data *data = malloc(sizeof(*data));
			if (!data)
				continue;
			data->dev = MAKE_DEV(dev_major, dev_minor);
			data->dname = strdup(s);
			list_add(&data->link, mlist);
		}
	}
	regfree(&re);
leave:
	close(f);
	return;
}

static int parse_event(struct nl_cache_ops *unused, struct genl_cmd *cmd,
		struct genl_info *info, void *arg)
{
	struct mount_data *mdata;
	int dev_major, dev_minor;

	dev_major = info->attrs[FS_NL_A_DEV_MAJOR]
		  ? nla_get_u32(info->attrs[FS_NL_A_DEV_MAJOR])
		  : 0;

	dev_minor = info->attrs[FS_NL_A_DEV_MINOR]
		  ? nla_get_u32(info->attrs[FS_NL_A_DEV_MINOR])
		  : 0;

	mdata = find_mount(&mount_list, MAKE_DEV(dev_major, dev_minor));
	if (!mdata) {
		LOG("Unable to identify file system\n");
		return 0;
	}

	LOG("Notification received for %s \n", mdata->dname);
	LOG("Event ID: %d\n", nla_get_u32(info->attrs[FS_NL_A_EVENT_ID]));
	LOG("Owner: %d\n", nla_get_u32(info->attrs[FS_NL_A_CAUSED_ID]));
	LOG("Threshold data: %llu\n", info->attrs[FS_NL_A_DATA]
		? nla_get_u64(info->attrs[FS_NL_A_DATA])
		: 0);

	return 0;
}


static struct genl_cmd cmd[] = {
	{
		.c_id = 1 ,
		.c_name = "event",
		.c_maxattr = 5,
		.c_msg_parser = parse_event,
	},
};

static struct genl_ops ops = {
	.o_id = GENL_ID_FS_EVENT,
	.o_name = "FS_EVENT",
	.o_hdrsize = 0,
	.o_cmds = cmd,
	.o_ncmds = ARRAY_SIZE(cmd),
};


int events_cb(struct nl_msg *msg, void *arg)
{
	 return  genl_handle_msg(msg, arg);
}

int main(int argc, char **argv)
{
	struct nl_sock *sock;
	int ret;

	create_mount_base(&mount_list);

	sock = nl_cli_alloc_socket();
	nl_socket_set_local_port(sock, 0);
	nl_socket_disable_seq_check(sock);

	nl_socket_modify_cb(sock, NL_CB_VALID, NL_CB_CUSTOM, events_cb, NULL);

	nl_cli_connect(sock, NETLINK_GENERIC);

	if ((ret = nl_socket_add_membership(sock, GENL_ID_FS_EVENT))) {
		LOG("Failed to add membership\n");
		goto leave;
	}

	if((ret = genl_register_family(&ops))) {
		LOG("Failed to register protocol family\n");
		goto leave;
	}

	if ((ret = genl_ops_resolve(sock, &ops) < 0)) {
		LOG("Unable to resolve the family name\n");
		goto leave;
	}

	if (genl_ctrl_resolve(sock, "FS_EVENT") < 0) {
		LOG("Failed to resolve the family name\n");
		goto leave;
	}

	while (1) {
		if ((ret = nl_recvmsgs_default(sock)) < 0)
			LOG("Unable to receive message: %s\n",
				nl_geterror(ret));
	}

leave:
	nl_close(sock);
	nl_socket_free(sock);
	return 0;
}

----------------------------
The configuration setup for the app:
# echo /tmp T 50000 10000 > /sys/fs/events/config;
# echo /opt/usr G T 710000 500000 > /sys/fs/events/config;

(tmpfs and ext4 as the support for those is part of the patchset)

And the output after playing around with the 'dd':

Notification received for /tmp 
Event ID: 3 				/* FS_THR_LRBELOW */
Owner: 3128
Threshold data: 50000
Notification received for /opt/usr 
Event ID: 3				/* FS_THR_LRBELOW */
Owner: 3127
Threshold data: 710000
Notification received for /tmp 
Event ID: 5				/* FS_THR_URBELOW */
Owner: 3128
Threshold data: 10000
Notification received for /opt/usr 
Event ID: 5				/* FS_THR_URBELOW */
Owner: 3127
Threshold data: 500000
Notification received for /opt/usr 
Event ID: 1				/* FS_WARN_ENOSPC */
Owner: 3127
Threshold data: 0
Notification received for /opt/usr 
Event ID: 1				/* FS_WARN_ENOSPC */
Owner: 3127
Threshold data: 0
-------------------------

BR
Beata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
