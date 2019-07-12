Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3912AC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:13:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBD482084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 06:13:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jrq93zYp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBD482084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70B848E0119; Fri, 12 Jul 2019 02:13:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BBC08E00DB; Fri, 12 Jul 2019 02:13:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1508E0119; Fri, 12 Jul 2019 02:13:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3DB8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:13:08 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id q26so9448358ioi.10
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:13:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DUo8ryhLl3Mi3YkE+U/flzBUawPzDZ2QG8xmBbLJ4MU=;
        b=tabZFd65IVazb+NardbPiIiKIgZYPt2PfAHUCErOrwMxZkdiGeHmkJYoKAyY08nRuF
         fcAZlEdods+Z9WOpEuXF/zvgCW/yrkObCufOcxUTYC8tzz6yXGXBR5yyVJKRMhKVKTCP
         w5/BFwlFOnf83WBl5TZTNbd6DrTegaG1+9x/MTwgAWKI/MDCnrXjsZaMMZkxgtD0quft
         l+JEOoDtZI552CguCthjQG3fbWzZnZTuDDTOYDB3MdSK35eMqQGW0bN4PASZm6RyFO/C
         q3dN2/jXs30fHTsz3Sr6Vzk//giQcxPeHlHibQSKijKz3MuKHqAWDVGJBdgRI4sTxQwn
         lM6A==
X-Gm-Message-State: APjAAAXHNY0oC4QRW8oGlWmHhJDQy8Jn5fMMU7E9Z1S71m2HCfAyTpOj
	ErSKbd+/aDfuQJHZAlNFj0lw76m5dYbkfTzpJXQ+/uJbcPYo06EaGUOrHWenPUBQpt4KyZtNVru
	7Y7eRQXbFZvKtmFEsddPmsLIbK0YjxU5yN83xEAq+5KQOGhNWkfxSwEqUXqHWoG+y9g==
X-Received: by 2002:a05:6602:2183:: with SMTP id b3mr5859092iob.249.1562911987991;
        Thu, 11 Jul 2019 23:13:07 -0700 (PDT)
X-Received: by 2002:a05:6602:2183:: with SMTP id b3mr5859047iob.249.1562911987283;
        Thu, 11 Jul 2019 23:13:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562911987; cv=none;
        d=google.com; s=arc-20160816;
        b=UI3T4xtfh6a8AkoplrS2olvEyWT1lPbV3O2ZTftSuKHlDSloFsIFQNHOBqDrx/JIF9
         OWldSR7tJ35hMj3OEL3Jzf2A+/db6wkpXE/CxLhS3rs8Lcx456HESFiFhjQzA3V4TL5D
         SAW/v3ZXd0HyMlPjLrN4gz0l6DAbbviLlBE9CQpBmKAeNgMrj/EubmefIaaMJpVP30SH
         4AHFHqu7BhqEa3qkPax7lcg7K6ZGTtMmvZjsk9/u5i1GEoEglXT7GMURJnIgtZdi9xW2
         D5TPN9vtyWooKcnIlpGkwbDc2LU6dHnkdmpCJgiSy1GVIzafzLaCseF+NCvgJoZy3Iyt
         lC3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DUo8ryhLl3Mi3YkE+U/flzBUawPzDZ2QG8xmBbLJ4MU=;
        b=akNgbR3R0lTKp6iWP+Kzq+KvZn2RQ5RAocgkbxDcpLTYH9RbNaLPktDezORxAKYQRv
         eq/2RZZopoLmf6h7qDeIhXQR+VxegbqlgFj2hTF4usn1OTXlrW0g3iAwJlSYuyId8OBg
         ru5OpBIh0C15EOt7M8UPRu7ND9i1NgfGshLPhXYMy0+YhWKO+mPvZYYuraMXhC8EvVN3
         a8wDRX+qC/WYbqzmZ2v9qxEj1bK+gaPzXvsuYtu0yhHVtSi4po9AqeKBxl+5NhAOHC1g
         vzZlZpWPomJyR11aKBAWQBSNi56z5cq8VKJ5iO2S8jmeOfV5NUpl/mWL4STIgvT9GQvR
         y9cA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jrq93zYp;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a66sor6369784iog.113.2019.07.11.23.13.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Jul 2019 23:13:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jrq93zYp;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DUo8ryhLl3Mi3YkE+U/flzBUawPzDZ2QG8xmBbLJ4MU=;
        b=jrq93zYpiEk9ANW+72FxB7iLsrwS1mkR0joqMvADSbYubv7SdY4mMuRxLY4p4hVFnR
         Z/FNQJ+edvjtDv2wqNgRsvo6/iylq7yrBWlJ+20HTK6VprK+j4npoGmF+wtMsLSmm9wZ
         Xexl7pCzfYQuYFBRnjx844looRc/n88yVcUHcHuBRanGtOGVIVX6TxoENfxYEyLEQY/9
         bcuG5odBvPyKShwDrcTlPCn66YUpxZku7Cn4sl6oj7uz+5Jkdr/Pmyf5VXiDVJ/XTa3+
         AqUMRn1NrtiO86ENHJ4pW1b0NTxr4QfvqcQLnn7G2HaD9qMSZm+8xEz4puT9gFswefVg
         qkBA==
