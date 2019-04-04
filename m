Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D993C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:40:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A697A206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:40:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="LilBzVZs";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="B7wwLCg6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A697A206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18BFB6B0007; Thu,  4 Apr 2019 00:40:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13C156B0008; Thu,  4 Apr 2019 00:40:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004736B000D; Thu,  4 Apr 2019 00:40:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D76D06B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 00:40:29 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 54so1208596qtn.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:40:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bUj9cbWyiESD0Bndu7rVRnpZO5RGiJ6UN/btqvOMQzs=;
        b=fPdQ1WV2KLFMyneJ4JYbJ8ad379HHENFX+xOkQSIBHEnXgzQ4ZWTCAESre8LyJJeuE
         lYbICrGagEDn1zgsYEr8UA9REsv34EKP5m2sYMH2kpB1Q2g/Nd3gTIm7rSDWuY1DZegW
         fO9+tKGdVi2h7QbnzbKmRuPZ86h0izYZAYSZe8jctn30jaaRrE5Nd7JmKfDB86L1BdyF
         1h+bxqI9of9O0dlKq7u4l105Prz07P6Z9frM+JmKTyDJkf5TpI30teZTe/aV6tVXCQnp
         PQGmdIY4WLz2Lk0Vc4LXNyfK4kE6QQUdlsPztUJuuC4IN6RwW3/PfY9GC4wfBKljOjOG
         Ii8A==
X-Gm-Message-State: APjAAAU3PzN/sYSpKzWSlUrvt5u9oBCnjhxWQ8NDeVx8cLm6OIjzP5vY
	NAhcrRPBOEUPbRO7uf0jRH6/DUsg7rdlQ1stfit+e/btcMaTfR2hzf8bpPP8Tez9jxLSzYBtchn
	yQoEo04Bly1tc+9dXoUFFYLz/5uF1VxLCatIH3/YszlK5kB1OZKUv9mzzvIDfXF47bg==
X-Received: by 2002:a0c:afae:: with SMTP id s43mr2911438qvc.145.1554352829571;
        Wed, 03 Apr 2019 21:40:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjm4ifEsncvySnNntzjFO3UdHgeCqiI+h0DDUwlHvV4LGTcUW1dJ4X2hz8RRTpl2kRzF0V
