Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC9286B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 20:25:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d18so37150126pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 17:25:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j17si3178444pgg.167.2017.02.28.17.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 17:25:04 -0800 (PST)
Date: Tue, 28 Feb 2017 17:21:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm subsystem refcounter conversions
Message-Id: <20170228172156.de13fdc41a3ca6a4deea7750@linux-foundation.org>
In-Reply-To: <1487671124-11188-1-git-send-email-elena.reshetova@intel.com>
References: <1487671124-11188-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, arnd@arndb.de, luto@kernel.org

On Tue, 21 Feb 2017 11:58:39 +0200 Elena Reshetova <elena.reshetova@intel.com> wrote:

> Now when new refcount_t type and API are finally merged
> (see include/linux/refcount.h), the following
> patches convert various refcounters in the mm susystem from atomic_t
> to refcount_t. By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> 
> The below patches are fully independent and can be cherry-picked separately.
> Since we convert all kernel subsystems in the same fashion, resulting
> in about 300 patches, we have to group them for sending at least in some
> fashion to be manageable. Please excuse the long cc list.

I don't think so.  Unless I'm missing something rather large...


We're going to convert every

	atomic_inc(&foo);

into an uninlined function which calls an uninlined

bool refcount_inc_not_zero(refcount_t *r)
{
	unsigned int old, new, val = atomic_read(&r->refs);

	for (;;) {
		new = val + 1;

		if (!val)
			return false;

		if (unlikely(!new))
			return true;

		old = atomic_cmpxchg_relaxed(&r->refs, val, new);
		if (old == val)
			break;

		val = old;
	}

	WARN(new == UINT_MAX, "refcount_t: saturated; leaking memory.\n");

	return true;
}

The performance implications of this proposal are terrifying.

I suggest adding a set of non-debug inlined refcount functions which
just fall back to the simple atomic.h operations.

And add a new CONFIG_DEBUG_REFCOUNT.  So the performance (and code
size!) with CONFIG_DEBUG_REFCOUNT=n is unaltered from present code. 
And make CONFIG_DEBUG_REFCOUNT suitably difficult to set.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
