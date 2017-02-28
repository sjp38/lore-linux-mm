Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24C426B03A6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 08:05:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x17so15768530pgi.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:05:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d2si1737191pfk.113.2017.02.28.05.05.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 05:05:23 -0800 (PST)
Date: Tue, 28 Feb 2017 14:05:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228130513.GH5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> +#define MAX_XHLOCKS_NR 64UL

> +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +	if (tsk->xhlocks) {
> +		void *tmp = tsk->xhlocks;
> +		/* Disable crossrelease for current */
> +		tsk->xhlocks = NULL;
> +		vfree(tmp);
> +	}
> +#endif

> +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +	p->xhlock_idx = 0;
> +	p->xhlock_idx_soft = 0;
> +	p->xhlock_idx_hard = 0;
> +	p->xhlock_idx_nmi = 0;
> +	p->xhlocks = vzalloc(sizeof(struct hist_lock) * MAX_XHLOCKS_NR);

I don't think we need vmalloc for this now.

> +	p->work_id = 0;
> +#endif

> +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +	if (p->xhlocks) {
> +		void *tmp = p->xhlocks;
> +		/* Diable crossrelease for current */
> +		p->xhlocks = NULL;
> +		vfree(tmp);
> +	}
> +#endif

Second instance of the same code, which would suggest using a function
for this. Also, with a function you can loose the #ifdeffery.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
