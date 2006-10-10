Message-ID: <452AEF02.20203@yahoo.com.au>
Date: Tue, 10 Oct 2006 10:53:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc] 2.6.19-rc1-git5: consolidation of file backed fault	handlers
References: <20061009140354.13840.71273.sendpatchset@linux.site>	 <1160427472.7752.15.camel@localhost.localdomain> <1160427638.7752.17.camel@localhost.localdomain>
In-Reply-To: <1160427638.7752.17.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Tue, 2006-10-10 at 06:57 +1000, Benjamin Herrenschmidt wrote:
> 
>>On Mon, 2006-10-09 at 18:12 +0200, Nick Piggin wrote:
>>
>>>OK, I've cleaned up and further improved this patchset, removed duplication
>>>while retaining legacy nopage handling, restored page_mkwrite to the ->fault
>>>path (due to lack of users upstream to attempt a conversion), converted the
>>>rest of the filesystems to use ->fault, restored MAP_POPULATE and population
>>>of remap_file_pages pages, replaced nopfn completely, and removed
>>>NOPAGE_REFAULT because that can be done easily with ->fault.
>>
>>What is the replacement ?
> 
> 
> I see ... so we now use PTR_ERR to return errors and NULL for refault...
> good for me but Andrew may want more...

The fault handler puts its desired return type into fault_data.type, and
returns NULL if there is no page to install, otherwise the pointer to
the struct page.

So you'd just set VM_FAULT_MINOR and return NULL, after doing the
vm_insert_pfn thing.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
