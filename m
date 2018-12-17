Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 557B48E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:22:35 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so11018828pgb.7
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:22:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y6si11404217pfi.228.2018.12.17.08.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 08:22:33 -0800 (PST)
Date: Mon, 17 Dec 2018 17:22:23 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] psi: introduce psi monitor
Message-ID: <20181217162223.GD2218@hirez.programming.kicks-ass.net>
References: <20181214171508.7791-1-surenb@google.com>
 <20181214171508.7791-7-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214171508.7791-7-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@android.com

On Fri, Dec 14, 2018 at 09:15:08AM -0800, Suren Baghdasaryan wrote:
> +ssize_t psi_trigger_parse(char *buf, size_t nbytes, enum psi_res res,
> +	enum psi_states *state, u32 *threshold_us, u32 *win_sz_us)
> +{
> +	bool some;
> +	bool threshold_pct;
> +	u32 threshold;
> +	u32 win_sz;
> +	char *p;
> +
> +	p = strsep(&buf, " ");
> +	if (p == NULL)
> +		return -EINVAL;
> +
> +	/* parse type */
> +	if (!strcmp(p, "some"))
> +		some = true;
> +	else if (!strcmp(p, "full"))
> +		some = false;
> +	else
> +		return -EINVAL;
> +
> +	switch (res) {
> +	case (PSI_IO):
> +		*state = some ? PSI_IO_SOME : PSI_IO_FULL;
> +		break;
> +	case (PSI_MEM):
> +		*state = some ? PSI_MEM_SOME : PSI_MEM_FULL;
> +		break;
> +	case (PSI_CPU):
> +		if (!some)
> +			return -EINVAL;
> +		*state = PSI_CPU_SOME;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	while (isspace(*buf))
> +		buf++;
> +
> +	p = strsep(&buf, "%");
> +	if (p == NULL)
> +		return -EINVAL;
> +
> +	if (buf == NULL) {
> +		/* % sign was not found, threshold is specified in us */
> +		buf = p;
> +		p = strsep(&buf, " ");
> +		if (p == NULL)
> +			return -EINVAL;
> +
> +		threshold_pct = false;
> +	} else
> +		threshold_pct = true;
> +
> +	/* parse threshold */
> +	if (kstrtouint(p, 0, &threshold))
> +		return -EINVAL;
> +
> +	while (isspace(*buf))
> +		buf++;
> +
> +	p = strsep(&buf, " ");
> +	if (p == NULL)
> +		return -EINVAL;
> +
> +	/* Parse window size */
> +	if (kstrtouint(p, 0, &win_sz))
> +		return -EINVAL;
> +
> +	/* Check window size */
> +	if (win_sz < PSI_TRIG_MIN_WIN_US || win_sz > PSI_TRIG_MAX_WIN_US)
> +		return -EINVAL;
> +
> +	if (threshold_pct)
> +		threshold = (threshold * win_sz) / 100;
> +
> +	/* Check threshold */
> +	if (threshold == 0 || threshold > win_sz)
> +		return -EINVAL;
> +
> +	*threshold_us = threshold;
> +	*win_sz_us = win_sz;
> +
> +	return 0;
> +}

How well has this thing been fuzzed? Custom string parser, yay!
