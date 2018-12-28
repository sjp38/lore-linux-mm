Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E7BDC43387
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 16:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9048D20873
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 16:56:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=digitalocean.com header.i=@digitalocean.com header.b="VdfDe9Ns"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9048D20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=digitalocean.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA1508E0048; Fri, 28 Dec 2018 11:56:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E771F8E0001; Fri, 28 Dec 2018 11:56:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8D908E0048; Fri, 28 Dec 2018 11:56:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id AEFF28E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 11:56:51 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id 73so13001723oth.9
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 08:56:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mFIOl1zzXIqjbAiRSganjvLWLNVSiwC6Zd61prutwDU=;
        b=nwyZhPPRUPG7bTXHVeQren80by6aisy8uZDFcuhXF56CX2HkaaQgPp6SFAvSuTT4P0
         TZh+ESy5BHd3QHwJxH3Hb1o3NN9/xBESIru0XshI/QTlCR/8XRGcZLMcCAbro8vVxdIF
         BnYKV9YNXfvGTxQDbdQRRefCHoE+3UcarEVKybmGsJjg9RUBs0gozxnsIW5LUXdJE/cc
         CC5LVm0stDi2F6CLK6M5//V0uqx7ysE/87Vhwcp8Ozygwe8V42ypk4l3l6VPgCQkTre6
         9loioN9Ord3EVemCBuvjX3G6tQCKjOSoFu2afXm/TNMH9wGjQaVcu3CR0DkPwNbUSi7T
         /2lw==
X-Gm-Message-State: AA+aEWYz3t3B4nOGYkY86TEHGbQ0VNnLlQz5HjKE5Yp06Q30vhK0kwwH
	GV2W4QNZPqjQYNOYIpFc917yt98L5e/dKQhqgZqRWxPFizs2pDPtchb/K91V0LvEy7TKI0Zrn3P
	XmAWiUP4VwFZT+gjkMnJrGkezu2Ry/d4og9Ds1EJmXjk+H0KJN15VzQAHbZEHFH6xxDzR/H/zFv
	xoSVDi9rTlnUg9ZnUa7GrM2rHFIgiHdKLomrugqoJGnFGHZBGCMmeF2rqg2Ux3Z5YoaaeRONCiu
	f3gcbTbuBjaL9faJ4IehWAvat/QC+B4x7xWsQfYekuhVEciR3mYie1An61vFhfZgo2xdnGpBEI1
	BVo7mobroQrZsdaWrTCcPtpMCXyInjZcYntlMule2dhvKO2kp/ICJNUBxjqUBXunSL4mscUOtDO
	t
X-Received: by 2002:aca:5d57:: with SMTP id r84mr18821307oib.243.1546016211304;
        Fri, 28 Dec 2018 08:56:51 -0800 (PST)
X-Received: by 2002:aca:5d57:: with SMTP id r84mr18821283oib.243.1546016210494;
        Fri, 28 Dec 2018 08:56:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546016210; cv=none;
        d=google.com; s=arc-20160816;
        b=iyNKyzYf0m5I59FeeDQXLvPRMsyo+MgnCZ4n7X4o9RjksGs6/sLFemvdmrD1W2255X
         6gFZqI02aypHLAeaoZAaFtR9NfxRbiNrUTgVJFXkrFP0eDreXvaZtnZUjeYKhBILWgEq
         OyOnIU6vmZu42MwfENyKGao9upWm58yprZcYZHDQjKGFAeK/A7ZNNagJQRtJBBusQAv9
         DnWvytto76vmRs4gIn0mYImwKhpEDcun8kzx2UNxXv2LP2lIFUc5dgGWopTsMPpF857f
         9rTOZJ0R/u40ohDRXlb62An2vdsP8KsrG0MgFU1ftl1W9mUy61z0GMUl+4WGUfE0QHAL
         335w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mFIOl1zzXIqjbAiRSganjvLWLNVSiwC6Zd61prutwDU=;
        b=hh7wHLIQrsMdlMoCwp3YyuCtKXr9eRqeNze8tExPXLrQJzxvZdpCXHotb/zo6qeLLD
         txuVLMqIkS9bgdp3LV65GsF2YMz//6IIt00IzfceNP7qKTnfXfsMTPgrw6X8sO5Q0vWF
         xGV3C24TUe/Nr7jDxZOmWq0Kn/sj6PGj0zr74z0YLhNlYhPxYwkZ78B9TnESvoBp6KC9
         uyOM3Ufqsp0Ii+PDAHFbk5rqi+C00TU8hGD/4cqlPFvGV3jzzB9P//NqLRWXseZRHUaT
         Twv94CSVCAp+W40MUVlvvr448NsHfr668dU2eKfZ67xnY57zfoXBzH5Cc0vvETWcbPv8
         vEZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=VdfDe9Ns;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h124sor14337287oif.44.2018.12.28.08.56.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 08:56:50 -0800 (PST)
