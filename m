Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADBD0C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 05:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D0B82073D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 05:37:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ftzFVjyf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D0B82073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1C196B0008; Fri,  2 Aug 2019 01:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CD416B000A; Fri,  2 Aug 2019 01:37:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BB146B000C; Fri,  2 Aug 2019 01:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56A946B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 01:37:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q11so40919896pll.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 22:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ihRIEHRjtJIPus/danpDF2O/WfsfhF+xvDGQLaVGba0=;
        b=s7GD5VXE+mktIj3vDSUhyBnW3s7dSmOelTj4JB/BdlAjAdOtyHUvfmXPurpLSZ3DQF
         WGTJEUg5YUtPVGLEDCt4rKXS8D8nwf2r8QDfmPSqgMV4ZiVUK92xVWQgNXtlY9fVGX7k
         +jRf/qf1rpf7yis+EbF5HfyGw//6+fnum5lD9YwzUBndlbmxj4/1GASEJ16XjQK4V2G3
         zI6ISwDa/jwyX8mtZpL9Y45KzigvPpgxFmwUe82gdRVGDMszcnul3mjnVQqhyaYptKo4
         kIgtcjllxhWFAN83hGcuctpdd5TmZ6ZLSQO6dz0xDS2YEaCNl2zjvFIgA5s6EqbBcF+z
         pCyw==
X-Gm-Message-State: APjAAAWjDkVyJRzUj2BvthsCOW3YDFLDy+HExMZAe8YQs7hfhBgSMJ5g
	Y5tz8Tp6U5kUHBN0W7f36LXuXji9VO0oLrCIoxx3DT457Ne1uSL28n1uATPK+/chetIJ2ue5cds
	tkWUTxfiGfBzYeAHu+Zb/qo232wjFstzxRpYdRmWT+Mz99DFjDlNjwyPU5qAkuvTh6w==
X-Received: by 2002:a63:2264:: with SMTP id t36mr115304245pgm.87.1564724246771;
        Thu, 01 Aug 2019 22:37:26 -0700 (PDT)
