Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D59D0C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:01:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97AE7206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 21:01:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uStsrgDN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97AE7206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 313A86B0003; Thu,  1 Aug 2019 17:01:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4426B0008; Thu,  1 Aug 2019 17:01:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DA966B000A; Thu,  1 Aug 2019 17:01:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3E4C6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 17:01:10 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t196so62592762qke.0
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 14:01:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=At1IZWoUrcjzoFBo6+pPU11vzH0qsCf+6x4oe65bvIg=;
        b=YuYYcAtf7kMjy+1w+SvytRvxskr8bQ5FTj/SY5HgcLjf9ZlawfU6Ni6ekdK3XA+Cam
         Z0VyIDnCN+a/nENFRQCKGNUxPkwu4HOs4XEygAvA2Py6YVmcIKnIe+Vg4EuhLfK0bnOi
         B2cW8kmqKzcTkS32V0Ix23y5rum3Fl8TAPEosaiOY0DmB5RTJsU8t/M3Wo+AHqd5gIgW
         1z5dN+4CGrTFjKxPErT29FAf/yMsb+gnT+Udtlh/OTwsb3lc+F/zZySdhgruAYTZEjnq
         eNdKJ8FqkZJdmjY3IH//DwWIbCXT2R5A5ogcS8ERteW82yUO74VcjtNeRUHZNvtZY2lD
         Ng2w==
X-Gm-Message-State: APjAAAUl4EhD8f6n0D/Hw9l9Jdt3/KwSoy2uc7o/FFbHg/SYZ+wcaUSF
	uZNU6BxhUKoNrd2ZwVmmkBRWQn6yZeiZ7MfUBYht3kdpO/5CNr7qIPJja8HYZjDOdvr9tuGyc7z
	6tziDZH4y6yiTUuXLFqP+X6vWchqIprUvdYcug2+v4VJlm/N4X0vtxzJSIGp5i7avlA==
X-Received: by 2002:a0c:db93:: with SMTP id m19mr91715388qvk.96.1564693270759;
        Thu, 01 Aug 2019 14:01:10 -0700 (PDT)
X-Received: by 2002:a0c:db93:: with SMTP id m19mr91715011qvk.96.1564693266151;
        Thu, 01 Aug 2019 14:01:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564693266; cv=none;
        d=google.com; s=arc-20160816;
        b=0LD1M8k+lfDQGM9x+4QYnUyku9Iq+4+tzONbVJnRdI/8M2gbTpsBAbUCIJfQDmPWSR
         BPFpvt5LbEplm0kjQJzTpF+G0O3MiQ6cH0OabU3+7fz59d76Si/0aMR4Wb/5ygcDwyip
         IH6396HwUCumtC1a4ub73mEFimT4F8+T7xXtUWqUPQk9ReZOn9Omg6e3NJmBDfyVjcdE
         4AjoHkdvodnYQd3TQRzpNJtClC3Vvt+PoFEzvonSwLCTbPaYmPQh2cP6D6QJ5U/cPt1j
         cKwYtV0HGGT+9rVZ2n7fCgFfXoj2JHDdINW7C4669/W/YeUAojtC+xkg5vX9ewIC1E29
         28dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=At1IZWoUrcjzoFBo6+pPU11vzH0qsCf+6x4oe65bvIg=;
        b=uCjYqCfsuQfUhmj4MhbCmX/KckuKvkb5RF9HwAGR9Yt0tbda//EkIvUTymjhEyfFZC
         6EIrxRRHFKK+7HVFvHn7So/0XNjN58n2W50AhvCSIIJ5ChCHaNS5w+feqlUPa3CPx6bv
         YNIyH4ifaNq7Y/5iAE6XQgnecDIc47F8IZABsR7jO6nRFV3WhphtezZ9HNHgfS+/F67h
         aQE7gYA0CA7+L0SUhp+3Dja74XUec3J4ocB0d3yJrvY4PEYus5T0Y63qM6W8T73xZOdB
         Wek/RuuPif64vCvcciieGirEfXD5E9L5czuCUiQ2Zs0JsZwpx1i8Tl/o7208c8ynv/mH
         GfAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uStsrgDN;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m50sor94996411qtf.44.2019.08.01.14.01.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 14:01:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uStsrgDN;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=At1IZWoUrcjzoFBo6+pPU11vzH0qsCf+6x4oe65bvIg=;
        b=uStsrgDNX3A3NRNPBmsfEftPfszUtOF9JqpdBbxcAseb2Cp1nI6QJ4BVFu5H/rIZ8v
         rbzDuskZ1BvP68LPeL0zq8ZjO/V5OD40IDX9ZX4jz0s3j6TiVwylL6qxzXVjoGygHzq9
         NmtbEwgot5NskVLQwlSiyq0FuDuFiySrUDL+272PF2AvoPl6l1u6DBsQ8OlznD+uFli4
         4OHGxfrZaIQUIYT2PfKT1uatEHmlFCJQpUua+5gcsJt6g8M0BXkEO+QPsDrI1K3I16L/
         aTcKdJV9yk1ZrIuhzinYwy3k623M0pkPpqHfW8HbwvMAGxoiGTdSRxSA1LN1rg9S3KDA
         /nmQ==
