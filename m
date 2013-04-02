Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 412B06B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 07:32:34 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id hv10so289206vcb.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 04:32:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1364836882-9713-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1364836882-9713-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1364836882-9713-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 2 Apr 2013 20:32:33 +0900
Message-ID: <CABOkKT0uceznvR0bKx79GB5HSEbWA2vp0G5dAjg6V23O3anS7w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] hugetlbfs: stop setting VM_DONTDUMP in
 initializing vma(VM_HUGETLB)
From: HATAYAMA Daisuke <d.hatayama@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b6dc9a8eaba7404d95f172e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

--047d7b6dc9a8eaba7404d95f172e
Content-Type: text/plain; charset=ISO-8859-1

2013/4/2 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> Currently we fail to include any data on hugepages into coredump,
> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> mm->reserved_vm counter". This looks to me a serious regression,
> so let's fix it.
>
> ChangeLog v2:
>  - add 'return 0' in hugepage memory check
>
<cut>

> @@ -1137,6 +1137,7 @@ static unsigned long vma_dump_size(struct
> vm_area_struct *vma,
>                         goto whole;
>                 if (!(vma->vm_flags & VM_SHARED) &&
> FILTER(HUGETLB_PRIVATE))
>                         goto whole;
> +               return 0;
>         }
>

You should split this part into another patch. This fix is orthogonal to
the bug this patch tries to fix.

The bug you're trying to fix implicitly here is the filtering behaviour
that doesn't follow
the description in Documentation/filesystems/proc.txt that:

  Note bit 0-4 doesn't effect any hugetlb memory. hugetlb memory are only
  effected by bit 5-6.

Right?

Thanks.
HATAYAMA, Daisuke

--047d7b6dc9a8eaba7404d95f172e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2013/4/2 Naoya Horiguchi <span dir=3D"lt=
r">&lt;<a href=3D"mailto:n-horiguchi@ah.jp.nec.com" target=3D"_blank">n-hor=
iguchi@ah.jp.nec.com</a>&gt;</span><br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Currently we fail to include any data on hugepages into coredump,<br>
because VM_DONTDUMP is set on hugetlbfs&#39;s vma. This behavior was recent=
ly<br>
introduced by commit 314e51b98 &quot;mm: kill vma flag VM_RESERVED and<br>
mm-&gt;reserved_vm counter&quot;. This looks to me a serious regression,<br=
>
so let&#39;s fix it.<br>
<br>
ChangeLog v2:<br>
=A0- add &#39;return 0&#39; in hugepage memory check<br></blockquote><div>&=
lt;cut&gt; <br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
@@ -1137,6 +1137,7 @@ static unsigned long vma_dump_size(struct vm_area_str=
uct *vma,<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto whole;<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(vma-&gt;vm_flags &amp; VM_SHARED) &am=
p;&amp; FILTER(HUGETLB_PRIVATE))<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto whole;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
=A0 =A0 =A0 =A0 }<br></blockquote><div><br>You should split this part into =
another patch. This fix is orthogonal to the bug this patch tries to fix.<b=
r><br>The bug you&#39;re trying to fix implicitly here is the filtering beh=
aviour that doesn&#39;t follow<br>
the description in Documentation/filesystems/proc.txt that:<br><br>=A0 Note=
 bit 0-4 doesn&#39;t effect any hugetlb memory. hugetlb memory are only<br>=
=A0 effected by bit 5-6.<br><br>Right?<br><br>Thanks.<br>HATAYAMA, Daisuke<=
br>
<br></div></div><div style id=3D"__af745f8f43-e961-4b88-8424-80b67790c964__=
"></div>

--047d7b6dc9a8eaba7404d95f172e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