X-Received: by 2002:a0c:afae:: with SMTP id s43mr2911405qvc.145.1554352828738;
        Wed, 03 Apr 2019 21:40:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554352828; cv=none;
        d=google.com; s=arc-20160816;
        b=SBqdsgAD6Ymy+7Z4Tu5tx5NJjwRtkuYvp/rkkGOnCJVHszEfekBTFZP7sZsoWpTNVA
         F1eU+xICV7dGaUkpqpgZT9nPJZE2Ss9ZBMBDPiztGnECjavqpz/c4xVlfA0MfHZZqpFa
         c5javXI6GrVTaUAfaYrrjHRTEiiwCTjlafIeCltBm4TD+BAsD08Z8r5avo9NTZ+nyXNT
         tCstpQakn4nfe84s90PS4Ea2qKsvENKBxMbB2dsBH6BNqHYKxiuH7n8sXYuG7NeC6w4p
         vMgvYB4ElUY2tK7Fy37SbsmBWmVnK24erE5pQ2mqJLgu4KQuOzSiDtNA6B0e5An+IlR5
         jKrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=bUj9cbWyiESD0Bndu7rVRnpZO5RGiJ6UN/btqvOMQzs=;
        b=KxAJUKMiHdnSRAtzW9cC64lMIXfqpymv0+S4WWkJgU7DULlyuLdWw5z4Kb9ruuQ6wi
         21mLkjP6/qCMw8tz+ubPyQx+yWh6wsUw4VccmW2rSXpPWeSa1vAcl6bhzjG+SSXBnk3B
         cpGdB7Vq2PvgIoRy77U27Vq5u8eVw3BTO4m7jwbZXNPlOmj/hBBiBZwLCnbx68o6y+nn
         ldPYP4c94vYB4zTvxPnrhGHbfVW1Xw0RFL5tkbmiEgM9KeMBz22993LZ49rSP+AU+FUR
         VLyh5Lrl00U2oP/ank6wsE0Mo1C1hBOnisJdtMIc8kVCzcM+O9YCsM1I+PkAJZqluIVY
         8VKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=LilBzVZs;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=B7wwLCg6;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id z7si4134984qkf.253.2019.04.03.21.40.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 21:40:28 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=LilBzVZs;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=B7wwLCg6;
       spf=neutral (google.com: 66.111.4.29 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3945E22001;
	Thu,  4 Apr 2019 00:40:28 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute5.internal (MEProxy); Thu, 04 Apr 2019 00:40:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=bUj9cbWyiESD0Bndu7rVRnpZO5R
	GiJ6UN/btqvOMQzs=; b=LilBzVZsyjXpmUeuJmZQ7Y+uZrJnTTp3BYXzPrZZ5lY
	T2M9C00bxrnlWdXN8RULcQnLug7v/Z8WgHE5T3e9+tsTA8s2nL/vKgfD1//NwQ6N
	fRoBpYpfJg0V37fdH72ptQh8/gXbXeryPKCleEKF2G7Ab7s1g3ZvpxXGxld+g4Gk
	4x4WPrnIILYaiyZAzuHrB09pi+8ommonzl1QtPztwVkTvRVaZWj6Qz9a93EWk1zd
	UK9cUAke4Urf02P4AoIMD+M1sFABWGyJqPRSUe/RfHgVuTOsVLfZ8Pt/N/cddG64
	AmwZVL+UH7tzZNfmTEXfFa9RGuX9KfMB5o4Nq+Fom3w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=bUj9cb
	WyiESD0Bndu7rVRnpZO5RGiJ6UN/btqvOMQzs=; b=B7wwLCg61dSqSMNqMB2jX/
	NZgBgRnxkTKygwqNS2Ty+qvnu7AKFu1l4GyCzY0jj5qdVeYMFIWyWET17/SEbrzj
	IU7vv/sJM+f9CWnzGn3+vOVkOV9uv8Q4g6jojiAUgcsyLMRRjcJDr+iiz7EXUBZO
	7LktPymVBPnmlVUEZUxlyMnqmyRvhxCXOssUd2f8E8G+hcU87x4gezRGWOIQV0A9
	wTTair7UEojVB76FWDf/6KxeG2lSKCiKqBvgyrpE4Uen7rBj66Dnk1uJA4xcTpAW
	m2xPcj39R8sulCRcgmdPCh4HYeHAr74OkMFMzBA7/iV+9TRzG5vm6u58g8fwxVoA
	==
X-ME-Sender: <xms:u4qlXGTFrTZb_DWvALZx7_euM30AD_HrwUXvuhhgj9t3dicy95FhhQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdekfeculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecufghrlhcuvffnffculd
    ejmdenucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhep
    fdfvohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecuff
    homhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepuddvgedrudegledruddugedrkeei
    necurfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsth
    gvrhfuihiivgeptd
X-ME-Proxy: <xmx:u4qlXGfYZuxFbCPsWQQx6bcZBokcUeyGR3CXXH9woUnpfo_PzTgsTQ>
    <xmx:u4qlXH0w9YC9VYnG42RROq5pmJfxKbHD8VSQvoneEOcn_k9v0Ra7pg>
    <xmx:u4qlXCs_zoe62dctCp6DDOWxL3ja28G5IKYzpncaFfa-gsk8kXxbpg>
    <xmx:vIqlXPca26sTVtn2yzYtYifaq6OtxueTr3W6epUZNMna33Cfk0tgnA>
Received: from localhost (124-149-114-86.dyn.iinet.net.au [124.149.114.86])
	by mail.messagingengine.com (Postfix) with ESMTPA id DD01510310;
	Thu,  4 Apr 2019 00:40:26 -0400 (EDT)
Date: Thu, 4 Apr 2019 15:39:56 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: kernel test robot <lkp@intel.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>, LKP <lkp@01.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 15c8410c67 ("mm/slob.c: respect list_head abstraction layer"):
 WARNING: CPU: 0 PID: 1 at lib/list_debug.c:28 __list_add_valid
Message-ID: <20190404043956.GA19471@eros.localdomain>
References: <5ca413c6.9TM84kwWw8lLhnmK%lkp@intel.com>
 <20190403045417.GA19313@eros.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403045417.GA19313@eros.localdomain>
X-Mailer: Mutt 1.11.4 (2019-03-13)
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 03:54:17PM +1100, Tobin C. Harding wrote:
> On Wed, Apr 03, 2019 at 10:00:38AM +0800, kernel test robot wrote:
> > Greetings,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > 
> > commit 15c8410c67adefd26ea0df1f1b86e1836051784b
> > Author:     Tobin C. Harding <tobin@kernel.org>
> > AuthorDate: Fri Mar 29 10:01:23 2019 +1100
> > Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> > CommitDate: Sat Mar 30 16:09:41 2019 +1100
> > 
> >     mm/slob.c: respect list_head abstraction layer
> >     
> >     Currently we reach inside the list_head.  This is a violation of the layer
> >     of abstraction provided by the list_head.  It makes the code fragile.
> >     More importantly it makes the code wicked hard to understand.
> >     
> >     The code logic is based on the page in which an allocation was made, we
> >     want to modify the slob_list we are working on to have this page at the
> >     front.  We already have a function to check if an entry is at the front of
> >     the list.  Recently a function was added to list.h to do the list
> >     rotation.  We can use these two functions to reduce line count, reduce
> >     code fragility, and reduce cognitive load required to read the code.
> >     
> >     Use list_head functions to interact with lists thereby maintaining the
> >     abstraction provided by the list_head structure.
> >     
> >     Link: http://lkml.kernel.org/r/20190318000234.22049-3-tobin@kernel.org
> >     Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> >     Cc: Christoph Lameter <cl@linux.com>
> >     Cc: David Rientjes <rientjes@google.com>
> >     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >     Cc: Pekka Enberg <penberg@kernel.org>
> >     Cc: Roman Gushchin <guro@fb.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >     Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > 
> > 2e1f88301e  include/linux/list.h: add list_rotate_to_front()
> > 15c8410c67  mm/slob.c: respect list_head abstraction layer
> > 05d08e2995  Add linux-next specific files for 20190402
> > +-------------------------------------------------------+------------+------------+---------------+
> > |                                                       | 2e1f88301e | 15c8410c67 | next-20190402 |
> > +-------------------------------------------------------+------------+------------+---------------+
> > | boot_successes                                        | 1009       | 198        | 299           |
> > | boot_failures                                         | 0          | 2          | 44            |
> > | WARNING:at_lib/list_debug.c:#__list_add_valid         | 0          | 2          | 44            |
> > | RIP:__list_add_valid                                  | 0          | 2          | 44            |
> > | WARNING:at_lib/list_debug.c:#__list_del_entry_valid   | 0          | 2          | 25            |
> > | RIP:__list_del_entry_valid                            | 0          | 2          | 25            |
> > | WARNING:possible_circular_locking_dependency_detected | 0          | 2          | 44            |
> > | RIP:_raw_spin_unlock_irqrestore                       | 0          | 2          | 2             |
> > | BUG:kernel_hang_in_test_stage                         | 0          | 0          | 6             |
> > | BUG:unable_to_handle_kernel                           | 0          | 0          | 1             |
> > | Oops:#[##]                                            | 0          | 0          | 1             |
> > | RIP:slob_page_alloc                                   | 0          | 0          | 1             |
> > | Kernel_panic-not_syncing:Fatal_exception              | 0          | 0          | 1             |
> > | RIP:delay_tsc                                         | 0          | 0          | 2             |
> > +-------------------------------------------------------+------------+------------+---------------+
> > 
> > [    2.618737] db_root: cannot open: /etc/target
> > [    2.620114] mtdoops: mtd device (mtddev=name/number) must be supplied
> > [    2.620967] slram: not enough parameters.
> > [    2.621614] ------------[ cut here ]------------
> > [    2.622254] list_add corruption. prev->next should be next (ffffffffaeeb71b0), but was ffffcee1406d3f70. (prev=ffffcee140422508).
> 
> Is this perhaps a false positive because we hackishly move the list_head
> 'head' and insert it back into the list.  Perhaps this is confusing the
> validation functions?

This has got me stumped.  I cannot create a test case where manipulating
a list with list_rotate_to_front() causes the list validation functions
to emit an error.  Also I cannot come up with a way on paper that it can
happen either.

I don't really know how to go forwards from here.  I'll sleep on it and
see if something comes to me, any ideas to look into please?

thanks,
Tobin.

