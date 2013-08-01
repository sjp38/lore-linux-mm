Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 357D76B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 11:19:51 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id ec20so1533272lab.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2013 08:19:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375357892-10188-1-git-send-email-handai.szj@taobao.com>
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
	<1375357892-10188-1-git-send-email-handai.szj@taobao.com>
Date: Thu, 1 Aug 2013 23:19:48 +0800
Message-ID: <CAAM7YAmxmmA6g2WPVtGN1-42rtDBYzLhF-gvNXxcBN6dUveBYQ@mail.gmail.com>
Subject: Re: [PATCH V5 2/8] fs/ceph: vfs __set_page_dirty_nobuffers interface
 instead of doing it inside filesystem
From: "Yan, Zheng" <ukernel@gmail.com>
Content-Type: multipart/alternative; boundary=089e0160a6f277e6f204e2e45f4f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, ceph-devel <ceph-devel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, Sage Weil <sage@inktank.com>, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@taobao.com>

--089e0160a6f277e6f204e2e45f4f
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Aug 1, 2013 at 7:51 PM, Sha Zhengju <handai.szj@gmail.com> wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
>
> Following we will begin to add memcg dirty page accounting around
__set_page_dirty_
> {buffers,nobuffers} in vfs layer, so we'd better use vfs interface to
avoid exporting
> those details to filesystems.
>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> ---
>  fs/ceph/addr.c |   13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
>
> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index 3e68ac1..1445bf1 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -76,7 +76,7 @@ static int ceph_set_page_dirty(struct page *page)
>         if (unlikely(!mapping))
>                 return !TestSetPageDirty(page);
>
> -       if (TestSetPageDirty(page)) {
> +       if (!__set_page_dirty_nobuffers(page)) {

it's too early to set the radix tree tag here. We should set page's
snapshot context and increase the i_wrbuffer_ref first. This is because
once the tag is set, writeback thread can find and start flushing the page.


>                 dout("%p set_page_dirty %p idx %lu -- already dirty\n",
>                      mapping->host, page, page->index);
>                 return 0;
> @@ -107,14 +107,7 @@ static int ceph_set_page_dirty(struct page *page)
>              snapc, snapc->seq, snapc->num_snaps);
>         spin_unlock(&ci->i_ceph_lock);
>
> -       /* now adjust page */
> -       spin_lock_irq(&mapping->tree_lock);
>         if (page->mapping) {    /* Race with truncate? */
> -               WARN_ON_ONCE(!PageUptodate(page));
> -               account_page_dirtied(page, page->mapping);
> -               radix_tree_tag_set(&mapping->page_tree,
> -                               page_index(page), PAGECACHE_TAG_DIRTY);
> -

this code was coped from __set_page_dirty_nobuffers(). I think the reason
Sage did this is to handle the race described in
__set_page_dirty_nobuffers()'s comment. But I'm wonder if "page->mapping ==
NULL" can still happen here. Because truncate_inode_page() unmap page from
processes's address spaces first, then delete page from page cache.

Regards
Yan, Zheng

>                 /*
>                  * Reference snap context in page->private.  Also set
>                  * PagePrivate so that we get invalidatepage callback.
> @@ -126,14 +119,10 @@ static int ceph_set_page_dirty(struct page *page)
>                 undo = 1;
>         }
>
> -       spin_unlock_irq(&mapping->tree_lock);




> -
>         if (undo)
>                 /* whoops, we failed to dirty the page */
>                 ceph_put_wrbuffer_cap_refs(ci, 1, snapc);
>
> -       __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> -
>         BUG_ON(!PageDirty(page));
>         return 1;
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--089e0160a6f277e6f204e2e45f4f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Thu, Aug 1, 2013 at 7:51 PM, Sha Zhengju &lt;<a href=3D=
"mailto:handai.szj@gmail.com" target=3D"_blank">handai.szj@gmail.com</a>&gt=
; wrote:<br>&gt; From: Sha Zhengju &lt;<a href=3D"mailto:handai.szj@taobao.=
com" target=3D"_blank">handai.szj@taobao.com</a>&gt;<br>


&gt;<br>&gt; Following we will begin to add memcg dirty page accounting aro=
und __set_page_dirty_<br>&gt; {buffers,nobuffers} in vfs layer, so we&#39;d=
 better use vfs interface to avoid exporting<br>&gt; those details to files=
ystems.<br>


&gt;<br>&gt; Signed-off-by: Sha Zhengju &lt;<a href=3D"mailto:handai.szj@ta=
obao.com" target=3D"_blank">handai.szj@taobao.com</a>&gt;<br>&gt; ---<br>&g=
t; =A0fs/ceph/addr.c | =A0 13 +------------<br>&gt; =A01 file changed, 1 in=
sertion(+), 12 deletions(-)<br>


&gt;<br>&gt; diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c<br>&gt; index 3e6=
8ac1..1445bf1 100644<br>&gt; --- a/fs/ceph/addr.c<br>&gt; +++ b/fs/ceph/add=
r.c<br>&gt; @@ -76,7 +76,7 @@ static int ceph_set_page_dirty(struct page *p=
age)<br>


&gt; =A0 =A0 =A0 =A0 if (unlikely(!mapping))<br>&gt; =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 return !TestSetPageDirty(page);<br>&gt;<br>&gt; - =A0 =A0 =A0 i=
f (TestSetPageDirty(page)) {<br>&gt; + =A0 =A0 =A0 if (!__set_page_dirty_no=
buffers(page)) {<div><br></div><div>

it&#39;s too early to set the radix tree tag here. We should set page&#39;s=
 snapshot context and increase the i_wrbuffer_ref first. This is because on=
ce the tag is set, writeback thread can find and start flushing the page.</=
div>

<div><br></div><div><br><div>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dout(&quo=
t;%p set_page_dirty %p idx %lu -- already dirty\n&quot;,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mapping-&gt;host, page, pag=
e-&gt;index);<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>&gt; @@ =
-107,14 +107,7 @@ static int ceph_set_page_dirty(struct page *page)<br>&gt;=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0snapc, snapc-&gt;seq, snapc-&gt;num_snaps);<br>


&gt; =A0 =A0 =A0 =A0 spin_unlock(&amp;ci-&gt;i_ceph_lock);<br>&gt;<br>&gt; =
- =A0 =A0 =A0 /* now adjust page */<br>&gt; - =A0 =A0 =A0 spin_lock_irq(&am=
p;mapping-&gt;tree_lock);<br>&gt; =A0 =A0 =A0 =A0 if (page-&gt;mapping) { =
=A0 =A0/* Race with truncate? */</div>

<div>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!PageUptodate(page));<=
br></div><div>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 account_page_dirtied(page,=
 page-&gt;mapping);<br>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 radix_tree_tag_se=
t(&amp;mapping-&gt;page_tree,<br>&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 page_index(page), PAGECACHE_TAG_DIRTY);<br>


&gt; -</div><div><br></div><div style>this code was coped from __set_page_d=
irty_nobuffers(). I think the reason Sage did this is to handle the race de=
scribed in __set_page_dirty_nobuffers()&#39;s comment. But I&#39;m wonder i=
f &quot;page-&gt;mapping =3D=3D NULL&quot; can still happen here. Because t=
runcate_inode_page() unmap page from processes&#39;s address spaces first, =
then delete page from page cache.</div>
<div style><br></div><div style>Regards</div><div style>Yan, Zheng</div><di=
v><br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>&gt; =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0* Reference snap context in page-&gt;private. =A0Also set<br=
>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* PagePrivate so that we get inval=
idatepage callback.<br>
&gt; @@ -126,14 +119,10 @@ static int ceph_set_page_dirty(struct page *page=
)<br>

&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 undo =3D 1;<br>&gt; =A0 =A0 =A0 =A0 }<=
br>&gt;<br>&gt; - =A0 =A0 =A0 spin_unlock_irq(&amp;mapping-&gt;tree_lock);<=
/div><div><br></div><div><br></div><div><br></div><div><br>&gt; -<br>&gt; =
=A0 =A0 =A0 =A0 if (undo)<br>&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* whoops=
, we failed to dirty the page */<br>


&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ceph_put_wrbuffer_cap_refs(ci, 1, snap=
c);</div><div>&gt;<br>&gt; - =A0 =A0 =A0 __mark_inode_dirty(mapping-&gt;hos=
t, I_DIRTY_PAGES);<br>&gt; -<br>&gt; =A0 =A0 =A0 =A0 BUG_ON(!PageDirty(page=
));<br>
&gt; =A0 =A0 =A0 =A0 return 1;<br>&gt; =A0}<br>&gt; --<br>&gt; 1.7.9.5<br>&=
gt;<br>&gt; --<br>&gt; To unsubscribe from this list: send the line &quot;u=
nsubscribe ceph-devel&quot; in<br>&gt; the body of a message to <a href=3D"=
mailto:majordomo@vger.kernel.org" target=3D"_blank">majordomo@vger.kernel.o=
rg</a><br>


&gt; More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-=
info.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a>=
<br><br></div></div></div>

--089e0160a6f277e6f204e2e45f4f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
