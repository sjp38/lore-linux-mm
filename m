Received: by gv-out-0910.google.com with SMTP id l14so152377gvf.19
        for <linux-mm@kvack.org>; Fri, 10 Oct 2008 06:13:24 -0700 (PDT)
Message-ID: <48EF54EF.6040002@gmail.com>
Date: Fri, 10 Oct 2008 15:13:19 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] page-writeback: fine-grained dirty_ratio and dirty_background_ratio
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com>	<20080912131816.e0cfac7a.akpm@linux-foundation.org>	<532480950809221641y3471267esff82a14be8056586@mail.gmail.com>	<48EB4236.1060100@linux.vnet.ibm.com>	<48EB851D.2030300@gmail.com>	<20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com>	<48ECB215.4040409@linux.vnet.ibm.com>	<48EE236A.90007@gmail.com> <20081010094139.e7f8653d.kamezawa.hiroyu@jp.fujitsu.com> <48EF2138.9050307@gmail.com>
In-Reply-To: <48EF2138.9050307@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@linux-foundation.org>, menage@google.com, dave@linux.vnet.ibm.com, chlunde@ping.uio.no, dpshah@google.com, eric.rannaud@gmail.com, fernando@oss.ntt.co.jp, agk@sourceware.org, m.innocenti@cineca.it, s-uchida@ap.jp.nec.com, ryov@valinux.co.jp, matt@bluehost.com, dradford@bluehost.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
> KAMEZAWA Hiroyuki wrote:
>> <snip>
>>
>>> -int dirty_background_ratio = 5;
>>> +int dirty_background_ratio = 5 * PERCENT_PCM;
>>>  
>>>  /*
>>>   * free highmem will not be subtracted from the total free memory
>>> @@ -77,7 +77,7 @@ int vm_highmem_is_dirtyable;
>>>  /*
>>>   * The generator of dirty data starts writeback at this percentage
>>>   */
>>> -int vm_dirty_ratio = 10;
>>> +int vm_dirty_ratio = 10 * PERCENT_PCM;
>>>  
>>>  /*
>>>   * The interval between `kupdate'-style writebacks, in jiffies
>>> @@ -135,7 +135,8 @@ static int calc_period_shift(void)
>>>  {
>>>  	unsigned long dirty_total;
>>>  
>>> -	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) / 100;
>>> +	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory())
>>> +			/ ONE_HUNDRED_PCM;
>>>  	return 2 + ilog2(dirty_total - 1);
>>>  }
>>>  
>> I wonder...isn't this overflow in 32bit system ?
> 
> Correct! the worst case is (in pages):
> 
> 4GB = 100,000 * determine_dirtyable_memory()
> 
> that means 42950 pages (~168MB) of dirtyable memory is enough to overflow :(.
> Using an u64 for dirty_total should resolve.
> 
> Delta patch is below.
> 
> Unfortunately I have all 64-bit machines right now. Maybe tomorrow I'll
> be able to get a 32-bit box, if someone doesn't test this before.
> 
> Thanks!
> -Andrea

I've been able to quickly resolve creating a 1GB mem i386 VM with kvm. :)

Everything seems to work fine and with the following fix it doesn't overflow.

-Andrea


> 
> ---
> Subject: fix overflow in 32-bit systems using fine-grained dirty_ratio
> 
> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/page-writeback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 6bc8c9b..29913e5 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -133,7 +133,7 @@ static struct prop_descriptor vm_dirties;
>   */
>  static int calc_period_shift(void)
>  {
> -	unsigned long dirty_total;
> +	u64 dirty_total;
>  
>  	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory())
>  			/ ONE_HUNDRED_PCM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
