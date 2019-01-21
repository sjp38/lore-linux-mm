Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5094EC282F6
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC5442084A
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="irk0kpYT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC5442084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88F5D8E0035; Mon, 21 Jan 2019 03:30:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83E548E0025; Mon, 21 Jan 2019 03:30:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72DD48E0035; Mon, 21 Jan 2019 03:30:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 491C78E0025
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:30:41 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so9998940ita.1
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:30:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Ww085OACm4i7mqE67ZdIQ/eDnX5lMbW7fzlbmIgXAEk=;
        b=lw+WjLv2DT/r4OB3hBKIWFhzBsixwzn+e/aO8qYFHqSjNy5RhTTf5EZPit/WRKcapV
         2bH6M0OAY2JxlAru98y8AUGk+ogHpzlIG58pT1q3CI/7oF7uWTdtRzomJvSH4XsdXdq9
         Vvltl3NBymbqd7ygGJkycqiwGUFxo1Pk/iNXj82M7Jk4FEoSMQi9clfoZeuPR2dpWQ+x
         uq6nHjHD5t5ehq9RVynHmOCnBvaQ715ssjHrOipDs89Fk1Awbqp4XdMshY7MKlz3iQsy
         IPdfDTWl3m1vsNHOvQWW0OkrxGxw5r2zeUDNKWSRJPnOwsPFOBTmiWiVXPyrn3FfB4oN
         vrtA==
X-Gm-Message-State: AJcUukdZmIJWZqSyAqWGRmaiNcEg4dy8+xL8ZpzNmdMiAs1aTa0C7LNY
	Qxd9ezAxsypsdNgNNIEoASRMLkD+mgTyqz+CbPfHE47KtdGRI6acvSxIDUQ43cwnEJuWEncI+52
	MJDPn5HerT7CYM56pg64JfdtH13yko3RYMd1wFupu+Hwl6ANqy036AI3vfZsGkT12d4Cv+7G5/T
	FH9rgjwQ7oxao5EEyHRuEX27sE0OF/Rerk4qrI5rvxP1h9nYxGNnR1qRxdxcS6zwzEVW0cjuX+M
	RBJEtYn5S9DmrCQwZLRg8rIc8ym0pl9sOzKNcIO4tDVtNwmBKgyzrsgzV8eoEDKxKRaMlucmtB3
	28zfeu4kXylwho1A9pIdLE+oSbBhswmKqNZEcFiKFIXZShS/sNX2U4x0+5TIh87M70MLzE/Qo01
	Y
X-Received: by 2002:a02:98d2:: with SMTP id c18mr15625497jak.11.1548059441003;
        Mon, 21 Jan 2019 00:30:41 -0800 (PST)