Received-SPF: pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=VdfDe9Ns;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=digitalocean.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mFIOl1zzXIqjbAiRSganjvLWLNVSiwC6Zd61prutwDU=;
        b=VdfDe9Ns6tjzYvbiXpvdvKDqeDYFV/CIU8Um66E5O+4s53UhfV2p0sBa2i+PSjVxF2
         3f0eIH8Ue7kXTtBCBCd5hlbWvRu4umSUkQ3Doix8HYNtK7vDvBjqVigOAjy6nMdr37xl
         ae+FXzMUBZEFMBYEMYrtIbsBrfuV4H+6benVc=
X-Google-Smtp-Source: ALg8bN5icnk0BwlZAms9mc/ZQ42PYSpAiDe5eKnXFiRDoZGRMYmyoVXlRSRaRn3yMsXHihPFICcIDciHJb5nv50756M=
X-Received: by 2002:a54:4114:: with SMTP id l20mr18881291oic.110.1546016209911;
 Fri, 28 Dec 2018 08:56:49 -0800 (PST)
MIME-Version: 1.0
References: <20181226051522.28442-1-ying.huang@intel.com> <20181227185553.81928247d95418191b063d40@linux-foundation.org>
In-Reply-To: <20181227185553.81928247d95418191b063d40@linux-foundation.org>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Fri, 28 Dec 2018 11:56:39 -0500
Message-ID:
 <CANaguZDGr+WbaJ1czsOvcHCSNAyusK6KAHNhNppe_9hwQhAFtg@mail.gmail.com>
Subject: Re: [PATCH] mm, swap: Fix swapoff with KSM pages
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, 
	Shaohua Li <shli@kernel.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Hugh Dickins <hughd@google.com>, Kelley Nielsen <kelleynnn@gmail.com>
Content-Type: multipart/alternative; boundary="0000000000000256fa057e17f3b2"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228165639.h5WhTaBtuJtCb0ORmMYRCIf9KEoF2RP1D_L7YV88Yzg@z>

--0000000000000256fa057e17f3b2
Content-Type: text/plain; charset="UTF-8"

Thanks for letting me know Andrew! I shall include all the fixes in the
next iteration.

Thanks,
Vineeth

On Thu, Dec 27, 2018 at 9:55 PM Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Wed, 26 Dec 2018 13:15:22 +0800 Huang Ying <ying.huang@intel.com>
> wrote:
>
> > KSM pages may be mapped to the multiple VMAs that cannot be reached
> > from one anon_vma.  So during swapin, a new copy of the page need to
> > be generated if a different anon_vma is needed, please refer to
> > comments of ksm_might_need_to_copy() for details.
> >
> > During swapoff, unuse_vma() uses anon_vma (if available) to locate VMA
> > and virtual address mapped to the page, so not all mappings to a
> > swapped out KSM page could be found.  So in try_to_unuse(), even if
> > the swap count of a swap entry isn't zero, the page needs to be
> > deleted from swap cache, so that, in the next round a new page could
> > be allocated and swapin for the other mappings of the swapped out KSM
> > page.
> >
> > But this contradicts with the THP swap support.  Where the THP could
> > be deleted from swap cache only after the swap count of every swap
> > entry in the huge swap cluster backing the THP has reach 0.  So
> > try_to_unuse() is changed in commit e07098294adf ("mm, THP, swap:
> > support to reclaim swap space for THP swapped out") to check that
> > before delete a page from swap cache, but this has broken KSM swapoff
> > too.
> >
> > Fortunately, KSM is for the normal pages only, so the original
> > behavior for KSM pages could be restored easily via checking
> > PageTransCompound().  That is how this patch works.
> >
> > ...
> >
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -2197,7 +2197,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
> >                */
> >               if (PageSwapCache(page) &&
> >                   likely(page_private(page) == entry.val) &&
> > -                 !page_swapped(page))
> > +                 (!PageTransCompound(page) ||
> > +                  !swap_page_trans_huge_swapped(si, entry)))
> >                       delete_from_swap_cache(compound_head(page));
> >
>
> The patch "mm, swap: rid swapoff of quadratic complexity" changes this
> code significantly.  There are a few issues with that patch so I'll
> drop it for now.
>
> Vineeth, please ensure that future versions retain the above fix,
> thanks.
>
>
>

