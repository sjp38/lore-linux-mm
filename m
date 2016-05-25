Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEB76B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 05:25:07 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id m81so101804043vka.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 02:25:07 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id q68si6836932qkb.227.2016.05.25.02.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 02:25:05 -0700 (PDT)
Received: by mail-qk0-x22b.google.com with SMTP id x7so29979279qkd.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 02:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160518144148.GD21200@dastard>
References: <D64A3952-53D8-4B9D-98A1-C99D7E231D42@gmail.com>
	<573C2BB6.6070801@suse.cz>
	<78A99337-5542-4E59-A648-AB2A328957D3@gmail.com>
	<20160518144148.GD21200@dastard>
Date: Wed, 25 May 2016 17:25:05 +0800
Message-ID: <CAGbZs7j=c=eRYFGvpv5NRhKs16Vq-cQTcbTZTKa4xKP4QGRuzQ@mail.gmail.com>
Subject: Re: why the kmalloc return fail when there is free physical address
 but return success after dropping page caches
From: =?UTF-8?B?6ZmI5a6X5b+X?= <baotiao@gmail.com>
Content-Type: multipart/alternative; boundary=001a114f3f28c05c7b0533a73f88
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

--001a114f3f28c05c7b0533a73f88
Content-Type: text/plain; charset=UTF-8

Hi Dave

> >> The machine's status is describe as blow:
> >>
> >> the machine has 96 physical memory. And the real use memory is about
> >> 64G, and the page cache use about 32G. we also use the swap area, at
> >> that time we have about 10G(we set the swap max size to 32G). At that
> >> moment, we find xfs report
> >>
> >> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation
> >> deadlock in kmem_alloc (mode:0x250) |

Pretty sure that's a GFP_NOFS allocation context.

You are right, it is a GFP_NOFS operator from the xfs,  xfs use GFP_NOFS
flag to avoid recursive filesystem call


> > Just once, or many times?
>
> the message appear many times
> from the code, I know that xfs will try 100 time of kmalloc() function

The curent upstream kernels report much more information - process,
size of allocation, etc.

In general, the cause of such problems is memory fragmentation
preventing a large contiguous allocation from taking place (e.g.
when you try to read a file with millions of extents).

> >> in the system. But there is still 32G page cache.
> >>
> >> So I run
> >>
> >> |echo 3 > /proc/sys/vm/drop_caches |
> >>
> >> to drop the page cache.
> >>
> >> Then the system is fine.
> >
> > Are you saying that the error message was repeated infinitely until you
did the drop_caches?
>
>
> No. the error message don't appear after I drop_cache.


Yes, you are right, before I echo 3 > /proc/sys/vm/drop_caches, the
/proc/buddyinfo is list blow:
Node 0, zone      DMA      0      0      0      1      2      1      1
0      1      1      3
Node 0, zone    DMA32   2983   2230   1037    290    121     63     47
61     16      0      0
Node 0, zone   Normal  13707   1126    285    268    291    160     64
21     11      0      0
Node 1, zone   Normal  10678   5041   1167    705    316    158     61
22      0      0      0


after the operator the /proc/buddyinfo is list blow:
Node 0, zone      DMA      0      0      0      1      2      1      1
0      1      1      3
Node 0, zone    DMA32  61091  22791   3659    348    169     81     89
63     16      0      0
Node 0, zone   Normal 781723 532596 246195  57076   9853   4061   1922
799    217     19      0
Node 1, zone   Normal 334903 138984  49608   6929   2770   1603    843
447    232      2      0


we can find that after the operator, we get more large size pages

beside the /proc/buddyinfo, is there any other command the get the memory
fragmentation info?

And beside the drop_caches operator, is there any other command can avoid
the memory fragmentation?




IIRC, the reason the system can't recover itself is that memory
compaction is not triggered from GFP_NOFS allocation context, which
means memory reclaim won't try to create contiguous regions by
moving things around and hence the allocation will not succeed until
a significant amount of memory is freed by some other trigger....


The GFP_NOFS will not triggered memory compaction, where can I find the
logic in kernel source code?

thank you

On Wed, May 18, 2016 at 10:41 PM, Dave Chinner <david@fromorbit.com> wrote:

