Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AD90760021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 22:08:31 -0500 (EST)
Message-ID: <4B15D9F8.9090800@redhat.com>
Date: Tue, 01 Dec 2009 22:07:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Clear reference bit although page isn't mapped.
References: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com> <20091201102645.5C0A.A69D9226@jp.fujitsu.com> <20091202115358.5C4F.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091202115358.5C4F.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/01/2009 09:55 PM, KOSAKI Motohiro wrote:
>> btw, current shrink_active_list() have unnecessary page_mapping_inuse() call.
>> it prevent to drop page reference bit from unmapped cache page. it mean
>> we protect unmapped cache page than mapped page. it is strange.
>>      
> How about this?
>
> ---------------------------------
> SplitLRU VM replacement algorithm assume shrink_active_list() clear
> the page's reference bit. but unnecessary page_mapping_inuse() test
> prevent it.
>
> This patch remove it.
>    
Shrink_page_list ignores the referenced bit on pages
that are !page_mapping_inuse().

                 if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
                                         referenced && 
page_mapping_inuse(page)
&& !(vm_flags & VM_LOCKED))
                         goto activate_locked;

The reason we leave the referenced bit on unmapped
pages is that we want the next reference to a deactivated
page cache page to move that page back to the active
list.  We do not want to require that such a page gets
accessed twice before being reactivated while on the
inactive list, because (1) we know it was a frequently
accessed page already and (2) ongoing streaming IO
might evict it from the inactive list before it gets accessed
twice.

Arguably, we should just replace the page_mapping_inuse()
in both places with page_mapped() to simplify things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
