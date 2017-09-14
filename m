Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AD2D6B0260
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:10:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l196so2713482lfl.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 07:10:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x4sor489435ljd.52.2017.09.14.07.10.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 07:10:49 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [RFC PATCH 0/1] ksm allow dedup all process memory
Date: Thu, 14 Sep 2017 17:10:39 +0300
Message-Id: <20170914141040.9497-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timofey Titovets <nefelim4ag@gmail.com>

Hi, about 3 years ago i firstly write to linux-mm,
when i acking about UKSM and make some ugly patches (like that [1]).

It's difficult to find conversation (for me at least, i only find
my patches).
So IIRC:
 - I trying add support KSM to all process memory
   for that i patch several memory places to call hooks like madvise.
   MM folks not like that and at now i'm not only agree, i can fix that another way.

First i try look at hugepagesd, but hugepages have a much different usecase.
As example it's bad idea add ksm hook to page_fault.

So:
 I use kernel task list in ksm_scan_thread and add logic to allow ksm
 import VMA from tasks.
 That behaviour controlled by new attribute: mode
 I try mimic hugepages attribute, so mode have two states:
  - normal [old default behaviour]
  - always [new] - allow ksm to get tasks vma and try working on that.

To reduce CPU load & tasklist locking time, ksm try import one VMA per loop.

Patch mirror: https://github.com/Nefelim4ag/linux/commit/be6a94e171bf214a26f8186bb76b1d365ccb3b08

Thanks, any comments are appricated!

(Yes i can split patch, but it's RFC and it's too small)

1. https://lkml.org/lkml/2014/11/8/208

Timofey Titovets (1):
  ksm: allow dedup all tasks memory

 Documentation/vm/ksm.txt |   3 +
 mm/ksm.c                 | 139 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 121 insertions(+), 21 deletions(-)

--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