> On Wed, May 18, 2016 at 04:58:31PM +0800, baotiao wrote:
> > Thanks for your reply
> >
> > >> Hello every, I meet an interesting kernel memory problem. Can anyone
> > >> help me explain what happen under the kernel
> > >
> > > Which kernel version is that?
> >
> > The kernel version is 3.10.0-327.4.5.el7.x86_64
>
> RHEL7 kernel. Best you report the problem to your RH support
> contact - the RHEL7 kernels are far different to upstream kernels..
>
> > >> The machine's status is describe as blow:
> > >>
> > >> the machine has 96 physical memory. And the real use memory is about
> > >> 64G, and the page cache use about 32G. we also use the swap area, at
> > >> that time we have about 10G(we set the swap max size to 32G). At that
> > >> moment, we find xfs report
> > >>
> > >> |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory allocation
> > >> deadlock in kmem_alloc (mode:0x250) |
>
> Pretty sure that's a GFP_NOFS allocation context.
>
> > > Just once, or many times?
> >
> > the message appear many times
> > from the code, I know that xfs will try 100 time of kmalloc() function
>
> The curent upstream kernels report much more information - process,
> size of allocation, etc.
>
> In general, the cause of such problems is memory fragmentation
> preventing a large contiguous allocation from taking place (e.g.
> when you try to read a file with millions of extents).
>
> > >> in the system. But there is still 32G page cache.
> > >>
> > >> So I run
> > >>
> > >> |echo 3 > /proc/sys/vm/drop_caches |
> > >>
> > >> to drop the page cache.
> > >>
> > >> Then the system is fine.
> > >
> > > Are you saying that the error message was repeated infinitely until
> you did the drop_caches?
> >
> >
> > No. the error message don't appear after I drop_cache.
>
> Of course - freeing memory will cause contiguous free space to
> reform. then the allocation will succeed.
>
> IIRC, the reason the system can't recover itself is that memory
> compaction is not triggered from GFP_NOFS allocation context, which
> means memory reclaim won't try to create contiguous regions by
> moving things around and hence the allocation will not succeed until
> a significant amount of memory is freed by some other trigger....
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
>



-- 
---
Blog: http://www.chenzongzhi.info
Twitter: https://twitter.com/baotiao <https://twitter.com/#%21/baotiao>
Git: https://github.com/baotiao

--001a114f3f28c05c7b0533a73f88
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Dave<br><br><span class=3D"">&gt; &gt;&gt; The machine&=
#39;s status is describe as blow:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; the machine has 96 physical memory. And the real use memory i=
s about<br>
&gt; &gt;&gt; 64G, and the page cache use about 32G. we also use the swap a=
rea, at<br>
&gt; &gt;&gt; that time we have about 10G(we set the swap max size to 32G).=
 At that<br>
&gt; &gt;&gt; moment, we find xfs report<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory a=
llocation<br>
&gt; &gt;&gt; deadlock in kmem_alloc (mode:0x250) |<br>
<br>
</span>Pretty sure that&#39;s a GFP_NOFS allocation context.<br><br>You are=
 right, it is a GFP_NOFS operator from the xfs,=C2=A0 xfs use GFP_NOFS flag=
 to avoid recursive filesystem call<br><br><span class=3D""><br>
