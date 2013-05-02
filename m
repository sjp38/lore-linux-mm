Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 548D26B024C
	for <linux-mm@kvack.org>; Thu,  2 May 2013 00:57:52 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i13so107935qcs.1
        for <linux-mm@kvack.org>; Wed, 01 May 2013 21:57:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130501191033.GG1229@cmpxchg.org>
References: <516B9B57.6050308@redhat.com>
	<20130416075047.GA4184@osiris>
	<1638103518.2400447.1366266465689.JavaMail.root@redhat.com>
	<20130418071303.GB4203@osiris>
	<20130424104255.GC4350@osiris>
	<20130424131851.GC31960@dhcp22.suse.cz>
	<20130424152043.GP2018@cmpxchg.org>
	<alpine.LNX.2.00.1304242022200.16233@eggly.anvils>
	<20130430172711.GE1229@cmpxchg.org>
	<alpine.LNX.2.00.1305010758090.12051@eggly.anvils>
	<20130501191033.GG1229@cmpxchg.org>
Date: Wed, 1 May 2013 21:57:50 -0700
Message-ID: <CANsGZ6YoqrcOGJGJtLjccJ5S8-ObN=VRYP4OK_NgW0bGeqCt3A@mail.gmail.com>
Subject: Re: [v3.9-rc8]: kernel BUG at mm/memcontrol.c:3994! (was: Re:
 [BUG][s390x] mm: system crashed)
From: Hugh Dickins <hughd@google.com>
Content-Type: multipart/alternative; boundary=e89a8f64753f971e9e04dbb5131a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Zhouping Liu <zliu@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Lingzhu Xiang <lxiang@redhat.com>

--e89a8f64753f971e9e04dbb5131a
Content-Type: text/plain; charset=UTF-8

On Wed, May 1, 2013 at 12:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, May 01, 2013 at 08:28:30AM -0700, Hugh Dickins wrote:
> > On Tue, 30 Apr 2013, Johannes Weiner wrote:
> > > On Wed, Apr 24, 2013 at 08:50:01PM -0700, Hugh Dickins wrote:
> > > > On Wed, 24 Apr 2013, Johannes Weiner wrote:
> > > > > On Wed, Apr 24, 2013 at 03:18:51PM +0200, Michal Hocko wrote:
> > > > > > On Wed 24-04-13 12:42:55, Heiko Carstens wrote:
> > > > > > > On Thu, Apr 18, 2013 at 09:13:03AM +0200, Heiko Carstens wrote:
> > > > > > >
> > > > > > > [   48.347963] ------------[ cut here ]------------
> > > > > > > [   48.347972] kernel BUG at mm/memcontrol.c:3994!
> > > > > > > __mem_cgroup_uncharge_common() triggers:
> > > > > > >
> > > > > > > [...]
> > > > > > >         if (mem_cgroup_disabled())
> > > > > > >                 return NULL;
> > > > > > >
> > > > > > >         VM_BUG_ON(PageSwapCache(page));
> > > > > > > [...]
> > > >
> > > > I agree that the actual memcg uncharging should be okay, but the
> memsw
> > > > swap stats will go wrong (doesn't matter toooo much), and
> mem_cgroup_put
> > > > get missed (leaking a struct mem_cgroup).
> > >
> > > Ok, so I just went over this again.  For the swapout path the memsw
> > > uncharge is deferred, but if we "steal" this uncharge from the swap
> > > code, we actually do uncharge memsw in mem_cgroup_do_uncharge(), so we
> > > may prematurely unaccount the swap page, but we never leak a charge.
> > > Good.
> > >
> > > Because of this stealing, we also don't do the following:
> > >
> > >     if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> > >             mem_cgroup_swap_statistics(memcg, true);
> > >             mem_cgroup_get(memcg);
> > >     }
> > >
> > > I.e. it does not matter that mem_cgroup_uncharge_swap() doesn't do the
> > > put, we are also not doing the get.  We should not leak references.
> > >
> > > So the only thing that I can see go wrong is that we may have a
> > > swapped out page that is not charged to memsw and not accounted as
> > > MEM_CGROUP_STAT_SWAP.  But I don't know how likely that is, because we
> > > check for PG_swapcache in this uncharge path after the last pte is
> > > torn down, so even though the page is put on swap cache, it probably
> > > won't be swapped.  It would require that the PG_swapcache setting
> > > would become visible only after the page has been added to the swap
> > > cache AND rmap has established at least one swap pte for us to
> > > uncharge a page that actually continues to be used.  And that's a bit
> > > of a stretch, I think.
> >
> > Sorry, our minds seem to work in different ways,
> > I understood very little of what you wrote above :-(
> >
> > But once I try to disprove you with a counter-example, I seem to
> > arrive at the same conclusion as you have (well, I haven't quite
> > arrived there yet, but cannot give it any more time).
>
> I might be losing my mind.  But since you are reaching the same
> conclusion, and I see the same mental milestones in your thought
> process described below, it's more likely that I suck at describing my
> train of thought coherently.  Or the third possibility: we're both
> losing it!
>
> > Looking at it from my point of view, I concentrate on the racy
> >       if (PageSwapCache(page))
> >               return;
> >       __mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON,
> false);
> > in mem_cgroup_uncharge_page().
> >
> > Now, that may or may not catch the case where last reference to page
> > is unmapped at the same time as the page is added to swap: but being
> > a MEM_CGROUP_CHARGE_TYPE_ANON call, it does not interfere with the
> > memsw stats and get/put at all, those remain in balance.
>
> Yes, exactly.
>
> > And mem_cgroup_uncharge_swap() has all along been prepared to get
> > a zero id from swap_cgroup_record(), if a SwapCache page should be
> > uncharged when it was never quite charged as such.
> >
> > Yes, we may occasionally fail to charge a SwapCache page as such
> > if its final unmap from userspace races with its being added to swap;
> > but it's heading towards swap_writepage()'s try_to_free_swap() anyway,
> > so I don't think that's anything to worry about.
>
> Agreed as well.  If there are no pte references to the swap slot, it
> will be freed either way.  I didn't even think of the
> try_to_free_swap() in the writeout call, but was looking at the
> __remove_mapping later on in reclaim that will do a swapcache_free().
>
> The only case I was worried about is the following:
>
> #0                                      #1
> page_remove_rmap()                      shrink_page_list()
>   if --page->mapcount == 0:               add_to_swap()
>     mem_cgroup_uncharge_page()              __add_to_swap_cache()
>       if PageSwapCache:                       SetPageSwapCache()
>         return                            try_to_unmap()
>       __mem_cgroup_uncharge_common()        for each pte:
>                                               install swp_entry_t
>                                               page->mapcount--
>

