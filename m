Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E884F6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 05:06:29 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oAIA6JM6029081
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:06:21 -0800
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz9.hot.corp.google.com with ESMTP id oAIA6H0x012849
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:06:18 -0800
Received: by qyk7 with SMTP id 7so1191138qyk.20
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:06:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101118085921.GA11314@amd>
References: <1290054891-6097-1-git-send-email-yinghan@google.com>
	<20101118085921.GA11314@amd>
Date: Thu, 18 Nov 2010 02:06:17 -0800
Message-ID: <AANLkTinQX_cSG3BtenCYXnPbr4GoV=3Y6sHwotWL4dN=@mail.gmail.com>
Subject: Re: [PATCH] Pass priority to shrink_slab
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016364ecea4d87033049550f08d
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0016364ecea4d87033049550f08d
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Nov 18, 2010 at 12:59 AM, Nick Piggin <npiggin@kernel.dk> wrote:

> On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying Han wrote:
> > Pass the reclaim priority down to the shrink_slab() which passes to the
> > shrink_icache_memory() for inode cache. It helps the situation when
> > shrink_slab() is being too agressive, it removes the inode as well as all
> > the pages associated with the inode. Especially when single inode has
> lots
> > of pages points to it. The application encounters performance hit when
> > that happens.
> >
> > The problem was observed on some workload we run, where it has small
> number
> > of large files. Page reclaim won't blow away the inode which is pinned by
> > dentry which in turn is pinned by open file descriptor. But if the
> application
> > is openning and closing the fds, it has the chance to trigger the issue.
> >
> > I have a script which reproduce the issue. The test is creating 1500
> empty
> > files and one big file in a cgroup. Then it starts adding memory pressure
> > in the cgroup. Both before/after the patch we see the slab drops (inode)
> in
> > slabinfo but the big file clean pages being preserves only after the
> change.
>
> I was going to do this as a flag when nearing OOM. Is there a reason
> to have it priority based? That seems a little arbitrary to me...
>

We pass down the priority from the page reclaim to hint the shrinker. Unless
the page reclaim path
really have hard time get some pages freed which brings down the priority to
zero, we probably don't
want to throw out tons of page cache pages in order to free a single inode
cache. So the priority here
is really a hint of how badly we want to shrink the inode no matter what.

So what the flag is based on to set? How we justify the nearing OOM
condition in the shrinker?

--Ying


> FWIW, we can just add this to the new shrinker API, and convert over
> the users who care about it, so it doesn't have to be done in a big
> patch.
>

--0016364ecea4d87033049550f08d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Nov 18, 2010 at 12:59 AM, Nick P=
iggin <span dir=3D"ltr">&lt;<a href=3D"mailto:npiggin@kernel.dk">npiggin@ke=
rnel.dk</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Wed, Nov 17, 2010 at 08:34:51PM -0800, Ying Han wrote:=
<br>
&gt; Pass the reclaim priority down to the shrink_slab() which passes to th=
e<br>
&gt; shrink_icache_memory() for inode cache. It helps the situation when<br=
>
&gt; shrink_slab() is being too agressive, it removes the inode as well as =
all<br>
&gt; the pages associated with the inode. Especially when single inode has =
lots<br>
&gt; of pages points to it. The application encounters performance hit when=
<br>
&gt; that happens.<br>
&gt;<br>
&gt; The problem was observed on some workload we run, where it has small n=
umber<br>
&gt; of large files. Page reclaim won&#39;t blow away the inode which is pi=
nned by<br>
&gt; dentry which in turn is pinned by open file descriptor. But if the app=
lication<br>
&gt; is openning and closing the fds, it has the chance to trigger the issu=
e.<br>
&gt;<br>
&gt; I have a script which reproduce the issue. The test is creating 1500 e=
mpty<br>
&gt; files and one big file in a cgroup. Then it starts adding memory press=
ure<br>
&gt; in the cgroup. Both before/after the patch we see the slab drops (inod=
e) in<br>
&gt; slabinfo but the big file clean pages being preserves only after the c=
hange.<br>
<br>
</div>I was going to do this as a flag when nearing OOM. Is there a reason<=
br>
to have it priority based? That seems a little arbitrary to me...<br></bloc=
kquote><div><br></div><div>We pass down the priority from the page reclaim =
to hint the shrinker. Unless the page reclaim path</div><div>really have ha=
rd time get some pages freed which brings down the priority to zero, we pro=
bably don&#39;t</div>
<div>want to throw out tons of page cache pages in order to free a single i=
node cache.=A0So the priority here</div><div>is really a hint of how badly =
we want to shrink the inode no matter what.</div><div><br></div><div>So wha=
t the flag is based on to set? How we justify the nearing OOM condition in =
the shrinker?=A0</div>
<div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
FWIW, we can just add this to the new shrinker API, and convert over<br>
the users who care about it, so it doesn&#39;t have to be done in a big<br>
patch.<br></blockquote><div><br></div><div>=A0</div></div><br>

--0016364ecea4d87033049550f08d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
