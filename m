Return-Path: <owner-linux-mm@kvack.org>
MIME-Version: 1.0
In-Reply-To: <20130514135850.GG13845@kvack.org>
References: <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
	<20130205120137.GG21389@suse.de>
	<20130206004234.GD11197@blaptop>
	<20130206095617.GN21389@suse.de>
	<5190AE4F.4000103@cn.fujitsu.com>
	<20130513091902.GP11497@suse.de>
	<20130513143757.GP31899@kvack.org>
	<x49obcfnd6c.fsf@segfault.boston.devel.redhat.com>
	<20130513150147.GQ31899@kvack.org>
	<5191926A.2090608@cn.fujitsu.com>
	<20130514135850.GG13845@kvack.org>
Date: Tue, 14 May 2013 23:16:41 +0800
Message-ID: <CAD11hGwmPDe2KkyX=5MFVNneM7HWWA-wMTvBAaNTxrTp0r+2cw@mail.gmail.com>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
From: chen tang <imtangchen@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8fb202c2d5c37704dcaf1e5d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Jeff Moyer <jmoyer@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

--e89a8fb202c2d5c37704dcaf1e5d
Content-Type: text/plain; charset=ISO-8859-1

Hi Benjamin,

Thank you for the explaination. But would you please give me more info
about aio ?
See below.

2013/5/14 Benjamin LaHaise <bcrl@kvack.org>

> On Tue, May 14, 2013 at 09:24:58AM +0800, Tang Chen wrote:
> > Hi Mel, Benjamin, Jeff,
> >
> > On 05/13/2013 11:01 PM, Benjamin LaHaise wrote:
> > >On Mon, May 13, 2013 at 10:54:03AM -0400, Jeff Moyer wrote:
> > >>How do you propose to move the ring pages?
> > >
> > >It's the same problem as doing a TLB shootdown: flush the old pages from
> > >userspace's mapping, copy any existing data to the new pages, then
> > >repopulate the page tables.  It will likely require the addition of
> > >address_space_operations for the mapping, but that's not too hard to do.
> > >
> >
> > I think we add migrate_unpin() callback to decrease page->count if
> > necessary,
> > and migrate the page to a new page, and add migrate_pin() callback to pin
> > the new page again.
>
> You can't just decrease the page count for this to work.  The pages are
> pinned because aio_complete() can occur at any time and needs to have a
> place to write the completion events.  When changing pages, aio has to
> take the appropriate lock when changing one page for another.
>

I saw in aio_complete(), it holds kioctx->ctx_lock. Can we hold this lock
when
we migrate aio ring pages ?


>
> > The migrate procedure will work just as before. We use callbacks to
> > decrease
> > the page->count before migration starts, and increase it when the
> migration
> > is done.
> >
> > And migrate_pin() and migrate_unpin() callbacks will be added to
> > struct address_space_operations.
>
> I think the existing migratepage operation in address_space_operations can
> be used.  Does it get called when hot unplug occurs?  That is: is testing
> with the migrate_pages syscall similar enough to the memory removal case?
>

For anonymous pages, they don't have address_space, so they don't have
address_space_operations. And aio ring pages are anonymous pages, right ?

In move_to_new_page(), kernel will decide which function to call.

if (!mapping)
rc = migrate_page(mapping, newpage, page, mode);
else if (mapping->a_ops->migratepage)
rc = mapping->a_ops->migratepage(mapping,
newpage, page, mode);
else
rc = fallback_migrate_page(mapping, newpage, page, mode);

And for aio ring pages, it always call migrate_page(), right ?

Thanks. :)


>
>                 -ben
>
> > Is that right ?
> >
> > If so, I'll be working on it.
> >
> > Thanks. :)
>
> --
> "Thought is the essence of where you are now."
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--e89a8fb202c2d5c37704dcaf1e5d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi=A0Benjamin,<br><div class=3D"gmail_extra"><br></div><di=
v class=3D"gmail_extra">Thank you for the explaination. But would you pleas=
e give me more info about aio ?</div><div class=3D"gmail_extra">See below.<=
br><br>
<div class=3D"gmail_quote">2013/5/14 Benjamin LaHaise <span dir=3D"ltr">&lt=
;<a href=3D"mailto:bcrl@kvack.org" target=3D"_blank">bcrl@kvack.org</a>&gt;=
</span><br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.=
8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-st=
yle:solid;padding-left:1ex">
<div class=3D"im">On Tue, May 14, 2013 at 09:24:58AM +0800, Tang Chen wrote=
:<br>
&gt; Hi Mel, Benjamin, Jeff,<br>
&gt;<br>
&gt; On 05/13/2013 11:01 PM, Benjamin LaHaise wrote:<br>
&gt; &gt;On Mon, May 13, 2013 at 10:54:03AM -0400, Jeff Moyer wrote:<br>
&gt; &gt;&gt;How do you propose to move the ring pages?<br>
&gt; &gt;<br>
&gt; &gt;It&#39;s the same problem as doing a TLB shootdown: flush the old =
pages from<br>
&gt; &gt;userspace&#39;s mapping, copy any existing data to the new pages, =
then<br>
&gt; &gt;repopulate the page tables. =A0It will likely require the addition=
 of<br>