Thanks for spelling it out for me in more detail, this time I think I do
grasp your concern.


>
> Looking at #1, I don't see anything that would force concurrent
> threads to observe SetSwapCache ordered against the page->mapcount--.
> My concern was that if those get reordered, #0 may see page->mapcount
> == 1 AND !PageSwapcache, and then go ahead and uncharge the page while
> there is actually a swp_entry_t pointing to it.  The page will be a
> proper long-term swap page without being charged as such.
>

But I don't see any problem with ordering here.  #0 is using an atomic
operation which returns a result on page->mapcount, so that amounts to
(more than) an smp_rmb ensuring it reads mapcount before reading
PageSwapCache flag.  And in #1, there's at least an unlock of the
radix_tree lock (after adding to swap tree) and a lock of the page table
lock (before unmapping the page), and that pairing amounts to (more than)
an smp_wmb.

Hugh


> > (If I had time to stop and read through that, I'd probably find it
> > just as hard to understand as what you wrote!)
> >
> > >
> > > Did I miss something?  If not, I'll just send a patch that removes the
> > > VM_BUG_ON() and adds a comment describing the scenarios and a note
> > > that we may want to fix this in the future.
> >
> > I don't think you missed something.  Yes, please just send Linus and
> > Andrew a patch to remove the VM_BUG_ON() (with Cc stable tag), I now
> > agree that's all that's really needed - thanks.
>
> Will do, thanks for taking them time to think through it again, even
> after failing to decipher my ramblings...
>
> Johannes
>

