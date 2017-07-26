Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68AD86B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:52:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id z195so1358246wmz.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:52:59 -0700 (PDT)
Received: from mail-wr0-x22d.google.com (mail-wr0-x22d.google.com. [2a00:1450:400c:c0c::22d])
        by mx.google.com with ESMTPS id q15si9855400wmb.13.2017.07.26.12.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:52:58 -0700 (PDT)
Received: by mail-wr0-x22d.google.com with SMTP id 12so135852252wrb.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:52:58 -0700 (PDT)
MIME-Version: 1.0
Reply-To: dmitriyz@waymo.com
In-Reply-To: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
References: <20170726165022.10326-1-dmitriyz@waymo.com> <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
From: Dima Zavin <dmitriyz@waymo.com>
Date: Wed, 26 Jul 2017 12:52:56 -0700
Message-ID: <CAPz4a6AtLNf8sJzA2Ux-ta4B+_YLdG7OWEMvJij_Zguo0Q1sjw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/slub: fix a deadlock due to incomplete patching of cpusets_enabled()
Content-Type: multipart/alternative; boundary="001a114b42406c89a005553dcb01"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>

--001a114b42406c89a005553dcb01
Content-Type: text/plain; charset="UTF-8"

On Wed, Jul 26, 2017 at 10:02 AM, Christopher Lameter <cl@linux.com> wrote:

> On Wed, 26 Jul 2017, Dima Zavin wrote:
>
> > The fix is to cache the value that's returned by cpusets_enabled() at the
> > top of the loop, and only operate on the seqlock (both begin and retry)
> if
> > it was true.
>
> I think the proper fix would be to ensure that the calls to
> read_mems_allowed_{begin,retry} cannot cause the deadlock. Otherwise you
> have to fix this in multiple places.
>
> Maybe read_mems_allowed_* can do some form of synchronization or *_retry
> can implictly rely on the results of cpusets_enabled() by *_begin?
>

Thanks for the quick reply!

I can turn the cookie into a uint64, put the sequence into the low order 32
bits and put the enabled state into bit 33 (or 63 :) ). Then retry will not
query cpusets_enabled() and will just look at the enabled bit. This means
that *_retry will always have a conditional jump (i.e. lose the whole
static_branch optimization) but maybe that's ok since that's pretty rare
and the *_begin() will still benefit from it?

--Dima

--001a114b42406c89a005553dcb01
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Wed, Jul 26, 2017 at 10:02 AM, Christopher Lameter <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:cl@linux.com" target=3D"_blank">cl@linux.com</a>&gt;=
</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Wed, 2=
6 Jul 2017, Dima Zavin wrote:<br>
<br>
&gt; The fix is to cache the value that&#39;s returned by cpusets_enabled()=
 at the<br>
&gt; top of the loop, and only operate on the seqlock (both begin and retry=
) if<br>
&gt; it was true.<br>
<br>
</span>I think the proper fix would be to ensure that the calls to<br>
read_mems_allowed_{begin,<wbr>retry} cannot cause the deadlock. Otherwise y=
ou<br>
have to fix this in multiple places.<br>
<br>
Maybe read_mems_allowed_* can do some form of synchronization or *_retry<br=
>
can implictly rely on the results of cpusets_enabled() by *_begin?<br></blo=
ckquote><div><br></div><div>Thanks for the quick reply!</div><div><br></div=
><div>I can turn the cookie into a uint64, put the sequence into the low or=
der 32 bits and put the enabled state into bit 33 (or 63 :) ). Then retry w=
ill not query cpusets_enabled() and will just look at the enabled bit. This=
 means that *_retry will always have a conditional jump (i.e. lose the whol=
e static_branch optimization) but maybe that&#39;s ok since that&#39;s pret=
ty rare and the *_begin() will still benefit from it?</div><div><br></div><=
div>--Dima</div></div></div></div>

--001a114b42406c89a005553dcb01--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
