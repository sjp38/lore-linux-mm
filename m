Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23A3DC43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 19:34:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 667F320873
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 19:34:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bfTXSxz5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 667F320873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D28398E0062; Sat, 29 Dec 2018 14:34:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD8858E005B; Sat, 29 Dec 2018 14:34:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9ED48E0062; Sat, 29 Dec 2018 14:34:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 873338E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 14:34:42 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id d72so17607132ywe.9
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 11:34:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Rm4V5mvOJxeB4IxCyXzJR7q46ixdXejdpIGZhtAm/DA=;
        b=P8LNrejYUJmPQVZbsb0D7rQWbXjWUAh7flgiV+DaGzsO5Scdxh3dI0zdUQho1tkHHc
         h3aAlBu9XqDF6vjszdh5qHGVnKYrTAJj+n6AnSE8Bj8MuygGNcmKm9sUlvmov2akskFB
         7ybqddzlJmj6cREdgvlEtSYm0FEC84QQMtS90ptl+GTuvawnBLvSmEBAvxsnm9XAA/g3
         MprQoecO+8Ww1yh7AKAnMZiVP6HxY2XytcvmeyFeNg9GcX8qYsPSc29AWQ1bvDpjsvLN
         Va/Uu4N4l4qrHLVokjPpzFdNfqs7rxCT7VvLhljAlR6e+TpULXw5HOwcx9lN1JinSH/x
         MZhw==
X-Gm-Message-State: AA+aEWY6kPbNsk3IIx4ScGq1lDxO4YdGsbDpBNV2dbS+1LiLBb56gURd
	mtzA5tyMPaOd/kxsICdOEXgX/YXUiF0ziYfhBwj+hzNrcomxh2N4kN4xSF6jzRHILwekWsTnvXa
	2qMx9HIwSQrlwGJsKH5+/TkvOn8HUk8NWG1QdPwFbYl/3BMN4uSb4gM4K8V3RWi7RQwxOdMaDW6
	DyyTYmQ1nC6DA9lyLmqiYs9FCWL+iCCEaXHCWgCJi6FOdgW5zmKWEdO3BT5jWNIwD8CQReyvIRU
	Z5YN5+pRpYia8x70GA5cr5LOQeueqW7JLPdaTBonAgiE5UNWlVUML8nqkREYeJYjlVfRYhyR/if
	8jU4rU49ibwjx3dWNjsTX1pMYAXLeI8Co+/ySU422nqDBYV5+pqlvEAohyrVc71hMyL4JRXmSIh
	D
X-Received: by 2002:a25:7c83:: with SMTP id x125-v6mr32054152ybc.152.1546112082102;
        Sat, 29 Dec 2018 11:34:42 -0800 (PST)
X-Received: by 2002:a25:7c83:: with SMTP id x125-v6mr32054136ybc.152.1546112081417;
        Sat, 29 Dec 2018 11:34:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546112081; cv=none;
        d=google.com; s=arc-20160816;
        b=BlcIflAtNN4sfzTvjZRmFI/Elb0rFGGTvePWtjC25UdrupN0+aC7e8DfCpjVkaRTDR
         qz4vgrO5VpsTmez27ltwNz3+X70UGgFa6dKSqqrVq8t8PET7YbmhrjbY7nBxszwOg9wq
         30hh+ESQQ45B5L8TMZbKGZEdfLPao//prkzkwROMi3XFOUBHYObldmDQA/wP5VkwoUPI
         mW8cF4T8u4ipRB91lI08jQkHgbjDz0cwTYK0/xKc+SkY8pbYhBLnAHIl05GBRvsbIjpd
         Kt+fz8Xv+UEDhHAH/DsF0k40ICQR89OSbgqWDVpce8ECM1B4JfAfiRAtzOKfKZZuvrXi
         83nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Rm4V5mvOJxeB4IxCyXzJR7q46ixdXejdpIGZhtAm/DA=;
        b=WwnzKP6OTvctWo5G/koYHs4JfNLfu7MO06fPBRVAJqalVnFcN7VFJiaMgP3BcX9PiY
         2BtHJFfAceXqzNrnYKldEOmmdcaydUpbivqRuGPua3cHcbPpIYjcN9Kh7e/xnaCNADZm
         2Im9Zo9Ic/Zfjktou5OGoVkFoZLV9rm5yV/K76+zLJ6988FnxMo+cGDNzh/EPKRR7+eO
         qmO0ciNG8ANAbZi3pZpfgcuK3v0UR4pJs/1jvJ+2mljFITmgBut6maqEjx74K1LFMUsY
         lSzYGqG8RuClYlblzdLyWCA1Efv2LbuMqLkyRVMJjTXU1/d4UOricbpLWTF3HC9eFAz3
         eQKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bfTXSxz5;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66-v6sor20426052ybg.113.2018.12.29.11.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 11:34:41 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bfTXSxz5;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rm4V5mvOJxeB4IxCyXzJR7q46ixdXejdpIGZhtAm/DA=;
        b=bfTXSxz5Zddw/9ltMyrfT7C5wJ9uM+MADH0R72Ii/MvtJvURondOXyRSWBmm4skOl4
         leG+tp5URxkh68+/zRBGOdfMRYN6lmMOwTlh5yWll6F1ySNDB7qOQTfCGoeNdsvUScQP
         r23wHoc8zIpmaE8eqbO1AtXnw0waCNnPCEYzpx9dndS0SxZezVgYC+izxyUjUHAz6isr
         rXi4UIMFCieB56GJJswjVSAwDCLICjJ51iU5ykcXMXk5IyJ3EpLj0tde7S3feAye/zKV
         5q2ABxhmpL7IRIC6s0gmGKnOhyk+fr3v6YSEimhQioHHMDqOPxuzxs7fmtW+a9keJIKP
         wWJQ==
X-Google-Smtp-Source: ALg8bN5dXmkJ/AmEgrcBLDrOSPMZRpne6/ywolwLjXUlixj8WqVeudQ9ZuX0qxUUbAeMy+YBwwKS9vBHci8vyP5hxGo=
X-Received: by 2002:a5b:f01:: with SMTP id x1mr27072891ybr.464.1546112080563;
 Sat, 29 Dec 2018 11:34:40 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
In-Reply-To: <20181229100615.GB16738@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 11:34:29 -0800
Message-ID:
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, 
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, 
	syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229193429.Veu3C69RXoJpAlWXcVmmdU2qwlaXQf54fPSfEjibPH8@z>

On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > whole system from a restricted memcg, a potential DoS.
> > >
> > > What is the lifetime of these objects? Are they bound to any process?
> >
> > No, they are not.
> > They are free'd only when userspace requests it or the netns is
> > destroyed.
>
> Then this is problematic, because the oom killer is not able to
> guarantee the hard limit and so the excessive memory consumption cannot
> be really contained. As a result the memcg will be basically useless
> until somebody tears down the charged objects by other means. The memcg
> oom killer will surely kill all the existing tasks in the cgroup and
> this could somehow reduce the problem. Maybe this is sufficient for
> some usecases but that should be properly analyzed and described in the
> changelog.
>

Can you explain why you think the memcg hard limit will not be
enforced? From what I understand, the memcg oom-killer will kill the
allocating processes as you have mentioned. We do force charging for
very limited conditions but here the memcg oom-killer will take care
of

Anyways, the kernel is already charging the memory for
[ip,ip6,arp]_tables and this patch adds the charging for ebtables.
Without this patch, as Kirill has described and shown by syzbot, a low
priority memcg can force system OOM.

Shakeel