--e89a8f64753f971e9e04dbb5131a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Wed, May 1, 2013 at 12:10 PM, Johannes Weiner <span dir=
=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_blank">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><div class=3D"gmail_extra"><div class=
=3D"gmail_quote">
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On W=
ed, May 01, 2013 at 08:28:30AM -0700, Hugh Dickins wrote:<br>
&gt; On Tue, 30 Apr 2013, Johannes Weiner wrote:<br>
&gt; &gt; On Wed, Apr 24, 2013 at 08:50:01PM -0700, Hugh Dickins wrote:<br>
&gt; &gt; &gt; On Wed, 24 Apr 2013, Johannes Weiner wrote:<br>
&gt; &gt; &gt; &gt; On Wed, Apr 24, 2013 at 03:18:51PM +0200, Michal Hocko =
wrote:<br>
&gt; &gt; &gt; &gt; &gt; On Wed 24-04-13 12:42:55, Heiko Carstens wrote:<br=
>
&gt; &gt; &gt; &gt; &gt; &gt; On Thu, Apr 18, 2013 at 09:13:03AM +0200, Hei=
ko Carstens wrote:<br>
&gt; &gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; &gt; [ =C2=A0 48.347963] ------------[ cut here ]-=
-----------<br>
&gt; &gt; &gt; &gt; &gt; &gt; [ =C2=A0 48.347972] kernel BUG at mm/memcontr=
ol.c:3994!<br>
&gt; &gt; &gt; &gt; &gt; &gt; __mem_cgroup_uncharge_common() triggers:<br>
&gt; &gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; &gt; [...]<br>
&gt; &gt; &gt; &gt; &gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_di=
sabled())<br>
&gt; &gt; &gt; &gt; &gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return NULL;<br>
&gt; &gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(PageSwa=
pCache(page));<br>
&gt; &gt; &gt; &gt; &gt; &gt; [...]<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I agree that the actual memcg uncharging should be okay, but=
 the memsw<br>
