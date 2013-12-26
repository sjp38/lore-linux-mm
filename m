Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f174.google.com (mail-gg0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2B86B0035
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 00:51:12 -0500 (EST)
Received: by mail-gg0-f174.google.com with SMTP id v2so1650387ggc.19
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 21:51:12 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id z48si27306200yha.231.2013.12.25.21.51.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Dec 2013 21:51:11 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id tp5so7955061ieb.8
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 21:51:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52BB847F.5080600@oracle.com>
References: <52B1C143.8080301@oracle.com>
	<52B871B2.7040409@oracle.com>
	<20131224025127.GA2835@lge.com>
	<52B8F8F6.1080500@oracle.com>
	<20131224060705.GA16140@lge.com>
	<20131224074546.GB27156@lge.com>
	<52BB847F.5080600@oracle.com>
Date: Thu, 26 Dec 2013 14:51:10 +0900
Message-ID: <CALYGNiP+xx6hhEL8ek4vWgRvcHh0wEsDZzG-Svr_mpEUrDQ6kQ@mail.gmail.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: multipart/alternative; boundary=14dae934088b874d3c04ee6990d2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

--14dae934088b874d3c04ee6990d2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hmm. This kind of race looks impossible: dup_mmap() always places child's
vma in into rmap tree after parent's one. For file-vma it's done explicitly
(vma_interval_tree_insert_after), for anon vma it's true because rb-tree
insert function goes to right branch if elements are equal.

Thus remove_migration_ptes() sees parent's pte first:
If child has the copy this function will check it after that.
And they are already synchronized with parent's and child's pte locks.=EF=
=BB=BF

On Dec 26, 2013 10:21 AM, "Bob Liu" <bob.liu@oracle.com> wrote:
>
> On 12/24/2013 03:45 PM, Joonsoo Kim wrote:
> > On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:
> >> On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:
> >>> On 12/23/2013 09:51 PM, Joonsoo Kim wrote:
> >>>> On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin wrote:
> >>>>>> Ping?
> >>>>>>
> >>>>>> I've also Cc'ed the "this page shouldn't be locked at all" team.
> >>>> Hello,
> >>>>
> >>>> I can't find the reason of this problem.
> >>>> If it is reproducible, how about bisecting?
> >>>
> >>> While it reproduces under fuzzing it's pretty hard to bisect it with
> >>> the amount of issues uncovered by trinity recently.
> >>>
> >>> I can add any debug code to the site of the BUG if that helps.
> >>
> >> Good!
> >> It will be helpful to add dump_page() in migration_entry_to_page().
> >>
> >> Thanks.
> >>
> >
> > Minchan teaches me that there is possible race condition between
> > fork and migration.
> >
> > Please consider following situation.
> >
> >
> > Process A (do migration)                      Process B (parents)
Process C (child)
> >
> > try_to_unmap() for migration <begin>          fork
> > setup migration entry to B's vma
> > ...
> > try_to_unmap() for migration <end>
> > move_to_new_page()
> >
> >                                               link new vma
> >                                                   into interval tree
> > remove_migration_ptes() <begin>
> > check and clear migration entry on C's vma
> > ...                                           copy_one_pte:
> > ...                                               now, B and C have
migration entry
> > ...
> > ...
> > check and clear migration entry on B's vma
> > ...
> > ...
> > remove_migration_ptes() <end>
> >
> >
> > Eventually, migration entry on C's vma is left.
> > And then, when C exits, above BUG_ON() can be triggered.
> >
>
> Yes, Looks like this is a potential race condition.
>
> > I'm not sure the I am right, so please think of it together. :)
> > And I'm not sure again that above assumption is related to this trigger
report,
> > since this may exist for a long time.
> >
> > So my question to mm folks is is above assumption possible and do we
have
> > any protection mechanism on this race?
> >
>
> I think we can down_read(&mm->mmap_sem) before remove_migration_ptes()
> to fix this issue, but I don't have time to verify it currently.
>
> --
> Regards,
> -Bob
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--14dae934088b874d3c04ee6990d2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Hmm. This kind of race looks impossible: dup_mmap() always p=
laces child&#39;s<br>
vma in into rmap tree after parent&#39;s one. For file-vma it&#39;s done ex=
plicitly<br>
(vma_interval_tree_insert_after), for anon vma it&#39;s true because rb-tre=
e<br>
insert function goes to right branch if elements are equal.</p>
<p dir=3D"ltr">Thus remove_migration_ptes() sees parent&#39;s pte first:<br=
>
If child has the copy this function will check it after that.<br>
And they are already synchronized with parent&#39;s and child&#39;s pte loc=
ks.=EF=BB=BF</p>
<p dir=3D"ltr">On Dec 26, 2013 10:21 AM, &quot;Bob Liu&quot; &lt;<a href=3D=
"mailto:bob.liu@oracle.com">bob.liu@oracle.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On 12/24/2013 03:45 PM, Joonsoo Kim wrote:<br>
&gt; &gt; On Tue, Dec 24, 2013 at 03:07:05PM +0900, Joonsoo Kim wrote:<br>
&gt; &gt;&gt; On Mon, Dec 23, 2013 at 10:01:10PM -0500, Sasha Levin wrote:<=
br>
&gt; &gt;&gt;&gt; On 12/23/2013 09:51 PM, Joonsoo Kim wrote:<br>
&gt; &gt;&gt;&gt;&gt; On Mon, Dec 23, 2013 at 12:24:02PM -0500, Sasha Levin=
 wrote:<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; Ping?<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt;&gt; I&#39;ve also Cc&#39;ed the &quot;this page s=
houldn&#39;t be locked at all&quot; team.<br>
&gt; &gt;&gt;&gt;&gt; Hello,<br>
&gt; &gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt; I can&#39;t find the reason of this problem.<br>
&gt; &gt;&gt;&gt;&gt; If it is reproducible, how about bisecting?<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; While it reproduces under fuzzing it&#39;s pretty hard to=
 bisect it with<br>
&gt; &gt;&gt;&gt; the amount of issues uncovered by trinity recently.<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; I can add any debug code to the site of the BUG if that h=
elps.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Good!<br>
&gt; &gt;&gt; It will be helpful to add dump_page() in migration_entry_to_p=
age().<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Thanks.<br>
&gt; &gt;&gt;<br>
&gt; &gt;<br>
&gt; &gt; Minchan teaches me that there is possible race condition between<=
br>
&gt; &gt; fork and migration.<br>
&gt; &gt;<br>
&gt; &gt; Please consider following situation.<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Process A (do migration) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Process B (parents) Process C (child)=
<br>
&gt; &gt;<br>
&gt; &gt; try_to_unmap() for migration &lt;begin&gt; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0fork<br>
&gt; &gt; setup migration entry to B&#39;s vma<br>
&gt; &gt; ...<br>
&gt; &gt; try_to_unmap() for migration &lt;end&gt;<br>
&gt; &gt; move_to_new_page()<br>
&gt; &gt;<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 link new vma<br>
&gt; &gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 into interval tree<br>
&gt; &gt; remove_migration_ptes() &lt;begin&gt;<br>
&gt; &gt; check and clear migration entry on C&#39;s vma<br>
&gt; &gt; ... =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 copy_one_pte:<br>
&gt; &gt; ... =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 now, B and C have migration entry<br>
&gt; &gt; ...<br>
&gt; &gt; ...<br>
&gt; &gt; check and clear migration entry on B&#39;s vma<br>
&gt; &gt; ...<br>
&gt; &gt; ...<br>
&gt; &gt; remove_migration_ptes() &lt;end&gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Eventually, migration entry on C&#39;s vma is left.<br>
&gt; &gt; And then, when C exits, above BUG_ON() can be triggered.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Yes, Looks like this is a potential race condition.<br>
&gt;<br>
&gt; &gt; I&#39;m not sure the I am right, so please think of it together. =
:)<br>
&gt; &gt; And I&#39;m not sure again that above assumption is related to th=
is trigger report,<br>
&gt; &gt; since this may exist for a long time.<br>
&gt; &gt;<br>
&gt; &gt; So my question to mm folks is is above assumption possible and do=
 we have<br>
&gt; &gt; any protection mechanism on this race?<br>
&gt; &gt;<br>
&gt;<br>
&gt; I think we can down_read(&amp;mm-&gt;mmap_sem) before remove_migration=
_ptes()<br>
&gt; to fix this issue, but I don&#39;t have time to verify it currently.<b=
r>
&gt;<br>
&gt; --<br>
&gt; Regards,<br>
&gt; -Bob<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =C2=A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/">http://www.linux-mm.org/</a>=
 .<br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
</p>

--14dae934088b874d3c04ee6990d2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
