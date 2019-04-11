Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A86EFC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C7A220693
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:40:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rcj98wqA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C7A220693
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F15946B026C; Thu, 11 Apr 2019 12:40:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9C556B026D; Thu, 11 Apr 2019 12:40:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3D6E6B026E; Thu, 11 Apr 2019 12:40:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8096B026C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:40:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s26so4556034pfm.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:40:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xjkeztdV1bSp1P3BTq+bBb2VfW42+e2YxlyeXyVPm18=;
        b=Wt2cDiJ3u6NrgsJLlut13asA61EJ5IA/9dFtpE0AuCgmgUzXNcDwMOtX2hR6I8rR9p
         i5/ECi6vAZmcmZT1hNvw+pExRzGGe2xY+1q+19/DK5xh0Can+lJISEdIOY2JIqTNqDjo
         A/j2Vt8ICoJF6TMw2nAjFT/nwykltP98jUNV/BRJHAhWsUNPV+ZNzVa8s7uhiAQWNs8c
         wbzkqIvdTsLeaOcBNP4Y/wsJf1n6qdSAmxSPE9BGZtNe2rj/e9eoAhNpSd4zqeYZV/VC
         4iWq90NFuELx4y2XHf7u+5EFO9HNTQCRUvgwQqjh7A9XbxVq3wbKnEMBuVW+UzytHQZ2
         fdTg==
X-Gm-Message-State: APjAAAXXeSIhXDFhpyNJvmIwbYPzQOamdhKAWHvucN17snNEpOFRXQPE
	7+OVZkZm4fFQ9qKrYOzxJ4UYUtbf8MLxehGrVXwjoMPJLjgmzr/j548Oplvfl9PnIHHKUyuqqiY
	+7g9PEHKrqC9vMxhXDHLlOMS17rN5l9xbsI5A91Xjvo7sOrz22b3CYi0WqXHONSRhSQ==
X-Received: by 2002:a62:1c54:: with SMTP id c81mr9175745pfc.122.1555000853283;
        Thu, 11 Apr 2019 09:40:53 -0700 (PDT)
X-Received: by 2002:a62:1c54:: with SMTP id c81mr9175691pfc.122.1555000852647;
        Thu, 11 Apr 2019 09:40:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555000852; cv=none;
        d=google.com; s=arc-20160816;
        b=CSD9xDxh0Bxzgl/uCyU9TW4zEbiXjIV+tJlOYikqjUwJoWgSHr9U5PLc6n80I1B4sg
         vffS2u9qPt2CqkCZJgwvFJC2aSwSEqjytbusa9IWHnBQk7P0VbylODMP+xY+v0sNjogp
         N2q36hIypuOsc9Cgo1k+f/Q83MrgFKwfiokSlp6zSwNPn6SzvQGkY0jBAgBBHcoxFIpy
         KMqIpxmxtTKWJDX0z1dV8zr/A2Fux7A1YQ2+LEiBHKOYDatEp2DMf5y4k0lDozvhp305
         eMJJEls5nJb67pp/U0/acl/OjwHIeiwnhlELoIuFwbYkdOYAaPmxIivHZpB5DnJZLdc2
         oD3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xjkeztdV1bSp1P3BTq+bBb2VfW42+e2YxlyeXyVPm18=;
        b=mz4c/N4YO28mdRW/wiCgcjxETMEWwdvXp8jJBKlHP2dm2JwDe7vkPao1xe1TFjs6HH
         pQdRricimqm8pSnQVR7TEI9K9NWFjtiMpnHN8rrsjjON3+ffC7DJFCBbkYXq3sAuCgnz
         sWf2eRG0N1VwP1+asnB0hTPv5A+TZ77I8Pwtrm3mHZPFKltc8Yh33RyYPsz40lZceWZH
         YhKIa9pUXGqAFI+HLFwTDUgaTy8yNznY/J62lCDkgjebcS/emrE27OYrWt7LIwJ58S1Z
         /QKVhlEh4r6Bi+bV3f6F+7LlHFJNjnlUpE/FNT6m+d+BGrcZF70pIJ8MZG2HILm8gv8a
         xrWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rcj98wqA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 89sor11985717ple.49.2019.04.11.09.40.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:40:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rcj98wqA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xjkeztdV1bSp1P3BTq+bBb2VfW42+e2YxlyeXyVPm18=;
        b=rcj98wqAzGbatlWWe59/uozNfBj4rO4ppoFs7mGR2ajPBUwj64832uJJyerLf4f3hB
         NnmxAn4yW6fcN9KVe0IAWbiXYZY4vrQtwmFymMNZVnSiQ0JpqGAyOD1UtGfQdtW01ZeD
         OaNzPQgtpvIEpNfKlI1wguSq5hSEq91Dh2i894yBi6iNy8BZqecoRn3JObtitoOIgehs
         yUjSzlhM47F3YfhW1IImyLMgAY/Zrc35jZyjy4XfebF+xbNmuq3uLzYelQ8U9PBP7Mc2
         OgzLzImWEduK38qhmERe/KjDfP1ALP0KObg7rAae7KbV6i6xu2IkaulXfjPpeMuaoj3O
         F2bw==
X-Google-Smtp-Source: APXvYqw84X17/2tMcnAAiHtTY2ZpMsDA6RxuoF7vbUoxpmIEnE9pJ0qp4rvejKC2mQB45W0JQtnaZYip7fW/+yH01xM=
X-Received: by 2002:a17:902:bd4b:: with SMTP id b11mr14797620plx.68.1555000851965;
 Thu, 11 Apr 2019 09:40:51 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
 <20190322154136.GP13384@arrakis.emea.arm.com> <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
In-Reply-To: <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 11 Apr 2019 18:40:40 +0200
Message-ID: <CAAeHK+zeeTw7fpXoV6YYRyizGCL0d8pqDS=-z2pBoWmBzm+eTQ@mail.gmail.com>
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in prctl_set_mm*
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

On Mon, Apr 1, 2019 at 6:44 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> On Fri, Mar 22, 2019 at 4:41 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> >
> > On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
> > > @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
> > >       if (opt == PR_SET_MM_AUXV)
> > >               return prctl_set_auxv(mm, addr, arg4);
> > >
> > > -     if (addr >= TASK_SIZE || addr < mmap_min_addr)
> > > +     if (untagged_addr(addr) >= TASK_SIZE ||
> > > +                     untagged_addr(addr) < mmap_min_addr)
> > >               return -EINVAL;
> > >
> > >       error = -EINVAL;
> > >
> > >       down_write(&mm->mmap_sem);
> > > -     vma = find_vma(mm, addr);
> > > +     vma = find_vma(mm, untagged_addr(addr));
> > >
> > >       prctl_map.start_code    = mm->start_code;
> > >       prctl_map.end_code      = mm->end_code;
> >
> > Does this mean that we are left with tagged addresses for the
> > mm->start_code etc. values? I really don't think we should allow this,
> > I'm not sure what the implications are in other parts of the kernel.
> >
> > Arguably, these are not even pointer values but some address ranges. I
> > know we decided to relax this notion for mmap/mprotect/madvise() since
> > the user function prototypes take pointer as arguments but it feels like
> > we are overdoing it here (struct prctl_mm_map doesn't even have
> > pointers).
> >
> > What is the use-case for allowing tagged addresses here? Can user space
> > handle untagging?
>
> I don't know any use cases for this. I did it because it seems to be
> covered by the relaxed ABI. I'm not entirely sure what to do here,
> should I just drop this patch?

ping

>
> >
> > --
> > Catalin

