Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAE3EC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:31:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BF8720883
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 16:31:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PTIp3bf6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BF8720883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1215F6B000D; Mon,  1 Apr 2019 12:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AB0A6B000E; Mon,  1 Apr 2019 12:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8C8D6B0010; Mon,  1 Apr 2019 12:31:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A98AB6B000D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 12:31:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j184so7803972pgd.7
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 09:31:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZU+dn0jh+GKq8s3PGdQqhFLxcPJemFqyajBFbkPbAEY=;
        b=DzFWixQmhhui0qonHdHZeLG4zhwU0OtW/H1ugOQKTfqCsOjmC40+T8EdjxE/kkA6pj
         mA+/RO23iIg7utRIrEJZNNsS/IN2Onv/8XQTPlfzz5RWRtezvE9pTSEwqzM+RHZFuCrY
         MNry/bgqQRnICmaiJ2VXF1tKZzUt5ZHxItZ29ex9czaahdVykrxi16X/EKKbYkscFAo5
         ib4NC2QO3EW/awRzw2V9Zbx5YwBxc/yma3A0opszyHoEJ0nqsuusObMuioa6zcftSRMd
         ztvbCOT9EU/0pTUAJonCakY9/aZoSlxG6lodqE7gdRudKR3KqU92BvY2GCLi8fhfmYKF
         Ehxw==
X-Gm-Message-State: APjAAAVQhi/m4Hpg+2s9kLTgedJT/QAiL5KhLSn02vil7lnDUnCgkSwH
	xCCJtOHBor1uMKuI+H53ozSLbbqBVfTMCjlXQuuYdN8Nk0Y0aRW/bhYCSReb7QE/juRz7Gesp3q
	GhVfh/kRurdpiJ8r1qrLr37yXezVqaJTM7Paw3PhpbqYSttMPw8a2C5M1qAjNCNOxRg==
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr1662882plb.147.1554136275170;
        Mon, 01 Apr 2019 09:31:15 -0700 (PDT)
X-Received: by 2002:a17:902:e110:: with SMTP id cc16mr1662824plb.147.1554136274490;
        Mon, 01 Apr 2019 09:31:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554136274; cv=none;
        d=google.com; s=arc-20160816;
        b=NL8ipDGGJUZ4JBsvHnGzNKU6BLQZ2beVSHa1G4dipC760DCBRqrubwTVQA1txNY1Av
         Olfk4iPUXWvjAKXz43TdqiJvE2zb7CAVhMXOBCoBKJAcHSlRfy5ZyP/NDuwIlrpxanME
         rUNvNdB9DsYfx/8xJC5chD3M5Odf8QsMHCGqmm8qepXfJDqh31T0iv2VaIwfupmupqFG
         l/GdqRzNCiUpudc2OhTI/TmBKO/EPVC8M8YA83pEPrNICzXi+niLC1j+HZ2DQaxi+3Ae
         EOAaJHATSS3siz3FBPOc7sCXDJsN+aJ636MBYY1vrC52TYv9Pwqg68QokhrbFwl8AXbP
         6ySw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZU+dn0jh+GKq8s3PGdQqhFLxcPJemFqyajBFbkPbAEY=;
        b=CYvS6mGvIo3wLObhtp1B2bqG4HAMl/VM8fYv8Ru/cK4qN73G/qZl26KTNK2T6I+ESJ
         4YCH3/PFJRqxI9Dx7QiIHfwOaDb/Pqrg/M2NzPTh24fhlCNwdSxe24I5q6QRuWvQxaK2
         RZk84wiDMV8taF1mKKf8V69e/viPiRBhRnpVTGxpc1DgRalMiG/qdCmBhDUvCtz7hVZO
         TbJo/w/V057D6TN6z9HZziIQiEAbp1v8nERBQz6FpmMRn2v4/Jbo1X+q/+eTHgqnXXMv
         LESq+giEKTabTmIXeDeKYME7jNWUzfibD+KupUS2ZdjNrm8RPbsUX2rOAlLm0Q/1fP5H
         MQ7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PTIp3bf6;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor9132831pff.11.2019.04.01.09.31.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 09:31:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PTIp3bf6;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZU+dn0jh+GKq8s3PGdQqhFLxcPJemFqyajBFbkPbAEY=;
        b=PTIp3bf6t/txxwbyIhK2Z2NTv/LPvGZaD1YlQIyY7lsBudjLnQVLZL1Ve6DOnMyTeD
         G/Dame8cNB44MvMZTF2gAoGTZUS03glmWvl0E/tvg4a0ZBYAQK4IOIeZq/MXXAKoZqj+
         F6zYfVzbbP3zb9iLZX0cHi+6GheWUFJmUaje6SxdJC6r1Flin3Q8nkYtlKHyDrN0MKp+
         d54pbR9XgnEZ1snB5K1EQJf/A/JficP4eiTjnEc6DfacnN7UG9D5RS2NFmRUmas0xcd0
         r+8ee+ZqKRGoK77BZOEkzmNU4opoW9vsaQ2FL/noPB84uf2QBKoKbvS6CrvLzzMd1YQW
         Yugg==
X-Google-Smtp-Source: APXvYqzUFjnUeTl2Hft5upNX5N31s+IVzFcZsTMvRdCq0jP+7hG4JMl7ueo4ZIuA3o/jOjyFi99QPHH1JtTQlKxNamI=
X-Received: by 2002:a62:2a97:: with SMTP id q145mr64643186pfq.22.1554136273828;
 Mon, 01 Apr 2019 09:31:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <665632a911273ab537ded9acb78f4bafd91cbc19.1553093421.git.andreyknvl@google.com>
 <20190322162223.GW13384@arrakis.emea.arm.com>
In-Reply-To: <20190322162223.GW13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 18:31:02 +0200
Message-ID: <CAAeHK+xjCUqpyOuR_G=SQe2GURJTyZjEueYoKRBA+hbZeAFyvw@mail.gmail.com>
Subject: Re: [PATCH v13 18/20] tee/optee, arm64: untag user pointers in check_mem_type
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 5:22 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:32PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > check_mem_type() uses provided user pointers for vma lookups (via
> > __check_mem_type()), which can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  drivers/tee/optee/call.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/drivers/tee/optee/call.c b/drivers/tee/optee/call.c
> > index a5afbe6dee68..e3be20264092 100644
> > --- a/drivers/tee/optee/call.c
> > +++ b/drivers/tee/optee/call.c
> > @@ -563,6 +563,7 @@ static int check_mem_type(unsigned long start, size_t num_pages)
> >       int rc;
> >
> >       down_read(&mm->mmap_sem);
> > +     start = untagged_addr(start);
> >       rc = __check_mem_type(find_vma(mm, start),
> >                             start + num_pages * PAGE_SIZE);
> >       up_read(&mm->mmap_sem);
>
> I guess we could just untag this in tee_shm_register(). The tag is not
> relevant to a TEE implementation (firmware) anyway.

Will do in v14, thanks!

>
> --
> Catalin

