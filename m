Message-ID: <41E42268.5090404@mvista.com>
Date: Tue, 11 Jan 2005 11:00:56 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: Re: page migration patchset
References: <41DB35B8.1090803@sgi.com> <m1wtusd3y0.fsf@muc.de> <41DB5CE9.6090505@sgi.com> <41DC34EF.7010507@mvista.com> <41E3F2DA.5030900@sgi.com>
In-Reply-To: <41E3F2DA.5030900@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, andrew morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Ray Bryant wrote:

> Andi and Steve,
>
> Steve Longerbeam wrote:
> <snip>
>
>>>
>>> My personal preference would be to keep as much of this as possible
>>> under user space control; that is, rather than having a big autonomous
>>> system call that migrates pages and then updates policy information,
>>> I'd prefer to split the work into several smaller system calls that
>>> are issued by a user space program responsible for coordinating the
>>> process migration as a series of steps, e. g.:
>>>
>>> (1)  suspend the process via SIGSTOP
>>> (2)  update the mempolicy information
>>> (3)  migrate the process's pages
>>> (4)  migrate the process to the new cpu via set_schedaffinity()
>>> (5)  resume the process via SIGCONT
>>>
>>
>> steps 2 and 3 can be accomplished by a call to mbind() and
>> specifying MPOL_MF_MOVE. And since mbind() takes an
>> address range, you could probably migrate pages and change
>> the policies for all of the process' mappings in a single mbind()
>> call.
>
>
> OK, I just got around to looking into this suggestion.  Unfortunately,
> it doesn't look as if this will do what I want.  I need to be able to
> conserve the topology of the application when it is migrated (required
> to give the application the same performance in its new location that
> it got in its old location).


I see what you mean, unless the requested address range exactly
fits within an existing vma, existing vma's will get split up.

>   So, I need to be able to say "take the
> pages on this node and move them to that node".  The sys_mbind() call
> doesn't have the necessry arguments to do this.  I'm thinking of
> something like:
>
> migrate_process_pages(pid, numnodes, oldnodelist, newnodelist);
>
> This would scan the address space of process pid, and each page that
> is found on oldnodelist[i] would be moved to node newnodelist[i].


right, that's something I'd be interested in as well. In fact, an address
range is not ideal for me either - what I really need is an API that
allows me to specify a single existing vma (or all the process'
regions in your case) that is to have its policy changed and resident
pages migrated, without changing the topology (eg. split vma's).

>
> Pages that are found to be swapped out would be handled as follows:
> Add the original node id to either the swap pte or the swp_entry_t.
> Swap in will be modified to allocate the page on the same node it
> came from.  Then, as part of migrate_process_pages, all that would
> be done for swapped out pages would be to change the "original node"
> field to point at the new node.


isn't this already taken care of? read_swap_cache_async() is given
a vma, and passes it to alloc_page_vma(). So if you have earlier
changed the policy for that vma, the new policy will be used
when allocating the page during the swap in.

Steve
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
