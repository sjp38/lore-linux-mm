Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C80A5C433FF
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 02:06:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8865C205C9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 02:06:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8865C205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E9BB6B0008; Sat,  3 Aug 2019 22:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09AB66B000A; Sat,  3 Aug 2019 22:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECB8F6B000C; Sat,  3 Aug 2019 22:06:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8E326B0008
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 22:06:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d2so44043281pla.18
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 19:06:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=BHiWHDAjrEDvZmSxZAxExbj9R5n9Bl2iDFzMLzKr6mI=;
        b=XKM51pw/1VFCgyqHuAVvp3HElAFt9lPwDSxMKt3mgoI6z0h+M70NRnIkL7ginxHzBp
         CVrQhVC9WT3IJcOAO+mdSOx8Mpylw83TBXFbzTOS/+nGw+An1wAAr+JebKQngmapgxXd
         8lScvaPnumR93aRIcpLj0v9lEp0970R1tI1DHB9GGr5zmBSQPLhiJGpZTUvn56p8PLtJ
         ngVaeX9WzD/BfhEBiYBjUmVNJwwyKKh4TufDHrh2hqOIaQLFiiUJWNfUmod6ZxubS2QF
         u5PNf7UkoCo5H6e5os6V0m8I0TEOZ87AdCKYT6LFXD8TvRv8WGaKB15vaeCixK8AN83n
         gIoA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWfpg3XG5VKiRx5sbrHmbs030YFYkaHT0rV0ShS0UHpNNzgBcWG
	q3n53tS304U81JO+IFNrXIEME8eJJlYKHnuUgdTG7ooTNiP0zh6RYZ+Y2C+2nxlN+rPJuUTelOJ
	j4k9prDelaJ7BtfGLwO7G9kzBBNtNEJgtL9fjFqtzkdjyzsSQtkXn93XZQ48lFqg=
X-Received: by 2002:a62:79c2:: with SMTP id u185mr67974389pfc.237.1564884402432;
        Sat, 03 Aug 2019 19:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOZuPtaBGhkjBzxNpYv9EloBsH3Go2PrHGaPYPiFx1pCsuaCncDRx6ET5b9U58kxxRxf+8
X-Received: by 2002:a62:79c2:: with SMTP id u185mr67974352pfc.237.1564884401693;
        Sat, 03 Aug 2019 19:06:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564884401; cv=none;
        d=google.com; s=arc-20160816;
        b=fDDyGMQb90mcTiHjJuD5RRMEbFqAElNwR+IPGOzHPcMHMqkqhBRPSb2knNcROpG3x0
         Ff9Py9z435wq9iNO2s1kSB0Th+M6rNCxll2HWQ0AOeEJ2W1Igt3HFngVyc7zZtHzzBZo
         ainwO4Qe8cuf0MkhaKYrN+7gRtKt4WRYysOiZkg/yu+qJt4lRn1VRAYP9Y+fNwOyJyS4
         YGteWK+mg3SwX29gREFmEb2fm2ckKCMlCKakplXJRAyR02zD4EbUAEVx0ArcmiNpqHU0
         fW3eJjRKASUZiGjnhH2AuwdmedQr4x5y3PmEHNcoAkISV3QCIfsBux636YmBbbwa/s0b
         a92Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=BHiWHDAjrEDvZmSxZAxExbj9R5n9Bl2iDFzMLzKr6mI=;
        b=mPZw+f8tgy2QAiObiC56wCuF3GB/P35B7wITBfIfnl5/Lr5a1Ct6dkDcxtSMCYPPWf
         6QK9Dh9plOU1PPkhenbSRhEzBTLfo+wIDoRZPpxrin2x3yT9GF+iaRoSREPBADRMbBGM
         f5H901QzGT5EqJSfHp1qLqFo/tFTLcT0rcexL+TxJZ/y5VZ/HZ08NQcHUkM/PIt6fX6w
         5hN1mCkNP4FDLKCwESzHWKSRzPrlVNgRPrlgQG5ZQgTkz3HhRKL2qQfRlk+p4ENATRlO
         X1Yx3PCrSjx1jkrt/Z45O7z1k8z/BaL8+ggTBJT99hWbqpT0PFkhe5BErK/50jKTAWko
         M8hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id k11si41122139pfi.3.2019.08.03.19.06.41
        for <linux-mm@kvack.org>;
        Sat, 03 Aug 2019 19:06:41 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 005EC3642AF;
	Sun,  4 Aug 2019 12:06:39 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hu5ts-0005Eg-P1; Sun, 04 Aug 2019 12:05:32 +1000
