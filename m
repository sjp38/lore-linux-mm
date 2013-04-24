Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 841F56B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 05:57:14 -0400 (EDT)
Message-ID: <5177AC75.7090101@redhat.com>
Date: Wed, 24 Apr 2013 11:57:09 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swap: redirty page if page write fails on swap file
References: <516E918B.3050309@redhat.com> <20130422133746.ffbbb70c0394fdbf1096c7ee@linux-foundation.org>
In-Reply-To: <20130422133746.ffbbb70c0394fdbf1096c7ee@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On 04/22/2013 10:37 PM, Andrew Morton wrote:
> On Wed, 17 Apr 2013 14:11:55 +0200 Jerome Marchand <jmarchan@redhat.com> wrote:
> 
>>
>> Since commit 62c230b, swap_writepage() calls direct_IO on swap files.
>> However, in that case page isn't redirtied if I/O fails, and is therefore
>> handled afterwards as if it has been successfully written to the swap
>> file, leading to memory corruption when the page is eventually swapped
>> back in.
>> This patch sets the page dirty when direct_IO() fails. It fixes a memory
>> corruption that happened while using swap-over-NFS.
>>
>> ...
>>
>> --- a/mm/page_io.c
>> +++ b/mm/page_io.c
>> @@ -222,6 +222,8 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>>  		if (ret == PAGE_SIZE) {
>>  			count_vm_event(PSWPOUT);
>>  			ret = 0;
>> +		} else {
>> +			set_page_dirty(page);
>>  		}
>>  		return ret;
>>  	}
> 
> So what happens to the page now?  It remains dirty and the kernel later
> tries to write it again?

Yes. Also, AS_EIO or AS_ENOSPC is set to the address space flags (in this
case, swapper_space).

> And if that write also fails, the page is
> effectively leaked until process exit?

AFAICT, there is no special handling for that page afterwards, so if all
subsequent attempts fail, it's indeed going to stay in memory until freed.

Jerome


> 
> 
> Aside: Mel, __swap_writepage() is fairly hair-raising.  It unlocks the
> page before doing the IO and doesn't set PageWriteback().  Why such an
> exception from normal handling?
> 
> Also, what is protecting the page from concurrent reclaim or exit()
> during the above swap_writepage()?
> 
> Seems that the code needs a bunch of fixes or a bunch of comments
> explaining why it is safe and why it has to be this way.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
