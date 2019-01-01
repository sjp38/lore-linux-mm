Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC1B8E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 13:24:28 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id p131so21148768oia.21
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 10:24:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f14sor22436682oib.5.2019.01.01.10.24.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 10:24:27 -0800 (PST)
MIME-Version: 1.0
References: <20181203170934.16512-1-vpillai@digitalocean.com>
 <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Tue, 1 Jan 2019 13:24:15 -0500
Message-ID: <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
Content-Type: multipart/alternative; boundary="000000000000b1832f057e69a39c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

--000000000000b1832f057e69a39c
Content-Type: text/plain; charset="UTF-8"

Thanks a lot for the fixes and detailed explanation Hugh! I shall fold all
the changes from you and Huang in the next iteration.

Thanks for all the suggestions and comments as well. I am looking into all
those and will include all the changes in the next version. Will discuss
over mail in case of any clarifications.

Thanks again!
~Vineeth

On Mon, Dec 31, 2018 at 7:44 PM Hugh Dickins <hughd@google.com> wrote:

> On Mon, 3 Dec 2018, Vineeth Remanan Pillai wrote:
>
> > This patch was initially posted by Kelley(kelleynnn@gmail.com).
> > Reposting the patch with all review comments addressed and with minor
> > modifications and optimizations. Tests were rerun and commit message
> > updated with new results.
> >
> > The function try_to_unuse() is of quadratic complexity, with a lot of
> > wasted effort. It unuses swap entries one by one, potentially iterating
> > over all the page tables for all the processes in the system for each
> > one.
> >
> > This new proposed implementation of try_to_unuse simplifies its
> > complexity to linear. It iterates over the system's mms once, unusing
> > all the affected entries as it walks each set of page tables. It also
> > makes similar changes to shmem_unuse.
>
> Hi Vineeth, please fold in fixes below before reposting your
> "mm,swap: rid swapoff of quadratic complexity" patch -
> or ask for more detail if unclear.  I could split it up,
> of course, but since they should all (except perhaps one)
> just be merged into the base patch before going any further,
> it'll save me time to keep them together here and just explain:-
>
> shmem_unuse_swap_entries():
> If a user fault races with swapoff, it's very normal for
> shmem_swapin_page() to return -EEXIST, and the old code was
> careful not to pass back any error but -ENOMEM; whereas on mmotm,
> /usr/sbin/swapoff often failed silently because it got that EEXIST.
>
> shmem_unuse():
> A couple of crashing bugs there: a list_del_init without holding the
> mutex, and too much faith in the "safe" in list_for_each_entry_safe():
> it does assume that the mutex has been held throughout, you (very
> nicely!) drop it, but that does require "next" to be re-evaluated.
>
> shmem_writepage():
> Not a bug fix, this is the "except perhaps one": minor optimization,
> could be left out, but if shmem_unuse() is going through the list
> in the forward direction, and may completely unswap a file and del
> it from the list, then pages from that file can be swapped out to
> *other* swap areas after that, and it be reinserted in the list:
> better to reinsert it behind shmem_unuse()'s cursor than in front
> of it, which would entail a second pointless pass over that file.
>
> try_to_unuse():
> Moved up the assignment of "oldi = i" (and changed the test to
> "oldi <= i"), so as not to get trapped in that find_next_to_unuse()
> loop when find_get_page() does not find it.
>
> try_to_unuse():
> But the main problem was passing entry.val to find_get_page() there:
> that used to be correct, but since f6ab1f7f6b2d we need to pass just
> the offset - as it stood, it could only find the pages when swapping
> off area 0 (a similar issue was fixed in shmem_replace_page() recently).
> That (together with the late oldi assignment) was why my swapoffs were
> hanging on SWAP_HAS_CACHE swap_map entries.
>
> With those changes, it all seems to work rather well, and is a nice
> simplification of the source, in addition to removing the quadratic
> complexity. To my great surprise, the KSM pages are already handled
> fairly well - the ksm_might_need_to_copy() that has long been in
> unuse_pte() turns out to do (almost) a good enough job already,
> so most users of KSM and swapoff would never see any problem.
> And I'd been afraid of swapin readahead causing spurious -ENOMEMs,
> but have seen nothing of that in practice (though something else
> in mmotm does appear to use up more memory than before).
>
> My remaining criticisms would be:
>
> As Huang Ying pointed out in other mail, there is a danger of
> livelock (or rather, hitting the MAX_RETRIES limit) when a multiply
> mapped page (most especially a KSM page, whose mappings are not
> likely to be nearby in the mmlist) is swapped out then partially
> swapped off then some ptes swapped back out.  As indeed the
> "Under global memory pressure" comment admits.
>
> I have hit the MAX_RETRIES 3 limit several times in load testing,
> not investigated but I presume due to such a multiply mapped page,
> so at present we do have a regression there.  A very simple answer
> would be to remove the retries limiting - perhaps you just added
> that to get around the find_get_page() failure before it was
> understood?  That does then tend towards the livelock alternative,
> but you've kept the signal_pending() check, so there's still the
> same way out as the old technique had (but greater likelihood of
> needing it with the new technique).  The right fix will be to do
> an rmap walk to unuse all the swap entries of a single anon_vma
> while holding page lock (with KSM needing that page force-deleted
> from swap cache before moving on); but none of us have written
> that code yet, maybe just removing the retries limit good enough.
>
> Two dislikes on the code structure, probably one solution: the
> "goto retry", up two levels from inside the lower loop, is easy to
> misunderstand; and the oldi business is ugly - find_next_to_unuse()
> was written to wrap around continuously to suit the old loop, but
> now it's left with its "++i >= max" code to achieve that, then your
> "i <= oldi" code to detect when it did, to undo that again: please
> delete code from both ends to make that all simpler.
>
> I'd expect to see checks on inuse_pages in some places, to terminate
> the scans as soon as possible (swapoff of an unused swapfile should
> be very quick, shouldn't it? not requiring any scans at all); but it
> looks like the old code did not have those either - was inuse_pages
> unreliable once upon a time? is it unreliable now?
>
> Hugh
>
> ---
>
>  mm/shmem.c    |   12 ++++++++----
>  mm/swapfile.c |    8 ++++----
>  2 files changed, 12 insertions(+), 8 deletions(-)
>
> --- mmotm/mm/shmem.c    2018-12-22 13:32:51.339584848 -0800
> +++ linux/mm/shmem.c    2018-12-31 12:30:55.822407154 -0800
> @@ -1149,6 +1149,7 @@ static int shmem_unuse_swap_entries(stru
>                 }
>                 if (error == -ENOMEM)
>                         break;
> +               error = 0;
>         }
>         return error;
>  }
> @@ -1216,12 +1217,15 @@ int shmem_unuse(unsigned int type)
>                 mutex_unlock(&shmem_swaplist_mutex);
>                 if (prev_inode)
>                         iput(prev_inode);
> +               prev_inode = inode;
> +
>                 error = shmem_unuse_inode(inode, type);
> -               if (!info->swapped)
> -                       list_del_init(&info->swaplist);
>                 cond_resched();
> -               prev_inode = inode;
> +
>                 mutex_lock(&shmem_swaplist_mutex);
> +               next = list_next_entry(info, swaplist);
> +               if (!info->swapped)
> +                       list_del_init(&info->swaplist);
>                 if (error)
>                         break;
>         }
> @@ -1313,7 +1317,7 @@ static int shmem_writepage(struct page *
>          */
>         mutex_lock(&shmem_swaplist_mutex);
>         if (list_empty(&info->swaplist))
> -               list_add_tail(&info->swaplist, &shmem_swaplist);
> +               list_add(&info->swaplist, &shmem_swaplist);
>
>         if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
>                 spin_lock_irq(&info->lock);
> diff -purN mmotm/mm/swapfile.c linux/mm/swapfile.c
> --- mmotm/mm/swapfile.c 2018-12-22 13:32:51.347584880 -0800
> +++ linux/mm/swapfile.c 2018-12-31 12:30:55.822407154 -0800
> @@ -2156,7 +2156,7 @@ retry:
>
>         while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
>                 /*
> -                * under global memory pressure, swap entries
> +                * Under global memory pressure, swap entries
>                  * can be reinserted back into process space
>                  * after the mmlist loop above passes over them.
>                  * This loop will then repeat fruitlessly,
> @@ -2164,7 +2164,7 @@ retry:
>                  * but doing nothing to actually free up the swap.
>                  * In this case, go over the mmlist loop again.
>                  */
> -               if (i < oldi) {
> +               if (i <= oldi) {
>                         retries++;
>                         if (retries > MAX_RETRIES) {
>                                 retval = -EBUSY;
> @@ -2172,8 +2172,9 @@ retry:
>                         }
>                         goto retry;
>                 }
> +               oldi = i;
>                 entry = swp_entry(type, i);
> -               page = find_get_page(swap_address_space(entry), entry.val);
> +               page = find_get_page(swap_address_space(entry), i);
>                 if (!page)
>                         continue;
>
> @@ -2188,7 +2189,6 @@ retry:
>                 try_to_free_swap(page);
>                 unlock_page(page);
>                 put_page(page);
> -               oldi = i;
>         }
>  out:
>         return retval;
>

--000000000000b1832f057e69a39c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:verdana,=
sans-serif;font-size:small">Thanks a lot for the fixes and detailed=C2=A0ex=
planation Hugh! I shall fold all the changes from you and Huang in the next=
 iteration.</div><div class=3D"gmail_default" style=3D"font-family:verdana,=
sans-serif;font-size:small"><br></div><div class=3D"gmail_default" style=3D=
"font-family:verdana,sans-serif;font-size:small">Thanks for all the suggest=
ions and comments as well. I am looking into all those and will include all=
 the changes in the next=C2=A0version. Will discuss over mail in case of an=
y clarifications.</div><div class=3D"gmail_default" style=3D"font-family:ve=
rdana,sans-serif;font-size:small"><br></div><div class=3D"gmail_default" st=
yle=3D"font-family:verdana,sans-serif;font-size:small">Thanks again!</div><=
div class=3D"gmail_default" style=3D"font-family:verdana,sans-serif;font-si=
ze:small">~Vineeth</div></div><br><div class=3D"gmail_quote"><div dir=3D"lt=
r">On Mon, Dec 31, 2018 at 7:44 PM Hugh Dickins &lt;<a href=3D"mailto:hughd=
@google.com">hughd@google.com</a>&gt; wrote:<br></div><blockquote class=3D"=
gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(20=
4,204,204);padding-left:1ex">On Mon, 3 Dec 2018, Vineeth Remanan Pillai wro=
te:<br>
<br>
&gt; This patch was initially posted by Kelley(<a href=3D"mailto:kelleynnn@=
gmail.com" target=3D"_blank">kelleynnn@gmail.com</a>).<br>
&gt; Reposting the patch with all review comments addressed and with minor<=
br>
&gt; modifications and optimizations. Tests were rerun and commit message<b=
r>
&gt; updated with new results.<br>
&gt; <br>
&gt; The function try_to_unuse() is of quadratic complexity, with a lot of<=
br>
&gt; wasted effort. It unuses swap entries one by one, potentially iteratin=
g<br>
&gt; over all the page tables for all the processes in the system for each<=
br>
&gt; one.<br>
&gt; <br>
&gt; This new proposed implementation of try_to_unuse simplifies its<br>
&gt; complexity to linear. It iterates over the system&#39;s mms once, unus=
ing<br>
&gt; all the affected entries as it walks each set of page tables. It also<=
br>
&gt; makes similar changes to shmem_unuse.<br>
<br>
Hi Vineeth, please fold in fixes below before reposting your<br>
&quot;mm,swap: rid swapoff of quadratic complexity&quot; patch -<br>
or ask for more detail if unclear.=C2=A0 I could split it up,<br>
of course, but since they should all (except perhaps one)<br>
just be merged into the base patch before going any further,<br>
it&#39;ll save me time to keep them together here and just explain:-<br>
<br>
shmem_unuse_swap_entries():<br>
If a user fault races with swapoff, it&#39;s very normal for<br>
shmem_swapin_page() to return -EEXIST, and the old code was<br>
careful not to pass back any error but -ENOMEM; whereas on mmotm,<br>
/usr/sbin/swapoff often failed silently because it got that EEXIST.<br>
<br>
shmem_unuse():<br>
A couple of crashing bugs there: a list_del_init without holding the<br>
mutex, and too much faith in the &quot;safe&quot; in list_for_each_entry_sa=
fe():<br>
it does assume that the mutex has been held throughout, you (very<br>
nicely!) drop it, but that does require &quot;next&quot; to be re-evaluated=
.<br>
<br>
shmem_writepage():<br>
Not a bug fix, this is the &quot;except perhaps one&quot;: minor optimizati=
on,<br>
could be left out, but if shmem_unuse() is going through the list<br>
in the forward direction, and may completely unswap a file and del<br>
it from the list, then pages from that file can be swapped out to<br>
*other* swap areas after that, and it be reinserted in the list:<br>
better to reinsert it behind shmem_unuse()&#39;s cursor than in front<br>
of it, which would entail a second pointless pass over that file.<br>
<br>
try_to_unuse():<br>
Moved up the assignment of &quot;oldi =3D i&quot; (and changed the test to<=
br>
&quot;oldi &lt;=3D i&quot;), so as not to get trapped in that find_next_to_=
unuse()<br>
loop when find_get_page() does not find it.<br>
<br>
try_to_unuse():<br>
But the main problem was passing entry.val to find_get_page() there:<br>
that used to be correct, but since f6ab1f7f6b2d we need to pass just<br>
the offset - as it stood, it could only find the pages when swapping<br>
off area 0 (a similar issue was fixed in shmem_replace_page() recently).<br=
>
That (together with the late oldi assignment) was why my swapoffs were<br>
hanging on SWAP_HAS_CACHE swap_map entries.<br>
<br>
With those changes, it all seems to work rather well, and is a nice<br>
simplification of the source, in addition to removing the quadratic<br>
complexity. To my great surprise, the KSM pages are already handled<br>
fairly well - the ksm_might_need_to_copy() that has long been in<br>
unuse_pte() turns out to do (almost) a good enough job already,<br>
so most users of KSM and swapoff would never see any problem.<br>
And I&#39;d been afraid of swapin readahead causing spurious -ENOMEMs,<br>
but have seen nothing of that in practice (though something else<br>
in mmotm does appear to use up more memory than before).<br>
<br>
My remaining criticisms would be:<br>
<br>
As Huang Ying pointed out in other mail, there is a danger of<br>
livelock (or rather, hitting the MAX_RETRIES limit) when a multiply<br>
mapped page (most especially a KSM page, whose mappings are not<br>
likely to be nearby in the mmlist) is swapped out then partially<br>
swapped off then some ptes swapped back out.=C2=A0 As indeed the<br>
&quot;Under global memory pressure&quot; comment admits.<br>
<br>
I have hit the MAX_RETRIES 3 limit several times in load testing,<br>
not investigated but I presume due to such a multiply mapped page,<br>
so at present we do have a regression there.=C2=A0 A very simple answer<br>
would be to remove the retries limiting - perhaps you just added<br>
that to get around the find_get_page() failure before it was<br>
understood?=C2=A0 That does then tend towards the livelock alternative,<br>
but you&#39;ve kept the signal_pending() check, so there&#39;s still the<br=
>
same way out as the old technique had (but greater likelihood of<br>
needing it with the new technique).=C2=A0 The right fix will be to do<br>
an rmap walk to unuse all the swap entries of a single anon_vma<br>
while holding page lock (with KSM needing that page force-deleted<br>
from swap cache before moving on); but none of us have written<br>
that code yet, maybe just removing the retries limit good enough.<br>
<br>
Two dislikes on the code structure, probably one solution: the<br>
&quot;goto retry&quot;, up two levels from inside the lower loop, is easy t=
o<br>
misunderstand; and the oldi business is ugly - find_next_to_unuse()<br>
was written to wrap around continuously to suit the old loop, but<br>
now it&#39;s left with its &quot;++i &gt;=3D max&quot; code to achieve that=
, then your<br>
&quot;i &lt;=3D oldi&quot; code to detect when it did, to undo that again: =
please<br>
delete code from both ends to make that all simpler.<br>
<br>
I&#39;d expect to see checks on inuse_pages in some places, to terminate<br=
>
the scans as soon as possible (swapoff of an unused swapfile should<br>
be very quick, shouldn&#39;t it? not requiring any scans at all); but it<br=
>
looks like the old code did not have those either - was inuse_pages<br>
unreliable once upon a time? is it unreliable now?<br>
<br>
Hugh<br>
<br>
---<br>
<br>
=C2=A0mm/shmem.c=C2=A0 =C2=A0 |=C2=A0 =C2=A012 ++++++++----<br>
=C2=A0mm/swapfile.c |=C2=A0 =C2=A0 8 ++++----<br>
=C2=A02 files changed, 12 insertions(+), 8 deletions(-)<br>
<br>
--- mmotm/mm/shmem.c=C2=A0 =C2=A0 2018-12-22 13:32:51.339584848 -0800<br>
+++ linux/mm/shmem.c=C2=A0 =C2=A0 2018-12-31 12:30:55.822407154 -0800<br>
@@ -1149,6 +1149,7 @@ static int shmem_unuse_swap_entries(stru<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error =3D=3D -E=
NOMEM)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D 0;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return error;<br>
=C2=A0}<br>
@@ -1216,12 +1217,15 @@ int shmem_unuse(unsigned int type)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&amp;s=
hmem_swaplist_mutex);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (prev_inode)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 iput(prev_inode);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prev_inode =3D inod=
e;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D shmem_unu=
se_inode(inode, type);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!info-&gt;swapp=
ed)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_del_init(&amp;info-&gt;swaplist);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prev_inode =3D inod=
e;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;shm=
em_swaplist_mutex);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0next =3D list_next_=
entry(info, swaplist);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!info-&gt;swapp=
ed)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_del_init(&amp;info-&gt;swaplist);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (error)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
@@ -1313,7 +1317,7 @@ static int shmem_writepage(struct page *<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&amp;shmem_swaplist_mutex);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (list_empty(&amp;info-&gt;swaplist))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add_tail(&amp;=
info-&gt;swaplist, &amp;shmem_swaplist);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&amp;info-=
&gt;swaplist, &amp;shmem_swaplist);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (add_to_swap_cache(page, swap, GFP_ATOMIC) =
=3D=3D 0) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&amp;=
info-&gt;lock);<br>
diff -purN mmotm/mm/swapfile.c linux/mm/swapfile.c<br>
--- mmotm/mm/swapfile.c 2018-12-22 13:32:51.347584880 -0800<br>
+++ linux/mm/swapfile.c 2018-12-31 12:30:55.822407154 -0800<br>
@@ -2156,7 +2156,7 @@ retry:<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 while ((i =3D find_next_to_unuse(si, i, frontsw=
ap)) !=3D 0) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * under global mem=
ory pressure, swap entries<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Under global mem=
ory pressure, swap entries<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* can be rein=
serted back into process space<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* after the m=
mlist loop above passes over them.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* This loop w=
ill then repeat fruitlessly,<br>
@@ -2164,7 +2164,7 @@ retry:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* but doing n=
othing to actually free up the swap.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* In this cas=
e, go over the mmlist loop again.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (i &lt; oldi) {<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (i &lt;=3D oldi)=
 {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 retries++;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (retries &gt; MAX_RETRIES) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 retval =3D -EBUSY;<br>
@@ -2172,8 +2172,9 @@ retry:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto retry;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0oldi =3D i;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 entry =3D swp_entry=
(type, i);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D find_get_p=
age(swap_address_space(entry), entry.val);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D find_get_p=
age(swap_address_space(entry), i);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 continue;<br>
<br>
@@ -2188,7 +2189,6 @@ retry:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 try_to_free_swap(pa=
ge);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(page);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0oldi =3D i;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0out:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return retval;<br>
</blockquote></div>

--000000000000b1832f057e69a39c--
