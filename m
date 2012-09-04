Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A570F6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 06:34:39 -0400 (EDT)
Received: by iec9 with SMTP id 9so5701835iec.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 03:34:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5045D4B9.9000909@parallels.com>
References: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com>
	<5045D4B9.9000909@parallels.com>
Date: Tue, 4 Sep 2012 07:34:38 -0300
Message-ID: <CALF0-+WZhY5NOYiEdDR2n_JrCKB70jei55pEw=914aSWmeqhNg@mail.gmail.com>
Subject: Re: [PATCH v2] mm, slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi Glauber,

On Tue, Sep 4, 2012 at 7:15 AM, Glauber Costa <glommer@parallels.com> wrote:
> On 09/04/2012 02:13 PM, Ezequiel Garcia wrote:
>> This field was being used to store size allocation so it could be
>> retrieved by ksize(). However, it is a bad practice to not mark a page
>> as a slab page and then use fields for special purposes.
>> There is no need to store the allocated size and
>> ksize() can simply return PAGE_SIZE << compound_order(page).
>
> What happens for allocations smaller than a page?
> It seems you are breaking ksize for those.
>

Allocations smaller than a page save its own size on a header
located at each returned pointer. This is documented at the beginning of slob:

"Above this is an implementation of kmalloc/kfree. Blocks returned
from kmalloc are prepended with a 4-byte header with the kmalloc size."

For this objects (smaller than a page) ksize works fine:

size_t ksize(const void *block) {
[...]
  unsigned int *m = (unsigned int *)(block - align);
  return SLOB_UNITS(*m) * SLOB_UNIT;

(see how ksize substract 'align' from block to find the header?)

Of course, it's possible I've overlooked something, but I think this
should work.

Thanks!
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
