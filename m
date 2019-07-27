Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21BA9C433FF
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 16:44:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB40B2083B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 16:44:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NJtUCU9P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB40B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22EF58E0003; Sat, 27 Jul 2019 12:44:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B8668E0002; Sat, 27 Jul 2019 12:44:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 080A38E0003; Sat, 27 Jul 2019 12:44:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEEE28E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 12:44:49 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id b4so31016333otf.15
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 09:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hxbfUz9YUQxUJQuuEVPnw0FpsyVuxmGe9mWc6z1mpmc=;
        b=NLvZ4i2NPrh1Tz4iLU6+4Uwv9V5y5t+qBX10Bxm2tv+mlLAwBGwp+XMAdy54sGlrnH
         +UjJdnZ5LYT69LdOGlyXWVMmQIrFBCnf7ejOM+1sMBYzCZe5GOCIzaVcD0LFtMdNKmU7
         8tuBhYz250OgDcPGZAUWunHh1hqLmYc+semtzTcIWXbkolgnuBgNrCmS29ps2fOM3m1w
         5BEg2fwG2fUG2CQ64vhHKLhJQL/Bkn5fcPF8sBh0Y4biVj4vSKpzIbhErS5PfdGTOIzG
         bRLEZjpMOPmrf8FYdvtHypf0vB3ze8VFllS710PjG1nafXc2y8tfroALCdOr47i6aXQ6
         3qcg==
X-Gm-Message-State: APjAAAWqmKfYrBC7AexBLGY9+wLK+INe/lMhBSoD9xTwKP1LewTYWjR8
	f4eQSK2dplsQpqjJCFN5Ogf3G4xmtMS75sEiAtfke9wseHGAD71nf1ALFeQWHIBUOd2WDpqgmPZ
	VzKHu+KjIqv9yZc83v+3AnrPwkRW5j61grZGpzu1pHb4ZDHRKr8wU5iyQAlKiUmoLVA==
X-Received: by 2002:a54:4f97:: with SMTP id g23mr49372032oiy.97.1564245889275;
        Sat, 27 Jul 2019 09:44:49 -0700 (PDT)
X-Received: by 2002:a54:4f97:: with SMTP id g23mr49371998oiy.97.1564245887962;
        Sat, 27 Jul 2019 09:44:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564245887; cv=none;
        d=google.com; s=arc-20160816;
        b=DZAb73ipK4BAAEoJCSHcwjrjw6kD5LQMRYrx6xQJA72qSxK6qZePxYl7rueoI+Ojnq
         XI2M5MufEctnQUpfyd2APzgaiPA7QnC7FDO7kOc8d9e8dwS76kEd6YERl/AjpTuqLQ6H
         wNXjnSQYEPVHOLoGa2tgLFhRJPBIejz2CBhZ+3vl31NIfPgi/feXWOsyySzWZ5ReUAFp
         RAqk9im9Yz35cPygOmmRbdVZwdBEuOLpUzCThAXVmxqgYGBPLczYT6u7CMm0HlErCBpx
         pUY0tzhZXGYSO67HV0njMzRnvNl+v55B7yK3ejaQRHAYUInvnzhIL40bokvrVybDCVC0
         ZXEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hxbfUz9YUQxUJQuuEVPnw0FpsyVuxmGe9mWc6z1mpmc=;
        b=FQdkCo0giJ1W4BCSq9AgFIOUqUCCd8QJO34WT04tdym/I9f+CGqbY954xPhoQgBgzQ
         z9FIADb4G2D1myvgVLmMzOAjufDSG4SfwDMjLGEuNIo6wg7kAbb0oUkdUMNNx8AMcDXm
         1mqpqEb9vACMC5x6pQSUBr1nw7DU4CawANSm02rDSuwP2pD5CyEiyt/8kwZVHD5ZPtPC
         tAsq2SxPpa7y/cY5VNlk6pKIgyOjWPHWoK9ZjTg1zSbqZ6jDujW6bUp1wFxLqS4fmR63
         Afq852f3hjtrt7vPr09q5WB5Z/jSNvQPS2pNrDuI6HyMp3MqFPTYkZkS8qfgonq5i7uB
         qp9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NJtUCU9P;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42sor28506450otf.49.2019.07.27.09.44.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jul 2019 09:44:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NJtUCU9P;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hxbfUz9YUQxUJQuuEVPnw0FpsyVuxmGe9mWc6z1mpmc=;
        b=NJtUCU9Pg+JecRH5sfC1kTAirRTjO2Syik66f2PE37N4iAxJo4hxAv7EmcmgU1RZIp
         o2qn92hrF7ouBq6NieF6WGvIPE4kFItJ4P3ucLWwDI8rPaAvZTDJMR9qGRkLLphEGIZb
         Ql/HH7aKJQRy3P3hTFbfxVi8mL03iecaVsiID/SedZuict3//YexTVOWWuD4T6wGSvPY
         7zC0W2Vfyixt41DC0e1bhwNVl3iCKw0OMnCxHuLKINQIc7EDSK1zLDveiKogliU+1hJH
         Yuwy9HsIEad86LJxhzE9/+b7O2kyEqiMFhE7FUec4YrsvDsVLmOsAK8VA+kT+ShVaQHN
         NEXg==