&gt; &gt;address_space_operations for the mapping, but that&#39;s not too h=
ard to do.<br>
&gt; &gt;<br>
&gt;<br>
&gt; I think we add migrate_unpin() callback to decrease page-&gt;count if<=
br>
&gt; necessary,<br>
&gt; and migrate the page to a new page, and add migrate_pin() callback to =
pin<br>
&gt; the new page again.<br>
<br>
</div>You can&#39;t just decrease the page count for this to work. =A0The p=
ages are<br>
pinned because aio_complete() can occur at any time and needs to have a<br>
place to write the completion events. =A0When changing pages, aio has to<br=
>
take the appropriate lock when changing one page for another.<br></blockquo=
te><div><br></div><div style>I saw in aio_complete(), it holds=A0kioctx-&gt=
;ctx_lock. Can we hold this lock when=A0</div><div style>we migrate aio rin=
g pages ?</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px=
 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left=
-style:solid;padding-left:1ex">
<div class=3D"im"><br>
&gt; The migrate procedure will work just as before. We use callbacks to<br=
>
&gt; decrease<br>
&gt; the page-&gt;count before migration starts, and increase it when the m=
igration<br>
&gt; is done.<br>
&gt;<br>
&gt; And migrate_pin() and migrate_unpin() callbacks will be added to<br>
&gt; struct address_space_operations.<br>
<br>
</div>I think the existing migratepage operation in address_space_operation=
s can<br>
be used. =A0Does it get called when hot unplug occurs? =A0That is: is testi=
ng<br>
with the migrate_pages syscall similar enough to the memory removal case?<b=
r></blockquote><div><br></div><div style>For anonymous pages, they don&#39;=
t have address_space, so they don&#39;t have=A0</div><div style>address_spa=
ce_operations. And aio ring pages are anonymous pages, right ?<br>
</div><div style><br></div><div style>In move_to_new_page(), kernel will de=
cide which function to call.</div><div style><br></div><div style><div><spa=
n class=3D"" style=3D"white-space:pre">	</span>if (!mapping)</div><div><spa=
n class=3D"" style=3D"white-space:pre">		</span>rc =3D migrate_page(mapping=
, newpage, page, mode);</div>
<div><span class=3D"" style=3D"white-space:pre">	</span>else if (mapping-&g=
t;a_ops-&gt;migratepage)</div><div><span class=3D"" style=3D"white-space:pr=
e">		</span>rc =3D mapping-&gt;a_ops-&gt;migratepage(mapping,</div><div><sp=
an class=3D"" style=3D"white-space:pre">						</span>newpage, page, mode);<=
/div>
<div><span class=3D"" style=3D"white-space:pre">	</span>else</div><div><spa=
n class=3D"" style=3D"white-space:pre">		</span>rc =3D fallback_migrate_pag=
e(mapping, newpage, page, mode);</div><div><br></div><div style>And for aio=
 ring pages, it always call migrate_page(), right ?</div>
<div style><br></div><div style>Thanks. :)</div></div><div>=A0</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left-wi=
dth:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-=
left:1ex">

<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 -ben<br>
<div class=3D"im"><br>
&gt; Is that right ?<br>
&gt;<br>
&gt; If so, I&#39;ll be working on it.<br>
&gt;<br>
&gt; Thanks. :)<br>
<br>
--<br>
</div><div class=3D"im">&quot;Thought is the essence of where you are now.&=
quot;<br>
</div><div class=3D""><div class=3D"h5">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel=
&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at =A0<a href=3D"http://www.tux.org/lkml/" target=3D"_b=
lank">http://www.tux.org/lkml/</a><br>
</div></div></blockquote></div><br></div></div>

--e89a8fb202c2d5c37704dcaf1e5d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
