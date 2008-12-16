Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3BE6B0085
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 14:09:34 -0500 (EST)
Message-ID: <4947FBC8.2000601@google.com>
Date: Tue, 16 Dec 2008 11:04:40 -0800
From: Mike Waychison <mikew@google.com>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 03/13] General infrastructure for checkpoint
 restart
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1228498282-11804-4-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Oren Laadan wrote:

> +/*
> + * Helpers to write(read) from(to) kernel space to(from) the checkpoint
> + * image file descriptor (similar to how a core-dump is performed).
> + *
> + *   cr_kwrite() - write a kernel-space buffer to the checkpoint image
> + *   cr_kread() - read from the checkpoint image to a kernel-space buffer
> + */
> +
> +int cr_kwrite(struct cr_ctx *ctx, void *addr, int count)
> +{
> +	struct file *file = ctx->file;
> +	mm_segment_t fs;
> +	ssize_t nwrite;
> +	int nleft;
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	for (nleft = count; nleft; nleft -= nwrite) {
> +		nwrite = file->f_op->write(file, addr, nleft, &file->f_pos);
> +		if (nwrite < 0) {
> +			if (nwrite == -EAGAIN)
> +				nwrite = 0;
> +			else

set_fs(fs) here

> +				return nwrite;
> +		}
> +		addr += nwrite;
> +	}
> +	set_fs(fs);
> +	ctx->total += count;
> +	return 0;
> +}
> +
> +int cr_kread(struct cr_ctx *ctx, void *addr, int count)
> +{
> +	struct file *file = ctx->file;
> +	mm_segment_t fs;
> +	ssize_t nread;
> +	int nleft;
> +
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
> +	for (nleft = count; nleft; nleft -= nread) {
> +		nread = file->f_op->read(file, addr, nleft, &file->f_pos);
> +		if (nread <= 0) {
> +			if (nread == -EAGAIN) {
> +				nread = 0;
> +				continue;
> +			} else if (nread == 0)
> +				nread = -EPIPE;		/* unexecpted EOF */

set_fs(fs) here as well

> +			return nread;
> +		}
> +		addr += nread;
> +	}
> +	set_fs(fs);
> +	ctx->total += count;
> +	return 0;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
