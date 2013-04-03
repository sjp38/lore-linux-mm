Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 48D866B00AC
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 02:51:45 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id jk13so605345bkc.31
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 23:51:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364548450-28254-6-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
	<1364548450-28254-6-git-send-email-glommer@parallels.com>
Date: Wed, 3 Apr 2013 14:51:43 +0800
Message-ID: <CAFj3OHU_o5o_n_kcci1U_=M0tCpYEwy8abRvHKBdp-GoJ-cs3w@mail.gmail.com>
Subject: Re: [PATCH v2 05/28] dcache: remove dentries from LRU before putting
 on dispose list
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: multipart/alternative; boundary=14dae9c09d326dde6c04d96f49a8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, containers@lists.linux-foundation.org, Dave Chinner <dchinner@redhat.com>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

--14dae9c09d326dde6c04d96f49a8
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Mar 29, 2013 at 5:13 PM, Glauber Costa <glommer@parallels.com>wrote:

> From: Dave Chinner <dchinner@redhat.com>
>
> One of the big problems with modifying the way the dcache shrinker
> and LRU implementation works is that the LRU is abused in several
> ways. One of these is shrink_dentry_list().
>
> Basically, we can move a dentry off the LRU onto a different list
> without doing any accounting changes, and then use dentry_lru_prune()
> to remove it from what-ever list it is now on to do the LRU
> accounting at that point.
>
> This makes it -really hard- to change the LRU implementation. The
> use of the per-sb LRU lock serialises movement of the dentries
> between the different lists and the removal of them, and this is the
> only reason that it works. If we want to break up the dentry LRU
> lock and lists into, say, per-node lists, we remove the only
> serialisation that allows this lru list/dispose list abuse to work.
>
> To make this work effectively, the dispose list has to be isolated
> from the LRU list - dentries have to be removed from the LRU
> *before* being placed on the dispose list. This means that the LRU
> accounting and isolation is completed before disposal is started,
> and that means we can change the LRU implementation freely in
> future.
>
> This means that dentries *must* be marked with DCACHE_SHRINK_LIST
> when they are placed on the dispose list so that we don't think that
> parent dentries found in try_prune_one_dentry() are on the LRU when
> the are actually on the dispose list. This would result in
> accounting the dentry to the LRU a second time. Hence
> dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case
> differently because the dentry isn't on the LRU list.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/dcache.c | 73
> ++++++++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 63 insertions(+), 10 deletions(-)
>
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 0a1d7b3..d15420b 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -330,7 +330,6 @@ static void dentry_lru_add(struct dentry *dentry)
>  static void __dentry_lru_del(struct dentry *dentry)
>  {
>         list_del_init(&dentry->d_lru);
> -       dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>         dentry->d_sb->s_nr_dentry_unused--;
>         this_cpu_dec(nr_dentry_unused);
>  }
> @@ -340,6 +339,8 @@ static void __dentry_lru_del(struct dentry *dentry)
>   */
>  static void dentry_lru_del(struct dentry *dentry)
>  {
> +       BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
> +
>         if (!list_empty(&dentry->d_lru)) {
>                 spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>                 __dentry_lru_del(dentry);
> @@ -351,28 +352,42 @@ static void dentry_lru_del(struct dentry *dentry)
>   * Remove a dentry that is unreferenced and about to be pruned
>   * (unhashed and destroyed) from the LRU, and inform the file system.
>   * This wrapper should be called _prior_ to unhashing a victim dentry.
> + *
> + * Check that the dentry really is on the LRU as it may be on a private
> dispose
> + * list and in that case we do not want to call the generic LRU removal
> + * functions. This typically happens when shrink_dcache_sb() clears the
> LRU in
> + * one go and then try_prune_one_dentry() walks back up the parent chain
> finding
> + * dentries that are also on the dispose list.
>   */
>  static void dentry_lru_prune(struct dentry *dentry)
>  {
>         if (!list_empty(&dentry->d_lru)) {
> +
>                 if (dentry->d_flags & DCACHE_OP_PRUNE)
>                         dentry->d_op->d_prune(dentry);
>
> -               spin_lock(&dentry->d_sb->s_dentry_lru_lock);
> -               __dentry_lru_del(dentry);
> -               spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
> +               if ((dentry->d_flags & DCACHE_SHRINK_LIST))
> +                       list_del_init(&dentry->d_lru);
> +               else {
> +                       spin_lock(&dentry->d_sb->s_dentry_lru_lock);
> +                       __dentry_lru_del(dentry);
> +                       spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
> +               }
> +               dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>         }
>  }
>
>  static void dentry_lru_move_list(struct dentry *dentry, struct list_head
> *list)
>  {
> +       BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
> +
>         spin_lock(&dentry->d_sb->s_dentry_lru_lock);
>         if (list_empty(&dentry->d_lru)) {
>                 list_add_tail(&dentry->d_lru, list);
> -               dentry->d_sb->s_nr_dentry_unused++;
> -               this_cpu_inc(nr_dentry_unused);
>         } else {
>                 list_move_tail(&dentry->d_lru, list);
> +               dentry->d_sb->s_nr_dentry_unused--;
> +               this_cpu_dec(nr_dentry_unused);
>         }
>         spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
>  }
> @@ -814,12 +829,18 @@ static void shrink_dentry_list(struct list_head
> *list)
>                 }
>
>                 /*
> +                * The dispose list is isolated and dentries are not
> accounted
> +                * to the LRU here, so we can simply remove it from the
> list
> +                * here regardless of whether it is referenced or not.
> +                */
> +               list_del_init(&dentry->d_lru);
> +
> +               /*
>                  * We found an inuse dentry which was not removed from
> -                * the LRU because of laziness during lookup.  Do not free
> -                * it - just keep it off the LRU list.
> +                * the LRU because of laziness during lookup. Do not free
> it.
>                  */
>                 if (dentry->d_count) {
> -                       dentry_lru_del(dentry);
> +                       dentry->d_flags &= ~DCACHE_SHRINK_LIST;
>                         spin_unlock(&dentry->d_lock);
>                         continue;
>                 }
> @@ -871,6 +892,8 @@ relock:
>                 } else {
>                         list_move_tail(&dentry->d_lru, &tmp);
>                         dentry->d_flags |= DCACHE_SHRINK_LIST;
> +                       this_cpu_dec(nr_dentry_unused);
> +                       sb->s_nr_dentry_unused--;
>                         spin_unlock(&dentry->d_lock);
>                         if (!--count)
>                                 break;
> @@ -884,6 +907,28 @@ relock:
>         shrink_dentry_list(&tmp);
>  }
>
> +/*
> + * Mark all the dentries as on being the dispose list so we don't think
> they are
> + * still on the LRU if we try to kill them from ascending the parent
> chain in
> + * try_prune_one_dentry() rather than directly from the dispose list.
> + */
> +static void
> +shrink_dcache_list(
> +       struct list_head *dispose)
> +{
> +       struct dentry *dentry;
> +
> +       rcu_read_lock();
> +       list_for_each_entry_rcu(dentry, dispose, d_lru) {
> +               spin_lock(&dentry->d_lock);
> +               dentry->d_flags |= DCACHE_SHRINK_LIST;
> +               this_cpu_dec(nr_dentry_unused);
>

Why here dec nr_dentry_unused again? Has it been decreased in the following
shrink_dcache_sb()?



> +               spin_unlock(&dentry->d_lock);
> +       }
> +       rcu_read_unlock();
> +       shrink_dentry_list(dispose);
> +}
> +
>  /**
>   * shrink_dcache_sb - shrink dcache for a superblock
>   * @sb: superblock
> @@ -898,8 +943,16 @@ void shrink_dcache_sb(struct super_block *sb)
>         spin_lock(&sb->s_dentry_lru_lock);
>         while (!list_empty(&sb->s_dentry_lru)) {
>                 list_splice_init(&sb->s_dentry_lru, &tmp);
> +
> +               /*
> +                * account for removal here so we don't need to handle it
> later
> +                * even though the dentry is no longer on the lru list.
> +                */
> +               this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
> +               sb->s_nr_dentry_unused = 0;
> +
>                 spin_unlock(&sb->s_dentry_lru_lock);
> -               shrink_dentry_list(&tmp);
> +               shrink_dcache_list(&tmp);
>                 spin_lock(&sb->s_dentry_lru_lock);
>         }
>         spin_unlock(&sb->s_dentry_lru_lock);
>
>

