Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCB016B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 22:23:35 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id oAK3NU9h005660
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 19:23:31 -0800
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by kpbe14.cbf.corp.google.com with ESMTP id oAK3NOSv002815
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 19:23:29 -0800
Received: by qyk33 with SMTP id 33so230896qyk.2
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 19:23:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101119142552.df0e351c.akpm@linux-foundation.org>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
	<20101119142552.df0e351c.akpm@linux-foundation.org>
Date: Fri, 19 Nov 2010 19:23:22 -0800
Message-ID: <AANLkTi=EnNqEDoWn6OiR04TaTBskNEZx4z8MOAYH8nK1@mail.gmail.com>
Subject: Re: [PATCH] Pass priority to shrink_slab
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016362839fa9e34730495738b4f
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

--0016362839fa9e34730495738b4f
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Nov 19, 2010 at 2:25 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Thu, 18 Nov 2010 19:59:21 +1100
> Nick Piggin <npiggin@kernel.dk> wrote:
>
> > On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying Han wrote:
> > > Pass the reclaim priority down to the shrink_slab() which passes to the
> > > shrink_icache_memory() for inode cache. It helps the situation when
> > > shrink_slab() is being too agressive, it removes the inode as well as
> all
> > > the pages associated with the inode. Especially when single inode has
> lots
> > > of pages points to it. The application encounters performance hit when
> > > that happens.
> > >
> > > The problem was observed on some workload we run, where it has small
> number
> > > of large files. Page reclaim won't blow away the inode which is pinned
> by
> > > dentry which in turn is pinned by open file descriptor. But if the
> application
> > > is openning and closing the fds, it has the chance to trigger the
> issue.
> > >
> > > I have a script which reproduce the issue. The test is creating 1500
> empty
> > > files and one big file in a cgroup. Then it starts adding memory
> pressure
> > > in the cgroup. Both before/after the patch we see the slab drops
> (inode) in
> > > slabinfo but the big file clean pages being preserves only after the
> change.
> >
> > I was going to do this as a flag when nearing OOM. Is there a reason
> > to have it priority based? That seems a little arbitrary to me...
> >
>
> There are subtleties here.
>
> Take the case of a machine with 1MB lowmem and 8GB highmem.  It has a
> million cached inodes, each one with a single attached pagecache page.
> The fairly common lots-of-small-files workload.
>
> The inodes are all in lowmem.  Most of their pagecache is in highmem.
>
> To satisfy a GFP_KERNEL or GFP_USER allocation request, we need to free
> up some of that lowmem.  But none of those inodes are reclaimable,
> because of their attached highmem pagecache.  So in this case we very
> much want to shoot down those inodes' pagecache within the icache
> shrinker, so we can get those inodes reclaimed.
>


With the proposed change, that reclaim won't be happening until vmscan
> has reached a higher priority.  Which means that the VM will instead go
> nuts reclaiming *other* lowmem objects.  That means all the other slabs
> which have shrinkers.  It also means lowmem pagecache: those inodes
> will cause all your filesystem metadata to get evicted.  It also means
> that anonymous memory which happened to land in lowmem will get swapped
> out, and program text which is in lowmem will be unmapped and evicted.
>
> Thanks Andrew for your comments. The example makes sense to me although it
seems to
little bit rare.

On the page reclaim path, we always try the page lru first and then the
shrink slab since the latter one
has no guarantee of freeing page. If the lowmem has user pages on the lru
which could be reclaimed,
preserving the slabs might not be a bed idea? And if the page lru has hard
time to reclaim those pages,
it will raise up the priority and in turn will affect the shrinker after the
change.

There may be other undesirable interactions as well - I'm not thinking
> too hard at present ;)  Thinking caps on, please.
>
>
> I think the patch needs to be smarter.  It should at least take
> into account the *amount* of memory attached to the inode -
> address_space.nr_pages.
>

Agree. The check of  (priority > 0 && inode->i_data.nrpages) could
potentially
be improved.

>
> Where "amount" is a fuzzy concept - the shrinkers try to account for
> seek cost and not just number-of-bytes, so that needs thinking about as
> well.
>
>    So what to do?  I don't immediately see any alternative to implementing

> reasonably comprehensive aging for inodes.  Each time around the LRU
> the inode gets aged.  Each time it or its pages get touched, it gets
> unaged.  When considering an inode for eviction we look to see if
>
>  fn(inode age) > fn(number of seeks to reestablish inode and its pagecache)
>
> Which is an interesting project ;)
>
> Interesting idea, but this also has the highmem and lowmem problem.

>


> And yes, we need a struct shrinker_control so we can fiddle with the
> argument passing without having to edit lots of files each time.
>

Yes, and it would be much easier later to add a small feature (like this
one) w/o
touching so many files of the shrinkers. I am thinking if we can extend the
scan_control
from page reclaim and pass it down to the shrinker ?

--Ying

--0016362839fa9e34730495738b4f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Nov 19, 2010 at 2:25 PM, Andrew =
Morton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">a=
kpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">
On Thu, 18 Nov 2010 19:59:21 +1100<br>
<div class=3D"im">Nick Piggin &lt;<a href=3D"mailto:npiggin@kernel.dk">npig=
gin@kernel.dk</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying=
 Han wrote:<br>
&gt; &gt; Pass the reclaim priority down to the shrink_slab() which passes =
to the<br>
&gt; &gt; shrink_icache_memory() for inode cache. It helps the situation wh=
en<br>
&gt; &gt; shrink_slab() is being too agressive, it removes the inode as wel=
l as all<br>
&gt; &gt; the pages associated with the inode. Especially when single inode=
 has lots<br>
