Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D18816B0005
	for <linux-mm@kvack.org>; Fri,  1 Jun 2018 19:34:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k27-v6so19312526wre.23
        for <linux-mm@kvack.org>; Fri, 01 Jun 2018 16:34:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n128-v6sor797098wma.46.2018.06.01.16.34.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 01 Jun 2018 16:34:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com>
References: <CAKYffwqAXWUhdmU7t+OzK1A2oODS+WsfMKJZyWVTwxzR2QbHbw@mail.gmail.com>
 <55be03eb-3d0d-d43d-b0a4-669341e6d9ab@redhat.com> <CAGXu5jKYsS2jnRcb9RhFwvB-FLdDhVyAf+=CZ0WFB9UwPdefpw@mail.gmail.com>
 <20180601205837.GB29651@bombadil.infradead.org> <CAGXu5jLvN5bmakZ3aDu4TRB9+_DYVaCX2LTLtKvsqgYpjMaNsA@mail.gmail.com>
From: Anton Eidelman <anton@lightbitslabs.com>
Date: Fri, 1 Jun 2018 16:34:01 -0700
Message-ID: <CAKYffwpAAgD+a+0kebid43tpyS6L+8o=4hBbDvhfgaoV_gze1g@mail.gmail.com>
Subject: Re: HARDENED_USERCOPY will BUG on multiple slub objects coalesced
 into an sk_buff fragment
Content-Type: multipart/alternative; boundary="000000000000e771d7056d9d044a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, linux-hardened@lists.openwall.com

--000000000000e771d7056d9d044a
Content-Type: text/plain; charset="UTF-8"

Hi all,

I do not have a way of reproducing this decent enough to recommend: I'll
keep digging.

The page belongs to a slub when the fragment is being constructed in
__skb_fill_page_desc(), see the instrumentation I used below.
When usercopy triggers, .coals shows values of 2/3 for 128/192 bytes
respectively.

The question is how the RX sk_buff ends up having data fragment in a
PageSlab page.
Some network drivers use netdev_alloc_frag() so pages indeed come
from page_frag allocator.
Others (mellanox, intel) just alloc_page() when filling their RX
descriptors.
In both cases the pages will be refcounted properly.

I suspect my kernel TCP traffic that uses kernel_sendpage() for bio pages
AND slub pages.

Thanks a lot!
Anton
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a098d95..7cd744c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -40,6 +40,7 @@
 #include <linux/in6.h>
 #include <linux/if_packet.h>
 #include <net/flow.h>
+#include <linux/slub_def.h>

 /* The interface for checksum offload between the stack and networking
drivers
  * is as follows...
@@ -316,7 +317,8 @@ struct skb_frag_struct {
        } page;
 #if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
        __u32 page_offset;
-       __u32 size;
+       __u16 size;
+       __u16 coals;
 #else
        __u16 page_offset;
        __u16 size;
@@ -1850,9 +1852,11 @@ static inline void __skb_fill_page_desc(struct
sk_buff *skb, int i,
         */
        frag->page.p              = page;
        frag->page_offset         = off;
+       frag->coals               = 0;
        skb_frag_size_set(frag, size);

        page = compound_head(page);
+       *WARN_ON(PageSlab(page) && (page->slab_cache->size < size)); //
does NOT trigger*
        if (page_is_pfmemalloc(page))
                skb->pfmemalloc = true;
 }
@@ -2849,10 +2853,14 @@ static inline bool skb_can_coalesce(struct sk_buff
*skb, int i,
                                    const struct page *page, int off)
 {
        if (i) {
-               const struct skb_frag_struct *frag =
&skb_shinfo(skb)->frags[i - 1];
+               struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i -
1];

-               return page == skb_frag_page(frag) &&
+               bool ret = page == skb_frag_page(frag) &&
                       off == frag->page_offset + skb_frag_size(frag);
+               if (unlikely(ret))
*+                       if (PageSlab(compound_head((struct page *)page)))*
*+                               frag->coals++;*
+               return ret;
        }
        return false;
 }


On Fri, Jun 1, 2018 at 2:55 PM, Kees Cook <keescook@chromium.org> wrote:

> On Fri, Jun 1, 2018 at 1:58 PM, Matthew Wilcox <willy@infradead.org>
> wrote:
> > On Fri, Jun 01, 2018 at 01:49:38PM -0700, Kees Cook wrote:
> >> On Fri, Jun 1, 2018 at 12:02 PM, Laura Abbott <labbott@redhat.com>
> wrote:
> >> > (cc-ing some interested people)
> >> >
> >> >
> >> >
> >> > On 05/31/2018 05:03 PM, Anton Eidelman wrote:
> >> >> Here's a rare issue I reproduce on 4.12.10 (centos config): full log
> >> >> sample below.
> >>
> >> Thanks for digging into this! Do you have any specific reproducer for
> >> this? If so, I'd love to try a bisection, as I'm surprised this has
> >> only now surfaced: hardened usercopy was introduced in 4.8 ...
> >>
> >> >> An innocent process (dhcpclient) is about to receive a datagram, but
> >> >> during skb_copy_datagram_iter() usercopy triggers a BUG in:
> >> >> usercopy.c:check_heap_object() -> slub.c:__check_heap_object(),
> because
> >> >> the sk_buff fragment being copied crosses the 64-byte slub object
> boundary.
> >> >>
> >> >> Example __check_heap_object() context:
> >> >>    n=128    << usually 128, sometimes 192.
> >> >>    object_size=64
> >> >>    s->size=64
> >> >>    page_address(page)=0xffff880233f7c000
> >> >>    ptr=0xffff880233f7c540
> >> >>
> >> >> My take on the root cause:
> >> >>    When adding data to an skb, new data is appended to the current
> >> >> fragment if the new chunk immediately follows the last one: by simply
> >> >> increasing the frag->size, skb_frag_size_add().
> >> >>    See include/linux/skbuff.h:skb_can_coalesce() callers.
> >>
> >> Oooh, sneaky:
> >>                 return page == skb_frag_page(frag) &&
> >>                        off == frag->page_offset + skb_frag_size(frag);
> >>
> >> Originally I was thinking that slab red-zoning would get triggered
> >> too, but I see the above is checking to see if these are precisely
> >> neighboring allocations, I think.
> >>
> >> But then ... how does freeing actually work? I'm really not sure how
> >> this seeming layering violation could be safe in other areas?
> >
> > I'm confused ... I thought skb frags came from the page_frag allocator,
> > not the slab allocator.  But then why would the slab hardening trigger?
>
> Well that would certainly make more sense (well, the sense about
> alloc/free). Having it overlap with a slab allocation, though, that's
> quite bad. Perhaps this is a very odd use-after-free case? I.e. freed
> page got allocated to slab, and when it got copied out, usercopy found
> it spanned a slub object?
>
> [ 655.602500] usercopy: kernel memory exposure attempt detected from
> ffff88022a31aa00 (kmalloc-64) (192 bytes)
>
> This wouldn't be the first time usercopy triggered due to a memory
> corruption...
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--000000000000e771d7056d9d044a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi all,<div><br></div><div>I do not have a way of reproduc=
ing this decent enough to recommend: I&#39;ll keep digging.</div><div><br><=
/div><div>The page belongs to a slub when the fragment is being constructed=
<span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:s=
mall;font-style:normal;font-variant-ligatures:normal;font-variant-caps:norm=
al;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0px;t=
ext-transform:none;white-space:normal;word-spacing:0px;background-color:rgb=
(255,255,255);text-decoration-style:initial;text-decoration-color:initial;f=
loat:none;display:inline"><span>=C2=A0</span>in=C2=A0</span><span style=3D"=
color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-style=
:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:=
400;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:n=
one;white-space:normal;word-spacing:0px;text-decoration-style:initial;text-=
decoration-color:initial;background-color:rgb(255,255,255);float:none;displ=
ay:inline">__skb_fill_page_desc(),=C2=A0</span>see the instrumentation I us=
ed below.</div><div>When usercopy triggers, .coals shows values of 2/3 for =
128/192 bytes respectively.</div><div><span style=3D"color:rgb(34,34,34);fo=
nt-family:arial,sans-serif;font-size:small;font-style:normal;font-variant-l=
igatures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:nor=
mal;text-align:start;text-indent:0px;text-transform:none;white-space:normal=
;word-spacing:0px;text-decoration-style:initial;text-decoration-color:initi=
al;background-color:rgb(255,255,255);float:none;display:inline"><br></span>=
</div><div><span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;=
font-size:small;font-style:normal;font-variant-ligatures:normal;font-varian=
t-caps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-i=
ndent:0px;text-transform:none;white-space:normal;word-spacing:0px;text-deco=
ration-style:initial;text-decoration-color:initial;background-color:rgb(255=
,255,255);float:none;display:inline">The question is how the RX sk_buff end=
s up having data fragment in a PageSlab page.</span></div><div><span style=
=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-s=
tyle:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-wei=
ght:400;letter-spacing:normal;text-align:start;text-indent:0px;text-transfo=
rm:none;white-space:normal;word-spacing:0px;text-decoration-style:initial;t=
ext-decoration-color:initial;background-color:rgb(255,255,255);float:none;d=
isplay:inline">Some network drivers use=C2=A0netdev_alloc_frag() so pages i=
ndeed come from=C2=A0page_frag allocator.</span></div><div><span style=3D"c=
olor:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-style:=
normal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:4=
00;letter-spacing:normal;text-align:start;text-indent:0px;text-transform:no=
ne;white-space:normal;word-spacing:0px;text-decoration-style:initial;text-d=
ecoration-color:initial;background-color:rgb(255,255,255);float:none;displa=
y:inline">Others (mellanox, intel) just=C2=A0alloc_page() when filling thei=
r RX descriptors.</span></div><div><span style=3D"color:rgb(34,34,34);font-=
family:arial,sans-serif;font-size:small;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;text-decoration-style:initial;text-decoration-color:initial;=
background-color:rgb(255,255,255);float:none;display:inline">In both cases =
the pages will be refcounted properly.</span></div><div><span style=3D"colo=
r:rgb(34,34,34);font-family:arial,sans-serif;font-size:small;font-style:nor=
mal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;=
letter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;=
white-space:normal;word-spacing:0px;text-decoration-style:initial;text-deco=
ration-color:initial;background-color:rgb(255,255,255);float:none;display:i=
nline"><br></span></div><div><span style=3D"color:rgb(34,34,34);font-family=
:arial,sans-serif;font-size:small;font-style:normal;font-variant-ligatures:=
normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-=
align:start;text-indent:0px;text-transform:none;white-space:normal;word-spa=
cing:0px;text-decoration-style:initial;text-decoration-color:initial;backgr=
ound-color:rgb(255,255,255);float:none;display:inline">I suspect my kernel =
TCP traffic that uses kernel_sendpage() for bio pages AND slub pages.</span=
></div><div><br></div><div>Thanks a lot!</div><div>Anton</div><div><div>dif=
f --git a/include/linux/skbuff.h b/include/linux/skbuff.h</div><div>index a=
098d95..7cd744c 100644</div><div>--- a/include/linux/skbuff.h</div><div>+++=
 b/include/linux/skbuff.h</div><div>@@ -40,6 +40,7 @@</div><div>=C2=A0#incl=
