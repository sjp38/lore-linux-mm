Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BD3BC6B00ED
	for <linux-mm@kvack.org>; Tue,  8 May 2012 02:28:27 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so5886776vbb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 23:28:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120506233117.GU5091@dastard>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-2-git-send-email-svenkatr@ti.com> <20120506233117.GU5091@dastard>
From: mani <manishrma@gmail.com>
Date: Tue, 8 May 2012 11:58:06 +0530
Message-ID: <CAB+TZU8FNWuHrf6Hqnjs5fwH8yMJgd=CLPB0iUkrs2a-fgehtQ@mail.gmail.com>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Content-Type: multipart/alternative; boundary=20cf3079b7fc8a3fec04bf807ef7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Venkatraman S <svenkatr@ti.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

--20cf3079b7fc8a3fec04bf807ef7
Content-Type: text/plain; charset=ISO-8859-1

How about adding the AS_DMPG flag in the file -> address_space when getting
a filemap_fault()
so that we can treat the page fault pages as the high priority pages over
normal read requests.
How about changing below lines for the support of the pages those are
requested for the page fault ?


--- a/fs/mpage.c 2012-05-04 12:59:12.000000000 +0530
+++ b/fs/mpage.c 2012-05-07 13:13:49.000000000 +0530
@@ -408,6 +408,8 @@ mpage_readpages(struct address_space *ma
                    &last_block_in_bio, &map_bh,
                    &first_logical_block,
                    get_block);
+           if(test_bit(AS_DMPG, &mapping->flags) && bio)
+                 bio->bi_rw |= REQ_RW_DMPG
        }
        page_cache_release(page);
    }
--- a/include/linux/pagemap.h    2012-05-04 12:57:35.000000000 +0530
+++ b/include/linux/pagemap.h    2012-05-07 13:15:24.000000000 +0530
@@ -27,6 +27,7 @@ enum mapping_flags {
 #if defined (CONFIG_BD_CACHE_ENABLED)
    AS_DIRECT  =   __GFP_BITS_SHIFT + 4,  /* DIRECT_IO specified on file op
*/
 #endif
+   AS_DMPG  =   __GFP_BITS_SHIFT + 5,  /* DEMAND PAGE specified on file op
*/
 };

 static inline void mapping_set_error(struct address_space *mapping, int
error)

--- a/mm/filemap.c   2012-05-04 12:58:49.000000000 +0530
+++ b/mm/filemap.c   2012-05-07 13:15:03.000000000 +0530
@@ -1646,6 +1646,7 @@ int filemap_fault(struct vm_area_struct
    if (offset >= size)
        return VM_FAULT_SIGBUS;

+   set_bit(AS_DMPG, &file->f_mapping->flags);
    /*
     * Do we have something in the page cache already?
     */

Will these changes have any adverse effect ?

Thanks & Regards
Manish

On Mon, May 7, 2012 at 5:01 AM, Dave Chinner <david@fromorbit.com> wrote:

> On Thu, May 03, 2012 at 07:53:00PM +0530, Venkatraman S wrote:
> > From: Ilan Smith <ilan.smith@sandisk.com>
> >
> > Add attribute to identify demand paging requests.
> > Mark readpages with demand paging attribute.
> >
> > Signed-off-by: Ilan Smith <ilan.smith@sandisk.com>
> > Signed-off-by: Alex Lemberg <alex.lemberg@sandisk.com>
> > Signed-off-by: Venkatraman S <svenkatr@ti.com>
> > ---
> >  fs/mpage.c                |    2 ++
> >  include/linux/bio.h       |    7 +++++++
> >  include/linux/blk_types.h |    2 ++
> >  3 files changed, 11 insertions(+)
> >
> > diff --git a/fs/mpage.c b/fs/mpage.c
> > index 0face1c..8b144f5 100644
> > --- a/fs/mpage.c
> > +++ b/fs/mpage.c
> > @@ -386,6 +386,8 @@ mpage_readpages(struct address_space *mapping,
> struct list_head *pages,
> >                                       &last_block_in_bio, &map_bh,
> >                                       &first_logical_block,
> >                                       get_block);
> > +                     if (bio)
> > +                             bio->bi_rw |= REQ_RW_DMPG;
>
> Have you thought about the potential for DOSing a machine
> with this? That is, user data reads can now preempt writes of any
> kind, effectively stalling writeback and memory reclaim which will
> lead to OOM situations. Or, alternatively, journal flushing will get
> stalled and no new modifications can take place until the read
> stream stops.
>
> This really seems like functionality that belongs in an IO
> scheduler so that write starvation can be avoided, not in high-level
> data read paths where we have no clue about anything else going on
> in the IO subsystem....
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-mmc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--20cf3079b7fc8a3fec04bf807ef7
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

How about adding the AS_DMPG flag in the file -&gt; address_space when gett=
ing a filemap_fault() <br>so that we can treat the page fault pages as the =
high priority pages over normal read requests.<br>How about changing below =
lines for the support of the pages those are requested for the page fault ?=
<br>

<br><br>--- a/fs/mpage.c 2012-05-04 12:59:12.000000000 +0530<br>+++ b/fs/mp=
age.c 2012-05-07 13:13:49.000000000 +0530<br>@@ -408,6 +408,8 @@ mpage_read=
pages(struct address_space *ma<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 &amp;last_block_in_bio, &amp;map_bh,<br>

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 &amp;first_logica=
l_block,<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 get_b=
lock);<br>+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if(test_bit(AS_DMPG, &amp;mapping=
-&gt;flags) &amp;&amp; bio)<br>+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 bio-&gt;bi_rw |=3D REQ_RW_DMPG<br>=A0=A0=A0=A0=A0=A0=A0 }<br>

