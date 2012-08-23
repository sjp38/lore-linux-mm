Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id B76606B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 19:07:40 -0400 (EDT)
Received: by lbon3 with SMTP id n3so927349lbo.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:07:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120816113805.5ae65af0@cuia.bos.redhat.com>
References: <20120816113450.52f4e633@cuia.bos.redhat.com>
	<20120816113805.5ae65af0@cuia.bos.redhat.com>
Date: Thu, 23 Aug 2012 16:07:38 -0700
Message-ID: <CALWz4iz4kxi=gasZsomqgKW+y4MgJEWMhefaiaBjO8Mktk932Q@mail.gmail.com>
Subject: Re: [RFC][PATCH -mm -v2 4/4] mm,vmscan: evict inactive file pages first
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=f46d0435c1d2f953aa04c7f6ece9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aquini@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

--f46d0435c1d2f953aa04c7f6ece9
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Aug 16, 2012 at 8:38 AM, Rik van Riel <riel@redhat.com> wrote:

> When a lot of streaming file IO is happening, it makes sense to
> evict just the inactive file pages and leave the other LRU lists
> alone.
>
> Likewise, when driving a cgroup hierarchy into its hard limit,
> or over its soft limit, it makes sense to pick a child cgroup
> that has lots of inactive file pages, and evict those first.
>
> Being over its soft limit is considered a stronger preference
> than just having a lot of inactive file pages, so a well behaved
> cgroup is allowed to keep its file cache when there is a "badly
> behaving" one in the same hierarchy.
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   37 +++++++++++++++++++++++++++++++++----
>  1 files changed, 33 insertions(+), 4 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 769fdcd..2884b4f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1576,6 +1576,19 @@ static int inactive_list_is_low(struct lruvec
> *lruvec, enum lru_list lru)
>                 return inactive_anon_is_low(lruvec);
>  }
>
> +/* If this lruvec has lots of inactive file pages, reclaim those only. */
> +static bool reclaim_file_only(struct lruvec *lruvec, struct scan_control
> *sc,
> +                             unsigned long anon, unsigned long file)
> +{
> +       if (inactive_file_is_low(lruvec))
> +               return false;
> +
> +       if (file > (anon + file) >> sc->priority)
> +               return true;
> +
> +       return false;
> +}
> +
>  static unsigned long shrink_list(enum lru_list lru, unsigned long
> nr_to_scan,
>                                  struct lruvec *lruvec, struct
> scan_control *sc)
>  {
> @@ -1658,6 +1671,14 @@ static void get_scan_count(struct lruvec *lruvec,
> struct scan_control *sc,
>                 }
>         }
>
> +       /* Lots of inactive file pages? Reclaim those only. */
> +       if (reclaim_file_only(lruvec, sc, anon, file)) {
> +               fraction[0] = 0;
> +               fraction[1] = 1;
> +               denominator = 1;
> +               goto out;
> +       }
> +
>         /*
>          * With swappiness at 100, anonymous and file have the same
> priority.
>          * This scanning priority is essentially the inverse of IO cost.
> @@ -1922,8 +1943,8 @@ static void age_recent_pressure(struct lruvec
> *lruvec, struct zone *zone)
>   * should always be larger than recent_rotated, and the size should
>   * always be larger than recent_pressure.
>   */
> -static u64 reclaim_score(struct mem_cgroup *memcg,
> -                        struct lruvec *lruvec)
> +static u64 reclaim_score(struct mem_cgroup *memcg, struct lruvec *lruvec,
> +                        struct scan_control *sc)
>  {
>         struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>         u64 anon, file;
> @@ -1949,6 +1970,14 @@ static u64 reclaim_score(struct mem_cgroup *memcg,
>                 anon *= 10000;
>         }
>
> +       /*
> +        * Prefer reclaiming from an lruvec with lots of inactive file
> +        * pages. Once those have been reclaimed, the score will drop so
> +        * far we will pick another lruvec to reclaim from.
> +        */
> +       if (reclaim_file_only(lruvec, sc, anon, file))
> +               file *= 100;
> +
>         return max(anon, file);
>  }
>
> @@ -1977,7 +2006,7 @@ static void shrink_zone(struct zone *zone, struct
> scan_control *sc)
>
>                 age_recent_pressure(lruvec, zone);
>
> -               score = reclaim_score(memcg, lruvec);
> +               score = reclaim_score(memcg, lruvec, sc);
>
>                 /* Pick the lruvec with the highest score. */
>                 if (score > max_score) {
> @@ -2002,7 +2031,7 @@ static void shrink_zone(struct zone *zone, struct
> scan_control *sc)
>          */
>         do {
>                 shrink_lruvec(victim_lruvec, sc);
> -               score = reclaim_score(memcg, victim_lruvec);
> +               score = reclaim_score(memcg, victim_lruvec, sc);
>

I wonder if you meant s/memcg/victim_memcg here.

--Ying


>         } while (sc->nr_to_reclaim > 0 && score > max_score / 2);
>
>         mem_cgroup_put(victim_memcg);
>
>

--f46d0435c1d2f953aa04c7f6ece9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Aug 16, 2012 at 8:38 AM, Rik van=
 Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com" target=3D"_b=
lank">riel@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x">
When a lot of streaming file IO is happening, it makes sense to<br>
evict just the inactive file pages and leave the other LRU lists<br>
alone.<br>
<br>
Likewise, when driving a cgroup hierarchy into its hard limit,<br>
or over its soft limit, it makes sense to pick a child cgroup<br>
that has lots of inactive file pages, and evict those first.<br>
<br>
Being over its soft limit is considered a stronger preference<br>
than just having a lot of inactive file pages, so a well behaved<br>
cgroup is allowed to keep its file cache when there is a &quot;badly<br>
behaving&quot; one in the same hierarchy.<br>
<br>
Signed-off-by: Rik van Riel &lt;<a href=3D"mailto:riel@redhat.com">riel@red=
hat.com</a>&gt;<br>
---<br>
=A0mm/vmscan.c | =A0 37 +++++++++++++++++++++++++++++++++----<br>
=A01 files changed, 33 insertions(+), 4 deletions(-)<br>
<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 769fdcd..2884b4f 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -1576,6 +1576,19 @@ static int inactive_list_is_low(struct lruvec *lruve=
c, enum lru_list lru)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return inactive_anon_is_low(lruvec);<br>
=A0}<br>
<br>
+/* If this lruvec has lots of inactive file pages, reclaim those only. */<=
br>
+static bool reclaim_file_only(struct lruvec *lruvec, struct scan_control *=
sc,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long ano=
n, unsigned long file)<br>
+{<br>
+ =A0 =A0 =A0 if (inactive_file_is_low(lruvec))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
+<br>
+ =A0 =A0 =A0 if (file &gt; (anon + file) &gt;&gt; sc-&gt;priority)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;<br>
+<br>
+ =A0 =A0 =A0 return false;<br>
+}<br>
+<br>
=A0static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_=
scan,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct l=
ruvec *lruvec, struct scan_control *sc)<br>
=A0{<br>
@@ -1658,6 +1671,14 @@ static void get_scan_count(struct lruvec *lruvec, st=
ruct scan_control *sc,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 }<br>
<br>
+ =A0 =A0 =A0 /* Lots of inactive file pages? Reclaim those only. */<br>
+ =A0 =A0 =A0 if (reclaim_file_only(lruvec, sc, anon, file)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 fraction[0] =3D 0;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 fraction[1] =3D 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 denominator =3D 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
+ =A0 =A0 =A0 }<br>
+<br>
=A0 =A0 =A0 =A0 /*<br>
=A0 =A0 =A0 =A0 =A0* With swappiness at 100, anonymous and file have the sa=
me priority.<br>
=A0 =A0 =A0 =A0 =A0* This scanning priority is essentially the inverse of I=
O cost.<br>
@@ -1922,8 +1943,8 @@ static void age_recent_pressure(struct lruvec *lruvec=
, struct zone *zone)<br>
=A0 * should always be larger than recent_rotated, and the size should<br>
=A0 * always be larger than recent_pressure.<br>
=A0 */<br>
-static u64 reclaim_score(struct mem_cgroup *memcg,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct lruvec *lruvec)<br>
+static u64 reclaim_score(struct mem_cgroup *memcg, struct lruvec *lruvec,<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct scan_control *sc)<b=
r>
=A0{<br>
=A0 =A0 =A0 =A0 struct zone_reclaim_stat *reclaim_stat =3D &amp;lruvec-&gt;=
reclaim_stat;<br>
=A0 =A0 =A0 =A0 u64 anon, file;<br>
@@ -1949,6 +1970,14 @@ static u64 reclaim_score(struct mem_cgroup *memcg,<b=
r>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 anon *=3D 10000;<br>
=A0 =A0 =A0 =A0 }<br>
<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* Prefer reclaiming from an lruvec with lots of inactive f=
ile<br>
+ =A0 =A0 =A0 =A0* pages. Once those have been reclaimed, the score will dr=
op so<br>
+ =A0 =A0 =A0 =A0* far we will pick another lruvec to reclaim from.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 if (reclaim_file_only(lruvec, sc, anon, file))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 file *=3D 100;<br>
+<br>
=A0 =A0 =A0 =A0 return max(anon, file);<br>
=A0}<br>
<br>
@@ -1977,7 +2006,7 @@ static void shrink_zone(struct zone *zone, struct sca=
n_control *sc)<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 age_recent_pressure(lruvec, zone);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 score =3D reclaim_score(memcg, lruvec);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 score =3D reclaim_score(memcg, lruvec, sc);<b=
r>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Pick the lruvec with the highest score. =
*/<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (score &gt; max_score) {<br>
@@ -2002,7 +2031,7 @@ static void shrink_zone(struct zone *zone, struct sca=
n_control *sc)<br>
=A0 =A0 =A0 =A0 =A0*/<br>
=A0 =A0 =A0 =A0 do {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_lruvec(victim_lruvec, sc);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 score =3D reclaim_score(memcg, victim_lruvec)=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 score =3D reclaim_score(memcg, victim_lruvec,=
 sc);<br></blockquote><div><br></div><div>I wonder if you meant s/memcg/vic=
tim_memcg here.</div><div><br></div><div>--Ying</div><div>=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex">

=A0 =A0 =A0 =A0 } while (sc-&gt;nr_to_reclaim &gt; 0 &amp;&amp; score &gt; =
max_score / 2);<br>
<br>
=A0 =A0 =A0 =A0 mem_cgroup_put(victim_memcg);<br>
<br>
</blockquote></div><br>

--f46d0435c1d2f953aa04c7f6ece9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
