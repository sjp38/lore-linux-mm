Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD1C48D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 21:05:42 -0500 (EST)
Received: by vxk12 with SMTP id 12so43887vxk.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 18:05:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com>
References: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com>
	<alpine.DEB.2.00.1103111258340.31216@chino.kir.corp.google.com>
Date: Fri, 11 Mar 2011 18:05:39 -0800
Message-ID: <AANLkTiniwDx0wjYT439JSBuT=DA12OF_eAVQ782GfJ7W@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
From: Anand Mitra <anand.mitra@gmail.com>
Content-Type: multipart/alternative; boundary=20cf3071cb2ae545c7049e3f8398
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Prasad Joshi <prasadjoshi124@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

--20cf3071cb2ae545c7049e3f8398
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Mar 11, 2011 at 1:01 PM, David Rientjes <rientjes@google.com> wrote:
>
>
> You're going to run into trouble by hard-wiring __GFP_REPEAT into all of
> the pte allocations because if GFP_NOFS is used then direct reclaim will
> usually fail (see the comment for do_try_to_free_pages(): If the caller is
> !__GFP_FS then the probability of a failure is reasonably high) and, if
> it does so continuously, then the page allocator will loop forever.  This
> bit should probably be moved a level higher in your architecture changes
> to the caller passing GFP_KERNEL.
>

I'll repeat my understanding of the scenario you have pointed out to
make sure we have understood you correctly.

On the broad level the changes will cause a __GFP_NOFS flag to be
present in pte allocation which were earlier absent. The impact of
this is serious when both __GFP_REPEAT and __GFP_NOFS is set because

1) __GFP_NOFS will result in very few pages being reclaimed (can't go
   to the filesystems)
2) __GFP_REPEAT will cause both the reclaim and allocation to retry
   more aggressively if not indefinitely based on the influence the
   flag in functions should_alloc_retry & should_continue_reclaim

Effectively we need memory for use by the filesystem but we can't go
back to the filesystem to claim it. Without the suggested patch we
would actually try to claim space from the filesystem which would work
most of the times but would deadlock occasionally. With the suggested
patch as you have pointed out we can possibly get into a low memory
hang. I am not sure there is a way out of this, should this be
considered as genuinely low memory condition out of which the system
might or might not crawl out of ?

regards
-- 
Anand Mitra

--20cf3071cb2ae545c7049e3f8398
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote"><br></div><div class=3D"gmail_quote">On Fri, Mar=
 11, 2011 at 1:01 PM, David Rientjes <span dir=3D"ltr">&lt;<a href=3D"mailt=
o:rientjes@google.com">rientjes@google.com</a>&gt;</span> wrote:<blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">
<br>
</div>You&#39;re going to run into trouble by hard-wiring __GFP_REPEAT into=
 all of<br>
the pte allocations because if GFP_NOFS is used then direct reclaim will<br=
>
usually fail (see the comment for do_try_to_free_pages(): If the caller is<=
br>
!__GFP_FS then the probability of a failure is reasonably high) and, if<br>
it does so continuously, then the page allocator will loop forever. =A0This=
<br>
bit should probably be moved a level higher in your architecture changes<br=
>
to the caller passing GFP_KERNEL.<br>
</blockquote></div><br><div><div>I&#39;ll repeat my understanding of the sc=
enario you have pointed out to</div><div>make sure we have understood you c=
orrectly.</div><div><br></div><div>On the broad level the changes will caus=
e a __GFP_NOFS flag to be</div>
<div>present in pte allocation which were earlier absent. The impact of</di=
v><div>this is serious when both __GFP_REPEAT and __GFP_NOFS is set because=
</div><div><br></div><div>1) __GFP_NOFS will result in very few pages being=
 reclaimed (can&#39;t go</div>
<div>=A0=A0 to the filesystems)</div><div>2) __GFP_REPEAT will cause both t=
he reclaim and allocation to retry</div><div>=A0=A0 more aggressively if no=
t indefinitely based on the influence the</div><div>=A0=A0 flag in function=
s should_alloc_retry &amp; should_continue_reclaim</div>
<div><br></div><div>Effectively we need memory for use by the filesystem bu=
t we can&#39;t go</div><div>back to the filesystem to claim it. Without the=
 suggested patch we</div><div>would actually try to claim space from the fi=
lesystem which would work</div>
<div>most of the times but would deadlock occasionally. With the suggested<=
/div><div>patch as you have pointed out we can possibly get into a low memo=
ry</div><div>hang. I am not sure there is a way out of this, should this be=
</div>
<div>considered as genuinely low memory condition out of which the system</=
div><div>might or might not crawl out of ?</div><div><br></div><div>regards=
</div><div>--=A0</div><div>Anand Mitra</div></div><div><br></div>

--20cf3071cb2ae545c7049e3f8398--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
