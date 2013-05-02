Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 11E796B025B
	for <linux-mm@kvack.org>; Thu,  2 May 2013 09:37:59 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan
 API
Date: Thu, 2 May 2013 13:37:54 +0000
Message-ID: <xm7djq7r1xfsf4uo0hohgyxj.1367501887374@email.android.com>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-18-git-send-email-glommer@openvz.org>
 <20130430215355.GN6415@suse.de>
 <20130430220050.GK9931@google.com>,<20130502093744.GJ11497@suse.de>
In-Reply-To: <20130502093744.GJ11497@suse.de>
Reply-To: Glauber Costa <glommer@parallels.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_xm7djq7r1xfsf4uo0hohgyxj1367501887374emailandroidcom_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mgorman@suse.de" <mgorman@suse.de>, "koverstreet@google.com" <koverstreet@google.com>
Cc: "glommer@openvz.org" <glommer@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mhocko@suse.cz" <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "dchinner@redhat.com" <dchinner@redhat.com>, "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "dan.magenheimer@oracle.com" <dan.magenheimer@oracle.com>

--_000_xm7djq7r1xfsf4uo0hohgyxj1367501887374emailandroidcom_
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

Sorry for the following crappy message. I came travelling without my laptop=
.

Please note that one of my patches implement one shot shrinkers onto of vmp=
ressure mechanism. It can still be called frequently, because right now it =
is called every time userspace would get an event. But at least it won't it=
erate.

You can try investigating if that interface suits your i915 needs better


Sent by Samsung Mobile



-------- Original message --------
From: Mel Gorman <mgorman@suse.de>
Date:
To: Kent Overstreet <koverstreet@google.com>
Cc: Glauber Costa <glommer@openvz.org>,linux-mm@kvack.org,cgroups@vger.kern=
el.org,Andrew Morton <akpm@linux-foundation.org>,Greg Thelen <gthelen@googl=
e.com>,kamezawa.hiroyu@jp.fujitsu.com,Michal Hocko <mhocko@suse.cz>,Johanne=
s Weiner <hannes@cmpxchg.org>,Dave Chinner <dchinner@redhat.com>,intel-gfx@=
lists.freedesktop.org,dri-devel@lists.freedesktop.org,devel@driverdev.osuos=
l.org,Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan =
API


