Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 122556B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:08:36 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id hq12so365585wib.16
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:08:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130820140406.694b248b41611883878f8245@linux-foundation.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
	<20130820140406.694b248b41611883878f8245@linux-foundation.org>
Date: Thu, 22 Aug 2013 12:08:34 +0300
Message-ID: <CAL1dPcdgmjsUk9SF1w0Xggmx4SPFj=h-edGzSdt_5NsvGsv6mg@mail.gmail.com>
Subject: Re: [patch 9/9] mm: thrash detection-based file cache sizing v4
From: Metin Doslu <metin@citusdata.com>
Content-Type: multipart/alternative; boundary=f46d0444e855792f7104e485a273
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--f46d0444e855792f7104e485a273
Content-Type: text/plain; charset=ISO-8859-1

Hey everbody,

I run following tests, and it shows in what cases this patch is beneficial
for us.

Test Environment:

* Ubuntu Server 12.04.2 LTS Linux 3.2.0-40-virtual #64-Ubuntu on EC2.
* 15 GB memory (DMA32 4GB + Normal 11GB).

Test Settings:

We have two PostgreSQL tables with same size of 9.75GB (65% of total
memory), where these tables contain clickstream events for March and April.
We call these two tables "events_march" and "events_april" respectively.

Problem (Before Patch is Applied):

I pass over events_march data twice with an example query, such as "select
count(*) from events_march". This activates all of events_march's pages.

I then pass over events_april dozens of times with a similar query. No
matter how many times I query events_april, I can't get completely get this
table's pages into memory. This happens even when events_march isn't
touched at all, events_april easily fits into memory, and events_april has
been referenced dozens of times.

After Patch is Applied:

This time, after three passes over events_april, all the pages are cached
in memory. (4th access is completely served from memory.)

I also repeated this test with a bigger dataset of size 12GB (80% of total
memory) for both events_march and events_april, and observed the same
results. (after 3rd pass, all of pages in events_april are cached.)

Thank you,
Metin


On Wed, Aug 21, 2013 at 12:04 AM, Andrew Morton
<akpm@linux-foundation.org>wrote:

> On Sat, 17 Aug 2013 15:31:14 -0400 Johannes Weiner <hannes@cmpxchg.org>
> wrote:
>
> > This series solves the problem by maintaining a history of pages
> > evicted from the inactive list, enabling the VM to tell streaming IO
> > from thrashing and rebalance the page cache lists when appropriate.
>
> I can't say I'm loving the patchset.  It adds significant bloat to the
> inode (of all things!), seems to add some runtime overhead and
> certainly adds boatloads of complexity.
>
> In return for which we get...  well, I don't know what we get - no data
> was included.  It had better be good!
>
> To aid in this decision, please go through the patchset and calculate
> and itemize the overhead: increased inode size, increased radix-tree
> consumption, lengthier code paths, anything else I missed  Others can
> make their own judgements regarding complexity increase.
>
> Then please carefully describe the benefits, then see if you can
> convince us that one is worth the other!
>
>

--f46d0444e855792f7104e485a273
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hey everbody,<div><br></div><div>I run following tests, an=
d it shows in what cases this patch is beneficial for us.</div><div><br></d=
iv><div><div>Test Environment:</div><div><br></div><div>* Ubuntu Server 12.=
04.2 LTS Linux 3.2.0-40-virtual #64-Ubuntu on EC2.</div>
<div>* 15 GB memory (DMA32 4GB + Normal 11GB).</div><div><br></div><div>Tes=
t Settings:</div><div><br></div><div>We have two PostgreSQL tables with sam=
e size of 9.75GB (65% of total memory), where these tables contain clickstr=
eam events for March and April. We call these two tables &quot;events_march=
&quot; and &quot;events_april&quot; respectively.</div>
<div><br></div><div>Problem (Before Patch is Applied):</div><div><br></div>=
<div>I pass over events_march data twice with an example query, such as &qu=
ot;select count(*) from events_march&quot;. This activates all of events_ma=
rch&#39;s pages.</div>
<div><br></div><div>I then pass over events_april dozens of times with a si=
milar query. No matter how many times I query events_april, I can&#39;t get=
 completely get this table&#39;s pages into memory. This happens even when =
events_march isn&#39;t touched at all, events_april easily fits into memory=
, and events_april has been referenced dozens of times.</div>
<div><br></div><div>After Patch is Applied:</div><div><br></div><div>This t=
ime, after three passes over events_april, all the pages are cached in memo=
ry. (4th access is completely served from memory.)</div><div><br></div>
<div>I also repeated this test with a bigger dataset of size 12GB (80% of t=
otal memory) for both events_march and events_april, and observed the same =
results. (after 3rd pass, all of pages in events_april are cached.)</div>
</div><div><br></div><div>Thank you,</div><div>Metin</div></div><div class=
=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Wed, Aug 21, 2013 at=
 12:04 AM, Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux=
-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>&gt;</span>=
 wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On Sat, 17 Aug 2013 15:31:=
14 -0400 Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@c=
mpxchg.org</a>&gt; wrote:<br>

<br>
&gt; This series solves the problem by maintaining a history of pages<br>
&gt; evicted from the inactive list, enabling the VM to tell streaming IO<b=
r>
&gt; from thrashing and rebalance the page cache lists when appropriate.<br=
>
<br>
</div>I can&#39;t say I&#39;m loving the patchset. =A0It adds significant b=
loat to the<br>
inode (of all things!), seems to add some runtime overhead and<br>
certainly adds boatloads of complexity.<br>
<br>
In return for which we get... =A0well, I don&#39;t know what we get - no da=
ta<br>
was included. =A0It had better be good!<br>
<br>
To aid in this decision, please go through the patchset and calculate<br>
and itemize the overhead: increased inode size, increased radix-tree<br>
consumption, lengthier code paths, anything else I missed =A0Others can<br>
make their own judgements regarding complexity increase.<br>
<br>
Then please carefully describe the benefits, then see if you can<br>
convince us that one is worth the other!<br>
<br>
</blockquote></div><br></div>

--f46d0444e855792f7104e485a273--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