ude &lt;linux/in6.h&gt;</div><div>=C2=A0#include &lt;linux/if_packet.h&gt;<=
/div><div>=C2=A0#include &lt;net/flow.h&gt;</div><div>+#include &lt;linux/s=
lub_def.h&gt;</div><div>=C2=A0</div><div>=C2=A0/* The interface for checksu=
m offload between the stack and networking drivers</div><div>=C2=A0 * is as=
 follows...</div><div>@@ -316,7 +317,8 @@ struct skb_frag_struct {</div><di=
v>=C2=A0 =C2=A0 =C2=A0 =C2=A0 } page;</div><div>=C2=A0#if (BITS_PER_LONG &g=
t; 32) || (PAGE_SIZE &gt;=3D 65536)</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 _=
_u32 page_offset;</div><div>-=C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 size;</div><d=
iv>+=C2=A0 =C2=A0 =C2=A0 =C2=A0__u16 size;</div><div>+=C2=A0 =C2=A0 =C2=A0 =
=C2=A0__u16 coals;</div><div>=C2=A0#else</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __u16 page_offset;</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 __u16 size;</d=
iv><div>@@ -1850,9 +1852,11 @@ static inline void __skb_fill_page_desc(stru=
ct sk_buff *skb, int i,</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/</div=
><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 frag-&gt;page.p=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =3D page;</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 fr=
ag-&gt;page_offset=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D off;</div><div>+=C2=
=A0 =C2=A0 =C2=A0 =C2=A0frag-&gt;coals=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0=3D 0;</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_frag_s=
ize_set(frag, size);</div><div>=C2=A0</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 page =3D compound_head(page);</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0<b>WAR=
N_ON(PageSlab(page) &amp;&amp; (page-&gt;slab_cache-&gt;size &lt; size)); /=
/ does NOT trigger</b></div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_is_pf=
memalloc(page))</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 skb-&gt;pfmemalloc =3D true;</div><div>=C2=A0}</div><div>@@ -2849,10=
 +2853,14 @@ static inline bool skb_can_coalesce(struct sk_buff *skb, int i=
,</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct=
 page *page, int off)</div><div>=C2=A0{</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (i) {</div><div>-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0const struct skb_frag_struct *frag =3D &amp;skb_shinfo(skb)-&gt;frags=
[i - 1];</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
struct skb_frag_struct *frag =3D &amp;skb_shinfo(skb)-&gt;frags[i - 1];</di=
v><div>=C2=A0</div><div>-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0return page =3D=3D skb_frag_page(frag) &amp;&amp;</div><div>+=C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool ret =3D page =3D=3D sk=
b_frag_page(frag) &amp;&amp;</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0off =3D=3D frag-&gt;page_of=
fset + skb_frag_size(frag);</div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if (unlikely(ret))</div><div><b>+=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageSlab(=
compound_head((struct page *)page)))</b></div><div><b>+=C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0frag-&gt;coals++;</b></div><div>+=C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;</div><div>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;</div><div>=C2=
=A0}</div></div><div><br></div></div><div class=3D"gmail_extra"><br><div cl=
ass=3D"gmail_quote">On Fri, Jun 1, 2018 at 2:55 PM, Kees Cook <span dir=3D"=
ltr">&lt;<a href=3D"mailto:keescook@chromium.org" target=3D"_blank">keescoo=
k@chromium.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div=
 class=3D"HOEnZb"><div class=3D"h5">On Fri, Jun 1, 2018 at 1:58 PM, Matthew=
 Wilcox &lt;<a href=3D"mailto:willy@infradead.org">willy@infradead.org</a>&=
gt; wrote:<br>
&gt; On Fri, Jun 01, 2018 at 01:49:38PM -0700, Kees Cook wrote:<br>
&gt;&gt; On Fri, Jun 1, 2018 at 12:02 PM, Laura Abbott &lt;<a href=3D"mailt=
o:labbott@redhat.com">labbott@redhat.com</a>&gt; wrote:<br>
&gt;&gt; &gt; (cc-ing some interested people)<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; On 05/31/2018 05:03 PM, Anton Eidelman wrote:<br>
&gt;&gt; &gt;&gt; Here&#39;s a rare issue I reproduce on 4.12.10 (centos co=
nfig): full log<br>
&gt;&gt; &gt;&gt; sample below.<br>
&gt;&gt;<br>
&gt;&gt; Thanks for digging into this! Do you have any specific reproducer =
for<br>
&gt;&gt; this? If so, I&#39;d love to try a bisection, as I&#39;m surprised=
 this has<br>
&gt;&gt; only now surfaced: hardened usercopy was introduced in 4.8 ...<br>
&gt;&gt;<br>
&gt;&gt; &gt;&gt; An innocent process (dhcpclient) is about to receive a da=
tagram, but<br>
&gt;&gt; &gt;&gt; during skb_copy_datagram_iter() usercopy triggers a BUG i=
n:<br>
&gt;&gt; &gt;&gt; usercopy.c:check_heap_object() -&gt; slub.c:__check_heap_=
object(), because<br>
&gt;&gt; &gt;&gt; the sk_buff fragment being copied crosses the 64-byte slu=
b object boundary.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Example __check_heap_object() context:<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 n=3D128=C2=A0 =C2=A0 &lt;&lt; usually 128, s=
ometimes 192.<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 object_size=3D64<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 s-&gt;size=3D64<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 page_address(page)=3D<wbr>0xffff880233f7c000=
<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 ptr=3D0xffff880233f7c540<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; My take on the root cause:<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 When adding data to an skb, new data is appe=
nded to the current<br>
&gt;&gt; &gt;&gt; fragment if the new chunk immediately follows the last on=
e: by simply<br>
&gt;&gt; &gt;&gt; increasing the frag-&gt;size, skb_frag_size_add().<br>
&gt;&gt; &gt;&gt;=C2=A0 =C2=A0 See include/linux/skbuff.h:skb_<wbr>can_coal=
esce() callers.<br>
&gt;&gt;<br>
&gt;&gt; Oooh, sneaky:<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0retur=
n page =3D=3D skb_frag_page(frag) &amp;&amp;<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 off =3D=3D frag-&gt;page_offset + skb_frag_size(frag);<br=
>
&gt;&gt;<br>
&gt;&gt; Originally I was thinking that slab red-zoning would get triggered=
<br>
&gt;&gt; too, but I see the above is checking to see if these are precisely=
<br>
&gt;&gt; neighboring allocations, I think.<br>
&gt;&gt;<br>
&gt;&gt; But then ... how does freeing actually work? I&#39;m really not su=
re how<br>
&gt;&gt; this seeming layering violation could be safe in other areas?<br>
&gt;<br>
&gt; I&#39;m confused ... I thought skb frags came from the page_frag alloc=
ator,<br>
&gt; not the slab allocator.=C2=A0 But then why would the slab hardening tr=
igger?<br>
<br>
</div></div>Well that would certainly make more sense (well, the sense abou=
t<br>
alloc/free). Having it overlap with a slab allocation, though, that&#39;s<b=
r>
quite bad. Perhaps this is a very odd use-after-free case? I.e. freed<br>
page got allocated to slab, and when it got copied out, usercopy found<br>
it spanned a slub object?<br>
<span class=3D""><br>
[ 655.602500] usercopy: kernel memory exposure attempt detected from<br>
</span>ffff88022a31aa00 (kmalloc-64) (192 bytes)<br>
<br>
This wouldn&#39;t be the first time usercopy triggered due to a memory corr=
uption...<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
-Kees<br>
<br>
-- <br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div>

--000000000000e771d7056d9d044a--
