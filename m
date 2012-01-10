Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 1B7F06B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 07:43:23 -0500 (EST)
Received: by vcge1 with SMTP id e1so4265937vcg.14
        for <linux-mm@kvack.org>; Tue, 10 Jan 2012 04:43:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v7tsxgu33l0zgt@mpn-glaptop>
References: <1326040026-7285-8-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1201091034390.31395@router.home>
	<op.v7tsxgu33l0zgt@mpn-glaptop>
Date: Tue, 10 Jan 2012 14:43:21 +0200
Message-ID: <CAOtvUMcJgnGf+RbF6J5zPxi3x4sCt7qoWe+Xd6C8GOhJV=xhqQ@mail.gmail.com>
Subject: Re: [PATCH v6 7/8] mm: only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

2012/1/9 Michal Nazarewicz <mina86@mina86.com>:
> On Mon, 09 Jan 2012 17:35:26 +0100, Christoph Lameter <cl@linux.com> wrot=
e:
>
>> On Sun, 8 Jan 2012, Gilad Ben-Yossef wrote:
>>
>>> @@ -67,6 +67,14 @@ DEFINE_PER_CPU(int, numa_node);
>>> =A0EXPORT_PER_CPU_SYMBOL(numa_node);
>>> =A0#endif
>>>
>>> +/*
>>> + * A global cpumask of CPUs with per-cpu pages that gets
>>> + * recomputed on each drain. We use a global cpumask
>>> + * here to avoid allocation on direct reclaim code path
>>> + * for CONFIG_CPUMASK_OFFSTACK=3Dy
>>> + */
>>> +static cpumask_var_t cpus_with_pcps;
>>
>>
>> Move the static definition into drain_all_pages()?
>
>
> This is initialised in setup_per_cpu_pageset() so it needs to be file
> scoped.

Yes. The cpumask_var_t abstraction is convenient and all but it does
make the allocation
very non obvious when it does not happen in proximity to the variable
use - it doesn't *look* like
a pointer. "syntactic sugar causes cancer of the semicolon" and all that.

Gilad



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
