Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 447436B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 04:17:34 -0400 (EDT)
Received: by wiax7 with SMTP id x7so28490439wia.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 01:17:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu19si17930627wjc.14.2015.04.17.01.17.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 01:17:32 -0700 (PDT)
Date: Fri, 17 Apr 2015 10:17:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 0/4] Generic file system events interface
Message-ID: <20150417081727.GB3116@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

  Hello,

On Wed 15-04-15 09:15:43, Beata Michalska wrote:
> The following patchset is a result of previous discussions regarding
> file system threshold notifiactions. It introduces support for file
> system event notifications, sent through generic netlinik interface
> whenever an fs-related event occurs. Included are also some shmem
> and ext4 changes showing how the new interface might actually be used.
> 
> The vary idea of using the generic netlink interface has been previoulsy
> suggested here:  https://lkml.org/lkml/2011/8/18/169
> 
> The basic description of the new functionality can be found in
> the first patch from this set - both in the commit message and
> in the doc file.
> 
> Some very basic tests have been performed though still this is
> a PoC version. Below though is a sample user space application
> which subscribes to the new multicast group and listens for
> potential fs-related events. The code has been based on libnl 3.4
> and its test application for the generic netlink.
  Thanks for the patches! As a general note for the next posting, please CC
also linux-fsdevel@vger.kernel.org (since this has implications for other
filesystems as well, specifically I know about XFS guys thinking about some
notification system as well) and linux-api@vger.kernel.org (since this is a
new kernel interface to userspace).

								Honza
