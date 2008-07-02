Received: by rv-out-0708.google.com with SMTP id f25so219656rvb.26
        for <linux-mm@kvack.org>; Tue, 01 Jul 2008 22:00:25 -0700 (PDT)
Message-ID: <28c262360807012200x27711a0fq280504b00096f7e6@mail.gmail.com>
Date: Wed, 2 Jul 2008 14:00:25 +0900
From: "MinChan Kim" <minchan.kim@gmail.com>
Subject: Re: [resend][PATCH -mm] split_lru: fix pagevec_move_tail() doesn't treat unevictable page
In-Reply-To: <20080702122850.380B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080701093840.07b48ced@bree.surriel.com>
	 <28c262360807011739w5668920buf7880de6ed30f912@mail.gmail.com>
	 <20080702122850.380B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 2, 2008 at 12:30 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Kim-san,
>
>> Hi, Rik and Kosaki-san
>>
>> I want to know exact race situation for remaining git log.
>> As you know, git log is important for me who is newbie to understand source
>>
>> There are many possibility in this race problem.
>>
>> Did you use hugepage in this test ?
>> I think that If you used hugepage, it seems to happen following race.
>
> I don't use hugepage. but use SYSV-shmem.
> so following scenario is very reasonable.

It is not reasonable if you don't use hugepage.
That's because file's address_space is still unevictable.
Am I missing your point?

I think following case is more reasonable rather than it,
Please, Let you review this scenario.
---

CPU1							CPU2

shrink_[in]active_list
cull_unevictable_page
putback_lru_page
TestClearPageUnevicetable
						rotate_reclaimable_page
						!PageUnevictable(page)
add_page_to_unevictable_list
						pagevec_move_tail



> OK.
> I resend my patch with following description.
>
>
>>
>> --------------
>>
>> CPU1                                                           CPU2
>>
>> shm_unlock
>> scan_mapping_unevictable_pages
>> check_move_unevictable_page
>> ClearPageUnevictable                                 rotate_reclaimable_page
>>
>> PageUnevictable(page) return 0
>> SetPageUnevictable
>> list_move(LRU_UNEVICTABLE)
>>
>> local_irq_save
>>
>> pagevec_move_tail
>>
>> Do you think it is possible ?
>
>
>



-- 
Kinds regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
