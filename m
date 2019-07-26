Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA35AC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:21:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EE9B22BEF
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:21:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N0w2rApM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EE9B22BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371B86B0005; Fri, 26 Jul 2019 11:21:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3229D6B0007; Fri, 26 Jul 2019 11:21:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E96F8E0002; Fri, 26 Jul 2019 11:21:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id F35066B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:21:10 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s83so59028255iod.13
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:21:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=F9G1CH0Ps2FRcZ/NwMc7CwEB3cMwgOdfmNpmMO9HdoM=;
        b=k93t93hRbog5DOwDtgxeocgbG6s/Gorq+xCL4ZXvlYLhiOY8zRg9/ip0nUI2sVhwFz
         l4+SEyekzNrS+DsZ0XaI0NvSH5aOeV4PS7C3j9era0KKYXv8c/LtrDTbm4DOwEVUFPPa
         GeHHlem3gNgPaelCj71lFGktoQmEfvFl4Kv0qXpi4W5sesIIwgFHeRUJUhtlMkhZlDlS
         w/P7oI95DS6ZMqLgnLQk+kS8UmRWy4NLwyjQz+AjsiYqOoXf2nuSis1ex6piUKqi+IDF
         6sRWaHMW4UUrcuhGKFTEtsyhO5t9xPUckr6DZNzyPRJ2o53HFd5f1bVfssr4RB88rIKH
         cBdQ==
X-Gm-Message-State: APjAAAWWRWh+PHWnnvdO7szfTHRjtLr7ENqTGEkJQhzD6A7jfe8a77Nw
	r/r3jnLxSWqdcFK1ZMmZj8Zqd/VFSt0DW0mxcVLcMdIYwjArF5G+cjuRHlQkbw+vtx2J9wV3889
	STxS4GG0J5lzXYctb0yau4G/Uszm4KNtuOx1npFMtFWexq7U7DeY8tlapAz3wBNs5Og==
X-Received: by 2002:a02:29ce:: with SMTP id p197mr36252886jap.139.1564154470757;
        Fri, 26 Jul 2019 08:21:10 -0700 (PDT)
X-Received: by 2002:a02:29ce:: with SMTP id p197mr36252801jap.139.1564154469774;
        Fri, 26 Jul 2019 08:21:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564154469; cv=none;
        d=google.com; s=arc-20160816;
        b=d+j/Edi5Q6sziHbtlTTL0rf7w3O2oNUf0mP5wr/8JX7zpuqU1qJw9mz15G8nuK7XLC
         BjFDJnGQk7ivEO8nRd9bF5tViADrRzcUPsEYjVXRJ3Hg5XAOjWvTkEaEgyD2L/IPIEim
         VBTfxy4tYEh/B+cIKhUe6g9eO8N1hKI+G+IpwuUV6DAGjYyfvkhXXABzeArTxPp9f/n9
         vwZaOmp6JvTuJ5NdGeFeIqQwVcqqCaOiESl/iBsYOw1pN45fkF45dQTlFbgTbgk22xlq
         pZcXqRgxlAoCCxrdt7g7zK3CoMz5TW/y3hqxzbi+42eRB9ldRW+PrFFW1U7LVXs7mhQU
         uY4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=F9G1CH0Ps2FRcZ/NwMc7CwEB3cMwgOdfmNpmMO9HdoM=;
        b=yMdxeVSOUvb2soskP9RrAPWM8tWcstXEuzmmskzrZxrGuW4j2QuUQOED1d535vwEY4
         oywly199t0dyNlV5AlOZNu4ruTkEj6r9hPK0D8xSe/RIyqXkGQ3b5ttN8p71a9jusjaf
         rkw0j2wQgFp6CHxfETwKxSzpnAZFD49EnAZ5eA5NmdXtPRF2fnCLA8y2oUvbElpfLQOf
         XT7PXg6iug0HmRF+ve3j0At6yzS9FrInErPHOa7+hIYzj2hSskNUXj0uf4cKal1RoSP+
         95c73cw+V3VSYo7/xLgUXIL35PDe4y6KePagbXTeq2Bvc0zQpi9lzUOqPOlwZupIawDy
         VeGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N0w2rApM;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor36149552ioh.122.2019.07.26.08.21.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 08:21:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=N0w2rApM;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=F9G1CH0Ps2FRcZ/NwMc7CwEB3cMwgOdfmNpmMO9HdoM=;
        b=N0w2rApMLkoaZxE6gBTrU8k8luxL61ZdCWczIF69GZlKQMFUb4lG2guayRg6yAIpbk
         H1X366pDlqnI3DIuEPp2eBW6njqlQnGw537yrxBAD3BJ8WtV/88SiHMNhsFBE5NfC8Mc
         6pFDGGrtahrlAC+muBEsD3Uw/mU6kjLtiI4R5g3tYOUIQwjj+xGug574LijMJ9525yyM
         PBE6JWBDuqPjDFgkXCHTfNPmGyDCt/onMSaEIBQ8DSyYxWlpz9e/7Zj/YiwrwWq4N/JH
         c1tG2fhMhAiOJtHrldKpL6DVeLTIm6XxQznNCdMNS+EWp3QiFKDkpkNeDLme62XdCPgV
         PtnQ==
X-Google-Smtp-Source: APXvYqzWkKaER3d1SoL4pM51luD5r76GIZCi5wBc/4zHT9xYg4/8N5PMzy6UISLqCi9oNf8Xd9jLBaT9T4dOYpBVyvo=
X-Received: by 2002:a5d:80d6:: with SMTP id h22mr65334094ior.231.1564154468687;
 Fri, 26 Jul 2019 08:21:08 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000052ad6b058e722ba4@google.com> <20190726130013.GC2368@arrakis.emea.arm.com>
In-Reply-To: <20190726130013.GC2368@arrakis.emea.arm.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 Jul 2019 17:20:55 +0200
Message-ID: <CACT4Y+b5H4jvY34iT2K0m6a2HCpzgKd3dtv+YFsApp=-18B+pw@mail.gmail.com>
Subject: Re: memory leak in vq_meta_prefetch
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>, 
	alexandre.belloni@free-electrons.com, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, nicolas.ferre@atmel.com, Rob Herring <robh@kernel.org>, 
	sre@kernel.org, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:00 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Jul 24, 2019 at 12:18:07PM -0700, syzbot wrote:
> > syzbot found the following crash on:
> >
> > HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> > dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000
> >
> > The bug was bisected to:
> >
> > commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
> > Author: Nicolas Ferre <nicolas.ferre@atmel.com>
> > Date:   Wed Mar 16 13:19:49 2016 +0000
> >
> >     ARM: dts: at91: shdwc binding: add new shutdown controller documentation
>
> That's another wrong commit identification (a documentation patch should
> not cause a memory leak).
>
> I don't really think kmemleak, with its relatively high rate of false
> positives, is suitable for automated testing like syzbot. You could

Hi Catalin,

Do you mean automated testing in general, or bisection only?
The wrong commit identification is related to bisection only, but you
generalized it to automated testing in general. So which exactly you
mean?


> reduce the false positives if you add support for scanning in
> stop_machine(). Otherwise, in order to avoid locking the kernel for long
> periods, kmemleak runs concurrently with other threads (even on the
> current CPU) and under high load, pointers are missed (e.g. they are in
> CPU registers rather than stack).

