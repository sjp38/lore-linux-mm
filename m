Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57F096B02DF
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 21:31:33 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so450731344pgc.1
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:31:33 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id n28si20129959pgd.148.2016.12.19.18.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 18:31:32 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id i5so505809pgh.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:31:32 -0800 (PST)
Date: Tue, 20 Dec 2016 12:31:13 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161220123113.1e1de7b0@roar.ozlabs.ibm.com>
In-Reply-To: <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, mgorman@techsingularity.net, linux-mm@kvack.org

On Mon, 19 Dec 2016 16:20:05 -0800
Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 12/19/2016 03:07 PM, Linus Torvalds wrote:
> >     +wait_queue_head_t *bit_waitqueue(void *word, int bit)
> >     +{
> >     +       const int __maybe_unused nid = page_to_nid(virt_to_page(word));
> >     +
> >     +       return __bit_waitqueue(word, bit, nid);
> > 
> > No can do. Part of the problem with the old coffee was that it did that
> > virt_to_page() crud. That doesn't work with the virtually mapped stack.   
> 
> Ahhh, got it.
> 
> So, what did you have in mind?  Just redirect bit_waitqueue() to the
> "first_online_node" waitqueues?
> 
> wait_queue_head_t *bit_waitqueue(void *word, int bit)
> {
>         return __bit_waitqueue(word, bit, first_online_node);
> }
> 
> We could do some fancy stuff like only do virt_to_page() for things in
> the linear map, but I'm not sure we'll see much of a gain for it.  None
> of the other waitqueue users look as pathological as the 'struct page'
> ones.  Maybe:
> 
> wait_queue_head_t *bit_waitqueue(void *word, int bit)
> {
> 	int nid
> 	if (word >= VMALLOC_START) /* all addrs not in linear map */
> 		nid = first_online_node;
> 	else
> 		nid = page_to_nid(virt_to_page(word));
>         return __bit_waitqueue(word, bit, nid);
> }

I think he meant just make the page_waitqueue do the per-node thing
and leave bit_waitqueue as the global bit.

It would be cool if CPUs had an instruction that translates an address
though. You could avoid all that lookup and just do it with the TLB :)

Thanks,
Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