&gt; &gt; Just once, or many times?<br>
&gt;<br>
&gt; the message appear many times<br>
&gt; from the code, I know that xfs will try 100 time of kmalloc() function=
<br>
<br>
</span>The curent upstream kernels report much more information - process,<=
br>
size of allocation, etc.<br>
<br>
In general, the cause of such problems is memory fragmentation<br>
preventing a large contiguous allocation from taking place (e.g.<br>
when you try to read a file with millions of extents).<br>
<span class=3D""><br>
&gt; &gt;&gt; in the system. But there is still 32G page cache.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; So I run<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; |echo 3 &gt; /proc/sys/vm/drop_caches |<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; to drop the page cache.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Then the system is fine.<br>
&gt; &gt;<br>
&gt; &gt; Are you saying that the error message was repeated infinitely unt=
il you did the drop_caches?<br>
&gt;<br>
&gt;<br>
&gt; No. the error message don&#39;t appear after I drop_cache.<br>
<br><br>Yes, you are right, before I echo 3 &gt; /proc/sys/vm/drop_caches, =
the /proc/buddyinfo is list blow:<br>Node 0, zone=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 DMA=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 3<br>No=
de 0, zone=C2=A0=C2=A0=C2=A0 DMA32=C2=A0=C2=A0 2983=C2=A0=C2=A0 2230=C2=A0=
=C2=A0 1037=C2=A0=C2=A0=C2=A0 290=C2=A0=C2=A0=C2=A0 121=C2=A0=C2=A0=C2=A0=
=C2=A0 63=C2=A0=C2=A0=C2=A0=C2=A0 47=C2=A0=C2=A0=C2=A0=C2=A0 61=C2=A0=C2=A0=
=C2=A0=C2=A0 16=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 0<br>Node 0, zone=C2=A0=C2=A0 Normal=C2=A0 13707=C2=A0=C2=A0 1126=C2=A0=
=C2=A0=C2=A0 285=C2=A0=C2=A0=C2=A0 268=C2=A0=C2=A0=C2=A0 291=C2=A0=C2=A0=C2=
=A0 160=C2=A0=C2=A0=C2=A0=C2=A0 64=C2=A0=C2=A0=C2=A0=C2=A0 21=C2=A0=C2=A0=
=C2=A0=C2=A0 11=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 0<br>Node 1, zone=C2=A0=C2=A0 Normal=C2=A0 10678=C2=A0=C2=A0 5041=C2=A0=
=C2=A0 1167=C2=A0=C2=A0=C2=A0 705=C2=A0=C2=A0=C2=A0 316=C2=A0=C2=A0=C2=A0 1=
58=C2=A0=C2=A0=C2=A0=C2=A0 61=C2=A0=C2=A0=C2=A0=C2=A0 22=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 0<br><br><br>after the operator the /proc/buddyinfo is list blow:<br>No=
de 0, zone=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 DMA=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 3<br>Node 0, zone=C2=A0=C2=A0=C2=A0 DMA32=C2=A0 61=
091=C2=A0 22791=C2=A0=C2=A0 3659=C2=A0=C2=A0=C2=A0 348=C2=A0=C2=A0=C2=A0 16=
9=C2=A0=C2=A0=C2=A0=C2=A0 81=C2=A0=C2=A0=C2=A0=C2=A0 89=C2=A0=C2=A0=C2=A0=
=C2=A0 63=C2=A0=C2=A0=C2=A0=C2=A0 16=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 0<br>Node 0, zone=C2=A0=C2=A0 Normal 781723 532596=
 246195=C2=A0 57076=C2=A0=C2=A0 9853=C2=A0=C2=A0 4061=C2=A0=C2=A0 1922=C2=
=A0=C2=A0=C2=A0 799=C2=A0=C2=A0=C2=A0 217=C2=A0=C2=A0=C2=A0=C2=A0 19=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 0<br>Node 1, zone=C2=A0=C2=A0 Normal 334903 138984=
=C2=A0 49608=C2=A0=C2=A0 6929=C2=A0=C2=A0 2770=C2=A0=C2=A0 1603=C2=A0=C2=A0=
=C2=A0 843=C2=A0=C2=A0=C2=A0 447=C2=A0=C2=A0=C2=A0 232=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 2=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0<br><br><br>we can find that aft=
er the operator, we get more large size pages<br><br>beside the /proc/buddy=
info, is there any other command the get the memory fragmentation info?<br>=
<br>And beside the drop_caches operator, is there any other command can avo=
id the memory fragmentation?<br><br><br></span><br><br>
IIRC, the reason the system can&#39;t recover itself is that memory<br>
compaction is not triggered from GFP_NOFS allocation context, which<br>
means memory reclaim won&#39;t try to create contiguous regions by<br>
moving things around and hence the allocation will not succeed until<br>
a significant amount of memory is freed by some other trigger....<br>
<br><br>The GFP_NOFS will not triggered memory compaction, where can I find=
 the logic in kernel source code?<br><br>thank you<br><div><div class=3D"gm=
