Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BCFFC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:21:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5171C21530
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:21:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EmzFHtYR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5171C21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCCFC8E0085; Wed, 10 Jul 2019 14:21:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7F188E0032; Wed, 10 Jul 2019 14:21:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C947D8E0085; Wed, 10 Jul 2019 14:21:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAEBD8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:21:35 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x1so2758011qkn.6
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:21:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=vaM/jDV0vwnZcpeTJQx+SNo6Abxw5kOZNK++pSNNKbs=;
        b=k6cWkmesnSzxsSsPRmt7LgaaUqXfsKgc9fbkCd7lVnXMGHjqrWiLx+eZIzeEc4z0zf
         iMdPfY2Q65hxhAW+CUeAu5/doPkBKtzrD7z7Uu6EeAe606o8bHmJS8SlLBm21dTkGzCT
         ZU1TBg4H7qEpKDcGKe2+Obkrpw7HOu8YXf7b9FEOEK7QrKPh3dnqONPtzmdE79SV6gy7
         3nozWrbbDXKINu/Mwzi61GLZFOxgIchq4dAoklTP5a3V1XoG+ALCI+cltiskIaQWAFyq
         d6RNNpR7arA/XH+ccKs6O6+BLLSAgJgqt6dhtAaruH2yFBB5YSJjKwnqiKZXuGcOJJ43
         bSGQ==
X-Gm-Message-State: APjAAAU67ia8cVRkhx7Ue5vt4CGV4ruAtE0jX36rMmU4Qd0oxYKE4yLf
	pwIVi6L/ERZwVv4dB5asXDL+Uq/H5CD+qPEIZp9KzUleDmMDVLIfoKXdQdfLNbteeiEVpeKMTAr
	tZ0KPL+XqADm9DlaKSZIBOZVWpFWzSF5jCGToWdXczhDJyy71XMAAdwnvjJhIekBtdg==
X-Received: by 2002:a05:620a:14ab:: with SMTP id x11mr24632280qkj.186.1562782895429;
        Wed, 10 Jul 2019 11:21:35 -0700 (PDT)
X-Received: by 2002:a05:620a:14ab:: with SMTP id x11mr24632243qkj.186.1562782894935;
        Wed, 10 Jul 2019 11:21:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562782894; cv=none;
        d=google.com; s=arc-20160816;
        b=wrDq4YYi/998ocOe8DjOjr5gzdFCsuD+aTddwdFl/lVBfou5RFGUjXSHO4KK3dsAn5
         LUcXZX9W5jwBIJHuXVrhBQ/soqTdlySngaj6wBmCxWEO/tLgRhvHd0g1cunQkBWt23aM
         WrJDWJ8xoPxWI2meRsHBL/oKl6O3ETEVdva5uljVjgJKGOctxNx+xkjJXks68YkyQ4Mg
         QKPBecmYAkAbOFVq4gS8SNehpEhNycPs0JmaGMX9CRaV8zfAb/NWbm0xORZRvn06orBU
         37LMYbI/uLpiOoTjbf+jC909YMkWuhqiWi249Nu8ttuJkVNhlV7lJ1Cs4UNHe7jlMMVA
         zPqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vaM/jDV0vwnZcpeTJQx+SNo6Abxw5kOZNK++pSNNKbs=;
        b=wa2hkBcRqhaEkiDaWEj6B42yiT0bUaR4KKBEPtftP4EXrS8nqegsLtZJkxxroyOivG
         cNaJxG0tUESnHkAg755aP+msivDy8WDk3VBPzz3em3ydG0FdpQ7pkKdY1NOzjR6lF36G
         OaxlLVrNd9C/dC8xnDhz9K48TbV04GOoYmoUS74/nU9b3rUlHatR6uY5ZaIiHpC9/cLm
         kiat+STltTtteVkHmS3e5FAACAo4YxYvpiYbGS8O4heQG60NKZXCG2Dbkbl39ol4l+v2
         PfetYz/pt3z4u+1AgweZhMJfrWsU/PNQ+utLfdLlXnc7AUh/gFDIc34EJz+MwtXnG1B6
         35IQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EmzFHtYR;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s6sor4386620qtq.34.2019.07.10.11.21.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 11:21:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=EmzFHtYR;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=vaM/jDV0vwnZcpeTJQx+SNo6Abxw5kOZNK++pSNNKbs=;
        b=EmzFHtYR5s/7FzftX73JyWNWe1gQKt9q2QKmCdU683LuU4dkvC9Yg/jt3kGDQZ30A3
         tVYmKfvOul5/+g0vkHsIOJbl1c39hvRThPP1RE2VNegulSiWqLW4sVZgGvpKLr83RMjP
         GQEaYvO6PsWRUjjMJQS4Gd3uJr9l7hWaTKajaJKscDdqRAlLRgFY/jpHeuW1o0QREa8N
         r3riiQK6og8NhF2PTPFt+Wd66HAzMMvBAGMhGiog/y4kM3NrOFj1V0QIvK7iiY6Zxmyl
         Ih5a/4/nczJ8VP/QIrPoh037t3NcuZyn+As6NWR9gnWhqUDWfXY7xgffDXRyAKg60hGe
         oQ9Q==