-- 
Thanks,
Sha

--14dae9c09d326dde6c04d96f49a8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Fri, Mar 29, 2013 at 5:13 PM, Glauber Costa <span dir=3D"ltr">&l=
t;<a href=3D"mailto:glommer@parallels.com" target=3D"_blank">glommer@parall=
els.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">From: Dave Chinner &lt;<a href=3D"mailto:dch=
inner@redhat.com">dchinner@redhat.com</a>&gt;<br>
<br>
One of the big problems with modifying the way the dcache shrinker<br>
and LRU implementation works is that the LRU is abused in several<br>
ways. One of these is shrink_dentry_list().<br>
<br>
Basically, we can move a dentry off the LRU onto a different list<br>
without doing any accounting changes, and then use dentry_lru_prune()<br>
to remove it from what-ever list it is now on to do the LRU<br>
accounting at that point.<br>
<br>
This makes it -really hard- to change the LRU implementation. The<br>
use of the per-sb LRU lock serialises movement of the dentries<br>
between the different lists and the removal of them, and this is the<br>
only reason that it works. If we want to break up the dentry LRU<br>
lock and lists into, say, per-node lists, we remove the only<br>
serialisation that allows this lru list/dispose list abuse to work.<br>
<br>
To make this work effectively, the dispose list has to be isolated<br>
from the LRU list - dentries have to be removed from the LRU<br>
*before* being placed on the dispose list. This means that the LRU<br>
accounting and isolation is completed before disposal is started,<br>
and that means we can change the LRU implementation freely in<br>
future.<br>
<br>
This means that dentries *must* be marked with DCACHE_SHRINK_LIST<br>
when they are placed on the dispose list so that we don&#39;t think that<br=
>
parent dentries found in try_prune_one_dentry() are on the LRU when<br>
the are actually on the dispose list. This would result in<br>
accounting the dentry to the LRU a second time. Hence<br>
dentry_lru_prune() has to handle the DCACHE_SHRINK_LIST case<br>
differently because the dentry isn&#39;t on the LRU list.<br>
<br>
Signed-off-by: Dave Chinner &lt;<a href=3D"mailto:dchinner@redhat.com">dchi=
nner@redhat.com</a>&gt;<br>
---<br>
=A0fs/dcache.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++---=
------<br>
=A01 file changed, 63 insertions(+), 10 deletions(-)<br>
<br>
diff --git a/fs/dcache.c b/fs/dcache.c<br>
index 0a1d7b3..d15420b 100644<br>
--- a/fs/dcache.c<br>
+++ b/fs/dcache.c<br>
@@ -330,7 +330,6 @@ static void dentry_lru_add(struct dentry *dentry)<br>
=A0static void __dentry_lru_del(struct dentry *dentry)<br>
=A0{<br>
=A0 =A0 =A0 =A0 list_del_init(&amp;dentry-&gt;d_lru);<br>
- =A0 =A0 =A0 dentry-&gt;d_flags &amp;=3D ~DCACHE_SHRINK_LIST;<br>
=A0 =A0 =A0 =A0 dentry-&gt;d_sb-&gt;s_nr_dentry_unused--;<br>
=A0 =A0 =A0 =A0 this_cpu_dec(nr_dentry_unused);<br>
=A0}<br>
@@ -340,6 +339,8 @@ static void __dentry_lru_del(struct dentry *dentry)<br>
=A0 */<br>
=A0static void dentry_lru_del(struct dentry *dentry)<br>
=A0{<br>
+ =A0 =A0 =A0 BUG_ON(dentry-&gt;d_flags &amp; DCACHE_SHRINK_LIST);<br>
+<br>
=A0 =A0 =A0 =A0 if (!list_empty(&amp;dentry-&gt;d_lru)) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;dentry-&gt;d_sb-&gt;s_dentry=
_lru_lock);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dentry_lru_del(dentry);<br>
@@ -351,28 +352,42 @@ static void dentry_lru_del(struct dentry *dentry)<br>
=A0 * Remove a dentry that is unreferenced and about to be pruned<br>
=A0 * (unhashed and destroyed) from the LRU, and inform the file system.<br=
>
=A0 * This wrapper should be called _prior_ to unhashing a victim dentry.<b=
r>
+ *<br>
+ * Check that the dentry really is on the LRU as it may be on a private di=
spose<br>
+ * list and in that case we do not want to call the generic LRU removal<br=
>
+ * functions. This typically happens when shrink_dcache_sb() clears the LR=
U in<br>
+ * one go and then try_prune_one_dentry() walks back up the parent chain f=
inding<br>
+ * dentries that are also on the dispose list.<br>
=A0 */<br>
=A0static void dentry_lru_prune(struct dentry *dentry)<br>
=A0{<br>
=A0 =A0 =A0 =A0 if (!list_empty(&amp;dentry-&gt;d_lru)) {<br>
+<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dentry-&gt;d_flags &amp; DCACHE_OP_PRUN=
E)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_op-&gt;d_prune=
(dentry);<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;dentry-&gt;d_sb-&gt;s_dentry_l=
ru_lock);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dentry_lru_del(dentry);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt;d_sb-&gt;s_dentry=
_lru_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((dentry-&gt;d_flags &amp; DCACHE_SHRINK_L=
IST))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&amp;dentry-&gt=
;d_lru);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;dentry-&gt;d_s=
b-&gt;s_dentry_lru_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dentry_lru_del(dentry);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt;d=
_sb-&gt;s_dentry_lru_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_flags &amp;=3D ~DCACHE_SHRINK_LI=
ST;<br>
=A0 =A0 =A0 =A0 }<br>
=A0}<br>
<br>
=A0static void dentry_lru_move_list(struct dentry *dentry, struct list_head=
 *list)<br>
