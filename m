Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC786B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 14:55:35 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4AItX2G014980
	for <linux-mm@kvack.org>; Tue, 10 May 2011 11:55:33 -0700
Received: from gyf2 (gyf2.prod.google.com [10.243.50.66])
	by wpaz37.hot.corp.google.com with ESMTP id p4AItWlZ015421
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 11:55:32 -0700
Received: by gyf2 with SMTP id 2so3215467gyf.11
        for <linux-mm@kvack.org>; Tue, 10 May 2011 11:55:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DC90AE8.101@parallels.com>
References: <4DAFD0B1.9090603@parallels.com>
	<20110421064150.6431.84511.stgit@localhost6>
	<20110421124424.0a10ed0c.akpm@linux-foundation.org>
	<4DB0FE8F.9070407@parallels.com>
	<alpine.LSU.2.00.1105031223120.9845@sister.anvils>
	<4DC4D9A6.9070103@parallels.com>
	<alpine.LSU.2.00.1105071621330.3668@sister.anvils>
	<4DC691D0.6050104@parallels.com>
	<alpine.LSU.2.00.1105081234240.15963@sister.anvils>
	<4DC90AE8.101@parallels.com>
Date: Tue, 10 May 2011 11:55:26 -0700
Message-ID: <BANLkTi=pev65quykAhp6SeisxyW7=A3fGA@mail.gmail.com>
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, May 10, 2011 at 2:52 AM, Konstantin Khlebnikov
<khlebnikov@parallels.com> wrote:
> Hugh Dickins wrote:
>>
>> On Sun, 8 May 2011, Konstantin Khlebnikov wrote:
>>>
>>> Ok, I can test final patch-set on the next week.
>>> Also I can try to add some swapoff test-cases.
>>
>> That would be helpful if you have the time: thank you.
>
> I Confirm, patch 1/3 really fixes race between writepage and umount, as
> expected.

Good, thank you (but that path was identical to what you'd already tested).

>
> In patch 2/3: race-window between unlock_page and iput extremely small.

(I should clarify that the main race window is actually much wider
than that.  That page lock is only effective at holding off
shmem_evict_inode() while the page is in the file's pagecache -
between the (old positioning of) mutex_unlock(&shmem_swaplist_mutex)
and the add_to_page_cache_locked(), the page is just in swapcache and
so not recognizably attached to the file: shmem_evict_inode() will
call shmem_truncate_range(), and that would find the swp_entry_t, but
it frees it with a free_swap_and_cache() - which does not wait if it
cannot trylock the page.)

> My test works fine in parallel with thirty random swapon-swapoff,
> but it works without this patch too, thus I cannot catch this race.

Thanks for trying.  Given my difficulty in reproducing your umount
case, I'm not at all surprised that you didn't manage to reproduce
this swapoff case.  Indeed, I didn't even try to reproduce it myself:
I just saw the theoretical possibility once you'd warned me of
igrab(), and tested that this igrab-less approach works as well as the
old approach, without risking that race.

>
> I apply patch 3/3 too, but have not tested this case.

Fine, that part I could reproduce fairly easily for myself, and the
fix tested out fine.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
