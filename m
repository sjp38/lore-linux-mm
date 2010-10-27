Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F1A3B6B0099
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 14:37:32 -0400 (EDT)
Received: by gyh20 with SMTP id 20so709563gyh.14
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 11:37:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
Date: Wed, 27 Oct 2010 12:37:31 -0600
Message-ID: <AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 12:22 PM, Nick Piggin <npiggin@gmail.com> wrote:
> On Wed, Oct 27, 2010 at 12:05 PM, Rik van Riel <riel@redhat.com> wrote:
>> On 10/27/2010 01:21 PM, Ying Han wrote:
>>>
>>> kswapd's use case of hardware PTE accessed bit is to approximate page L=
RU.
>>> =A0The
>>> ActiveLRU demotion to InactiveLRU are not base on accessed bit, while i=
t
>>> is only
>>> used to promote when a page is on inactive LRU list. =A0All of the stat=
e
>>> transitions
>>> are triggered by memory pressure and thus has weak relationship with
>>> respect to
>>> time. =A0In addition, hardware already transparently flush tlb whenever=
 CPU
>>> context
>>> switch processes and given limited hardware TLB resource, the time peri=
od
>>> in
>>> which a page is accessed but not yet propagated to struct page is very
>>> small
>>> in practice. With the nature of approximation, kernel really don't need=
 to
>>> flush TLB
>>> for changing PTE's access bit. =A0This commit removes the flush operati=
on
>>> from it.
>>>
>>> Signed-off-by: Ying Han<yinghan@google.com>
>>> Singed-off-by: Ken Chen<kenchen@google.com>
>>
>> The reasoning behind the patch makes sense.
>>
>> However, have you measured any improvements in run time with
>> this patch? =A0The VM is already tweaked to minimize the number
>> of pages that get aged, so it would be interesting to know
>> where you saw issues.
>
> Firstly, not all CPUs do flush the TLB on VM switch, and secondly, it
> would be theoretically possible to spin and never be able to flush free
> pages even if none are ever being touched.
>
> It doesn't have to be an absurdly tiny machine, either. You could cover
> a good few megs with TLBs (and a small embedded system could easily
> have less than that of mapped memory on its LRU).
>
> I agree the theory is fine because if the CPU thinks it is worth to keep =
a
> TLB entry around, then it probably knows better than our stupid LRU :)
> And TLB flushing can get nasty when we start swapping a lot with
> threaded apps.
>
> However, to handle corner cases it should either:
>
> flush all TLBs once per *something* [eg. every scan priority level above =
N,
> or every N pages scanned, etc]
>
> start doing the flush versions of the ptep manipulation when memory
> pressure is getting high.
>

I'm sorry, that's absurd, ignore that :)

However, it's a scary change -- higher chance of reclaiming a TLB covered p=
age.

I had a vague memory of this problem biting someone when this flush wasn't
actually done properly... maybe powerpc.

But anyway, same solution could be possible, by flushing every N pages scan=
ned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
