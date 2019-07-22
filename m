Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3F33C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:52:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 874BA2199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:52:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 874BA2199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20D9C8E0006; Mon, 22 Jul 2019 05:52:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BF438E0001; Mon, 22 Jul 2019 05:52:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AFEC8E0006; Mon, 22 Jul 2019 05:52:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB29A8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:52:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so23324577pgg.15
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:52:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=+9Hah1o88uTNtSe4/7uYaciyMFH0liersSRqkZ9QIvs=;
        b=eTtPSFI/+d3gVqy8ePnuZfVZyvxf/jJECfJZVuxdUbcW0feRBagL7JfWVjm6l2CXiO
         bp1+wluzpURQDn/xoC2cnf8qh1D3JBaynOi9eQROasEz6auqNYLLY5XY+ccr0GTGUDNh
         8nW6fVWUXuJwZWhDFWjfRzrkg4nyve1ve3h9lcForeX6qKvVFOQwcIzp7w2JBKpagqTJ
         RVq78Setu1t/V08+DvG+IBl2RZwRFNyIwLIoCXtcCF9N1rYGp1u9iUAGTzLRf+MOw94a
         SsIGb+nN5buX9tCAPnJGzDGe805YxCeC9Y6KBUFfA/5heYGOi9/a7fIOdUVjFLIIPOf9
         afKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAUFDdKJlAcaOhP7VtC9EHDA3LSgqVBBgbXlfzcIi88VoArz9RTt
	v8cXZdXfm9shJAC98keHaViRCm8JmvryAh6o8NWht+H5y9gBMBWe4uno4rWnzewIhC7gT94fEz4
	c854cjyaIzbQzol0QhgkqT26FkQDS/+xdy3S3w9laGayY3MXLzNSVU4t1HgEr9EzFxA==
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr78077614pje.14.1563789167492;
        Mon, 22 Jul 2019 02:52:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXNTvd7LMtkUfw/3llzDILK6+VLAOAgYgeaozl71FdyxtW4i2GzTC7PQulIiU51277JuaY
