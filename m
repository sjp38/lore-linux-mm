Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 74AA69000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 03:29:05 -0400 (EDT)
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 09:28:34 +0200
In-Reply-To: <1316940890-24138-5-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-5-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317022114.9084.53.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> +static inline void inc_pcp_count(int cpu, struct per_cpu_pages *pcp, int=
 count)
> +{
> +       if (unlikely(!total_cpu_pcp_count))

	if (unlikely(!__this_cpu_read(total_cpu_pco_count))

> +               cpumask_set_cpu(cpu, cpus_with_pcp);
> +
> +       total_cpu_pcp_count +=3D count;

	__this_cpu_add(total_cpu_pcp_count, count);

> +       pcp->count +=3D count;
> +}
> +
> +static inline void dec_pcp_count(int cpu, struct per_cpu_pages *pcp, int=
 count)
> +{
> +       pcp->count -=3D count;
> +       total_cpu_pcp_count -=3D count;

	__this_cpu_sub(total_cpu_pcp_count, count);

> +
> +       if (unlikely(!total_cpu_pcp_count))

	if (unlikely(!__this_cpu_read(total_cpu_pcp_count))

> +               cpumask_clear_cpu(cpu, cpus_with_pcp);
> +}=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
