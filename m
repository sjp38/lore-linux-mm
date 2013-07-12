Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7FEA86B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 09:13:58 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id it16so3792054bkc.27
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 06:13:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFj3OHV=6YDcbKmSeuF3+oMv1HfZF1RxXHoiLgTk0wH5cJVsiQ@mail.gmail.com>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
	<1373045623-27712-1-git-send-email-handai.szj@taobao.com>
	<20130711145625.GK21667@dhcp22.suse.cz>
	<CAFj3OHV=6YDcbKmSeuF3+oMv1HfZF1RxXHoiLgTk0wH5cJVsiQ@mail.gmail.com>
Date: Fri, 12 Jul 2013 21:13:56 +0800
Message-ID: <CAFj3OHXF+ZjnaDS2L6ZmuHPx20+7XC9r-s7Gh=_TYOr4Opr4Bw@mail.gmail.com>
Subject: Re: [PATCH V4 5/6] memcg: patch mem_cgroup_{begin,end}_update_page_stat()
 out if only root memcg exists
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: multipart/alternative; boundary=20cf302aceda7df8d604e15048fb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, glommer@gmail.com, Sha Zhengju <handai.szj@taobao.com>

--20cf302aceda7df8d604e15048fb
Content-Type: text/plain; charset=ISO-8859-1

Ooops.... it seems unreachable, change Glauber's email...


On Fri, Jul 12, 2013 at 8:59 PM, Sha Zhengju <handai.szj@gmail.com> wrote:

> Add cc to Glauber
>
>
> On Thu, Jul 11, 2013 at 10:56 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
> >> From: Sha Zhengju <handai.szj@taobao.com>
> >>
> >> If memcg is enabled and no non-root memcg exists, all allocated
> >> pages belongs to root_mem_cgroup and wil go through root memcg
> >> statistics routines.  So in order to reduce overheads after adding
> >> memcg dirty/writeback accounting in hot paths, we use jump label to
> >> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
> >> used.
> >
> > I do not think this is enough. How much do you save? One atomic read.
> > This doesn't seem like a killer.
> >
> > I hoped we could simply not account at all and move counters to the root
> > cgroup once the label gets enabled.
>
> I have thought of this approach before, but it would probably run into
> another issue, e.g, each zone has a percpu stock named ->pageset to
> optimize the increment and decrement operations, and I haven't figure out a
> simpler and cheaper approach to handle that stock numbers if moving global
> counters to root cgroup, maybe we can just leave them and can afford the
> approximation?
>
> Glauber have already done lots of works here, in his previous patchset he
> also tried to move some global stats to root (
> http://comments.gmane.org/gmane.linux.kernel.cgroups/6291). May I steal
> some of your ideas here, Glauber? :P
>
>
>
> >
> > Besides that, the current patch is racy. Consider what happens when:
> >
> > mem_cgroup_begin_update_page_stat
> >                                         arm_inuse_keys
> >
> mem_cgroup_move_account
> > mem_cgroup_move_account_page_stat
> > mem_cgroup_end_update_page_stat
> >
> > The race window is small of course but it is there. I guess we need
> > rcu_read_lock at least.
>
> Yes, you're right. I'm afraid we need to take care of the racy in the next
> updates as well. But mem_cgroup_begin/end_update_page_stat() already have
> rcu lock, so here we maybe only need a synchronize_rcu() after changing
> memcg_inuse_key?
>
>
> >
> >> If no non-root memcg comes to life, we do not need to accquire moving
> >> locks, so patch them out.
> >>
> >> cc: Michal Hocko <mhocko@suse.cz>
> >> cc: Greg Thelen <gthelen@google.com>
> >> cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> cc: Andrew Morton <akpm@linux-foundation.org>
> >> cc: Fengguang Wu <fengguang.wu@intel.com>
> >> cc: Mel Gorman <mgorman@suse.de>
> >> ---
> >>  include/linux/memcontrol.h |   15 +++++++++++++++
> >>  mm/memcontrol.c            |   23 ++++++++++++++++++++++-
> >>  2 files changed, 37 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> >> index ccd35d8..0483e1a 100644
> >> --- a/include/linux/memcontrol.h
> >> +++ b/include/linux/memcontrol.h
> >> @@ -55,6 +55,13 @@ struct mem_cgroup_reclaim_cookie {
> >>  };
> >>
> >>  #ifdef CONFIG_MEMCG
> >> +
> >> +extern struct static_key memcg_inuse_key;
> >> +static inline bool mem_cgroup_in_use(void)
> >> +{
> >> +     return static_key_false(&memcg_inuse_key);
> >> +}
> >> +
> >>  /*
> >>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
> >>   * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg
> doesn't
> >> @@ -159,6 +166,8 @@ static inline void
> mem_cgroup_begin_update_page_stat(struct page *page,
> >>  {
> >>       if (mem_cgroup_disabled())
> >>               return;
> >> +     if (!mem_cgroup_in_use())
> >> +             return;
> >>       rcu_read_lock();
> >>       *locked = false;
> >>       if (atomic_read(&memcg_moving))
> >> @@ -172,6 +181,8 @@ static inline void
> mem_cgroup_end_update_page_stat(struct page *page,
> >>  {
> >>       if (mem_cgroup_disabled())
> >>               return;
> >> +     if (!mem_cgroup_in_use())
> >> +             return;
> >>       if (*locked)
> >>               __mem_cgroup_end_update_page_stat(page, flags);
> >>       rcu_read_unlock();
> >> @@ -215,6 +226,10 @@ void mem_cgroup_print_bad_page(struct page *page);
> >>  #endif
> >>  #else /* CONFIG_MEMCG */
> >>  struct mem_cgroup;
> >> +static inline bool mem_cgroup_in_use(void)
> >> +{
> >> +     return false;
> >> +}
> >>
> >>  static inline int mem_cgroup_newpage_charge(struct page *page,
> >>                                       struct mm_struct *mm, gfp_t
> gfp_mask)
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 9126abc..a85f7c5 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -463,6 +463,13 @@ enum res_type {
> >>  #define MEM_CGROUP_RECLAIM_SHRINK_BIT        0x1
> >>  #define MEM_CGROUP_RECLAIM_SHRINK    (1 <<
> MEM_CGROUP_RECLAIM_SHRINK_BIT)
> >>
> >> +/* static_key used for marking memcg in use or not. We use this jump
> label to
> >> + * patch some memcg page stat accounting code in or out.
> >> + * The key will be increased when non-root memcg is created, and be
> decreased
> >> + * when memcg is destroyed.
> >> + */
> >> +struct static_key memcg_inuse_key;
> >> +
> >>  /*
> >>   * The memcg_create_mutex will be held whenever a new cgroup is
> created.
> >>   * As a consequence, any change that needs to protect against new
> child cgroups
> >> @@ -630,10 +637,22 @@ static void disarm_kmem_keys(struct mem_cgroup
> *memcg)
> >>  }
> >>  #endif /* CONFIG_MEMCG_KMEM */
> >>
> >> +static void disarm_inuse_keys(struct mem_cgroup *memcg)
> >> +{
> >> +     if (!mem_cgroup_is_root(memcg))
> >> +             static_key_slow_dec(&memcg_inuse_key);
> >> +}
> >> +
> >> +static void arm_inuse_keys(void)
> >> +{
> >> +     static_key_slow_inc(&memcg_inuse_key);
> >> +}
> >> +
> >>  static void disarm_static_keys(struct mem_cgroup *memcg)
> >>  {
> >>       disarm_sock_keys(memcg);
> >>       disarm_kmem_keys(memcg);
> >> +     disarm_inuse_keys(memcg);
> >>  }
> >>
> >>  static void drain_all_stock_async(struct mem_cgroup *memcg);
> >> @@ -2298,7 +2317,6 @@ void mem_cgroup_update_page_stat(struct page
> *page,
> >>  {
> >>       struct mem_cgroup *memcg;
> >>       struct page_cgroup *pc = lookup_page_cgroup(page);
> >> -     unsigned long uninitialized_var(flags);
> >>
> >>       if (mem_cgroup_disabled())
> >>               return;
> >> @@ -6293,6 +6311,9 @@ mem_cgroup_css_online(struct cgroup *cont)
> >>       }
> >>
> >>       error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> >> +     if (!error)
> >> +             arm_inuse_keys();
> >> +
> >>       mutex_unlock(&memcg_create_mutex);
> >>       return error;
> >>  }
> >> --
> >> 1.7.9.5
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > --
> > Michal Hocko
> > SUSE Labs
>
>
>
> --
> Thanks,
> Sha
>



-- 
Thanks,
Sha

--20cf302aceda7df8d604e15048fb
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Ooops.... it seems unreachable, change Glauber&#39;s email=
...<br><div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">O=
n Fri, Jul 12, 2013 at 8:59 PM, Sha Zhengju <span dir=3D"ltr">&lt;<a href=
=3D"mailto:handai.szj@gmail.com" target=3D"_blank">handai.szj@gmail.com</a>=
&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div dir=3D"ltr"><div>Add cc to Glauber<div =
class=3D"im"><br><br>On Thu, Jul 11, 2013 at 10:56 PM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@suse.cz" target=3D"_blank">mhocko@suse.cz</a>&gt; wro=
te:<br>
&gt; On Sat 06-07-13 01:33:43, Sha Zhengju wrote:<br>&gt;&gt; From: Sha Zhe=
ngju &lt;<a href=3D"mailto:handai.szj@taobao.com" target=3D"_blank">handai.=
szj@taobao.com</a>&gt;<br>
&gt;&gt;<br>&gt;&gt; If memcg is enabled and no non-root memcg exists, all =
allocated<br>&gt;&gt; pages belongs to root_mem_cgroup and wil go through r=
oot memcg<br>&gt;&gt; statistics routines. =A0So in order to reduce overhea=
ds after adding<br>

&gt;&gt; memcg dirty/writeback accounting in hot paths, we use jump label t=
o<br>&gt;&gt; patch mem_cgroup_{begin,end}_update_page_stat() in or out whe=
n not<br>&gt;&gt; used.<br>&gt;<br>&gt; I do not think this is enough. How =
much do you save? One atomic read.<br>

&gt; This doesn&#39;t seem like a killer.<br>&gt;<br>&gt; I hoped we could =
simply not account at all and move counters to the root<br>&gt; cgroup once=
 the label gets enabled.<br><br></div>I have thought of this approach befor=
e, but it would probably run into another issue, e.g, each zone has a percp=
u stock named -&gt;pageset to optimize the increment and decrement operatio=
ns, and I haven&#39;t figure out a simpler and cheaper approach to handle t=
hat stock numbers if moving global counters to root cgroup, maybe we can ju=
st leave them and can afford the approximation?<br>

<br>Glauber have already done lots of works here, in his previous patchset =
he also tried to move some global stats to root (<a href=3D"http://comments=
.gmane.org/gmane.linux.kernel.cgroups/6291" target=3D"_blank">http://commen=
ts.gmane.org/gmane.linux.kernel.cgroups/6291</a>). May I steal some of your=
 <span></span><span></span> ideas here, Glauber? :P<div class=3D"im">
<br>
<br><br>&gt;<br>&gt; Besides that, the current patch is racy. Consider what=
 happens when:<br>&gt;<br>&gt; mem_cgroup_begin_update_page_stat<br>&gt; =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 arm_inuse_keys<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup=
_move_account<br>

&gt; mem_cgroup_move_account_page_stat<br>&gt; mem_cgroup_end_update_page_s=
tat<br>&gt;<br>&gt; The race window is small of course but it is there. I g=
uess we need<br>&gt; rcu_read_lock at least.<br><br></div></div>Yes, you&#3=
9;re right. I&#39;m afraid we need to take care of the racy in the next upd=
ates as well. But mem_cgroup_begin/end_update_page_stat() already have rcu =
lock, so here we maybe only need a synchronize_rcu() after changing memcg_i=
nuse_key? <br>

<div><br><div><div><div class=3D"h5"><br>&gt;<br>&gt;&gt; If no non-root me=
mcg comes to life, we do not need to accquire moving<br>&gt;&gt; locks, so =
patch them out.<br>&gt;&gt;<br>&gt;&gt; cc: Michal Hocko &lt;<a href=3D"mai=
lto:mhocko@suse.cz" target=3D"_blank">mhocko@suse.cz</a>&gt;<br>

&gt;&gt; cc: Greg Thelen &lt;<a href=3D"mailto:gthelen@google.com" target=
=3D"_blank">gthelen@google.com</a>&gt;<br>&gt;&gt; cc: KAMEZAWA Hiroyuki &l=
t;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com" target=3D"_blank">kamez=
awa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt;&gt; cc: Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org"=
 target=3D"_blank">akpm@linux-foundation.org</a>&gt;<br>
&gt;&gt; cc: Fengguang Wu &lt;<a href=3D"mailto:fengguang.wu@intel.com" tar=
get=3D"_blank">fengguang.wu@intel.com</a>&gt;<br>&gt;&gt; cc: Mel Gorman &l=
t;<a href=3D"mailto:mgorman@suse.de" target=3D"_blank">mgorman@suse.de</a>&=
gt;<br>
&gt;&gt; ---<br>&gt;&gt; =A0include/linux/memcontrol.h | =A0 15 +++++++++++=
++++<br>
&gt;&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 23 +++++++++++++++=
+++++++-<br>&gt;&gt; =A02 files changed, 37 insertions(+), 1 deletion(-)<br=
>&gt;&gt;<br>&gt;&gt; diff --git a/include/linux/memcontrol.h b/include/lin=
ux/memcontrol.h<br>

&gt;&gt; index ccd35d8..0483e1a 100644<br>&gt;&gt; --- a/include/linux/memc=
ontrol.h<br>&gt;&gt; +++ b/include/linux/memcontrol.h<br>&gt;&gt; @@ -55,6 =
+55,13 @@ struct mem_cgroup_reclaim_cookie {<br>&gt;&gt; =A0};<br>&gt;&gt;<=
br>

&gt;&gt; =A0#ifdef CONFIG_MEMCG<br>&gt;&gt; +<br>&gt;&gt; +extern struct st=
atic_key memcg_inuse_key;<br>&gt;&gt; +static inline bool mem_cgroup_in_use=
(void)<br>&gt;&gt; +{<br>&gt;&gt; + =A0 =A0 return static_key_false(&amp;me=
mcg_inuse_key);<br>

&gt;&gt; +}<br>&gt;&gt; +<br>&gt;&gt; =A0/*<br>&gt;&gt; =A0 * All &quot;cha=
rge&quot; functions with gfp_mask should use GFP_KERNEL or<br>&gt;&gt; =A0 =
* (gfp_mask &amp; GFP_RECLAIM_MASK). In current implementatin, memcg doesn&=
#39;t<br>

&gt;&gt; @@ -159,6 +166,8 @@ static inline void mem_cgroup_begin_update_pag=
e_stat(struct page *page,<br>&gt;&gt; =A0{<br>&gt;&gt; =A0 =A0 =A0 if (mem_=
cgroup_disabled())<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&=
gt; + =A0 =A0 if (!mem_cgroup_in_use())<br>

&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&gt; =A0 =A0 =A0 rcu_read=
_lock();<br>&gt;&gt; =A0 =A0 =A0 *locked =3D false;<br>&gt;&gt; =A0 =A0 =A0=
 if (atomic_read(&amp;memcg_moving))<br>&gt;&gt; @@ -172,6 +181,8 @@ static=
 inline void mem_cgroup_end_update_page_stat(struct page *page,<br>

&gt;&gt; =A0{<br>&gt;&gt; =A0 =A0 =A0 if (mem_cgroup_disabled())<br>&gt;&gt=
; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&gt; + =A0 =A0 if (!mem_cgroup=
_in_use())<br>&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&gt; =A0 =
=A0 =A0 if (*locked)<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_e=
nd_update_page_stat(page, flags);<br>

&gt;&gt; =A0 =A0 =A0 rcu_read_unlock();<br>&gt;&gt; @@ -215,6 +226,10 @@ vo=
id mem_cgroup_print_bad_page(struct page *page);<br>&gt;&gt; =A0#endif<br>&=
gt;&gt; =A0#else /* CONFIG_MEMCG */<br>&gt;&gt; =A0struct mem_cgroup;<br>&g=
t;&gt; +static inline bool mem_cgroup_in_use(void)<br>

&gt;&gt; +{<br>&gt;&gt; + =A0 =A0 return false;<br>&gt;&gt; +}<br>&gt;&gt;<=
br>&gt;&gt; =A0static inline int mem_cgroup_newpage_charge(struct page *pag=
e,<br>&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct mm_struct *mm, gfp_t gfp_mask)<br>

&gt;&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>&gt;&gt; index 9=
126abc..a85f7c5 100644<br>&gt;&gt; --- a/mm/memcontrol.c<br>&gt;&gt; +++ b/=
mm/memcontrol.c<br>&gt;&gt; @@ -463,6 +463,13 @@ enum res_type {<br>&gt;&gt=
; =A0#define MEM_CGROUP_RECLAIM_SHRINK_BIT =A0 =A0 =A0 =A00x1<br>

&gt;&gt; =A0#define MEM_CGROUP_RECLAIM_SHRINK =A0 =A0(1 &lt;&lt; MEM_CGROUP=
_RECLAIM_SHRINK_BIT)<br>&gt;&gt;<br>&gt;&gt; +/* static_key used for markin=
g memcg in use or not. We use this jump label to<br>&gt;&gt; + * patch some=
 memcg page stat accounting code in or out.<br>

&gt;&gt; + * The key will be increased when non-root memcg is created, and =
be decreased<br>&gt;&gt; + * when memcg is destroyed.<br>&gt;&gt; + */<br>&=
gt;&gt; +struct static_key memcg_inuse_key;<br>&gt;&gt; +<br>&gt;&gt; =A0/*=
<br>

&gt;&gt; =A0 * The memcg_create_mutex will be held whenever a new cgroup is=
 created.<br>&gt;&gt; =A0 * As a consequence, any change that needs to prot=
ect against new child cgroups<br>&gt;&gt; @@ -630,10 +637,22 @@ static void=
 disarm_kmem_keys(struct mem_cgroup *memcg)<br>

&gt;&gt; =A0}<br>&gt;&gt; =A0#endif /* CONFIG_MEMCG_KMEM */<br>&gt;&gt;<br>=
&gt;&gt; +static void disarm_inuse_keys(struct mem_cgroup *memcg)<br>&gt;&g=
t; +{<br>&gt;&gt; + =A0 =A0 if (!mem_cgroup_is_root(memcg))<br>&gt;&gt; + =
=A0 =A0 =A0 =A0 =A0 =A0 static_key_slow_dec(&amp;memcg_inuse_key);<br>

&gt;&gt; +}<br>&gt;&gt; +<br>&gt;&gt; +static void arm_inuse_keys(void)<br>=
&gt;&gt; +{<br>&gt;&gt; + =A0 =A0 static_key_slow_inc(&amp;memcg_inuse_key)=
;<br>&gt;&gt; +}<br>&gt;&gt; +<br>&gt;&gt; =A0static void disarm_static_key=
s(struct mem_cgroup *memcg)<br>

&gt;&gt; =A0{<br>&gt;&gt; =A0 =A0 =A0 disarm_sock_keys(memcg);<br>&gt;&gt; =
=A0 =A0 =A0 disarm_kmem_keys(memcg);<br>&gt;&gt; + =A0 =A0 disarm_inuse_key=
s(memcg);<br>&gt;&gt; =A0}<br>&gt;&gt;<br>&gt;&gt; =A0static void drain_all=
_stock_async(struct mem_cgroup *memcg);<br>

&gt;&gt; @@ -2298,7 +2317,6 @@ void mem_cgroup_update_page_stat(struct page=
 *page,<br>&gt;&gt; =A0{<br>&gt;&gt; =A0 =A0 =A0 struct mem_cgroup *memcg;<=
br>&gt;&gt; =A0 =A0 =A0 struct page_cgroup *pc =3D lookup_page_cgroup(page)=
;<br>&gt;&gt; - =A0 =A0 unsigned long uninitialized_var(flags);<br>

&gt;&gt;<br>&gt;&gt; =A0 =A0 =A0 if (mem_cgroup_disabled())<br>&gt;&gt; =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>&gt;&gt; @@ -6293,6 +6311,9 @@ mem_cgro=
up_css_online(struct cgroup *cont)<br>&gt;&gt; =A0 =A0 =A0 }<br>&gt;&gt;<br=
>&gt;&gt; =A0 =A0 =A0 error =3D memcg_init_kmem(memcg, &amp;mem_cgroup_subs=
ys);<br>

&gt;&gt; + =A0 =A0 if (!error)<br>&gt;&gt; + =A0 =A0 =A0 =A0 =A0 =A0 arm_in=
use_keys();<br>&gt;&gt; +<br>&gt;&gt; =A0 =A0 =A0 mutex_unlock(&amp;memcg_c=
reate_mutex);<br>&gt;&gt; =A0 =A0 =A0 return error;<br>&gt;&gt; =A0}<br>&gt=
;&gt; --<br>&gt;&gt; 1.7.9.5<br>

&gt;&gt;<br>&gt;&gt; --<br>&gt;&gt; To unsubscribe from this list: send the=
 line &quot;unsubscribe cgroups&quot; in<br>&gt;&gt; the body of a message =
to <a href=3D"mailto:majordomo@vger.kernel.org" target=3D"_blank">majordomo=
@vger.kernel.org</a><br>

&gt;&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majord=
omo-info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html=
</a><br>&gt;<br>&gt; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs<br><br><br><=
br>
</div></div>--<br>Thanks,<br>
Sha</div></div></div>
</blockquote></div><br><br clear=3D"all"><br>-- <br>Thanks,<br>Sha
</div></div></div>

--20cf302aceda7df8d604e15048fb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
