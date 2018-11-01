Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0746B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 10:30:33 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n5-v6so14571123pgv.6
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 07:30:33 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i8-v6si31469165pgj.283.2018.11.01.07.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 07:30:31 -0700 (PDT)
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181031081945.207709-1-vovoy@chromium.org>
 <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
 <CAEHM+4q7V3d+EiHR6+TKoJC=6Ga0eCLWik0oJgDRQCpWps=wMA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <80347465-38fd-54d3-facf-bcd6bf38228a@intel.com>
Date: Thu, 1 Nov 2018 07:30:30 -0700
MIME-Version: 1.0
In-Reply-To: <CAEHM+4q7V3d+EiHR6+TKoJC=6Ga0eCLWik0oJgDRQCpWps=wMA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vovo Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/1/18 5:06 AM, Vovo Yang wrote:
>> mlock() and ramfs usage are pretty easy to track down.  /proc/$pid/smaps
>> or /proc/meminfo can show us mlock() and good ol' 'df' and friends can
>> show us ramfs the extent of pinned memory.
>>
>> With these, if we see "Unevictable" in meminfo bump up, we at least have
>> a starting point to find the cause.
>>
>> Do we have an equivalent for i915?
> AFAIK, there is no way to get i915 unevictable page count, some
> modification to i915 debugfs is required.

Is something like this feasible to add to this patch set before it gets
merged?  For now, it's probably easy to tell if i915 is at fault because
if the unevictable memory isn't from mlock or ramfs, it must be i915.

But, if we leave it as-is, it'll just defer the issue to the fourth user
of the unevictable list, who will have to come back and add some
debugging for this.

Seems prudent to just do it now.
