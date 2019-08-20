Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02365C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7C0422CF5
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:27:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="crmmiaws"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7C0422CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 313406B0007; Tue, 20 Aug 2019 05:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4676B0008; Tue, 20 Aug 2019 05:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DB426B000A; Tue, 20 Aug 2019 05:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0173.hostedemail.com [216.40.44.173])
	by kanga.kvack.org (Postfix) with ESMTP id F39DD6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:27:26 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A499E180AD806
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:27:26 +0000 (UTC)
X-FDA: 75842278092.09.men46_23cd3bab13247
X-HE-Tag: men46_23cd3bab13247
X-Filterd-Recvd-Size: 9306
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:27:25 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id i22so10766560ioh.2
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:27:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=he10M2YvCXe/YhoajP4VMxL1e0kqbJ8TW0EN7J8G9VM=;
        b=crmmiawsSYAMYvn3pYh8kfk6KA+Lq98ZChKVPdJP/1ol/RefTblGkfY19kjFmAJfxd
         bl4TFR4va6SqEmpKCuKX83GkPbQGNrTskkOyKXcy5o7s4DWjI+dHYgKbBvRSJfS00BPa
         A8YNOGxQgL9HWHaoTLGAPiYEfOSxPtTL20juh0Y8z+STU5T61LA19itQX/gmQ+LlJ325
         XOurNZ36LMeIobEZOd2rJRish4qWkxkPb6TbNHliQfELVcrNigHIqdO7TZLEt0sLP+UB
         0HEFmThbJ0OnMTFUWX/c4FWsecgYDLj/wz94BNJOzuYkOTgVbU7sj90cU/ID5mV07MXw
         2RoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=he10M2YvCXe/YhoajP4VMxL1e0kqbJ8TW0EN7J8G9VM=;
        b=JJjwrPvR5EzLzL/OhFuLakIQDDm2ydvf/SJzFfE4ajKuf/2B4TD2mjnBPduIHzqr/l
         MINDoVCN+sFrn72Sd9t/vybzjIkolVqcThep9a05o/UuaejSeMrrrEJ1ay+1KkSraxVW
         HbfB1Ij7l3GtcpKTaPM0rhdwYXTdv4WwVR0obCQfwYDwLTjZPddbbwpYbtca7s1oaajp
         sZHQjCRi2nBTpo8ZvjWSMg1l0/mfHq0Gn5gL5lxqzNwFohIUAiIjhCaMGtNuQruydQgE
         zMRX+iGRlXnOCdO56aJMQrPx00IbV/dWgvhK6gXYOWSmVCMUgp/M/wvZRrCCyY4C8ZDe
         eVgQ==
X-Gm-Message-State: APjAAAUSBkgvDnhZZtv/mhq52vSkDfYCdfL5r2PqegU+adypTA8hGpHt
	iEG9y4UY3WzREOu9tBQYaQx1VSh84O4g72j0SpQ=
X-Google-Smtp-Source: APXvYqwPIsih6Mb1FgtP0VBPWOkQW+fk0JyxfowzNtBQUBw6yb6fohUfut3OhgmHpqnJMXBlrzGDp2YgQffQng0wBuc=
X-Received: by 2002:a05:6602:224a:: with SMTP id o10mr15974386ioo.44.1566293245298;
 Tue, 20 Aug 2019 02:27:25 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com> <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz> <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
 <20190820072703.GF3111@dhcp22.suse.cz> <CALOAHbC+ByFV6tPOnkmCM9FjxP3wWnQNCWUDO6e6RaeS=Mx8_Q@mail.gmail.com>
 <20190820083412.GK3111@dhcp22.suse.cz> <CALOAHbBfvnOtEVjoD7=GcSb4TF3eHTX7wXT-M9meZaj6b9QofA@mail.gmail.com>
 <20190820091735.GM3111@dhcp22.suse.cz>
In-Reply-To: <20190820091735.GM3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 17:26:49 +0800
Message-ID: <CALOAHbB68w0miNE7FBASyMi=ou58AfsQTOkFY3fXgZi0w2aMrQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Yafang Shao <shaoyafang@didiglobal.com>, 
	Roman Gushchin <guro@fb.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Randy Dunlap <rdunlap@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 5:17 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 20-08-19 16:55:12, Yafang Shao wrote:
> > On Tue, Aug 20, 2019 at 4:34 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Tue 20-08-19 15:49:20, Yafang Shao wrote:
> > > > On Tue, Aug 20, 2019 at 3:27 PM Michal Hocko <mhocko@suse.com> wrote:
> > > > >
> > > > > On Tue 20-08-19 15:15:54, Yafang Shao wrote:
> > > > > > On Tue, Aug 20, 2019 at 2:40 PM Michal Hocko <mhocko@suse.com> wrote:
> > > > > > >
> > > > > > > On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> > > > > > > > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > > > > > > > >
> > > > > > > > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > > > > > > > In the current memory.min design, the system is going to do OOM instead
> > > > > > > > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > > > > > > > system is lack of free memory. While under this condition, the OOM
> > > > > > > > > > killer may kill the processes in the memcg protected by memory.min.
> > > > > > > > > > This behavior is very weird.
> > > > > > > > > > In order to make it more reasonable, I make some changes in the OOM
> > > > > > > > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > > > > > > > skip the processes under memcg protection at the first scan, and if it
> > > > > > > > > > can't kill any processes it will rescan all the processes.
> > > > > > > > > >
> > > > > > > > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > > > > > > > problem because this only happens under system  memory pressure and
> > > > > > > > > > the OOM killer can't find any proper victims which are not under memcg
> > > > > > > > > > protection.
> > > > > > > > >
> > > > > > > > > Hi Yafang!
> > > > > > > > >
> > > > > > > > > The idea makes sense at the first glance, but actually I'm worried
> > > > > > > > > about mixing per-memcg and per-process characteristics.
> > > > > > > > > Actually, it raises many questions:
> > > > > > > > > 1) if we do respect memory.min, why not memory.low too?
> > > > > > > >
> > > > > > > > memroy.low is different with memory.min, as the OOM killer will not be
> > > > > > > > invoked when it is reached.
> > > > > > >
> > > > > > > Responded in other email thread (please do not post two versions of the
> > > > > > > patch on the same day because it makes conversation too scattered and
> > > > > > > confusing).
> > > > > > >
> > > > > > (This is an issue about time zone :-) )
> > > > >
> > > > > Normally we wait few days until feedback on the particular patch is
> > > > > settled before a new version is posted.
> > > > >
> > > > > > > Think of min limit protection as some sort of a more inteligent mlock.
> > > > > >
> > > > > > Per my perspective, it is a less inteligent mlock, because what it
> > > > > > protected may be a garbage memory.
> > > > > > As I said before, what it protected is the memroy usage, rather than a
> > > > > > specified file memory or anon memory or somethin else.
> > > > > >
> > > > > > The advantage of it is easy to use.
> > > > > >
> > > > > > > It protects from the regular memory reclaim and it can lead to the OOM
> > > > > > > situation (be it global or memcg) but by no means it doesn't prevent
> > > > > > > from the system to kill the workload if there is a need. Those two
> > > > > > > decisions are simply orthogonal IMHO. The later is a an emergency action
> > > > > > > while the former is to help guanratee a runtime behavior of the workload.
> > > > > > >
> > > > > >
> > > > > > If it can handle OOM memory reclaim, it will be more inteligent.
> > > > >
> > > > > Can we get back to an actual usecase please?
> > > > >
> > > >
> > > > No real usecase.
> > > > What we concerned is if it can lead to more OOMs but can't protect
> > > > itself in OOM then this behavior seems a little wierd.
> > >
> > > This is a natural side effect of protecting memory from the reclaim.
> > > Read mlock kind of protection. Weird? I dunno. Unexpected, no!
> > >
> > > > Setting oom_score_adj is another choice,  but there's no memcg-level
> > > > oom_score_adj.
> > > > memory.min is memcg-level, while oom_score_adj is process-level, that
> > > > is wierd as well.
> > >
> > > OOM, is per process operation. Sure we have that group kill option but
> > > then still the selection is per-process.
> > >
> > > Without any clear usecase in sight I do not think it makes sense to
> > > pursue this further.
> > >
> >
> > As there's a memory.oom.group option to select killing all processes
> > in a memcg, why not introduce a memcg level memcg.oom.score_adj?
>
> Because the oom selection is process based as already mentioned. There
> was a long discussion about memcg based oom victim selection last year
> but no consensus has been achieved.
>
> > Then we can set different scores to different memcgs.
> > Because we always deploy lots of containers on a single host, when OOM
> > occurs it will better to prefer killing the low priority containers
> > (with higher memcg.oom.score_adj) first.
>
> How would you define low priority container with score_adj?
>

For example, Container-A is high priority and Container-B is low priority.
When OOM killer happens we prefer to kill all processes in Container-B
and prevent Container-A from being killed.
So we set memroy.oom.score_adj  with -1000 to Container-A  and +1000
to Container-B, both container with memory.oom.cgroup set.
When we set memroy.oom.score_adj  to a container, all processes
belonging to this container will be set this value to their own
oom_score_adj.
If a new process is created, its oom_score_adj will be initialized
with this memory.oom.score_adj as well.

Thanks
Yafang