X-Received: by 2002:a63:2264:: with SMTP id t36mr115304202pgm.87.1564724245828;
        Thu, 01 Aug 2019 22:37:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564724245; cv=none;
        d=google.com; s=arc-20160816;
        b=Ul4m8ESkDOUmHCoWYfE3t5rzZC8AzW4ff42j7t81/dbWt1GhH/RmX4iKASLZInnM8J
         RzFapm/EEFkUp63Ajb6EiE65CD0jZX+m2j8zqoE8BuGnegqhTA3im7NP47IXLbd6n3v9
         xasX5c63+F9bCQAJFspFBCCMXBw73QtzSk1PraP/tlIyuiqXm50ijpmRHV/P8sDP7dGD
         639oYntTlr5cnHibqsxCTm6VN/6KlwX3tP/61J0I+fevw/2DS6d7vhJBaVOFvERITW0j
         ndFjlvez/j3JpCi1kEgQzUEiFh7LgLHZnL6l5EAGCDuHJ5AMFSdZD7EXsNVs2ETOd3L2
         9VZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ihRIEHRjtJIPus/danpDF2O/WfsfhF+xvDGQLaVGba0=;
        b=LnVUyoxrQmSI4B3P1nuw5YmbnXCiHx4Zy6k/utJ6M6kj+X7lBUcQCX94RNQPX4OzZm
         p8cJU+p8qAx3ToSWImDFN6umKs/rYDA5GbvtcdJf+eHAqpGqv/hCwx5jbJy+VotlAX0z
         BuvB7MZT8JMT/eqgtPktfC8FNdmapprRb3hRIHSr3+qfxh+cRCyGSn/Zp8+LIZxw2uTU
         pSeSAjMRoNY5bhCYN3Ju5wethQoZNdHq63YTR7XXl7IdFJMXTMo/Q7t5T9PjPgenqT1s
         RRGjFul/O/v9Lu8DmYrnKEvrwKteHsyAGxVnYZkz8aIxAG4KaTQ1+TXCcVu/oeDqaXCE
         /GQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ftzFVjyf;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor88523364plb.21.2019.08.01.22.37.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 22:37:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ftzFVjyf;
       spf=pass (google.com: domain of sergey.senozhatsky.work@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sergey.senozhatsky.work@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ihRIEHRjtJIPus/danpDF2O/WfsfhF+xvDGQLaVGba0=;
        b=ftzFVjyfXoKLkBYNUMy31X98rL/NnJ8hllXWpl0KRZE/jG55BdBSqB5J1eDuE9kY7a
         aOrDSt03+MjcLtacH3layAaidKQ6bFw2OUKmk1j6Ol9G426SpZEcIf/M1fZRfSsuAJYj
         C6+SzwOAVWFe0xcQC/KGNlvgWQMGGBooqyrnAWQom/dNI0UjuYp7RayvRxOegnWThP25
         Tey1oildsxoH7wSomoGATwjH1OmclS1/j9TMY7I6PZ9Fe70UuJMWMHkIR5Z1qfdJ+JvX
         asuve8Y7Sd9y66IvBmlGl2LuEZN88zQPY/rDQC+SP4UvLmMQWmpALsqq4rtj5qPrJU3d
         2Wfw==
X-Google-Smtp-Source: APXvYqyxSYMw4QN2SRQ515CrxjGKV3nanM01epjwWH4RWeHALCxAI0t+x/3BqYGx0VGsG1ZUoXSy1Q==
X-Received: by 2002:a17:902:1004:: with SMTP id b4mr131792482pla.325.1564724245276;
        Thu, 01 Aug 2019 22:37:25 -0700 (PDT)
Received: from localhost ([175.223.19.29])
        by smtp.gmail.com with ESMTPSA id q19sm77991081pfc.62.2019.08.01.22.37.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 22:37:24 -0700 (PDT)
Date: Fri, 2 Aug 2019 14:37:20 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org,
	Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Intel-gfx] [linux-next] mm/i915: i915_gemfs_init() NULL
 dereference
Message-ID: <20190802053720.GA3838@jagdpanzerIV>
References: <20190721142930.GA480@tigerII.localdomain>
 <20190731164829.GA399@tigerII.localdomain>
 <156468064507.12570.1311173864105235053@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156468064507.12570.1311173864105235053@skylake-alporthouse-com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/01/19 18:30), Chris Wilson wrote:
> Quoting Sergey Senozhatsky (2019-07-31 17:48:29)
> > @@ -36,19 +38,35 @@ int i915_gemfs_init(struct drm_i915_private *i915)
[..]
> > +               if (!fc->ops->parse_monolithic)
> > +                       goto err;
> > +
> > +               err = fc->ops->parse_monolithic(fc, options);
> > +               if (err)
> > +                       goto err;
> > +
> > +               if (!fc->ops->reconfigure)
> 
> It would be odd for fs_context_for_reconfigure() to allow creation of a
> context if that context couldn't perform a reconfigre, nevertheless that
> seems to be the case.

Well, I kept those checks just because fs/ code does the same.

E.g. fs/super.c

	reconfigure_super()
	{
		if (fc->ops->reconfigure)
			fc->ops->reconfigure(fc)
	}

	do_emergency_remount_callback()
	{
		fc = fs_context_for_reconfigure();
		reconfigure_super(fc);
	}

> > +                       goto err;
> > +
> > +               err = fc->ops->reconfigure(fc);
> > +               if (err)
> > +                       goto err;
> 
> Only thing that stands out is that we should put_fs_context() here as
> well.

Oh... Indeed, somehow I forgot to put_fs_context().

> I guess it's better than poking at the SB_INFO directly ourselves.
> I think though we shouldn't bail if we can't change the thp setting, and
> just accept whatever with a warning.

OK.

> Looks like the API is already available in dinq, so we can apply this
> ahead of the next merge window.

OK, will cook a formal patch then. Thanks!

	-ss

