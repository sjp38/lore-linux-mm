Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F0E4C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 118762183E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:11:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QYox3mHS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 118762183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 936776B0008; Thu, 18 Apr 2019 08:11:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90D6B6B000A; Thu, 18 Apr 2019 08:11:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 823F86B000C; Thu, 18 Apr 2019 08:11:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD8C6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:11:57 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id r17so425027vsk.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:11:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=iSgCAvUEGOmkA7yqq7QK6OCH2CFcFcPt+JEh4ZctSK0=;
        b=DJrKrr3lULkNuD6E+VeQDq8XSEzIZ3j0lk4ZchCXMYF4XVkgv88P4WgHA4RPVRC6sZ
         iDs/lE4/9VDE4brSfqNfmV2UN28pDAYu5nECuld0+H6neCp6eoC1cedI7DlQE+qstPWY
         odZDIwDTLAkc6xU9Zze8NiX/+mRuRs+KqsnQ8XBtEb6bHlmK/YpTlOEuYZFPbT6lpgJc
         NXQB7yJNfgkVq3VqsDOGHR6HSxgkbVKLzyB3paaF+8ovESisY7fQ9FRTFauaFRgZBy3Y
         1X5SeM2G04QldNJGWaBpBlzQ+jVzUh2O5ZPY/1j0aGlWiOtJaV38plXlcDAncwCtJwXo
         gKUw==
X-Gm-Message-State: APjAAAUyKt9K/ui72U4LK/u3EKhvmV/+ksslSmvZMm5yJimpbD9MBhR1
	kgEZK1cQoyx2gz+YNulHhDQDnaHIhfC6Q9xtKcrCFTwegC/RXaH8CJkv9GQsvtfKF2J/CEPlyIG
	F5/KusjFzjvZrARBHkTs1yzGi7k92L6Fhy5V2aJ23XfINztFhfsyFi8/9J6tzOf1OAg==
X-Received: by 2002:ab0:5fc1:: with SMTP id g1mr8640098uaj.91.1555589516989;
        Thu, 18 Apr 2019 05:11:56 -0700 (PDT)
X-Received: by 2002:ab0:5fc1:: with SMTP id g1mr8640060uaj.91.1555589516298;
        Thu, 18 Apr 2019 05:11:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555589516; cv=none;
        d=google.com; s=arc-20160816;
        b=BqZHsSZobN1x50ekQXALh2MZ5jHdioHmvMccs180fIGx8cHA212F/bshtGk1HE92T1
         m80+oQJWqqXiGE44EbQlWZn2oWoAWW85m1gCs3bPF7El/oxzu+kSEVyTBOijU4xkLX8B
         /3XIlyyXsJqp3bvAr2OvKHCwVne2ROQbXG8ci+s9y7K8HrZT/Ik5kWzd3vkwy2sL2rgK
         i/B26rwouqnipka7aXybjG8hjXdgVFdy6xwMNCTW+Lq25iLf68XREm3RYpxHA48uRuSY
         88yw3nOsrVjXR466zt7c02nOEcDzN/3oCfPBF2PJh0vQ9oqK1p4+zSJKSp1Emjj/22vt
         +wrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=iSgCAvUEGOmkA7yqq7QK6OCH2CFcFcPt+JEh4ZctSK0=;
        b=Lr5+EIkh9w0moU+PLhK5RMoJCGIbJkx9Yn0IJ8itIO8987m9FOAHUZLJpz8ImrsN51
         MOciNGClhgSpib6ghDPhXYP/zYKZuEMHOIQaX1+qcmVk8DLXWXCRcIdcxwEJxNNxPqtG
         q5dzrr/0TFPqf3y270Kw6lBmFS5C4vzMX2i78cX32V5Kowt/MRoVI5E4oAlX9p2zZ6mm
         HZ2FhF/lER8llXnVEe2wx3spjbiF8erLNhOQF8u3lZD3Oy2tS/lQGbk+sn0VymueKxm2
         9GXMgP67XvEnb1FFS2/hJBQCvyr7+q5UhVM666hF0waVhkPzWRFNrF2agurzgcua9YbH
         GhlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QYox3mHS;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y140sor829621vsc.13.2019.04.18.05.11.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 05:11:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QYox3mHS;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=iSgCAvUEGOmkA7yqq7QK6OCH2CFcFcPt+JEh4ZctSK0=;
        b=QYox3mHSqW80j2A3IIiagUUBm09mZj02WRCKir6HBQx5T+b+hhAzGHQFOTwlONKbj+
         JJgyR/WQHwg8Cc7ukRkbYZ/f59+ReLAwpKS1zTzZMgMWjQjpa+NvSVrh8A8T3ceV7bLY
         uoXOMjV66AX9yM+yes+lXGolAtYtmsYKfcrPtWTFFr/7rqv9SEvseUou0t+cwv7s/iye
         TvT67Ae1wW9IHuwbcM5KGneuy8s3xRcKd0xOYCDyYWSzCvqtrVSm9//cPZFi/yYSzHlT
         1EQatPDgbrTsuxjhpE9ZcaOv8iSwAziw9Dkkkdizs+FhJMHfeZvWV03ILGIJlDd0RIEk
         lVyA==
X-Google-Smtp-Source: APXvYqwECAvEJzUlV7fzRl9b6wg7o0AisQ+1RCTx/KeiR4GaCwP9nHgwP4vp46KXwzB2ZT6/gaSoiXLGbekHjekrJKI=
X-Received: by 2002:a67:e30a:: with SMTP id j10mr51098919vsf.103.1555589515631;
 Thu, 18 Apr 2019 05:11:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190418084119.056416939@linutronix.de> <20190418084254.361284697@linutronix.de>
 <CAG_fn=WP9+bVv9hedoaTzWK+xBzedxaGJGVOPnF0o115s-oWvg@mail.gmail.com> <alpine.DEB.2.21.1904181353420.3174@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1904181353420.3174@nanos.tec.linutronix.de>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 18 Apr 2019 14:11:44 +0200
Message-ID: <CAG_fn=WL0yLqavV_mhodT=B6KcAzJ+LS0hss1jqany9Cn92RHw@mail.gmail.com>
Subject: Re: [patch V2 14/29] dm bufio: Simplify stack trace retrieval
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org, 
	Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, dm-devel@redhat.com, 
	Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
	Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>, 
	iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>, 
	Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, 
	Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, 
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, 
	intel-gfx@lists.freedesktop.org, 
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, 
	David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, 
	Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 1:54 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Thu, 18 Apr 2019, Alexander Potapenko wrote:
> > On Thu, Apr 18, 2019 at 11:06 AM Thomas Gleixner <tglx@linutronix.de> w=
rote:
> > > -       save_stack_trace(&b->stack_trace);
> > > +       b->stack_len =3D stack_trace_save(b->stack_entries, MAX_STACK=
, 2);
> > As noted in one of similar patches before, can we have an inline
> > comment to indicate what does this "2" stand for?
>
> Come on. We have gazillion of functions which take numerical constant
> arguments. Should we add comments to all of them?
Ok, sorry. I might not be familiar enough with the kernel style guide.
> Thanks,
>
>         tglx



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