&gt; &gt; of pages points to it. The application encounters performance hit=
 when<br>
&gt; &gt; that happens.<br>
&gt; &gt;<br>
&gt; &gt; The problem was observed on some workload we run, where it has sm=
all number<br>
&gt; &gt; of large files. Page reclaim won&#39;t blow away the inode which =
is pinned by<br>
&gt; &gt; dentry which in turn is pinned by open file descriptor. But if th=
e application<br>
&gt; &gt; is openning and closing the fds, it has the chance to trigger the=
 issue.<br>
&gt; &gt;<br>
&gt; &gt; I have a script which reproduce the issue. The test is creating 1=
500 empty<br>
&gt; &gt; files and one big file in a cgroup. Then it starts adding memory =
pressure<br>
&gt; &gt; in the cgroup. Both before/after the patch we see the slab drops =
(inode) in<br>
&gt; &gt; slabinfo but the big file clean pages being preserves only after =
the change.<br>
&gt;<br>
&gt; I was going to do this as a flag when nearing OOM. Is there a reason<b=
r>
&gt; to have it priority based? That seems a little arbitrary to me...<br>
&gt;<br>
<br>
</div>There are subtleties here.<br>
<br>
Take the case of a machine with 1MB lowmem and 8GB highmem. =A0It has a<br>
million cached inodes, each one with a single attached pagecache page.<br>
The fairly common lots-of-small-files workload.<br>
<br>
The inodes are all in lowmem. =A0Most of their pagecache is in highmem.<br>
<br>
To satisfy a GFP_KERNEL or GFP_USER allocation request, we need to free<br>
up some of that lowmem. =A0But none of those inodes are reclaimable,<br>
because of their attached highmem pagecache. =A0So in this case we very<br>
much want to shoot down those inodes&#39; pagecache within the icache<br>
shrinker, so we can get those inodes reclaimed.<br></blockquote><div><br></=
div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex;">With the proposed change=
, that reclaim won&#39;t be happening until vmscan<br>

has reached a higher priority. =A0Which means that the VM will instead go<b=
r>
nuts reclaiming *other* lowmem objects. =A0That means all the other slabs<b=
r>
which have shrinkers. =A0It also means lowmem pagecache: those inodes<br>
will cause all your filesystem metadata to get evicted. =A0It also means<br=
>
that anonymous memory which happened to land in lowmem will get swapped<br>
out, and program text which is in lowmem will be unmapped and evicted.<br>
<br></blockquote><meta http-equiv=3D"content-type" content=3D"text/html; ch=
arset=3Dutf-8"><div>Thanks Andrew for your comments. The example makes sens=
e to me although it seems to</div><div>little bit rare.=A0</div><div>=A0</d=
iv><div>
On the page reclaim path, we always try the page lru first and then the shr=
ink slab since the latter one</div><div>has no=A0guarantee of freeing page.=
 If the lowmem has user pages on the lru which could be reclaimed,</div><di=
v>
preserving the slabs might not be a bed idea? And if the page lru has hard =
time to reclaim those pages,</div><div>it will raise up the priority and in=
 turn will affect the shrinker after the change.=A0</div><div><br></div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

There may be other undesirable interactions as well - I&#39;m not thinking<=
br>
too hard at present ;) =A0Thinking caps on, please.<br>
<br>
<br>
I think the patch needs to be smarter. =A0It should at least take<br>
into account the *amount* of memory attached to the inode -<br>
address_space.nr_pages.<br></blockquote><div><br></div><div>Agree. The chec=
k of=A0<span class=3D"Apple-style-span" style=3D"font-family: arial, sans-s=
erif; font-size: 13px; border-collapse: collapse; ">=A0(priority &gt; 0 &am=
p;&amp; inode-&gt;i_data.nrpages)</span>=A0could potentially=A0</div>
<div>be improved.</div><meta http-equiv=3D"content-type" content=3D"text/ht=
ml; charset=3Dutf-8"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Where &quot;amount&quot; is a fuzzy concept - the shrinkers try to account =
for<br>
seek cost and not just number-of-bytes, so that needs thinking about as<br>
well.<br>

<br></blockquote><div>=A0=A0 So what to do? =A0I don&#39;t immediately see =
any alternative to implementing</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
reasonably comprehensive aging for inodes. =A0Each time around the LRU<br>
the inode gets aged. =A0Each time it or its pages get touched, it gets<br>
unaged. =A0When considering an inode for eviction we look to see if<br>
<br>
 =A0fn(inode age) &gt; fn(number of seeks to reestablish inode and its page=
cache)<br>
<br>
Which is an interesting project ;)<br>
<br>
</blockquote><div>Interesting idea, but this also has the highmem and lowme=
m problem.</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex;">=A0</blockquote><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">

<br>
And yes, we need a struct shrinker_control so we can fiddle with the<br>
argument passing without having to edit lots of files each time.<br></block=
quote><div><br></div><div>Yes, and it would be much easier later to add a s=
mall feature (like this one) w/o=A0</div><div>touching so many files of the=
=A0shrinkers. I am thinking if we can extend the scan_control</div>
<div>from page reclaim=A0and pass it down to the shrinker ?</div><div><br><=
/div><div>--Ying</div></div><br>

--0016362839fa9e34730495738b4f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
