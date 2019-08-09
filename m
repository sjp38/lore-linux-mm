Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4190C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:59:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9803A20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 19:59:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UR17JX/N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9803A20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314376B0003; Fri,  9 Aug 2019 15:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C48E6B0005; Fri,  9 Aug 2019 15:59:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B3446B0010; Fri,  9 Aug 2019 15:59:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C387C6B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 15:59:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y23so4457094edo.13
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 12:59:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AHqEsgDgb5JzggXVfgJe1D/a5UW3aJXppbSuLP37XBs=;
        b=FMH1J914rDQrnvX9vCks+TIhRzZiDWWL0/CHGWY3f2rBe9JbjVOJlZKd+GBH12mOKB
         +5xL2QUAXYifUC0CHd6TBYA1QxCp+fjHKxcUbmFtAL2uZmWOu69dfO1Ecmn1B14pbrDu
         uaeXi/uGuPhKpC1suh5HVltId87CNYS7aiVPgF0+uAdCMfdj2GGMQqDgQ323XwQ/oYUh
         2V7xAyPbREPyco9uD++o5GtCUAzcFFUnUaZY2A2XSjXPvbHZB7svEFIBj6xrPgeBKDqn
         j5/V/Q+3Avj104xhNKzZYAX73z/LnsGLxPTgSN08asPuiPoYFaaa4bKWlroqmIZ9G+z7
         t9MQ==
X-Gm-Message-State: APjAAAUDVZb3plfbrnVXej+3aYYXh2xbfbqPF0LaorhdisjVesvjuAn5
	B1LJdOODzcPyQ2B1cGAGd7BVTtAcSRw44ikWv43r4KGaW/9FBi7Zmw7AgzrdbtC/QJjOxZ64dHA
	Wbo/UfVOsESFFb2Qq1g2sSoMHU7yn4okTjVSCtSQcy54BzR1KUg0r3PdG2m1Un0iejw==
X-Received: by 2002:a50:8d48:: with SMTP id t8mr10836762edt.200.1565380774367;
        Fri, 09 Aug 2019 12:59:34 -0700 (PDT)
X-Received: by 2002:a50:8d48:: with SMTP id t8mr10836712edt.200.1565380773577;
        Fri, 09 Aug 2019 12:59:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565380773; cv=none;
        d=google.com; s=arc-20160816;
        b=wPLjP7yWR8o94EsXWNu3tJDvMFZMD/qcnSTvxGkLDOOJwxruReFghO+SNU9Jpthuyr
         TacWCM43hLvO+KGIJ7g1/Zl7WBzrX8O1B9CWzNTVMZpeWqhc2zgR9EBF8/IuaCZu/XXh
         jlaw+Y3AE9ZXwcrKVxm/pBR/vA1M8raOJNfz/CiyJ9xA8F0BgEjNnoAIhpIoW+aLSBx3
         +VPLEFyhW6v6RY7eChRGAuDcAJn1Ia5LHltjSBkh1notPLU5jHrjKREV6jsw6bXvCuky
         GUoyyN2mn6mAts+I7Sq4IzvpiKHlWGuz0laBsAB7X9nlpGxWJYNlCQyqRFVxON84oVsG
         7hTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AHqEsgDgb5JzggXVfgJe1D/a5UW3aJXppbSuLP37XBs=;
        b=E9jW1a8rNMrqb42sSFBHu3cwZKLJVHZAo/Agum5rwe9YadPbky2mCgXXfOxIYdCQGJ
         8NN4+rjeIbmklJz4Ix+WhZvC63j78Py5/gEicRLdLNrBK1CDcil3U4Qbloyd+QRFFNtO
         KmsV8W92h5em5T5CmDr4jme48RA68J2oKGaipTZEguNzNXk0dwAxPTJG40DuGm8sALZc
         G8w7unFmCK2jszYmZ/mh46G4bfmED9JuCLGWQqf3CzwUa/ofmsZLnmWGmDjl/KbUblnb
         sXpBtXnFWlp3AbuTtRzbFv0YoGYEPffGEqYc3IFBhN2j0sBq9Kalob53VGrQEW3FyUTB
         oKTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UR17JX/N";
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k21sor34113246ejs.43.2019.08.09.12.59.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 12:59:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="UR17JX/N";
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AHqEsgDgb5JzggXVfgJe1D/a5UW3aJXppbSuLP37XBs=;
        b=UR17JX/NbilG4ikKVy/oXcFAzOhqmweKVz+dGvxNjAxtqUl5SWhFuFYzVE+TP8BMzr
         /3wWPC+QBgk+BfTQpJ8Kbq3+RM0V2Zagx7vEC1in0XQJHg+ZWo9WXEc/f1njls5jOOFi
         Ma0xpWbqLMFuX3HFTu+Y3+kjmNsk2aQZrnDkKRo/Wa5oLEhhXba5gPFMIt5nPx8T5kpC
         hlpgIYXYoWwsUey8+XKE2f9rv8IY+i8+s/1Ce60eQ+jCRjqsE4LD/h9OBMuaaZrVj8ev
         yVay6t75Kik1BCr8A4MjxdCRAdQcAbXVXv48wR4oFL425IvfbU5JgliosnozC0h1loYA
         FmjA==