X-Received: by 2002:a02:98d2:: with SMTP id c18mr15625479jak.11.1548059440255;
        Mon, 21 Jan 2019 00:30:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548059440; cv=none;
        d=google.com; s=arc-20160816;
        b=prv8I++3IL/xO03+W4YVzPYUMD3mocnXANS5NJ0/JoOpbFmIikqEiS5CeFUrqIwCCS
         n98IGm8HBuohlXHf9GFj6WacjfmTgeOz2S7/9Ll8ZVckMaQjrqYMZoBXCPnFMRsPJbQi
         q50zE4W9e3C5AYAFc9nFLwu7TKUjUsVySyPiYmcdPBhPA0wXjmcOLs/tWkjO0IL7nlH8
         w0SJUKVWkr28qS5MACfQekB00DCrRV0R0HPiSv6a6CR0kY1A1B6jcPYreAg7AWxKD2jy
         zfrrQ/tmUyQTDEE6OJ11y84Mr8cZ7i2RFQhPTWfapnYtJGkogXQq6G5BOZOGUHjYM6Hg
         H+Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Ww085OACm4i7mqE67ZdIQ/eDnX5lMbW7fzlbmIgXAEk=;
        b=zQZOdQ01XZxb/bYf+m7KOJnLtM7I9zEWPAKPztTFQl6Y2OxpZFFNgPgRIqe47+ZiXz
         lqyox1Pf2kcIqRqn4ZtWSpkLh2rPaa5n6KME0tJVCHlA0+SntIzTvMB2cB/+VAUCW5eW
         pVb7fdgsgDvhyfhNoUIP2HGNp2NDrEjCYTSywRloFHVH+zORbc7GnWx8z2BSi04GXvKd
         e8dffib10wmqbePVGE21o1mFZqH+oRII0IX1OJKJ+PR5P2HBZISfYqxgYAAM9wCh6UVm
         7ILHvHEP58KOjevjmL/3tHE17EpK2ZXqFUX5wAAIH320fRCtBPsRhrjPkHZxXoivnvUI
         O+iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=irk0kpYT;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b26sor5363235ior.98.2019.01.21.00.30.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 00:30:40 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=irk0kpYT;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Ww085OACm4i7mqE67ZdIQ/eDnX5lMbW7fzlbmIgXAEk=;
        b=irk0kpYTWl+fMLn717tgCoPUMr7EWiqL5y7s82Xc9j0VPLy6PAEnLNMuGjDMoFV0Yy
         2s6vFd/lJb8XWemgbmryxsgj9dEtQNcd32fDPLB1HsPt+SCVEUwFg4/boDUMEJovqRzI
         tq52Q6C+gt6cf5wqYzISfoTdLLYBN02u3ujIZskb8jftLw92rTGZZjnJz1hsV9wXrDwk
         QqRqk/lF7M+Uqv3JWbLC6qUiCXDAOeAg6XTvtuBeOl8E/SF/msImGHKEtZ9pK7L5/RlO
         LT2jzgZDAGSaMmD8El1xkmk10aw+dR7ee7ENpuhltHJDDXl+vMsj0KbQTq6Ym/yi89P7
         X1ng==
X-Google-Smtp-Source: ALg8bN6pVSUQAGPoALJVcBXrooWWBo6DjGveKj9PCGXAw/Gya0V/2bdBH5M4qgvqAI4lru73E5WrUgt3rKufK0pKDe8=
X-Received: by 2002:a5d:8491:: with SMTP id t17mr16024815iom.11.1548059439657;
 Mon, 21 Jan 2019 00:30:39 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547289808.git.christophe.leroy@c-s.fr> <935f9f83393affb5d55323b126468ecb90373b88.1547289808.git.christophe.leroy@c-s.fr>
 <e4b343fa-702b-294f-7741-bb85ed877cdf@virtuozzo.com> <8d433501-a5a7-8e3b-03f7-ccdd0f8622e1@c-s.fr>
In-Reply-To: <8d433501-a5a7-8e3b-03f7-ccdd0f8622e1@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 21 Jan 2019 09:30:27 +0100
Message-ID:
 <CACT4Y+Z+UbN1rjHr3T5rgHpCJUknupPvEPw0SHs1-qjWBDhm3Q@mail.gmail.com>
Subject: Re: [PATCH v3 3/3] powerpc/32: Add KASAN support
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, 
	kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121083027._ZmKlI13cE6kcqT-SGrUSgDrpaJIMYHeH91hJKS31xg@z>

