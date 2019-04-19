Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AC3EC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:41:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC1B5217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:41:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC1B5217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0A46B0003; Fri, 19 Apr 2019 04:41:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76FD46B0006; Fri, 19 Apr 2019 04:41:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685926B0007; Fri, 19 Apr 2019 04:41:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4013A6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:41:38 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id b10so1756390vkf.3
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 01:41:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=3WrZ4nrQXT6lMVdLtFrtfYLo/oaX3NjG7Uq5HMfmeoQ=;
        b=pV85RMyGfSglJvj88qHrFLAkNZaNnN6pIy5kc9exJhpOuPIvI/RKh8ELp94sgUhHjs
         JbEqNhi3nvPZOMnRGDUnxTAHtAFjK4hVxMVXvYF2GXJgUYcnFyN1Y1JZ22Eg2dX1I7i+
         Rm0Y6Tio57JGVUvdf3nw+v6E259p2gm9S88dw1gzJlMZRfN+y1brHr/V6EOBe3nKFyiH
         HJjElujt9DhFHUiat041KRfYy0G4JxpfFoPeu7QP2p0BBh0YpRxskKu9X73qK1N61mWJ
         tdjc028UeQpbusVgZ+5Vw/5THEtPzJ72aO+OQ+N3ZMyPuqEmPZGYFESn/ACNvS5qrVFL
         9NIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU9KHlsa0h8DBjy1Haj7ne7cggUfYLokGj+XY++6IEMMkh0/h9W
	hRaFsggSUQFXZj4sfjZ2YxvjHzydw/q9/JR87XG2ZaWtRd0v1Xbn+vnydpL9y95gFbPf1Br5iBj
	PoPmyDI54/KFor7W0/oxIny8nZnqT9e64F0sEoorZNXUa9XNt3fQTM6T6k62Wz2so0Q==
X-Received: by 2002:a67:84d1:: with SMTP id g200mr1331607vsd.69.1555663297900;
        Fri, 19 Apr 2019 01:41:37 -0700 (PDT)
X-Received: by 2002:a67:84d1:: with SMTP id g200mr1331591vsd.69.1555663297185;
        Fri, 19 Apr 2019 01:41:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555663297; cv=none;
        d=google.com; s=arc-20160816;
        b=yXqi0To2EhKzCpFo+UDtA4S4kcEhd+860FjiQvRcgkkqkoFbeApDpIUjlUn6Q1/hNc
         dI2wYAbBg3xqwGJM+E+73ruYEgHW/UKfZsJfUwIo405GBhXVFoWReD1JT2j2VKTMgLc4
         /vpPEdqPKDmDj3s4kWjYZU81lcbxYTrQhT6TT55baPMVQuoIxgBMEmJiqqltlGnh7szy
         eu6bSPnmF5ZHxRW/VNzLILtY1EcLjME2XtAkz2eB+Dk096VPlzeTpMAlQwYdMu0z2Zvo
         2P+uCow5ClkgGQ0Oy0atYQaR8iPX+AE3t2X2wA8o5U3JUMSjkpR4+DUvoWGwhX6avRFe
         Mb9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=3WrZ4nrQXT6lMVdLtFrtfYLo/oaX3NjG7Uq5HMfmeoQ=;
        b=pZVg3R1E/OT6I1GDL6EMs4RZD6KP4HZfF0/2XDl483Fj2+G9AeFjxxuI1FddPx6HX0
         3+AQtCZPjTsLvSiGNAa1cI66CNG/gzqTXyhfMujp3WMzkXGnnUA01+jYDyHW+OpovsU8
         OTkhdF0Yz/YJ87ZqjJTPqdX/uV41+N2l6RSjDxwbl64V26Ytr7aGMb58OF9hcSPYBrue
         6JtXqCe9Y0zZXtCLC60XurOmzEby/vTQbMMXaHAOM5caa9vPhckdMlQcBXZeLDiTYgEq
         nHT0+yUb8oYmDFxJ8jSMiDJlJ+GcnYIM1BfMrtWup/FVNodEtitQF8xHdl0xvuZeFYvV
         /+RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r22sor1457260vkd.26.2019.04.19.01.41.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 01:41:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzTraqRK+oC6VFZ/Z9QvHtFilqqrml7LDcD6MisiRETl2PJM+eHcamM6IliSXsxkdPm+ahkAJ/bXktAn3gKqJg=
X-Received: by 2002:a1f:1284:: with SMTP id 126mr1252702vks.72.1555663295199;
 Fri, 19 Apr 2019 01:41:35 -0700 (PDT)
MIME-Version: 1.0
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz> <20190418135452.GF18914@techsingularity.net>
In-Reply-To: <20190418135452.GF18914@techsingularity.net>
From: Li Wang <liwang@redhat.com>
Date: Fri, 19 Apr 2019 16:41:24 +0800
Message-ID: <CAEemH2eN55Nuvqngvpr1=1LU16KTbPAKo0-ZZW3Da6YX1S3kZw@mail.gmail.com>
Subject: Re: v5.1-rc5 s390x WARNING
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>
Content-Type: multipart/alternative; boundary="0000000000001a05020586de16f0"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000001a05020586de16f0
Content-Type: text/plain; charset="UTF-8"

