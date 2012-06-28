Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 56CCD6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:23:51 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1954446ggm.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 23:23:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120626143703.396d6d66.akpm@linux-foundation.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 28 Jun 2012 02:23:30 -0400
Message-ID: <CAHGf_=ra6eXSVyhox3z2X-4csrwWeeDgMjS83i-J2nJwuWpqhg@mail.gmail.com>
Subject: Re: needed lru_add_drain_all() change
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Tue, Jun 26, 2012 at 5:37 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D43811
>
> lru_add_drain_all() uses schedule_on_each_cpu(). =A0But
> schedule_on_each_cpu() hangs if a realtime thread is spinning, pinned
> to a CPU. =A0There's no intention to change the scheduler behaviour, so I
> think we should remove schedule_on_each_cpu() from the kernel.
>
> The biggest user of schedule_on_each_cpu() is lru_add_drain_all().
>
> Does anyone have any thoughts on how we can do this? =A0The obvious
> approach is to declare these:
>
> static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
> static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
>
> to be irq-safe and use on_each_cpu(). =A0lru_rotate_pvecs is already
> irq-safe and converting lru_add_pvecs and lru_deactivate_pvecs looks
> pretty simple.
>
> Thoughts?

I agree.

But i hope more. In these days, we have plenty lru_add_drain_all()
callsite. So,
i think we should remove struct pagevec and should aim migration aware new
batch mechanism. maybe. This also improve compaction success rate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