=A0{<br>
+ =A0 =A0 =A0 BUG_ON(dentry-&gt;d_flags &amp; DCACHE_SHRINK_LIST);<br>
+<br>
=A0 =A0 =A0 =A0 spin_lock(&amp;dentry-&gt;d_sb-&gt;s_dentry_lru_lock);<br>
=A0 =A0 =A0 =A0 if (list_empty(&amp;dentry-&gt;d_lru)) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&amp;dentry-&gt;d_lru, list);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_sb-&gt;s_nr_dentry_unused++;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_inc(nr_dentry_unused);<br>
=A0 =A0 =A0 =A0 } else {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;dentry-&gt;d_lru, list)=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_sb-&gt;s_nr_dentry_unused--;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_dec(nr_dentry_unused);<br>
=A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt;d_sb-&gt;s_dentry_lru_lock);<br=
>
=A0}<br>
@@ -814,12 +829,18 @@ static void shrink_dentry_list(struct list_head *list=
)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The dispose list is isolated and dentrie=
s are not accounted<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to the LRU here, so we can simply remove=
 it from the list<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* here regardless of whether it is referen=
ced or not.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del_init(&amp;dentry-&gt;d_lru);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We found an inuse dentry which was not=
 removed from<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the LRU because of laziness during looku=
p. =A0Do not free<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it - just keep it off the LRU list.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the LRU because of laziness during looku=
p. Do not free it.<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dentry-&gt;d_count) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry_lru_del(dentry);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_flags &amp;=3D ~=
DCACHE_SHRINK_LIST;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt=
;d_lock);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
@@ -871,6 +892,8 @@ relock:<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move_tail(&amp;dentry-=
&gt;d_lru, &amp;tmp);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_flags |=3D DCA=
CHE_SHRINK_LIST;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_dec(nr_dentry_unused=
);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sb-&gt;s_nr_dentry_unused--;<=
br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt=
;d_lock);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!--count)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
@@ -884,6 +907,28 @@ relock:<br>
=A0 =A0 =A0 =A0 shrink_dentry_list(&amp;tmp);<br>
=A0}<br>
<br>
+/*<br>
+ * Mark all the dentries as on being the dispose list so we don&#39;t thin=
k they are<br>
+ * still on the LRU if we try to kill them from ascending the parent chain=
 in<br>
+ * try_prune_one_dentry() rather than directly from the dispose list.<br>
+ */<br>
+static void<br>
+shrink_dcache_list(<br>
+ =A0 =A0 =A0 struct list_head *dispose)<br>
+{<br>
+ =A0 =A0 =A0 struct dentry *dentry;<br>
+<br>
+ =A0 =A0 =A0 rcu_read_lock();<br>
+ =A0 =A0 =A0 list_for_each_entry_rcu(dentry, dispose, d_lru) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;dentry-&gt;d_lock);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 dentry-&gt;d_flags |=3D DCACHE_SHRINK_LIST;<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_dec(nr_dentry_unused);<br></blockquo=
te><div><br></div><div>Why here dec nr_dentry_unused again? Has it been dec=
reased in the following shrink_dcache_sb()?<br><br></div><div>=A0</div><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex">