On Thu, Apr 18, 2019 at 9:55 PM Mel Gorman <mgorman@techsingularity.net>
wrote:

> On Wed, Apr 17, 2019 at 10:54:38AM +0200, Vlastimil Babka wrote:
> > On 4/17/19 10:35 AM, Li Wang wrote:
> > > Hi there,
> > >
> > > I catched this warning on v5.1-rc5(s390x). It was trggiered in fork &
> malloc & memset stress test, but the reproduced rate is very low. I'm
> working on find a stable reproducer for it.
> > >
> > > Anyone can have a look first?
> > >
> > > [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777
> __alloc_pages_irect_compact+0x182/0x190
> >
> > This means compaction was either skipped or deferred, yet it captured a
> > page. We have some registers with value 1 and 2, which is
> > COMPACT_SKIPPED and COMPACT_DEFERRED, so it could be one of those.
> > Probably COMPACT_SKIPPED. I think a race is possible:
> >
> > - compact_zone_order() sets up current->capture_control
> > - compact_zone() calls compaction_suitable() which returns
> > COMPACT_SKIPPED, so it also returns
> > - interrupt comes and its processing happens to free a page that forms
> > high-order page, since 'current' isn't changed during interrupt (IIRC?)
> > the capture_control is still active and the page is captured
> > - compact_zone_order() does *capture = capc.page
> >
> > What do you think, Mel, does it look plausible?
>
> It's plausible, just extremely unlikely. I think the most likely result
> was that a page filled the per-cpu lists and a bunch of pages got freed
> in a batch from interrupt context.
>
> > Not sure whether we want
> > to try avoiding this scenario, or just remove the warning and be
> > grateful for the successful capture :)
> >
>
> Avoiding the scenario is pointless because it's not wrong. The check was
> initially meant to catch serious programming errors such as using a
> stale page pointer so I think the right patch is below. Li Wang, how
> reproducible is this and would you be willing to test it?
>

It's not easy to reproduce that again. I just saw only once during the OOM
phase that occurred on my s390x platform.

Sure, I run the stress test against a new kernel(build with this patch
applied) for many rounds, so far so good.