X-Google-Smtp-Source: APXvYqwHortoC3HcpqjMzFxLjE2mhHsAMvl1heLdRcJVNJMCV1ipKxQJ8Vx2ZX0om5xKDNx3gvyG4x9JhFIvgUkWLfE=
X-Received: by 2002:a02:1a86:: with SMTP id 128mr9449831jai.95.1562911986958;
 Thu, 11 Jul 2019 23:13:06 -0700 (PDT)
MIME-Version: 1.0
References: <1562851979-10610-1-git-send-email-laoar.shao@gmail.com>
 <20190711164215.7e8fdcf635ac29f2d2572438@linux-foundation.org>
 <CALOAHbDC+JWaXfMwG97PEsEB4f0vRkx7JsDRN8m47x1DMVuuFg@mail.gmail.com> <20190712052938.GI29483@dhcp22.suse.cz>
In-Reply-To: <20190712052938.GI29483@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Jul 2019 14:12:30 +0800
Message-ID: <CALOAHbCt7b-AMDtK6FmAfYnYSMiB=UhKbBVKt7CzFFazzrKeVQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/memcontrol: keep local VM counters in sync with the
 hierarchical ones
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 1:29 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 12-07-19 09:47:14, Yafang Shao wrote:
> > On Fri, Jul 12, 2019 at 7:42 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > >
> > > On Thu, 11 Jul 2019 09:32:59 -0400 Yafang Shao <laoar.shao@gmail.com> wrote:
> > >
> > > > After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> > > > the local VM counters is not in sync with the hierarchical ones.
> > > >
> > > > Bellow is one example in a leaf memcg on my server (with 8 CPUs),
> > > >       inactive_file 3567570944
> > > >       total_inactive_file 3568029696
> > > > We can find that the deviation is very great, that is because the 'val' in
> > > > __mod_memcg_state() is in pages while the effective value in
> > > > memcg_stat_show() is in bytes.
> > > > So the maximum of this deviation between local VM stats and total VM
> > > > stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> > > > great value.
> > > >
> > > > We should keep the local VM stats in sync with the total stats.
> > > > In order to keep this behavior the same across counters, this patch updates
> > > > __mod_lruvec_state() and __count_memcg_events() as well.
> > >
> > > hm.
> > >
> > > So the local counters are presently more accurate than the hierarchical
> > > ones because the hierarchical counters use batching.  And the proposal
> > > is to make the local counters less accurate so that the inaccuracies
> > > will match.
> > >
> > > It is a bit counter intuitive to hear than worsened accuracy is a good
> > > thing!  We're told that the difference may be "unacceptably great" but
> > > we aren't told why.  Some additional information to support this
> > > surprising assertion would be useful, please.  What are the use-cases
> > > which are harmed by this difference and how are they harmed?
> > >
> >
> > Hi Andrew,
> >
> > Both local counter and the hierachical one are exposed to user.
> > In a leaf memcg, the local counter should be equal with the hierarchical one,
> > if they are different, the user may wondering what's wrong in this memcg.
> > IOW, the difference makes these counters not reliable, if they are not
> > reliable we can't use them to help us anylze issues.
>
> But those numbers are in flight anyway. We do not stop updating them
> while they are read so there is no guarantee they will be consistent
> anyway, right?

Right.
They can't be guaranted to be consistent.
When we read them, may only the local counters are updated and the
hierarchical ones are not updated yet.
But the current deviation is so great that can't be ignored.
So the question is similar like  what about increasing the
MEMCG_CHARGE_BATCH from 32 to 32 * 4096 ?

Thanks
Yafang