> 
> ---
> 
> Beata Michalska (4):
>   fs: Add generic file system event notifications
>   ext4: Add helper function to mark group as corrupted
>   ext4: Add support for generic FS events
>   shmem: Add support for generic FS events
> 
>  Documentation/filesystems/events.txt |  254 +++++++++++
>  fs/Makefile                          |    1 +
>  fs/events/Makefile                   |    6 +
>  fs/events/fs_event.c                 |  775 ++++++++++++++++++++++++++++++++++
>  fs/events/fs_event.h                 |   27 ++
>  fs/events/fs_event_netlink.c         |   94 +++++
>  fs/ext4/balloc.c                     |   26 +-
>  fs/ext4/ext4.h                       |   10 +
>  fs/ext4/ialloc.c                     |    5 +-
>  fs/ext4/inode.c                      |    2 +-
>  fs/ext4/mballoc.c                    |   17 +-
>  fs/ext4/resize.c                     |    1 +
>  fs/ext4/super.c                      |   43 ++
>  fs/namespace.c                       |    1 +
>  include/linux/fs.h                   |    6 +-
>  include/linux/fs_event.h             |   69 +++
>  include/uapi/linux/fs_event.h        |   62 +++
>  include/uapi/linux/genetlink.h       |    1 +
>  mm/shmem.c                           |   39 +-
>  net/netlink/genetlink.c              |    7 +-
>  20 files changed, 1412 insertions(+), 34 deletions(-)
>  create mode 100644 Documentation/filesystems/events.txt
>  create mode 100644 fs/events/Makefile
>  create mode 100644 fs/events/fs_event.c
>  create mode 100644 fs/events/fs_event.h
>  create mode 100644 fs/events/fs_event_netlink.c
>  create mode 100644 include/linux/fs_event.h
>  create mode 100644 include/uapi/linux/fs_event.h
> 
> ---
> Sample application:
> 
> #include <netlink/cli/utils.h>
> #include <fs_event.h>
> 
> #define ARRAY_SIZE(x) (sizeof(x)/sizeof((x)[0]))
> #define LOG(args...) fprintf(stderr, args)
> 
> static int parse_info(struct nl_cache_ops *unused, struct genl_cmd *cmd,
> 		struct genl_info *info, void *arg)
> {
> 	LOG("New trace %d:\n",
> 		info->attrs[FS_EVENT_ATR_FS_ID]
> 		?  nla_get_u32(info->attrs[FS_EVENT_ATR_FS_ID])
> 		: -1);
> 	LOG("Mout point: %s\n", info->attrs[FS_EVENT_ATR_MOUNT]
> 		? nla_get_string(info->attrs[FS_EVENT_ATR_MOUNT])
> 		: "unknown");
> 	return 0;
> }
> 
> static int parse_thres(struct nl_cache_ops *unused, struct genl_cmd *cmd,
> 		struct genl_info *info, void *arg)
> {
> 
> 	LOG("Threshold notification received for trace %d:\n",
> 		info->attrs[FS_EVENT_ATR_FS_ID]
> 		?  nla_get_u32(info->attrs[FS_EVENT_ATR_FS_ID])
> 		: -1);
> 
> 	if (info->attrs[FS_EVENT_ATR_DEV_MAJOR])
> 		LOG("Backing dev major: %u\n",
> 			nla_get_u32(info->attrs[FS_EVENT_ATR_DEV_MAJOR]));
> 	if (info->attrs[FS_EVENT_ATR_DEV_MINOR])
> 		LOG("Backing dev minor: %u\n",
> 			nla_get_u32(info->attrs[FS_EVENT_ATR_DEV_MINOR]));
> 	LOG("Proc:              %u\n", info->attrs[FS_EVENT_ATR_CAUSED_ID] ?
> 			nla_get_u32(info->attrs[FS_EVENT_ATR_CAUSED_ID]) : -1);
> 	LOG("Threshold data:    %llu\n", info->attrs[FS_EVENT_ATR_DATA]
> 		? nla_get_u64(info->attrs[FS_EVENT_ATR_DATA])
> 		: 0);
> 
> 	return 0;
> }
> 
> static int parse_warning(struct nl_cache_ops *unused, struct genl_cmd *cmd,
> 			 struct genl_info *info, void *arg)
> {
> 
> 	LOG("Warning recieved for trace %d\n", info->attrs[FS_EVENT_ATR_FS_ID] ?
> 		nla_get_u32(info->attrs[FS_EVENT_ATR_FS_ID]) : -1);
> 	if (info->attrs[FS_EVENT_ATR_DEV_MAJOR])
> 		LOG("Backing dev major: %u\n",
> 			nla_get_u32(info->attrs[FS_EVENT_ATR_DEV_MAJOR]));
> 	if (info->attrs[FS_EVENT_ATR_DEV_MINOR])
> 		LOG("Backing dev minor: %u\n",
> 			nla_get_u32(info->attrs[FS_EVENT_ATR_DEV_MINOR]));
> 	LOG("Proc:              %u\n", info->attrs[FS_EVENT_ATR_CAUSED_ID] ?
> 		nla_get_u32(info->attrs[FS_EVENT_ATR_CAUSED_ID]) : -1);
> 	LOG("Warning:           %u\n", info->attrs[FS_EVENT_ATR_ID] ?
> 		nla_get_u32(info->attrs[FS_EVENT_ATR_ID]) : -1);
> 
> 	return 0;
> }
> 
> static struct genl_cmd cmd[] = {
> 	{
> 		.c_id = FS_EVENT_TYPE_NEW_TRACE,
> 		.c_name = "info",
> 		.c_maxattr = 2,
> 		.c_msg_parser = parse_info,
> 	}, {
> 		.c_id = FS_EVENT_TYPE_THRESH,
> 		.c_name = "thres",
> 		.c_maxattr = 6,
> 		.c_msg_parser = parse_thres,
> 	}, {
> 		.c_id = FS_EVENT_TYPE_WARN,
> 		.c_name = "warn",
> 		.c_maxattr = 5,
> 		.c_msg_parser = parse_warning,
> 	},
> };
> 
> static struct genl_ops ops = {
> 	.o_id = GENL_ID_FS_EVENT,
> 	.o_name = "FS_EVENT",
> 	.o_hdrsize = 0,
> 	.o_cmds = cmd,
> 	.o_ncmds = ARRAY_SIZE(cmd),
> };
> 
> 
> int events_cb(struct nl_msg *msg, void *arg)
> {
> 	 return  genl_handle_msg(msg, arg);
> }
> 
> int main(int argc, char **argv)
> {
> 	struct nl_sock *sock;
> 	int ret;
> 
> 	sock = nl_cli_alloc_socket();
> 	nl_socket_set_local_port(sock, 0);
> 	nl_socket_disable_seq_check(sock);
> 
> 	nl_socket_modify_cb(sock, NL_CB_VALID, NL_CB_CUSTOM, events_cb, NULL);
> 
> 	nl_cli_connect(sock, NETLINK_GENERIC);
> 
> 	if ((ret = nl_socket_add_membership(sock, GENL_ID_FS_EVENT))) {
> 		LOG("Failed to add membership\n");
> 		goto leave;
> 	}
> 
> 	if((ret = genl_register_family(&ops))) {
> 		LOG("Failed to register protocol family\n");
> 		goto leave;
> 	}
> 
> 	if ((ret = genl_ops_resolve(sock, &ops) < 0)) {
> 		LOG("Unable to resolve the family name\n");
> 		goto leave;
> 	}
> 
> 	if (genl_ctrl_resolve(sock, "FS_EVENT") < 0) {
> 		LOG("Failed to resolve  the family name\n");
> 		goto leave;
> 	}
> 
> 	while (1) {
> 		if ((ret = nl_recvmsgs_default(sock)) < 0)
> 			LOG("Unable to receive message: %s\n", nl_geterror(ret));
> 	}
> 
> leave:
> 	nl_close(sock);
> 	nl_socket_free(sock);
> 	return 0;
> }
> 
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