X-Google-Smtp-Source: APXvYqyBQgzDnte0g4uHiBAg3nkxHWBNTGbNj3O+BMlRYhSlAlDr3MA3IMQ2aTyB9x2cAnxkaop1dPaVhNEgkny0YLE=
X-Received: by 2002:a9d:67cf:: with SMTP id c15mr8289343otn.326.1564245887547;
 Sat, 27 Jul 2019 09:44:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <20190726072637.GC2739@techsingularity.net>
In-Reply-To: <20190726072637.GC2739@techsingularity.net>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Sun, 28 Jul 2019 00:44:36 +0800
Message-ID: <CAD7_sbHwjN3RY+ofgWvhQFJdxhCC4=gsMs194=wOH3tKV-qSUg@mail.gmail.com>
Subject: Re: [PATCH 00/10] make "order" unsigned int
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, vbabka@suse.cz, 
	Qian Cai <cai@lca.pw>, aryabinin@virtuozzo.com, osalvador@suse.de, 
	rostedt@goodmis.org, mingo@redhat.com, pavel.tatashin@microsoft.com, 
	rppt@linux.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:26 PM Mel Gorman <mgorman@techsingularity.net> wrote:
>

Thank you for your comments.

> On Fri, Jul 26, 2019 at 02:42:43AM +0800, Pengfei Li wrote:
> > Objective
> > ----
> > The motivation for this series of patches is use unsigned int for
> > "order" in compaction.c, just like in other memory subsystems.
> >
>
> Why? The series is relatively subtle in parts, particularly patch 5.

Before I sent this series of patches, I took a close look at the
git log for compact.c.

Here is a short history, trouble you to look patiently.

1) At first, "order" is _unsigned int_

The commit 56de7263fcf3 ("mm: compaction: direct compact when a
high-order allocation fails") introduced the "order" in
compact_control and its type is unsigned int.

Besides, you specify that order == -1 is the flag that triggers
compaction via proc.

2) Next, because order equals -1 is special, it causes an error.

The commit 7be62de99adc ("vmscan: kswapd carefully call compaction")
determines if "order" is less than 0.

This condition is always true because the type of "order" is
_unsigned int_.

-               compact_zone(zone, &cc);
+               if (cc->order < 0 || !compaction_deferred(zone))

3) Finally, in order to fix the above error, the type of the order
is modified to _int_

It is done by commit: aad6ec3777bf ("mm: compaction: make
compact_control order signed").

The reason I mention this is because I want to express that the
type of "order" is originally _unsigned int_. And "order" is
modified to _int_ because of the special value of -1.

If the special value of "order" is not a negative number (for
example, -1), but a number greater than MAX_ORDER - 1 (for example,
MAX_ORDER), then the "order" may still be _unsigned int_ now.

> There have been places where by it was important for order to be able to
> go negative due to loop exit conditions.

I think that even if "cc->order" is _unsigned int_, it can be done
with a local temporary variable easily.

Like this,

function(...)
{
    for(int tmp_order = cc->order; tmp_order >= 0; tmp_order--) {
        ...
    }
}

> If there was a gain from this
> or it was a cleanup in the context of another major body of work, I
> could understand the justification but that does not appear to be the
> case here.
>

My final conclusion:

Why "order" is _int_ instead of unsigned int?
  => Because order == -1 is used as the flag.
    => So what about making "order" greater than MAX_ORDER - 1?
      => The "order" can be _unsigned int_ just like in most places.

(Can we only pick -1 as this special value?)

This series of patches makes sense because,

1) It guarantees that "order" remains the same type.

No one likes to see this

__alloc_pages_slowpath(unsigned int order, ...)
 => should_compact_retry(int order, ...)            /* The type changed */
  => compaction_zonelist_suitable(int order, ...)
   => __compaction_suitable(int order, ...)
    => zone_watermark_ok(unsigned int order, ...)   /* The type
changed again! */

2) It eliminates the evil "order == -1".

If "order" is specified as any positive number greater than
MAX_ORDER - 1 in commit 56de7263fcf3, perhaps no int order will
appear in compact.c until now.

> --
> Mel Gorman

Thank you again for your comments, and sincerely thank you for
your patience in reading such a long email.

> SUSE Labs

