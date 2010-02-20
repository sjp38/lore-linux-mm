Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DAFD96B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 23:28:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1K4SN1n020814
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 20 Feb 2010 13:28:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4573B45DE50
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:28:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B0C645DE4E
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:28:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ECA3C1DB8038
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:28:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A06281DB8037
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 13:28:22 +0900 (JST)
Date: Sat, 20 Feb 2010 13:24:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/4] cgroups: Add simple listener of cgroup
 events to documentation
Message-Id: <20100220132450.c9f63f06.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
	<a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
	<6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Feb 2010 00:28:18 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>


Nice. but please add one-line patch description, at least.
(Because it helps we see merge log rather than patch dump.)

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  Documentation/cgroups/cgroup_event_listener.c |  102 +++++++++++++++++++++++++
>  1 files changed, 102 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/cgroups/cgroup_event_listener.c
> 
> diff --git a/Documentation/cgroups/cgroup_event_listener.c b/Documentation/cgroups/cgroup_event_listener.c
> new file mode 100644
> index 0000000..a8277b2
> --- /dev/null
> +++ b/Documentation/cgroups/cgroup_event_listener.c
> @@ -0,0 +1,102 @@
> +/*
> + * cgroup_event_listener.c - Simple listener of cgroup events
> + *
> + * Copyright (C) Kirill A. Shutemov <kirill@shutemov.name>
> + */
> +
> +#include <assert.h>
> +#include <errno.h>
> +#include <fcntl.h>
> +#include <libgen.h>
> +#include <limits.h>
> +#include <stdio.h>
> +#include <string.h>
> +#include <unistd.h>
> +
> +#include <sys/eventfd.h>
> +
> +#define USAGE_STR "Usage: cgroup_event_listener <path-to-control-file> <args>\n"
> +
> +int main(int argc, char **argv)
> +{
> +	int efd = -1;
> +	int cfd = -1;
> +	int event_control = -1;
> +	char event_control_path[PATH_MAX];
> +	int ret;
> +
> +	if (argc != 3) {
> +		fputs(USAGE_STR, stderr);
> +		return 1;
> +	}
> +
> +	cfd = open(argv[1], O_RDONLY);
> +	if (cfd == -1) {
> +		fprintf(stderr, "Cannot open %s: %s\n", argv[1],
> +				strerror(errno));
> +		goto out;
> +	}
> +
> +	ret = snprintf(event_control_path, PATH_MAX, "%s/cgroup.event_control",
> +			dirname(argv[1]));
> +	if (ret > PATH_MAX) {
> +		fputs("Path to cgroup.event_control is too long\n", stderr);
> +		goto out;
> +	}
> +
> +	event_control = open(event_control_path, O_WRONLY);
> +	if (event_control == -1) {
> +		fprintf(stderr, "Cannot open %s: %s\n", event_control_path,
> +				strerror(errno));
> +		goto out;
> +	}
> +
> +	efd = eventfd(0, 0);
> +	if (efd == -1) {
> +		perror("eventfd() failed");
> +		goto out;
> +	}
> +
> +	ret = dprintf(event_control, "%d %d %s", efd, cfd, argv[2]);
> +	if (ret == -1) {
> +		perror("Cannot write to cgroup.event_control");
> +		goto out;
> +	}
> +
> +	while (1) {
> +		uint64_t result;
> +
> +		ret = read(efd, &result, sizeof(result));
> +		if (ret == -1) {
> +			if (errno == EINTR)
> +				continue;
> +			perror("Cannot read from eventfd");
> +			break;
> +		}
> +		assert (ret == sizeof(result));
> +
> +		ret = access(event_control_path, W_OK);
> +		if ((ret == -1) && (errno == ENOENT)) {
> +				puts("The cgroup seems to have removed.");
> +				ret = 0;
> +				break;
> +		}
> +
> +		if (ret == -1) {
> +			perror("cgroup.event_control is not accessable any more");
> +			break;
> +		}
> +
> +		printf("%s %s: crossed\n", argv[1], argv[2]);
> +	}
> +
> +out:
> +	if (efd >= 0)
> +		close(efd);
> +	if (event_control >= 0)
> +		close(event_control);
> +	if (cfd >= 0)
> +		close(cfd);
> +
> +	return (ret != 0);
> +}
> -- 
> 1.6.6.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