=A0=A0=A0=A0=A0=A0=A0 page_cache_release(page);<br>=A0=A0=A0 }<br>--- a/inc=
lude/linux/pagemap.h=A0=A0=A0 2012-05-04 12:57:35.000000000 +0530<br>+++ b/=
include/linux/pagemap.h=A0=A0=A0 2012-05-07 13:15:24.000000000 +0530<br>@@ =
-27,6 +27,7 @@ enum mapping_flags {<br>

=A0#if defined (CONFIG_BD_CACHE_ENABLED)<br>=A0=A0=A0 AS_DIRECT=A0 =3D=A0=
=A0 __GFP_BITS_SHIFT + 4,=A0 /* DIRECT_IO specified on file op */<br>=A0#en=
dif<br>+=A0=A0 AS_DMPG=A0 =3D=A0=A0 __GFP_BITS_SHIFT + 5,=A0 /* DEMAND PAGE=
 specified on file op */<br>=A0};<br>

=A0<br>=A0static inline void mapping_set_error(struct address_space *mappin=
g, int error)<br><br>--- a/mm/filemap.c=A0=A0 2012-05-04 12:58:49.000000000=
 +0530<br>+++ b/mm/filemap.c=A0=A0 2012-05-07 13:15:03.000000000 +0530<br>@=
@ -1646,6 +1646,7 @@ int filemap_fault(struct vm_area_struct <br>

=A0=A0=A0 if (offset &gt;=3D size)<br>=A0=A0=A0=A0=A0=A0=A0 return VM_FAULT=
_SIGBUS;<br>=A0<br>+=A0=A0 set_bit(AS_DMPG, &amp;file-&gt;f_mapping-&gt;fla=
gs);<br>=A0=A0=A0 /*<br>=A0=A0=A0=A0 * Do we have something in the page cac=
he already?<br>=A0=A0=A0=A0 */<br>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 <br>

Will these changes have any adverse effect ? <br><br>Thanks &amp; Regards<b=
r>Manish<br><br><div class=3D"gmail_quote">On Mon, May 7, 2012 at 5:01 AM, =
Dave Chinner <span dir=3D"ltr">&lt;<a href=3D"mailto:david@fromorbit.com" t=
arget=3D"_blank">david@fromorbit.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"im">On Thu, May 03, 2012 at 07=
:53:00PM +0530, Venkatraman S wrote:<br>
&gt; From: Ilan Smith &lt;<a href=3D"mailto:ilan.smith@sandisk.com">ilan.sm=
ith@sandisk.com</a>&gt;<br>
&gt;<br>
&gt; Add attribute to identify demand paging requests.<br>
&gt; Mark readpages with demand paging attribute.<br>
&gt;<br>
&gt; Signed-off-by: Ilan Smith &lt;<a href=3D"mailto:ilan.smith@sandisk.com=
">ilan.smith@sandisk.com</a>&gt;<br>
&gt; Signed-off-by: Alex Lemberg &lt;<a href=3D"mailto:alex.lemberg@sandisk=
.com">alex.lemberg@sandisk.com</a>&gt;<br>
&gt; Signed-off-by: Venkatraman S &lt;<a href=3D"mailto:svenkatr@ti.com">sv=
enkatr@ti.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0fs/mpage.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++<br>
&gt; =A0include/linux/bio.h =A0 =A0 =A0 | =A0 =A07 +++++++<br>
&gt; =A0include/linux/blk_types.h | =A0 =A02 ++<br>
&gt; =A03 files changed, 11 insertions(+)<br>
&gt;<br>
&gt; diff --git a/fs/mpage.c b/fs/mpage.c<br>
&gt; index 0face1c..8b144f5 100644<br>
&gt; --- a/fs/mpage.c<br>
&gt; +++ b/fs/mpage.c<br>
&gt; @@ -386,6 +386,8 @@ mpage_readpages(struct address_space *mapping, str=
uct list_head *pages,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &amp;last_block_in_bio, &amp;map_bh,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 &amp;first_logical_block,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 get_block);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bio)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bio-&gt;bi_r=
w |=3D REQ_RW_DMPG;<br>
<br>
</div>Have you thought about the potential for DOSing a machine<br>
with this? That is, user data reads can now preempt writes of any<br>
kind, effectively stalling writeback and memory reclaim which will<br>
lead to OOM situations. Or, alternatively, journal flushing will get<br>
stalled and no new modifications can take place until the read<br>
stream stops.<br>
<br>
This really seems like functionality that belongs in an IO<br>
scheduler so that write starvation can be avoided, not in high-level<br>
data read paths where we have no clue about anything else going on<br>
in the IO subsystem....<br>
<br>
Cheers,<br>
<br>
Dave.<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Dave Chinner<br>
<a href=3D"mailto:david@fromorbit.com">david@fromorbit.com</a><br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-mmc&qu=
ot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
</div></div></blockquote></div><br>

--20cf3079b7fc8a3fec04bf807ef7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
