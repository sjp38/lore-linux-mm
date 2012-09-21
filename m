Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 188196B0068
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:29:22 -0400 (EDT)
Received: by weyu3 with SMTP id u3so266849wey.14
        for <linux-mm@kvack.org>; Fri, 21 Sep 2012 02:29:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347977530-29755-9-git-send-email-glommer@parallels.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
	<1347977530-29755-9-git-send-email-glommer@parallels.com>
Date: Fri, 21 Sep 2012 12:29:20 +0300
Message-ID: <CAOJsxLFeh5G1JBMmZPkwMBTEXSJB7Bmp1yvvbDz0suWE5sReYA@mail.gmail.com>
Subject: Re: [PATCH v3 08/16] slab: allow enable_cpu_cache to use preset
 values for its tunables
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Sep 18, 2012 at 5:12 PM, Glauber Costa <glommer@parallels.com> wrote:
> diff --git a/mm/slab.c b/mm/slab.c
> index e2cf984..f2d760c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4141,8 +4141,19 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
>  static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp)
>  {
>         int err;
> -       int limit, shared;
> -
> +       int limit = 0;
> +       int shared = 0;
> +       int batchcount = 0;
> +
> +#ifdef CONFIG_MEMCG_KMEM
> +       if (cachep->memcg_params.parent) {
> +               limit = cachep->memcg_params.parent->limit;
> +               shared = cachep->memcg_params.parent->shared;
> +               batchcount = cachep->memcg_params.parent->batchcount;

Style nit: please introduce a variable for
"cachep->memcg_params.parent" to make this human-readable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
