Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 39BBF6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 21:47:22 -0500 (EST)
Received: by iwn4 with SMTP id 4so259701iwn.14
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:47:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4CE40129.9060103@redhat.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
	<877hgmr72o.fsf@gmail.com>
	<20101114140920.E013.A69D9226@jp.fujitsu.com>
	<AANLkTim59Qx6TsvXnTBL5Lg6JorbGaqx3KsdBDWO04X9@mail.gmail.com>
	<1289810825.2109.469.camel@laptop>
	<AANLkTikibS1fDuk67RHk4SU14pJ9nPdodWba1T3Z_pWE@mail.gmail.com>
	<4CE14848.2060805@redhat.com>
	<AANLkTi=6RtPDnZZa=jrcciB1zHQMiB3LnouBw3G2OyaK@mail.gmail.com>
	<4CE40129.9060103@redhat.com>
Date: Thu, 18 Nov 2010 11:47:17 +0900
Message-ID: <AANLkTin2fXGOAdGNegDhijjo_kV7nOBJP_hagjgoYdtX@mail.gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Gamari <bgamari.foss@gmail.com>, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 1:22 AM, Rik van Riel <riel@redhat.com> wrote:
> On 11/17/2010 05:16 AM, Minchan Kim wrote:
>
>> Absolutely. But how about rsync's two touch?
>> It can evict working set.
>>
>> I need the time for investigation.
>> Thanks for the comment.
>
> Maybe we could exempt MADV_SEQUENTIAL and FADV_SEQUENTIAL
> touches from promoting the page to the active list?
>

The problem is non-mapped file page.
non-mapped file page promotion happens by only mark_page_accessed.
But it doesn't enough information to prevent promotion(ex, vma or file)
Hmm.. Do other guys have any idea?

Here is another idea.
Current problem is following as.
User can use fadivse with FADV_DONTNEED.
But problem is that it can't affect when it meet dirty pages.
So user have to sync dirty page before calling fadvise with FADV_DONTNEED.
It would lose performance.

Let's add some semantic of FADV_DONTNEED.
It invalidates only pages which are not dirty.
If it meets dirty page, let's move the page into inactive's tail or head.
If we move the page into tail, shrinker can move it into head again
for deferred write if it isn't written the backed device.


> Then we just need to make sure rsync uses fadvise properly
> to keep the working set protected from rsync.
>
> --
> All rights reversed
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