+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;dentry-&gt;d_lock);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 rcu_read_unlock();<br>
+ =A0 =A0 =A0 shrink_dentry_list(dispose);<br>
+}<br>
+<br>
=A0/**<br>
=A0 * shrink_dcache_sb - shrink dcache for a superblock<br>
=A0 * @sb: superblock<br>
@@ -898,8 +943,16 @@ void shrink_dcache_sb(struct super_block *sb)<br>
=A0 =A0 =A0 =A0 spin_lock(&amp;sb-&gt;s_dentry_lru_lock);<br>
=A0 =A0 =A0 =A0 while (!list_empty(&amp;sb-&gt;s_dentry_lru)) {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_splice_init(&amp;sb-&gt;s_dentry_lru, =
&amp;tmp);<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* account for removal here so we don&#39;t=
 need to handle it later<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* even though the dentry is no longer on t=
he lru list.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_sub(nr_dentry_unused, sb-&gt;s_nr_de=
ntry_unused);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 sb-&gt;s_nr_dentry_unused =3D 0;<br>
+<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;sb-&gt;s_dentry_lru_lock);=
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_dentry_list(&amp;tmp);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_dcache_list(&amp;tmp);<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;sb-&gt;s_dentry_lru_lock);<b=
r>
=A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 spin_unlock(&amp;sb-&gt;s_dentry_lru_lock);<br><span class=
=3D"HOEnZb"></span><br></blockquote></div><br clear=3D"all"><br>-- <br>Than=
ks,<br>Sha
</div></div>

--14dae9c09d326dde6c04d96f49a8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
