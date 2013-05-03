Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D25706B02CC
	for <linux-mm@kvack.org>; Fri,  3 May 2013 05:12:48 -0400 (EDT)
Message-ID: <51837F8C.4080801@redhat.com>
Date: Fri, 03 May 2013 11:12:44 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
References: <516E918B.3050309@redhat.com> <516F3AA7.1000908@gmail.com> <5180C6C1.6010000@gmail.com>
In-Reply-To: <5180C6C1.6010000@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

On 05/01/2013 09:39 AM, Simon Jeons wrote:
> Ping, ;-)
> On 04/18/2013 08:13 AM, Simon Jeons wrote:
>> Hi Jerome,
>> On 04/17/2013 08:11 PM, Jerome Marchand wrote:
>>> Since commit 62c230b, swap_writepage() calls direct_IO on swap files.
>>> However, in that case page isn't redirtied if I/O fails, and is 
>>> therefore
>>> handled afterwards as if it has been successfully written to the swap
>>> file, leading to memory corruption when the page is eventually swapped
>>> back in.
>>> This patch sets the page dirty when direct_IO() fails. It fixes a memory
>>
>> If swapfile has related page cache which cached swapfile in memory? It 
>> is not necessary, correct?

I'm not sure I understand the question. What I can tell you is that it is 
necessary if the swapfile is located on a fs that uses swap_activate (only
NFS so far). Other swap file hasn't been impacted by commit 62c230b.

>>
>>> corruption that happened while using swap-over-NFS.
>>>
>>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>>> ---
>>>   mm/page_io.c |    2 ++
>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/mm/page_io.c b/mm/page_io.c
>>> index 78eee32..04ca00d 100644
>>> --- a/mm/page_io.c
>>> +++ b/mm/page_io.c
>>> @@ -222,6 +222,8 @@ int swap_writepage(struct page *page, struct 
>>> writeback_control *wbc)
>>>           if (ret == PAGE_SIZE) {
>>>               count_vm_event(PSWPOUT);
>>>               ret = 0;
>>> +        } else {
>>> +            set_page_dirty(page);
>>>           }
>>>           return ret;
>>>       }
>>>
>>> -- 
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
