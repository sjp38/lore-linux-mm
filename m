Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 09B386B0311
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 19:52:50 -0500 (EST)
Received: by dajx4 with SMTP id x4so1432756daj.26
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 16:52:50 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 14 Dec 2011 16:52:50 -0800 (PST)
In-Reply-To: <CAEas1LKNMSxhp-7DpsOOCu0fx6kx5ya-zqsZQgnf6JwzX0E0gw@mail.gmail.com>
References: <CAEas1LKNMSxhp-7DpsOOCu0fx6kx5ya-zqsZQgnf6JwzX0E0gw@mail.gmail.com>
Message-ID: <daec6a41-d318-4142-a3e1-14b8af64af66@b14g2000prn.googlegroups.com>
Subject: Re: question: why use vzalloc() and vzfree() in mem_cgroup_alloc()
 and mem_cgroup_free()
From: Chris Snook <csnook@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kernel-team <kernel-team@google.com>
Cc: Laurent Chavey <chavey@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, glommer@parallels.com

On Dec 14, 12:12=A0pm, Laurent Chavey <chavey@google.com> wrote:
> context:
>
> While testing patches from Glauber Costa, "adding support
> for tcp memory allocation in kmem cgroup", we hit a
> BUG_ON(in_interrupt()) in vfree(). The code path in question
> is taken because the izeof(struct mem_cgroup) is
>
> >=3D PAGE_SIZE in the call to mem_cgroup_free(),

Still, or again? A cursory search turns up this patch:

https://lkml.org/lkml/2010/9/27/147

but I don't have handy any further information about how it fared.

> Since socket may get free in an interrupt context,
> the combination of vzalloc(), vfree() should not be used
> when accounting for socket mem (unless the code is modified).

Agreed, but why does socket freeing cause struct mem_cgroup to be
freed? I think I'm missing something about the kmem cgroup
implementation.

> question:
>
> Is there reasons why vzalloc() is used in mem_cgroup_alloc() ?
> =A0 =A0 . are we seeing mem fragmentations to level that fail
> =A0 =A0 =A0 kzalloc() or kmalloc().
> =A0 =A0 . do we have empirical data that shows the allocation failure
> =A0 =A0 =A0 rate for kmalloc(), kzalloc() per alloc size (num pages)

Laziness? Last I checked, OpenAFS still called vmalloc() in the
pageout path, which is a no-no of similar magnitude, because handling
the failure properly is difficult to code and even more difficult to
test, and nobody is seeing machines deadlock often enough to justify
the development effort.

If we're having significant failures in allocating two consecutive
pages, we'll probably have other problems too, but there are
conditions where being able to vzalloc that could save you. I suspect
they're less common than conditions where vzalloc in interrupt context
would burn you, but I have no empirical data to support that.

-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
