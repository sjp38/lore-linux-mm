Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 671196B011A
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:24:58 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id l26so104373fgb.4
        for <linux-mm@kvack.org>; Wed, 22 Jul 2009 10:25:04 -0700 (PDT)
Date: Wed, 22 Jul 2009 21:25:02 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC v17][PATCH 52/60] c/r: support semaphore sysv-ipc
Message-ID: <20090722172502.GA15805@lenovo>
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-53-git-send-email-orenl@librato.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1248256822-23416-53-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

[Oren Laadan - Wed, Jul 22, 2009 at 06:00:14AM -0400]
...
| +static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
| +{
| +	struct sem *sma;
| +	int i, ret;
| +
| +	sma = kmalloc(nsems * sizeof(*sma), GFP_KERNEL);

Forgot to

	if (!sma)
		return -ENOMEM;

right?

| +	ret = _ckpt_read_buffer(ctx, sma, nsems * sizeof(*sma));
| +	if (ret < 0)
| +		goto out;
| +
| +	/* validate sem array contents */
| +	for (i = 0; i < nsems; i++) {
| +		if (sma[i].semval < 0 || sma[i].sempid < 0) {
| +			ret = -EINVAL;
| +			break;
| +		}
| +	}
| + out:
| +	if (ret < 0) {
| +		kfree(sma);
| +		sma = ERR_PTR(ret);
| +	}
| +	return sma;
| +}
...

	-- Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
