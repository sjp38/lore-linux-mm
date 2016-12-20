Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14A3A6B02CF
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 19:20:07 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 71so169017590ioe.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 16:20:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n195si3109637ita.23.2016.12.19.16.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 16:20:06 -0800 (PST)
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
 <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
Date: Mon, 19 Dec 2016 16:20:05 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, mgorman@techsingularity.net, linux-mm@kvack.org

On 12/19/2016 03:07 PM, Linus Torvalds wrote:
>     +wait_queue_head_t *bit_waitqueue(void *word, int bit)
>     +{
>     +       const int __maybe_unused nid = page_to_nid(virt_to_page(word));
>     +
>     +       return __bit_waitqueue(word, bit, nid);
> 
> No can do. Part of the problem with the old coffee was that it did that
> virt_to_page() crud. That doesn't work with the virtually mapped stack. 

Ahhh, got it.

So, what did you have in mind?  Just redirect bit_waitqueue() to the
"first_online_node" waitqueues?

wait_queue_head_t *bit_waitqueue(void *word, int bit)
{
        return __bit_waitqueue(word, bit, first_online_node);
}

We could do some fancy stuff like only do virt_to_page() for things in
the linear map, but I'm not sure we'll see much of a gain for it.  None
of the other waitqueue users look as pathological as the 'struct page'
ones.  Maybe:

wait_queue_head_t *bit_waitqueue(void *word, int bit)
{
	int nid
	if (word >= VMALLOC_START) /* all addrs not in linear map */
		nid = first_online_node;
	else
		nid = page_to_nid(virt_to_page(word));
        return __bit_waitqueue(word, bit, nid);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
