Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A71D0C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B7E82175B
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:44:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aFH35CN6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B7E82175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFA576B028A; Thu, 23 May 2019 11:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAA8B6B028C; Thu, 23 May 2019 11:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C993F6B028D; Thu, 23 May 2019 11:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8656B028A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:44:27 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id v8so976847lfg.2
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/wji4Ea/4BKbtz1pB+NomkucTVNmeP5sWS4Z09Qoh/0=;
        b=b5TympZSkFN5v79rpTxrVCmQCPyVurHN/cc9+8WaZJun0WhbzLuz9RU735xl+AWyvu
         uNjevk0kCi06sTfm1LMbqTeIgOkCIWS1N3949w8ygskx8c9qmvsx43aocod59ADpy4jT
         Rz6tfmRENRVqU1TmhMYYxlBbmlZX45ODCZCmI05f1u1r1sQ9PzaQL8OijKGRKxCkTit+
         BFz22QtMKIbBCSbRHJFaunzDrQWmrt30AvSJUgpr37BVcnhx6vF3qUW+UhpwJjjC06n+
         avIc3AMegzZnmW2IqNztLIyrCgJ3z3WSSdWZ/9l4vjcN/qLNKDcKjGmv5KOjhPcAWqLh
         oMgQ==
X-Gm-Message-State: APjAAAWnehWZjwwzc/m9dvK/GUYmrgu8H+k8bGZmZUQkd0cyMZyf/EK8
	pxHhdIoiu7A+7bewGXIzlNjRp4M7cqQ2efbv65qMZm1CyMlVEnkipIjnfJo8fHoQ2leJIOSqDE0
	Wj9XR1dk6UnlfAU8bx3FeuSortoKQDH3cSw0ibHM5znxsmiD7T2ixzPOhGUjSOKFj1w==
X-Received: by 2002:a2e:9d09:: with SMTP id t9mr16360333lji.151.1558626266463;
        Thu, 23 May 2019 08:44:26 -0700 (PDT)