On Tue, Apr 30, 2013 at 03:00:50PM -0700, Kent Overstreet wrote:
> On Tue, Apr 30, 2013 at 10:53:55PM +0100, Mel Gorman wrote:
> > On Sat, Apr 27, 2013 at 03:19:13AM +0400, Glauber Costa wrote:
> > > diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/btree.c
> > > index 03e44c1..8b9c1a6 100644
> > > --- a/drivers/md/bcache/btree.c
> > > +++ b/drivers/md/bcache/btree.c
> > > @@ -599,11 +599,12 @@ static int mca_reap(struct btree *b, struct clo=
sure *cl, unsigned min_order)
> > >    return 0;
> > >  }
> > >
> > > -static int bch_mca_shrink(struct shrinker *shrink, struct shrink_con=
trol *sc)
> > > +static long bch_mca_scan(struct shrinker *shrink, struct shrink_cont=
rol *sc)
> > >  {
> > >    struct cache_set *c =3D container_of(shrink, struct cache_set, shr=
ink);
> > >    struct btree *b, *t;
> > >    unsigned long i, nr =3D sc->nr_to_scan;
> > > + long freed =3D 0;
> > >
> > >    if (c->shrinker_disabled)
> > >            return 0;
> >
> > -1 if shrinker disabled?
> >
> > Otherwise if the shrinker is disabled we ultimately hit this loop in
> > shrink_slab_one()
>
> My memory is very hazy on this stuff, but I recall there being another
> loop that'd just spin if we always returned -1.
>
> (It might've been /proc/sys/vm/drop_caches, or maybe that was another
> bug..)
>

It might be worth chasing down what that bug was and fixing it.

> But 0 should certainly be safe - if we're always returning 0, then we're
> claiming we don't have anything to shrink.
>

It won't crash, but in Glauber's current code, it'll call you a few more
times uselessly and the scanned statistics become misleading. I think
Glauber/Dave's series is a big improvement over what we currently have
and it would be nice to get it ironed out.

--
Mel Gorman
SUSE Labs

--_000_xm7djq7r1xfsf4uo0hohgyxj1367501887374emailandroidcom_
Content-Type: text/html; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
15">
<meta name=3D"Generator" content=3D"Microsoft Exchange Server">
<!-- converted from text --><style><!-- .EmailQuote { margin-left: 1pt; pad=
ding-left: 4pt; border-left: #800000 2px solid; } --></style>
</head>
<body>
<div>
<div>Sorry for the following crappy message. I came travelling without my l=
aptop.</div>
<div><br>
</div>
<div>Please note that one of my patches implement one shot shrinkers onto o=
f vmpressure mechanism. It can still be called frequently, because right no=
w it is called every time userspace would get an event. But at least it won=
't iterate.</div>
<div><br>
</div>
<div>You can try investigating if that interface suits your i915 needs bett=
er</div>
<div><br>
</div>
<div><br>
</div>
<div>
<div style=3D"font-size:75%; color:#575757">Sent by Samsung Mobile</div>
</div>
<br>
<br>
<br>
-------- Original message --------<br>
From: Mel Gorman &lt;mgorman@suse.de&gt; <br>
Date: <br>
To: Kent Overstreet &lt;koverstreet@google.com&gt; <br>
Cc: Glauber Costa &lt;glommer@openvz.org&gt;,linux-mm@kvack.org,cgroups@vge=
r.kernel.org,Andrew Morton &lt;akpm@linux-foundation.org&gt;,Greg Thelen &l=
t;gthelen@google.com&gt;,kamezawa.hiroyu@jp.fujitsu.com,Michal Hocko &lt;mh=
ocko@suse.cz&gt;,Johannes Weiner &lt;hannes@cmpxchg.org&gt;,Dave
 Chinner &lt;dchinner@redhat.com&gt;,intel-gfx@lists.freedesktop.org,dri-de=
vel@lists.freedesktop.org,devel@driverdev.osuosl.org,Dan Magenheimer &lt;da=
n.magenheimer@oracle.com&gt;
<br>
Subject: Re: [PATCH v4 17/31] drivers: convert shrinkers to new count/scan =
API <br>
<br>
<br>
</div>
<font size=3D"2"><span style=3D"font-size:10pt;">
<div class=3D"PlainText">On Tue, Apr 30, 2013 at 03:00:50PM -0700, Kent Ove=
rstreet wrote:<br>
&gt; On Tue, Apr 30, 2013 at 10:53:55PM &#43;0100, Mel Gorman wrote:<br>
&gt; &gt; On Sat, Apr 27, 2013 at 03:19:13AM &#43;0400, Glauber Costa wrote=
:<br>
&gt; &gt; &gt; diff --git a/drivers/md/bcache/btree.c b/drivers/md/bcache/b=
tree.c<br>
&gt; &gt; &gt; index 03e44c1..8b9c1a6 100644<br>
&gt; &gt; &gt; --- a/drivers/md/bcache/btree.c<br>
&gt; &gt; &gt; &#43;&#43;&#43; b/drivers/md/bcache/btree.c<br>
&gt; &gt; &gt; @@ -599,11 &#43;599,12 @@ static int mca_reap(struct btree *=
b, struct closure *cl, unsigned min_order)<br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp; return 0;<br>
&gt; &gt; &gt;&nbsp; }<br>
&gt; &gt; &gt;&nbsp; <br>
&gt; &gt; &gt; -static int bch_mca_shrink(struct shrinker *shrink, struct s=
hrink_control *sc)<br>
&gt; &gt; &gt; &#43;static long bch_mca_scan(struct shrinker *shrink, struc=
t shrink_control *sc)<br>
&gt; &gt; &gt;&nbsp; {<br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp; struct cache_set *c =3D container_of(shrin=
k, struct cache_set, shrink);<br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp; struct btree *b, *t;<br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp; unsigned long i, nr =3D sc-&gt;nr_to_scan;=
<br>
&gt; &gt; &gt; &#43; long freed =3D 0;<br>
&gt; &gt; &gt;&nbsp; <br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp; if (c-&gt;shrinker_disabled)<br>
&gt; &gt; &gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; return 0;<br>
&gt; &gt; <br>
&gt; &gt; -1 if shrinker disabled?<br>
&gt; &gt; <br>
&gt; &gt; Otherwise if the shrinker is disabled we ultimately hit this loop=
 in<br>
&gt; &gt; shrink_slab_one()<br>
&gt; <br>
&gt; My memory is very hazy on this stuff, but I recall there being another=
<br>
&gt; loop that'd just spin if we always returned -1.<br>
&gt; <br>
&gt; (It might've been /proc/sys/vm/drop_caches, or maybe that was another<=
br>
&gt; bug..)<br>
&gt; <br>
<br>
It might be worth chasing down what that bug was and fixing it.<br>
<br>
&gt; But 0 should certainly be safe - if we're always returning 0, then we'=
re<br>
&gt; claiming we don't have anything to shrink.<br>
&gt; <br>
<br>
It won't crash, but in Glauber's current code, it'll call you a few more<br=
>
times uselessly and the scanned statistics become misleading. I think<br>
Glauber/Dave's series is a big improvement over what we currently have<br>
and it would be nice to get it ironed out.<br>
<br>
-- <br>
Mel Gorman<br>
SUSE Labs<br>
</div>
</span></font>
</body>
</html>

--_000_xm7djq7r1xfsf4uo0hohgyxj1367501887374emailandroidcom_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
