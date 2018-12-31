Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22CC8C43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 08:24:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBEF320B1F
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 08:24:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lL9PqDvS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBEF320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A1D08E0087; Mon, 31 Dec 2018 03:24:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 350998E005B; Mon, 31 Dec 2018 03:24:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23EAB8E0087; Mon, 31 Dec 2018 03:24:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F07F78E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 03:24:28 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so31224488ioh.21
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 00:24:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=x/dJbjiOAY3ymU6pajADp9+hSys+HJ1L9NBPmb3INQs=;
        b=HtQBlXAX6pt0YzcWxU9BFOw8v+7Jpo/9z6MdlLWFjNcHIifM6ukj6yk61lZRAkTvo3
         bVoI15+Q+6IXVotDk5gxUSQSgJKpyoIxm6Ytf02H/zEWA8W04MuIQ7DIw7OPWmvR9tL4
         LkVn/QrXLT96QpexPpsjlQhy55wJ8zFj9eS9znACmsDnNmo/gRv4173NeEVL5BrLElYg
         qNK9/bIJl0BzEOSSDjmtzirxNZmR9MhBuAjyN1LTm2czHhsq4aw3oRoE+kINPzMhoNbI
         gqE4QME7nUiJ3qHdSv8d6g4zI7jjJRn3LHBaI61PcvawrThkTt3cuoVpnKqS9SfvPnqx
         780Q==
X-Gm-Message-State: AA+aEWYj/yg4422DKRQk+vD0Yy27ZkHPXP8Mgl2dtCVc4zeLKHe7jdqP
	tfKcwI+dJrvR9NJnHvr3LvPY8M8z5r8JaAOKTMgv2EbfpEpYw+Ipdir3Dx+2/3n5quyqTtHamEk
	9YEcRwMW+IObFlxc0zw7i+OlDg6zBRldT71h/S8Kjcof2vNKABJ3SNcgBaBCgYccW/X7xXbg9R5
	isXuYTSq153GF3ObRt2hvRXUyVZdIK530S3YHx/hF04EQkv+EaLcn4fsLvrCaKfzdQuXjgy9N0j
	vghcR2VybMAg7Q7DryuLW1NrjhRPSRmhXzoX4r5ttya2jHWS8ytP0uDMHoyGdCLcFCx/JnpKYSC
	YF0mjUBrqmJm5Alte7z1QRDn0ovRrzvxIjIg1QMic4hoKHrUFsTWncT8S1lDREenoAfeS7knbpv
	Y
X-Received: by 2002:a02:590:: with SMTP id 16mr24578219jal.48.1546244668721;
        Mon, 31 Dec 2018 00:24:28 -0800 (PST)