>
> ---8<---
> mm, page_alloc: Always use a captured page regardless of compaction result
>
> During the development of commit 5e1f0f098b46 ("mm, compaction: capture
> a page under direct compaction"), a paranoid check was added to ensure
> that if a captured page was available after compaction that it was
> consistent with the final state of compaction. The intent was to catch
> serious programming bugs such as using a stale page pointer and causing
> corruption problems.
>
> However, it is possible to get a captured page even if compaction was
> unsuccessful if an interrupt triggered and happened to free pages in
> interrupt context that got merged into a suitable high-order page. It's
> highly unlikely but Li Wang did report the following warning on s390
>
> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777
> __alloc_pages_irect_compact+0x182/0x190
> [ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4
> dns_resolver
>  nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
>  des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
>  libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
>  ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
> [ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted
> 5.1.0-rc 5 #1
>
> This patch simply removes the check entirely instead of trying to be
> clever about pages freed from interrupt context. If a serious programming
> error was introduced, it is highly likely to be caught by prep_new_page()
> instead.
>
> Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct
> compaction")
> Reported-by: Li Wang <liwang@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 5 -----
>  1 file changed, 5 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d96ca5bc555b..cfaba3889fa2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask,
> unsigned int order,
>         memalloc_noreclaim_restore(noreclaim_flag);
>         psi_memstall_leave(&pflags);
>
> -       if (*compact_result <= COMPACT_INACTIVE) {
> -               WARN_ON_ONCE(page);
> -               return NULL;
> -       }
> -
>         /*
>          * At least in one zone compaction wasn't deferred or skipped, so
> let's
>          * count a compaction stall
>


-- 
Regards,
Li Wang

--0000000000001a05020586de16f0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><div class=3D"gmail_default" style=3D"fon=
t-size:small"><br></div></div><br><div class=3D"gmail_quote"><div dir=3D"lt=
r" class=3D"gmail_attr">On Thu, Apr 18, 2019 at 9:55 PM Mel Gorman &lt;<a h=
ref=3D"mailto:mgorman@techsingularity.net" target=3D"_blank">mgorman@techsi=
ngularity.net</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);paddi=
ng-left:1ex">On Wed, Apr 17, 2019 at 10:54:38AM +0200, Vlastimil Babka wrot=
e:<br>
&gt; On 4/17/19 10:35 AM, Li Wang wrote:<br>
&gt; &gt; Hi there,<br>
&gt; &gt; <br>
&gt; &gt; I catched this warning on v5.1-rc5(s390x). It was trggiered in fo=
rk &amp; malloc &amp; memset stress test, but the reproduced rate is very l=
ow. I&#39;m working on find a stable reproducer for it. <br>
&gt; &gt; <br>
&gt; &gt; Anyone can have a look first?<br>
&gt; &gt; <br>
&gt; &gt; [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 =
__alloc_pages_irect_compact+0x182/0x190<br>
&gt; <br>
&gt; This means compaction was either skipped or deferred, yet it captured =
a<br>
&gt; page. We have some registers with value 1 and 2, which is<br>
&gt; COMPACT_SKIPPED and COMPACT_DEFERRED, so it could be one of those.<br>
&gt; Probably COMPACT_SKIPPED. I think a race is possible:<br>
&gt; <br>
&gt; - compact_zone_order() sets up current-&gt;capture_control<br>
&gt; - compact_zone() calls compaction_suitable() which returns<br>
&gt; COMPACT_SKIPPED, so it also returns<br>
&gt; - interrupt comes and its processing happens to free a page that forms=
<br>
&gt; high-order page, since &#39;current&#39; isn&#39;t changed during inte=
rrupt (IIRC?)<br>
&gt; the capture_control is still active and the page is captured<br>
&gt; - compact_zone_order() does *capture =3D capc.page<br>
&gt; <br>
&gt; What do you think, Mel, does it look plausible?<br>
<br>
It&#39;s plausible, just extremely unlikely. I think the most likely result=
<br>
was that a page filled the per-cpu lists and a bunch of pages got freed<br>
in a batch from interrupt context.<br>
<br>
&gt; Not sure whether we want<br>
&gt; to try avoiding this scenario, or just remove the warning and be<br>
&gt; grateful for the successful capture :)<br>
&gt; <br>
<br>
Avoiding the scenario is pointless because it&#39;s not wrong. The check wa=
s<br>
initially meant to catch serious programming errors such as using a<br>
stale page pointer so I think the right patch is below. Li Wang, how<br>
reproducible is this and would you be willing to test it?<br></blockquote><=
div><br></div><div><div class=3D"gmail_default" style=3D"font-size:small">I=
t&#39;s not easy to reproduce that again. I just saw only once during the O=
OM phase that occurred on my s390x platform.</div><div class=3D"gmail_defau=
lt" style=3D"font-size:small"><br></div><div class=3D"gmail_default" style=
=3D"font-size:small">Sure, I run the stress test against a new kernel(build=
 with this patch applied) for many rounds, so far so good.</div></div><div>=
=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
---8&lt;---<br>
mm, page_alloc: Always use a captured page regardless of compaction result<=
br>
<br>
During the development of commit 5e1f0f098b46 (&quot;mm, compaction: captur=
e<br>
a page under direct compaction&quot;), a paranoid check was added to ensure=
<br>
that if a captured page was available after compaction that it was<br>
consistent with the final state of compaction. The intent was to catch<br>
serious programming bugs such as using a stale page pointer and causing<br>
corruption problems.<br>
<br>
However, it is possible to get a captured page even if compaction was<br>
unsuccessful if an interrupt triggered and happened to free pages in<br>
interrupt context that got merged into a suitable high-order page. It&#39;s=
<br>
highly unlikely but Li Wang did report the following warning on s390<br>
<br>
[ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pa=
ges_irect_compact+0x182/0x190<br>
[ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_res=
olver<br>
=C2=A0nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_=
s390<br>
=C2=A0des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables=
 xfs<br>
=C2=A0libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs c=
tcm<br>
=C2=A0ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod<br>
[ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1=
.0-rc 5 #1<br>
<br>
This patch simply removes the check entirely instead of trying to be<br>
clever about pages freed from interrupt context. If a serious programming<b=
r>
error was introduced, it is highly likely to be caught by prep_new_page()<b=
r>
instead.<br>
<br>
Fixes: 5e1f0f098b46 (&quot;mm, compaction: capture a page under direct comp=
action&quot;)<br>
Reported-by: Li Wang &lt;<a href=3D"mailto:liwang@redhat.com" target=3D"_bl=
ank">liwang@redhat.com</a>&gt;<br>
Signed-off-by: Mel Gorman &lt;<a href=3D"mailto:mgorman@techsingularity.net=
" target=3D"_blank">mgorman@techsingularity.net</a>&gt;<br>
---<br>
=C2=A0mm/page_alloc.c | 5 -----<br>
=C2=A01 file changed, 5 deletions(-)<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index d96ca5bc555b..cfaba3889fa2 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigne=
d int order,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 memalloc_noreclaim_restore(noreclaim_flag);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 psi_memstall_leave(&amp;pflags);<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (*compact_result &lt;=3D COMPACT_INACTIVE) {=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN_ON_ONCE(page);=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return NULL;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
-<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* At least in one zone compaction wasn&#3=
9;t deferred or skipped, so let&#39;s<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* count a compaction stall<br>
</blockquote></div><br clear=3D"all"><div><br></div>-- <br><div dir=3D"ltr"=
 class=3D"m_3887816321275772100m_1756284913108742544m_2223145387994709340gm=
ail_signature"><div dir=3D"ltr"><div>Regards,<br></div><div>Li Wang<br></di=
v></div></div></div>

--0000000000001a05020586de16f0--