ail_extra"><br><div class=3D"gmail_quote">On Wed, May 18, 2016 at 10:41 PM,=
 Dave Chinner <span dir=3D"ltr">&lt;<a href=3D"mailto:david@fromorbit.com" =
target=3D"_blank">david@fromorbit.com</a>&gt;</span> wrote:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px sol=
id rgb(204,204,204);padding-left:1ex"><span class=3D"">On Wed, May 18, 2016=
 at 04:58:31PM +0800, baotiao wrote:<br>
&gt; Thanks for your reply<br>
&gt;<br>
&gt; &gt;&gt; Hello every, I meet an interesting kernel memory problem. Can=
 anyone<br>
&gt; &gt;&gt; help me explain what happen under the kernel<br>
&gt; &gt;<br>
&gt; &gt; Which kernel version is that?<br>
&gt;<br>
&gt; The kernel version is 3.10.0-327.4.5.el7.x86_64<br>
<br>
</span>RHEL7 kernel. Best you report the problem to your RH support<br>
contact - the RHEL7 kernels are far different to upstream kernels..<br>
<span class=3D""><br>
&gt; &gt;&gt; The machine&#39;s status is describe as blow:<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; the machine has 96 physical memory. And the real use memory i=
s about<br>
&gt; &gt;&gt; 64G, and the page cache use about 32G. we also use the swap a=
rea, at<br>
&gt; &gt;&gt; that time we have about 10G(we set the swap max size to 32G).=
 At that<br>
&gt; &gt;&gt; moment, we find xfs report<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; |Apr 29 21:54:31 w-openstack86 kernel: XFS: possible memory a=
llocation<br>
&gt; &gt;&gt; deadlock in kmem_alloc (mode:0x250) |<br>
<br>
</span>Pretty sure that&#39;s a GFP_NOFS allocation context.<br>
<span class=3D""><br>
&gt; &gt; Just once, or many times?<br>
&gt;<br>
&gt; the message appear many times<br>
&gt; from the code, I know that xfs will try 100 time of kmalloc() function=
<br>
<br>
</span>The curent upstream kernels report much more information - process,<=
br>
size of allocation, etc.<br>
<br>
In general, the cause of such problems is memory fragmentation<br>
preventing a large contiguous allocation from taking place (e.g.<br>
when you try to read a file with millions of extents).<br>
<span class=3D""><br>
&gt; &gt;&gt; in the system. But there is still 32G page cache.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; So I run<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; |echo 3 &gt; /proc/sys/vm/drop_caches |<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; to drop the page cache.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Then the system is fine.<br>
&gt; &gt;<br>
&gt; &gt; Are you saying that the error message was repeated infinitely unt=
il you did the drop_caches?<br>
&gt;<br>
&gt;<br>
&gt; No. the error message don&#39;t appear after I drop_cache.<br>
<br>
</span>Of course - freeing memory will cause contiguous free space to<br>
reform. then the allocation will succeed.<br>
<br>
IIRC, the reason the system can&#39;t recover itself is that memory<br>
compaction is not triggered from GFP_NOFS allocation context, which<br>
means memory reclaim won&#39;t try to create contiguous regions by<br>
moving things around and hence the allocation will not succeed until<br>
a significant amount of memory is freed by some other trigger....<br>
<br>
Cheers,<br>
<br>
Dave.<br>
<span class=3D""><font color=3D"#888888">--<br>
Dave Chinner<br>
<a href=3D"mailto:david@fromorbit.com">david@fromorbit.com</a><br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div clas=
s=3D"gmail_signature"><div dir=3D"ltr"><div>---<br>Blog: <a href=3D"http://=
www.chenzongzhi.info" target=3D"_blank">http://www.chenzongzhi.info</a><br>=
Twitter: <a href=3D"https://twitter.com/#%21/baotiao" target=3D"_blank">htt=
ps://twitter.com/baotiao</a><br>Git: <a href=3D"https://github.com/baotiao"=
 target=3D"_blank">https://github.com/baotiao</a><br></div></div></div>
</div></div></div>

--001a114f3f28c05c7b0533a73f88--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
