Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 847F76B005A
	for <linux-mm@kvack.org>; Sun, 24 May 2009 22:38:56 -0400 (EDT)
Message-ID: <4A1A057A.3080203@oracle.com>
Date: Sun, 24 May 2009 19:42:02 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <20090524144056.0849.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090524144056.0849.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
> I have two question.
> 
> 
>> Subject: Warn if we run out of swap space
>>
>> Running out of swap space means that the evicton of anonymous pages may no longer
>> be possible which can lead to OOM conditions.
>>
>> Print a warning when swap space first becomes exhausted.
>>
>> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>>
>> ---
>>  mm/swapfile.c |    5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> Index: linux-2.6/mm/swapfile.c
>> ===================================================================
>> --- linux-2.6.orig/mm/swapfile.c	2009-05-22 12:25:19.000000000 -0500
>> +++ linux-2.6/mm/swapfile.c	2009-05-22 13:56:10.000000000 -0500
>> @@ -380,6 +380,7 @@ swp_entry_t get_swap_page(void)
>>  	pgoff_t offset;
>>  	int type, next;
>>  	int wrapped = 0;
>> +	static int printed = 0;
>>
>>  	spin_lock(&swap_lock);
>>  	if (nr_swap_pages <= 0)
>> @@ -410,6 +411,10 @@ swp_entry_t get_swap_page(void)
>>  	}
>>
>>  	nr_swap_pages++;
>> +	if (!printed) {
>> +		printed = 1;
>> +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
>> +	}
> 
> Why don't you use WARN_ONCE()?

Someone earlier in this patch thread (maybe Pavel?) commented that
WARN_ONCE() would cause a stack dump and that would be too harsh,
especially for users.  I.e., just the message is needed here, not a
stack dump.

> lumpy reclaim on no swap system makes this warnings, right?
> if so, I think it's a bit annoy.
> 
> 
> 
>>  noswap:
>>  	spin_unlock(&swap_lock);
>>  	return (swp_entry_t) {0};


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
