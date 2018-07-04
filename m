Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 46C036B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 04:46:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z11-v6so1919068edq.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 01:46:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t22-v6si3037802eda.7.2018.07.04.01.46.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 01:46:53 -0700 (PDT)
Subject: Re: [REGRESSION] "Locked" and "Pss" in /proc/*/smaps are the same
References: <69eb77f7-c8cc-fdee-b44f-ad7e522b8467@gmail.com>
 <ebf6c7fb-fec3-6a26-544f-710ed193c154@suse.cz>
 <CAKOZuev9K0EMpqBoie4H7XduB63KayORxO=JEZvS9rv_4PVsqQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f31b26d0-b94e-b545-8776-a4494179149d@suse.cz>
Date: Wed, 4 Jul 2018 10:46:52 +0200
MIME-Version: 1.0
In-Reply-To: <CAKOZuev9K0EMpqBoie4H7XduB63KayORxO=JEZvS9rv_4PVsqQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: Thomas Lindroth <thomas.lindroth@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 07/03/2018 06:20 PM, Daniel Colascione wrote:
> On Tue, Jul 3, 2018 at 12:36 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> +CC
>>
>> On 07/01/2018 08:31 PM, Thomas Lindroth wrote:
>>> While looking around in /proc on my v4.14.52 system I noticed that
>>> all processes got a lot of "Locked" memory in /proc/*/smaps. A lot
>>> more memory than a regular user can usually lock with mlock().
>>>
>>> commit 493b0e9d945fa9dfe96be93ae41b4ca4b6fdb317 (v4.14-rc1) seems
>>> to have changed the behavior of "Locked".
> 
> Thanks for fixing that. I submitted a patch [1] for this bug and some
> others a while ago, but the patch didn't make it into the tree because
> or wasn't split up correctly or something, and I had to do other work.

Hmm I see. I pondered about the patch and wondered if the scenarios it
fixes are really possible for smaps_rollup. Did you observe them in
practice? Namely:
- when seq_file starts and stops multiple times on a single open file
description
- when it issues multiple show calls for the same iterator value

I don't think it can happen when all positions but the last one just
return SEQ_SKIP.

Anyway I think the seq_file iterator API usage for smaps_rollup is
unnecessary. Semantically the file shows only one "element" and that's
the set of rollup values for all vmas. Letting seq_file do the iteration
over vmas brings only complications?

> [1] https://marc.info/?l=linux-mm&m=151927723128134&w=2
> 
