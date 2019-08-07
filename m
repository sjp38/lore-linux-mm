Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF5F4C32757
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A69C32231F
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 17:17:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lvCOFn8k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A69C32231F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51FAB6B0007; Wed,  7 Aug 2019 13:17:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AA136B0008; Wed,  7 Aug 2019 13:17:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FD5C6B000C; Wed,  7 Aug 2019 13:17:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E94766B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 13:17:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so53071484pla.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 10:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8eJrnZxNMCItWIynTatJDEuA9CjWuilxGr3zPMXDYoA=;
        b=Ubmo6YK3C/9pjX/+j2b+IZuS1KVCTfPtzIySIZcPYoHdkzX9VnyTIDvc/qTR1YUA/g
         KT2tym4xyPrG3jozh3BpQddOiVAX6HgUZUMzGepmMET+1sLDhPeJa+OJZlJ0h1N+6wEE
         4rKQGdDacBzC2YFrpHc5WNZEK5WjNsh1NvN/T9qChSdmntfBbiZ20AEWk598l3EwAPU9
         oxhjiSlp2tppzwx1oFvErqbc1XDmxA12J8o2YUlIfI8skdFWdEW1PPcjxUQQcnqPDbe+
         fPiLudQyBYcjxHxyVQlk3l1NLZhZfgJJDWXz/XcNKeq0U8NfDhdVWHUG1D5AJBThXMSM
         ge/Q==
X-Gm-Message-State: APjAAAV3S5vszw4ewQHJnJWAGO8JXq1kW0zfTv7O3ASsxQDnoEEtQZNM
	sYkJrwnpZ/wI+w3dZm1Y1ySy+r2FM5z+tmpDBZgvvGcJSkiYlkacRJXcL4DO+wim5+OwuMp+RVl
	mYcx4FzLrEPASUDmVSpz6b2IjRe1C9dJ5I15qbex/LyUq2wi9UTDaiOpDuDrKDXBkjA==
X-Received: by 2002:aa7:8e17:: with SMTP id c23mr10441198pfr.227.1565198268612;
        Wed, 07 Aug 2019 10:17:48 -0700 (PDT)
X-Received: by 2002:aa7:8e17:: with SMTP id c23mr10441134pfr.227.1565198267708;
        Wed, 07 Aug 2019 10:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565198267; cv=none;
        d=google.com; s=arc-20160816;
        b=zKW+MZIt3s1ftjt0DYpSz7vp7Lge2p9w3ZJ8cNYT7S3fGMQhFCWEQXqHzqY5Wwfbz5
         H3QIqBL/CZzcqDRCCm2A+QXrNxduUZxdN3CJJHtP+SemqY7AgS+aSEGEsGHIp3uvGz9y
         NtinoGTqwGD8Dwt+9XtZ9KRtgMKxaW/+6E7SGUe05bRmqf0RiGbCBiK1PjGWRHvXosz8
         2qZSuCr/cysMc5mA5qygey00JB3g+2ZmqUB6eHv2oVgcT2umtOSkVgAbTi9GqC2dq9cf
         Je84cpXc9lWRqlS4+TIvaBdpmomiVNvWVVcQsK9xfoo2XUV+ueD1uYCLbnAiJSIpN8rY
         VsJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8eJrnZxNMCItWIynTatJDEuA9CjWuilxGr3zPMXDYoA=;
        b=ypt5TEj/WdhaslX4FVyGMwx/9R9O1LuhIK5NBV5oM5fTjlrjAjjRBUiL2zE4yJccWc
         Mp3eTrXeRlVx3a3Zg+VlIwevYWqq6cL5Nx2Io3rYWgz8D8t5130y1XABJCGR7/MmTS+7
         ntSczWiqexGMsTjmNjXFxcj0eu2geVM0jqs+L1Eu+gWhYchbTjU6StGxG90Mf9qmzu/K
         EbrC9lqmVjT1uTkAmlnDPP8OhD1GUHVdUS/yFtXtOOnl1XpVfrglVN7PGMDTXArZoq66
         HSO0Em5TkAi81azK0fkydJGGHfT9SsoF/56Hhk5/hBIz6OqAdIWwNDTNmyB39g95iEuw
         WghQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lvCOFn8k;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor36653788pgv.12.2019.08.07.10.17.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Aug 2019 10:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lvCOFn8k;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8eJrnZxNMCItWIynTatJDEuA9CjWuilxGr3zPMXDYoA=;
        b=lvCOFn8kPw5sKWIBqAtj9nTDw5hreHjOLB8fZD9LK4XqWLqI/y9ZOZsE/4TR27f4Um
         7sNjnMM7si41kfySDx/t9SNrRsRpe9RSjuTSsxtP/LZWsBQ/9wQ/cD4jAY9Afx15eKqx
         drzyP65XIEr5B54raR+/HRbXQh7LyawRCf3zPKIRTqPoYkdFiyNYDBtM/quaMKyDYY7N
         e0hyz+AA4niyiPyNwzehq1Nhy/KS415dSI2CnjbBlju4Nld2LwgPUsvJDvfBXebX8Wbi
         Nmslq3Y7cfQOcqEViWBEfcEzC2SDosb0kffCvwGdMnZ05+LE89QNyyYCkt8oyQaFasdF
         n/vQ==