X-Google-Smtp-Source: APXvYqz5a7RO0N9V2+pKGw7IFaG7VrGw1vD109CfGojs8XjLLN259Sjyaymy//2dM1gWI+9NNSyMdh4I+fVa9Rkxjzc=
X-Received: by 2002:a17:906:318e:: with SMTP id 14mr20172779ejy.85.1565380772979;
 Fri, 09 Aug 2019 12:59:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org>
In-Reply-To: <20190717215956.GA30369@altlinux.org>
From: Anatoly Pugachev <matorola@gmail.com>
Date: Fri, 9 Aug 2019 22:59:23 +0300
Message-ID: <CADxRZqy61-JOYSv3xtdeW_wTDqKovqDg2G+a-=LH3w=mrf2zUQ@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	"David S. Miller" <davem@davemloft.net>, Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 12:59 AM Dmitry V. Levin <ldv@altlinux.org> wrote:
> On Tue, Jun 25, 2019 at 04:37:08PM +0200, Christoph Hellwig wrote:
> > The sparc64 code is mostly equivalent to the generic one, minus various
> > bugfixes and two arch overrides that this patch adds to pgtable.h.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > ---
> >  arch/sparc/Kconfig                  |   1 +
> >  arch/sparc/include/asm/pgtable_64.h |  18 ++
> >  arch/sparc/mm/Makefile              |   2 +-
> >  arch/sparc/mm/gup.c                 | 340 ----------------------------
> >  4 files changed, 20 insertions(+), 341 deletions(-)
> >  delete mode 100644 arch/sparc/mm/gup.c
>
> So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505

I've tried to revert this commit on a current master branch , but i'm getting :

linux-2.6$ git show 7b9afb86b632 > /tmp/gup.patch
linux-2.6$ patch -p1 -R < /tmp/gup.patch
...
linux-2.6$ make -j && make -j modules
...
  CALL    scripts/atomic/check-atomics.sh
  CALL    scripts/checksyscalls.sh
<stdin>:1511:2: warning: #warning syscall clone3 not implemented [-Wcpp]
  CHK     include/generated/compile.h
  CHK     include/generated/autoksyms.h
  GEN     .version
  CHK     include/generated/compile.h
  UPD     include/generated/compile.h
  CC      init/version.o
  AR      init/built-in.a
  LD      vmlinux.o
ld: mm/gup.o: in function `__get_user_pages_fast':
gup.c:(.text+0x1bc0): multiple definition of `__get_user_pages_fast';
arch/sparc/mm/gup.o:gup.c:(.text+0x620): first defined here
ld: mm/gup.o: in function `get_user_pages_fast':
gup.c:(.text+0x1be0): multiple definition of `get_user_pages_fast';
arch/sparc/mm/gup.o:gup.c:(.text+0x740): first defined here
make: *** [Makefile:1060: vmlinux] Error 1

Can someone help me to revert this commit? Is it even possible? Since
it's not only futex strace calls getting killed and producing OOPS,
even util-linux.git 'make check' hangs machine/LDOM with multiple OOPS
in logs, while previous (before this commit) kernel passes tests ok
(and without kernel OOPS). I've already tried to compile current
master with gcc-6, gcc-7, gcc-8 debian versions, but all produce same
OOPS.

Thanks.