On Mon, Jan 21, 2019 at 8:17 AM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
>
>
>
> Le 15/01/2019 =C3=A0 18:23, Andrey Ryabinin a =C3=A9crit :
> >
> >
> > On 1/12/19 2:16 PM, Christophe Leroy wrote:
> >
> >> +KASAN_SANITIZE_early_32.o :=3D n
> >> +KASAN_SANITIZE_cputable.o :=3D n
> >> +KASAN_SANITIZE_prom_init.o :=3D n
> >> +
> >
> > Usually it's also good idea to disable branch profiling - define DISABL=
E_BRANCH_PROFILING
> > either in top of these files or via Makefile. Branch profiling redefine=
s if() statement and calls
> > instrumented ftrace_likely_update in every if().
> >
> >
> >
> >> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init=
.c
> >> new file mode 100644
> >> index 000000000000..3edc9c2d2f3e
> >
> >> +void __init kasan_init(void)
> >> +{
> >> +    struct memblock_region *reg;
> >> +
> >> +    for_each_memblock(memory, reg)
> >> +            kasan_init_region(reg);
> >> +
> >> +    pr_info("KASAN init done\n");
> >
> > Without "init_task.kasan_depth =3D 0;" kasan will not repot bugs.
> >
> > There is test_kasan module. Make sure that it produce reports.
> >
>
> Thanks for the review.
>
> Now I get the following very early in boot, what does that mean ?

This looks like an instrumented memset call before kasan shadow is
mapped, or kasan shadow is not zeros. Does this happen before or after
mapping of kasan_early_shadow_page?
This version seems to miss what x86 code has to clear the early shadow:

/*
* kasan_early_shadow_page has been used as early shadow memory, thus
* it may contain some garbage. Now we can clear and write protect it,
* since after the TLB flush no one should write to it.
*/
memset(kasan_early_shadow_page, 0, PAGE_SIZE);


> [    0.000000] KASAN init done
> [    0.000000]
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [    0.000000] BUG: KASAN: unknown-crash in memblock_alloc_try_nid+0xd8/0=
xf0
> [    0.000000] Write of size 68 at addr c7ff5a90 by task swapper/0
> [    0.000000]
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted
> 5.0.0-rc2-s3k-dev-00559-g88aa407c4bce #772
> [    0.000000] Call Trace:
> [    0.000000] [c094ded0] [c016c7e4]
> print_address_description+0x1a0/0x2b8 (unreliable)
> [    0.000000] [c094df00] [c016caa0] kasan_report+0xe4/0x168
> [    0.000000] [c094df40] [c016b464] memset+0x2c/0x4c
> [    0.000000] [c094df60] [c08731f0] memblock_alloc_try_nid+0xd8/0xf0
> [    0.000000] [c094df90] [c0861f20] mmu_context_init+0x58/0xa0
> [    0.000000] [c094dfb0] [c085ca70] start_kernel+0x54/0x400
> [    0.000000] [c094dff0] [c0002258] start_here+0x44/0x9c
> [    0.000000]
> [    0.000000]
> [    0.000000] Memory state around the buggy address:
> [    0.000000]  c7ff5980: e2 a1 87 81 bd d4 a5 b5 f8 8d 89 e7 72 bc 20 24
> [    0.000000]  c7ff5a00: e7 b9 c1 c7 17 e9 b4 bd a4 d0 e7 a0 11 15 a5 b5
> [    0.000000] >c7ff5a80: b5 e1 83 a5 2d 65 31 3f f3 e5 a7 ef 34 b5 69 b5
> [    0.000000]                  ^
> [    0.000000]  c7ff5b00: 21 a5 c1 c1 b4 bf 2d e5 e5 c3 f5 91 e3 b8 a1 34
> [    0.000000]  c7ff5b80: ad ef 23 87 3d a6 ad b5 c3 c3 80 b7 ac b1 1f 37
> [    0.000000]
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [    0.000000] Disabling lock debugging due to kernel taint
> [    0.000000] MMU: Allocated 76 bytes of context maps for 16 contexts
> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 817=
6
> [    0.000000] Kernel command line: console=3DttyCPM0,115200N8
> ip=3D192.168.2.7:192.168.2.2::255.0.0.0:vgoip:eth0:off kgdboc=3DttyCPM0
> [    0.000000] Dentry cache hash table entries: 16384 (order: 2, 65536
> bytes)
> [    0.000000] Inode-cache hash table entries: 8192 (order: 1, 32768 byte=
s)
> [    0.000000] Memory: 99904K/131072K available (7376K kernel code, 528K
> rwdata, 1168K rodata, 576K init, 4623K bss, 31168K reserved, 0K
> cma-reserved)
> [    0.000000] Kernel virtual memory layout:
> [    0.000000]   * 0xffefc000..0xffffc000  : fixmap
> [    0.000000]   * 0xf7c00000..0xffc00000  : kasan shadow mem
> [    0.000000]   * 0xf7a00000..0xf7c00000  : consistent mem
> [    0.000000]   * 0xf7a00000..0xf7a00000  : early ioremap
> [    0.000000]   * 0xc9000000..0xf7a00000  : vmalloc & ioremap
>
>
> Christophe

