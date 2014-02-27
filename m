Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDBE6B0071
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 17:34:58 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so3007051pdj.40
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 14:34:58 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n8si655333pab.319.2014.02.27.14.34.56
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 14:34:57 -0800 (PST)
Message-ID: <530FBD8F.7090304@linux.intel.com>
Date: Thu, 27 Feb 2014 14:34:55 -0800
From: Dave Hansen <dave.hansen@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 1/2] mm: introduce vm_ops->map_pages()
References: <1393530827-25450-1-git-send-email-kirill.shutemov@linux.intel.com>	<1393530827-25450-2-git-send-email-kirill.shutemov@linux.intel.com>	<530FB55F.2070106@linux.intel.com> <CA+55aFzUYTHXcVnZL0vTGRPh3oQ8qYGO9+Va1Ch3P1yX+9knDg@mail.gmail.com>
In-Reply-To: <CA+55aFzUYTHXcVnZL0vTGRPh3oQ8qYGO9+Va1Ch3P1yX+9knDg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, anton@samba.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 02/27/2014 02:06 PM, Linus Torvalds wrote:
> On Thu, Feb 27, 2014 at 1:59 PM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> Also, the folks with larger base bage sizes probably don't want a
>> FAULT_AROUND_ORDER=4.  That's 1MB of fault-around for ppc64, for example.
> 
> Actually, I'd expect that they won't mind, because there's no real
> extra cost (the costs are indepenent of page size).

The question is really whether or not we ever access the mapping that we
faulted around, though.  If we never access it, then the cost (however
small it was) is a loss.  That's the mechanism that I'd expect causes
Kirill's numbers to go up after they hit their minimum at ~order-4.

> For small mappings the mapping size itself will avoid the
> fault-around, and for big mappings they'll get the reduced page
> faults.

Kirill's git test suite runs did show that it _can_ hurt in some cases.
 Orders 1 to 4 were improvements.  But, Order-5 was even with the
baseline, and orders 7 and 9 got a bit worse:

> Git test suite (make -j60 test)
> FAULT_AROUND_ORDER		Baseline	1		3		4		5		7		9
> 	minor-faults		129,591,823	99,200,751	66,106,718	57,606,410	51,510,808	45,776,813	44,085,515
> 	time, seconds		66.087215026	64.784546905	64.401156567	65.282708668	66.034016829	66.793780811	67.237810413


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