X-Received: by 2002:a02:590:: with SMTP id 16mr24578198jal.48.1546244668145;
        Mon, 31 Dec 2018 00:24:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546244668; cv=none;
        d=google.com; s=arc-20160816;
        b=Ft8b+DlEq6GiQ6dIIuFstxjAqqu5xI0AnXwOo27i37swXtcxuCxjfDYLAZc+tZJ8q3
         ZcMwSGNAuqCSFURql+yIgy5V3NQJoXjXIhYOzAaZcVss4N2viXoAa+H8+X4LuV2/LCi+
         9BzEJmQ4qTP4UZPFw4gSe5Un2J1310Zz9+9jISuRZT3yRtqelfJiH8K9rIiVbpvUK5qg
         qr5bbe58huJfQGYGI8pHLwwYFOJTJDhmDWc6AMnR7+MVseHYFGXCIpAYNfafI6NHbJXB
         s+WHRFwcj1AoMi7mgXZqRBWVeLfEWqJRFEc7zZtL2jwIaN6upsb9/dpGY78BWzucavoy
         r37g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=x/dJbjiOAY3ymU6pajADp9+hSys+HJ1L9NBPmb3INQs=;
        b=mSXenbRYmGKsAkNd5UgG/u5DgyUovOG1K5ZvIKTtG9P2Jab58TqORVWKen+g8FKpP5
         4a73hcB13mU9L5QiJKzvpPtAOAVwKHJC/gWhcOTAJge1Ta1AjSrPS5x5477J/0NsBPKU
         zpYvvUR8h6r4SL8bQItBSPXdZJZyK1HD9DP0p6DhIKWEEj50mgv6MeaSweYCTbM8qQrX
         xz9yauKZJo2pEhmyz8F1EV9EhSYvOMluhulFz4gBkyV0xSMrZapwmuyKv8YYXCM7eYoU
         q+0snvPsxxABMnx2lxVjvHi/Jn5mC7Cereu3yzHIRmymJhNaSqwOJNxey1ULIkJF2Ytz
         IeKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lL9PqDvS;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v20sor31247342ita.10.2018.12.31.00.24.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 00:24:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lL9PqDvS;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x/dJbjiOAY3ymU6pajADp9+hSys+HJ1L9NBPmb3INQs=;
        b=lL9PqDvSoOx02XKuKc4YXYvZEjuWMuahfKL9/Xlz+0U/k9gTkaDk+cOWtoH04IgSmI
         6+tiQ+AC5KSIHUJhvxrLuW51jmhUH/fp2d6d2IdQqYmm7tzVKr+uUTGPjrm2BxV9mxgx
         U5XykdJaTfL4SbVPowXm1de5Add8k69pE+f1VJEf3jVHdF9CWVnkAhzrkL5S07Hk7qZS
         0VKs3/9VHcOojv1drHai35XhpBT3rppyZakSOnZ16wmPCBPCw4S3J6YiJXoFP4nYoj3f
         izS9l3vG2opYLcvP8qVG/JCooLA5ZOCLL3mvAUeYr7rfOtsRodvRuqV8QHrc0vfnpbmI
         aUpw==
X-Google-Smtp-Source: AFSGD/WAXRR32TGOAsq8ckXtNG4WI9cS6EgN+hAJoP8QpGjd2i1aJD1h4MIBx0fPKKhWRr2JmBQqnyNtZYsKApO51K0=
X-Received: by 2002:a05:660c:f94:: with SMTP id x20mr20595383itl.144.1546244667674;
 Mon, 31 Dec 2018 00:24:27 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com> <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
 <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
In-Reply-To: <ef2508c9-d069-2143-09a6-a90b9ef12568@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 09:24:16 +0100
Message-ID:
 <CACT4Y+YYwYDnqFmMwfSg6UNXnrbh46bo0jp7ijbej8nkDDmBXQ@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>, 
	David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, 
	LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231082416.OFiRcqdDYgTkO8JkiL6_Nda0anuTon6vZXWT5TvUeMo@z>

On Mon, Dec 31, 2018 at 9:17 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2018/12/31 16:49, Dmitry Vyukov wrote:
> > On Mon, Dec 31, 2018 at 8:42 AM syzbot
> > <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com> wrote:
> >>
> >> Hello,
> >>
> >> syzbot found the following crash on:
> >>
> >> HEAD commit:    ef4ab8447aa2 selftests: bpf: install script with_addr.sh
> >> git tree:       bpf-next
> >> console output: https://syzkaller.appspot.com/x/log.txt?x=14a28b6e400000
> >> kernel config:  https://syzkaller.appspot.com/x/.config?x=7e7e2279c0020d5f
> >> dashboard link: https://syzkaller.appspot.com/bug?extid=ea7d9cb314b4ab49a18a
> >> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> >>
> >> Unfortunately, I don't have any reproducer for this crash yet.
> >>
> >> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >> Reported-by: syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com
> >
> > Since this involves OOMs and looks like a one-off induced memory corruption:
> >
> > #syz dup: kernel panic: corrupted stack end in wb_workfn
> >
>
> Why?
>
> RCU stall in this case is likely to be latency caused by flooding of printk().

Just a hypothesis. OOMs lead to arbitrary memory corruptions, so can
cause stalls as well. But can be what you said too. I just thought
that cleaner dashboard is more useful than a large assorted pile of
crashes. If you think it's actionable in some way, feel free to undup.

