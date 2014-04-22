Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0D26B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:23:35 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so4092770eek.15
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 21:23:34 -0700 (PDT)
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
        by mx.google.com with ESMTPS id 45si57751070eeh.123.2014.04.21.21.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 21:23:33 -0700 (PDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so4052733eek.24
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 21:23:33 -0700 (PDT)
Message-ID: <5355EEC2.4010304@colorfullife.com>
Date: Tue, 22 Apr 2014 06:23:30 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398101106.2623.6.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1398101106.2623.6.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/21/2014 07:25 PM, Davidlohr Bueso wrote:
> On Mon, 2014-04-21 at 16:26 +0200, Manfred Spraul wrote:
>> Hi all,
>>
>> the increase of SHMMAX/SHMALL is now a 4 patch series.
>> I don't have ideas how to improve it further.
> Manfred, is there any difference between this set and the one you sent a
> couple of days ago?
a) I updated the comments.
b) the initial set used TASK_SIZE, not I switch to ULONG_MAX-(1L<<24)

>>    - Using "0" as a magic value for infinity is even worse, because
>>      right now 0 means 0, i.e. fail all allocations.
> Sorry but I don't quite get this. Using 0 eliminates the need for all
> these patches, no? I mean overflows have existed since forever, and
> taking this route would naturally solve the problem. 0 allocations are a
> no no anyways.
No. The patches are required to handle e.g. shmget(,ULONG_MAX,):
Right now, shmget(,ULONG_MAX,) results in a 0-byte segment.

The risk of using 0 is that it reverses the current behavior:
Up to now,
     # sysctl kernel.shmall=0
disables allocations.
If we define 0 a infinity, then the same configuration would allow 
unlimited allocations.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
