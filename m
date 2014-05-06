Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id B2FD26B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:23:56 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so10408qgf.21
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:23:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z8si4364289qca.69.2014.05.06.13.23.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 13:23:56 -0700 (PDT)
Date: Tue, 6 May 2014 22:23:50 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 03/17] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
Message-ID: <20140506202350.GE1429@laptop.programming.kicks-ass.net>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1398933888-4940-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 09:44:34AM +0100, Mel Gorman wrote:
> If cpusets are not in use then we still check a global variable on every
> page allocation. Use jump labels to avoid the overhead.
>=20
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/cpuset.h | 31 +++++++++++++++++++++++++++++++
>  kernel/cpuset.c        |  8 ++++++--
>  mm/page_alloc.c        |  3 ++-
>  3 files changed, 39 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index b19d3dc..2b89e07 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -17,6 +17,35 @@
> =20
>  extern int number_of_cpusets;	/* How many cpusets are defined in system?=
 */
> =20
> +#ifdef HAVE_JUMP_LABEL
> +extern struct static_key cpusets_enabled_key;
> +static inline bool cpusets_enabled(void)
> +{
> +	return static_key_false(&cpusets_enabled_key);
> +}
> +#else
> +static inline bool cpusets_enabled(void)
> +{
> +	return number_of_cpusets > 1;
> +}
> +#endif
> +
> +static inline void cpuset_inc(void)
> +{
> +	number_of_cpusets++;
> +#ifdef HAVE_JUMP_LABEL
> +	static_key_slow_inc(&cpusets_enabled_key);
> +#endif
> +}
> +
> +static inline void cpuset_dec(void)
> +{
> +	number_of_cpusets--;
> +#ifdef HAVE_JUMP_LABEL
> +	static_key_slow_dec(&cpusets_enabled_key);
> +#endif
> +}

Why the HAVE_JUMP_LABEL and number_of_cpusets thing? When
!HAVE_JUMP_LABEL the static_key thing reverts to an atomic_t and
static_key_false() becomes:

 return unlikely(atomic_read(&key->enabled) > 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
