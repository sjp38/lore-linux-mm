Received: by wf-out-1314.google.com with SMTP id 28so2657859wfc.11
        for <linux-mm@kvack.org>; Tue, 21 Oct 2008 10:18:26 -0700 (PDT)
Message-ID: <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
Date: Wed, 22 Oct 2008 02:18:26 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mlock: mlocked pages are unevictable
In-Reply-To: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200810201659.m9KGxtFC016280@hera.kernel.org>
	 <20081021151301.GE4980@osiris.boeblingen.de.ibm.com>
	 <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2008/10/22 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> Hi
>
>> I think the following part of your patch:
>>
>>> diff --git a/mm/swap.c b/mm/swap.c
>>> index fee6b97..bc58c13 100644
>>> --- a/mm/swap.c
>>> +++ b/mm/swap.c
>>> @@ -278,7 +278,7 @@ void lru_add_drain(void)
>>>       put_cpu();
>>>  }
>>>
>>> -#ifdef CONFIG_NUMA
>>> +#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
>>>  static void lru_add_drain_per_cpu(struct work_struct *dummy)
>>>  {
>>>       lru_add_drain();
>>
>> causes this (allyesconfig on s390):
>
> hm,
>
> I don't think so.
>
> Actually, this patch has
>   mmap_sem -> lru_add_drain_all() dependency.
>
> but its dependency already exist in another place.
> example,
>
>  sys_move_pages()
>      do_move_pages()  <- down_read(mmap_sem)
>          migrate_prep()
>               lru_add_drain_all()
>
> Thought?

ok. maybe I understand this issue.

This bug is caused by folloing dependencys.

some VM place has
      mmap_sem -> kevent_wq

net/core/dev.c::dev_ioctl()  has
     rtnl_lock  ->  mmap_sem        (*) almost ioctl has
copy_from_user() and it cause page fault.

linkwatch_event has
    kevent_wq -> rtnl_lock


So, I think VM subsystem shouldn't use kevent_wq because many driver
use ioctl and work queue combination.
then drivers fixing isn't easy.

I'll make the patch soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