&gt; &gt; &gt; swap stats will go wrong (doesn&#39;t matter toooo much), an=
d mem_cgroup_put<br>
&gt; &gt; &gt; get missed (leaking a struct mem_cgroup).<br>
&gt; &gt;<br>
&gt; &gt; Ok, so I just went over this again. =C2=A0For the swapout path th=
e memsw<br>
&gt; &gt; uncharge is deferred, but if we &quot;steal&quot; this uncharge f=
rom the swap<br>
&gt; &gt; code, we actually do uncharge memsw in mem_cgroup_do_uncharge(), =
so we<br>
&gt; &gt; may prematurely unaccount the swap page, but we never leak a char=
ge.<br>
&gt; &gt; Good.<br>
&gt; &gt;<br>
&gt; &gt; Because of this stealing, we also don&#39;t do the following:<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0 =C2=A0 if (do_swap_account &amp;&amp; ctype =3D=3D MEM_CGR=
OUP_CHARGE_TYPE_SWAPOUT) {<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_swap_statist=
ics(memcg, true);<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_get(memcg);<=
br>
&gt; &gt; =C2=A0 =C2=A0 }<br>
&gt; &gt;<br>
&gt; &gt; I.e. it does not matter that mem_cgroup_uncharge_swap() doesn&#39=
;t do the<br>
&gt; &gt; put, we are also not doing the get. =C2=A0We should not leak refe=
rences.<br>
&gt; &gt;<br>
&gt; &gt; So the only thing that I can see go wrong is that we may have a<b=
r>
&gt; &gt; swapped out page that is not charged to memsw and not accounted a=
s<br>
&gt; &gt; MEM_CGROUP_STAT_SWAP. =C2=A0But I don&#39;t know how likely that =
is, because we<br>
&gt; &gt; check for PG_swapcache in this uncharge path after the last pte i=
s<br>
&gt; &gt; torn down, so even though the page is put on swap cache, it proba=
bly<br>
&gt; &gt; won&#39;t be swapped. =C2=A0It would require that the PG_swapcach=
e setting<br>
&gt; &gt; would become visible only after the page has been added to the sw=
ap<br>
&gt; &gt; cache AND rmap has established at least one swap pte for us to<br=
>
&gt; &gt; uncharge a page that actually continues to be used. =C2=A0And tha=
t&#39;s a bit<br>
&gt; &gt; of a stretch, I think.<br>
&gt;<br>
&gt; Sorry, our minds seem to work in different ways,<br>
&gt; I understood very little of what you wrote above :-(<br>
&gt;<br>
&gt; But once I try to disprove you with a counter-example, I seem to<br>
&gt; arrive at the same conclusion as you have (well, I haven&#39;t quite<b=
r>
&gt; arrived there yet, but cannot give it any more time).<br>
<br>
</div></div>I might be losing my mind. =C2=A0But since you are reaching the=
 same<br>
conclusion, and I see the same mental milestones in your thought<br>
process described below, it&#39;s more likely that I suck at describing my<=
br>
train of thought coherently. =C2=A0Or the third possibility: we&#39;re both=
<br>
losing it!<br>
<div class=3D"im"><br>
&gt; Looking at it from my point of view, I concentrate on the racy<br>
&gt; =C2=A0 =C2=A0 =C2=A0 if (PageSwapCache(page))<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_uncharge_common(page, MEM_CGROUP_CHA=
RGE_TYPE_ANON, false);<br>
&gt; in mem_cgroup_uncharge_page().<br>
&gt;<br>
&gt; Now, that may or may not catch the case where last reference to page<b=
r>
&gt; is unmapped at the same time as the page is added to swap: but being<b=
r>
&gt; a MEM_CGROUP_CHARGE_TYPE_ANON call, it does not interfere with the<br>
&gt; memsw stats and get/put at all, those remain in balance.<br>
<br>
</div>Yes, exactly.<br>
<div class=3D"im"><br>
&gt; And mem_cgroup_uncharge_swap() has all along been prepared to get<br>
&gt; a zero id from swap_cgroup_record(), if a SwapCache page should be<br>
&gt; uncharged when it was never quite charged as such.<br>
&gt;<br>
&gt; Yes, we may occasionally fail to charge a SwapCache page as such<br>
&gt; if its final unmap from userspace races with its being added to swap;<=
br>
&gt; but it&#39;s heading towards swap_writepage()&#39;s try_to_free_swap()=
 anyway,<br>
&gt; so I don&#39;t think that&#39;s anything to worry about.<br>
<br>
</div>Agreed as well. =C2=A0If there are no pte references to the swap slot=
, it<br>
will be freed either way. =C2=A0I didn&#39;t even think of the<br>
try_to_free_swap() in the writeout call, but was looking at the<br>
__remove_mapping later on in reclaim that will do a swapcache_free().<br>
<br>
The only case I was worried about is the following:<br>
<br>
#0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0#1<br>
page_remove_rmap() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0shrink_page_list()<br>
=C2=A0 if --page-&gt;mapcount =3D=3D 0: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 add_to_swap()<br>
=C2=A0 =C2=A0 mem_cgroup_uncharge_page() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0__add_to_swap_cache()<br>
=C2=A0 =C2=A0 =C2=A0 if PageSwapCache: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageSwapCache()<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_unmap()<b=
r>
=C2=A0 =C2=A0 =C2=A0 __mem_cgroup_uncharge_common() =C2=A0 =C2=A0 =C2=A0 =
=C2=A0for each pte:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 install swp_entry_t<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 page-&gt;mapcount--<br></blockquote><div><br></div><div style=
>Thanks for spelling it out for me in more detail, this time I think I do g=
rasp your concern.</div><div style>=C2=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<br>
Looking at #1, I don&#39;t see anything that would force concurrent<br>
threads to observe SetSwapCache ordered against the page-&gt;mapcount--.<br=
>
My concern was that if those get reordered, #0 may see page-&gt;mapcount<br=
>
=3D=3D 1 AND !PageSwapcache, and then go ahead and uncharge the page while<=
br>
there is actually a swp_entry_t pointing to it. =C2=A0The page will be a<br=
>
proper long-term swap page without being charged as such.<br></blockquote><=
div><br></div><div style>But I don&#39;t see any problem with ordering here=
. =C2=A0#0 is using an atomic operation which returns a result on page-&gt;=
mapcount, so that amounts to (more than) an smp_rmb ensuring it reads mapco=
unt before reading PageSwapCache flag. =C2=A0And in #1, there&#39;s at leas=
t an unlock of the radix_tree lock (after adding to swap tree) and a lock o=
f the page table lock (before unmapping the page), and that pairing amounts=
 to (more than) an smp_wmb.</div>
<div style><br></div><div style>Hugh</div><div style><br></div><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex">
<div class=3D"im"><br>
&gt; (If I had time to stop and read through that, I&#39;d probably find it=
<br>
&gt; just as hard to understand as what you wrote!)<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; Did I miss something? =C2=A0If not, I&#39;ll just send a patch th=
at removes the<br>
&gt; &gt; VM_BUG_ON() and adds a comment describing the scenarios and a not=
e<br>
&gt; &gt; that we may want to fix this in the future.<br>
&gt;<br>
&gt; I don&#39;t think you missed something. =C2=A0Yes, please just send Li=
nus and<br>
&gt; Andrew a patch to remove the VM_BUG_ON() (with Cc stable tag), I now<b=
r>
&gt; agree that&#39;s all that&#39;s really needed - thanks.<br>
<br>
</div>Will do, thanks for taking them time to think through it again, even<=
br>
after failing to decipher my ramblings...<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Johannes<br>
</font></span></blockquote></div><br></div></div>

--e89a8f64753f971e9e04dbb5131a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