X-Google-Smtp-Source: APXvYqwhymDEm77SIkns9B8wc1lKNrsfxnW9NBqSXp4VKy6EVvLCYpla9dXa1RZ322N03KEbau2RsEAvQMeD5eFdUT8=
X-Received: by 2002:ac8:f3b:: with SMTP id e56mr25390354qtk.123.1562782894620;
 Wed, 10 Jul 2019 11:21:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
In-Reply-To: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
From: Yang Shi <shy828301@gmail.com>
Date: Wed, 10 Jul 2019 11:21:19 -0700
Message-ID: <CAHbLzkpME1oT2=-TNPm9S_iZ2nkGsY6AXo7iVgDUhg8WysDpZw@mail.gmail.com>
Subject: Re: Memory compaction and mlockall()
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Linux MM <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 7:41 AM Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
>
> Hi,
>
> I've been looking at the following trace:
> | cyclicte-526     0d...2.. 6876070 603us : finish_task_switch <-__schedu=
le
> | cyclicte-526     0....2.. 6876070 605us : preempt_count_sub <-finish_ta=
sk_switch
> | cyclicte-526     0....1.. 6876070 607us : preempt_count_sub <-schedule
> | cyclicte-526     0....... 6876070 610us : finish_wait <-put_and_wait_on=
_page_locked
>
> I see put_and_wait_on_page_locked after schedule and didn't expect that.
> cyclictest then blocks on a lock and switches to `kcompact'. Once it
> finishes, it switches back to cyclictest:
> | cyclicte-526     0....... 6876070 853us : rt_spin_unlock <-put_and_wait=
_on_page_locked
> | cyclicte-526     0....... 6876070 854us : migrate_enable <-rt_spin_unlo=
ck
> | cyclicte-526     0....... 6876070 860us : up_read <-do_page_fault
> | cyclicte-526     0....... 6876070 861us : __up_read <-do_page_fault
> | cyclicte-526     0d...... 6876070 867us : do_PrefetchAbort <-ret_from_e=
xception
> | cyclicte-526     0d...... 6876070 868us : do_page_fault <-do_PrefetchAb=
ort
> | cyclicte-526     0....... 6876070 870us : down_read_trylock <-do_page_f=
ault
> | cyclicte-526     0....... 6876070 872us : __down_read_trylock <-do_page=
_fault
> =E2=80=A6
> | cyclicte-526     0....... 6876070 914us : __up_read <-do_page_fault
> | cyclicte-526     0....... 6876070 923us : sys_clock_gettime32 <-ret_fas=
t_syscall
> | cyclicte-526     0....... 6876070 925us : posix_ktime_get_ts <-sys_cloc=
k_gettime32
>
> I did not expect a pagefault with mlockall(). I assume it has to do with
> memory compaction. I have
> | CONFIG_COMPACTION=3Dy
> | CONFIG_MIGRATION=3Dy
>
> and Kconfig says:
> |config COMPACTION
> =E2=80=A6
> |                                                       You shouldn't
> |           disable this option unless there really is a strong reason fo=
r
> |           it and then we would be really interested to hear about that =
at
> |           linux-mm@kvack.org.
>
> Shouldn't COMPACTION avoid touching/moving mlock()ed pages?

compaction should not isolate unevictable pages unless you have
/proc/sys/vm/compact_unevictable_allowed set.

>
> Sebastian
>

