Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 83EE66B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 22:05:24 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so4122584pdj.30
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 19:05:23 -0700 (PDT)
Received: by mail-vb0-f54.google.com with SMTP id q14so2878539vbe.13
        for <linux-mm@kvack.org>; Sat, 28 Sep 2013 19:05:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380288468-5551-30-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
	<1380288468-5551-30-git-send-email-mgorman@suse.de>
Date: Sun, 29 Sep 2013 10:05:21 +0800
Message-ID: <CAF7GXvrYaHhGHn5ASb1AA78=m5uKNuza=K0Ddsq0mCp1N8gNSQ@mail.gmail.com>
Subject: Re: [PATCH 29/63] sched: Set preferred NUMA node based on number of
 private faults
From: "Figo.zhang" <figo1802@gmail.com>
Content-Type: multipart/alternative; boundary=001a1132e6e2e27d0a04e77c267a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--001a1132e6e2e27d0a04e77c267a
Content-Type: text/plain; charset=ISO-8859-1

> @@ -2317,8 +2319,8 @@ int mpol_misplaced(struct page *page, struct
> vm_area_struct *vma, unsigned long
>                  * it less likely we act on an unlikely task<->page
>                  * relation.
>                  */
> -               last_nid = page_nid_xchg_last(page, polnid);
> -               if (last_nid != polnid)
> +               last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
> +               if (!nidpid_pid_unset(last_nidpid) &&
> nidpid_to_nid(last_nidpid) != polnid)
>                         goto out;
>         }
>
>
Suppose that the first accessed page it will check the "if (curnid !=
polnid)" and maybe migrate the page later.
so maybe modify like that:

+               last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
+               if  (nidpid_pid_unset(last_nidpid))
+                     goto out;
+               else if (nidpid_to_nid(last_nidpid) != polnid)
                        goto out;

Best,
Figo.zhang

--001a1132e6e2e27d0a04e77c267a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex=
;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style=
:solid;padding-left:1ex">
<br>
@@ -2317,8 +2319,8 @@ int mpol_misplaced(struct page *page, struct vm_area_=
struct *vma, unsigned long<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it less likely we act on an unlikely t=
ask&lt;-&gt;page<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* relation.<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 last_nid =3D page_nid_xchg_last(page, polnid)=
;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (last_nid !=3D polnid)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 last_nidpid =3D page_nidpid_xchg_last(page, t=
his_nidpid);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!nidpid_pid_unset(last_nidpid) &amp;&amp;=
 nidpid_to_nid(last_nidpid) !=3D polnid)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
=A0 =A0 =A0 =A0 }<br>
<br></blockquote><div><br></div><div>Suppose that the first accessed page i=
t will check the &quot;if (curnid !=3D polnid)&quot; and maybe migrate the =
page later.</div><div>so maybe modify like that:</div><div><br></div><div>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 last_nidpid =3D page_nidpid_xchg_last(page, t=
his_nidpid);<br></div><div>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if =A0(nidpid_pid_=
unset(last_nidpid))</div><div>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 got=
o out;</div><div>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (nidpid_to_nid(last_=
nidpid) !=3D polnid)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br></div><div><br=
></div><div>Best,</div><div>Figo.zhang</div><div>=A0=A0</div></div></div></=
div>

--001a1132e6e2e27d0a04e77c267a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