Date: Sun, 4 Aug 2019 12:05:32 +1000
From: Dave Chinner <david@fromorbit.com>
To: Nikolay Borisov <nborisov@suse.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 03/24] mm: factor shrinker work calculations
Message-ID: <20190804020532.GT7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-4-david@fromorbit.com>
 <e07bf57b-a9cb-cb7b-b2be-3ec1b355a184@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e07bf57b-a9cb-cb7b-b2be-3ec1b355a184@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=IkcTkHD0fZMA:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=YrQ3agGYtJL690KwsyUA:9
	a=moKeNvOLZCFDdMlA:21 a=LCgEZU1dFy5Qw733:21 a=QEXdDO2ut3YA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 06:08:37PM +0300, Nikolay Borisov wrote:
> 
> 
> On 1.08.19 г. 5:17 ч., Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Start to clean up the shrinker code by factoring out the calculation
> > that determines how much work to do. This separates the calculation
> > from clamping and other adjustments that are done before the
> > shrinker work is run.
> > 
> > Also convert the calculation for the amount of work to be done to
> > use 64 bit logic so we don't have to keep jumping through hoops to
> > keep calculations within 32 bits on 32 bit systems.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  mm/vmscan.c | 74 ++++++++++++++++++++++++++++++++++-------------------
> >  1 file changed, 47 insertions(+), 27 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ae3035fe94bc..b7472953b0e6 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -464,13 +464,45 @@ EXPORT_SYMBOL(unregister_shrinker);
> >  
> >  #define SHRINK_BATCH 128
> >  
> > +/*
> > + * Calculate the number of new objects to scan this time around. Return
> > + * the work to be done. If there are freeable objects, return that number in
> > + * @freeable_objects.
> > + */
> > +static int64_t shrink_scan_count(struct shrink_control *shrinkctl,
> > +			    struct shrinker *shrinker, int priority,
> > +			    int64_t *freeable_objects)
> 
> nit: make the return parm definition also uin64_t, also we have u64 types.

SHRINK_EMPTY is actually a negative number (-2), and it gets whacked
back into a signed long value in the caller. So returning a signed
integer is actually correct.

> > +{
> > +	uint64_t delta;
> > +	uint64_t freeable;
> > +
> > +	freeable = shrinker->count_objects(shrinker, shrinkctl);
> > +	if (freeable == 0 || freeable == SHRINK_EMPTY)
> > +		return freeable;
> > +
> > +	if (shrinker->seeks) {
> > +		delta = freeable >> (priority - 2);
> > +		do_div(delta, shrinker->seeks);
> 
> a comment about the reasoning behind this calculation would be nice.

I'm just moving code here.

The reason for this calculation requires an awfully long description
that isn't actually appropriate here or in this patch set.

If there should be any comment describing how shrinker work biasing
should be configured, it needs to be in include/linux/shrinker.h
around the definition of DEFAULT_SEEKS and shrinker->seeks as this
code requires shrinker->seeks to be configured appropriately by the
code that registers the shrinker.

> >  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  				    struct shrinker *shrinker, int priority)
> >  {
> >  	unsigned long freed = 0;
> > -	unsigned long long delta;
> >  	long total_scan;
> > -	long freeable;
> > +	int64_t freeable_objects = 0;
> > +	int64_t scan_count;
> 
> why int and not uint64 ? We can never have negative object count, right?

SHRINK_STOP, SHRINK_EMPTY are negative numbers, and the higher level
interface uses longs, not unsigned longs. So we have to treat
numbers greater than LONG_MAX as invalid for object/scan counts.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