X-Google-Smtp-Source: APXvYqx0U8hwjSfrfGv5PCv/q1e/Y06r9RaTrs0m4NDxmC1Gv/TW5z0Gt4fs9Rq2NhPg85DUKv7yZUyFkk37Ay5yXaQ=
X-Received: by 2002:ac8:2646:: with SMTP id v6mr91139076qtv.205.1564693265783;
 Thu, 01 Aug 2019 14:01:05 -0700 (PDT)
MIME-Version: 1.0
References: <156431697805.3170.6377599347542228221.stgit@buzz>
 <20190729091738.GF9330@dhcp22.suse.cz> <3d6fc779-2081-ba4b-22cf-be701d617bb4@yandex-team.ru>
 <20190729103307.GG9330@dhcp22.suse.cz> <CAHbLzkrdj-O2uXwM8ujm90OcgjyR4nAiEbFtRGe7SOoY_fs=BA@mail.gmail.com>
 <20190729184850.GH9330@dhcp22.suse.cz>
In-Reply-To: <20190729184850.GH9330@dhcp22.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 1 Aug 2019 14:00:51 -0700
Message-ID: <CAHbLzkp9xFV2sE0TdKfWNRVcAwaYNKwDugRiBBoEKx6A_Hr3Jw@mail.gmail.com>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
To: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 11:48 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-07-19 10:28:43, Yang Shi wrote:
> [...]
> > I don't worry too much about scale since the scale issue is not unique
> > to background reclaim, direct reclaim may run into the same problem.
>
> Just to clarify. By scaling problem I mean 1:1 kswapd thread to memcg.
> You can have thousands of memcgs and I do not think we really do want
> to create one kswapd for each. Once we have a kswapd thread pool then we
> get into a tricky land where a determinism/fairness would be non trivial
> to achieve. Direct reclaim, on the other hand is bound by the workload
> itself.

Yes, I agree thread pool would introduce more latency than dedicated
kswapd thread. But, it looks not that bad in our test. When memory
allocation is fast, even though dedicated kswapd thread can't catch
up. So, such background reclaim is best effort, not guaranteed.

I don't quite get what you mean about fairness. Do you mean they may
spend excessive cpu time then cause other processes starvation? I
think this could be mitigated by properly organizing and setting
groups. But, I agree this is tricky.

Typically, the processes are placed into different cgroups according
to their importance and priority. For example, in our cluster, system
processes would go to system group, then latency sensitive jobs and
batch jobs (they are usually second class citizens) go to different
groups. The memcg kswapd would be enabled for latency sensitive groups
only. The memcg kswapd threads would have the same priority with
global kswapd.

> --
> Michal Hocko
> SUSE Labs