X-Received: by 2002:a2e:9d09:: with SMTP id t9mr16360282lji.151.1558626265361;
        Thu, 23 May 2019 08:44:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558626265; cv=none;
        d=google.com; s=arc-20160816;
        b=JRMGNIgh/d/lx7HEh/3vNRaIHC0v94fYufkSd4OIynhrbS1QBc+j9tFik3pv/lsZnB
         YFjEZKUP7BRquCIP9iPkMirJt+Bvmag0S+B8uGEfpPV3F2LrQpFKV7fHz/rbclE+Kfel
         c4a35kzVBCPWoE+4wXYYVtIyy/X4oe4TuL7Q/3sXNC9pTiNmhv6osRmy8VJL5FWKNUss
         6AP/w+pBySSImnBRsdL6jYUvONlTCc1t3mAFJiFvadG47ae1xbFWs6kvd9cdusG4HoRq
         V1UbZIgWKONZJcAPzU+p/ZTsQFRVU8h/okV8LS4BFC5IsYpRHnAMpVIlhsDBJYiEKRMc
         H4xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/wji4Ea/4BKbtz1pB+NomkucTVNmeP5sWS4Z09Qoh/0=;
        b=tSdwxd2QVjc2+1kM1MBbmerRZxs/fOM+1I6rW3mGsCdb1ShFUHFClaI23GmhdaaHnV
         1K+Tkb5pNuToG0TEVsx4VUm2RZX5ZQ88Hqkhvg0iAcsja6ZfnyiQgRMKWKXKCKZs1e2H
         XxOKMZDCPliCB9ADf8ylLtApfvRHsQ0ldO45dNKcd+HBHdOJKhWrrLjdnV7i1hFkaNHU
         C9AgAP8m8/C3h3EzQebzWeouBaWyKk1XQr7uepR6FUH3+IopKx2ngMQBRIbwfJgYP9a0
         bNB4DEfnO/ERri0cLpi8pNcnoF9XfnkkYNBfTIgH+rVRcfPXezg5IuC2pT1fQK7O0kn+
         l1cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aFH35CN6;
       spf=pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=enh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor2951124ljg.35.2019.05.23.08.44.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 08:44:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aFH35CN6;
       spf=pass (google.com: domain of enh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=enh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/wji4Ea/4BKbtz1pB+NomkucTVNmeP5sWS4Z09Qoh/0=;
        b=aFH35CN6oPRsy0HINPVyUyCLmmZ1q+W5tanGOLFB9ZDOu6iaE0T6Zf2p50/YpwHsbr
         48EE1NUmchXldef87VmFcBOfomkIHiEfKDLilaRqMK87cFmewn3SJqhTI1TRHWczozD4
         oXQnG40alYiwUIlV5zhAeNCFOXlq3pqE0BbnZ0FvRVuwBWMRV9wfu1H9fYBPCAdnSv5U
         HVNKv9dUz6r+VmwUQYwzrC3kRsKz62p+YOIjrLW4bC1aoOEaVaZZBPmIi8QCc4AHmXYb
         1tLTls+6tcRQac2V8FPQbYxeEAGXeJISVC1rVB3y4LA5KetGIABPN8JvrlKNXRYKDzkN
         FlXA==
X-Google-Smtp-Source: APXvYqzhSDjrNWAy5KyNhMUlv7cjkwlGbRwsa6Uqsf4zqqYvI69PmEIAwS9JjP+IZnW+JBpTZSKDycdIF2QLVLgBgoM=
X-Received: by 2002:a2e:9d4e:: with SMTP id y14mr23518941ljj.199.1558626264355;
 Thu, 23 May 2019 08:44:24 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com> <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <20190522101110.m2stmpaj7seezveq@mbp> <CAJgzZoosKBwqXRyA6fb8QQSZXFqfHqe9qO9je5TogHhzuoGXJQ@mail.gmail.com>
 <20190522163527.rnnc6t4tll7tk5zw@mbp> <201905221316.865581CF@keescook> <20190523144449.waam2mkyzhjpqpur@mbp>
In-Reply-To: <20190523144449.waam2mkyzhjpqpur@mbp>
From: enh <enh@google.com>
Date: Thu, 23 May 2019 08:44:12 -0700
Message-ID: <CAJgzZoqX--Kd9=Kjpnfz-5cjVJ=TdsXM5dJM_EjLFKniVbny2w@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Evgenii Stepanov <eugenis@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 7:45 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, May 22, 2019 at 01:47:36PM -0700, Kees Cook wrote:
> > On Wed, May 22, 2019 at 05:35:27PM +0100, Catalin Marinas wrote:
> > > The two hard requirements I have for supporting any new hardware feature
> > > in Linux are (1) a single kernel image binary continues to run on old
> > > hardware while making use of the new feature if available and (2) old
> > > user space continues to run on new hardware while new user space can
> > > take advantage of the new feature.
> >
> > Agreed! And I think the series meets these requirements, yes?
>
> Yes. I mentioned this just to make sure people don't expect different
> kernel builds for different hardware features.
>
> There is also the obvious requirement which I didn't mention: new user
> space continues to run on new/subsequent kernel versions. That's one of
> the points of contention for this series (ignoring MTE) with the
> maintainers having to guarantee this without much effort. IOW, do the
> 500K+ new lines in a subsequent kernel version break any user space out
> there? I'm only talking about the relaxed TBI ABI. Are the usual LTP,
> syskaller sufficient? Better static analysis would definitely help.
>
> > > For MTE, we just can't enable it by default since there are applications
> > > who use the top byte of a pointer and expect it to be ignored rather
> > > than failing with a mismatched tag. Just think of a hwasan compiled
> > > binary where TBI is expected to work and you try to run it with MTE
> > > turned on.
> >
> > Ah! Okay, here's the use-case I wasn't thinking of: the concern is TBI
> > conflicting with MTE. And anything that starts using TBI suddenly can't
> > run in the future because it's being interpreted as MTE bits? (Is that
> > the ABI concern?
>
> That's another aspect to figure out when we add the MTE support. I don't
> think we'd be able to do this without an explicit opt-in by the user.
>
> Or, if we ever want MTE to be turned on by default (i.e. tag checking),
> even if everything is tagged with 0, we have to disallow TBI for user
> and this includes hwasan. There were a small number of programs using
> the TBI (I think some JavaScript compilers tried this). But now we are
> bringing in the hwasan support and this can be a large user base. Shall
> we add an ELF note for such binaries that use TBI/hwasan?
>
> This series is still required for MTE but we may decide not to relax the
> ABI blindly, therefore the opt-in (prctl) or personality idea.
>
> > I feel like we got into the weeds about ioctl()s and one-off bugs...)
>
> This needs solving as well. Most driver developers won't know why
> untagged_addr() is needed unless we have more rigorous types or type
> annotations and a tool to check them (we should probably revive the old
> sparse thread).
>
> > So there needs to be some way to let the kernel know which of three
> > things it should be doing:
> > 1- leaving userspace addresses as-is (present)
> > 2- wiping the top bits before using (this series)
>
> (I'd say tolerating rather than wiping since get_user still uses the tag
> in the current series)
>
> The current series does not allow any choice between 1 and 2, the
> default ABI basically becomes option 2.
>
> > 3- wiping the top bits for most things, but retaining them for MTE as
> >    needed (the future)
>
> 2 and 3 are not entirely compatible as a tagged pointer may be checked
> against the memory colour by the hardware. So you can't have hwasan
> binary with MTE enabled.
>
> > I expect MTE to be the "default" in the future. Once a system's libc has
> > grown support for it, everything will be trying to use MTE. TBI will be
> > the special case (but TBI is effectively a prerequisite).
>
> The kernel handling of tagged pointers is indeed a prerequisite. The ABI
> distinction between the above 2 and 3 needs to be solved.
>
> > AFAICT, the only difference I see between 2 and 3 will be the tag handling
> > in usercopy (all other places will continue to ignore the top bits). Is
> > that accurate?
>
> Yes, mostly (for the kernel). If MTE is enabled by default for a hwasan
> binary, it will SEGFAULT (either in user space or in kernel uaccess).
> How does the kernel choose between 2 and 3?
>
> > Is "1" a per-process state we want to keep? (I assume not, but rather it
> > is available via no TBI/MTE CONFIG or a boot-time option, if at all?)
>
> Possibly, though not necessarily per process. For testing or if
> something goes wrong during boot, a command line option with a static
> label would do. The AT_FLAGS bit needs to be checked by user space. My
> preference would be per-process.
>
> > To choose between "2" and "3", it seems we need a per-process flag to
> > opt into TBI (and out of MTE).
>
> Or leave option 2 the default and get it to opt in to MTE.
>
> > For userspace, how would a future binary choose TBI over MTE? If it's
> > a library issue, we can't use an ELF bit, since the choice may be
> > "late" after ELF load (this implies the need for a prctl().) If it's
> > binary-only ("built with HWKASan") then an ELF bit seems sufficient.
> > And without the marking, I'd expect the kernel to enforce MTE when
> > there are high bits.
>
> The current plan is that a future binary issues a prctl(), after
> checking the HWCAP_MTE bit (as I replied to Elliot, the MTE instructions
> are not in the current NOP space). I'd expect this to be done by the
> libc or dynamic loader under the assumption that the binaries it loads
> do _not_ use the top pointer byte for anything else.

yeah, it sounds like to support hwasan and MTE, the dynamic linker
will need to not use either itself.

> With hwasan
> compiled objects this gets more confusing (any ELF note to identify
> them?).

no, at the moment code that wants to know checks for the presence of
__hwasan_init. (and bionic doesn't actually look at any ELF notes
right now.) but we can always add something if we need to.

> (there is also the risk of existing applications using TBI already but
> I'm not aware of any still using this feature other than hwasan)
>
> --
> Catalin

