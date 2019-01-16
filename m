Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD623C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 04:55:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46D9C2087E
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 04:55:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="QWHBTSl2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46D9C2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B3098E0003; Tue, 15 Jan 2019 23:55:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 939DE8E0002; Tue, 15 Jan 2019 23:55:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828558E0003; Tue, 15 Jan 2019 23:55:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14C2C8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 23:55:12 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v24-v6so1277290ljj.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 20:55:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9dT6Z1C6XjxVvtC/JI24HhxwtHBgNAG7wWwQyTEeC8g=;
        b=nJ1eRNUf4L/faQZWrlaEkicdbg1tPrU4Q2OOSLMnk4LJeI348G5lOzAadOK/CtDljg
         Hcn2CIGVg+937GPnXc0fGPasE80T4VOh1ZxSqA6TMDVMcpArwMYcZZIkIOGdiqiCYumI
         sj2+ZaXn+E+Xd/KITHyRmPZcJ2flNzkgaSmqxciG44Qien1abHRtkvzrIb6Z4rLLgtcd
         8OpnABZZxjVa8R9mquBDPLKE6F6dK05DPICW9Ocq7VwgK2KayD+sHePc5CSidAPKd74c
         MjagqSCgoxE6aLOOUTTJ91ZfRTM5ujy4+grixPr3aWPR8ZvA1S7xWbbxBjpHza7BlQ+M
         bcLA==
X-Gm-Message-State: AJcUukfF9WtG1u6Fp5ZX0CAanhEHYo/W/gk4oDUGea73n/TkrkQ6JKCP
	cYdzrfLtUynjMI1ngW/Rzvbip0y+bVz+n0DC+5CHVwL/ftRiE4aIo5G9YnMmFoZVS25enU3kFDk
	gXWv5Dug9PheapvxdbrQsZqL6sCRMcflulC0e4WhIEKH2LBU6/qzl0S1z4HvMnjdEMn7at/M1a4
	o7ITPfGucaGdbApVQtu+sX83o+7AGM2P8OewGqicCcIEfnwr9OpQwrHpgVbnYS5ZlRFgMiXNrSv
	faIk/fnkumzquAAiUUO+kZrve3TNRSR06dR2WmpgKrADVMh25ZNOhceh7czZFUasOr8Kim1Eb7P
	4bI3mZ+ia94qUTl6bVFNqH8qcY62jNxWdWnnECUo7cCBeA8L5MvqXuW9KRvpQ6c0hip4buFB4rx
	b
X-Received: by 2002:a19:200b:: with SMTP id g11mr5239143lfg.58.1547614511243;
        Tue, 15 Jan 2019 20:55:11 -0800 (PST)
X-Received: by 2002:a19:200b:: with SMTP id g11mr5239100lfg.58.1547614510059;
        Tue, 15 Jan 2019 20:55:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547614510; cv=none;
        d=google.com; s=arc-20160816;
        b=ZoHwzC0c0VLY114nIt8j8uzUolvpdGDs/MLmA8qKFMPo2Ffy5rybzwoBdZz00/SaP/
         Sqiog/mj+Zrg0Bs9xPzh7xNPXTR6HUra9cCPEgpEPRQyzBQqd4WrdT+8qdhlh6gdsRlE
         EzFW8hnEmZ6P+PLmQmMU1fhcCjfoXqcjX4GMiNGE3uBTY2X8tjuaHFg9pfvZjyqdl+qi
         2FOq0EAPdqvQ5QpfHnqf4DAyDo3ZU5RacSXfW/WodtW/LiT0g1iv26I93vqM1vP9LcLF
         MRArHHVejJroc0XwIewBKiG5K34zyT3Tb635pqRjSCBHjwxlt2VKFGgoib+YNsORz5yq
         hmmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9dT6Z1C6XjxVvtC/JI24HhxwtHBgNAG7wWwQyTEeC8g=;
        b=a7l1Z+/MNO4vtXltHRw8sGZpYuJWVJnbgX5cbbfxAkPD1IVoGIARL+sm1uVjL3udqP
         0iH3pjFaMOJ9RK69sRcOw2iUITdKcANgABwlNP6sAHL7n8A4SzQ2oyVzsk//3eQ8tdOV
         40VpWIgLVmn1sofxUOVnH4mcQEXOD1+Kxnh9B+UncUbwm5/xvf0GFlMD0J7G8aFa+9ar
         R4XbiZsqRh383V/MiwlB8wZVdBoUKfXchXgXvHq/oH8+aSyz0cUPSn6Wb3siysTmqcRa
         xwQaDKPzpuugTLm+tN0EQw8k4AR8OTAwCO8huatMDJtBes7PR/y6omnl9F/J9P0KPYXJ
         y91Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QWHBTSl2;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor3713338ljh.37.2019.01.15.20.55.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 20:55:09 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=QWHBTSl2;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9dT6Z1C6XjxVvtC/JI24HhxwtHBgNAG7wWwQyTEeC8g=;
        b=QWHBTSl2+YiO/WzrvJahbbQ87bpLZ6/onh/Kp5srLGkZrYPlaN6oukCtm1Z0AT1LYO
         HLIcgFSc+gs7NYsU09HhM39Ym/DIXj/Veu+3Ku/WQn/1IYdcRQ6YkKQPT4jpWtQ4IQkz
         Qll14RPpm50bpXY+tnYbA7BNDP+sTXeHXafdU=
X-Google-Smtp-Source: ALg8bN7oAgPGcl183G+LuNUGNucopdvqPY34PyYJZooJExPv+2mPVn/uu2UEktCbgTvVNeN2AeyhVA==
X-Received: by 2002:a2e:1bc5:: with SMTP id c66-v6mr5060044ljf.96.1547614508877;
        Tue, 15 Jan 2019 20:55:08 -0800 (PST)
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com. [209.85.167.48])
        by smtp.gmail.com with ESMTPSA id z64sm946035lff.39.2019.01.15.20.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 20:55:07 -0800 (PST)
Received: by mail-lf1-f48.google.com with SMTP id v5so3829616lfe.7
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 20:55:06 -0800 (PST)
X-Received: by 2002:a19:c014:: with SMTP id q20mr5021271lff.16.1547614506503;
 Tue, 15 Jan 2019 20:55:06 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard> <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
 <20190115234510.GA6173@dastard>
In-Reply-To: <20190115234510.GA6173@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 16:54:49 +1200
X-Gmail-Original-Message-ID: <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
Message-ID:
 <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116045449.K5YFd4xzS3Mnc0qEagoMK3KGHWEXUhWeSJSyASvLVtk@z>

On Wed, Jan 16, 2019 at 11:45 AM Dave Chinner <david@fromorbit.com> wrote:
>
> I'm assuming that you can invalidate the page cache reliably by a
> means that does not repeated require probing to detect invalidation
> has occurred. I've mentioned one method in this discussion
> already...

Yes. And it was made clear to you that it was a bug in xfs dio and
what the right thing to do was.

And you ignored that, and claimed it was a feature.

Why do you then bother arguing this thing? We absolutely agree that
xfs has an information leak. If you don't care, just _say_ so. Don't
try to argue against other people who are trying to fix things.

We can easily just say "ok, xfs people don't care", and ignore the xfs
invalidation issue. That's fine.

But don't try to make it a big deal for other filesystems that _don't_
have the bug. I even pointed out how ext4 does the page cache flushing
correcrly. You pooh-poohed it.

You can't have it both ways.

Either you care or you don't. If you don't care (and so far everything
you said seems to imply you don't), then why are you even discussing
this? Just admit you don't care, and we're done.

                  Linus