X-Received: by 2002:a17:90a:2430:: with SMTP id h45mr78077550pje.14.1563789166658;
        Mon, 22 Jul 2019 02:52:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563789166; cv=none;
        d=google.com; s=arc-20160816;
        b=rX/GVVp0Xt6qdp8ze0VofYGItbGJJb7CHKIKeUzW3UwwBUGJPecNRebsnzjNUxE0d3
         h9OZPHX2D/78jwfrfBLtFuEGH/rdR7RMdP1g6Wfa1z+9OigEiO0a9G1h0m6vnamyrXYT
         UQO8v33bu4ivy+IXVtXe0Rv1M+A9JyMZMUvYJbwZhgYNSIxcFd0sm6oHtOQcNuoxtXF9
         VitkgHDnuHZlaiN77OUfFeZtLmsNzow3xDLrhmkqV4+JgH1BI1PWEHZF8uBEzOlDmJed
         7UlDdbQdMWbVRvt30zoR+XULBYg8Ceuo/LYLar/SA7Afw6XLAaLsI+idk3WmEECZsq32
         CFFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=+9Hah1o88uTNtSe4/7uYaciyMFH0liersSRqkZ9QIvs=;
        b=tO2cJi4OekTYLNiqlNnJzKLWux9pvcR/2z/bQ8W8GqztTLhIiL7RnXSexqxyjdJsMm
         2StrJnCWU1e2W5sq+rHUJa5k/igZZRu3ChVXilp9F6WTCefWRNYT//tM/Jf0xi8dtLBZ
         +NIdOjIRaJhCqxbJLqLhDiBi27FJN0IFGfORh5GhKfHQ8HbnEhq7CxdhHGGM63kHoQ/4
         ne5NulsBy32OLRpCY3oRfUOBx7K3ELu7ecVCC8ttlv3ebIyNn8j7g2p/MGxC6VMweyZ3
         fYZVrA1+QltZ1GQZlKa3hIH5SJC5SG6f4w4weA1+I0xjTwIUh59J093AFQHb7A+zCxRG
         lUSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id f96si11026599plb.339.2019.07.22.02.52.46
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 02:52:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 4416e42ecd35467192de92f81e192f6f-20190722
X-UUID: 4416e42ecd35467192de92f81e192f6f-20190722
Received: from mtkmrs01.mediatek.inc [(172.21.131.159)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1042474360; Mon, 22 Jul 2019 17:52:43 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs07n1.mediatek.inc (172.21.101.16) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Mon, 22 Jul 2019 17:52:42 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Mon, 22 Jul 2019 17:52:42 +0800
Message-ID: <1563789162.31223.3.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko
	<glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, Linux ARM
	<linux-arm-kernel@lists.infradead.org>, <linux-mediatek@lists.infradead.org>,
	wsd_upstream <wsd_upstream@mediatek.com>
Date: Mon, 22 Jul 2019 17:52:42 +0800
In-Reply-To: <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
	 <1560479520.15814.34.camel@mtksdccf07>
	 <1560744017.15814.49.camel@mtksdccf07>
	 <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
	 <1560774735.15814.54.camel@mtksdccf07>
	 <1561974995.18866.1.camel@mtksdccf07>
	 <CACT4Y+aMXTBE0uVkeZz+MuPx3X1nESSBncgkScWvAkciAxP1RA@mail.gmail.com>
	 <ebc99ee1-716b-0b18-66ab-4e93de02ce50@virtuozzo.com>
	 <1562640832.9077.32.camel@mtksdccf07>
	 <d9fd1d5b-9516-b9b9-0670-a1885e79f278@virtuozzo.com>
	 <1562839579.5846.12.camel@mtksdccf07>
	 <37897fb7-88c1-859a-dfcc-0a5e89a642e0@virtuozzo.com>
	 <1563160001.4793.4.camel@mtksdccf07>
	 <9ab1871a-2605-ab34-3fd3-4b44a0e17ab7@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-18 at 19:11 +0300, Andrey Ryabinin wrote:
> 
> On 7/15/19 6:06 AM, Walter Wu wrote:
> > On Fri, 2019-07-12 at 13:52 +0300, Andrey Ryabinin wrote:
> >>
> >> On 7/11/19 1:06 PM, Walter Wu wrote:
> >>> On Wed, 2019-07-10 at 21:24 +0300, Andrey Ryabinin wrote:
> >>>>
> >>>> On 7/9/19 5:53 AM, Walter Wu wrote:
> >>>>> On Mon, 2019-07-08 at 19:33 +0300, Andrey Ryabinin wrote:
> >>>>>>
> >>>>>> On 7/5/19 4:34 PM, Dmitry Vyukov wrote:
> >>>>>>> On Mon, Jul 1, 2019 at 11:56 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
> >>>>
> >>>>>>>
> >>>>>>> Sorry for delays. I am overwhelm by some urgent work. I afraid to
> >>>>>>> promise any dates because the next week I am on a conference, then
> >>>>>>> again a backlog and an intern starting...
> >>>>>>>
> >>>>>>> Andrey, do you still have concerns re this patch? This change allows
> >>>>>>> to print the free stack.
> >>>>>>
> >>>>>> I 'm not sure that quarantine is a best way to do that. Quarantine is made to delay freeing, but we don't that here.
> >>>>>> If we want to remember more free stacks wouldn't be easier simply to remember more stacks in object itself?
> >>>>>> Same for previously used tags for better use-after-free identification.
> >>>>>>
> >>>>>
> >>>>> Hi Andrey,
> >>>>>
> >>>>> We ever tried to use object itself to determine use-after-free
> >>>>> identification, but tag-based KASAN immediately released the pointer
> >>>>> after call kfree(), the original object will be used by another
> >>>>> pointer, if we use object itself to determine use-after-free issue, then
> >>>>> it has many false negative cases. so we create a lite quarantine(ring
> >>>>> buffers) to record recent free stacks in order to avoid those false
> >>>>> negative situations.
> >>>>
> >>>> I'm telling that *more* than one free stack and also tags per object can be stored.
> >>>> If object reused we would still have information about n-last usages of the object.
> >>>> It seems like much easier and more efficient solution than patch you proposing.
> >>>>
> >>> To make the object reused, we must ensure that no other pointers uses it
> >>> after kfree() release the pointer.
> >>> Scenario:
> >>> 1). The object reused information is valid when no another pointer uses
> >>> it.
> >>> 2). The object reused information is invalid when another pointer uses
> >>> it.
> >>> Do you mean that the object reused is scenario 1) ?
> >>> If yes, maybe we can change the calling quarantine_put() location. It
> >>> will be fully use that quarantine, but at scenario 2) it looks like to
> >>> need this patch.
> >>> If no, maybe i miss your meaning, would you tell me how to use invalid
> >>> object information? or?
> >>>
> >>
> >>
> >> KASAN keeps information about object with the object, right after payload in the kasan_alloc_meta struct.
> >> This information is always valid as long as slab page allocated. Currently it keeps only one last free stacktrace.
> >> It could be extended to record more free stacktraces and also record previously used tags which will allow you
> >> to identify use-after-free and extract right free stacktrace.
> > 
> > Thanks for your explanation.
> > 
> > For extend slub object, if one record is 9B (sizeof(u8)+ sizeof(struct
> > kasan_track)) and add five records into slub object, every slub object
> > may add 45B usage after the system runs longer. 
> > Slub object number is easy more than 1,000,000(maybe it may be more
> > bigger), then the extending object memory usage should be 45MB, and
> > unfortunately it is no limit. The memory usage is more bigger than our
> > patch.
> 
> No, it's not necessarily more.
> And there are other aspects to consider such as performance, how simple reliable the code is.
> 
> > 
> > We hope tag-based KASAN advantage is smaller memory usage. If it’s
> > possible, we should spend less memory in order to identify
> > use-after-free. Would you accept our patch after fine tune it?
> 
> Sure, if you manage to fix issues and demonstrate that performance penalty of your
> patch is close to zero.


I remember that there are already the lists which you concern. Maybe we
can try to solve those problems one by one.

1. deadlock issue? cause by kmalloc() after kfree()?
2. decrease allocation fail, to modify GFP_NOWAIT flag to GFP_KERNEL?
3. check whether slim 48 bytes (sizeof (qlist_object) +
sizeof(kasan_alloc_meta)) and additional unique stacktrace in
stackdepot?
4. duplicate struct 'kasan_track' information in two different places

Would you have any other concern? or?