X-Google-Smtp-Source: APXvYqyBW2S319ERBiJQIcPzcGoHmCZb6zerpXN+gU6uALMoVMzBI9LSMd7krnp9xpHZv3cXEfAdJC0fzaJdRwq+DTM=
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr8596413pgq.130.1565198266795;
 Wed, 07 Aug 2019 10:17:46 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com> <CAAeHK+yc0D_nd7nTRsY4=qcSx+eQR0VLut3uXMf4NEiE-VpeCw@mail.gmail.com>
 <20190724140212.qzvbcx5j2gi5lcoj@willie-the-truck> <CAAeHK+xXzdQHpVXL7f1T2Ef2P7GwFmDMSaBH4VG8fT3=c_OnjQ@mail.gmail.com>
 <20190724142059.GC21234@fuggles.cambridge.arm.com> <20190806171335.4dzjex5asoertaob@willie-the-truck>
In-Reply-To: <20190806171335.4dzjex5asoertaob@willie-the-truck>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 7 Aug 2019 19:17:35 +0200
Message-ID: <CAAeHK+zF01mxU+PkEYLkoVu-ZZM6jNfL_OwMJKRwLr-sdU4Myg@mail.gmail.com>
Subject: Re: [PATCH v19 00/15] arm64: untag user pointers passed to the kernel
To: Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, dri-devel@lists.freedesktop.org, 
	Kostya Serebryany <kcc@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, Christoph Hellwig <hch@infradead.org>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Kees Cook <keescook@chromium.org>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Alex Williamson <alex.williamson@redhat.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Yishai Hadas <yishaih@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Lee Smith <Lee.Smith@arm.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, enh <enh@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 6, 2019 at 7:13 PM Will Deacon <will@kernel.org> wrote:
>
> On Wed, Jul 24, 2019 at 03:20:59PM +0100, Will Deacon wrote:
> > On Wed, Jul 24, 2019 at 04:16:49PM +0200, Andrey Konovalov wrote:
> > > On Wed, Jul 24, 2019 at 4:02 PM Will Deacon <will@kernel.org> wrote:
> > > > On Tue, Jul 23, 2019 at 08:03:29PM +0200, Andrey Konovalov wrote:
> > > > > Should this go through the mm or the arm tree?
> > > >
> > > > I would certainly prefer to take at least the arm64 bits via the arm64 tree
> > > > (i.e. patches 1, 2 and 15). We also need a Documentation patch describing
> > > > the new ABI.
> > >
> > > Sounds good! Should I post those patches together with the
> > > Documentation patches from Vincenzo as a separate patchset?
> >
> > Yes, please (although as you say below, we need a new version of those
> > patches from Vincenzo to address the feedback on v5). The other thing I
> > should say is that I'd be happy to queue the other patches in the series
> > too, but some of them are missing acks from the relevant maintainers (e.g.
> > the mm/ and fs/ changes).
>
> Ok, I've queued patches 1, 2, and 15 on a stable branch here:
>
>   https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git/log/?h=for-next/tbi
>
> which should find its way into -next shortly via our for-next/core branch.
> If you want to make changes, please send additional patches on top.
>
> This is targetting 5.4, but I will drop it before the merge window if
> we don't have both of the following in place:
>
>   * Updated ABI documentation with Acks from Catalin and Kevin

Catalin has posted a new version today.

>   * The other patches in the series either Acked (so I can pick them up)
>     or queued via some other tree(s) for 5.4.

So we have the following patches in this series:

1. arm64: untag user pointers in access_ok and __uaccess_mask_ptr
2. arm64: Introduce prctl() options to control the tagged user addresses ABI
3. lib: untag user pointers in strn*_user
4. mm: untag user pointers passed to memory syscalls
5. mm: untag user pointers in mm/gup.c
6. mm: untag user pointers in get_vaddr_frames
7. fs/namespace: untag user pointers in copy_mount_options
8. userfaultfd: untag user pointers
9. drm/amdgpu: untag user pointers
10. drm/radeon: untag user pointers in radeon_gem_userptr_ioctl
11. IB/mlx4: untag user pointers in mlx4_get_umem_mr
12. media/v4l2-core: untag user pointers in videobuf_dma_contig_user_get
13. tee/shm: untag user pointers in tee_shm_register
14. vfio/type1: untag user pointers in vaddr_get_pfn
15. selftests, arm64: add a selftest for passing tagged pointers to kernel

1, 2 and 15 have been picked by Will.

11 has been picked up by Jason.

9, 10, 12, 13 and 14 have acks from their subsystem maintainers.

3 touches generic lib code, I'm not sure if there's a dedicated
maintainer for that.

The ones that are left are the mm ones: 4, 5, 6, 7 and 8.

Andrew, could you take a look and give your Acked-by or pick them up directly?

>
> Make sense?
>
> Cheers,
>
> Will

Thanks!

