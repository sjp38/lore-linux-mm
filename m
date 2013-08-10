Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 434FF6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 21:39:21 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id pa12so4462013veb.16
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 18:39:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130809155309.71d93380425ef8e19c0ff44c@linux-foundation.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
	<20130809155309.71d93380425ef8e19c0ff44c@linux-foundation.org>
Date: Fri, 9 Aug 2013 18:39:20 -0700
Message-ID: <CAAxz3Xsn_m5CxudayR+ChTZhS04rGChK+9QM2SWwt1vV_1aDdA@mail.gmail.com>
Subject: Re: [patch 0/9] mm: thrash detection-based file cache sizing v3
From: Ozgun Erdogan <ozgun@citusdata.com>
Content-Type: multipart/alternative; boundary=047d7b6d88c8c69c9c04e38df58f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--047d7b6d88c8c69c9c04e38df58f
Content-Type: text/plain; charset=ISO-8859-1

Hi Andrew,

One common use case where this is really helpful is in data analytics.
Assume that you regularly analyze some chunk of data, say one month's
worth, and you run SQL queries or MapReduce jobs on this data. Let's also
assume you want to serve the current month's data from memory.

Going with an example, let's say data for March takes 60% of total memory.
You run queries over that data, and it gets pulled into the active list.
Comes next month, you want to query April's data (which again holds 60% of
memory). Since analytic queries sequentially walk over data, April's data
never becomes active, doesn't get pulled into memory, and you're stuck with
serving queries from disk.

To overcome this issue, you could regularly drop the page cache, or advise
customers to provision clusters whose cumulative memory is 2x the working
set. Neither are that ideal. My understanding is that this patch resolves
this issue, but then again my knowledge of the Linux memory manager is
pretty limited. So please call off if I'm off here.

Thanks,
Ozgun


On Fri, Aug 9, 2013 at 3:53 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Tue,  6 Aug 2013 18:44:01 -0400 Johannes Weiner <hannes@cmpxchg.org>
> wrote:
>
> > This series solves the problem by maintaining a history of pages
> > evicted from the inactive list, enabling the VM to tell streaming IO
> > from thrashing and rebalance the page cache lists when appropriate.
>
> Looks nice. The lack of testing results is conspicuous ;)
>
> It only really solves the problem in the case where
>
>         size-of-inactive-list < size-of-working-set < size-of-total-memory
>
> yes?  In fact less than that, because the active list presumably
> doesn't get shrunk to zero (how far *can* it go?).  I wonder how many
> workloads fit into those constraints in the real world.
>
>

--047d7b6d88c8c69c9c04e38df58f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi Andrew,<br><br></div>One common use case where thi=
s is really helpful is in data analytics. Assume that you regularly analyze=
 some chunk of data, say one month&#39;s worth, and you run SQL queries or =
MapReduce jobs on this data. Let&#39;s also assume you want to serve the cu=
rrent month&#39;s data from memory.<br>
<br><div><div>Going with an example, let&#39;s say data for March takes 60%=
 of total memory. You run queries over that data, and it gets pulled into t=
he active list. Comes next month, you want to query April&#39;s data (which=
 again holds 60% of memory). Since analytic queries sequentially walk over =
data, April&#39;s data never becomes active, doesn&#39;t get pulled into me=
mory, and you&#39;re stuck with serving queries from disk.<br>
<br>To overcome this issue, you could regularly drop the page cache, or adv=
ise customers to provision clusters whose cumulative memory is 2x the worki=
ng set. Neither are that ideal. My understanding is that this patch resolve=
s this issue, but then again my knowledge of the Linux memory manager is pr=
etty limited. So please call off if I&#39;m off here.<br>
<br></div><div>Thanks,<br></div><div>Ozgun<br></div></div></div><div class=
=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Fri, Aug 9, 2013 at =
3:53 PM, Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-f=
oundation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;</span> w=
rote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On Tue, =A06 Aug 2013 18:4=
4:01 -0400 Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt; wrote:<br>

<br>
&gt; This series solves the problem by maintaining a history of pages<br>
&gt; evicted from the inactive list, enabling the VM to tell streaming IO<b=
r>
&gt; from thrashing and rebalance the page cache lists when appropriate.<br=
>
<br>
</div>Looks nice. The lack of testing results is conspicuous ;)<br>
<br>
It only really solves the problem in the case where<br>
<br>
=A0 =A0 =A0 =A0 size-of-inactive-list &lt; size-of-working-set &lt; size-of=
-total-memory<br>
<br>
yes? =A0In fact less than that, because the active list presumably<br>
doesn&#39;t get shrunk to zero (how far *can* it go?). =A0I wonder how many=
<br>
workloads fit into those constraints in the real world.<br>
<br>
</blockquote></div><br></div>

--047d7b6d88c8c69c9c04e38df58f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
