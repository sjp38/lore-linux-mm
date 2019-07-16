Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0497DC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 23:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BD06218BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 23:36:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lpuf1b2g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BD06218BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08AB56B0003; Tue, 16 Jul 2019 19:36:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0144F8E0003; Tue, 16 Jul 2019 19:36:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4D318E0001; Tue, 16 Jul 2019 19:36:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC6A56B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 19:36:31 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p18so17359205ywe.17
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 16:36:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=3DvRpKoCvAYwziHYtBccHcC1dSVXuaUnbOKo+S/X11k=;
        b=nlQRW3jEcQ8BdYCIFgFKIfaCWL1P05K+L0Esp4sce6aOu2xisaY0pnafvLgZYRMcc0
         Fe84+rI7D6dJvWF6YHlH1DWXk5jtW/7c36PkjwiwUzhSZlWzhM5G1zdu/aG+36/vdtk9
         yzNVNu3Rk1QeZwZF2FQfOLgGRHtjFWRa78YMfMPReqw5BdIkCRAkNwUKUSZlOL7ReOJD
         ut5u1HUKWNAX0jRN4uUD9AkoqGNMw0Zgy1IsvcRRR2V29rOBvF0K3+jGB89uFCUV7E30
         y1d0qGo8snI3d6yHZG5AYsESN2qnusg/DyJw/sgYEUgMiPXFyLU0g9/1W2/aZS2JLEhJ
         m8wA==
X-Gm-Message-State: APjAAAX8SdIvIXZB5Gk41Ik2uGGsQTcTZ7fe3NRlzNErmXOHpqRpaIRi
	kU54/01iTnCikjyuPkZGkDBkGp1fTSWwl+0YD0+trAu6oTG9+VxbOc5s2yU+WBZGtcRIhCA/6aC
	E6PY4UOirwGweW7iXXHf1t8nVIRlu+sqHcS/74aAp/s8gYRr5dAWdZDBwk1e5SWmNyA==
X-Received: by 2002:a81:74d7:: with SMTP id p206mr22499742ywc.60.1563320191433;
        Tue, 16 Jul 2019 16:36:31 -0700 (PDT)
X-Received: by 2002:a81:74d7:: with SMTP id p206mr22499699ywc.60.1563320190334;
        Tue, 16 Jul 2019 16:36:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563320190; cv=none;
        d=google.com; s=arc-20160816;
        b=eq2aeuRAa/Xpa+p+OlygoSfVMa6rgVcd3edM4sY4LfbwY3KDL3WdoSpUZ2TgizrYcy
         DC/EHIGeRh84kZBr6r2epT0XGvXgYypxQASBvQc1mFZcQwBFnvKHn7zba2ca1F/QL4gd
         MexZ19EWj5G6wdKG0cxfoI5P6AnfL38+eGTeZp3rbrUmv0KWQlh7gOXzJxz4sk5/jb+A
         uI0SKBlWJGAjTxMIcvvnUVsllar7+Ig3bx7brgQREwfmyN6fZtj18x7ka/yo154VRUi1
         Ry6dq7elZVQMmJBEjmrpOm5jCiM/Jd4yxHjbFmaxNvFcQQLvQIiMuSVRUdvqwWi9lPcE
         mKZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=3DvRpKoCvAYwziHYtBccHcC1dSVXuaUnbOKo+S/X11k=;
        b=OZVngZCc4oHYvKAiheVpU8VQqVI/VNLUaXyXU5DTd8QJN/5/2Zu1GB00mcBEz33wt3
         +FhijYrFnuLXH+vNZigF9Hy0uax0/ypw45xcap+226nooM7aMzaGzm5Sj5EMn9U2Ax1u
         9fCnM1ykirzolFzjuBjl/hc0jGc5qLfM5N0OXE92+NsL6PuqVqdWgTAu+hfh3dFLSC+p
         D+0YQxngeNWHxeStUQehpt9cbUIn5eANxy9inWzPHNlFSFatZOdAVZbnwiQsvJHQR1LC
         JcMCyM/aM9VBmvts5VXsMF0sCNpTvnbHHphlYvEACZiH8R3Gtl9EedHuBJCIKsdLDNW7
         toYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lpuf1b2g;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18sor1309307ybq.56.2019.07.16.16.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 16:36:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lpuf1b2g;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=3DvRpKoCvAYwziHYtBccHcC1dSVXuaUnbOKo+S/X11k=;
        b=lpuf1b2gx/aUfClr5+KNJP5DLR09tUGD2JrJWQQtk8qjh12G0y4YpXbKoYRphoyu36
         T6b27L37CHAQK6fO5kxUwb9DSyp6FRLDUAgcYc1myXa5RLsmBiz8Iq+cuZz+5n5DSeIa
         1NhF8rvjEFLKh76hIYXvkjknfOOfyvH+9ruEq7cQYoWanb76cFT5gWr5Octl5yMn8zsD
         45n92fDTMCSLUJwho4HP0+o6zXY55O+Dm1bmEGxjUp/6W7hu2CwOKIuYddkzVdLlB1TX
         XlCETh/NQ1NUAJ2QRCdYkgn9O25OGAe/dzSemA+2ln0Cssb+Dd/NLofB0g87ivWA8XJv
         RdAw==
