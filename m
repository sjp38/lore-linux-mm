Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 383BB8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 12:15:00 -0500 (EST)
Message-ID: <4D63EF18.5080807@linux.intel.com>
Date: Tue, 22 Feb 2011 09:15:04 -0800
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] Preserve local node for KSM copies
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-4-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102220945210.16060@router.home> <20110222162011.GD13092@random.random>
In-Reply-To: <20110222162011.GD13092@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lwoodman@redhat.com

On 2/22/2011 8:20 AM, Andrea Arcangeli wrote:
> On Tue, Feb 22, 2011 at 09:47:26AM -0600, Christoph Lameter wrote:
>> On Mon, 21 Feb 2011, Andi Kleen wrote:
>>
>>> Add a alloc_page_vma_node that allows passing the "local" node in.
>>> Use it in ksm to allocate copy pages on the same node as
>>> the original as possible.
>> Why would that be useful? The shared page could be on a node that is not
>> near the process that maps the page. Would it not be better to allocate on
>> the node that is local to the process that maps the page?
> This is what I was trying to understand. To me it looks like this is
> making things worse. Following the "vma" advice like current code

The problem is: most people use local policy and for that the correct node
is the node that the memory got allocated on.

You cannot get that information from the vma because the vma just says
"local"

If you don't use that node the daemon will arbitarily destroy memory 
locality.
In fact this has happened. This is really bad regression caused by THP.

Now full KSM locality is more difficult (obviously you can have a 
conflict), but
keeping it on the original node is still the most predictable. At least 
you won't
make anything worse for that process.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
