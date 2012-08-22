Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C90DB6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 18:27:57 -0400 (EDT)
Received: by lbon3 with SMTP id n3so74262lbo.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 15:27:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <503354FF.1070809@parallels.com>
References: <1343942658-13307-1-git-send-email-yinghan@google.com>
	<20120803152234.GE8434@dhcp22.suse.cz>
	<501BF952.7070202@redhat.com>
	<CALWz4iw6Q500k5qGWaubwLi-3V3qziPuQ98Et9Ay=LS0-PB0dQ@mail.gmail.com>
	<20120806133324.GD6150@dhcp22.suse.cz>
	<CALWz4iw2NqQw3FgjM9k6nbMb7k8Gy2khdyL_9NpGM6T7Ma5t3g@mail.gmail.com>
	<5031EF4C.6070204@parallels.com>
	<CALWz4izy1zK5ZNZOK+82x-YPa-WdQnJu1Gq=70SDJmOVVrpPwQ@mail.gmail.com>
	<503354FF.1070809@parallels.com>
Date: Wed, 22 Aug 2012 15:27:55 -0700
Message-ID: <CALWz4iwtRzO07pU859CaK4Oz2EgziMvSJWRYDhULQ6ZdtR-4xg@mail.gmail.com>
Subject: Re: [PATCH V8 1/2] mm: memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=f46d0401723f1a2f5004c7e241ba
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

--f46d0401723f1a2f5004c7e241ba
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Aug 21, 2012 at 2:29 AM, Glauber Costa <glommer@parallels.com>wrote:

> On 08/20/2012 10:30 PM, Ying Han wrote:
> > Not exactly. Here reclaiming from root is mainly for "reclaiming from
> > root's exclusive lru", which links the page includes:
> > 1. processes running under root
> > 2. reparented pages from rmdir memcg under root
> > 3. bypassed pages
> >
> > Setting root cgroup's softlimit = 0 has the implication of putting
> > those pages to likely to reclaim, which works fine. The question is
> > that if no other memcg is above its softlimit, would it be a problem
> > to adding a bit extra pressure to root which always is eligible for
> > softlimit reclaim ( usage is always greater than softlimit).
> >
> > As an example, it works fine in our environment since we don't
> > explicitly put any process under root. Most of  the pages linked in
> > root lru would be reparented pages which should be reclaimed prior to
> > others.
>
> Keep in mind that not all environments will be specialized to the point
> of having root memcg empty. This basically treats root memcg as a trash
> bin, and can be very detrimental to use cases where actual memory is
> present in there.
>
> It would maybe be better to have all this garbage to go to a separate
> place, like a shadow garbage memcg, which is invisible to the
> filesystem, and is always the first to be reclaimed from, in any
> circumstance.
>

We can certainly do something like that, and actually we have the *special*
cgroup setup today in google's environment. It is mainly targeting for
pages that are allocated not on behalf of applications, but more of
system maintainess overhead. One example would be kernel thread memory
charging.

In this case, it might make sense to put those reparented pages to
a separate cgroup. However I do wonder with the following questions:

1.  it might only make sense to do that if something else running under
root. As we know, root is kind of special in memcg where there is no limit
on it. So I wonder what would be the real life use case to put something
under root?

2.  even the reparented pages are mixed together with pages from process
running under root, the LRU mechanism should still take effect of evicting
cold pages first. if the reparent pages are the left-over pages from the
removed cgroups, I would assume they are the candidate to reclaim first.

I am curious that in your environment, do you have things running root?

--Ying

--f46d0401723f1a2f5004c7e241ba
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Aug 21, 2012 at 2:29 AM, Glauber=
 Costa <span dir=3D"ltr">&lt;<a href=3D"mailto:glommer@parallels.com" targe=
t=3D"_blank">glommer@parallels.com</a>&gt;</span> wrote:<br><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex">
<div class=3D"im">On 08/20/2012 10:30 PM, Ying Han wrote:<br>
&gt; Not exactly. Here reclaiming from root is mainly for &quot;reclaiming =
from<br>
&gt; root&#39;s exclusive lru&quot;, which links the page includes:<br>
&gt; 1. processes running under root<br>
&gt; 2. reparented pages from rmdir memcg under root<br>
&gt; 3. bypassed pages<br>
&gt;<br>
&gt; Setting root cgroup&#39;s softlimit =3D 0 has the implication of putti=
ng<br>
&gt; those pages to likely to reclaim, which works fine. The question is<br=
>
&gt; that if no other memcg is above its softlimit, would it be a problem<b=
r>
&gt; to adding a bit extra pressure to root which always is eligible for<br=
>
&gt; softlimit reclaim ( usage is always greater than softlimit).<br>
&gt;<br>
&gt; As an example, it works fine in our environment since we don&#39;t<br>
&gt; explicitly put any process under root. Most of =A0the pages linked in<=
br>
&gt; root lru would be reparented pages which should be reclaimed prior to<=
br>
&gt; others.<br>
<br>
</div>Keep in mind that not all environments will be specialized to the poi=
nt<br>
of having root memcg empty. This basically treats root memcg as a trash<br>
bin, and can be very detrimental to use cases where actual memory is<br>
present in there.<br>
<br>
It would maybe be better to have all this garbage to go to a separate<br>
place, like a shadow garbage memcg, which is invisible to the<br>
filesystem, and is always the first to be reclaimed from, in any<br>
circumstance.<br></blockquote><div><br></div><div>We can certainly do somet=
hing like that, and actually we have the *special* cgroup setup today in go=
ogle&#39;s=A0environment. It is mainly targeting for pages that are allocat=
ed not on behalf of applications, but more of=A0</div>
<div>system=A0maintainess=A0overhead. One example would be kernel thread me=
mory charging.</div><div><br></div><div>In this case, it might make sense t=
o put those reparented pages to a=A0separate cgroup. However I do wonder wi=
th the following questions:</div>
<div><br></div><div>1. =A0it might only make sense to do that if something =
else running under root. As we know, root is kind of special in memcg where=
 there is no limit on it. So I wonder what would be the real life use case =
to put something under root?</div>
<div><br></div><div>2. =A0even the reparented pages are mixed together with=
 pages from process running under root, the LRU mechanism should still take=
 effect of evicting cold pages first. if the reparent pages are the left-ov=
er pages from the removed cgroups, I would assume they are the candidate to=
 reclaim first.</div>
<div><br></div><div>I am curious that in your=A0environment, do you have th=
ings running root?=A0</div><div><br></div><div>--Ying</div></div><br>

--f46d0401723f1a2f5004c7e241ba--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
