Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 026B76B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:11:53 -0400 (EDT)
Received: by igbos3 with SMTP id os3so25434843igb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:11:52 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id i80si10353858ioi.31.2015.06.15.11.11.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 11:11:52 -0700 (PDT)
Received: by igbos3 with SMTP id os3so25434564igb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 11:11:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434388931-24487-2-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
	<1434388931-24487-2-git-send-email-aarcange@redhat.com>
Date: Mon, 15 Jun 2015 08:11:50 -1000
Message-ID: <CA+55aFzdZJw7Ot7=PYyyskNhkv=H+NPzoF6rKtb6oMyzkuQ-=Q@mail.gmail.com>
Subject: Re: [PATCH 1/7] userfaultfd: require UFFDIO_API before other ioctls
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=001a113feefc6280fe05189264ce
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Paolo Bonzini <pbonzini@redhat.com>, qemu-devel@nongnu.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, zhang.zhanghailiang@huawei.com, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Peter Feiner <pfeiner@google.com>, Mel Gorman <mgorman@suse.de>, kvm@vger.kernel.org

--001a113feefc6280fe05189264ce
Content-Type: text/plain; charset=UTF-8

On Jun 15, 2015 7:22 AM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
>
> +       if (cmd != UFFDIO_API) {
> +               if (ctx->state == UFFD_STATE_WAIT_API)
> +                       return -EINVAL;
> +               BUG_ON(ctx->state != UFFD_STATE_RUNNING);
> +       }

NAK.

Once again: we don't add BUG_ON() as some kind of assert. If your
non-critical code has s bug in it, you do WARN_ONCE() and you return. You
don't kill the machine just because of some "this can't happen" situation.

It turns out "this can't happen" happens way too often, just because code
changes, or programmers didn't think all the cases through. And killing the
machine is just NOT ACCEPTABLE.

People need to stop adding machine-killing checks to code that just doesn't
merit killing the machine.

And if you are so damn sure that it really cannot happen ever, then you
damn well had better remove the test too!

BUG_ON is not a debugging tool, or a "I think this would be bad" helper.

    Linus

--001a113feefc6280fe05189264ce
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 15, 2015 7:22 AM, &quot;Andrea Arcangeli&quot; &lt;<a href=3D"mailto=
:aarcange@redhat.com">aarcange@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (cmd !=3D UFFDIO_API) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ctx-&gt;st=
ate =3D=3D UFFD_STATE_WAIT_API)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return -EINVAL;<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(ctx-&gt=
;state !=3D UFFD_STATE_RUNNING);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}</p>
<p dir=3D"ltr">NAK. </p>
<p dir=3D"ltr">Once again: we don&#39;t add BUG_ON() as some kind of assert=
. If your non-critical code has s bug in it, you do WARN_ONCE() and you ret=
urn. You don&#39;t kill the machine just because of some &quot;this can&#39=
;t happen&quot; situation.</p>
<p dir=3D"ltr">It turns out &quot;this can&#39;t happen&quot; happens way t=
oo often, just because code changes, or programmers didn&#39;t think all th=
e cases through. And killing the machine is just NOT ACCEPTABLE.</p>
<p dir=3D"ltr">People need to stop adding machine-killing checks to code th=
at just doesn&#39;t merit killing the machine.</p>
<p dir=3D"ltr">And if you are so damn sure that it really cannot happen eve=
r, then you damn well had better remove the test too!</p>
<p dir=3D"ltr">BUG_ON is not a debugging tool, or a &quot;I think this woul=
d be bad&quot; helper.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 Linus</p>

--001a113feefc6280fe05189264ce--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
