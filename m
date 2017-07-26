Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08F3C6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:54:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g28so32918827wrg.3
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:54:46 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id 71si508695wmy.167.2017.07.26.12.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:54:45 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id c184so87750677wmd.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:54:45 -0700 (PDT)
MIME-Version: 1.0
Reply-To: dmitriyz@waymo.com
In-Reply-To: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
References: <20170726165022.10326-1-dmitriyz@waymo.com> <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
From: Dima Zavin <dmitriyz@waymo.com>
Date: Wed, 26 Jul 2017 12:54:44 -0700
Message-ID: <CAPz4a6DWohW+vjnvQLh2DNrVrn9CUQ3HNuZ+2fKZJkRc+hXq3w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/slub: fix a deadlock due to incomplete patching of cpusets_enabled()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>

On Wed, Jul 26, 2017 at 10:02 AM, Christopher Lameter <cl@linux.com> wrote:
> On Wed, 26 Jul 2017, Dima Zavin wrote:
>
>> The fix is to cache the value that's returned by cpusets_enabled() at the
>> top of the loop, and only operate on the seqlock (both begin and retry) if
>> it was true.
>
> I think the proper fix would be to ensure that the calls to
> read_mems_allowed_{begin,retry} cannot cause the deadlock. Otherwise you
> have to fix this in multiple places.
>
> Maybe read_mems_allowed_* can do some form of synchronization or *_retry
> can implictly rely on the results of cpusets_enabled() by *_begin?
>

(res-ending because gmail hates me, sorry).

Thanks for the quick reply!

I can turn the cookie into a uint64, put the sequence into the low
order 32 bits and put the enabled state into bit 33 (or 63 :) ). Then
retry will not query cpusets_enabled() and will just look at the
enabled bit. This means that *_retry will always have a conditional
jump (i.e. lose the whole static_branch optimization) but maybe that's
ok since that's pretty rare and the *_begin() will still benefit from
it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
