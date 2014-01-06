Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9093C6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 12:09:05 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so8141012eei.28
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 09:09:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e2si84846680eeg.93.2014.01.06.09.09.04
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 09:09:04 -0800 (PST)
Date: Mon, 6 Jan 2014 18:08:56 +0100
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [RFC][PATCH 3/3] audit: Audit proc cmdline value
Message-ID: <20140106170855.GA1828@mguzik.redhat.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
 <1389022230-24664-3-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1389022230-24664-3-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

I can't comment on the concept, but have one nit.

On Mon, Jan 06, 2014 at 07:30:30AM -0800, William Roberts wrote:
> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct *tsk,
> +			 struct audit_context *context)
> +{
> +	int res;
> +	char *buf;
> +	char *msg = "(null)";
> +	audit_log_format(ab, " cmdline=");
> +
> +	/* Not  cached */
> +	if (!context->cmdline) {
> +		buf = kmalloc(PATH_MAX, GFP_KERNEL);
> +		if (!buf)
> +			goto out;
> +		res = get_cmdline(tsk, buf, PATH_MAX);
> +		/* Ensure NULL terminated */
> +		if (buf[res-1] != '\0')
> +			buf[res-1] = '\0';

This accesses memory below the buffer if get_cmdline returned 0, which I
believe will be the case when someone jokingly unmaps the area (all
maybe when it is swapped out but can't be swapped in due to I/O errors).

Also since you are just putting 0 in there anyway I don't see much point
in testing for it.

> +		context->cmdline = buf;
> +	}
> +	msg = context->cmdline;
> +out:
> +	audit_log_untrustedstring(ab, msg);
> +}
> +



-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
