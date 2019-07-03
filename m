Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6D44C06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 23:11:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FD5C21881
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 23:11:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AaZ3mUvL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FD5C21881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF72A6B0006; Wed,  3 Jul 2019 19:11:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80CB8E0003; Wed,  3 Jul 2019 19:11:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48558E0001; Wed,  3 Jul 2019 19:11:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2826B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 19:11:47 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id l4so923445lja.22
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 16:11:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UP+qxKT5rVjcWek7KzsMBfffszv54jR92VkwBR/jGz0=;
        b=C3dTV0bvKCsix4ANGvP7TwmOUbUX+9Pj+LNGjOzXqxjP7ZS7cYtJqZil4pixHRA0fX
         gBofdI98oPuw743qz0ZXkC7EU520ZBHzMV4jG/DvRtY5Qlwu5gvot6oZ8Vf+/xRHo3qb
         i64a9tHkoUvPA0rsKCw4PHWLO7A9pK06SvUTKK9Y3ZWZ0pA+4LlX1Wdvb0vvepk0eC4L
         GS+DDwY9sTC0zWOSzBFfK92j/93LK0fDSz6yabMi0SpWXiXXez6fMbSO8Lz5VSBdte8u
         KEcTzc5s7MhYXZN1BU8DUuLG9KRIqY7KyHClnQZKohCx5FLdwr0yndK0Paz0Uq0djXgm
         +RCg==
X-Gm-Message-State: APjAAAVCzWSCaGm7CmhgAVOB8QjBd0ZFj0+jt07qh8srXWDUy3uqI6Qp
	ENQIVZR/V57BPF8qnhZHFsRaeb1+3+k0AjOuKYOUEj52QglGVGCImBibOHF5uo7jlDr7yiXfRU6
	hFPesNKTHpHyFvB5KEAm8Oqw6nlJxztLmdM6OZ1k5SRmuz5g9G+nrlut8bpneGejbdw==
X-Received: by 2002:a2e:89d0:: with SMTP id c16mr2682826ljk.219.1562195506504;
        Wed, 03 Jul 2019 16:11:46 -0700 (PDT)
X-Received: by 2002:a2e:89d0:: with SMTP id c16mr2682793ljk.219.1562195505440;
        Wed, 03 Jul 2019 16:11:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562195505; cv=none;
        d=google.com; s=arc-20160816;
        b=J80hOQtdtO6TVWYPTm6TefE9o0XT6gS9co6tlwwitZ39/7aI4nih+zSwpaiMdMT3Wk
         7qCb3CCPSpIHNPvDxNtCxWEc4XN7IJ9ipsZaE5P7n0PvTQCRoc3I029jlIKqZHqH3Ebz
         3Tnbx7RXBMYyJ/z88KsMDVgLsEHWUSDJx3j41eJDxlDuB3eJJMvHerRwyxtCD7fT1wfp
         g8FSjBfLlwL2r8BaqvHow2KNU9S/RJ1EfwUzp/B7DpMeLDlgb6f5jJCFZfSTu0nhN+hz
         MKQvSJUpmdq2OEYODMRPb2rRjP7MF41gtpceTA9nQcOY/g62oDRRa79gEyTb6ppM2SgM
         CRUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UP+qxKT5rVjcWek7KzsMBfffszv54jR92VkwBR/jGz0=;
        b=thLS5InMlqkI+CiWOrwoI/kWxvzMpFm2xmGw+7tkhBeiyF8RXAfNuBQybHnOsxVYdH
         VdMZYVWqob5htUvrtq5tZ8Eam6BeCyDA9nOa5xSr6JrtIwJqAh02o66tVTe0DVMbtNbK
         CFVqdzLFM0FJzhl5G7HgK+RVbRx9DvINl+F+bOBEuEqoWD38UtAqboFST2fDYNdOVgSn
         KL3dAT3SeKmXccrJlvRbt9Ki4lbf+ThqDW+2UrbzjBVoeusS+xZW6i77ioQa0WIKq+t9
         ECJnviUDTgj1yuvgKIuKtuR/tRgCQMDKDAUKwRtqP/kfHZ3u14F5ZNkL5g8l4mC9/7eQ
         7JDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AaZ3mUvL;
       spf=pass (google.com: domain of airlied@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=airlied@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor2295926lja.38.2019.07.03.16.11.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 16:11:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of airlied@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AaZ3mUvL;
       spf=pass (google.com: domain of airlied@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=airlied@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UP+qxKT5rVjcWek7KzsMBfffszv54jR92VkwBR/jGz0=;
        b=AaZ3mUvL8AP96UyzVBT0wxy8e2SkMqvx50vLcd+2kNzxqNml8a56RhWeDZ8Q5Fc2wl
         KVqgai+DjYeH0uxdb1Ognc5BPZmL4WZWdPwoU9e/1vsBuhzhe15MUQC2vQ3x6DppiYYz
         keGu6n4LLGu0Lemc6scDgcDK2s7pVyjXKF1ICSfd81PCtTR04+43X2bbtckqCIgtQabF
         eve1j/83zkjYW5NYa8HNRPStRAQvookixhnFrvr6KwHgPAoLrwAZkKZg4Z+8+30v+HAZ
         eeMs9aX8DfP59lB6jGwMLBV4CWUVYTp0o5DmD1U0q7rtvnIXP4lu7165G3Kaz4iUbfda
         ev0g==
X-Google-Smtp-Source: APXvYqzZF2qms9SKK53fAVCvJv1RN+MZtTtgMYoI42VqDQ6BxFVX18oItEruFDL5MuzmBcvvjtk/MtdpSZD4X7Yl4T4=
X-Received: by 2002:a2e:9a10:: with SMTP id o16mr3126839lji.95.1562195504800;
 Wed, 03 Jul 2019 16:11:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
 <20190703141001.GH18688@mellanox.com> <a9764210-9401-471b-96a7-b93606008d07@amd.com>
 <CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com> <20190704073214.266a9c33@canb.auug.org.au>
In-Reply-To: <20190704073214.266a9c33@canb.auug.org.au>
From: Dave Airlie <airlied@gmail.com>
Date: Thu, 4 Jul 2019 09:11:33 +1000
Message-ID: <CAPM=9tx+w5ujeaFQ1koqsqV5cTw8M8B=Ws_-wB1Z_Jy-msFtAQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Alex Deucher <alexdeucher@gmail.com>, "Yang, Philip" <Philip.Yang@amd.com>, 
	Dave Airlie <airlied@linux.ie>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Jason Gunthorpe <jgg@mellanox.com>, 
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2019 at 07:32, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Alex,
>
> On Wed, 3 Jul 2019 17:09:16 -0400 Alex Deucher <alexdeucher@gmail.com> wrote:
> >
> > Go ahead and respin your patch as per the suggestion above.  then I
> > can apply it I can either merge hmm into amd's drm-next or we can just
> > provide the conflict fix patch whichever is easier.  Which hmm branch
> > is for 5.3?
> > https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/?h=hmm
>
> Please do not merge the hmm tree into yours - especially if the
> conflict comes down to just a few lines.  Linus has addressed this in
> the past.  There is a possibility that he may take some objection to
> the hmm tree (for example) and then your tree (and consequently the drm
> tree) would also not be mergeable.
>

I'm fine with merging the hmm tree if Jason has a stable non-rebasing
base. I'd rather merge into drm tree and then have amd backmerge if it
we are doing it.

But if we can just reduce the conflicts to a small amount it's easier
for everyone to just do that.

Dave.


> Just supply Linus with a hint about the conflict resolution.
>
> --
> Cheers,
> Stephen Rothwell
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

