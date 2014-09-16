Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 792976B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 12:52:41 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id a13so413897igq.5
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:52:41 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id h2si2250574iga.43.2014.09.16.09.52.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 09:52:40 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id l13so5919537iga.0
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:52:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54184078.4070505@redhat.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<54184078.4070505@redhat.com>
Date: Tue, 16 Sep 2014 09:52:39 -0700
Message-ID: <CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: multipart/alternative; boundary=bcaec51867424d771a0503319470
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--bcaec51867424d771a0503319470
Content-Type: text/plain; charset=UTF-8

On Tue, Sep 16, 2014 at 6:51 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:

> Il 15/09/2014 22:11, Andres Lagar-Cavilla ha scritto:
> > +     if (!locked) {
> > +             BUG_ON(npages != -EBUSY);
>
> VM_BUG_ON perhaps?
>
Sure.


> > @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr,
> bool *async, bool write_fault,
> >               npages = get_user_page_nowait(current, current->mm,
> >                                             addr, write_fault, page);
> >               up_read(&current->mm->mmap_sem);
> > -     } else
> > -             npages = get_user_pages_fast(addr, 1, write_fault,
> > -                                          page);
> > +     } else {
> > +             /*
> > +              * By now we have tried gup_fast, and possible async_pf,
> and we
> > +              * are certainly not atomic. Time to retry the gup,
> allowing
> > +              * mmap semaphore to be relinquished in the case of IO.
> > +              */
> > +             npages = kvm_get_user_page_retry(current, current->mm,
> addr,
> > +                                              write_fault, page);
>
> This is a separate logical change.  Was this:
>
>         down_read(&mm->mmap_sem);
>         npages = get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
>         up_read(&mm->mmap_sem);
>
> the intention rather than get_user_pages_fast?
>

Nope. The intention was to pass FAULT_FLAG_RETRY to the vma fault handler
(without _NOWAIT). And once you do that, if you come back without holding
the mmap sem, you need to call yet again.

By that point in the call chain I felt comfortable dropping the _fast. All
paths that get there have already tried _fast (and some have tried _NOWAIT).


> I think a first patch should introduce kvm_get_user_page_retry ("Retry a
> fault after a gup with FOLL_NOWAIT.") and the second would add
> FOLL_TRIED ("This properly relinquishes mmap semaphore if the
> filemap/swap has to wait on page lock (and retries the gup to completion
> after that").
>

That's not what FOLL_TRIED does. The relinquishing of mmap semaphore is
done by this patch minus the FOLL_TRIED bits. FOLL_TRIED will let the fault
handler (e.g. filemap) know that we've been there and waited on the IO
already, so in the common case we won't need to redo the IO.

Have a look at how FAULT_FLAG_TRIED is used in e.g. arch/x86/mm/fault.c.


>
> Apart from this, the patch looks good.  The mm/ parts are minimal, so I
> think it's best to merge it through the KVM tree with someone's Acked-by.
>

Thanks!
Andres


>
> Paolo
>



-- 
Andres Lagar-Cavilla | Google Cloud Platform | andreslc@google.com |
 647-778-4380

--bcaec51867424d771a0503319470
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
ue, Sep 16, 2014 at 6:51 AM, Paolo Bonzini <span dir=3D"ltr">&lt;<a href=3D=
"mailto:pbonzini@redhat.com" target=3D"_blank">pbonzini@redhat.com</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">Il 15/09/2014 22:11, Andres=
 Lagar-Cavilla ha scritto:<br>
<span class=3D"">&gt; +=C2=A0 =C2=A0 =C2=A0if (!locked) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(npages !=3D -E=
BUSY);<br>
<br>
</span>VM_BUG_ON perhaps?<br></blockquote><div>Sure.</div><div><br></div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex">
<span class=3D""><br>
&gt; @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr, =
bool *async, bool write_fault,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0npages =3D get_u=
ser_page_nowait(current, current-&gt;mm,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0addr, write_fault, page);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&amp;cur=
rent-&gt;mm-&gt;mmap_sem);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0} else<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0npages =3D get_user_p=
ages_fast(addr, 1, write_fault,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 page);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * By now we have tri=
ed gup_fast, and possible async_pf, and we<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * are certainly not =
atomic. Time to retry the gup, allowing<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * mmap semaphore to =
be relinquished in the case of IO.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0npages =3D kvm_get_us=
er_page_retry(current, current-&gt;mm, addr,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 write_fault, page);<br>
<br>
</span>This is a separate logical change.=C2=A0 Was this:<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 down_read(&amp;mm-&gt;mmap_sem);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 npages =3D get_user_pages(NULL, mm, addr, 1, 1,=
 0, NULL, NULL);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 up_read(&amp;mm-&gt;mmap_sem);<br>
<br>
the intention rather than get_user_pages_fast?<br></blockquote><div><br></d=
iv><div>Nope. The intention was to pass FAULT_FLAG_RETRY to the vma fault h=
andler (without _NOWAIT). And once you do that, if you come back without ho=
lding the mmap sem, you need to call yet again.</div><div><br></div><div>By=
 that point in the call chain I felt comfortable dropping the _fast. All pa=
ths that get there have already tried _fast (and some have tried _NOWAIT).<=
/div><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
I think a first patch should introduce kvm_get_user_page_retry (&quot;Retry=
 a<br>
fault after a gup with FOLL_NOWAIT.&quot;) and the second would add<br>
FOLL_TRIED (&quot;This properly relinquishes mmap semaphore if the<br>
filemap/swap has to wait on page lock (and retries the gup to completion<br=
>
after that&quot;).<br></blockquote><div><br></div><div>That&#39;s not what =
FOLL_TRIED does. The relinquishing of mmap semaphore is done by this patch =
minus the FOLL_TRIED bits. FOLL_TRIED will let the fault handler (e.g. file=
map) know that we&#39;ve been there and waited on the IO already, so in the=
 common case we won&#39;t need to redo the IO.</div><div><br></div><div>Hav=
e a look at how FAULT_FLAG_TRIED is used in e.g. arch/x86/mm/fault.c.</div>=
<div>=C2=A0<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Apart from this, the patch looks good.=C2=A0 The mm/ parts are minimal, so =
I<br>
think it&#39;s best to merge it through the KVM tree with someone&#39;s Ack=
ed-by.<br></blockquote><div><br></div><div>Thanks!</div><div>Andres</div><d=
iv>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex">
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Paolo<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div dir=3D"ltr"><span style=3D"color:rgb(85,85,85);font-family:sans-seri=
f;font-size:small;line-height:19.5px;border-width:2px 0px 0px;border-style:=
solid;border-color:rgb(213,15,37);padding-top:2px;margin-top:2px">Andres La=
gar-Cavilla=C2=A0|</span><span style=3D"color:rgb(85,85,85);font-family:san=
s-serif;font-size:small;line-height:19.5px;border-width:2px 0px 0px;border-=
style:solid;border-color:rgb(51,105,232);padding-top:2px;margin-top:2px">=
=C2=A0Google Cloud Platform=C2=A0|</span><span style=3D"color:rgb(85,85,85)=
;font-family:sans-serif;font-size:small;line-height:19.5px;border-width:2px=
 0px 0px;border-style:solid;border-color:rgb(0,153,57);padding-top:2px;marg=
in-top:2px">=C2=A0<a href=3D"mailto:andreslc@google.com" target=3D"_blank">=
andreslc@google.com</a>=C2=A0|</span><span style=3D"color:rgb(85,85,85);fon=
t-family:sans-serif;font-size:small;line-height:19.5px;border-width:2px 0px=
 0px;border-style:solid;border-color:rgb(238,178,17);padding-top:2px;margin=
-top:2px">=C2=A0647-778-4380</span><br></div>
</div></div>

--bcaec51867424d771a0503319470--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