X-Google-Smtp-Source: APXvYqyEqS+8CgKjlAnskwqJ647ZLgnRuugIZRb3TtL/lsuMBFVBrm2lRsHmMt27Q2DG8Rz4wuaf7udpSd7BK3zcw4M=
X-Received: by 2002:a25:9903:: with SMTP id z3mr22033869ybn.293.1563320189587;
 Tue, 16 Jul 2019 16:36:29 -0700 (PDT)
MIME-Version: 1.0
References: <1562795006.8510.19.camel@lca.pw> <cd6e10bc-cb79-65c5-ff2b-4c244ae5eb1c@linux.alibaba.com>
 <1562879229.8510.24.camel@lca.pw> <b38ee633-f8e0-00ee-55ee-2f0aaea9ed6b@linux.alibaba.com>
 <1563225798.4610.5.camel@lca.pw> <5c853e6e-6367-d83c-bb97-97cd67320126@linux.alibaba.com>
 <8A64D551-FF5B-4068-853E-9E31AF323517@lca.pw> <e5aa1f5b-b955-5b8e-f502-7ac5deb141a7@linux.alibaba.com>
In-Reply-To: <e5aa1f5b-b955-5b8e-f502-7ac5deb141a7@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 16 Jul 2019 16:36:18 -0700
Message-ID: <CALvZod7+ComCUROSBaj==r0VmCczs=npP4u6C9LuJWNWdfB0Pg@mail.gmail.com>
Subject: Re: list corruption in deferred_split_scan()
To: Yang Shi <yang.shi@linux.alibaba.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Hugh Dickins <hughd@google.com>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>
Cc: Qian Cai <cai@lca.pw>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding related people.

The thread starts at:
http://lkml.kernel.org/r/1562795006.8510.19.camel@lca.pw

On Mon, Jul 15, 2019 at 8:01 PM Yang Shi <yang.shi@linux.alibaba.com> wrote=
:
>
>
>
> On 7/15/19 6:36 PM, Qian Cai wrote:
> >
> >> On Jul 15, 2019, at 8:22 PM, Yang Shi <yang.shi@linux.alibaba.com> wro=
te:
> >>
> >>
> >>
> >> On 7/15/19 2:23 PM, Qian Cai wrote:
> >>> On Fri, 2019-07-12 at 12:12 -0700, Yang Shi wrote:
> >>>>> Another possible lead is that without reverting the those commits b=
elow,
> >>>>> kdump
> >>>>> kernel would always also crash in shrink_slab_memcg() at this line,
> >>>>>
> >>>>> map =3D rcu_dereference_protected(memcg->nodeinfo[nid]->shrinker_ma=
p, true);
> >>>> This looks a little bit weird. It seems nodeinfo[nid] is NULL? I did=
n't
> >>>> think of where nodeinfo was freed but memcg was still online. Maybe =
a
> >>>> check is needed:
> >>> Actually, "memcg" is NULL.
> >> It sounds weird. shrink_slab() is called in mem_cgroup_iter which does=
 pin the memcg. So, the memcg should not go away.
> > Well, the commit =E2=80=9Cmm: shrinker: make shrinker not depend on mem=
cg kmem=E2=80=9D changed this line in shrink_slab_memcg(),
> >
> > -     if (!memcg_kmem_enabled() || !mem_cgroup_online(memcg))
> > +     if (!mem_cgroup_online(memcg))
> >               return 0;
> >
> > Since the kdump kernel has the parameter =E2=80=9Ccgroup_disable=3Dmemo=
ry=E2=80=9D, shrink_slab_memcg() will no longer be able to handle NULL memc=
g from mem_cgroup_iter() as,
> >
> > if (mem_cgroup_disabled())
> >       return NULL;
>
> Aha, yes. memcg_kmem_enabled() implicitly checks !mem_cgroup_disabled().
> Thanks for figuring this out. I think we need add mem_cgroup_dsiabled()
> check before calling shrink_slab_memcg() as below:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a0301ed..2f03c61 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -701,7 +701,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int
> nid,
>          unsigned long ret, freed =3D 0;
>          struct shrinker *shrinker;
>
> -       if (!mem_cgroup_is_root(memcg))
> +       if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>                  return shrink_slab_memcg(gfp_mask, nid, memcg, priority)=
;
>
>          if (!down_read_trylock(&shrinker_rwsem))
>

We were seeing unneeded oom-kills on kernels with
"cgroup_disabled=3Dmemory" and Yang's patch series basically expose the
bug to crash. I think the commit aeed1d325d42 ("mm/vmscan.c:
generalize shrink_slab() calls in shrink_node()") missed the case for
"cgroup_disabled=3Dmemory". However I am surprised that root_mem_cgroup
is allocated even for "cgroup_disabled=3Dmemory" and it seems like
css_alloc() is called even before checking if the corresponding
controller is disabled.

Yang, can you please send the above change with signed-off and CC to
stable as well?

thanks,
Shakeel

