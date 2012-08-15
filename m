Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 073626B0044
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 12:35:42 -0400 (EDT)
Received: by yhr47 with SMTP id 47so2404659yhr.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 09:35:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com>
References: <1345045084-7292-1-git-send-email-js1304@gmail.com>
	<000001392af5ab4e-41dbbbe4-5808-484b-900a-6f4eba102376-000000@email.amazonses.com>
Date: Thu, 16 Aug 2012 01:35:41 +0900
Message-ID: <CAAmzW4M9WMnxVKpR00SqufHadY-=i0Jgf8Ktydrw5YXK8VwJ7A@mail.gmail.com>
Subject: Re: [PATCH] slub: try to get cpu partial slab even if we get enough
 objects for cpu freelist
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/16 Christoph Lameter <cl@linux.com>:
> On Thu, 16 Aug 2012, Joonsoo Kim wrote:
>
>> s->cpu_partial determine the maximum number of objects kept
>> in the per cpu partial lists of a processor. Currently, it is used for
>> not only per cpu partial list but also cpu freelist. Therefore
>> get_partial_node() doesn't work properly according to our first intention.
>
> The "cpu freelist" in slub is the number of free objects in a specific
> page. There is nothing that s->cpu_partial can do about that.
>
> Maybe I do not understand you correctly. Could you explain this in some
> more detail?

I assume that cpu slab and cpu partial slab are not same thing.

In my definition,
cpu slab is in c->page,
cpu partial slab is in c->partial

When we have no free objects in cpu slab and cpu partial slab, we try
to get slab via get_partial_node().
In that function, we call acquire_slab(). Then we hit "!object" case
(for cpu slab).
In that case, we test available with s->cpu_partial.

I think that s->cpu_partial is for cpu partial slab, not cpu slab.
So this test is not proper.
This patch is for correcting this.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