--0000000000000256fa057e17f3b2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:verdana,=
sans-serif;font-size:small">Thanks for letting me know Andrew! I shall incl=
ude all the fixes in the next iteration.</div><div class=3D"gmail_default" =
style=3D"font-family:verdana,sans-serif;font-size:small"><br></div><div cla=
ss=3D"gmail_default" style=3D"font-family:verdana,sans-serif;font-size:smal=
l">Thanks,</div><div class=3D"gmail_default" style=3D"font-family:verdana,s=
ans-serif;font-size:small">Vineeth</div></div><br><div class=3D"gmail_quote=
"><div dir=3D"ltr">On Thu, Dec 27, 2018 at 9:55 PM Andrew Morton &lt;<a hre=
f=3D"mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; wr=
ote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px=
 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Wed, 26 =
Dec 2018 13:15:22 +0800 Huang Ying &lt;<a href=3D"mailto:ying.huang@intel.c=
om" target=3D"_blank">ying.huang@intel.com</a>&gt; wrote:<br>
<br>
&gt; KSM pages may be mapped to the multiple VMAs that cannot be reached<br=
>
&gt; from one anon_vma.=C2=A0 So during swapin, a new copy of the page need=
 to<br>
&gt; be generated if a different anon_vma is needed, please refer to<br>
&gt; comments of ksm_might_need_to_copy() for details.<br>
&gt; <br>
&gt; During swapoff, unuse_vma() uses anon_vma (if available) to locate VMA=
<br>
&gt; and virtual address mapped to the page, so not all mappings to a<br>
&gt; swapped out KSM page could be found.=C2=A0 So in try_to_unuse(), even =
if<br>
&gt; the swap count of a swap entry isn&#39;t zero, the page needs to be<br=
>
&gt; deleted from swap cache, so that, in the next round a new page could<b=
r>
&gt; be allocated and swapin for the other mappings of the swapped out KSM<=
br>
&gt; page.<br>
&gt; <br>
&gt; But this contradicts with the THP swap support.=C2=A0 Where the THP co=
uld<br>
&gt; be deleted from swap cache only after the swap count of every swap<br>
&gt; entry in the huge swap cluster backing the THP has reach 0.=C2=A0 So<b=
r>
&gt; try_to_unuse() is changed in commit e07098294adf (&quot;mm, THP, swap:=
<br>
&gt; support to reclaim swap space for THP swapped out&quot;) to check that=
<br>
&gt; before delete a page from swap cache, but this has broken KSM swapoff<=
br>
&gt; too.<br>
&gt; <br>
&gt; Fortunately, KSM is for the normal pages only, so the original<br>
&gt; behavior for KSM pages could be restored easily via checking<br>
&gt; PageTransCompound().=C2=A0 That is how this patch works.<br>
&gt; <br>
&gt; ...<br>
&gt;<br>
&gt; --- a/mm/swapfile.c<br>
&gt; +++ b/mm/swapfile.c<br>
&gt; @@ -2197,7 +2197,8 @@ int try_to_unuse(unsigned int type, bool frontsw=
ap,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageSwapCach=
e(page) &amp;&amp;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0li=
kely(page_private(page) =3D=3D entry.val) &amp;&amp;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0!page_s=
wapped(page))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(!PageT=
ransCompound(page) ||<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !swap_=
page_trans_huge_swapped(si, entry)))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0delete_from_swap_cache(compound_head(page));<br>
&gt;=C2=A0 <br>
<br>
The patch &quot;mm, swap: rid swapoff of quadratic complexity&quot; changes=
 this<br>
code significantly.=C2=A0 There are a few issues with that patch so I&#39;l=
l<br>
drop it for now.<br>
<br>
Vineeth, please ensure that future versions retain the above fix,<br>
thanks.<br>
<br>
<br>
</blockquote></div>

--0000000000000256fa057e17f3b2--

